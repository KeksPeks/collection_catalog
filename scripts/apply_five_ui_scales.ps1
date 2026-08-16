$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$file = Join-Path $root 'lib\app\app.dart'

if (-not (Test-Path $file)) {
    throw "File not found: $file"
}

$content = Get-Content $file -Raw -Encoding UTF8

# Replace the three-level size-name method without relying on non-ASCII PowerShell source encoding.
$methodPattern = '(?s)  String _sizeName\(BuildContext context, double value\) \{.*?\n  \}\r?\n'
$newSizeName = @'
  String _sizeName(BuildContext context, double value) {
    if (value < 0.8125) {
      return _text(context, '\u041e\u0447\u0435\u043d\u044c \u043c\u0430\u043b\u0435\u043d\u044c\u043a\u0438\u0439', 'Very small', 'Sehr klein', 'Tres petit', 'Muy pequeno', 'Molto piccolo', 'Muito pequeno', '\u6781\u5c0f', '\u6975\u5c0f', '\ub9e4\uc6b0 \uc791\uac8c', '\u0635\u063a\u064a\u0631 \u062c\u062f\u064b\u0627');
    }
    if (value < 0.9375) {
      return _text(context, '\u041c\u0430\u043b\u0435\u043d\u044c\u043a\u0438\u0439', 'Small', 'Klein', 'Petit', 'Pequeno', 'Piccolo', 'Pequeno', '\u5c0f', '\u5c0f', '\uc791\uac8c', '\u0635\u063a\u064a\u0631');
    }
    if (value < 1.0625) {
      return _text(context, '\u0421\u0440\u0435\u0434\u043d\u0438\u0439', 'Medium', 'Mittel', 'Moyen', 'Medio', 'Medio', 'Medio', '\u4e2d', '\u4e2d', '\uc911\uac04', '\u0645\u062a\u0648\u0633\u0637');
    }
    if (value < 1.1875) {
      return _text(context, '\u0411\u043e\u043b\u044c\u0448\u043e\u0439', 'Large', 'Gross', 'Grand', 'Grande', 'Grande', 'Grande', '\u5927', '\u5927', '\ud06c\uac8c', '\u0643\u0628\u064a\u0631');
    }
    return _text(context, '\u041e\u0447\u0435\u043d\u044c \u0431\u043e\u043b\u044c\u0448\u043e\u0439', 'Very large', 'Sehr gross', 'Tres grand', 'Muy grande', 'Molto grande', 'Muito grande', '\u6781\u5927', '\u6975\u5927', '\ub9e4\uc6b0 \ud06c\uac8c', '\u0643\u0628\u064a\u0631 \u062c\u062f\u064b\u0627');
  }
'@

if (-not [regex]::IsMatch($content, $methodPattern)) {
    throw "Method _sizeName was not found in app.dart"
}

$content = [regex]::Replace($content, $methodPattern, $newSizeName, 1)

$oldValues = "final values = font ? const [0.85, 1.0, 1.15] : const [0.75, 1.0, 1.25];"
$newValues = "final values = font ? const [0.75, 0.875, 1.0, 1.125, 1.25] : const [0.70, 0.85, 1.0, 1.15, 1.30];"

if (-not $content.Contains($oldValues)) {
    throw "Old scale values were not found in app.dart"
}

$content = $content.Replace($oldValues, $newValues)

Set-Content -Path $file -Value $content -Encoding UTF8

Write-Host ''
Write-Host 'Done: app.dart now uses five font and UI scale presets.' -ForegroundColor Green
Write-Host 'Font: 75%, 87.5%, 100%, 112.5%, 125%.'
Write-Host 'UI: 70%, 85%, 100%, 115%, 130%.'
Write-Host ''
Write-Host 'Run:' -ForegroundColor Cyan
Write-Host 'flutter analyze'
Write-Host 'flutter run'
