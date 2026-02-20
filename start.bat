@echo off
REM Iniciar todos los servicios
echo.
echo ========================================
echo   Iniciando servicios DevOps...
echo ========================================
echo.

docker-compose up -d

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] Servicios iniciados exitosamente
    echo.
    echo Dashboard disponible en:     http://localhost
    echo Jenkins:                     http://localhost:8080 (admin/admin123)
    echo SonarQube:                   http://localhost:9000 (admin/admin)
    echo Grafana:                     http://localhost:3001 (admin/admin)
    echo Gitea (Git Server):          http://localhost:3030
    echo Product Service API:         http://localhost:3000
    echo.
    echo Espera 2-3 minutos para que todos los servicios inicien completamente
    echo.
    echo Para ver logs en tiempo real, ejecuta: logs.bat
    echo Para ver el estado, ejecuta: status.bat
    echo.
) else (
    echo.
    echo [ERROR] Fallo al iniciar servicios
    echo Revisa los logs con: docker-compose logs
    echo.
)

pause
