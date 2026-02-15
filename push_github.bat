@echo off
cd /d "%~dp0"
echo Adding changes...
"C:\Program Files\Git\cmd\git.exe" add .

echo Committing changes...
"C:\Program Files\Git\cmd\git.exe" commit -m "Supabase Integration Complete: Real Payments, Cancellations, Password Reset"

echo Pushing to GitHub...
"C:\Program Files\Git\cmd\git.exe" push origin main

echo Done!
pause
