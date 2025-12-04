#!/bin/bash
set -e

# Wait for MySQL to be ready
echo "Waiting for MySQL..."
until php artisan db:show 2>/dev/null; do
    echo "MySQL is unavailable - sleeping"
    sleep 2
done

echo "MySQL is up - executing command"

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
