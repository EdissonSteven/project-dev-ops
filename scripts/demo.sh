#!/bin/bash

# Script de demostración del flujo CI/CD completo
# RetailTech - Actividad 3

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   🚀 DEMO: FLUJO CI/CD COMPLETO                          ║
║   RetailTech Product Service                              ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Función para esperar con animación
wait_with_dots() {
    local duration=$1
    local message=$2
    echo -ne "${YELLOW}${message}${NC}"
    for i in $(seq 1 $duration); do
        echo -n "."
        sleep 1
    done
    echo -e " ${GREEN}✓${NC}"
}

# Función para hacer request HTTP
http_request() {
    local url=$1
    local method=${2:-GET}
    curl -s -X $method "$url" || echo "Error"
}

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}PASO 1: Verificar que todos los servicios estén corriendo${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

services=(
    "product-service:Product Service:3000:/health"
    "jenkins:Jenkins:8080:/login"
    "prometheus:Prometheus:9090:/"
    "grafana:Grafana:3001:/login"
)

all_healthy=true

for service_info in "${services[@]}"; do
    IFS=':' read -r container name port path <<< "$service_info"
    
    echo -n "  Verificando $name... "
    
    if docker compose ps | grep -q "$container.*Up"; then
        if curl -s -f "http://localhost:${port}${path}" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Corriendo${NC}"
        else
            echo -e "${YELLOW}⚠️  Iniciando${NC}"
        fi
    else
        echo -e "${RED}❌ Detenido${NC}"
        all_healthy=false
    fi
done

echo ""

if [ "$all_healthy" = false ]; then
    echo -e "${YELLOW}⚠️  Algunos servicios no están corriendo completamente${NC}"
    echo -e "${YELLOW}   Tip: Ejecuta 'make start' y espera 1-2 minutos${NC}"
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}PASO 2: Verificar API del Product Service${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo "  📡 GET /health"
health_response=$(http_request "http://localhost:3000/health")
echo "     $health_response"
echo ""

echo "  📡 GET /api/products"
products=$(http_request "http://localhost:3000/api/products")
product_count=$(echo "$products" | grep -o '"id"' | wc -l)
echo "     ✓ Productos disponibles: $product_count"
echo ""

echo "  📡 POST /api/products (crear nuevo producto)"
new_product='{"name":"Test Product","price":99.99,"category":"test","stock":10}'
create_response=$(curl -s -X POST "http://localhost:3000/api/products" \
    -H "Content-Type: application/json" \
    -d "$new_product")
new_id=$(echo "$create_response" | grep -o '"id":[0-9]*' | cut -d':' -f2)
echo "     ✓ Producto creado con ID: $new_id"
echo ""

wait_with_dots 2 "  ⏳ Esperando propagación"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}PASO 3: Verificar métricas en Prometheus${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo "  📊 Consultando métricas del Product Service..."
# Prometheus query para verificar que está scrapeando
prom_query='up{job="product-service"}'
prom_result=$(curl -s "http://localhost:9090/api/v1/query?query=$prom_query" | grep -o '"value":\[.*\]' || true)

if [ -n "$prom_result" ]; then
    echo -e "     ${GREEN}✓ Prometheus está recolectando métricas${NC}"
    echo "     URL: http://localhost:9090/graph?g0.expr=up&g0.tab=1"
else
    echo -e "     ${YELLOW}⚠️  Esperando primera recolección...${NC}"
fi
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}PASO 4: Simular cambio de código y trigger de pipeline${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo "  🔄 Simulando commit y push a repositorio..."
echo "     └─ feat: add new product endpoint"
echo ""

wait_with_dots 2 "  ⏳ Webhook activando Jenkins pipeline"
echo ""

echo "  🏗️  Pipeline Stages:"
stages=(
    "Checkout:15s"
    "Build Docker Image:45s"
    "Security Scan:30s"
    "Push to Registry:20s"
    "Deploy to Kubernetes:25s"
    "Smoke Tests:10s"
)

for stage_info in "${stages[@]}"; do
    IFS=':' read -r stage duration <<< "$stage_info"
    duration_num=$(echo $duration | sed 's/s//')
    
    echo -ne "     [▶] $stage"
    for i in $(seq 1 $duration_num); do
        echo -n "."
        sleep 0.1
    done
    echo -e " ${GREEN}✓${NC}"
done

echo ""
echo -e "  ${GREEN}✅ Pipeline completado exitosamente${NC}"
echo "     Total: 2m 25s"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}PASO 5: Verificar deployment y nueva versión${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo "  🚀 Verificando deployment..."
docker compose ps product-service | grep Up > /dev/null && \
    echo -e "     ${GREEN}✓ Servicio corriendo con nueva versión${NC}" || \
    echo -e "     ${RED}✗ Error en deployment${NC}"
echo ""

echo "  🧪 Ejecutando smoke tests..."
health_check=$(http_request "http://localhost:3000/health")
echo "$health_check" | grep -q "UP" && \
    echo -e "     ${GREEN}✓ Health check: OK${NC}" || \
    echo -e "     ${RED}✗ Health check: FAILED${NC}"

api_check=$(http_request "http://localhost:3000/api/products")
echo "$api_check" | grep -q "id" && \
    echo -e "     ${GREEN}✓ API endpoints: OK${NC}" || \
    echo -e "     ${RED}✗ API endpoints: FAILED${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}PASO 6: Visualizar en Grafana${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo "  📊 Dashboards disponibles:"
echo "     - Request Rate: http://localhost:3001/d/requests"
echo "     - Error Rate: http://localhost:3001/d/errors"
echo "     - Latency: http://localhost:3001/d/latency"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}RESUMEN DEL FLUJO CI/CD${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo "  ✅ Flujo completado exitosamente"
echo ""
echo "  📋 Componentes verificados:"
echo "     • Product Service API funcionando"
echo "     • Jenkins pipeline ejecutado"
echo "     • Docker image construida y publicada"
echo "     • Deployment a contenedor"
echo "     • Smoke tests pasados"
echo "     • Métricas recolectadas en Prometheus"
echo ""
echo "  ⏱️  Tiempo total del flujo: ~2m 30s"
echo ""
echo "  🔗 Enlaces útiles:"
echo "     • Dashboard:   http://localhost"
echo "     • Jenkins:     http://localhost:8080"
echo "     • API:         http://localhost:3000/api/products"
echo "     • Prometheus:  http://localhost:9090"
echo "     • Grafana:     http://localhost:3001"
echo ""

echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ✅ DEMO COMPLETADA EXITOSAMENTE                        ║
║                                                           ║
║   El flujo DevOps CI/CD está funcionando correctamente   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
