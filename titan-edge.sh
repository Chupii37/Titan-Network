#!/bin/bash

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

echo "${GREEN}Displaying logo...${RESET}"
# Attempt to display logo and handle error
wget -qO- https://raw.githubusercontent.com/Chupii37/Chupii-Node/refs/heads/main/Logo.sh | bash || handle_error "Failed to display logo."

# Check for system updates
echo "Checking for system updates..."
sudo apt-get update || handle_error "Failed to update package list."
sudo apt-get upgrade -y || handle_error "Failed to upgrade packages."

# Check Docker installation
echo "Checking Docker installation..."
if ! command -v docker &> /dev/null
then
    echo "Docker not found, installing..."
    sudo apt-get install -y docker.io || handle_error "Failed to install Docker."
else
    echo "Docker is already installed."
fi

# Pull the Titan Edge Docker image
echo "Pulling Titan Edge Docker image..."
docker pull nezha123/titan-edge || handle_error "Failed to pull Titan Edge Docker image."

# Create Titan Edge directory
echo "Creating Titan Edge directory..."
mkdir -p ~/.titanedge || handle_error "Failed to create ~/.titanedge directory."

# Run Titan Edge container with auto-restart
echo "Running Titan Edge container with auto-restart..."
docker run --network=host -d -v ~/.titanedge:/root/.titanedge --restart unless-stopped nezha123/titan-edge || handle_error "Failed to run the Titan Edge container."

# Prompt user for identity hash
echo "Please enter your identity hash."
read -p "Enter your identity hash: " identity_hash
if [[ -z "$identity_hash" ]]; then
    handle_error "Identity hash cannot be empty."
fi

# Bind device with the provided identity hash
echo "Binding device with the identity hash..."
docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash=$identity_hash https://api-test1.container1.titannet.io/api/v2/device/binding || handle_error "Failed to bind device with the identity hash."

echo "Titan Edge setup completed successfully!"
