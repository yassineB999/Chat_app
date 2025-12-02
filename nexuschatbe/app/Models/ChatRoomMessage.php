<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatRoomMessage extends Model
{
    protected $guarded = [];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Alias for user relationship (used in controller)
    public function sender()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
