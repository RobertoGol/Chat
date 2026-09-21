# 1. Показываем список веток напрямую через команду git
Write-Host "Доступные удаленные ветки на GitHub:" -ForegroundColor Cyan
git branch -r

# 2. Поле ввода ветки
Write-Host "`nВведите имя ветки (например, origin/project_ref): " -ForegroundColor Cyan -NoNewline
$target = (Read-Host).Trim()

if ([string]::IsNullOrEmpty($target)) { 
    $target = "origin/main" 
}

# 3. Собираем списки файлов
$localList = Get-ChildItem -File | Select-Object -ExpandProperty Name
$gitList = git ls-tree -r --name-only $target

# 4. Объединяем и сортируем
$combined = ($localList + $gitList) | Select-Object -Unique | Sort-Object

# 5. Рисуем таблицу
Clear-Host
Write-Host ("{0,-50} | {1,-20}" -f "ЛОКАЛЬНАЯ ПАПКА (На ПК)", "РЕПОЗИТОРИЙ ($target)") -ForegroundColor Cyan
Write-Host ("-" * 85) -ForegroundColor Cyan

foreach ($file in $combined) {
    if ($file -eq "stat.ps1") { continue }

    $hasLocal = $localList -contains $file
    $hasGit = $gitList -contains $file

    if ($hasLocal -and $hasGit) {
        Write-Host ("{0,-50} | " -f $file) -ForegroundColor Green -NoNewline
        Write-Host "Синхронизирован (Зеленый)" -ForegroundColor Green
    }
    elseif ($hasLocal -and (-not $hasGit)) {
        Write-Host ("{0,-50} | " -f $file) -ForegroundColor Red -NoNewline
        Write-Host "НЕ ЗАГРУЖЕН (Красный)" -ForegroundColor Red
    }
    elseif ((-not $hasLocal) -and $hasGit) {
        Write-Host ("{0,-50} | " -f "⚠️ Файл отсутствует на ПК ($file)") -ForegroundColor Yellow -NoNewline
        Write-Host "Удален локально" -ForegroundColor Yellow
    }
}
