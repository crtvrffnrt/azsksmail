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
            display_message "[WARNING] $tool is not installed." "yellow"
        else
            display_message "[INFO] $tool is already installed." "green"
        fi
    done

    if [ ${#missing_tools[@]} -eq 0 ]; then
        display_message "[INFO] All required tools are installed." "green"
    else
        display_message "[ERROR] Missing tools: ${missing_tools[*]}." "red"
        display_message "Attempting to proceed with the script, but functionality may be limited." "yellow"
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
#                   Execute System and Tools Check        #
############################################################
run_checks() {
    check_system_and_tools
    check_azure_extensions

    display_message "[INFO] Final version checks..." "cyan"

    # Azure CLI version
    if command -v az >/dev/null 2>&1; then
        display_message "Azure CLI Version: $(az version | jq -r '.\"azure-cli\"')" "blue"
    else
        display_message "[ERROR] Azure CLI not found." "red"
    fi

    # Docker version
    if command -v docker >/dev/null 2>&1; then
        display_message "Docker Version: $(docker --version | awk '{print $3 $4}' | sed 's/,//')" "blue"
    else
        display_message "[ERROR] Docker not found." "red"
    fi

    # Kubernetes tools version
    if command -v kubectl >/dev/null 2>&1; then
        display_message "kubectl Version: $(kubectl version --client --short)" "blue"
    else
        display_message "[ERROR] kubectl not found." "red"
    fi

    if command -v helm >/dev/null 2>&1; then
        display_message "Helm Version: $(helm version --short)" "blue"
    else
        display_message "[ERROR] Helm not found." "red"
    fi

    # Node.js and npm versions
    if command -v node >/dev/null 2>&1; then
        display_message "Node.js Version: $(node --version)" "blue"
    else
        display_message "[ERROR] Node.js not found." "red"
    fi

    if command -v npm >/dev/null 2>&1; then
        display_message "npm Version: $(npm --version)" "blue"
    else
        display_message "[ERROR] npm not found." "red"
    fi
}

############################################################
#                   Main Script Execution                 #
############################################################
run_checks

