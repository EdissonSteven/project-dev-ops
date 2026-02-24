# Documentación Técnica — RetailTech Product Service
## Pipeline CI/CD con GitHub Actions + Jenkins

**Proyecto:** lab3-retailtech-app
**Repositorio:** https://github.com/EdissonSteven/project-dev-ops
**Fecha:** Febrero 2026
**Materia:** Fundamentos DevOps — Maestría en Arquitectura de Software

---

## Tabla de Contenidos

1. [Descripción General](#1-descripción-general)
2. [Arquitectura del Sistema](#2-arquitectura-del-sistema)
3. [Microservicio: Product Service](#3-microservicio-product-service)
4. [Pipeline CI — GitHub Actions](#4-pipeline-ci--github-actions)
5. [Pipeline CD — Jenkins](#5-pipeline-cd--jenkins)
6. [Infraestructura con Docker Compose](#6-infraestructura-con-docker-compose)
7. [Calidad de Código — SonarQube](#7-calidad-de-código--sonarqube)
8. [Monitoreo — Prometheus y Grafana](#8-monitoreo--prometheus-y-grafana)
9. [Archivos de Configuración](#9-archivos-de-configuración)
10. [Flujo Completo CI/CD](#10-flujo-completo-cicd)
11. [Acceso a los Servicios](#11-acceso-a-los-servicios)

---

## 1. Descripción General

Este proyecto implementa un entorno completo de **CI/CD (Integración y Entrega Continua)** para el microservicio `product-service` de la plataforma ficticia RetailTech E-Commerce.

### Objetivo
Demostrar la automatización del ciclo de vida de software desde el commit hasta el despliegue, aplicando prácticas modernas de DevOps:

- **Integración Continua (CI):** automatización de lint, pruebas y build de imagen Docker mediante **GitHub Actions**.
- **Entrega Continua (CD):** despliegue automático con análisis de calidad y smoke tests mediante **Jenkins**.
- **Observabilidad:** métricas de la aplicación con **Prometheus** y visualización en **Grafana**.
- **Calidad de Código:** análisis estático con **SonarQube**.

### Tecnologías utilizadas

| Componente        | Tecnología              | Versión    |
|-------------------|-------------------------|------------|
| Aplicación        | Node.js + Express       | 18.x / 4.x |
| Containerización  | Docker + Docker Compose | 24+        |
| CI Pipeline       | GitHub Actions          | —          |
| CD Pipeline       | Jenkins (LTS)           | 2.x LTS    |
| Registry local    | Docker Registry         | 2          |
| Calidad de código | SonarQube Community     | Latest     |
| Métricas          | Prometheus              | Latest     |
| Visualización     | Grafana                 | Latest     |
| Proxy reverso     | Nginx                   | Alpine     |
| Gestión Docker    | Portainer CE            | Latest     |

---

## 2. Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                      DESARROLLADOR                              │
│                    git push → GitHub                            │
└────────────────────────┬────────────────────────────────────────┘
                         │
          ┌──────────────▼──────────────┐
          │      GITHUB ACTIONS (CI)    │
          │  1. Lint (ESLint)           │
          │  2. Tests + Coverage        │
          │  3. Build & Push GHCR       │
          └──────────────┬──────────────┘
                         │ Commit en main/develop
          ┌──────────────▼──────────────┐
          │     JENKINS (CD) — polling  │
          │  1. Checkout                │
          │  2. Install & Test          │
          │  3. SonarQube Analysis      │
          │  4. Build Docker Image      │
          │  5. Push → Registry Local   │
          │  6. Deploy container        │
          │  7. Smoke Tests             │
          └──────────────┬──────────────┘
                         │
     ┌───────────────────▼─────────────────────┐
     │         STACK LOCAL (Docker Compose)     │
     │  ┌─────────────┐  ┌──────────────────┐  │
     │  │product-svc  │  │    SonarQube     │  │
     │  │  :3000      │  │     :9000        │  │
     │  └──────┬──────┘  └──────────────────┘  │
     │         │metrics                         │
     │  ┌──────▼──────┐  ┌──────────────────┐  │
     │  │  Prometheus │  │     Grafana      │  │
     │  │    :9090    │  │     :3001        │  │
     │  └─────────────┘  └──────────────────┘  │
     │  ┌─────────────┐  ┌──────────────────┐  │
     │  │   Jenkins   │  │     Nginx        │  │
     │  │    :8080    │  │      :80         │  │
     │  └─────────────┘  └──────────────────┘  │
     └─────────────────────────────────────────┘
```

---

## 3. Microservicio: Product Service

### Descripción
API REST para la gestión del catálogo de productos de RetailTech. Expone operaciones CRUD sobre productos de tecnología.

### Endpoints

| Método | Ruta                   | Descripción                        |
|--------|------------------------|------------------------------------|
| GET    | `/health`              | Health check del servicio          |
| GET    | `/metrics`             | Métricas Prometheus                |
| GET    | `/docs`                | Documentación Swagger UI           |
| GET    | `/api/products`        | Listar todos los productos         |
| GET    | `/api/products?category=` | Filtrar por categoría           |
| GET    | `/api/products/:id`    | Obtener producto por ID            |
| POST   | `/api/products`        | Crear nuevo producto               |
| PUT    | `/api/products/:id`    | Actualizar producto existente      |
| DELETE | `/api/products/:id`    | Eliminar producto                  |

### Estructura del proyecto

```
lab3-reatiltech-app/
├── app.js                    # Servidor Express + rutas + métricas Prometheus
├── swagger.js                # Configuración OpenAPI/Swagger
├── app.test.js               # Tests unitarios con Jest + Supertest
├── package.json              # Dependencias y scripts npm
├── sonar-project.properties  # Configuración SonarQube
└── Dockerfile                # Multi-stage build (builder + runtime)
```

### Dockerfile (Multi-stage)

El Dockerfile implementa un patrón **multi-stage build** para minimizar el tamaño de la imagen final:

```
Etapa 1 (builder):  node:18-alpine → instala dependencias de producción
Etapa 2 (runtime):  node:18-alpine → copia solo lo necesario, usuario no-root
```

**Medidas de seguridad aplicadas:**
- Usuario no-root (`nodejs:1001`) para ejecutar la aplicación
- `dumb-init` para manejo correcto de señales del SO
- Solo dependencias de producción en imagen final
- Health check integrado en la imagen

---

## 4. Pipeline CI — GitHub Actions

**Archivo:** `.github/workflows/ci.yml`

### Disparadores

El pipeline se activa automáticamente cuando:
- Se hace `push` a las ramas `main` o `develop`
- Se abre un `pull_request` hacia `main` o `develop`
- Solo si hay cambios en `lab3-reatiltech-app/` o en el propio `ci.yml`

### Etapas del pipeline

```
push → [lint] → [test] → [build & push Docker] → [summary]
                    ↑
              (necesita lint)
```

#### Job 1: Lint
- Configura Node.js 18
- Instala dependencias (`npm install`)
- Ejecuta ESLint (`npm run lint`)

#### Job 2: Tests & Coverage
- Depende de: `lint`
- Ejecuta Jest con cobertura (`npm test`)
- Sube el reporte de cobertura como **artifact** (retenido 7 días)

#### Job 3: Build & Push Docker Image
- Depende de: `lint` + `test`
- Solo ejecuta en eventos `push` (no en pull requests)
- Autentica con **GitHub Container Registry (GHCR)**
- Genera tags automáticos:
  - `latest` (solo desde `main`)
  - `<branch>` (nombre de la rama)
  - `<branch>-<sha_corto>` (commit específico)
- Usa **caché de GitHub Actions** para acelerar builds

#### Job 4: Pipeline Summary
- Siempre se ejecuta (`if: always()`)
- Genera un resumen visual en la UI de GitHub Actions

### Variables de entorno

| Variable     | Valor                                      |
|--------------|--------------------------------------------|
| NODE_VERSION | `18.x`                                     |
| REGISTRY     | `ghcr.io`                                  |
| IMAGE_NAME   | `<repo>/product-service`                   |
| APP_DIR      | `lab3-reatiltech-app`                      |

---

## 5. Pipeline CD — Jenkins

**Archivo:** `lab3-reatiltech-app/Jenkinsfile`

### Configuración

Jenkins está configurado mediante **Configuration as Code (CasC)** — archivo `jenkins/casc.yaml`. El job `product-service-cd` se crea automáticamente al iniciar Jenkins, sin intervención manual.

**Polling:** Jenkins revisa el repositorio cada 2 minutos (`H/2 * * * *`).

### Etapas del pipeline

```
Checkout → Install & Test → SonarQube Analysis → Build Docker Image
    → Push to Local Registry → Deploy → Smoke Tests
```

#### Stage 1: Checkout
- Clona el repositorio
- Extrae el mensaje del último commit
- Genera el tag de imagen: `<build_number>-<git_sha7>`

#### Stage 2: Install & Test
- Ejecuta `npm install` y `npm test` dentro del directorio de la app
- Continúa aunque los tests fallen (`|| true`) para no bloquear el análisis

#### Stage 3: SonarQube Analysis
- Corre el escáner de SonarQube via contenedor Docker
- Conecta al servidor SonarQube en la red interna `devops-network`
- Si falla (token no configurado), muestra advertencia pero no rompe el pipeline

#### Stage 4: Build Docker Image
- Construye la imagen con dos tags: `<build>-<sha>` y `latest`
- Agrega labels de trazabilidad (`build.number`, `git.commit`)

#### Stage 5: Push to Local Registry
- Publica la imagen al registry local en `localhost:5000`
- Disponible para otros servicios en la red Docker

#### Stage 6: Deploy
- Detiene y elimina el contenedor anterior (si existe)
- Lanza el nuevo contenedor en la red `devops-network`
- Expone el puerto 3000

#### Stage 7: Smoke Tests
- Espera hasta 30 segundos (10 reintentos × 3s) a que el servicio arranque
- Verifica `/health` → respuesta con `"UP"`
- Verifica `/api/products` → respuesta con `"id"`

### Post-ejecución

| Resultado | Acción                                    |
|-----------|-------------------------------------------|
| Success   | Imprime URLs de todos los servicios       |
| Failure   | Indica que revise los logs                |
| Always    | Limpia workspace y elimina imágenes huérfanas |

---

## 6. Infraestructura con Docker Compose

**Archivo:** `docker-compose.yml`

Todos los servicios comparten la red interna `devops-network` (bridge).

### Servicios

| Servicio          | Imagen/Build              | Puerto Host | Descripción                        |
|-------------------|---------------------------|-------------|------------------------------------|
| `jenkins`         | `./jenkins/Dockerfile`    | 8080, 50000 | Servidor CI/CD con CasC            |
| `registry`        | `registry:2`              | 5000        | Docker Registry local              |
| `sonarqube`       | `sonarqube:community`     | 9000        | Análisis de calidad de código      |
| `sonarqube_db`    | `postgres:14-alpine`      | —           | Base de datos de SonarQube         |
| `prometheus`      | `prom/prometheus:latest`  | 9090        | Recolector de métricas             |
| `grafana`         | `grafana/grafana:latest`  | 3001        | Visualización de métricas          |
| `product-service` | `./lab3-reatiltech-app`   | 3000        | Microservicio principal            |
| `nginx`           | `nginx:alpine`            | 80           | Proxy reverso + dashboard          |
| `portainer`       | `portainer/portainer-ce`  | 9443        | Gestión visual de contenedores     |

### Volúmenes persistentes

- `jenkins_home` — configuración y builds de Jenkins
- `registry_data` — imágenes del registry local
- `sonarqube_data/logs/extensions` — datos de SonarQube
- `sonarqube_db` — base de datos PostgreSQL
- `prometheus_data` — series de tiempo de métricas
- `grafana_data` — dashboards y configuración de Grafana
- `portainer_data` — estado de Portainer

---

## 7. Calidad de Código — SonarQube

**Archivo:** `lab3-reatiltech-app/sonar-project.properties`

### Configuración del análisis

| Parámetro                        | Valor                              |
|----------------------------------|------------------------------------|
| `sonar.projectKey`               | `retailtech-product-service`       |
| `sonar.sources`                  | `.` (directorio raíz de la app)    |
| `sonar.exclusions`               | `node_modules/**`, `coverage/**`, `**/*.test.js` |
| `sonar.javascript.lcov.reportPaths` | `coverage/lcov.info`            |
| `sonar.host.url`                 | `http://sonarqube:9000`            |

El escáner se ejecuta desde Jenkins via contenedor Docker (`sonarsource/sonar-scanner-cli`), conectado a la red `devops-network` para acceder al servidor SonarQube interno.

---

## 8. Monitoreo — Prometheus y Grafana

**Archivo:** `prometheus/prometheus.yml`

### Métricas expuestas por la aplicación

La aplicación expone métricas nativas de Prometheus en `/metrics`:

| Métrica                          | Tipo      | Descripción                               |
|----------------------------------|-----------|-------------------------------------------|
| `retailtech_*`                   | Default   | Métricas estándar de Node.js              |
| `http_requests_total`            | Counter   | Total de peticiones HTTP por método/ruta/código |
| `http_request_duration_seconds`  | Histogram | Duración de peticiones (buckets: 5ms–2.5s) |

### Jobs de scraping configurados

| Job             | Target                         | Intervalo |
|-----------------|--------------------------------|-----------|
| `prometheus`    | `localhost:9090`               | 15s       |
| `product-service` | `product-service:3000`       | 15s       |
| `jenkins`       | `jenkins:8080/prometheus`      | 15s       |
| `docker`        | `host.docker.internal:9323`    | 15s       |

**Grafana** se conecta a Prometheus como datasource y permite crear dashboards personalizados de:
- Tasa de peticiones HTTP por endpoint
- Latencia P50/P95/P99
- Métricas del proceso Node.js (CPU, memoria, event loop)

---

## 9. Archivos de Configuración

Todos los archivos de configuración están incluidos en el repositorio:

```
project-dev-ops/
│
├── .github/
│   └── workflows/
│       └── ci.yml                     # Pipeline CI (GitHub Actions)
│
├── lab3-reatiltech-app/
│   ├── Dockerfile                     # Multi-stage build de la aplicación
│   ├── Jenkinsfile                    # Pipeline CD (Jenkins)
│   ├── sonar-project.properties       # Configuración SonarQube
│   ├── app.js                         # Código fuente principal
│   ├── app.test.js                    # Tests unitarios
│   ├── swagger.js                     # Definición OpenAPI
│   └── package.json                   # Dependencias y scripts
│
├── jenkins/
│   ├── Dockerfile                     # Jenkins personalizado con plugins
│   ├── casc.yaml                      # Jenkins Configuration as Code
│   └── jobs/
│       └── product-service-cd/        # Definición del job (generado por CasC)
│
├── prometheus/
│   └── prometheus.yml                 # Configuración de scraping
│
├── grafana/
│   └── provisioning/                  # Dashboards y datasources automáticos
│
├── nginx/
│   ├── nginx.conf                     # Configuración del proxy reverso
│   └── html/                          # Dashboard web estático
│
├── docker-compose.yml                 # Stack completo de infraestructura
├── .gitignore                         # Exclusiones de Git
└── DOCUMENTACION_TECNICA.md           # Este documento
```

---

## 10. Flujo Completo CI/CD

El siguiente diagrama muestra el flujo de extremo a extremo:

```
┌─────────────────────────────────────────────────────────────────────┐
│  1. DESARROLLADOR hace git push a main/develop                      │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │ GitHub Actions  │  Trigger: push/PR
                    │                 │
                    │  ① Lint         │  ~1 min
                    │  ② Tests        │  ~2 min  → artifact: coverage/
                    │  ③ Docker Build │  ~3 min  → GHCR image
                    │  ④ Summary      │  siempre
                    └────────┬────────┘
                             │  CI exitoso ✅
                    ┌────────▼────────┐
                    │ Jenkins polling │  cada 2 minutos detecta nuevo commit
                    │                 │
                    │  ① Checkout     │
                    │  ② Test local   │
                    │  ③ SonarQube    │  → http://localhost:9000
                    │  ④ Docker Build │  → localhost:5000/retailtech/product-service
                    │  ⑤ Push         │  → registry local
                    │  ⑥ Deploy       │  → contenedor retailtech-product-service
                    │  ⑦ Smoke Tests  │  → /health + /api/products
                    └────────┬────────┘
                             │  CD exitoso ✅
                    ┌────────▼────────┐
                    │  Servicios en   │
                    │  producción     │
                    │                 │
                    │  :3000 API      │
                    │  :3001 Grafana  │
                    │  :9000 Sonar    │
                    │  :9090 Prom     │
                    └─────────────────┘
```

### Tiempo estimado total
- **GitHub Actions:** ~5-7 minutos (lint + test + build)
- **Jenkins detecta commit:** hasta 2 minutos (polling)
- **Jenkins pipeline:** ~3-5 minutos
- **Total desde push hasta producción:** ~10-15 minutos

---

## 11. Acceso a los Servicios

Una vez ejecutado `docker compose up -d`:

| Servicio             | URL                          | Credenciales        |
|----------------------|------------------------------|---------------------|
| Dashboard (Nginx)    | http://localhost             | —                   |
| Product Service API  | http://localhost:3000        | —                   |
| Swagger UI           | http://localhost:3000/docs   | —                   |
| Métricas Prometheus  | http://localhost:3000/metrics | —                  |
| Jenkins              | http://localhost:8080        | admin / admin123    |
| SonarQube            | http://localhost:9000        | admin / admin       |
| Prometheus           | http://localhost:9090        | —                   |
| Grafana              | http://localhost:3001        | admin / admin       |
| Docker Registry      | http://localhost:5000        | —                   |
| Portainer            | https://localhost:9443       | (configurar al inicio) |

---

*Documento generado para el Lab 3 — Fundamentos DevOps, Maestría en Arquitectura de Software*
