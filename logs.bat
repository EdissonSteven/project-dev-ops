@echo off
REM Ver logs de todos los servicios
echo.
echo Mostrando logs de todos los servicios...
echo Presiona Ctrl+C para salir
echo.

docker-compose logs -f
