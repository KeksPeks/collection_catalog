$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$file = Join-Path $root 'lib\app\app.dart'

if (-not (Test-Path $file)) {
    throw "Не найден файл: $file"
}

$content = Get-Content $file -Raw -Encoding UTF8

$oldSizeName = @'
  String _sizeName(BuildContext context, double value) {
    if (value < 0.95) {
      return _text(context, 'Маленький', 'Small', 'Klein', 'Petit', 'Pequeño', 'Piccolo', 'Pequeno', '小', '小', '작게', 'صغير');
    }
    if (value > 1.05) {
      return _text(context, 'Большой', 'Large', 'Groß', 'Grand', 'Grande', 'Grande', 'Grande', '大', '大', '크게', 'كبير');
    }
    return _text(context, 'Средний', 'Medium', 'Mittel', 'Moyen', 'Medio', 'Medio', 'Médio', '中', '中', '중간', 'متوسط');
  }
'@

$newSizeName = @'
  String _sizeName(BuildContext context, double value) {
    if (value < 0.8125) {
      return _text(context, 'Очень маленький', 'Very small', 'Sehr klein', 'Très petit', 'Muy pequeño', 'Molto piccolo', 'Muito pequeno', '极小', '極小', '매우 작게', 'صغير جدًا');
    }
    if (value < 0.9375) {
      return _text(context, 'Маленький', 'Small', 'Klein', 'Petit', 'Pequeño', 'Piccolo', 'Pequeno', '小', '小', '작게', 'صغير');
    }
    if (value < 1.0625) {
      return _text(context, 'Средний', 'Medium', 'Mittel', 'Moyen', 'Medio', 'Medio', 'Médio', '中', '中', '중간', 'متوسط');
    }
    if (value < 1.1875) {
      return _text(context, 'Большой', 'Large', 'Groß', 'Grand', 'Grande', 'Grande', 'Grande', '大', '大', '크게', 'كبير');
    }
    return _text(context, 'Очень большой', 'Very large', 'Sehr groß', 'Très grand', 'Muy grande', 'Molto grande', 'Muito grande', '极大', '極大', '매우 크게', 'كبير جدًا');
  }
'@

if (-not $content.Contains($oldSizeName)) {
    throw 'Не найден метод _sizeName. Возможно, файл уже изменён или имеет другую версию.'
}

$content = $content.Replace($oldSizeName, $newSizeName)

$oldValues = "final values = font ? const [0.85, 1.0, 1.15] : const [0.75, 1.0, 1.25];"
$newValues = "final values = font ? const [0.75, 0.875, 1.0, 1.125, 1.25] : const [0.70, 0.85, 1.0, 1.15, 1.30];"

if (-not $content.Contains($oldValues)) {
    throw 'Не найден список старых размеров в _showScale.'
}

$content = $content.Replace($oldValues, $newValues)

Set-Content -Path $file -Value $content -Encoding UTF8

Write-Host ''
Write-Host 'Готово: app.dart переведен на 5 размеров.' -ForegroundColor Green
Write-Host 'Шрифт: 75%, 87.5%, 100%, 112.5%, 125%.'
Write-Host 'Интерфейс: 70%, 85%, 100%, 115%, 130%.'
Write-Host ''
Write-Host 'Теперь выполните:' -ForegroundColor Cyan
Write-Host 'flutter analyze'
Write-Host 'flutter run'
