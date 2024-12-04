#!/bin/bash

# Step 1: Check and install Docker if not installed
if ! command -v docker &> /dev/null
then
    echo "Docker not found, installing Docker..."
    
    # Add Docker repository and install Docker
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce
    echo "Docker has been installed."
else
    echo "Docker is already installed."
fi

# Step 2: Download the Docker Image
echo "Pulling the Docker image nezha123/titan-edge..."
docker pull nezha123/titan-edge

# Step 3: Create Your Own Storage Volume (~/.titanedge directory)
if [ ! -d "$HOME/.titanedge" ]; then
    echo "Creating ~/.titanedge directory for storage volume..."
    mkdir -p "$HOME/.titanedge"
else
    echo "~/.titanedge directory already exists."
fi

# Step 4: Run the Docker Container with Network Host and Name
echo "Running the Titan-Edge container with volume ~/.titanedge and network=host..."
docker run -d --name titan_edge --network=host -v "$HOME/.titanedge:/root/.titanedge" nezha123/titan-edge

# Step 5: Bind the Identification Code (Ask for and update the hash if needed)
if [ ! -f "$HOME/.titanedge/hash.txt" ]; then
    read -p "Enter your hash (your-hash-here): " user_hash
    echo "$user_hash" > "$HOME/.titanedge/hash.txt"
else
    user_hash=$(cat "$HOME/.titanedge/hash.txt")
    echo "Currently used hash: $user_hash"
    read -p "If you want to change the hash, enter the new hash (press Enter to keep the current one): " new_hash
    if [ -n "$new_hash" ]; then
        echo "$new_hash" > "$HOME/.titanedge/hash.txt"
        user_hash="$new_hash"
        echo "New hash has been saved."
    fi
fi

# Step 6: Run the binding command with the user-provided hash
echo "Running the binding command with your hash... (This will require your input)"
docker run --rm -it -v "$HOME/.titanedge:/root/.titanedge" nezha123/titan-edge bind --hash="$user_hash" https://api-test1.container1.titannet.io/api/v2/device/binding

echo "Process completed."
