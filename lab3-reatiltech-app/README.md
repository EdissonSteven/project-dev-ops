# 🚀 RetailTech Product Service



Microservicio de catálogo de productos para RetailTech E-Commerce. Este proyecto demuestra la implementación de pipelines CI/CD modernos con GitHub Actions y Jenkins.

## 📋 Tabla de Contenidos

- [Descripción](#descripción)
- [Arquitectura CI/CD](#arquitectura-cicd)
- [Tecnologías](#tecnologías)
- [Instalación Local](#instalación-local)
- [API Endpoints](#api-endpoints)
- [Pipeline CI](#pipeline-ci)
- [Pipeline CD](#pipeline-cd)
- [Docker](#docker)
- [Testing](#testing)
- [Métricas y Monitoreo](#métricas-y-monitoreo)

## 📖 Descripción

Servicio RESTful que gestiona el catálogo de productos tecnológicos. Implementado como parte de la arquitectura de microservicios de RetailTech Colombia S.A.S.

### Características

- ✅ API RESTful con Express.js
- ✅ Tests unitarios con Jest
- ✅ Linting con ESLint
- ✅ Containerización con Docker
- ✅ CI/CD automatizado (GitHub Actions + Jenkins)
- ✅ Security scanning (Snyk + Trivy)
- ✅ Health checks y metrics

## 🏗️ Arquitectura CI/CD

### Pipeline de Integración Continua (GitHub Actions)

El pipeline CI se ejecuta automáticamente en cada push o pull request:

```
┌─────────┐    ┌──────┐    ┌──────────┐    ┌───────┐    ┌────────┐
│  Lint   │ -> │ Test │ -> │ Security │ -> │ Build │ -> │ Push   │
│  Code   │    │      │    │  Scan    │    │ Image │    │ to ECR │
└─────────┘    └──────┘    └──────────┘    └───────┘    └────────┘
```

**Stages del CI:**

1. **Lint**: ESLint para verificar calidad de código
2. **Test**: Jest para tests unitarios con coverage
3. **Security**: Snyk y npm audit para vulnerabilidades
4. **Build**: Construcción de imagen Docker multi-stage
5. **Push**: Publicación a GitHub Container Registry

**Tiempo estimado**: ~8 minutos

### Pipeline de Entrega Continua (Jenkins)

El pipeline CD gestiona el deployment a Kubernetes:

```
┌──────────┐    ┌───────┐    ┌──────────┐    ┌────────┐    ┌────────┐
│ Checkout │ -> │ Build │ -> │ Security │ -> │  Push  │ -> │ Deploy │
│   Code   │    │ Image │    │   Scan   │    │Registry│    │  to K8s│
└──────────┘    └───────┘    └──────────┘    └────────┘    └────────┘
```

**Stages del CD:**

1. **Checkout**: Clona código del repositorio
2. **Build**: Construye imagen Docker con tags apropiados
3. **Security Scan**: Escaneo con Trivy
4. **Push to Registry**: Publica a Docker Hub/Registry privado
5. **Update Manifests**: Actualiza manifests K8s (GitOps)
6. **Deploy**: Deployment a EKS usando kubectl
7. **Smoke Tests**: Validación post-deployment

**Estrategia de deployment**: Blue-Green con rollback automático

## 🛠️ Tecnologías

### Backend

- **Runtime**: Node.js 18+
- **Framework**: Express.js 4.x
- **Testing**: Jest + Supertest
- **Linting**: ESLint

### DevOps

- **CI**: GitHub Actions
- **CD**: Jenkins
- **Containerización**: Docker (multi-stage builds)
- **Orquestación**: Kubernetes (Amazon EKS)
- **Registry**: GitHub Container Registry / Docker Hub
- **Security**: Snyk, Trivy, npm audit
- **GitOps**: ArgoCD

## 💻 Instalación Local

### Prerrequisitos

- Node.js >= 18.0.0
- npm >= 9.0.0
- Docker (opcional)

### Pasos

1. **Clonar repositorio**

```bash
git clone https://github.com/retailtech/product-service.git
cd product-service
```

2. **Instalar dependencias**

```bash
npm install
```

3. **Configurar variables de entorno**

```bash
cp .env.example .env
# Editar .env con tus configuraciones
```

4. **Ejecutar en modo desarrollo**

```bash
npm run dev
```

5. **Ejecutar tests**

```bash
npm test
```

La aplicación estará disponible en `http://localhost:3000`

## 📡 API Endpoints

### Health Check

```http
GET /health
```

Respuesta:
```json
{
  "status": "UP",
  "timestamp": "2026-02-12T10:30:00.000Z",
  "service": "product-service"
}
```

### Productos

#### Listar todos los productos

```http
GET /api/products
GET /api/products?category=smartphones
```

#### Obtener producto por ID

```http
GET /api/products/:id
```

#### Crear producto

```http
POST /api/products
Content-Type: application/json

{
  "name": "MacBook Pro M3",
  "price": 2499.99,
  "category": "laptops",
  "stock": 10
}
```

#### Actualizar producto

```http
PUT /api/products/:id
Content-Type: application/json

{
  "price": 2399.99,
  "stock": 15
}
```

#### Eliminar producto

```http
DELETE /api/products/:id
```

## 🔄 Pipeline CI (GitHub Actions)

### Configuración

El workflow está definido en `.github/workflows/ci.yml`

### Triggers

- Push a `main` o `develop`
- Pull requests a `main` o `develop`

### Variables de entorno requeridas

Configurar en GitHub Secrets:

- `SNYK_TOKEN`: Token de Snyk para security scanning
- `GITHUB_TOKEN`: Auto-generado por GitHub Actions

### Ejecución manual

```bash
# Desde la interfaz de GitHub
Actions > CI Pipeline > Run workflow
```

### Métricas del Pipeline

- **Coverage objetivo**: > 80%
- **Security**: 0 vulnerabilidades HIGH o CRITICAL
- **Build time**: < 10 minutos

## 🚢 Pipeline CD (Jenkins)

### Configuración

El Jenkinsfile está en la raíz del proyecto.

### Credentials requeridas en Jenkins

1. **dockerhub-credentials**: Username/Password para Docker Hub
2. **kubeconfig-credentials**: Archivo kubeconfig para acceso a EKS

### Ambientes

- **Staging**: Branch `develop` → Namespace `staging`
- **Production**: Branch `main` → Namespace `production`

### Deployment Strategy

```yaml
# Blue-Green deployment
- Deploy nueva versión (Green)
- Smoke tests en Green
- Switch traffic a Green
- Mantener Blue para rollback rápido
```

### Rollback

```bash
# Automático si smoke tests fallan
# Manual via Jenkins:
kubectl rollout undo deployment/product-service -n production
```

## 🐳 Docker

### Build local

```bash
docker build -t retailtech/product-service:latest .
```

### Run local

```bash
docker run -p 3000:3000 \
  -e NODE_ENV=production \
  retailtech/product-service:latest
```

### Multi-stage build benefits

- **Tamaño**: Imagen final ~150MB (vs ~800MB sin multi-stage)
- **Seguridad**: Usuario no-root, mínimas dependencias
- **Performance**: Caching de capas optimizado

## 🧪 Testing

### Tests unitarios

```bash
npm test
```

### Tests con coverage

```bash
npm test -- --coverage
```

### Coverage report

```
----------------------|---------|----------|---------|---------|
File                  | % Stmts | % Branch | % Funcs | % Lines |
----------------------|---------|----------|---------|---------|
All files             |   95.12 |    88.23 |   100.0 |   95.12 |
 app.js               |   95.12 |    88.23 |   100.0 |   95.12 |
----------------------|---------|----------|---------|---------|
```

### Linting

```bash
npm run lint
npm run lint:fix  # Auto-fix
```

## 📊 Métricas y Monitoreo

### Health Checks

- **Endpoint**: `/health`
- **Frecuencia**: Cada 30s
- **Timeout**: 3s

### Prometheus Metrics

Expuestos en `/metrics`:

- `http_request_duration_seconds`
- `http_requests_total`
- `nodejs_heap_size_used_bytes`

### Logging

```javascript
// Estructura de logs
{
  "timestamp": "2026-02-12T10:30:00.000Z",
  "level": "info",
  "message": "GET /api/products",
  "duration": 45,
  "statusCode": 200
}
```

## 🔒 Seguridad

### Implementaciones

- ✅ Helmet.js para HTTP headers seguros
- ✅ CORS configurado
- ✅ Rate limiting (TODO)
- ✅ Input validation
- ✅ Security scanning en CI/CD
- ✅ Container scanning con Trivy
- ✅ Dependency scanning con Snyk

### Vulnerabilidades conocidas

Ninguna vulnerabilidad HIGH o CRITICAL (última verificación: 2026-02-12)

## 🤝 Contribución

1. Fork del proyecto
2. Crear feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a branch (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

### Code Review Checklist

- [ ] Tests unitarios agregados
- [ ] Linting pasa
- [ ] Coverage > 80%
- [ ] Documentación actualizada
- [ ] Sin vulnerabilidades nuevas

## 📝 Licencia

MIT License - ver archivo [LICENSE](LICENSE)

## 👥 Equipo

- **DevOps Lead**: [Nombre]
- **Backend Team**: [Nombres]
- **QA Team**: [Nombres]

## 📞 Contacto

- **Email**: devops@retailtech.com
- **Slack**: #devops-support
- **Wiki**: https://wiki.retailtech.com/product-service

---

**Versión**: 1.0.0  
**Última actualización**: 2026-02-12  
**Estado**: ✅ Producción
