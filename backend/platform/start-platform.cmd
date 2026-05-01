@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SERVER_PATH=%SCRIPT_DIR%server.js"
set "BUNDLED_NODE=C:\Users\U S E R\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
set "SD_PLATFORM_HOST=%~1"
set "SD_PLATFORM_PORT=%~2"

if "%SD_PLATFORM_HOST%"=="" set "SD_PLATFORM_HOST=127.0.0.1"
if "%SD_PLATFORM_PORT%"=="" set "SD_PLATFORM_PORT=4100"

echo.
echo Starting SD Travel Guide platform on %SD_PLATFORM_HOST%:%SD_PLATFORM_PORT% ...

if exist "%BUNDLED_NODE%" (
  "%BUNDLED_NODE%" "%SERVER_PATH%"
) else (
  echo Bundled Node runtime was not found, falling back to node from PATH.
  node "%SERVER_PATH%"
)
