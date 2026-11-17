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

## Console output

Scripts follow a consistent semantic color scheme:

| Color | Meaning |
| --- | --- |
| Cyan | Informational output (help text, progress, service counts) |
| Green | Successful operations and `[ OK ]` status tags |
| Red | Failed operations, `[FAIL]` status tags, and their error details |
| Yellow | Warnings and summaries containing failures |

Every colored status also carries a plain-text tag (`[ OK ]` / `[FAIL]`), so output stays readable when redirected to logs or for color-blind users. To turn off coloring entirely, set the `NO_COLOR` environment variable ([no-color.org convention](https://no-color.org/)):

```powershell
$env:NO_COLOR = '1'
.\Manage-VeeamServices.ps1 -Stop
```

## Requirements

- Windows with PowerShell 5.1+
- An elevated PowerShell session (Administrator)
- Veeam Backup & Replication installed locally

## Adding a new script

Place new Veeam scripts in the repo root and add a row to the **Scripts** table above.
