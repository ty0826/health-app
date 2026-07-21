param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^https://')]
    [string]$ApiBaseUrl,

    [ValidateSet('aab', 'apk')]
    [string]$Format = 'aab',

    [string]$BuildName = '1.0.0',

    [int]$BuildNumber = 1
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$keyProperties = Join-Path $projectRoot 'android\key.properties'

if (-not (Test-Path -LiteralPath $keyProperties)) {
    throw 'Missing android/key.properties. Copy android/key.properties.example and fill in the release signing values.'
}

$flutterArgs = @(
    'build'
    $(if ($Format -eq 'aab') { 'appbundle' } else { 'apk' })
    '--release'
    "--build-name=$BuildName"
    "--build-number=$BuildNumber"
    "--dart-define=API_BASE_URL=$ApiBaseUrl"
)

Push-Location $projectRoot
try {
    & flutter @flutterArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter Android release build failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}
