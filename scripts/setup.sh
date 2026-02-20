#!/bin/bash

# Script de configuración inicial del entorno DevOps
# RetailTech - Actividad 3

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════╗"
echo "║   RetailTech DevOps Environment Setup             ║"
echo "║   Laboratorio Técnico - Actividad 3               ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar prerrequisitos
echo -e "${YELLOW}📋 Verificando prerrequisitos...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker instalado: $(docker --version)${NC}"
echo -e "${GREEN}✅ Docker Compose instalado: $(docker compose version)${NC}"

# Verificar que Docker esté corriendo
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker daemon no está corriendo${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker daemon corriendo${NC}"
echo ""

# Descomprimir repositorio si existe el tar.gz
if [ -f "lab3-retailtech-app.tar.gz" ]; then
    echo -e "${YELLOW}📦 Descomprimiendo repositorio...${NC}"
    tar -xzf lab3-retailtech-app.tar.gz
    echo -e "${GREEN}✅ Repositorio descomprimido${NC}"
fi

# Verificar estructura
echo -e "${YELLOW}📁 Verificando estructura de archivos...${NC}"

required_files=(
    "docker-compose.yml"
    "Makefile"
    "lab3-reatiltech-app/Dockerfile"
    "lab3-reatiltech-app/package.json"
    "jenkins/casc.yaml"
    "prometheus/prometheus.yml"
    "nginx/nginx.conf"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Falta archivo: $file${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅${NC} $file"
done

echo ""

# Crear directorios necesarios
echo -e "${YELLOW}📂 Creando directorios...${NC}"
mkdir -p jenkins/jobs
mkdir -p grafana/provisioning/datasources
mkdir -p grafana/provisioning/dashboards
echo -e "${GREEN}✅ Directorios creados${NC}"

# Configurar Grafana datasources
echo -e "${YELLOW}⚙️  Configurando Grafana datasources...${NC}"
cat > grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

echo -e "${GREEN}✅ Grafana configurado${NC}"

# Información de puertos
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 CONFIGURACIÓN COMPLETA             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📊 Puertos configurados:${NC}"
echo "  - Dashboard:        http://localhost:80"
echo "  - Product Service:  http://localhost:3000"
echo "  - Jenkins:          http://localhost:8080"
echo "  - SonarQube:        http://localhost:9000"
echo "  - Grafana:          http://localhost:3001"
echo "  - Prometheus:       http://localhost:9090"
echo "  - Docker Registry:  http://localhost:5000"
echo "  - Portainer:        https://localhost:9443"
echo ""
echo -e "${YELLOW}🔐 Credenciales por defecto:${NC}"
echo "  - Jenkins:    admin / admin123"
echo "  - SonarQube:  admin / admin"
echo "  - Grafana:    admin / admin"
echo ""
echo -e "${YELLOW}🚀 Siguiente paso:${NC}"
echo "  Ejecuta: ${GREEN}make start${NC} para iniciar todos los servicios"
echo "  O:       ${GREEN}docker-compose up -d${NC}"
echo ""
echo -e "${GREEN}✅ Setup completado exitosamente${NC}"
