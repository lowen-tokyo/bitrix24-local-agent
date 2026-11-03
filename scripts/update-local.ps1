$ErrorActionPreference = 'Stop'
$previousGitPrompt = $env:GIT_TERMINAL_PROMPT
$previousGcmInteractive = $env:GCM_INTERACTIVE
$env:GIT_TERMINAL_PROMPT = '0'
$env:GCM_INTERACTIVE = 'never'

$projectRoot = Split-Path -Parent $PSScriptRoot
$logDirectory = Join-Path $env:LOCALAPPDATA 'Bitrix24LocalAgent'
$logPath = Join-Path $logDirectory 'updates.log'
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null

function Report($message) {
    $line = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $message
    Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
    Write-Output $message
}

Push-Location $projectRoot
try {
    $origin = git remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $origin) {
        Report 'No Git origin is configured; update check skipped.'
        exit 0
    }

    $branch = git branch --show-current
    if ($LASTEXITCODE -ne 0 -or -not $branch) {
        Report 'No current Git branch; update check skipped.'
        exit 0
    }

    $changes = @(git status --porcelain)
    if ($LASTEXITCODE -ne 0 -or $changes.Count -gt 0) {
        Report 'Local changes exist; update skipped to preserve them.'
        exit 0
    }

    git fetch --quiet origin $branch
    if ($LASTEXITCODE -ne 0) { throw 'Could not fetch Git origin.' }

    $localCommit = git rev-parse HEAD
    $remoteRef = 'origin/' + $branch
    $remoteCommit = git rev-parse $remoteRef
    if ($LASTEXITCODE -ne 0) { throw 'Could not read the remote branch.' }

    if ($localCommit -eq $remoteCommit) {
        Report 'Agent is up to date.'
        exit 0
    }

    $mergeBase = git merge-base HEAD $remoteRef
    if ($LASTEXITCODE -ne 0 -or $mergeBase -ne $localCommit) {
        Report 'Local and remote histories diverged; automatic update skipped.'
        exit 0
    }

    git merge --ff-only $remoteRef
    if ($LASTEXITCODE -ne 0) { throw 'Fast-forward update failed.' }
    & (Join-Path $PSScriptRoot 'install-local.ps1') | Out-Host
    if (-not $?) { throw 'Updated source, but plugin installation failed.' }
    $version = (Get-Content -LiteralPath (Join-Path $projectRoot 'plugins\bitrix24-local-agent\plugin.json') -Raw | ConvertFrom-Json).version
    Report "Updated agent to version $version. New chats will use it."
} catch {
    Report ('Update failed: ' + $_.Exception.Message)
    exit 1
} finally {
    Pop-Location
    $env:GIT_TERMINAL_PROMPT = $previousGitPrompt
    $env:GCM_INTERACTIVE = $previousGcmInteractive
}
