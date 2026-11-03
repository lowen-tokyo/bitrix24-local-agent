$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$taskName = 'Bitrix24 Local Agent Updates'
$updater = Join-Path $PSScriptRoot 'update-local.ps1'

Push-Location $projectRoot
try {
    git remote get-url origin *> $null
    if ($LASTEXITCODE -ne 0) { throw 'Configure a Git origin before enabling automatic updates.' }
} finally {
    Pop-Location
}

$existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Task '$taskName' already exists. No changes made."
    exit 0
}

$arguments = '-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $updater + '"'
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arguments
$triggers = @(
    (New-ScheduledTaskTrigger -AtLogOn -User ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)),
    (New-ScheduledTaskTrigger -Daily -At 10:00)
)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -Description 'Check GitHub for Bitrix24 agent updates and install fast-forward releases.' | Out-Null
Write-Host "Automatic update checks enabled. Results: $env:LOCALAPPDATA\Bitrix24LocalAgent\updates.log"
