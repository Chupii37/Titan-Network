#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing Docker..."
    
    # Install Docker on Ubuntu (for Debian/Ubuntu-based systems)
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce

    # Check if Docker was installed successfully
    if ! command -v docker &> /dev/null
    then
        echo "Failed to install Docker. Please try installing manually."
        exit 1
    fi
else
    echo "Docker is already installed."
fi

# Pull the necessary Docker image
echo "Pulling Docker image nezha123/titan-edge..."
docker pull nezha123/titan-edge

# Create the ~/.titanedge directory if it doesn't exist
echo "Creating ~/.titanedge directory..."
mkdir -p ~/.titanedge

# Run Docker container with --network=host option
echo "Running Docker container..."
docker run --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge

# Prompt the user to input the hash
read -p "Enter your hash (your-hash-here): " user_hash

# Run the binding command with the provided hash
echo "Running binding command with hash $user_hash..."
docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash=$user_hash https://api-test1.container1.titannet.io/api/v2/device/binding

echo "Script completed successfully."
