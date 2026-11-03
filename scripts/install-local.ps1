$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$marketplaceName = 'bitrix24-local'
$pluginId = 'bitrix24-local-agent@bitrix24-local'

$codexCommand = Get-Command codex -ErrorAction SilentlyContinue
if (-not $codexCommand) {
    $fallback = Join-Path $env:LOCALAPPDATA 'Programs\OpenAI\Codex\bin\codex.exe'
    if (Test-Path -LiteralPath $fallback) { $codexCommand = Get-Item -LiteralPath $fallback }
}
if (-not $codexCommand) { throw 'Codex CLI was not found. Install the ChatGPT/Codex desktop app first.' }
$codexPath = $codexCommand.Source
if (-not $codexPath) { $codexPath = $codexCommand.FullName }

Push-Location $projectRoot
try {
    $marketplaces = & $codexPath plugin marketplace list --json | ConvertFrom-Json
    $known = @($marketplaces.marketplaces | Where-Object { $_.name -eq $marketplaceName })
    if ($known.Count -eq 0) {
        & $codexPath plugin marketplace add . | Out-Host
        if ($LASTEXITCODE -ne 0) { throw 'Could not add the local marketplace.' }
    }

    & $codexPath plugin add $pluginId | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Could not install the local Bitrix24 plugin.' }
    Write-Host 'Installed. Start a new local chat to load the updated plugin.'
} finally {
    Pop-Location
}
