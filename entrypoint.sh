#!/bin/bash

set -e

# Setup VS Code data directory as a symlink of directory under /data
# so that user no need to install extensions on every DevSpace restarts.
mkdir -p /data/.vscode-remote
if [ ! -L "${HOME}/.vscode-remote" ]; then
  # Create Symlink for VSCode data
  ln -s /data/.vscode-remote ${HOME}/.vscode-remote
fi

# Start SSH server
/usr/sbin/sshd -D &

exec "$@"
