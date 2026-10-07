@echo off
title Petit Monde Local Website
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
if errorlevel 1 (
  echo.
  echo Unable to start Petit Monde. Make sure port 8080 is free.
  echo Impossible de demarrer Petit Monde. Verifiez que le port 8080 est libre.
  pause
)
