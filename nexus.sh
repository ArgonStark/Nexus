#!/bin/bash

# Define color variables
CYAN='\033[0;36m'
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

# Function to print colorful messages
echo_colored() {
    echo -e "${1}${2}${NC}"
}

# Get user input for Prover ID
echo_colored "$CYAN" "Enter your Prover ID: "
read -r PROVER_ID

# Get server IP addresses
echo_colored "$CYAN" "Enter server IPs, separated by spaces:"
read -a SERVER_IPS

# First script to run on servers
FIRST_SCRIPT="sudo apt install wget && wget -qO - https://raw.githubusercontent.com/zunxbt/nexus-prover/main/nexus.sh | bash"

# Second script to run on servers
SECOND_SCRIPT="sed -i 's/.*/$PROVER_ID/' .nexus/prover-id && sudo systemctl restart nexus.service"

# Loop through each server for the first script
echo_colored "$BLUE" "Starting the execution of the first script on all servers..."
for SERVER in "${SERVER_IPS[@]}"; do
    echo_colored "$YELLOW" "Connecting to server $SERVER"
    ssh "root@$SERVER" <<EOF
        echo "Executing first script on $SERVER"
        $FIRST_SCRIPT
EOF
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

# Loop through each server for the second script
echo_colored "$BLUE" "Starting the execution of the second script on all servers..."
for SERVER in "${SERVER_IPS[@]}"; do
    echo_colored "$YELLOW" "Connecting to server $SERVER"
    ssh "root@$SERVER" <<EOF
        echo "Executing second script on $SERVER"
        $SECOND_SCRIPT
EOF
    if [ $? -eq 0 ]; then
        echo_colored "$GREEN" "Successfully executed on $SERVER"
    else
        echo_colored "$RED" "Failed to execute on $SERVER"
    fi
    echo ""
done

echo_colored "$GREEN" "All tasks completed."
