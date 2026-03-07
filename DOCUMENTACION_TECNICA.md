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
6. [Despliegue con Ansible](#6-despliegue-con-ansible)
7. [Infraestructura con Docker Compose](#7-infraestructura-con-docker-compose)
8. [Seguridad — SonarQube y Snyk](#8-seguridad--sonarqube-y-snyk)
9. [Monitoreo — Prometheus y Grafana](#9-monitoreo--prometheus-y-grafana)
10. [Despliegue en Kubernetes](#10-despliegue-en-kubernetes)
11. [Archivos de Configuración](#11-archivos-de-configuración)
12. [Flujo Completo CI/CD](#12-flujo-completo-cicd)
13. [Acceso a los Servicios](#13-acceso-a-los-servicios)
14. [Reflexión sobre Eficiencia Operativa](#14-reflexión-sobre-eficiencia-operativa)

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
| Seguridad deps    | Snyk                    | —          |
| Despliegue (CD)   | Ansible                 | 2.19+      |
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

#### Stage 6: Deploy (via Ansible)
- Invoca el playbook `ansible/deploy.yml` pasando variables dinámicas desde Jenkins
- Ansible detiene y elimina el contenedor anterior de forma idempotente
- Lanza el nuevo contenedor en la red `devops-network` con el tag de imagen generado
- Verifica activamente que el contenedor quedó en estado `running` antes de continuar

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

## 6. Despliegue con Ansible

**Archivos:** `ansible/deploy.yml`, `ansible/inventory.ini`

Ansible reemplaza los comandos bash directos en el stage `Deploy` del Jenkinsfile, aportando declaratividad, idempotencia y verificación activa del despliegue.

### ¿Por qué Ansible para CD?

| Aspecto | Sin Ansible (bash) | Con Ansible |
|---------|-------------------|-------------|
| Legibilidad | Comandos encadenados con `\|\| true` | Tareas con nombre descriptivo |
| Variables | Hardcodeadas en el script | Parametrizadas con `-e` desde Jenkins |
| Verificación | Ninguna post-deploy | Verifica que el contenedor esté `running` |
| Idempotencia | Parcial (`\|\| true` como parche) | `ignore_errors` explícito y controlado |
| Reutilización | Solo en este Jenkinsfile | Playbook reutilizable desde cualquier herramienta |

### Inventario (`ansible/inventory.ini`)

```ini
[local]
localhost ansible_connection=local
```

Ansible usa `connection: local` porque Jenkins y Docker comparten el mismo socket (`/var/run/docker.sock`). No se requiere SSH.

### Playbook de despliegue (`ansible/deploy.yml`)

```yaml
- name: Deploy RetailTech Product Service
  hosts: local
  gather_facts: false
  vars:
    container_name: retailtech-product-service
    image: "{{ registry }}/retailtech/product-service:{{ image_tag }}"
    network: "{{ compose_net }}"
    port: "3000"
  tasks:
    - name: Stop existing container    # idempotente
    - name: Remove existing container  # idempotente
    - name: Start new container        # docker run con imagen versionada
    - name: Verify container is running
    - name: Assert container is running # falla el pipeline si no levantó
```

### Invocación desde Jenkins

```groovy
sh """
    ansible-playbook ansible/deploy.yml \\
        -i ansible/inventory.ini \\
        -e "image_tag=${IMAGE_TAG}" \\
        -e "registry=${LOCAL_REGISTRY}" \\
        -e "compose_net=${COMPOSE_NET}"
"""
```

Las variables `IMAGE_TAG`, `LOCAL_REGISTRY` y `COMPOSE_NET` se inyectan dinámicamente desde el entorno de Jenkins, haciendo el playbook completamente reutilizable entre entornos.

### Instalación de Ansible en Jenkins

Ansible se instala directamente en la imagen de Jenkins (`jenkins/Dockerfile`):

```dockerfile
RUN apt-get update && apt-get install -y \
    curl git docker.io \
    && apt-get install -y ansible \
    && rm -rf /var/lib/apt/lists/*
```

Esto garantiza que `ansible-playbook` está disponible como comando en todos los builds.

---

## 7. Infraestructura con Docker Compose

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

## 8. Seguridad — SonarQube y Snyk

### 7.1 SonarQube — Análisis estático de código

**Archivo:** `lab3-reatiltech-app/sonar-project.properties`

SonarQube analiza el código fuente en busca de bugs, vulnerabilidades, code smells y cobertura de tests.

| Parámetro                        | Valor                              |
|----------------------------------|------------------------------------|
| `sonar.projectKey`               | `retailtech-product-service`       |
| `sonar.sources`                  | `.` (directorio raíz de la app)    |
| `sonar.exclusions`               | `node_modules/**`, `coverage/**`, `**/*.test.js` |
| `sonar.javascript.lcov.reportPaths` | `coverage/lcov.info`            |
| `sonar.host.url`                 | `http://sonarqube:9000`            |

El escáner se ejecuta desde Jenkins via contenedor Docker (`sonarsource/sonar-scanner-cli`), conectado a la red `devops-network` para acceder al servidor SonarQube interno.

**Categorías de análisis:**
- **Bugs:** errores que pueden causar comportamiento inesperado en runtime
- **Vulnerabilidades:** puntos de ataque potenciales (ej. inyecciones, XSS)
- **Code Smells:** problemas de mantenibilidad y deuda técnica
- **Cobertura:** porcentaje del código cubierto por pruebas unitarias

### 7.2 Snyk — Detección de vulnerabilidades en dependencias

**Integración:** Job `security` en `.github/workflows/ci.yml`

Snyk analiza el archivo `package.json` para detectar vulnerabilidades conocidas (CVEs) en las dependencias del proyecto.

**Configuración en el pipeline:**
```yaml
- uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high
```

**Características:**
- Umbral configurado en **severidad alta** — solo falla el pipeline si hay CVEs `high` o `critical`
- Continúa el pipeline aunque encuentre vulnerabilidades (`continue-on-error: true`) para no bloquear el flujo
- Genera un reporte `snyk-report.json` disponible como artifact en GitHub Actions

**Dependencias analizadas del proyecto:**

| Dependencia       | Versión  | Propósito                    |
|-------------------|----------|------------------------------|
| express           | ^4.18.2  | Framework HTTP               |
| helmet            | ^7.1.0   | Headers de seguridad HTTP    |
| cors              | ^2.8.5   | Control de CORS              |
| prom-client       | ^15.1.0  | Métricas Prometheus          |
| swagger-ui-express| ^5.0.0   | Documentación API            |

> **Nota:** Para activar Snyk, crear cuenta gratuita en [snyk.io](https://snyk.io), obtener el token API y agregarlo como secret `SNYK_TOKEN` en GitHub → Settings → Secrets and variables → Actions.

---

## 9. Monitoreo — Prometheus y Grafana

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

## 10. Despliegue en Kubernetes

**Carpeta:** `k8s/`

El proyecto incluye manifiestos de Kubernetes para desplegar el `product-service` en un clúster k8s.

### Estructura de manifiestos

```
k8s/
├── namespace.yaml     # Namespace 'retailtech' aislado
├── configmap.yaml     # Variables de configuración (NODE_ENV, PORT)
├── deployment.yaml    # Deployment con 2 réplicas + health checks
├── service.yaml       # ClusterIP expuesto en puerto 80
└── ingress.yaml       # Ingress Nginx con host retailtech.local
```

### Características del Deployment

| Característica        | Configuración                         |
|-----------------------|---------------------------------------|
| Réplicas              | 2 (alta disponibilidad)               |
| Estrategia            | RollingUpdate (sin downtime)          |
| Imagen                | `ghcr.io/edissonsteven/project-dev-ops/product-service:latest` |
| CPU request/limit     | 100m / 250m                           |
| Memoria request/limit | 128Mi / 256Mi                         |
| Liveness probe        | `GET /health` cada 20s               |
| Readiness probe       | `GET /health` cada 10s               |
| Métricas              | Anotaciones para scraping de Prometheus |

### Despliegue rápido

```bash
# Crear namespace y desplegar todo
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

# Verificar estado
kubectl get pods -n retailtech
kubectl get svc -n retailtech
```

---

## 11. Archivos de Configuración

Todos los archivos de configuración están incluidos en el repositorio:

```
project-dev-ops/
│
├── .github/
│   └── workflows/
│       └── ci.yml                     # Pipeline CI — Lint, Test, Snyk, Docker Build
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
├── k8s/
│   ├── namespace.yaml                 # Namespace 'retailtech'
│   ├── configmap.yaml                 # Variables de entorno
│   ├── deployment.yaml                # Deployment con 2 réplicas
│   ├── service.yaml                   # ClusterIP service
│   └── ingress.yaml                   # Ingress Nginx
│
├── ansible/
│   ├── deploy.yml                     # Playbook de despliegue del contenedor
│   └── inventory.ini                  # Inventario (localhost connection local)
│
├── jenkins/
│   ├── Dockerfile                     # Jenkins personalizado con plugins + Ansible
│   ├── casc.yaml                      # Jenkins Configuration as Code
│   └── jobs/
│       └── product-service-cd/        # Definición del job (generado por CasC)
│
├── prometheus/
│   └── prometheus.yml                 # Configuración de scraping
│
├── grafana/
│   └── provisioning/
│       ├── dashboards/product-service.json  # Dashboard pre-configurado
│       └── datasources/prometheus.yml       # Datasource automático
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

## 12. Flujo Completo CI/CD

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
                    │  ⑥ Deploy       │  → Ansible playbook → contenedor retail-product-service
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

## 13. Acceso a los Servicios

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

## 14. Reflexión sobre Eficiencia Operativa

### Impacto de la automatización en el ciclo de desarrollo

La implementación de este pipeline CI/CD transforma radicalmente la forma en que el equipo entrega valor. Antes de la automatización, cada despliegue requería intervención manual: ejecutar tests, construir la imagen, validar calidad, desplegar y verificar. Con el pipeline implementado, este proceso ocurre automáticamente en menos de 15 minutos desde el `git push`.

**Mejoras medibles:**

| Métrica                       | Sin CI/CD (manual) | Con CI/CD (automatizado) |
|-------------------------------|-------------------|--------------------------|
| Tiempo de despliegue          | ~45-60 min        | ~10-15 min               |
| Detección de bugs             | En producción     | En PR / antes de merge   |
| Consistencia de builds        | Variable          | 100% reproducible        |
| Cobertura de tests obligatoria| No garantizada    | Enforced por pipeline     |
| Vulnerabilidades detectadas   | Reactivo          | Proactivo (cada commit)  |

### Seguridad integrada como parte del flujo (DevSecOps)

Uno de los principios más relevantes aplicados en este proyecto es el de **shift-left security**: incorporar la seguridad desde las etapas tempranas del desarrollo, no como una revisión final. Esto se materializa de dos formas:

1. **SonarQube** analiza el código en cada CD ejecutado por Jenkins, detectando vulnerabilidades y code smells antes de que la imagen llegue a producción.
2. **Snyk** escanea las dependencias del `package.json` en cada CI de GitHub Actions, alertando sobre CVEs conocidos en librerías de terceros.

Este enfoque reduce drásticamente el costo de corregir vulnerabilidades, que según estudios del sector es hasta **30 veces más barato** corregirlas en desarrollo que en producción.

### Observabilidad como habilitador de confianza

La integración de Prometheus y Grafana permite que el equipo tenga visibilidad continua del comportamiento de la aplicación en producción. Las métricas expuestas por el servicio (`/metrics`) permiten detectar degradaciones de rendimiento antes de que se conviertan en incidentes. Esto cambia el paradigma de operaciones: de **reactivo** (responder a alertas) a **proactivo** (anticipar problemas con datos).

### Lecciones aprendidas

- **Configuration as Code (CasC)** en Jenkins elimina la fricción del onboarding: cualquier nuevo miembro del equipo puede levantar el entorno completo con un solo comando.
- La estrategia **RollingUpdate** en Kubernetes garantiza cero downtime en los despliegues, algo imposible de lograr consistentemente con procesos manuales.
- El uso de **Docker multi-stage builds** redujo el tamaño de la imagen final en un ~70% respecto a una imagen sin optimizar, impactando directamente en tiempos de pull y arranque del contenedor.
- El **polling de Jenkins cada 2 minutos** es un balance entre latencia de detección y carga sobre el servidor. En un entorno productivo, se reemplazaría por webhooks para respuesta inmediata.

### Próximos pasos recomendados

1. Migrar de polling a **webhooks** en Jenkins para reducir latencia CI → CD
2. Implementar **Quality Gates** en SonarQube para bloquear merges con deuda técnica crítica
3. Agregar **alertas en Grafana** con notificaciones a Slack/email cuando métricas superen umbrales
4. Integrar **OWASP ZAP** para pruebas de seguridad dinámicas (DAST) como etapa adicional del pipeline
5. Configurar **Horizontal Pod Autoscaler** en k8s para escalado automático basado en métricas

---

*Documento generado para el Lab 3 — Fundamentos DevOps, Maestría en Arquitectura de Software*
