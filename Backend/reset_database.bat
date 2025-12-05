@echo off
echo ============================================
echo Resetting Train System Database
echo ============================================
echo.
echo This will:
echo 1. Drop existing train_system database
echo 2. Create new train_system database
echo 3. Create all tables with correct schema
echo 4. Insert sample data
echo.
pause

cd /d "%~dp0"
psql -U postgres -h localhost -p 5433 -f schema.sql

echo.
echo ============================================
echo Database reset complete!
echo ============================================
echo.
echo Admin credentials:
echo Email: admin@trainbooking.com
echo Password: Admin@123
echo.
pause
