<?php

namespace App\Http\Controllers;

use App\Events\PushChatMessageEvent;
use App\Models\ChatRoom;
use App\Models\ChatRoomMember;
use App\Models\ChatRoomMessage;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class ChatController extends Controller
{
    private $fileRules = [
        'IMAGE' => ['file' => 'required|image|max:10000'],
        'TEXT'  => ['content' => 'required|string'],
        'FILE'  => ['file' => 'required|mimes:pdf,doc,docx,pptx|max:10000'],
        'RECORD' => ['file' => 'required|mimes:mp3,wav|max:10000'],
    ];

    /**
     * Get all chat rooms for the authenticated user
     */
    public function getChatRooms()
    {
        $user = Auth::user();

        // Get all rooms where the user is a member
        $rooms = ChatRoom::whereHas('members', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })
            ->with(['members.user', 'messages' => function ($query) {
                $query->latest()->limit(1);
            }])
            ->get();

        // Format the response to include other user info and last message
        $formattedRooms = $rooms->map(function ($room) use ($user) {
            // Get the other user in the room
            $otherUser = $room->members->firstWhere('user_id', '!=', $user->id)?->user;

            return [
                'id' => $room->id,
                'name' => $otherUser?->name ?? 'Unknown',
                'email' => $otherUser?->email ?? '',
                'lastMessage' => $room->messages->first() ? [
                    'id' => $room->messages->first()->id,
                    'senderId' => $room->messages->first()->user_id,
                    'content' => $room->messages->first()->content,
                    'timestamp' => $room->messages->first()->created_at,
                ] : null,
            ];
        });

        return response()->json([
            'status' => true,
            'data' => $formattedRooms
        ]);
    }

    /**
     * Get messages for a specific chat room
     */
    public function getMessages($roomId)
    {
        $user = Auth::user();

        // Verify user has access to this room
        $room = ChatRoom::whereHas('members', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })->findOrFail($roomId);

        // Get messages with sender info
        $messages = ChatRoomMessage::where('chat_room_id', $roomId)
            ->with('user:id,name,email')
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($message) {
                return [
                    'id' => $message->id,
                    'senderId' => $message->user_id,
                    'content' => $message->content,
                    'type' => $message->type,
                    'timestamp' => $message->created_at,
                    'sender' => $message->user,
                ];
            });

        return response()->json([
            'status' => true,
            'data' => $messages
        ]);
    }

    public function provide(Request $request)
    {
        $request->validate([
            'first_user' => 'required|exists:users,id',
            'second_user' => 'required|exists:users,id',
        ]);

        $chats = $this->provideModel(
            $request->first_user,
            $request->second_user
        );

        return response()->json([
            'status' => true,
            'data' => $chats->load('messages')
        ]);
    }

    public function provideModel($first_user, $second_user, $status = 'OPEN')
    {
        $room = ChatRoom::whereHas('members', function ($query) use ($first_user) {
            $query->where('user_id', $first_user);
        })->whereHas('members', function ($query) use ($second_user) {
            $query->where('user_id', $second_user);
        })->first();

        if ($room) {
            return $room;
        }

        // Create new Room
        $room = ChatRoom::create([
            'status' => $status
        ]);

        // Add Members
        $room->members()->createMany([
            ['user_id' => $first_user, 'unread_count' => 0],
            ['user_id' => $second_user, 'unread_count' => 0],
        ]);

        return $room;
    }

    public function searchUsers(Request $request)
    {
        $query = $request->input('query');
        $currentUserId = auth()->id();

        $users = User::where('email', 'like', "%{$query}%")
            ->where('id', '!=', $currentUserId)
            ->get();

        return response()->json([
            'status' => true,
            'data' => $users
        ]);
    }



    // 2. SEND MESSAGE
    public function send(Request $request, $roomId)
    {
        $type = $request->input('type', 'TEXT');

        // Validate request based on type
        $rules = $this->fileRules[$type] ?? $this->fileRules['TEXT'];
        $request->validate($rules);

        DB::beginTransaction();
        try {
            // Verify user has access to this room
            $room = ChatRoom::whereHas('members', function ($query) {
                $query->where('user_id', auth()->id());
            })->find($roomId);

            if (!$room) {
                return response()->json([
                    'status' => false,
                    'message' => 'Chat room not found or you do not have access to it.'
                ], 404);
            }

            // 2. Handle Content/File
            $content = $request->input('content');

            if ($type !== 'TEXT' && $request->hasFile('file')) {
                $file = $request->file('file');
                $path = $file->store('chat_media', 'public');
                $content = asset('storage/' . $path);
            }

            // 3. Create Message
            $message = ChatRoomMessage::create([
                'chat_room_id' => $room->id,
                'user_id' => auth()->id(), // Sender
                'content' => $content,
                'type' => $type
            ]);

            // Load sender relationship for broadcasting
            $message->load('sender');

            // 4. Update Room timestamp
            $room->update(['updated_at' => now()]);

            // 5. Increment Unread Count for OTHERS
            ChatRoomMember::where('chat_room_id', $room->id)
                ->where('user_id', '!=', auth()->id())
                ->increment('unread_count');

            // 6. Broadcast
            // Get socket ID from header if available for broadcast filtering
            $socketId = $request->header('X-Socket-ID');
            Log::info('🎙️ Broadcasting message to room: ' . $room->id . ', Socket ID: ' . ($socketId ?? 'none'));

            if ($socketId) {
                // Broadcast to others, excluding the sender's socket
                broadcast(new PushChatMessageEvent($message))->toOthers();
            } else {
                // Broadcast to all if no socket ID provided
                broadcast(new PushChatMessageEvent($message));
            }

            Log::info('✅ Broadcast dispatched');

            DB::commit();

            return response()->json([
                'status' => true,
                'data' => $message
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error($e);
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
