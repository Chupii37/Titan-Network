# TITAN AGENT NODE

## System Requirements
CPU: 2 vCORE

RAM: 2 GB

Storage: 50 GB

## Installation

Before run node you need visit [Titan Network](https://test4.titannet.io/)
* Connect your wallet
* Node Management
* Copy your key

Run Node
   ```bash
   curl -sSL https://raw.githubusercontent.com/Chupii37/Titan-Network/refs/heads/main/Titan-Agent/titan-agent.sh -o titan-agent.sh && chmod +x titan-agent.sh && ./titan-agent.sh
   ```
## After End of Project
   ```bash
   sudo systemctl stop titan-agent.service
   ```
   ```bash
   sudo systemctl disable titan-agent.service
   ```
   ```bash
   sudo rm /etc/systemd/system/titan-agent.service
   ```
   ```bash
   sudo rm -rf /opt/titanagent
   ```
