@echo off
setlocal
cd /d "%~dp0"

where pnpm >nul 2>nul
if errorlevel 1 (
    echo [run.bat] pnpm not found. Install pnpm, or run: corepack enable
    pause
    exit /b 1
)

where cargo >nul 2>nul
if errorlevel 1 (
    echo [run.bat] cargo not found. Install Rust from https://rustup.rs
    pause
    exit /b 1
)

if not exist "node_modules\" (
    echo [run.bat] Installing dependencies...
    call pnpm install
    if errorlevel 1 (
        echo [run.bat] pnpm install failed.
        pause
        exit /b 1
    )
)

set "EXE=%~dp0src-tauri\target\release\nyaterm.exe"

rem A running release exe locks the file the linker has to replace.
echo [run.bat] Closing a running release NyaTerm, if any...
powershell -NoProfile -NonInteractive -Command "$exe = [IO.Path]::GetFullPath('%EXE%'); Get-Process nyaterm -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exe } | ForEach-Object { [void]$_.CloseMainWindow(); if (-not $_.WaitForExit(5000)) { $_.Kill(); $_.WaitForExit(5000) | Out-Null } }"

echo [run.bat] Building release...
call pnpm tauri build --no-bundle
if errorlevel 1 (
    echo [run.bat] Release build failed.
    pause
    exit /b 1
)

if not exist "%EXE%" (
    echo [run.bat] Missing %EXE%
    pause
    exit /b 1
)

echo [run.bat] Starting NyaTerm...
start "" /D "%~dp0src-tauri\target\release" "%EXE%"
endlocal
