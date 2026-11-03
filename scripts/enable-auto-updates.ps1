$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$taskName = 'Bitrix24 Local Agent Updates'
$taskDescription = 'Check GitHub for Bitrix24 agent updates and install fast-forward releases.'
$updater = Join-Path $PSScriptRoot 'update-local.ps1'

Push-Location $projectRoot
try {
    git remote get-url origin *> $null
    if ($LASTEXITCODE -ne 0) { throw 'Configure a Git origin before enabling automatic updates.' }
} finally {
    Pop-Location
}

$existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existing -and $existing.Description -ne $taskDescription) {
    throw "Task '$taskName' belongs to another command; it was not changed."
}

$arguments = '-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $updater + '"'
$powerShell = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$action = New-ScheduledTaskAction -Execute $powerShell -Argument $arguments
$triggers = @(
    (New-ScheduledTaskTrigger -AtLogOn -User ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)),
    (New-ScheduledTaskTrigger -Daily -At 10:00)
)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -Principal $principal -Description $taskDescription -Force | Out-Null
Write-Host "Automatic update checks enabled. Results: $env:LOCALAPPDATA\Bitrix24LocalAgent\updates.log"
