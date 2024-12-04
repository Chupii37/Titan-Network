#!/bin/bash

# Step 1: Check and install ufw if not installed
if ! command -v ufw &> /dev/null
then
    echo "ufw not found, installing ufw..."
    sudo apt update && sudo apt install -y ufw
    echo "ufw has been installed."
else
    echo "ufw is already installed."
fi

# Step 2: Check and install Docker if not installed
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

# Step 3: Download the Docker Image
echo "Pulling the Docker image nezha123/titan-edge..."
docker pull nezha123/titan-edge

# Step 4: Create Your Own Storage Volume (~/.titanedge directory)
if [ ! -d "$HOME/.titanedge" ]; then
    echo "Creating ~/.titanedge directory for storage volume..."
    mkdir -p "$HOME/.titanedge"
else
    echo "~/.titanedge directory already exists."
fi

# Step 5: Allow Port 1234 (or custom port) in the firewall
# Ask the user for a port number
read -p "Enter the port to be used for the container (default: 1234): " user_port
user_port=${user_port:-1234}  # If no input is provided, default to port 1234

echo "Checking and allowing access for port $user_port..."
sudo ufw allow $user_port/tcp
echo "Port $user_port has been opened in the firewall."

# Step 6: Run the Docker Container (without --network=host)
echo "Running the Titan-Edge container with volume ~/.titanedge..."
docker run -d -v "$HOME/.titanedge:/root/.titanedge" -p $user_port:$user_port nezha123/titan-edge

# Step 7: Bind the Identification Code (Ask for and update the hash if needed)
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

# Running the binding command with the user-provided hash
echo "Running the binding command with your hash..."
docker run --rm -it -v "$HOME/.titanedge:/root/.titanedge" nezha123/titan-edge bind --hash="$user_hash" https://api-test1.container1.titannet.io/api/v2/device/binding

echo "Process completed."
