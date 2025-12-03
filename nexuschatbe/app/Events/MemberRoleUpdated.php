<?php

namespace App\Events;

use App\Models\ChatGroup;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MemberRoleUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public ChatGroup $group;
    public int $userId;
    public string $newRole;
    public int $updatedBy;

    /**
     * Create a new event instance.
     */
    public function __construct(ChatGroup $group, int $userId, string $newRole, int $updatedBy)
    {
        $this->group = $group;
        $this->userId = $userId;
        $this->newRole = $newRole;
        $this->updatedBy = $updatedBy;
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
        return 'member.role.updated';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'group_id' => $this->group->id,
            'user_id' => $this->userId,
            'new_role' => $this->newRole,
            'updated_by' => $this->updatedBy,
            'timestamp' => now()->toISOString(),
        ];
    }
}
