<?php

use App\Models\ChatRoom;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('chat.room.{id}', function ($user, $id) {
    return ChatRoom::find($id)
            ->members()
            ->where('user_id', $user->id)
            ->exists();
});
