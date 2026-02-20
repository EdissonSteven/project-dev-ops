@echo off
REM Detener todos los servicios
echo.
echo Deteniendo servicios DevOps...
echo.

docker-compose down

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] Servicios detenidos exitosamente
    echo.
) else (
    echo.
    echo [ERROR] Fallo al detener servicios
    echo.
)

pause
