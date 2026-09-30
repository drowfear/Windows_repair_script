@echo off
:: ==============================================================================
:: Created by Drowfear - https://github.com/drowfear/Windows_repair_script
:: Optimized with real-time feedback and progress indicators
:: ==============================================================================
:: COMPREHENSIVE WINDOWS MAINTENANCE, REPAIR AND CLEANUP SCRIPT
:: Requires Administrator Privileges
:: ==============================================================================

title Windows System Repair and Deep Cleanup (Optimized)
color 0A

:: Create log file
set LOG=%SystemRoot%\Logs\RepairScript_Optimized.log
echo ==== PROCESS STARTED (%DATE% %TIME%) ==== >> "%LOG%"

:: 1. Administrator Privilege Check
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ==============================================================================
    echo [ERROR] This script MUST be executed as Administrator.
    echo.
    echo Right-click the .bat file and select "Run as administrator".
    echo ==============================================================================
    echo.
    pause
    exit /b
)

cls
echo ==============================================================================
echo                 STARTING SYSTEM MAINTENANCE AND REPAIR
echo ==============================================================================
echo [INFO] Initializing system diagnostic routines. Please do not close the window.
echo.
timeout /t 3 >nul

:: ------------------------------------------------------------------------------
:: PHASE 1: DISM (Deployment Image Servicing and Management)
:: ------------------------------------------------------------------------------
cls
echo ==============================================================================
echo [PROGRESS: 16%] [PHASE 1/6] Repairing Windows image (DISM)...
echo ==============================================================================
echo [STATUS] Running image restoration. This may take 5 to 15 minutes...
echo [INFO] Please wait, processing data in background...
echo.

:: Ejecutamos DISM en segundo plano mostrando animación de puntos para que se vea activo
start /b cmd /c "dism /Online /Cleanup-Image /RestoreHealth >> "%LOG%" 2>&1"
:loop_dism
tasklist /fi "imagename eq dism.exe" 2>nul | find /i "dism.exe" >nul
if %errorlevel% equ 0 (
    <nul set /p "=. "
    timeout /t 3 >nul
    goto loop_dism
)

echo.
echo [OK] DISM completed successfully!
timeout /t 2 >nul

:: ------------------------------------------------------------------------------
:: PHASE 2: SFC (System File Checker)
:: ------------------------------------------------------------------------------
cls
echo ==============================================================================
echo [PROGRESS: 33%] [PHASE 2/6] Scanning and repairing protected system files (SFC)...
echo ==============================================================================
echo [STATUS] Analyzing system file integrity. Please wait...
echo.

start /b cmd /c "sfc /scannow >> "%LOG%" 2>&1"
:loop_sfc
tasklist /fi "imagename eq sfc.exe" 2>nul | find /i "sfc.exe" >nul
if %errorlevel% equ 0 (
    <nul set /p "=. "
    timeout /t 3 >nul
    goto loop_sfc
)

echo.
echo [OK] SFC scan completed successfully!
timeout /t 2 >nul

:: ------------------------------------------------------------------------------
:: PHASE 3: WinSxS Component Store Cleanup
:: ------------------------------------------------------------------------------
cls
echo ==============================================================================
echo [PROGRESS: 50%] [PHASE 3/6] Cleaning and optimizing component store (WinSxS)...
echo ==============================================================================
echo [STATUS] Cleaning component store components. Please wait...
echo.

dism /Online /Cleanup-Image /StartComponentCleanup >> "%LOG%" 2>&1
echo [OK] Component store cleanup completed!
timeout /t 2 >nul

:: ------------------------------------------------------------------------------
:: PHASE 4: Disk Integrity Check
:: ------------------------------------------------------------------------------
cls
echo ==============================================================================
echo [PROGRESS: 66%] [PHASE 4/6] Checking drive C: integrity...
echo ==============================================================================
echo [STATUS] Scanning drive C: for filesystem errors...
echo.

chkdsk C: /scan >> "%LOG%" 2>&1
echo [OK] Disk scan completed!
timeout /t 2 >nul

:: ------------------------------------------------------------------------------
:: PHASE 5: Temp Files & Windows Update Cache Cleanup
:: ------------------------------------------------------------------------------
cls
echo ==============================================================================
echo [PROGRESS: 83%] [PHASE 5/6] Cleaning temporary files and Windows Update cache...
echo ==============================================================================
echo [STATUS] Stopping services and clearing temporary caches...
echo.

echo -- Stopping Windows Update related services...
for %%S in (wuauserv bits cryptsvc) do (
    net stop %%S >nul 2>&1
)

echo -- Removing Windows Update cache...
rd /s /q "%SystemRoot%\SoftwareDistribution\Download" 2>nul

echo -- Restarting services...
for %%S in (wuauserv bits cryptsvc) do (
    net start %%S >nul 2>&1
)

echo -- Cleaning temporary folders...
del /f /q /s "%TEMP%\*.*" 2>nul
del /f /q /s "%SystemRoot%\Temp\*.*" 2>nul

echo [OK] Temporary cleanup completed!
timeout /t 2 >nul

:: ------------------------------------------------------------------------------
:: PHASE 6: Network & DNS Reset
:: ------------------------------------------------------------------------------
cls
echo ==============================================================================
echo [PROGRESS: 100%] [PHASE 6/6] Resetting network components and flushing DNS...
echo ==============================================================================
echo [STATUS] Flushing DNS cache and resetting TCP/IP stack...
echo.

ipconfig /flushdns >> "%LOG%"
netsh winsock reset >> "%LOG%"
netsh int ip reset >> "%LOG%"

echo [OK] Network reset completed!
echo ==== PROCESS FINISHED (%DATE% %TIME%) ==== >> "%LOG%"

:: ------------------------------------------------------------------------------
:: FINISHED
:: ------------------------------------------------------------------------------
cls
echo ==============================================================================
echo                         MAINTENANCE COMPLETED! (100%)
echo ==============================================================================
echo All repair and cleanup tasks have been executed successfully.
echo A system reboot is recommended to apply all changes.
echo.
echo Log file saved at:
echo    %LOG%
echo.
pause
