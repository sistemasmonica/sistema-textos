@echo off
chcp 65001 > nul
echo.
echo  Iniciando respaldo de datos...
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0hacer_backup.ps1"
