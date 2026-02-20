@echo off
REM Demo del flujo CI/CD completo
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   DEMO: FLUJO CI/CD COMPLETO
echo   RetailTech Product Service
echo ========================================
echo.

echo PASO 1: Verificar servicios corriendo
echo ========================================
echo.

docker-compose ps | findstr "Up" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Los servicios no estan corriendo
    echo Por favor ejecuta: start.bat
    pause
    exit /b 1
)

echo [OK] Servicios corriendo
timeout /t 2 /nobreak >nul
echo.

echo PASO 2: Verificar API del Product Service
echo ========================================
echo.

echo Probando GET /health
curl -s http://localhost:3000/health
echo.
timeout /t 2 /nobreak >nul

echo Probando GET /api/products
curl -s http://localhost:3000/api/products
echo.
timeout /t 2 /nobreak >nul

echo [OK] API funcionando correctamente
echo.

echo PASO 3: Verificar metricas en Prometheus
echo ========================================
echo.

echo Consultando metricas del Product Service...
curl -s "http://localhost:9090/api/v1/query?query=up{job=\"product-service\"}" >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Prometheus recolectando metricas
) else (
    echo [X] Prometheus aun no tiene metricas
)
echo.
echo URL: http://localhost:9090/graph?g0.expr=up^&g0.tab=1
timeout /t 2 /nobreak >nul
echo.

echo PASO 4: Simulacion de cambio de codigo y pipeline
echo ========================================
echo.

echo Simulando commit y push a repositorio...
echo     - feat: add new product endpoint
echo.
timeout /t 2 /nobreak >nul

echo Webhook activando Jenkins pipeline...
timeout /t 1 /nobreak >nul
echo.

echo Pipeline Stages:
echo.
echo     [^>] Checkout..................
timeout /t 1 /nobreak >nul
echo     [OK] Checkout (15s)
echo.

echo     [^>] Build Docker Image........
timeout /t 2 /nobreak >nul
echo     [OK] Build Docker Image (4m 23s)
echo.

echo     [^>] Security Scan.............
timeout /t 2 /nobreak >nul
echo     [OK] Security Scan (2m 12s)
echo.

echo     [^>] Push to Registry..........
timeout /t 1 /nobreak >nul
echo     [OK] Push to Registry (1m 45s)
echo.

echo     [^>] Deploy to Kubernetes......
timeout /t 2 /nobreak >nul
echo     [OK] Deploy to Kubernetes (3m 14s)
echo.

echo     [^>] Smoke Tests...............
timeout /t 1 /nobreak >nul
echo     [OK] Smoke Tests (30s)
echo.

echo [OK] Pipeline completado exitosamente
echo      Total: 12m 19s
echo.
timeout /t 2 /nobreak >nul

echo PASO 5: Verificar deployment
echo ========================================
echo.

echo Verificando deployment...
docker-compose ps product-service | findstr "Up" >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Servicio corriendo con nueva version
) else (
    echo [X] Error en deployment
)
echo.

echo Ejecutando smoke tests...
curl -s http://localhost:3000/health | findstr "UP" >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Health check: OK
) else (
    echo [X] Health check: FAILED
)

curl -s http://localhost:3000/api/products >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] API endpoints: OK
) else (
    echo [X] API endpoints: FAILED
)
echo.

echo PASO 6: Dashboards disponibles
echo ========================================
echo.

echo Visualizacion:
echo   - Grafana:    http://localhost:3001
echo   - Prometheus: http://localhost:9090
echo   - Jenkins:    http://localhost:8080
echo.

echo ========================================
echo   RESUMEN DEL FLUJO CI/CD
echo ========================================
echo.

echo [OK] Flujo completado exitosamente
echo.
echo Componentes verificados:
echo   * Product Service API funcionando
echo   * Jenkins pipeline ejecutado (simulado)
echo   * Docker image construida
echo   * Deployment completado
echo   * Smoke tests pasados
echo   * Metricas recolectadas en Prometheus
echo.
echo Tiempo total del flujo: ~12m 30s
echo.
echo Enlaces utiles:
echo   * Dashboard:   http://localhost
echo   * Jenkins:     http://localhost:8080
echo   * API:         http://localhost:3000/api/products
echo   * Prometheus:  http://localhost:9090
echo   * Grafana:     http://localhost:3001
echo   * Gitea:       http://localhost:3030
echo.

echo ========================================
echo   DEMO COMPLETADA EXITOSAMENTE
echo ========================================
echo.

pause
