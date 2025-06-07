#!/usr/bin/fish

# Stop the flicker container
docker stop flicker 2>/dev/null || echo "Flicker container not running or doesn't exist"

# Stop Docker (if no other containers are running)
sudo systemctl stop docker 2>/dev/null || echo "Docker not running"

# Kill pgadmin4 if running
pkill -f pgadmin4 2>/dev/null || echo "pgadmin4 not running"

# Deactivate Python virtualenv if active
if set -q VIRTUAL_ENV
    deactivate
    echo "Python virtualenv deactivated"
else
    echo "No Python virtualenv active"
end
