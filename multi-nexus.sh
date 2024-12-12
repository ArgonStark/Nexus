#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Function to print colorful messages
echo_colored() {
    echo -e "${1}${2}${RESET}"
}

# Get user input for Prover ID
echo_colored "$CYAN" "Enter your Prover ID: "
read -r PROVER_ID

# Get server IP addresses
echo_colored "$CYAN" "Enter the IP addresses of servers (comma-separated): "
read -r SERVERS
IFS="," read -r -a SERVER_LIST <<< "$SERVERS"

# Loop through servers to run the first code
echo_colored "$BLUE" "Starting the execution of the first script on all servers..."
for SERVER in "${SERVER_LIST[@]}"; do
    echo_colored "$YELLOW" "Connecting to $SERVER"
    ssh "$SERVER" "sudo apt install curl -y && curl -sSL https://raw.githubusercontent.com/zunxbt/nexus-prover/main/nexus.sh | bash"
    if [ $? -eq 0 ]; then
        echo_colored "$GREEN" "Successfully executed on $SERVER"
    else
        echo_colored "$RED" "Failed to execute on $SERVER"
    fi
    echo ""
done

# Wait for 15 minutes
echo_colored "$CYAN" "Waiting for 15 minutes before running the second script..."
sleep $((15 * 60))

# Loop through servers to run the second code
echo_colored "$BLUE" "Starting the execution of the second script on all servers..."
for SERVER in "${SERVER_LIST[@]}"; do
    echo_colored "$YELLOW" "Connecting to $SERVER"
    ssh "$SERVER" "sed -i 's/.*/$PROVER_ID/' .nexus/prover-id && sudo systemctl restart nexus.service"
    if [ $? -eq 0 ]; then
        echo_colored "$GREEN" "Successfully executed on $SERVER"
    else
        echo_colored "$RED" "Failed to execute on $SERVER"
    fi
    echo ""
done

echo_colored "$GREEN" "All tasks completed."
