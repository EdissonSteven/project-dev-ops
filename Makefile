.PHONY: help start stop restart logs status test clean setup

SHELL := /usr/bin/bash

# Colores para output
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m # No Color

help: ## Muestra esta ayuda
	@echo "$(GREEN)RetailTech DevOps Environment$(NC)"
	@echo ""
	@echo "$(YELLOW)Comandos disponibles:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

setup: ## Configuración inicial del entorno
	@echo "$(GREEN)🔧 Configurando entorno DevOps...$(NC)"
	@chmod +x scripts/*.sh
	@bash ./scripts/setup.sh

start: ## Inicia todos los servicios
	@echo "$(GREEN)🚀 Iniciando servicios...$(NC)"
	@docker compose up -d
	@echo "$(GREEN)✅ Servicios iniciados$(NC)"
	@echo ""
	@echo "$(YELLOW)Dashboard disponible en:$(NC) http://localhost"
	@echo "$(YELLOW)Jenkins:$(NC) http://localhost:8080 (admin/admin123)"
	@echo "$(YELLOW)SonarQube:$(NC) http://localhost:9000 (admin/admin)"
	@echo "$(YELLOW)Grafana:$(NC) http://localhost:3001 (admin/admin)"
	@echo "$(YELLOW)Product Service:$(NC) http://localhost:3000"

stop: ## Detiene todos los servicios
	@echo "$(YELLOW)⏸️  Deteniendo servicios...$(NC)"
	@docker compose down
	@echo "$(GREEN)✅ Servicios detenidos$(NC)"

restart: ## Reinicia todos los servicios
	@make stop
	@make start

logs: ## Muestra logs de todos los servicios
	@docker compose logs -f

logs-jenkins: ## Muestra logs de Jenkins
	@docker compose logs -f jenkins

logs-app: ## Muestra logs de Product Service
	@docker compose logs -f product-service

status: ## Muestra estado de los servicios
	@echo "$(GREEN)📊 Estado de los servicios:$(NC)"
	@docker compose ps

build: ## Construye las imágenes
	@echo "$(GREEN)🔨 Construyendo imágenes...$(NC)"
	@docker compose build

rebuild: ## Reconstruye las imágenes sin cache
	@echo "$(GREEN)🔨 Reconstruyendo imágenes...$(NC)"
	@docker compose build --no-cache

test: ## Ejecuta tests de la aplicación
	@echo "$(GREEN)🧪 Ejecutando tests...$(NC)"
	@docker compose exec -T product-service npm test

test-coverage: ## Ejecuta tests con coverage
	@echo "$(GREEN)🧪 Ejecutando tests con coverage...$(NC)"
	@docker compose exec -T product-service npm test -- --coverage

lint: ## Ejecuta linting
	@echo "$(GREEN)🔍 Ejecutando linter...$(NC)"
	@docker compose exec -T product-service npm run lint

shell-app: ## Abre shell en el contenedor de la app
	@docker compose exec product-service sh

shell-jenkins: ## Abre shell en Jenkins
	@docker compose exec jenkins bash

clean: ## Limpia volúmenes y contenedores
	@echo "$(RED)⚠️  ¿Estás seguro? Esto eliminará todos los datos. [y/N]$(NC) " && read ans && [ $${ans:-N} = y ]
	@docker compose down -v
	@echo "$(GREEN)✅ Limpieza completada$(NC)"

reset: clean setup start ## Reset completo del entorno

trigger-pipeline: ## Dispara el pipeline de Jenkins manualmente
	@echo "$(GREEN)🔄 Disparando pipeline...$(NC)"
	@curl -X POST http://localhost:8080/job/product-service-cd/build \
		--user admin:admin123

health-check: ## Verifica health de todos los servicios
	@echo "$(GREEN)🏥 Verificando salud de servicios...$(NC)"
	@echo ""
	@echo -n "Product Service: "
	@curl -s http://localhost:3000/health | grep -q "UP" && echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"
	@echo -n "Jenkins: "
	@curl -s http://localhost:8080/login > /dev/null && echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"
	@echo -n "SonarQube: "
	@curl -s http://localhost:9000 > /dev/null && echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"
	@echo -n "Grafana: "
	@curl -s http://localhost:3001 > /dev/null && echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"
	@echo -n "Prometheus: "
	@curl -s http://localhost:9090 > /dev/null && echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"

demo: ## Ejecuta una demo completa del flujo CI/CD
	@bash ./scripts/demo.sh
