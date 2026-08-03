@echo off
chcp 65001 > nul

echo ==========================================
echo        Просмотр структуры папки
echo ==========================================
echo.

set /p FOLDER=Введите путь к папке [lib]:

if "%FOLDER%"=="" set "FOLDER=lib"

if not exist "%FOLDER%" (
    echo.
    echo Ошибка: папка "%FOLDER%" не найдена.
    pause
    exit /b
)

echo.
echo Структура папки:
echo %FOLDER%
echo.

tree "%FOLDER%" /F /A

echo.
echo ==========================================
echo Готово.
echo ==========================================

pause