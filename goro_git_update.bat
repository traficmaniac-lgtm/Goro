@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title GORO :: Git Update

REM ============================================================
REM  GORO Git Updater (Windows BAT)
REM  - Updates current repo folder from GitHub
REM  - Shows progress/log output
REM  - Safe by default: uses stash (optional) + pull --ff-only
REM ============================================================

REM --- Go to folder where this .bat is located (repo root expected)
cd /d "%~dp0"

echo ==========================================
echo  GORO :: GIT UPDATE
echo  Folder: %CD%
echo ==========================================
echo.

REM --- Check git exists
git --version >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Git not found in PATH. Install Git for Windows and retry.
  echo.
  pause
  exit /b 1
)

REM --- Check this is a git repo
if not exist ".git" (
  echo [ERROR] This folder is not a git repository (.git not found).
  echo Put this .bat into the repo root folder and run again.
  echo.
  pause
  exit /b 1
)

REM --- Show current branch
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set BRANCH=%%B
if "%BRANCH%"=="" set BRANCH=main
echo [INFO] Branch: %BRANCH%
echo.

REM --- Optional stash (only if there are local changes)
echo [INFO] Checking local changes...
for /f "delims=" %%S in ('git status --porcelain 2^>nul') do set HASCHANGES=1
if defined HASCHANGES (
  echo [WARN] Local changes detected.
  echo        I will stash them to avoid merge conflicts.
  echo.
  git stash push -u -m "auto-stash before update" >nul 2>&1
  if errorlevel 1 (
    echo [ERROR] Failed to stash changes. Aborting.
    echo.
    pause
    exit /b 1
  )
  set DIDSTASH=1
  echo [OK] Changes stashed.
  echo.
) else (
  echo [OK] Working tree clean.
  echo.
)

REM --- Fetch with progress
echo [INFO] Fetching from origin (with progress)...
git -c color.ui=always fetch --all --prune --progress
if errorlevel 1 (
  echo.
  echo [ERROR] Fetch failed. Check your internet / credentials.
  echo.
  pause
  exit /b 1
)
echo.

REM --- Pull (fast-forward only)
echo [INFO] Pulling updates (fast-forward only)...
git -c color.ui=always pull --ff-only --progress origin %BRANCH%
if errorlevel 1 (
  echo.
  echo [ERROR] Pull failed (non fast-forward or conflict).
  echo        Fix options:
  echo        1) Commit your local changes, then rerun
  echo        2) OR run: git reset --hard origin/%BRANCH%  (WILL DISCARD LOCAL CHANGES)
  echo.
  REM If we stashed, keep stash for safety (do not pop automatically on error)
  if defined DIDSTASH (
    echo [INFO] Your changes are in stash. You can view with: git stash list
  )
  echo.
  pause
  exit /b 1
)
echo.

REM --- Show what changed (last few commits)
echo [INFO] Latest commits:
git --no-pager log --oneline -n 8
echo.

REM --- If we stashed, try to pop
if defined DIDSTASH (
  echo [INFO] Restoring your stashed changes...
  git stash pop
  if errorlevel 1 (
    echo.
    echo [WARN] Stash pop had conflicts. Your stash is kept as backup.
    echo        Resolve conflicts, then you can apply manually.
    echo        Stashes: git stash list
    echo.
    pause
    exit /b 1
  )
  echo [OK] Stashed changes restored.
  echo.
)

echo ==========================================
echo  DONE :: Repo is up to date
echo ==========================================
echo.
pause
exit /b 0
