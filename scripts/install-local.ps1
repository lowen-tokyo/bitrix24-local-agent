$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$marketplaceName = 'bitrix24-local'
$pluginId = 'bitrix24-local-agent@bitrix24-local'

if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    throw 'Codex CLI was not found. Install the ChatGPT/Codex desktop app first.'
}

Push-Location $projectRoot
try {
    $marketplaces = codex plugin marketplace list --json | ConvertFrom-Json
    $known = @($marketplaces.marketplaces | Where-Object { $_.name -eq $marketplaceName })
    if ($known.Count -eq 0) {
        codex plugin marketplace add . | Out-Host
        if ($LASTEXITCODE -ne 0) { throw 'Could not add the local marketplace.' }
    }

    codex plugin add $pluginId | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Could not install the local Bitrix24 plugin.' }
    Write-Host 'Installed. Start a new local chat to load the updated plugin.'
} finally {
    Pop-Location
}
