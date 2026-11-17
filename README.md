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

## Exit codes

`Manage-VeeamServices.ps1` reports its outcome through the process exit code, so it is safe to use from CI pipelines, scheduled tasks, and wrapper scripts:

| Exit code | Meaning |
| --- | --- |
| `0` | All requested operations succeeded; also returned for `-Help` and when no Veeam services are found (nothing to do is not a failure) |
| `1` | One or more operations failed (check the `[FAIL]` entries), or conflicting parameters were supplied (e.g. `-Enable -Disable`) |

```powershell
.\Manage-VeeamServices.ps1 -Stop -Disable
if ($LASTEXITCODE -ne 0) { throw "Veeam services were not fully stopped/disabled." }
```

## Requirements

- Windows with PowerShell 5.1+
- An elevated PowerShell session (Administrator)
- Veeam Backup & Replication installed locally

## Adding a new script

Place new Veeam scripts in the repo root and add a row to the **Scripts** table above.
