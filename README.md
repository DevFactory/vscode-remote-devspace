# VS Code Remote Development in DevSpaces

Read more about remote development support in VS Code https://code.visualstudio.com/docs/remote/remote-overview

### Prerequisites
- Remote development feature is only available in Code Insiders. **Make sure you have installed this version https://code.visualstudio.com/insiders/**.

- Install "Remote Development" extension from VS Code market place https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack


## Overview
DevSpace with `Python v3.6` and `NodeJS v12.3` for using as a remote development environment. 
So that you can debug and run the application within your DevSpace using VS Code.


## Configuring Remote Development

1. Create your DevSpace by running `devspaces create` command from this directory.
2. Wait for DevSpace creation, then validation completion
3. Run `devspaces start vscode-remote` command to start your DevSpace
4. Execute `./run.sh` script. This prepares the environment and opens VS Code
7. From VS Code open "**Remote SSH**" pane, which should show `devspace-vscode-remote` under the connections.
8. Click on the connect button, which will open a new VS Code window and you can open `/data` directory which is in your DevSpace to see the files.


### Demo

