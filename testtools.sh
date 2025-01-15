#!/bin/bash

############################################################
#                   System and Tools Check                #
############################################################
check_system_and_tools() {
    local required_tools=("curl" "wget" "git" "unzip" "jq" "docker" "kubectl" "helm" "node" "npm")
    local missing_tools=()

    display_message "[INFO] Checking required tools and system configuration..." "cyan"

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
            display_message "[WARNING] $tool is not installed. Attempting to install..." "yellow"
            if [[ "$tool" == "docker" ]]; then
                sudo apt-get update && sudo apt-get install -y docker.io
                sudo systemctl start docker
                sudo systemctl enable docker
            elif [[ "$tool" == "kubectl" ]]; then
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            elif [[ "$tool" == "helm" ]]; then
                curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
            elif [[ "$tool" == "node" ]]; then
                curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
                sudo apt-get install -y nodejs
            elif [[ "$tool" == "npm" ]]; then
                sudo apt-get install -y npm
            else
                sudo apt-get update && sudo apt-get install -y "$tool"
            fi
        else
            display_message "[INFO] $tool is already installed." "green"
        fi
    done

    if [ ${#missing_tools[@]} -eq 0 ]; then
        display_message "[INFO] All required tools are installed." "green"
    else
        display_message "[INFO] Tools installed: ${missing_tools[*]}" "blue"
    fi
}

############################################################
#                   Azure CLI Extensions Check            #
############################################################
check_azure_extensions() {
    local required_extensions=("account" "resource-graph" "connectedk8s" "k8s-extension")

    display_message "[INFO] Checking Azure CLI extensions..." "cyan"

    for extension in "${required_extensions[@]}"; do
        if ! az extension show --name "$extension" >/dev/null 2>&1; then
            display_message "[INFO] Installing Azure CLI extension: $extension..." "yellow"
            az extension add --name "$extension" || {
                display_message "[ERROR] Failed to install Azure CLI extension: $extension." "red"
            }
        else
            display_message "[INFO] Azure CLI extension $extension is already installed." "green"
        fi
    done
}

############################################################
#                   Fancy Output for Commands             #
############################################################
run_checks() {
    check_system_and_tools
    check_azure_extensions

    display_message "[INFO] Final version checks..." "cyan"

    # Azure CLI version
    if command -v az >/dev/null 2>&1; then
        display_message "Azure CLI Version:" "cyan"
        az version
    else
        display_message "[ERROR] Azure CLI not found." "red"
    fi

    # Docker version
    if command -v docker >/dev/null 2>&1; then
        display_message "Docker Version:" "cyan"
        docker --version
    else
        display_message "[ERROR] Docker not found." "red"
    fi

    # Kubernetes tools version
    if command -v kubectl >/dev/null 2>&1; then
        display_message "kubectl Version:" "cyan"
        kubectl version --client --short
    else
        display_message "[ERROR] kubectl not found." "red"
    fi

    if command -v helm >/dev/null 2>&1; then
        display_message "Helm Version:" "cyan"
        helm version --short
    else
        display_message "[ERROR] Helm not found." "red"
    fi

    # Node.js and npm versions
    if command -v node >/dev/null 2>&1; then
        display_message "Node.js Version:" "cyan"
        node --version
    else
        display_message "[ERROR] Node.js not found." "red"
    fi

    if command -v npm >/dev/null 2>&1; then
        display_message "npm Version:" "cyan"
        npm --version
    else
        display_message "[ERROR] npm not found." "red"
    fi
}

############################################################
#                   Main Script Execution                 #
############################################################
display_banner
run_checks

# Add your additional functionality or logic below.
display_message "[INFO] Script execution completed successfully." "green"
