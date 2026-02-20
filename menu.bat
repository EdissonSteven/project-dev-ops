@echo off
REM Menu principal para Windows
title RetailTech DevOps Environment

:menu
cls
echo.
echo ========================================
echo   RetailTech DevOps Environment
echo   Laboratorio Tecnico - Actividad 3
echo ========================================
echo.
echo   1. Setup inicial (primera vez)
echo   2. Iniciar todos los servicios
echo   3. Detener todos los servicios
echo   4. Ver estado de servicios
echo   5. Ver logs en tiempo real
echo   6. Health check
echo   7. Ejecutar tests
echo   8. Demo del flujo CI/CD
echo   9. Abrir dashboard en navegador
echo   0. Salir
echo.
echo ========================================
echo.

set /p option="Selecciona una opcion (0-9): "

if "%option%"=="1" goto setup
if "%option%"=="2" goto start
if "%option%"=="3" goto stop
if "%option%"=="4" goto status
if "%option%"=="5" goto logs
if "%option%"=="6" goto health
if "%option%"=="7" goto test
if "%option%"=="8" goto demo
if "%option%"=="9" goto dashboard
if "%option%"=="0" goto exit

echo Opcion invalida
timeout /t 2 /nobreak >nul
goto menu

:setup
call setup.bat
goto menu

:start
call start.bat
goto menu

:stop
call stop.bat
goto menu

:status
call status.bat
goto menu

:logs
call logs.bat
goto menu

:health
call health-check.bat
goto menu

:test
call test.bat
goto menu

:demo
call demo.bat
goto menu

:dashboard
echo.
echo Abriendo dashboard en navegador...
start http://localhost
timeout /t 2 /nobreak >nul
goto menu

:exit
echo.
echo Saliendo...
exit /b 0
