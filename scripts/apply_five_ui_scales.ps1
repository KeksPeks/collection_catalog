$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$file = Join-Path $root 'lib\app\app.dart'

if (-not (Test-Path $file)) {
    throw "File not found: $file"
}

$content = Get-Content $file -Raw -Encoding UTF8

$expectedFont = 'const [0.75, 0.875, 1.0, 1.125, 1.25]'
$expectedUi = 'const [0.70, 0.85, 1.0, 1.15, 1.30]'

if (-not $content.Contains($expectedFont)) {
    throw "Five font scale presets were not found in app.dart"
}

if (-not $content.Contains($expectedUi)) {
    throw "Five UI scale presets were not found in app.dart"
}

if (-not $content.Contains('double _validScale(double? value)')) {
    throw "Scale validation was not found in app.dart"
}

Write-Host ''
Write-Host 'OK: app.dart already contains five font and UI scale presets.' -ForegroundColor Green
Write-Host 'Font: 75%, 87.5%, 100%, 112.5%, 125%.'
Write-Host 'UI: 70%, 85%, 100%, 115%, 130%.'
Write-Host ''
Write-Host 'The script is verification-only and can be run repeatedly.' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Run:' -ForegroundColor Cyan
Write-Host 'flutter analyze'
Write-Host 'flutter run'
