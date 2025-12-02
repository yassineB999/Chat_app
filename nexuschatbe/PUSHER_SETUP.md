# Pusher Setup & Migration Guide

## Overview

Your chat application has been successfully updated to:
- ✅ Use **Pusher** for real-time broadcasting
- ✅ Remove all **block user functionality** from the backend

## Changes Made

### Code Changes

1. **ChatController.php** - Removed:
   - `blockUser()` method
   - `unblockUser()` method
   - `BlockedUser` import
   - Blocked user checks in `send()` method
   - Blocked user filters in `searchUsers()` method

2. **User.php** - Removed:
   - `blockedBy()` relationship
   - `blockedUsers()` relationship

3. **api.php** - Removed:
   - `/api/users/block` endpoint
   - `/api/users/unblock` endpoint

4. **PushChatMessageEvent.php** - Enhanced:
   - Added `broadcastWith()` method for better Pusher payload control

5. **Database Migration** - Created:
   - `2025_11_29_111610_drop_blocked_users_table.php` to remove the blocked_users table

### Broadcasting Configuration

The Pusher configuration is already present in `config/broadcasting.php`. Only environment variables need to be set.

## Setup Steps

### 1. Install Pusher PHP SDK

```bash
composer require pusher/pusher-php-server
```

### 2. Configure Environment Variables

Add these to your `.env` file:

```env
BROADCAST_CONNECTION=pusher
PUSHER_APP_ID=your_app_id
PUSHER_APP_KEY=your_app_key
PUSHER_APP_SECRET=your_app_secret
PUSHER_APP_CLUSTER=your_cluster
```

**Get your credentials:**
1. Go to [pusher.com](https://pusher.com)
2. Sign up/login and create a new app
3. Copy the credentials from the "App Keys" section

### 3. Clear Configuration Cache

```bash
php artisan config:clear
php artisan cache:clear
```

### 4. Run Database Migration

To drop the blocked_users table:

```bash
php artisan migrate
```

### 5. Optional: Delete Old Migration File

You can optionally delete the old blocked users migration:

```bash
rm database/migrations/2025_11_25_120000_create_blocked_users_table.php
```

## Testing the Setup

### 1. Test Chat Functionality

**Create a chat room:**
```bash
POST /api/chat/provide
{
  "first_user": 1,
  "second_user": 2
}
```

**Send a message:**
```bash
POST /api/chat/rooms/{roomId}/messages
{
  "content": "Hello!",
  "type": "TEXT"
}
```

### 2. Monitor Pusher Dashboard

1. Log into your Pusher dashboard
2. Navigate to "Debug Console"
3. Send a test message via your app
4. You should see the event `message.sent` on channel `private-chat.room.{id}`

### 3. Verify Block Functionality Removed

- Confirm `/api/users/block` returns 404
- Confirm `/api/users/unblock` returns 404
- Verify `searchUsers` returns all users without filters

## Frontend Integration

Your Flutter frontend will need to connect to Pusher. Update your frontend to:

1. Install the Pusher Flutter package
2. Configure with the same Pusher credentials (App Key and Cluster)
3. Subscribe to `private-chat.room.{roomId}` channels
4. Listen for `message.sent` events

Example channel subscription:
```dart
// Subscribe to channel
channel = pusher.subscribe('private-chat.room.$roomId');

// Bind to event
channel.bind('message.sent', (event) {
  // Handle incoming message
  print('New message: ${event.data}');
});
```

## Event Payload Structure

When a message is sent, Pusher will broadcast with this payload:

```json
{
  "id": 123,
  "chat_room_id": 1,
  "user_id": 2,
  "content": "Hello!",
  "type": "TEXT",
  "created_at": "2025-11-29T12:13:00.000000Z"
}
```

## Troubleshooting

**Issue: Events not appearing in Pusher dashboard**
- Verify `BROADCAST_CONNECTION=pusher` in .env
- Check Pusher credentials are correct
- Run `php artisan config:clear`
- Check Laravel logs: `storage/logs/laravel.log`

**Issue: 403 errors on private channels**
- Ensure Broadcast::routes are registered (already done in api.php)
- Verify authentication is working
- Check channel authorization in `routes/channels.php`

**Issue: Migration fails**
- The blocked_users table may already be dropped
- Check if table exists: `php artisan tinker` then `Schema::hasTable('blocked_users')`
- If it doesn't exist, skip the migration

## Next Steps

1. ✅ Configure Pusher credentials in `.env`
2. ✅ Run migrations to drop blocked_users table
3. ✅ Clear config cache
4. ✅ Test message sending via API
5. ✅ Verify events in Pusher dashboard
6. 🔄 Update Flutter frontend to connect to Pusher
7. 🔄 Remove block/unblock UI from frontend

## Support

- Pusher Documentation: https://pusher.com/docs
- Laravel Broadcasting: https://laravel.com/docs/broadcasting
- Pusher Status: https://status.pusher.com
