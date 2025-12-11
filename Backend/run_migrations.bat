@echo off
echo ================================
echo Train System - Run Migrations
echo ================================
echo.

cd /d "%~dp0"

echo Running all pending migrations...
echo.

node src\database\migrations\migrationRunner.js up

echo.
echo Press any key to exit...
pause > nul
