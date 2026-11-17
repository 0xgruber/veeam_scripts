param (
    [switch]$Enable,
    [switch]$Disable,
    [switch]$Start,
    [switch]$Stop,
    [switch]$Help
)

# 1. Check for Help or no parameters
if ($Help -or (-not $Enable -and -not $Disable -and -not $Start -and -not $Stop)) {
    Write-Host @"

NAME
    Manage-VeeamServices.ps1

SYNOPSIS
    Manages the state and startup type of all local Veeam services.

PARAMETERS
    -Start      Starts all Veeam services.
    -Stop       Stops all Veeam services.
    -Enable     Sets the startup type of all Veeam services to Automatic.
    -Disable    Sets the startup type of all Veeam services to Disabled.
    -Help       Displays this help message.

EXAMPLES
    .\Manage-VeeamServices.ps1 -Stop -Disable
        Stops all Veeam services and prevents them from starting on boot.
        
    .\Manage-VeeamServices.ps1 -Enable -Start
        Sets all Veeam services to Automatic and starts them immediately.
        
    .\Manage-VeeamServices.ps1 -Stop
        Stops the services temporarily (they will restart on the next boot if Enabled).

"@ -ForegroundColor Cyan
    exit
}

# 2. Validate conflicting parameters
if ($Enable -and $Disable) {
    Write-Warning "You cannot specify both -Enable and -Disable."
    exit
}

if ($Start -and $Stop) {
    Write-Warning "You cannot specify both -Start and -Stop."
    exit
}

# 3. Find Veeam services
$veeamServices = Get-Service -Name "Veeam*" -ErrorAction SilentlyContinue

if (-not $veeamServices) {
    Write-Host "No Veeam services found on this system." -ForegroundColor Yellow
    exit
}

Write-Host "Processing $($veeamServices.Count) Veeam services..." -ForegroundColor Cyan

# 4. Process each service in the correct logical order
$veeamServices | ForEach-Object {
    $svc = $_
    Write-Host ("[{0}]" -f $svc.Name) -ForegroundColor White

    # STOP first
    if ($Stop) {
        Write-Host "  -> Stopping..." -NoNewline
        Stop-Service -InputObject $svc -Force -ErrorAction SilentlyContinue
        Write-Host " Done" -ForegroundColor DarkGray
    }

    # DISABLE
    if ($Disable) {
        Write-Host "  -> Disabling..." -NoNewline
        Set-Service -InputObject $svc -StartupType Disabled
        Write-Host " Done" -ForegroundColor DarkGray
    }

    # ENABLE (Sets back to Automatic)
    if ($Enable) {
        Write-Host "  -> Setting to Automatic..." -NoNewline
        Set-Service -InputObject $svc -StartupType Automatic
        Write-Host " Done" -ForegroundColor DarkGray
    }

    # START last
    if ($Start) {
        Write-Host "  -> Starting..." -NoNewline
        Start-Service -InputObject $svc -ErrorAction SilentlyContinue
        Write-Host " Done" -ForegroundColor DarkGray
    }
}

Write-Host "Operations complete." -ForegroundColor Green