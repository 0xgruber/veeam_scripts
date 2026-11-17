param (
    [switch]$Enable,
    [switch]$Disable,
    [switch]$Start,
    [switch]$Stop,
    [switch]$Help
)

# ---------------------------------------------------------------------------
# Semantic console output
#
# Color standard (applied consistently across this repo):
#   Cyan     Informational: help text, progress, service counts
#   Green    Success: [ OK ] tags, completion summary
#   Red      Failure: [FAIL] tags and their error details
#   Yellow   Warning: recoverable problems, summaries containing failures
#
# Best practices applied:
#   - Color always backs a plain-text tag ([ OK ] / [FAIL]), so output stays
#     readable in redirected logs and for color-blind users.
#   - Honors the NO_COLOR convention (https://no-color.org).
# ---------------------------------------------------------------------------

$script:NoColor = -not [string]::IsNullOrEmpty($env:NO_COLOR)

function Write-Status {
    param (
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][ValidateSet('Info', 'Success', 'Error', 'Warning')][string]$Type
    )

    if ($script:NoColor) {
        Write-Host $Text
        return
    }

    $color = switch ($Type) {
        'Info'     { [ConsoleColor]::Cyan }
        'Success'  { [ConsoleColor]::Green }
        'Warning'  { [ConsoleColor]::Yellow }
        'Error'    { [ConsoleColor]::Red }
    }
    Write-Host $Text -ForegroundColor $color
}

function Write-OperationStatus {
    param (
        [Parameter(Mandatory = $true)][string]$Action,
        [object[]]$Errors = @()
    )

    # Fixed-width action column keeps all status tags aligned.
    Write-Host ("  -> {0}" -f ("{0}..." -f $Action).PadRight(30)) -NoNewline

    if (@($Errors).Count -gt 0) {
        Write-Status -Text '[FAIL]' -Type Error
        foreach ($err in @($Errors)) {
            Write-Status -Text ("          {0}" -f $err.Exception.Message) -Type Error
        }
        $script:failedOps++
    }
    else {
        Write-Status -Text '[ OK ]' -Type Success
    }
}

# 1. Check for Help or no parameters
$helpText = @"

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

"@
if ($Help -or (-not $Enable -and -not $Disable -and -not $Start -and -not $Stop)) {
    Write-Status -Text $helpText -Type Info
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
    Write-Status -Text "No Veeam services found on this system (no action taken)." -Type Warning
    exit
}

Write-Status -Text "Processing $($veeamServices.Count) Veeam services..." -Type Info

# 4. Process each service in the correct logical order
$script:failedOps = 0
$veeamServices | ForEach-Object {
    $svc = $_
    Write-Host ("[{0}]" -f $svc.Name)

    # STOP first
    if ($Stop) {
        $opErrors = $null
        Stop-Service -InputObject $svc -Force -ErrorAction SilentlyContinue -ErrorVariable opErrors
        Write-OperationStatus -Action 'Stopping' -Errors $opErrors
    }

    # DISABLE
    if ($Disable) {
        $opErrors = $null
        Set-Service -InputObject $svc -StartupType Disabled -ErrorAction SilentlyContinue -ErrorVariable opErrors
        Write-OperationStatus -Action 'Disabling' -Errors $opErrors
    }

    # ENABLE (Sets back to Automatic)
    if ($Enable) {
        $opErrors = $null
        Set-Service -InputObject $svc -StartupType Automatic -ErrorAction SilentlyContinue -ErrorVariable opErrors
        Write-OperationStatus -Action 'Setting to Automatic' -Errors $opErrors
    }

    # START last
    if ($Start) {
        $opErrors = $null
        Start-Service -InputObject $svc -ErrorAction SilentlyContinue -ErrorVariable opErrors
        Write-OperationStatus -Action 'Starting' -Errors $opErrors
    }
}

# 5. Summary
if ($script:failedOps -gt 0) {
    Write-Status -Text ("Operations completed with {0} failed operation(s). See the [FAIL] entries above." -f $script:failedOps) -Type Warning
}
else {
    Write-Status -Text "Operations complete." -Type Success
}
