@echo off
REM Health check de servicios
echo.
echo ========================================
echo   Verificando salud de servicios
echo ========================================
echo.

echo Verificando Product Service...
curl -s http://localhost:3000/health >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Product Service
) else (
    echo [X] Product Service
)

echo Verificando Jenkins...
curl -s http://localhost:8080/login >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Jenkins
) else (
    echo [X] Jenkins
)

echo Verificando SonarQube...
curl -s http://localhost:9000 >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] SonarQube
) else (
    echo [X] SonarQube
)

echo Verificando Grafana...
curl -s http://localhost:3001 >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Grafana
) else (
    echo [X] Grafana
)

echo Verificando Prometheus...
curl -s http://localhost:9090 >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Prometheus
) else (
    echo [X] Prometheus
)

echo Verificando Gitea...
curl -s http://localhost:3030 >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Gitea
) else (
    echo [X] Gitea
)

echo.
pause
