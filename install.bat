@echo off
:: agy-godmode Windows installer (batch wrapper)
:: Double-click this file or run from cmd.exe
:: Requires PowerShell 7+ (pwsh) or Windows PowerShell 5.1+

where pwsh >nul 2>&1 && (
    pwsh -ExecutionPolicy Bypass -File "%~dp0install.ps1"
) || (
    powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"
)
pause
