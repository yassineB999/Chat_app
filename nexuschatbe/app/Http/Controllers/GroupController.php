<?php

namespace App\Http\Controllers;

use App\Events\GroupUpdated;
use App\Events\MemberAddedToGroup;
use App\Events\MemberRemovedFromGroup;
use App\Events\MemberRoleUpdated;
use App\Models\ChatGroup;
use App\Models\GroupMember;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class GroupController extends Controller
{
    /**
     * Get all groups for authenticated user
     */
    public function index()
    {
        $userId = Auth::id();

        $groups = ChatGroup::whereHas('members', function ($query) use ($userId) {
            $query->where('user_id', $userId);
        })
            ->with(['creator:id,name,email', 'members:id,name,email'])
            ->withCount('members')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($group) use ($userId) {
                return [
                    'id' => $group->id,
                    'name' => $group->name,
                    'description' => $group->description,
                    'avatar' => $group->avatar,
                    'created_by' => $group->created_by,
                    'created_at' => $group->created_at->toISOString(),
                    'member_count' => $group->members_count,
                    'is_admin' => $group->isAdmin($userId),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $groups,
        ]);
    }

    /**
     * Create a new group
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:50',
            'description' => 'nullable|string|max:200',
            'avatar' => 'nullable|image|max:2048',
            'member_ids' => 'required|array|min:1',
            'member_ids.*' => 'exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            DB::beginTransaction();

            $userId = Auth::id();

            // Create group
            $group = ChatGroup::create([
                'name' => $request->name,
                'description' => $request->description,
                'created_by' => $userId,
            ]);

            // Handle avatar upload
            if ($request->hasFile('avatar')) {
                $path = $request->file('avatar')->store('group_avatars', 'public');
                $group->avatar = Storage::url($path);
                $group->save();
            }

            // Add creator as admin
            GroupMember::create([
                'group_id' => $group->id,
                'user_id' => $userId,
                'role' => 'admin',
            ]);

            // Add other members
            foreach ($request->member_ids as $memberId) {
                if ($memberId != $userId) {
                    GroupMember::create([
                        'group_id' => $group->id,
                        'user_id' => $memberId,
                        'role' => 'member',
                    ]);
                }
            }

            DB::commit();

            // Load relationships for response
            $group->load(['creator:id,name,email', 'members:id,name,email']);
            $group->loadCount('members');

            // Broadcast event
            $addedUsers = User::whereIn('id', $request->member_ids)->get(['id', 'name', 'email'])->toArray();
            broadcast(new MemberAddedToGroup($group, $addedUsers, $userId));

            return response()->json([
                'success' => true,
                'message' => 'Group created successfully',
                'data' => [
                    'id' => $group->id,
                    'name' => $group->name,
                    'description' => $group->description,
                    'avatar' => $group->avatar,
                    'created_by' => $group->created_by,
                    'created_at' => $group->created_at->toISOString(),
                    'member_count' => $group->members_count,
                    'is_admin' => true,
                ],
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create group: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get group details
     */
    public function show($id)
    {
        $userId = Auth::id();

        $group = ChatGroup::with(['creator:id,name,email'])
            ->withCount('members')
            ->find($id);

        if (!$group) {
            return response()->json([
                'success' => false,
                'message' => 'Group not found',
            ], 404);
        }

        // Check if user is a member
        if (!$group->hasMember($userId)) {
            return response()->json([
                'success' => false,
                'message' => 'You are not a member of this group',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $group->id,
                'name' => $group->name,
                'description' => $group->description,
                'avatar' => $group->avatar,
                'created_by' => $group->created_by,
                'created_at' => $group->created_at->toISOString(),
                'member_count' => $group->members_count,
                'is_admin' => $group->isAdmin($userId),
            ],
        ]);
    }

    /**
     * Update group information
     */
    public function update(Request $request, $id)
    {
        $userId = Auth::id();

        $group = ChatGroup::find($id);

        if (!$group) {
            return response()->json([
                'success' => false,
                'message' => 'Group not found',
            ], 404);
        }

        // Only admins can update group info
        if (!$group->isAdmin($userId)) {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can update group information',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:50',
            'description' => 'nullable|string|max:200',
            'avatar' => 'nullable|image|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            if ($request->has('name')) {
                $group->name = $request->name;
            }

            if ($request->has('description')) {
                $group->description = $request->description;
            }

            if ($request->hasFile('avatar')) {
                // Delete old avatar if exists
                if ($group->avatar) {
                    $oldPath = str_replace('/storage/', '', $group->avatar);
                    Storage::disk('public')->delete($oldPath);
                }

                $path = $request->file('avatar')->store('group_avatars', 'public');
                $group->avatar = Storage::url($path);
            }

            $group->save();

            // Broadcast update
            broadcast(new GroupUpdated($group, $userId));

            return response()->json([
                'success' => true,
                'message' => 'Group updated successfully',
                'data' => [
                    'id' => $group->id,
                    'name' => $group->name,
                    'description' => $group->description,
                    'avatar' => $group->avatar,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update group: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete a group
     */
    public function destroy($id)
    {
        $userId = Auth::id();

        $group = ChatGroup::find($id);

        if (!$group) {
            return response()->json([
                'success' => false,
                'message' => 'Group not found',
            ], 404);
        }

        // Only admins can delete group
        if (!$group->isAdmin($userId)) {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can delete the group',
            ], 403);
        }

        try {
            // Delete avatar if exists
            if ($group->avatar) {
                $path = str_replace('/storage/', '', $group->avatar);
                Storage::disk('public')->delete($path);
            }

            $group->delete();

            return response()->json([
                'success' => true,
                'message' => 'Group deleted successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete group: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get group members
     */
    public function getMembers($id)
    {
        $userId = Auth::id();

        $group = ChatGroup::find($id);

        if (!$group) {
            return response()->json([
                'success' => false,
                'message' => 'Group not found',
            ], 404);
        }

        // Check if user is a member
        if (!$group->hasMember($userId)) {
            return response()->json([
                'success' => false,
                'message' => 'You are not a member of this group',
            ], 403);
        }

        $members = GroupMember::where('group_id', $id)
            ->with('user:id,name,email,profile_picture')
            ->get()
            ->map(function ($member) {
                return [
                    'id' => $member->id,
                    'user_id' => $member->user_id,
                    'user_name' => $member->user->name,
                    'user_email' => $member->user->email,
                    'user_avatar' => $member->user->profile_picture,
                    'role' => $member->role,
                    'joined_at' => $member->joined_at->toISOString(),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $members,
        ]);
    }

    /**
     * Add members to group
     */
    public function addMembers(Request $request, $id)
    {
        $userId = Auth::id();

        $group = ChatGroup::find($id);

        if (!$group) {
            return response()->json([
                'success' => false,
                'message' => 'Group not found',
            ], 404);
        }

        // Only admins can add members
        if (!$group->isAdmin($userId)) {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can add members',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'user_ids' => 'required|array|min:1',
            'user_ids.*' => 'exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $addedUsers = [];

            foreach ($request->user_ids as $memberId) {
                // Skip if already a member
                if ($group->hasMember($memberId)) {
                    continue;
                }

                GroupMember::create([
                    'group_id' => $group->id,
                    'user_id' => $memberId,
                    'role' => 'member',
                ]);

                $user = User::find($memberId);
                $addedUsers[] = [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ];
            }

            if (!empty($addedUsers)) {
                broadcast(new MemberAddedToGroup($group, $addedUsers, $userId));
            }

            return response()->json([
                'success' => true,
                'message' => count($addedUsers) . ' member(s) added successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to add members: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove a member from group
     */
    public function removeMember($groupId, $userId)
    {
        $authUserId = Auth::id();

        $group = ChatGroup::find($groupId);

        if (!$group) {
            return response()->json([
                'success' => false,
                'message' => 'Group not found',
            ], 404);
        }

        // Only admins can remove members (except self-leave)
        if ($authUserId != $userId && !$group->isAdmin($authUserId)) {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can remove members',
            ], 403);
        }

        try {
            $member = GroupMember::where('group_id', $groupId)
                ->where('user_id', $userId)
                ->first();

            if (!$member) {
                return response()->json([
                    'success' => false,
                    'message' => 'User is not a member of this group',
                ], 404);
            }

            $member->delete();

            broadcast(new MemberRemovedFromGroup($group, $userId, $authUserId));

            return response()->json([
                'success' => true,
                'message' => 'Member removed successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to remove member: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update member role
     */
    public function updateMemberRole(Request $request, $groupId, $userId)
    {
        $authUserId = Auth::id();

        $group = ChatGroup::find($groupId);

        if (!$group) {
            return response()->json([
                'success' => false,
                'message' => 'Group not found',
            ], 404);
        }

        // Only admins can update roles
        if (!$group->isAdmin($authUserId)) {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can update member roles',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'role' => 'required|in:member,admin',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $member = GroupMember::where('group_id', $groupId)
                ->where('user_id', $userId)
                ->first();

            if (!$member) {
                return response()->json([
                    'success' => false,
                    'message' => 'User is not a member of this group',
                ], 404);
            }

            $member->role = $request->role;
            $member->save();

            broadcast(new MemberRoleUpdated($group, $userId, $request->role, $authUserId));

            return response()->json([
                'success' => true,
                'message' => 'Member role updated successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update role: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Leave a group
     */
    public function leave($id)
    {
        $userId = Auth::id();

        $group = ChatGroup::find($id);

        if (!$group) {
            return response()->json([
                'success' => false,
                'message' => 'Group not found',
            ], 404);
        }

        try {
            $member = GroupMember::where('group_id', $id)
                ->where('user_id', $userId)
                ->first();

            if (!$member) {
                return response()->json([
                    'success' => false,
                    'message' => 'You are not a member of this group',
                ], 404);
            }

            $member->delete();

            broadcast(new MemberRemovedFromGroup($group, $userId, $userId));

            return response()->json([
                'success' => true,
                'message' => 'You have left the group',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to leave group: ' . $e->getMessage(),
            ], 500);
        }
    }
}
