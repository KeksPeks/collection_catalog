@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

echo ==========================================
echo      Поиск импортов в проекте Flutter
echo ==========================================
echo.

set "ROOT=lib"

set /p SEARCH=Введите строку для поиска: 

if "%SEARCH%"=="" (
    echo.
    echo Строка поиска не введена.
    pause
    exit /b
)

echo.
echo Поиск "%SEARCH%"...
echo.

set FOUND=0

for /R "%ROOT%" %%F in (*.dart) do (

    findstr /N /I /C:"%SEARCH%" "%%F" >nul

    if not errorlevel 1 (

        set FOUND=1

        echo ======================================================
        echo %%F
        echo ------------------------------------------------------

        findstr /N /I /C:"%SEARCH%" "%%F"

        echo.
    )
)

if %FOUND%==0 (
    echo Совпадений не найдено.
)

echo ======================================================
echo Готово.
pause