<?php

namespace App\Events;

use App\Models\ChatGroup;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MemberAddedToGroup implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public ChatGroup $group;
    public array $addedUsers;
    public int $addedBy;

    /**
     * Create a new event instance.
     */
    public function __construct(ChatGroup $group, array $addedUsers, int $addedBy)
    {
        $this->group = $group;
        $this->addedUsers = $addedUsers; // Array of user objects
        $this->addedBy = $addedBy;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('group.' . $this->group->id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'member.added';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'group_id' => $this->group->id,
            'added_users' => $this->addedUsers,
            'added_by' => $this->addedBy,
            'timestamp' => now()->toISOString(),
        ];
    }
}
