@echo off
echo Starting Project Tuttwiler...
echo.
echo This will start both the backend API and frontend dashboard
echo.
cd /d "%~dp0"

REM Start backend in new window
start "Backend API Server" cmd /k "cd backend && node server.js"

REM Wait a moment for backend to start
timeout /t 2 /nobreak >nul

REM Start frontend in new window
start "Frontend Dev Server" cmd /k "cd frontend && npm run dev"

echo.
echo Backend API: http://localhost:3001
echo Frontend Dashboard: http://localhost:3000
echo.
echo Both servers are starting in separate windows.
echo Close those windows or press Ctrl+C to stop them.
echo.
pause

