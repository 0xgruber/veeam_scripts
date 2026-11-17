# veeam_scripts

A collection of standalone PowerShell scripts for managing Veeam environments.

## Scripts

| Script | Description |
| --- | --- |
| [`Manage-VeeamServices.ps1`](./Manage-VeeamServices.ps1) | Manages the state and startup type of all local Veeam services (`Veeam*`). |

## Manage-VeeamServices.ps1

Starts, stops, enables, or disables all local Veeam services. Useful for patching or maintenance windows where services should not be running.

```powershell
# Stop all Veeam services and prevent them from starting on boot
.\Manage-VeeamServices.ps1 -Stop -Disable

# Set all services to Automatic and start them
.\Manage-VeeamServices.ps1 -Enable -Start

# Stop services temporarily (they restart on next boot if Enabled)
.\Manage-VeeamServices.ps1 -Stop

# Show help
.\Manage-VeeamServices.ps1 -Help
```

## Requirements

- Windows with PowerShell 5.1+
- An elevated PowerShell session (Administrator)
- Veeam Backup & Replication installed locally

## Adding a new script

Place new Veeam scripts in the repo root and add a row to the **Scripts** table above.
