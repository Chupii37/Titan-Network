# TITAN NETWORK (Galileo Testnet)
Fourth test network — Galileo Testnet. The code name of this node is Titan Agent, if you run this node you will get a TNT4 testnet token.

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
  curl -O https://raw.githubusercontent.com/Chupii37/Titan-Node/refs/heads/main/Titan-Agent/titan-agent.sh && chmod +x titan-agent.sh && ./titan-agent.sh
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
   sudo systemctl daemon-reload
   ```
   ```bash
   sudo rm -rf /opt/titanagent
   ```
   ```bash
   multipass delete --all
   multipass purge
   ```

## Want to See More Cool Projects?

Buy me a coffee so I can stay awake and make more cool stuff (and less bugs)! I’ll be forever grateful and a little bit jittery. 😆☕ 

[Buy me a coffee](https://paypal.me/chupii37 )
