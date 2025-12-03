<?php

namespace App\Events;

use App\Models\ChatGroup;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class GroupUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public ChatGroup $group;
    public int $updatedBy;

    /**
     * Create a new event instance.
     */
    public function __construct(ChatGroup $group, int $updatedBy)
    {
        $this->group = $group;
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
        return 'group.updated';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        return [
            'group' => [
                'id' => $this->group->id,
                'name' => $this->group->name,
                'description' => $this->group->description,
                'avatar' => $this->group->avatar,
            ],
            'updated_by' => $this->updatedBy,
            'timestamp' => now()->toISOString(),
        ];
    }
}
