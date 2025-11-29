@echo off
echo ========================================
echo   Project Tuttwiler - Mission Control
echo ========================================
echo.

cd /d "%~dp0"

REM Start backend in background
echo [1/3] Starting Backend API Server...
start /B "Backend API" cmd /c "cd backend && node server.js"

REM Wait for backend
timeout /t 3 /nobreak >nul

REM Start frontend in background  
echo [2/3] Starting Frontend Dev Server...
start /B "Frontend Dev" cmd /c "cd frontend && npm run dev"

REM Wait for frontend
timeout /t 5 /nobreak >nul

REM Open the launcher HTML file
echo [3/3] Opening Dashboard...
start "" "frontend\launch.html"

echo.
echo ✅ Dashboard should open in your browser!
echo.
echo Backend: http://localhost:3001
echo Frontend: http://localhost:3000
echo.
echo Servers are running in the background.
echo Press any key to exit this window (servers will keep running).
pause >nul
