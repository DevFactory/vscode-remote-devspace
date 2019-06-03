#!/bin/bash

set -e

DS_NAME="${1:-vscode-remote}"
SSH_HOST_NAME=""
SSH_PORT=""
DS_SSH_KEY="${HOME}/.ssh/devspaces_rsa"
SSH_CONFIG="${HOME}/.ssh/config"

usage()
{
    echo "Remote development using VS Code in DevSpaces.

Usage: $0 <DevSpace>

Positionals:
    DevSpace -  Name of the DevSpace [Optional]"
}

log ()
{
    timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
    echo "[${timestamp}] $1"
}

configure_ssh()
{
    log "Configuring SSH on your machine..."
    if [ -z "${SSH_HOST_NAME}" ] || [ -z "${SSH_PORT}" ] || [ -z "${DS_NAME}" ]; then
        log "Missing DevSpace name, hostname or port"
        exit 1
    fi

    # Generate SSH key
    if [ ! -f ${DS_SSH_KEY} ]; then
        log "Generating DevSpace specific SSH key ${DS_SSH_KEY}..."
        ssh-keygen -t rsa -f ${DS_SSH_KEY} -q -C "$(whoami)@devspace" -N ""
    fi

    # Make backup of config file
    log "Backing up ${SSH_CONFIG} to ${SSH_CONFIG}.bak"
    cp "${SSH_CONFIG}" "${SSH_CONFIG}.bak"

    local config_name="devspace-${DS_NAME}"

    # Clear the existing configuration
    if grep -q "#Start ${config_name}" "${SSH_CONFIG}"; then
        log "Clearing existing configuration from ${SSH_CONFIG}"
        find_pattern="#Start ${config_name}(.*)#${config_name}\n"
        perl -i -0pe 's/'"${find_pattern}"'//sg' ~/.ssh/config
    fi

    log "Adding configuration to ${SSH_CONFIG}"
    cat >> "${SSH_CONFIG}" <<EOL
#Start ${config_name}
Host ${config_name}
    HostName ${SSH_HOST_NAME}
    User root
    Port ${SSH_PORT}
    IdentityFile ${DS_SSH_KEY}
#${config_name}

EOL
    log "SSH configuration completed"
}

run_devspace()
{
    log "Preparing DevSpace ${DS_NAME}"
    local ds_status=$(devspaces ls | grep "${DS_NAME}" | awk -F"|" '{print $3}' | sed 's/ //g')

    while [ "${ds_status}" == "Stopping" ] || [ "${ds_status}" == "Building" ];
    do
        log "Waiting for DevSpace ${DS_NAME} to stop..."
        sleep 5
        ds_status=$(devspaces ls | grep "${DS_NAME}" | awk -F"|" '{print $3}' | sed 's/ //g')
    done

    if [ "${ds_status}" == "Stopped" ]; then
        log "Starting DevSpace ${DS_NAME}"
        devspaces start "${DS_NAME}"
    fi

    while [ ! "${ds_status}" == "Running" ]
    do
        log "Waiting for DevSpace ${DS_NAME} to start..."
        sleep 5
        ds_status=$(devspaces ls | grep "${DS_NAME}" | awk -F"|" '{print $3}' | sed 's/ //g')
    done
    log "DevSpace ${DS_NAME} is ready"
}

extract_data_from_devspace_info()
{
    local ssh_url=$(devspaces info ${DS_NAME} | grep "tcp://")
    SSH_HOST_NAME=$(echo ${ssh_url} | awk -F":" '{print $2}' | sed -e 's/\///g' | sed -e 's/ //g')
    SSH_PORT=$(echo ${ssh_url} | awk -F":" '{print $3}' | awk '{print $1}' | sed -e 's/ //g')
}

collect_devspace_url_and_port()
{
    log "Collecting DevSpace ${DS_NAME} info"
    extract_data_from_devspace_info

    if [ -z "${SSH_HOST_NAME}" ] || [ -z "${SSH_PORT}" ]; then
        log "Failed to extract host name or port. Retrying..."
        sleep 5
        extract_data_from_devspace_info
    fi

    log "Extracted ${DS_NAME} info. Host: ${SSH_HOST_NAME}, Port: ${SSH_PORT}"
}

add_ssh_to_devspace()
{
    log "Adding SSH pub key to DevSpace ${DS_NAME}"
    local pub_key=$(cat "${DS_SSH_KEY}.pub")
    local cmd="echo ${pub_key} > ~/.ssh/authorized_keys"
    devspaces exec ${DS_NAME} bash -c "${cmd}"
    log "Added SSH pub key to DevSpace ${DS_NAME}"
}

if [ "$#" -ge 2 ]; then
    echo "Invalid number of arguments"
    usage
    exit 1
fi

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
    exit 0
fi

log "Launching...."
run_devspace
collect_devspace_url_and_port
configure_ssh
add_ssh_to_devspace
code-insiders
log "ALl set, go to VS Code Insiders and connect to your DevSpace"