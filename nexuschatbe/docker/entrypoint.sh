#!/bin/bash
set -e

echo "Starting NexusChat application..."

# Start supervisor (which runs PHP-FPM, queue worker, scheduler)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
