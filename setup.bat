@echo off
REM Script de setup para Windows
REM RetailTech DevOps Environment

echo.
echo ========================================
echo   RetailTech DevOps Environment Setup
echo   Laboratorio Tecnico - Actividad 3
echo ========================================
echo.

REM Verificar Docker
where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker no esta instalado
    echo Por favor instala Docker Desktop desde: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Verificar Docker Compose
where docker-compose >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker Compose no esta instalado
    pause
    exit /b 1
)

echo [OK] Docker instalado: 
docker --version

echo [OK] Docker Compose instalado:
docker-compose --version

echo.
echo Verificando que Docker este corriendo...
docker info >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker daemon no esta corriendo
    echo Por favor inicia Docker Desktop
    pause
    exit /b 1
)

echo [OK] Docker daemon corriendo
echo.

REM Descomprimir si existe tar.gz
if exist lab3-retailtech-app.tar.gz (
    echo Descomprimiendo repositorio...
    tar -xzf lab3-retailtech-app.tar.gz
    echo [OK] Repositorio descomprimido
)

REM Crear directorios
echo Creando directorios necesarios...
if not exist jenkins\jobs mkdir jenkins\jobs
if not exist grafana\provisioning\datasources mkdir grafana\provisioning\datasources
if not exist grafana\provisioning\dashboards mkdir grafana\provisioning\dashboards

REM Configurar Grafana datasource
echo Configurando Grafana...
(
echo apiVersion: 1
echo.
echo datasources:
echo   - name: Prometheus
echo     type: prometheus
echo     access: proxy
echo     url: http://prometheus:9090
echo     isDefault: true
echo     editable: true
) > grafana\provisioning\datasources\prometheus.yml

echo [OK] Grafana configurado
echo.

echo ========================================
echo          CONFIGURACION COMPLETA
echo ========================================
echo.
echo Puertos configurados:
echo   - Dashboard:        http://localhost:80
echo   - Product Service:  http://localhost:3000
echo   - Jenkins:          http://localhost:8080
echo   - SonarQube:        http://localhost:9000
echo   - Grafana:          http://localhost:3001
echo   - Prometheus:       http://localhost:9090
echo   - Gitea:            http://localhost:3030
echo   - Docker Registry:  http://localhost:5000
echo   - Portainer:        https://localhost:9443
echo.
echo Credenciales por defecto:
echo   - Jenkins:    admin / admin123
echo   - SonarQube:  admin / admin
echo   - Grafana:    admin / admin
echo   - Gitea:      (crear en primer acceso)
echo.
echo Siguiente paso:
echo   Ejecuta: start.bat
echo.
echo [OK] Setup completado exitosamente
pause
