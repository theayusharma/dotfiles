#!/usr/bin/fish

# Start Docker (requires sudo)
sudo systemctl start docker

# Start the 'flicker' container
docker start flicker

# Wait a moment
sleep 1

# Activate pgadmin4 virtual environment and run it in the background
source pgadmin4/bin/activate.fish
pgadmin4 &
