@echo off
REM Ejecutar tests de la aplicacion
echo.
echo ========================================
echo   Ejecutando tests unitarios
echo ========================================
echo.

docker-compose exec -T product-service npm test

echo.
pause
