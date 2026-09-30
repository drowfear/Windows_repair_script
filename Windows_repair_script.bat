@echo off
:: ==============================================================================
:: Original by Drowfear - https://github.com/drowfear/Windows_repair_script
:: Version con informe de progreso: explica cada fase y muestra el porcentaje
:: total cada 10 segundos, sin que el usuario tenga que intervenir.
:: Requiere privilegios de Administrador
:: ==============================================================================

:: Subrutinas internas (el propio script se llama a si mismo en segundo plano)
if /i "%~1"=="/fase5" goto :DoPhase5
if /i "%~1"=="/fase6" goto :DoPhase6

setlocal EnableExtensions
title Reparacion y limpieza de Windows
color 0A

:: ------------------------------------------------------------------------------
:: Comprobacion de privilegios de administrador
:: ------------------------------------------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ==============================================================================
    echo [ERROR] Este script DEBE ejecutarse como Administrador.
    echo.
    echo Haga clic derecho en el archivo .bat y elija "Ejecutar como administrador".
    echo ==============================================================================
    echo.
    pause
    exit /b 1
)

:: Registro (log) y carpeta con la salida detallada de cada fase
set "LOG=%SystemRoot%\Logs\RepairScript_Optimized.log"
set "DETAIL=%SystemRoot%\Logs\RepairScript_Detalle"
md "%DETAIL%" >nul 2>&1
>> "%LOG%" echo ==== PROCESO INICIADO (%DATE% %TIME%) ====

cls
echo ==============================================================================
echo            MANTENIMIENTO Y REPARACION AUTOMATICA DE WINDOWS
echo ==============================================================================
echo  El script se ejecuta solo: no hace falta pulsar nada hasta el final.
echo.
echo  Fases:  1 DISM RestoreHealth      2 SFC             3 Limpieza WinSxS
echo          4 CHKDSK                  5 Temporales y cache de Windows Update
echo          6 Red y DNS
echo.
echo  Cada 10 segundos vera el porcentaje TOTAL y el de la fase en curso.
echo  Duracion estimada: entre 20 y 60 minutos. NO cierre esta ventana.
echo ==============================================================================

call :GetNow
set "T_START=%NOW%"
set "BASE=0"
set "PH_TOTAL=6"

:: ------------------------------------------------------------------------------
:: FASE 1: DISM RestoreHealth
:: ------------------------------------------------------------------------------
set "PH_NUM=1"
set "PH_NAME=DISM RestoreHealth"
set "PH_DESC=Repara la imagen de Windows. Es la fase mas larga: puede quedarse en 20%% o 62%% un buen rato, es normal."
set "PH_WEIGHT=35"
set "PH_CMD=dism /Online /Cleanup-Image /RestoreHealth"
call :RunPhase

:: ------------------------------------------------------------------------------
:: FASE 2: SFC
:: ------------------------------------------------------------------------------
set "PH_NUM=2"
set "PH_NAME=SFC /scannow"
set "PH_DESC=Comprueba y repara los archivos protegidos del sistema."
set "PH_WEIGHT=25"
set "PH_CMD=sfc /scannow"
call :RunPhase

:: ------------------------------------------------------------------------------
:: FASE 3: Limpieza del almacen de componentes (WinSxS)
:: ------------------------------------------------------------------------------
set "PH_NUM=3"
set "PH_NAME=Limpieza de WinSxS"
set "PH_DESC=Elimina versiones antiguas de componentes de Windows para liberar espacio."
set "PH_WEIGHT=15"
set "PH_CMD=dism /Online /Cleanup-Image /StartComponentCleanup"
call :RunPhase

:: ------------------------------------------------------------------------------
:: FASE 4: Comprobacion del disco
:: ------------------------------------------------------------------------------
set "PH_NUM=4"
set "PH_NAME=CHKDSK C: /scan"
set "PH_DESC=Analiza el disco C: en busca de errores, sin necesidad de reiniciar."
set "PH_WEIGHT=12"
set "PH_CMD=chkdsk C: /scan"
call :RunPhase

:: ------------------------------------------------------------------------------
:: FASE 5: Temporales y cache de Windows Update
:: ------------------------------------------------------------------------------
set "PH_NUM=5"
set "PH_NAME=Temporales y cache de Windows Update"
set "PH_DESC=Detiene servicios de actualizacion, borra su cache y los archivos temporales."
set "PH_WEIGHT=8"
set "PH_CMD=call "%~f0" /fase5"
call :RunPhase

:: ------------------------------------------------------------------------------
:: FASE 6: Red y DNS
:: ------------------------------------------------------------------------------
set "PH_NUM=6"
set "PH_NAME=Red y DNS"
set "PH_DESC=Vacia la cache DNS y restablece Winsock y TCP/IP."
set "PH_WEIGHT=5"
set "PH_CMD=call "%~f0" /fase6"
call :RunPhase

goto :Finish


:: ==============================================================================
:: RunPhase: lanza el comando en segundo plano y informa cada 10 segundos
:: ==============================================================================
:RunPhase
set "OUT=%DETAIL%\fase%PH_NUM%.out"
set "DONE=%DETAIL%\fase%PH_NUM%.done"
set "WRAP=%DETAIL%\fase%PH_NUM%.cmd"
del "%OUT%" "%DONE%" "%WRAP%" >nul 2>&1

echo.
echo ==============================================================================
echo  FASE %PH_NUM%/%PH_TOTAL%: %PH_NAME%
echo  Que hace: %PH_DESC%
echo  Comando : %PH_CMD%
echo ==============================================================================
>> "%LOG%" echo [%DATE% %TIME%] Inicio fase %PH_NUM%/%PH_TOTAL%: %PH_NAME%

:: Script auxiliar que ejecuta el comando y guarda su codigo de salida al terminar
> "%WRAP%" echo @echo off
>> "%WRAP%" echo %PH_CMD%
>> "%WRAP%" echo ^>"%DONE%" echo %%errorlevel%%

call :GetNow
set "PH_START=%NOW%"
start "" /b cmd /c "call "%WRAP%" > "%OUT%" 2>&1 < nul"

set /a TICK=10
:WaitLoop
if exist "%DONE%" goto :PhaseFinished
if %TICK% geq 10 (
    call :ShowProgress
    set /a TICK=1
)
ping -n 2 127.0.0.1 >nul
set /a TICK+=1
goto :WaitLoop

:PhaseFinished
set "EXITCODE=?"
set /p EXITCODE=<"%DONE%"
call :GetNow
set /a EL_PH=NOW-PH_START
if %EL_PH% lss 0 set /a EL_PH+=86400
call :FmtTime %EL_PH%
set "FMT_PH=%FMT%"
set /a BASE+=PH_WEIGHT
set "TOTAL=%BASE%"
call :Bar
title Reparacion de Windows - %TOTAL%%%

echo.
if "%EXITCODE%"=="0" (
    echo  [OK] Fase %PH_NUM%/%PH_TOTAL% completada en %FMT_PH%.
) else (
    echo  [AVISO] Fase %PH_NUM%/%PH_TOTAL% termino con codigo %EXITCODE% - revise el detalle.
)
echo  Resumen de la salida:
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=Get-Content -Raw -LiteralPath '%OUT%' -ErrorAction SilentlyContinue; if($t){ ($t -replace '\x00','') -split '[\r\n]+' | Where-Object { $_.Trim() -ne '' -and $_ -notmatch '\d%%' } | Select-Object -Last 4 | ForEach-Object { '      ' + $_.Trim() } }" 2>nul
echo.
echo  [%TIME:~0,8%] TOTAL [%BAR%] %TOTAL%%%
>> "%LOG%" echo [%DATE% %TIME%] Fin fase %PH_NUM%/%PH_TOTAL%: codigo %EXITCODE% - duracion %FMT_PH%
goto :eof


:: ==============================================================================
:: ShowProgress: muestra el porcentaje total y el de la fase en curso
:: ==============================================================================
:ShowProgress
call :GetNow
set /a EL_PH=NOW-PH_START
if %EL_PH% lss 0 set /a EL_PH+=86400
set /a EL_TOT=NOW-T_START
if %EL_TOT% lss 0 set /a EL_TOT+=86400
call :FmtTime %EL_PH%
set "FMT_PH=%FMT%"
call :FmtTime %EL_TOT%
set "FMT_TOT=%FMT%"

call :ReadPct
set /a TOTAL=BASE+PH_WEIGHT*PH_PCT/100
if %TOTAL% gtr 99 set "TOTAL=99"
call :Bar

if %PH_PCT% gtr 0 (set "PH_TXT=%PH_PCT%%%") else (set "PH_TXT=en curso...")
title Reparacion de Windows - %TOTAL%%%

echo.
echo  [%TIME:~0,8%] TOTAL [%BAR%] %TOTAL%%%
echo             Fase %PH_NUM%/%PH_TOTAL% - %PH_NAME%: %PH_TXT%
echo             Tiempo de la fase: %FMT_PH%   Tiempo total: %FMT_TOT%
goto :eof


:: ReadPct: lee de la salida de la fase el ultimo porcentaje que ha impreso el comando
:ReadPct
set "PH_PCT=0"
for /f "usebackq delims=" %%P in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=Get-Content -Raw -LiteralPath '%OUT%' -ErrorAction SilentlyContinue; if($t){$t=$t -replace '\x00',''; $m=[regex]::Matches($t,'(\d{1,3})(?:[.,]\d+)?%%'); if($m.Count -gt 0){[int]$m[$m.Count-1].Groups[1].Value}else{0}}else{0}" 2^>nul`) do set "PH_PCT=%%P"
if %PH_PCT% gtr 100 set "PH_PCT=100"
goto :eof

:: Bar: construye una barra de 30 caracteres a partir de %TOTAL%
:Bar
set "BAR="
set /a FILLED=TOTAL*30/100
for /l %%i in (1,1,30) do call :BarChar %%i
goto :eof

:BarChar
if %1 leq %FILLED% (set "BAR=%BAR%#") else (set "BAR=%BAR%-")
goto :eof

:: GetNow: segundos transcurridos desde las 00:00 (variable NOW)
:GetNow
for /f "tokens=1-3 delims=:.," %%a in ("%TIME: =0%") do set /a "NOW=(1%%a-100)*3600+(1%%b-100)*60+(1%%c-100)"
goto :eof

:: FmtTime: convierte segundos (%1) a hh:mm:ss en la variable FMT
:FmtTime
set /a "_H=%~1/3600, _M=(%~1%%3600)/60, _S=%~1%%60"
set "_M=0%_M%"
set "_S=0%_S%"
set "FMT=%_H%:%_M:~-2%:%_S:~-2%"
goto :eof


:: ==============================================================================
:: Fases 5 y 6 (se ejecutan en segundo plano; escriben "Progreso interno: NN%")
:: ==============================================================================
:DoPhase5
echo [+] Deteniendo servicios: wuauserv, bits, cryptsvc...
for %%S in (wuauserv bits cryptsvc) do net stop %%S /y
echo Progreso interno: 20%%
echo [+] Eliminando la cache de descargas de Windows Update...
rd /s /q "%SystemRoot%\SoftwareDistribution\Download"
echo Progreso interno: 40%%
echo [+] Reiniciando servicios...
for %%S in (wuauserv bits cryptsvc) do net start %%S
echo Progreso interno: 60%%
echo [+] Eliminando archivos temporales del usuario...
del /f /q /s "%TEMP%\*.*" >nul 2>&1
echo Progreso interno: 80%%
echo [+] Eliminando archivos temporales de Windows...
del /f /q /s "%SystemRoot%\Temp\*.*" >nul 2>&1
echo Progreso interno: 100%%
exit /b 0

:DoPhase6
echo [+] Vaciando la cache DNS: ipconfig /flushdns
ipconfig /flushdns
echo Progreso interno: 33%%
echo [+] Restableciendo Winsock: netsh winsock reset
netsh winsock reset
echo Progreso interno: 66%%
echo [+] Restableciendo TCP/IP: netsh int ip reset
netsh int ip reset
echo Progreso interno: 100%%
exit /b 0


:: ==============================================================================
:: FIN
:: ==============================================================================
:Finish
call :GetNow
set /a EL_TOT=NOW-T_START
if %EL_TOT% lss 0 set /a EL_TOT+=86400
call :FmtTime %EL_TOT%
set "FMT_TOT=%FMT%"
>> "%LOG%" echo ==== PROCESO FINALIZADO (%DATE% %TIME%) - duracion %FMT_TOT% ====
title Reparacion de Windows - COMPLETADO
echo.
echo ==============================================================================
echo                     MANTENIMIENTO COMPLETADO  -  100%%
echo ==============================================================================
echo  Tiempo total: %FMT_TOT%
echo  Se recomienda REINICIAR el equipo para aplicar todos los cambios.
echo.
echo  Registro general : %LOG%
echo  Salida detallada : %DETAIL%
echo.
pause
