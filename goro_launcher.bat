@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title GORO :: Launcher

cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
  echo [INFO] Creating venv...
  python -m venv .venv
)

call ".venv\Scripts\activate.bat"
python -m pip install --upgrade pip >nul

:menu
echo.
echo ==========================================
echo   GORO Launcher
echo ==========================================
echo  [1] Run Configurator UI
echo  [2] Run Bot
echo  [3] Install/Update deps (requirements.txt)
echo  [4] Exit
echo.
set /p choice=Select:

if "%choice%"=="1" goto run_cfg
if "%choice%"=="2" goto run_bot
if "%choice%"=="3" goto install
if "%choice%"=="4" goto end

echo Invalid choice
goto menu

:install
if exist requirements.txt (
  pip install -r requirements.txt
) else (
  echo [WARN] requirements.txt not found
)
pause
goto menu

:run_cfg
python tools\configurator_ui.py
pause
goto menu

:run_bot
python bot\main.py
pause
goto menu

:end
exit /b
