# Titan Network (Edge Nodes)

## System Requirements
CPU: 1 vCORE
RAM: 0.5 GB
Storage: 1 GB
Bandwidth: based on availability
## Register for a Titan Network Account
Before running the node, you need to sign up for an account on Network3. You can sign up using the following link :

[Register Titan Network](https://test1.titannet.io/intiveRegister?code=qnOIMD)

## Installation
Follow the steps below to install the necessary software:
1. Update the System and Install curl
    ```bash
    sudo apt update
    sudo apt install curl
    ```
2. Creat Screen
 ```bash
   screen -S titan
```

3. Run Node
 ```bash
wget https://raw.githubusercontent.com/Chupii37/Titan-Network/refs/heads/main/titan-edge.sh -O titan-edge.sh && \
chmod +x titan-edge.sh && \
sed -i '/read -p "Enter your hash/,+1d' titan-edge.sh && \
sed -i '/docker run.*bind/s/^/echo "Enter your hash:"\nread user_hash\n/' titan-edge.sh && \
./titan-edge.sh
```
**Identity Code** (You will be prompted to enter)

