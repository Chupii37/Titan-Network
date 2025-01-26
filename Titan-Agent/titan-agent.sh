#!/bin/bash

# Display message with cyan color
echo -e "\033[36mShowing ANIANI!!!\033[0m" 

# Display logo directly from URL without saving
echo -e "\033[32mDisplaying logo...\033[0m"
wget -qO- https://raw.githubusercontent.com/Chupii37/Chupii-Node/refs/heads/main/Logo.sh | bash
if [ $? -ne 0 ]; then
  echo -e "\033[31mFailed to display logo.\033[0m"
  exit 1
fi

# Detect system architecture and select the appropriate agent
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" || "$ARCH" == "armv7l" ]]; then
    echo -e "\033[32mDetected ARM architecture, using ARM agent...\033[0m"
    AGENT_URL="https://pcdn.titannet.io/test4/bin/agent-arm.zip"
    AGENT_ZIP="agent-arm.zip"
else
    echo -e "\033[32mDetected non-ARM architecture, using default agent...\033[0m"
    AGENT_URL="https://pcdn.titannet.io/test4/bin/agent-linux.zip"
    AGENT_ZIP="agent-linux.zip"
fi

# Set installation directory and server URL
INSTALL_DIR="/opt/titanagent"
WORKING_DIR="/opt/titanagent"
SERVER_URL="https://test4-api.titannet.io"

# Prompt user for TITAN KEY
read -p "Please enter your TITAN KEY: " TITAN_KEY
if [ -z "$TITAN_KEY" ]; then
  echo -e "\033[31mTITAN_KEY is required to proceed. Exiting...\033[0m"
  exit 1
fi

# Update package list
echo -e "\033[34mUpdating package list...\033[0m"
sudo apt update -y

# Install snapd
echo -e "\033[34mInstalling snapd...\033[0m"
sudo apt install -y snapd

# Enable snapd.socket
echo -e "\033[34mEnabling snapd.socket...\033[0m"
sudo systemctl enable --now snapd.socket

# Install Multipass
echo -e "\033[34mInstalling Multipass...\033[0m"
sudo snap install multipass

# Verify Multipass installation
echo -e "\033[34mVerifying Multipass...\033[0m"
multipass --version

# Check network connection
echo -e "\033[34mChecking network connection...\033[0m"
ping -c 4 google.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "\033[31mInternet connection failed.\033[0m"
  exit 1
fi

# Download Titan Agent
echo -e "\033[34mDownloading Titan Agent...\033[0m"
mkdir -p $INSTALL_DIR

if [ ! -f "$INSTALL_DIR/$AGENT_ZIP" ]; then
  wget -O $INSTALL_DIR/$AGENT_ZIP $AGENT_URL
  if [ $? -ne 0 ]; then
    echo -e "\033[31mDownload failed.\033[0m"
    exit 1
  fi
else
  echo -e "\033[32mFile already exists, continuing...\033[0m"
fi

# Install unzip if necessary
echo -e "\033[34mInstalling unzip...\033[0m"
sudo apt install -y unzip

# Extract Titan Agent
echo -e "\033[34mExtracting Titan Agent...\033[0m"
unzip -o $INSTALL_DIR/$AGENT_ZIP -d $INSTALL_DIR

# Grant execution permission to the agent
echo -e "\033[34mGranting execution permission...\033[0m"
chmod +x $INSTALL_DIR/agent

# Create systemd service for Titan Agent
echo -e "\033[34mCreating systemd service...\033[0m"
cat <<EOF | sudo tee /etc/systemd/system/titan-agent.service
[Unit]
Description=Titan Agent Service
After=network.target

[Service]
Environment="TITAN_KEY=$TITAN_KEY"
ExecStart=$INSTALL_DIR/agent --working-dir=$WORKING_DIR --server-url=$SERVER_URL --key=${TITAN_KEY}
WorkingDirectory=$INSTALL_DIR
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
echo -e "\033[34mReloading systemd...\033[0m"
sudo systemctl daemon-reload
sudo systemctl enable titan-agent.service
sudo systemctl start titan-agent.service

# Display success and log monitoring instructions
echo -e "\033[32mTitan Agent is running.\033[0m"
echo -e "\033[32mTo monitor logs: sudo journalctl -u titan-agent -f --no-hostname -o cat\033[0m"
