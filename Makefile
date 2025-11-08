# MIGI Unified Dev Environment - Makefile
# Convenient commands for the entire ecosystem

.PHONY: help dev-up dev-down build logs status clean restart exec

# Colors for pretty output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Default target
help: ## Show this help message
	@echo "$(GREEN)MIGI Unified Dev Environment$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Environment setup
.env:
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)Creating .env from .env.example...$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN)Please edit .env file with your configuration$(NC)"; \
	fi

# Development commands
dev-up: .env ## Start entire ecosystem in development mode
	@echo "$(GREEN)🚀 Starting MIGI Unified Dev Environment...$(NC)"
	@cd infra && docker compose up --build -d
	@echo "$(GREEN)✅ Ecosystem started!$(NC)"
	@echo "$(YELLOW)Available services:$(NC)"
	@echo "  🌐 Main App:           http://localhost"
	@echo "  🎵 Hip-Hop Universe:   http://music.localhost"
	@echo "  📊 Grafana Dashboard:  http://dashboard.localhost"
	@echo "  📈 Metrics:            http://metrics.localhost"
	@echo "  🔧 Traefik Dashboard:  http://localhost:8080"
	@echo "  🗄️  Database Admin:     http://db.localhost"
	@echo "  📦 Redis Commander:    http://redis.localhost"

dev-down: ## Stop entire ecosystem
	@echo "$(RED)🛑 Stopping MIGI ecosystem...$(NC)"
	@cd infra && docker compose down
	@echo "$(GREEN)✅ Ecosystem stopped$(NC)"

build: ## Build all services
	@echo "$(YELLOW)🔨 Building all services...$(NC)"
	@cd infra && docker compose build --no-cache
	@echo "$(GREEN)✅ Build completed$(NC)"

restart: ## Restart entire ecosystem
	@echo "$(YELLOW)🔄 Restarting ecosystem...$(NC)"
	@cd infra && docker compose restart
	@echo "$(GREEN)✅ Ecosystem restarted$(NC)"

# Service management
restart-service: ## Restart specific service (usage: make restart-service service=meta_geniusz)
	@if [ -z "$(service)" ]; then \
		echo "$(RED)❌ Please specify service: make restart-service service=SERVICE_NAME$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)🔄 Restarting $(service)...$(NC)"
	@cd infra && docker compose restart $(service)
	@echo "$(GREEN)✅ $(service) restarted$(NC)"

rebuild-service: ## Rebuild specific service (usage: make rebuild-service service=meta_geniusz)
	@if [ -z "$(service)" ]; then \
		echo "$(RED)❌ Please specify service: make rebuild-service service=SERVICE_NAME$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)🔨 Rebuilding $(service)...$(NC)"
	@cd infra && docker compose up --build -d $(service)
	@echo "$(GREEN)✅ $(service) rebuilt$(NC)"

# Monitoring and debugging
logs: ## Show logs for all services
	@cd infra && docker compose logs -f --tail=100

logs-service: ## Show logs for specific service (usage: make logs-service service=meta_geniusz)
	@if [ -z "$(service)" ]; then \
		echo "$(RED)❌ Please specify service: make logs-service service=SERVICE_NAME$(NC)"; \
		exit 1; \
	fi
	@cd infra && docker compose logs -f --tail=100 $(service)

status: ## Show status of all services
	@echo "$(GREEN)📊 MIGI Ecosystem Status:$(NC)"
	@cd infra && docker compose ps

health: ## Check health of all services
	@echo "$(GREEN)🏥 Health Check:$(NC)"
	@cd infra && docker compose ps --format "table {{.Name}}\t{{.State}}\t{{.Status}}"

exec: ## Execute bash in specific service (usage: make exec service=meta_geniusz)
	@if [ -z "$(service)" ]; then \
		echo "$(RED)❌ Please specify service: make exec service=SERVICE_NAME$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)🔧 Entering $(service) container...$(NC)"
	@cd infra && docker compose exec $(service) /bin/bash

# Database operations
db-connect: ## Connect to PostgreSQL database
	@cd infra && docker compose exec postgres psql -U migi -d migi_ecosystem

db-backup: ## Backup database
	@echo "$(YELLOW)💾 Creating database backup...$(NC)"
	@mkdir -p backups
	@cd infra && docker compose exec postgres pg_dump -U migi migi_ecosystem > ../backups/migi_backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✅ Database backup created$(NC)"

db-restore: ## Restore database from backup (usage: make db-restore file=backup_file.sql)
	@if [ -z "$(file)" ]; then \
		echo "$(RED)❌ Please specify backup file: make db-restore file=backup_file.sql$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)📥 Restoring database from $(file)...$(NC)"
	@cd infra && docker compose exec -T postgres psql -U migi -d migi_ecosystem < ../backups/$(file)
	@echo "$(GREEN)✅ Database restored$(NC)"

# Blockchain operations
blockchain-deploy: ## Deploy smart contracts
	@echo "$(YELLOW)🔗 Deploying smart contracts...$(NC)"
	@cd infra && docker compose exec meta_geniusz npm run deploy:localhost
	@echo "$(GREEN)✅ Smart contracts deployed$(NC)"

blockchain-status: ## Check blockchain status
	@echo "$(GREEN)⛓️  Blockchain Status:$(NC)"
	@cd infra && docker compose exec hardhat npx hardhat node --show-accounts

# Cleaning and maintenance
clean: ## Clean up containers, volumes, and images
	@echo "$(RED)🧹 Cleaning up ecosystem...$(NC)"
	@cd infra && docker compose down -v --remove-orphans
	@docker system prune -f
	@docker volume prune -f
	@echo "$(GREEN)✅ Cleanup completed$(NC)"

clean-all: ## Deep clean - remove everything including images
	@echo "$(RED)🧹 Deep cleaning ecosystem...$(NC)"
	@cd infra && docker compose down -v --rmi all --remove-orphans
	@docker system prune -af
	@docker volume prune -f
	@echo "$(GREEN)✅ Deep cleanup completed$(NC)"

reset: ## Reset entire ecosystem (clean + fresh start)
	@echo "$(YELLOW)🔄 Resetting ecosystem...$(NC)"
	@make clean
	@make dev-up
	@echo "$(GREEN)✅ Ecosystem reset completed$(NC)"

# Development helpers
update-deps: ## Update dependencies in all services
	@echo "$(YELLOW)📦 Updating dependencies...$(NC)"
	@cd infra && docker compose exec meta_geniusz npm update
	@cd infra && docker compose exec drift_money npm update
	@cd infra && docker compose exec gok_ai npm update
	@cd infra && docker compose exec rocket_fuel_girls npm update
	@cd infra && docker compose exec hip_hop_universe npm update
	@echo "$(GREEN)✅ Dependencies updated$(NC)"

test: ## Run tests for all services
	@echo "$(YELLOW)🧪 Running tests...$(NC)"
	@cd infra && docker compose exec meta_geniusz npm test
	@cd infra && docker compose exec drift_money npm test
	@cd infra && docker compose exec gok_ai npm test
	@echo "$(GREEN)✅ Tests completed$(NC)"

lint: ## Run linting for all services
	@echo "$(YELLOW)🔍 Running linters...$(NC)"
	@cd infra && docker compose exec meta_geniusz npm run lint
	@cd infra && docker compose exec drift_money npm run lint
	@cd infra && docker compose exec gok_ai npm run lint
	@echo "$(GREEN)✅ Linting completed$(NC)"

# Quick access to services
dashboard: ## Open Grafana dashboard
	@echo "$(GREEN)📊 Opening dashboard...$(NC)"
	@open http://dashboard.localhost || xdg-open http://dashboard.localhost || echo "Open http://dashboard.localhost in your browser"

app: ## Open main application
	@echo "$(GREEN)🌐 Opening main app...$(NC)"
	@open http://localhost || xdg-open http://localhost || echo "Open http://localhost in your browser"

music: ## Open Hip-Hop Universe
	@echo "$(GREEN)🎵 Opening Hip-Hop Universe...$(NC)"
	@open http://music.localhost || xdg-open http://music.localhost || echo "Open http://music.localhost in your browser"

traefik: ## Open Traefik dashboard
	@echo "$(GREEN)🔧 Opening Traefik dashboard...$(NC)"
	@open http://localhost:8080 || xdg-open http://localhost:8080 || echo "Open http://localhost:8080 in your browser"

# Development workflow shortcuts
dev: dev-up ## Alias for dev-up
stop: dev-down ## Alias for dev-down
log: logs ## Alias for logs
ps: status ## Alias for status

# Documentation
docs: ## Generate documentation
	@echo "$(YELLOW)📚 Generating documentation...$(NC)"
	@echo "$(GREEN)MIGI Unified Dev Environment$(NC)"
	@echo "$(YELLOW)Services:$(NC)"
	@echo "  - Meta-Geniusz System (Core Intelligence)"
	@echo "  - Drift Money (Economic Engine)"
	@echo "  - GOK-AI (AI Services)"
	@echo "  - Rocket Fuel Girls (Community Frontend)"
	@echo "  - Hip-Hop Universe (Music Platform)"
	@echo "  - SpiralMind Nexus (Analytics)"
	@echo "$(YELLOW)Infrastructure:$(NC)"
	@echo "  - PostgreSQL (Database)"
	@echo "  - Redis (Cache)"
	@echo "  - Traefik (Gateway)"
	@echo "  - Prometheus (Metrics)"
	@echo "  - Grafana (Dashboards)"
	@echo "  - Loki (Logs)"

# Environment info
info: ## Show environment information
	@echo "$(GREEN)ℹ️  MIGI Environment Information:$(NC)"
	@echo "$(YELLOW)Docker Version:$(NC)"
	@docker --version
	@echo "$(YELLOW)Docker Compose Version:$(NC)"
	@docker compose version
	@echo "$(YELLOW)Environment File:$(NC)"
	@if [ -f .env ]; then echo "✅ .env exists"; else echo "❌ .env missing (run 'make .env')"; fi
	@echo "$(YELLOW)Services Status:$(NC)"
	@make status