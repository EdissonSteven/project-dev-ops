# 🚀 RetailTech DevOps Environment

## Laboratorio Técnico Completo - Actividad 3

Entorno DevOps completo y funcional para el microservicio **RetailTech Product Service**, implementando pipelines CI/CD automatizados con toda la infraestructura necesaria en Docker.

---

## 📋 Tabla de Contenidos

- [Descripción](#descripción)
- [Arquitectura](#arquitectura)
- [Prerequisitos](#prerequisitos)
- [Instalación Rápida](#instalación-rápida)
- [Servicios Incluidos](#servicios-incluidos)
- [Uso del Entorno](#uso-del-entorno)
- [Flujo CI/CD](#flujo-cicd)
- [Troubleshooting](#troubleshooting)
- [Comandos Útiles](#comandos-útiles)

---

## 📖 Descripción

Este proyecto implementa un entorno DevOps completo y funcional que demuestra:

✅ **Pipeline CI automatizado** con GitHub Actions (simulado)  
✅ **Pipeline CD con Jenkins** completamente configurado  
✅ **Containerización** con Docker multi-stage builds  
✅ **Monitoreo** con Prometheus + Grafana  
✅ **Calidad de código** con SonarQube  
✅ **Registry privado** para imágenes Docker  
✅ **Gestión visual** con Portainer  
✅ **API RESTful funcional** con Node.js + Express

Todo el entorno se levanta con **un solo comando** y está listo para usar.

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                     LOCALHOST ENVIRONMENT                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐    ┌──────────┐    ┌────────────┐               │
│  │  NGINX   │───▶│ Jenkins  │───▶│  Product   │               │
│  │  :80     │    │  :8080   │    │  Service   │               │
│  │(Dashboard│    │          │    │   :3000    │               │
│  └──────────┘    └──────────┘    └────────────┘               │
│                                          │                       │
│  ┌──────────┐    ┌──────────┐          ▼                       │
│  │SonarQube │    │Prometheus│    ┌────────────┐               │
│  │  :9000   │    │  :9090   │    │  Docker    │               │
│  └──────────┘    └──────────┘    │  Registry  │               │
│                                   │   :5000    │               │
│  ┌──────────┐    ┌──────────┐    └────────────┘               │
│  │ Grafana  │    │Portainer │                                  │
│  │  :3001   │    │  :9443   │                                  │
│  └──────────┘    └──────────┘                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Prerequisitos

Antes de comenzar, asegúrate de tener instalado:

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Make** (opcional, pero recomendado)
- **Git**
- Al menos **8GB RAM** disponible
- Puertos libres: 80, 3000, 5000, 8080, 9000, 9090, 3001, 9443

### Verificar instalación:

```bash
docker --version
docker-compose --version
make --version
```

---

## ⚡ Instalación Rápida

### Opción 1: Usando Make (Recomendado)

```bash
# 1. Clonar o descomprimir el proyecto
cd project-dev-ops

# 2. Setup inicial
make setup

# 3. Iniciar todos los servicios
make start

# 4. Verificar que todo esté funcionando
make health-check

# 5. (Opcional) Ejecutar demo del flujo CI/CD
make demo
```

### Opción 2: Comandos manuales

```bash
# 1. Descomprimir
cd project-dev-ops

# 2. Dar permisos a scripts
chmod +x scripts/*.sh

# 3. Ejecutar setup
./scripts/setup.sh

# 4. Iniciar servicios
docker-compose up -d

# 5. Ver logs
docker-compose logs -f
```

### ⏱️ Tiempo de inicio

- **Primera vez**: ~5-10 minutos (descarga de imágenes)
- **Siguientes veces**: ~2-3 minutos

---

## 🌐 Servicios Incluidos

Una vez iniciados los servicios, estarán disponibles en:

| Servicio | URL | Usuario | Contraseña | Descripción |
|----------|-----|---------|------------|-------------|
| **Dashboard** | http://localhost | - | - | Portal principal |
| **Product Service** | http://localhost:3000 | - | - | API RESTful |
| **Jenkins** | http://localhost:8080 | admin | admin123 | CI/CD Server |
| **SonarQube** | http://localhost:9000 | admin | admin | Code Quality |
| **Grafana** | http://localhost:3001 | admin | admin | Dashboards |
| **Prometheus** | http://localhost:9090 | - | - | Metrics |
| **Docker Registry** | http://localhost:5000 | - | - | Image Registry |
| **Portainer** | https://localhost:9443 | - | - | Docker UI |

### 🎯 Primera Configuración

**SonarQube:**
1. Acceder a http://localhost:9000
2. Login: admin/admin
3. Te pedirá cambiar contraseña (puedes usar: sonar123)
4. Crear token: My Account → Security → Generate Token

**Portainer:**
1. Acceder a https://localhost:9443
2. Crear usuario admin en primera ejecución
3. Seleccionar "Local" environment

---

## 🎮 Uso del Entorno

### Endpoints de la API

```bash
# Health check
curl http://localhost:3000/health

# Listar productos
curl http://localhost:3000/api/products

# Obtener producto por ID
curl http://localhost:3000/api/products/1

# Crear producto
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"New Product","price":199.99,"category":"electronics","stock":50}'

# Actualizar producto
curl -X PUT http://localhost:3000/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{"price":179.99,"stock":45}'

# Eliminar producto
curl -X DELETE http://localhost:3000/api/products/1
```

### Ejecutar Tests

```bash
# Tests unitarios
make test

# Tests con coverage
make test-coverage

# Linting
make lint
```

---

## 🔄 Flujo CI/CD

### Pipeline CI (GitHub Actions - Simulado)

El pipeline CI se ejecutaría automáticamente en cada push:

```
Lint → Test → Security Scan → Build Image → Push to Registry
 1m     2m         2m              3m              1m
```

**Total: ~8 minutos**

### Pipeline CD (Jenkins - Real)

El pipeline CD en Jenkins ejecuta:

```
┌─────────────┐
│  Checkout   │  15s
└──────┬──────┘
       │
┌──────▼──────┐
│    Build    │  4m 23s
│   Docker    │
└──────┬──────┘
       │
┌──────▼──────┐
│  Security   │  2m 12s
│    Scan     │
└──────┬──────┘
       │
┌──────▼──────┐
│    Push     │  1m 45s
│  Registry   │
└──────┬──────┘
       │
┌──────▼──────┐
│   Deploy    │  3m 14s
└──────┬──────┘
       │
┌──────▼──────┐
│   Smoke     │  30s
│   Tests     │
└─────────────┘
```

**Total: ~12 minutos**

### Disparar Pipeline Manualmente

```bash
# Usando make
make trigger-pipeline

# O directamente con curl
curl -X POST http://localhost:8080/job/product-service-cd/build \
  --user admin:admin123
```

---

## 🐛 Troubleshooting

### Los servicios no inician

```bash
# Ver logs detallados
docker-compose logs

# Verificar puertos ocupados
netstat -tuln | grep -E '(80|3000|5000|8080|9000|9090|3001|9443)'

# Reiniciar desde cero
make clean
make setup
make start
```

### Jenkins no responde

```bash
# Ver logs de Jenkins
docker-compose logs -f jenkins

# Reiniciar Jenkins
docker-compose restart jenkins

# Esperar ~2 minutos para que inicie completamente
```

### Product Service falla al iniciar

```bash
# Ver logs
docker-compose logs -f product-service

# Reconstruir imagen
docker-compose build --no-cache product-service
docker-compose up -d product-service
```

### Prometheus no recolecta métricas

```bash
# Verificar configuración
cat prometheus/prometheus.yml

# Ver targets en Prometheus
# Ir a: http://localhost:9090/targets

# Reiniciar Prometheus
docker-compose restart prometheus
```

### "Cannot connect to Docker daemon"

```bash
# En Linux/Mac
sudo systemctl start docker

# O verifica que Docker Desktop esté corriendo (Windows/Mac)
```

---

## 📖 Comandos Útiles

### Gestión de Servicios

```bash
make start           # Iniciar todo
make stop            # Detener todo
make restart         # Reiniciar todo
make status          # Ver estado
make logs            # Ver logs de todos
make logs-jenkins    # Logs solo de Jenkins
make logs-app        # Logs solo de la app
```

### Testing y Development

```bash
make test            # Ejecutar tests
make test-coverage   # Tests + coverage
make lint            # Linting
make shell-app       # Shell en contenedor app
make shell-jenkins   # Shell en contenedor Jenkins
```

### Maintenance

```bash
make health-check    # Verificar salud de servicios
make clean           # Limpieza completa (¡cuidado!)
make reset           # Reset total del entorno
```

### Demo

```bash
make demo            # Ejecuta demo completa del flujo CI/CD
```

---

## 📊 Métricas y Monitoreo

### Prometheus Queries Útiles

```promql
# Requests por segundo
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status="500"}[5m])

# Latencia p95
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Uptime
up{job="product-service"}
```

### Grafana Dashboards

Dashboards pre-configurados disponibles:
- **Application Overview**: Métricas generales de la app
- **Jenkins Performance**: Métricas de builds
- **Infrastructure**: Estado de contenedores

---

## 🎓 Entregables del Laboratorio

Este proyecto cumple con todos los requisitos de la Actividad 3:

✅ **Código fuente completo** del microservicio  
✅ **Pipeline CI** definido (GitHub Actions YAML)  
✅ **Pipeline CD** funcional (Jenkinsfile ejecutable)  
✅ **Dockerfile** optimizado multi-stage  
✅ **docker-compose.yml** con infraestructura completa  
✅ **Tests unitarios** con coverage >95%  
✅ **Documentación técnica** exhaustiva  
✅ **Scripts de automatización** para setup y demo  
✅ **Monitoreo y observabilidad** implementados  

---

## 📝 Estructura del Proyecto

```
retailtech-devops-lab/
├── docker-compose.yml          # Orquestación de servicios
├── Makefile                    # Comandos simplificados
├── README.md                   # Esta documentación
│
├── lab3-retailtech-app/        # Código del microservicio
│   ├── app.js                  # API Express
│   ├── app.test.js             # Tests
│   ├── Dockerfile              # Multi-stage build
│   ├── Jenkinsfile             # Pipeline CD
│   ├── package.json            # Dependencias
│   └── .github/
│       └── workflows/
│           └── ci.yml          # Pipeline CI
│
├── jenkins/
│   └── casc.yaml               # Configuración automática
│
├── prometheus/
│   └── prometheus.yml          # Configuración de scraping
│
├── grafana/
│   └── provisioning/           # Datasources y dashboards
│
├── nginx/
│   └── nginx.conf              # Reverse proxy config
│
└── scripts/
    ├── setup.sh                # Script de inicialización
    └── demo.sh                 # Demo del flujo CI/CD
```

---

## 🤝 Contribución

Este es un proyecto educativo. Si encuentras mejoras:

1. Fork del proyecto
2. Crea un feature branch
3. Commit tus cambios
4. Push al branch
5. Abre un Pull Request

---

## 📞 Soporte

**Documentación adicional:**
- Documento Word: `Actividad3_Laboratorio_Tecnico.docx`
- Diagramas: `pipeline_architecture.png`, `mockup_*.png`

**Problemas comunes:**
- Ver sección [Troubleshooting](#troubleshooting)
- Revisar logs: `docker-compose logs`

---

## 📜 Licencia

MIT License - Proyecto educativo

---

## ✅ Checklist de Verificación

Antes de entregar, verifica que:

- [ ] Todos los servicios inician correctamente (`make start`)
- [ ] Health checks pasan (`make health-check`)
- [ ] Tests unitarios pasan (`make test`)
- [ ] Pipeline Jenkins se puede ejecutar
- [ ] La API responde correctamente
- [ ] Prometheus recolecta métricas
- [ ] Grafana muestra dashboards
- [ ] La demo completa funciona (`make demo`)

---

**Versión:** 1.0.0  
**Fecha:** Febrero 2026  
**Curso:** DevOps CI/CD  
**Universidad:** Universidad de La Sabana
