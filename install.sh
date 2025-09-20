#!/bin/bash

# ==============================================================================
# || Aztec Sequencer Multi-Tool Installer & Management Script (v2 - Patched)  ||
# ==============================================================================

# --- Helper Functions for Colors ---
print_info() { echo -e "\e[34mINFO: $1\e[0m"; }
print_success() { echo -e "\e[32mSUCCESS: $1\e[0m"; }
print_warning() { echo -e "\e[33mWARNING: $1\e[0m"; }
print_error() { echo -e "\e[31mERROR: $1\e[0m"; }

# --- Configuration File ---
CONFIG_FILE="$HOME/.aztec_config"

# --- Function to Install Node ---
install_node() {
    print_info "Starting Aztec Sequencer Full Node installation..."

    # 1. System Update and Dependencies
    print_info "Updating system and installing dependencies..."
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen ufw apt-transport-https ca-certificates software-properties-common || { print_error "Failed to install dependencies."; exit 1; }
    
    # 2. Install Docker & Docker Compose
    if ! command -v docker &> /dev/null; then
        print_info "Installing Docker..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update && sudo apt-get install -y docker-ce
        sudo systemctl enable --now docker && sudo usermod -aG docker $USER
        print_success "Docker installed."
    else
        print_info "Docker is already installed."
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_info "Installing Docker Compose..."
        LATEST_COMPOSE_VERSION=`curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name`
        sudo curl -L "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        print_success "Docker Compose installed."
    else
        print_info "Docker Compose is already installed."
    fi

    # 3. Install Aztec CLI
    print_info "Installing Aztec CLI..."
    bash -i <(curl -s https://install.aztec.network)
    echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    aztec-up 2.0.2

    # 4. Configure Firewall
    print_info "Configuring firewall..."
    sudo ufw allow 22/tcp && sudo ufw allow 8080/tcp && sudo ufw allow 40400/tcp
    echo "y" | sudo ufw enable

    # 5. Get and Save User Configuration
    print_info "Please provide your details. They will be saved to $CONFIG_FILE for future use."
    read -p "Enter your Ethereum Sepolia RPC URL: " ETH_SEPOLIA_RPC
    read -p "Enter your Ethereum Sepolia Beacon RPC URL: " ETH_BEACON_SEPOLIA_RPC
    print_warning "NEVER use a private key from a wallet with real funds. Create a new, empty wallet."
    read -sp "Enter your new EVM wallet's Private Key: " PRIVATE_KEY
    echo ""
    read -p "Enter your EVM wallet's Public Address (0x...): " PUBLIC_ADDRESS
    
    # Save to config file
    echo "export ETH_SEPOLIA_RPC=\"$ETH_SEPOLIA_RPC\"" > $CONFIG_FILE
    echo "export ETH_BEACON_SEPOLIA_RPC=\"$ETH_BEACON_SEPOLIA_RPC\"" >> $CONFIG_FILE
    echo "export PRIVATE_KEY=\"$PRIVATE_KEY\"" >> $CONFIG_FILE
    echo "export PUBLIC_ADDRESS=\"$PUBLIC_ADDRESS\"" >> $CONFIG_FILE
    
    print_success "Installation complete! Your details are saved."
    print_info "Choose option '2' from the menu to run your node."
}

# --- Function to Run Node ---
run_node() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Configuration file not found. Please run the installation (Option 1) first."
        return
    fi
    
    if screen -list | grep -q "aztec"; then
        print_warning "Aztec screen session is already running."
        print_info "To attach to it, use: screen -r aztec"
        return
    fi

    print_info "Starting Aztec Sequencer..."
    source $CONFIG_FILE
    PUBLIC_IP=`curl -s ifconfig.me`
    
    screen -dmS aztec aztec start --node --archiver --sequencer \
      --network testnet \
      --l1-rpc-urls "$ETH_SEPOLIA_RPC" \
      --l1-consensus-host-urls "$ETH_BEACON_SEPOLIA_RPC" \
      --sequencer.validatorPrivateKeys "$PRIVATE_KEY" \
      --sequencer.coinbase "$PUBLIC_ADDRESS" \
      --p2p.p2pIp "$PUBLIC_IP"
      
    print_success "Aztec node started in a screen session named 'aztec'."
    print_info "To view logs, run: \e[32mscreen -r aztec\e[0m"
}

# --- Function to Update Node ---
update_node() {
    print_info "Updating Aztec CLI to the latest version..."
    aztec-up
    print_success "Update command finished."
}

# --- Function to Uninstall Node ---
uninstall_node() {
    print_warning "This will stop the node and remove all Aztec-related files."
    read -p "Are you sure you want to uninstall? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        print_info "Uninstallation cancelled."
        return
    fi

    print_info "Stopping screen session..."
    screen -S aztec -X quit

    print_info "Removing Aztec CLI and configuration..."
    rm -rf "$HOME/.aztec"
    rm -f "$CONFIG_FILE"
    
    # Remove path from .bashrc
    sed -i '/export PATH="$HOME\/.aztec\/bin:$PATH"/d' ~/.bashrc
    source ~/.bashrc

    print_success "Aztec Sequencer has been uninstalled."
    print_info "Docker and other dependencies were not removed."
}

# --- Main Menu ---
while true; do
    echo ""
    echo -e "\e[35m=================================================\e[0m"
    echo -e "\e[35m    Aztec Sequencer Management Script          \e[0m"
    echo -e "\e[35m            Created by HAMAD                   \e[0m"
    echo -e "\e[35m=================================================\e[0m"
    echo "1. Install Full Node (Run this first)"
    echo "2. Run Sequencer Node"
    echo "3. Update Aztec Tools"
    echo "4. Uninstall Sequencer"
    echo "5. Exit"
    echo "---------------------------------------"
    read -p "Choose an option [1-5]: " choice

    case $choice in
        1) install_node ;;
        2) run_node ;;
        3) update_node ;;
        4) uninstall_node ;;
        5) exit 0 ;;
        *) print_warning "Invalid option. Please try again." ;;
    esac
done