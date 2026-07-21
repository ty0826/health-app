param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('release', 'patch')]
    [string]$Action,

    [Parameter(Mandatory = $true)]
    [ValidateSet('android', 'ios')]
    [string]$Platform,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^https://')]
    [string]$ApiBaseUrl,

    [string]$BuildName = '1.0.0',

    [int]$BuildNumber = 1
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command shorebird -ErrorAction SilentlyContinue)) {
    throw 'Shorebird CLI is not installed. Install it from https://docs.shorebird.dev and run shorebird login.'
}

if (-not (Test-Path -LiteralPath (Join-Path $projectRoot 'shorebird.yaml'))) {
    throw 'Missing shorebird.yaml. Run shorebird init once with the project owner account.'
}

if ($Platform -eq 'ios' -and -not $IsMacOS) {
    throw 'iOS releases and patches must be built on macOS with Xcode.'
}

$shorebirdArgs = @(
    $Action
    $Platform
    '--'
    "--dart-define=API_BASE_URL=$ApiBaseUrl"
)

if ($Action -eq 'release') {
    $shorebirdArgs += "--build-name=$BuildName"
    $shorebirdArgs += "--build-number=$BuildNumber"
}

Push-Location $projectRoot
try {
    & shorebird @shorebirdArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Shorebird $Action failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}
