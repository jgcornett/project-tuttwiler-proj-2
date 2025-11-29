@echo off
echo Starting Backend API Server...
echo.
echo API will be available at http://localhost:3001
echo Press Ctrl+C to stop the server
echo.
cd /d "%~dp0"
call node server.js

