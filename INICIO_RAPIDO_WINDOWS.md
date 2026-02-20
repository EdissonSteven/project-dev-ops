# 🪟 GUÍA RÁPIDA PARA WINDOWS

## Laboratorio DevOps Completo - RetailTech

Instrucciones específicas para ejecutar el entorno en **Windows**.

---

## ✅ PRERREQUISITOS

Antes de comenzar, necesitas:

1. **Docker Desktop para Windows**
   - Descargar: https://www.docker.com/products/docker-desktop
   - Versión mínima: 20.10+
   - Asegúrate que esté **corriendo** (icono en system tray)

2. **Git for Windows** (opcional, para clonar repos)
   - Descargar: https://git-scm.com/download/win

3. **Windows 10/11** con WSL 2 habilitado

4. **Al menos 8GB RAM** disponible

---

## 🚀 INICIO RÁPIDO (3 pasos)

### Opción 1: Usando el Menú Interactivo (Recomendado)

```batch
REM 1. Descomprimir
tar -xzf retailtech-devops-complete.tar.gz
cd retailtech-devops-complete

REM 2. Ejecutar menú
menu.bat
```

El menú te mostrará todas las opciones disponibles.

### Opción 2: Comandos Directos

```batch
REM 1. Descomprimir
tar -xzf retailtech-devops-complete.tar.gz
cd retailtech-devops-complete

REM 2. Setup inicial (primera vez)
setup.bat

REM 3. Iniciar servicios
start.bat

REM 4. Ver estado
status.bat

REM 5. Demo
demo.bat
```

---

## 📋 SCRIPTS DISPONIBLES

Todos los scripts tienen extensión `.bat`:

| Script | Descripción |
|--------|-------------|
| `menu.bat` | Menú interactivo (recomendado) |
| `setup.bat` | Configuración inicial |
| `start.bat` | Iniciar todos los servicios |
| `stop.bat` | Detener todos los servicios |
| `status.bat` | Ver estado de servicios |
| `logs.bat` | Ver logs en tiempo real |
| `health-check.bat` | Verificar salud de servicios |
| `test.bat` | Ejecutar tests unitarios |
| `demo.bat` | Demo del flujo CI/CD completo |

---

## 🌐 SERVICIOS DISPONIBLES

Una vez iniciado, accede a:

| Servicio | URL | Usuario | Password |
|----------|-----|---------|----------|
| **Dashboard** | http://localhost | - | - |
| **API** | http://localhost:3000 | - | - |
| **Jenkins** | http://localhost:8080 | admin | admin123 |
| **SonarQube** | http://localhost:9000 | admin | admin |
| **Grafana** | http://localhost:3001 | admin | admin |
| **Prometheus** | http://localhost:9090 | - | - |
| **Gitea** | http://localhost:3030 | - | (crear en primer acceso) |
| **Portainer** | https://localhost:9443 | - | (crear en primer acceso) |

---

## ⏱️ TIEMPOS DE INICIO

- **Primera vez**: 5-10 minutos (descarga imágenes Docker)
- **Siguientes veces**: 2-3 minutos
- **Espera 2-3 minutos** después de ejecutar `start.bat` para que todos los servicios inicien completamente

---

## 🧪 PROBAR LA API

Desde PowerShell o CMD:

```powershell
# Health check
curl http://localhost:3000/health

# Listar productos
curl http://localhost:3000/api/products

# Crear producto
curl -X POST http://localhost:3000/api/products `
  -H "Content-Type: application/json" `
  -d '{\"name\":\"Test Product\",\"price\":99.99,\"category\":\"test\",\"stock\":10}'
```

O abre directamente en el navegador:
- http://localhost:3000/health
- http://localhost:3000/api/products

---

## 🐛 TROUBLESHOOTING WINDOWS

### Error: "Docker daemon no está corriendo"

**Solución**:
1. Abre Docker Desktop
2. Espera a que aparezca "Docker Desktop is running" en el icono
3. Ejecuta `docker info` para verificar

### Error: "Puerto ya en uso"

**Solución**:
```powershell
# Ver qué proceso usa el puerto 8080
netstat -ano | findstr :8080

# Matar proceso (reemplaza PID)
taskkill /PID <numero_pid> /F
```

### Error: "tar no se reconoce como comando"

**Solución**:
- Windows 10/11 ya incluye `tar`
- Si no funciona, usa 7-Zip o WinRAR para descomprimir el `.tar.gz`
- O actualiza Windows

### Los servicios no inician

**Solución**:
```batch
REM Ver logs detallados
logs.bat

REM O directamente
docker-compose logs

REM Reiniciar Docker Desktop y volver a intentar
```

### Error: "curl no se reconoce como comando"

**Solución Windows 10+**:
- `curl` viene incluido desde Windows 10 (2018)
- Si no funciona, usa tu navegador web para abrir las URLs

**Alternativa**:
```powershell
# Usar Invoke-WebRequest en PowerShell
Invoke-WebRequest -Uri http://localhost:3000/health
```

---

## 🎬 EJECUTAR DEMO

```batch
demo.bat
```

Esto mostrará:
- ✅ Verificación de servicios
- ✅ Prueba de API
- ✅ Simulación de pipeline CI/CD
- ✅ Verificación de deployment
- ✅ Smoke tests

Duración: ~2 minutos

---

## 📊 VER LOGS

### Ver todos los logs
```batch
logs.bat
```

### Ver logs de un servicio específico
```batch
docker-compose logs -f jenkins
docker-compose logs -f product-service
docker-compose logs -f prometheus
```

---

## 🔄 COMANDOS DOCKER COMPOSE DIRECTOS

Si prefieres usar Docker Compose directamente:

```batch
REM Iniciar
docker-compose up -d

REM Detener
docker-compose down

REM Ver estado
docker-compose ps

REM Ver logs
docker-compose logs -f

REM Reconstruir
docker-compose build --no-cache

REM Reiniciar un servicio
docker-compose restart product-service

REM Ejecutar comando en contenedor
docker-compose exec product-service npm test
```

---

## 🗑️ LIMPIEZA COMPLETA

⚠️ **CUIDADO**: Esto borra todos los datos

```batch
docker-compose down -v
docker system prune -a --volumes
```

Luego vuelve a ejecutar `setup.bat` y `start.bat`

---

## ✅ CHECKLIST ANTES DE PRESENTAR

- [ ] Docker Desktop está corriendo
- [ ] `start.bat` ejecutado sin errores
- [ ] `status.bat` muestra todos los servicios "Up"
- [ ] `health-check.bat` muestra todos [OK]
- [ ] `test.bat` ejecuta tests exitosamente
- [ ] `demo.bat` completa sin errores
- [ ] Dashboard accesible: http://localhost
- [ ] API responde: http://localhost:3000/health

---

## 🎓 PARA LA ENTREGA

Incluye:
1. ✅ `retailtech-devops-complete.tar.gz` (todo el código)
2. ✅ `Actividad3_Laboratorio_Tecnico.docx` (documentación)
3. ✅ Capturas de pantalla ejecutando `demo.bat`
4. ✅ Screenshot del dashboard en http://localhost

---

## 💡 TIPS PARA WINDOWS

1. **Ejecuta como Administrador** si tienes problemas de permisos
2. **Desactiva antivirus** temporalmente si Docker no inicia
3. **Reinicia Docker Desktop** si algo falla
4. **Usa el menú** (`menu.bat`) para navegación fácil
5. **Abre PowerShell como Admin** para algunos comandos

---

## 🆘 AYUDA RÁPIDA

```batch
REM Ejecutar menú interactivo
menu.bat

REM O ver todos los comandos disponibles
dir *.bat
```

---

## 📞 COMANDOS ÚTILES DE WINDOWS

```batch
REM Ver procesos Docker
docker ps

REM Ver espacio usado
docker system df

REM Limpiar imágenes no usadas
docker image prune -a

REM Reiniciar todo
stop.bat
start.bat

REM Ver configuración de Docker
docker info
```

---

**Versión**: 1.0.0  
**Fecha**: Febrero 2026  
**SO**: Windows 10/11
