$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $projectRoot 'plugins\bitrix24-local-agent\plugin.json'
$expectedVersion = (Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json).version
$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
if (-not $codexCommand) {
    $fallback = Join-Path $env:LOCALAPPDATA 'Programs\OpenAI\Codex\bin\codex.exe'
    if (Test-Path -LiteralPath $fallback) { $codexCommand = Get-Item -LiteralPath $fallback }
}
if (-not $codexCommand) { throw 'Codex CLI was not found.' }
$codexPath = $codexCommand.Source
if (-not $codexPath) { $codexPath = $codexCommand.FullName }

$plugins = & $codexPath plugin list --json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Could not read installed Codex plugins.' }
$plugin = @($plugins.installed | Where-Object { $_.pluginId -eq 'bitrix24-local-agent@bitrix24-local' })
$null = git -C $projectRoot remote get-url origin 2>$null
$originConfigured = ($LASTEXITCODE -eq 0)
$task = Get-ScheduledTask -TaskName 'Bitrix24 Local Agent Updates' -ErrorAction SilentlyContinue
$taskInfo = if ($task) { Get-ScheduledTaskInfo -TaskName 'Bitrix24 Local Agent Updates' } else { $null }

$result = [pscustomobject]@{
    SourceVersion = $expectedVersion
    InstalledVersion = if ($plugin.Count -eq 1) { $plugin[0].version } else { '(missing)' }
    PluginEnabled = ($plugin.Count -eq 1 -and $plugin[0].enabled)
    OriginConfigured = $originConfigured
    UpdateTaskState = if ($task) { [string]$task.State } else { '(missing)' }
    UpdateLastResult = if ($taskInfo) { $taskInfo.LastTaskResult } else { $null }
    UpdateNextRun = if ($taskInfo) { $taskInfo.NextRunTime } else { $null }
}
$result | Format-List

if ($plugin.Count -ne 1 -or -not $result.PluginEnabled -or $result.InstalledVersion -ne $expectedVersion) { exit 1 }
if (-not $originConfigured -or -not $task -or $task.State -eq 'Disabled') { exit 1 }
if ($taskInfo -and $taskInfo.LastRunTime -gt [datetime]::MinValue -and $taskInfo.LastTaskResult -ne 0) { exit 1 }
