$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command shorebird -ErrorAction SilentlyContinue)) {
    throw 'Shorebird CLI is not installed. Follow https://docs.shorebird.dev and then rerun this script.'
}

Push-Location $projectRoot
try {
    & shorebird doctor
    if ($LASTEXITCODE -ne 0) { throw 'shorebird doctor failed.' }

    & shorebird login
    if ($LASTEXITCODE -ne 0) { throw 'shorebird login failed.' }

    & shorebird init
    if ($LASTEXITCODE -ne 0) { throw 'shorebird init failed.' }

    Write-Host 'Shorebird is linked. Commit the generated shorebird.yaml before the first store release.'
}
finally {
    Pop-Location
}
