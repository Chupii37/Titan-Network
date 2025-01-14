#!/bin/bash

# Display message after the logo with cyan color
echo -e "\033[36mShowing ANIANI!!!\033[0m" 

# Display logo directly from the URL without saving the file
echo -e "\033[32mDisplaying logo...\033[0m"
wget -qO- https://raw.githubusercontent.com/Chupii37/Chupii-Node/refs/heads/main/Logo.sh | bash 
if [ $? -ne 0 ]; then
  echo -e "\033[31mFailed to display logo.\033[0m"
  exit 1
fi

# Variables for Titan Agent
AGENT_URL="https://pcdn.titannet.io/test4/bin/agent-linux.zip"
INSTALL_DIR="/opt/titanagent"
AGENT_ZIP="agent-linux.zip"
WORKING_DIR="/opt/titanagent"
SERVER_URL="https://test4-api.titannet.io"

# Step 1: Ask the user to input the Titan key
echo -e "\033[36mEnter your Titan key: \033[0m"
read -r KEY  # Accept user input for the key

# Ensure the key is not empty
if [ -z "$KEY" ]; then
  echo -e "\033[31mTitan key cannot be empty. Script aborted.\033[0m"
  exit 1
fi

# Step 2: Update package list
echo -e "\033[34mUpdating package list...\033[0m"
sudo apt update
if [ $? -ne 0 ]; then
  echo -e "\033[31mFailed to update package list.\033[0m"
  exit 1
fi

# Step 3: Install snapd if not installed
echo -e "\033[34mChecking and installing snapd...\033[0m"
sudo apt install -y snapd
if [ $? -ne 0 ]; then
  echo -e "\033[31mFailed to install snapd.\033[0m"
  exit 1
fi

# Step 4: Enable and start snapd.socket
echo -e "\033[34mEnabling snapd.socket...\033[0m"
sudo systemctl enable --now snapd.socket
if [ $? -ne 0 ]; then
  echo -e "\033[31mFailed to enable snapd.socket.\033[0m"
  exit 1
fi

# Step 5: Install Multipass using Snap
echo -e "\033[34mInstalling Multipass...\033[0m"
sudo snap install multipass
if [ $? -ne 0 ]; then
  echo -e "\033[31mFailed to install Multipass.\033[0m"
  exit 1
fi

# Verify Multipass installation
echo -e "\033[34mVerifying Multipass installation...\033[0m"
multipass --version
if [ $? -ne 0 ]; then
  echo -e "\033[31mMultipass is not installed correctly.\033[0m"
  exit 1
fi

# Step 6: Check Internet Connection
echo -e "\033[34mChecking network connection...\033[0m"
ping -c 4 google.com > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "\033[31mInternet connection failed. Please check your network.\033[0m"
  exit 1
fi

# Step 7: Download Titan Agent
echo -e "\033[34mDownloading Titan Agent...\033[0m"
mkdir -p $INSTALL_DIR  # Create directory if not exists

# Check if the file already exists
if [ ! -f "$INSTALL_DIR/$AGENT_ZIP" ]; then
  wget -O $INSTALL_DIR/$AGENT_ZIP $AGENT_URL
  if [ $? -ne 0 ]; then
    echo -e "\033[31mDownload failed. Please check your network connection or the URL.\033[0m"
    exit 1
  fi
else
  echo -e "\033[32mFile agent-linux.zip already exists, continuing extraction...\033[0m"
fi

# Step 8: Extract Titan Agent File
echo -e "\033[34mPreparing directory and extracting file...\033[0m"
# Ensure unzip is installed
if ! command -v unzip &> /dev/null; then
  echo -e "\033[31munzip command not found. Installing unzip...\033[0m"
  sudo apt install -y unzip
fi

unzip $INSTALL_DIR/$AGENT_ZIP -d $INSTALL_DIR
if [ $? -ne 0 ]; then
  echo -e "\033[31mExtraction failed. Ensure unzip is installed.\033[0m"
  exit 1
fi

# Step 9: Grant Execution Permission to the Titan Agent File
echo -e "\033[34mAdding execution permission to the agent file...\033[0m"
chmod +x $INSTALL_DIR/agent
if [ $? -ne 0 ]; then
  echo -e "\033[31mFailed to grant execution permission. Run with sudo.\033[0m"
  exit 1
fi

# Step 10: Run Titan Agent
echo -e "\033[34mRunning Titan Agent...\033[0m"
$INSTALL_DIR/agent --working-dir=$WORKING_DIR --server-url=$SERVER_URL --key=$KEY
if [ $? -ne 0 ]; then
  echo -e "\033[31mTitan Agent failed to run.\033[0m"
  exit 1
fi

# Step 11: Set Titan Agent as a System Service (Systemd)
echo -e "\033[34mSetting Titan Agent as a system service...\033[0m"
cat <<EOF | sudo tee /etc/systemd/system/titan-agent.service
[Unit]
Description=Titan Agent Service
After=network.target

[Service]
ExecStart=$INSTALL_DIR/agent --working-dir=$WORKING_DIR --server-url=$SERVER_URL --key=$KEY
WorkingDirectory=$INSTALL_DIR
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
echo -e "\033[32mSystemd unit for Titan Agent has been created.\033[0m"

# Step 12: Enable and Start Titan Agent Service
echo -e "\033[34mEnabling and starting Titan Agent service...\033[0m"
sudo systemctl enable titan-agent.service
sudo systemctl start titan-agent.service
if [ $? -ne 0 ]; then
  echo -e "\033[31mFailed to start Titan Agent service.\033[0m"
  exit 1
fi

# Step 13: Check Titan Agent Service Status
echo -e "\033[34mChecking Titan Agent service status...\033[0m"
sudo systemctl status titan-agent.service

# Step 14: Display Real-Time Logs from Titan Agent
echo -e "\033[32mStarting to monitor Titan Agent real-time logs...\033[0m"
sudo journalctl -u titan-agent -f --no-hostname -o cat

# Display success message
echo -e "\033[32mTitan Agent has been successfully installed and run as a service!\033[0m"
echo -e "\033[32mMultipass has also been installed.\033[0m"
echo -e "\033[33mInstallation process is complete.\033[0m"
