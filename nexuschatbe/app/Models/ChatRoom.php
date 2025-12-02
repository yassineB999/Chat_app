<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatRoom extends Model
{
    protected $guarded = [];

    public function members()
    {
        return $this->hasMany(ChatRoomMember::class);
    }

    public function messages()
    {
        return $this->hasMany(ChatRoomMessage::class);
    }
}
