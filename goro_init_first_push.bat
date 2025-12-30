@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title GORO :: Init + First Push

REM ============================================================
REM  GORO Repo Bootstrapper
REM  Fixes: "This repository is empty. Create a default branch..."
REM  - Creates initial commit on main and pushes to origin
REM  Put this file into your local repo folder (Desktop\goro)
REM ============================================================

cd /d "%~dp0"

echo ==========================================
echo  GORO :: INIT + FIRST PUSH
echo  Folder: %CD%
echo ==========================================
echo.

REM --- Check git
git --version >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Git not found in PATH.
  pause
  exit /b 1
)

REM --- Ensure repo initialized
if not exist ".git" (
  echo [INFO] .git not found. Initializing repo...
  git init
  if errorlevel 1 (
    echo [ERROR] git init failed.
    pause
    exit /b 1
  )
)

REM --- Ensure we are on main
echo [INFO] Switching/creating branch: main
git checkout -B main >nul 2>&1

REM --- Create minimal files if missing
if not exist "README.md" (
  echo # GORO > README.md
  echo Telegram SaaS Horoscope + AI Answers >> README.md
)

if not exist ".gitignore" (
  > .gitignore (
    echo .venv/
    echo __pycache__/
    echo *.pyc
    echo .env
    echo config/config.json
    echo logs/
  )
)

REM --- Check remote origin
git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo.
  echo [INPUT] Enter GitHub repo URL (example: https://github.com/traficmaniac-lgtm/Goro.git)
  set /p REPO_URL=origin URL:
  if "%REPO_URL%"=="" (
    echo [ERROR] Empty URL. Aborting.
    pause
    exit /b 1
  )
  git remote add origin "%REPO_URL%"
)

REM --- Add and commit
echo.
echo [INFO] Creating initial commit...
git add -A
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "Initial commit"
) else (
  echo [WARN] Nothing to commit (index empty).
)

REM --- Push
echo.
echo [INFO] Pushing to origin/main...
git push -u origin main
if errorlevel 1 (
  echo.
  echo [ERROR] Push failed.
  echo Tips:
  echo  - If asked for credentials, use GitHub PAT or GitHub Desktop login
  echo  - Check repo URL and permissions
  echo.
  pause
  exit /b 1
)

echo.
echo ==========================================
echo  DONE :: GitHub now has main branch
echo ==========================================
echo.
pause
exit /b 0
