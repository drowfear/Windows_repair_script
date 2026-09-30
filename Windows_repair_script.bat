@echo off
:: ==============================================================================
:: Created by DrSt1nger - https://github.com/DrSt1nger/Windows_repair_script
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
echo [INFO] Executing maintenance steps sequentially. Watch the output below.
echo.
timeout /t 2 >nul

:: ------------------------------------------------------------------------------
:: PHASE 1: DISM (Deployment Image Servicing and Management)
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PROGRESS: 16%] [PHASE 1/6] Running: dism /Online /Cleanup-Image /RestoreHealth
echo ==============================================================================
echo.
dism /Online /Cleanup-Image /RestoreHealth
echo.
echo [OK] Phase 1 completed.
echo.

:: ------------------------------------------------------------------------------
:: PHASE 2: SFC (System File Checker)
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PROGRESS: 33%] [PHASE 2/6] Running: sfc /scannow
echo ==============================================================================
echo.
sfc /scannow
echo.
echo [OK] Phase 2 completed.
echo.

:: ------------------------------------------------------------------------------
:: PHASE 3: WinSxS Component Store Cleanup
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PROGRESS: 50%] [PHASE 3/6] Running: dism /Online /Cleanup-Image /StartComponentCleanup
echo ==============================================================================
echo.
dism /Online /Cleanup-Image /StartComponentCleanup
echo.
echo [OK] Phase 3 completed.
echo.

:: ------------------------------------------------------------------------------
:: PHASE 4: Disk Integrity Check
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PROGRESS: 66%] [PHASE 4/6] Running: chkdsk C: /scan
echo ==============================================================================
echo.
chkdsk C: /scan
echo.
echo [OK] Phase 4 completed.
echo.

:: ------------------------------------------------------------------------------
:: PHASE 5: Temp Files & Windows Update Cache Cleanup
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PROGRESS: 83%] [PHASE 5/6] Cleaning Temporary Files and Windows Update Cache...
echo ==============================================================================
echo.

echo [+] Stopping services: wuauserv, bits, cryptsvc...
for %%S in (wuauserv bits cryptsvc) do (
    net stop %%S
)

echo [+] Removing SoftwareDistribution Download folder...
rd /s /q "%SystemRoot%\SoftwareDistribution\Download"

echo [+] Restarting services...
for %%S in (wuauserv bits cryptsvc) do (
    net start %%S
)

echo [+] Deleting user TEMP files...
del /f /q /s "%TEMP%\*.*" 2>nul

echo [+] Deleting Windows TEMP files...
del /f /q /s "%SystemRoot%\Temp\*.*" 2>nul

echo.
echo [OK] Phase 5 completed.
echo.

:: ------------------------------------------------------------------------------
:: PHASE 6: Network & DNS Reset
:: ------------------------------------------------------------------------------
echo.
echo ==============================================================================
echo [PROGRESS: 100%] [PHASE 6/6] Resetting Network & Flushing DNS...
echo ==============================================================================
echo.

echo [+] Running: ipconfig /flushdns
ipconfig /flushdns

echo [+] Running: netsh winsock reset
netsh winsock reset

echo [+] Running: netsh int ip reset
netsh int ip reset

echo.
echo [OK] Phase 6 completed.
echo ==== PROCESS FINISHED (%DATE% %TIME%) ==== >> "%LOG%"

:: ------------------------------------------------------------------------------
:: FINISHED
:: ------------------------------------------------------------------------------
echo.
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
