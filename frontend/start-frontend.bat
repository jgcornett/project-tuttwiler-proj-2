@echo off
echo Starting Frontend Dev Server...
echo.
echo The dashboard will open automatically at http://localhost:3000
echo Press Ctrl+C to stop the server
echo.
cd /d "%~dp0"
call npm run dev

