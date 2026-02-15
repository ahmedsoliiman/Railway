@echo off
echo Installing Git for Windows...
winget install --id Git.Git -e --source winget
echo.
echo Git installation complete. Please close this window and run push_github.bat again.
pause
