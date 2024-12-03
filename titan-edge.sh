#!/bin/bash

# Pull Docker Image
echo "Pulling Docker image nezha123/titan-edge..."
docker pull nezha123/titan-edge

# Membuat direktori ~/.titanedge jika belum ada
echo "Creating directory ~/.titanedge if it doesn't exist..."
mkdir -p ~/.titanedge

# Menjalankan Docker container dengan --network=host dan volume mount
echo "Running Docker container..."
docker run --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge

echo "Titan Edge container is now running."

