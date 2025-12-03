<?php

namespace App\Events;

use App\Models\ChatGroup;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MemberRemovedFromGroup implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public ChatGroup $group;
    public int $removedUserId;
    public int $removedBy;

    /**
     * Create a new event instance.
     */
    public function __construct(ChatGroup $group, int $removedUserId, int $removedBy)
    {
        $this->group = $group;
        $this->removedUserId = $removedUserId;
        $this->removedBy = $removedBy;
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
        return 'member.removed';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'group_id' => $this->group->id,
            'removed_user_id' => $this->removedUserId,
            'removed_by' => $this->removedBy,
            'timestamp' => now()->toISOString(),
        ];
    }
}
