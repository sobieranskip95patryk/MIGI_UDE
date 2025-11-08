#!/bin/bash

# MIGI UDE Quick Setup Script
# Automated setup for the entire Meta-Geniusz ecosystem

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║            🧠 MIGI Unified Dev Environment                    ║"
echo "║              Quick Setup & Launch Script                     ║"
echo "║                                                               ║"
echo "║        Run entire Meta-Geniusz ecosystem in one command      ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Docker
check_docker() {
    echo -e "${YELLOW}🐳 Checking Docker...${NC}"
    
    if ! command_exists docker; then
        echo -e "${RED}❌ Docker is not installed!${NC}"
        echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running!${NC}"
        echo "Please start Docker Desktop and try again."
        exit 1
    fi
    
    # Check Docker Compose
    if ! docker compose version >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker Compose v2 is not available!${NC}"
        echo "Please update Docker Desktop to get Docker Compose v2."
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker is ready${NC}"
}

# Function to check system resources
check_resources() {
    echo -e "${YELLOW}💾 Checking system resources...${NC}"
    
    # Check available memory (Linux/macOS)
    if command_exists free; then
        available_mem=$(free -g | awk '/^Mem:/{print $7}')
        if [ "$available_mem" -lt 4 ]; then
            echo -e "${YELLOW}⚠️  Warning: Low available memory (${available_mem}GB). 8GB+ recommended.${NC}"
        fi
    elif command_exists vm_stat; then
        # macOS memory check
        free_pages=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        free_gb=$((free_pages * 4096 / 1024 / 1024 / 1024))
        if [ "$free_gb" -lt 4 ]; then
            echo -e "${YELLOW}⚠️  Warning: Low available memory (${free_gb}GB). 8GB+ recommended.${NC}"
        fi
    fi
    
    # Check available disk space
    available_space=$(df -h . | awk 'NR==2{print $4}' | sed 's/G.*//')
    if [ "$available_space" -lt 10 ]; then
        echo -e "${YELLOW}⚠️  Warning: Low disk space (${available_space}GB available). 10GB+ recommended.${NC}"
    fi
    
    echo -e "${GREEN}✅ System resources checked${NC}"
}

# Function to setup environment
setup_environment() {
    echo -e "${YELLOW}⚙️  Setting up environment...${NC}"
    
    if [ ! -f .env ]; then
        echo -e "${BLUE}📝 Creating .env file from template...${NC}"
        cp .env.example .env
        echo -e "${GREEN}✅ .env file created${NC}"
        echo -e "${YELLOW}💡 You can customize .env file with your settings${NC}"
    else
        echo -e "${GREEN}✅ .env file already exists${NC}"
    fi
}

# Function to check project directories
check_project_directories() {
    echo -e "${YELLOW}📁 Checking project directories...${NC}"
    
    projects=(
        "../Meta_Geniusz_system-main"
        "../drift_money-main" 
        "../GOK-AI-MixTape-main"
        "../rocket_fuell_girls-main"
        "../hip_hop_universe-main"
        "../SpiralMind-Nexus-main"
    )
    
    missing_projects=()
    
    for project in "${projects[@]}"; do
        if [ ! -d "$project" ]; then
            missing_projects+=("$project")
        fi
    done
    
    if [ ${#missing_projects[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Some project directories are missing:${NC}"
        for project in "${missing_projects[@]}"; do
            echo -e "${YELLOW}   - $project${NC}"
        done
        echo -e "${YELLOW}💡 Services for missing projects will not start, but others will work fine.${NC}"
    else
        echo -e "${GREEN}✅ All project directories found${NC}"
    fi
}

# Function to create required directories
create_directories() {
    echo -e "${YELLOW}📂 Creating required directories...${NC}"
    
    directories=(
        "gateway/letsencrypt"
        "gateway/logs"
        "infra/sql/init"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
    done
    
    echo -e "${GREEN}✅ Directories created${NC}"
}

# Function to start services
start_services() {
    echo -e "${YELLOW}🚀 Starting MIGI ecosystem...${NC}"
    echo -e "${BLUE}This may take a few minutes on first run (downloading images)...${NC}"
    
    cd infra
    
    # Start infrastructure first
    echo -e "${BLUE}📊 Starting infrastructure services...${NC}"
    docker compose up -d postgres redis hardhat
    
    # Wait for databases to be ready
    echo -e "${BLUE}⏳ Waiting for databases to be ready...${NC}"
    sleep 10
    
    # Start core services
    echo -e "${BLUE}🧠 Starting core services...${NC}"
    docker compose up -d meta_geniusz drift_money gok_ai spiralmind_nexus
    
    # Wait for core services
    echo -e "${BLUE}⏳ Waiting for core services...${NC}"
    sleep 15
    
    # Start frontend services
    echo -e "${BLUE}🌐 Starting frontend services...${NC}"
    docker compose up -d rocket_fuel_girls hip_hop_universe
    
    # Start monitoring
    echo -e "${BLUE}📊 Starting monitoring services...${NC}"
    docker compose up -d prometheus grafana loki promtail
    
    # Start utilities
    echo -e "${BLUE}🛠️  Starting utility services...${NC}"
    docker compose up -d adminer redis_commander
    
    # Finally start gateway
    echo -e "${BLUE}🌐 Starting gateway...${NC}"
    docker compose up -d gateway
    
    cd ..
    
    echo -e "${GREEN}✅ All services started!${NC}"
}

# Function to show service status
show_status() {
    echo -e "${YELLOW}📊 Checking service status...${NC}"
    
    cd infra
    docker compose ps --format "table {{.Name}}\t{{.State}}\t{{.Status}}"
    cd ..
}

# Function to show access URLs
show_access_info() {
    echo -e "\n${GREEN}🎉 MIGI Ecosystem is ready!${NC}\n"
    
    echo -e "${BLUE}🌐 Access your services:${NC}"
    echo -e "  ${GREEN}Main App:${NC}           http://localhost"
    echo -e "  ${GREEN}Hip-Hop Universe:${NC}   http://music.localhost"
    echo -e "  ${GREEN}Grafana Dashboard:${NC}  http://dashboard.localhost"
    echo -e "  ${GREEN}Metrics:${NC}            http://metrics.localhost"
    echo -e "  ${GREEN}Traefik Dashboard:${NC}  http://localhost:8080"
    echo -e "  ${GREEN}Database Admin:${NC}     http://db.localhost"
    echo -e "  ${GREEN}Redis Commander:${NC}    http://redis.localhost"
    
    echo -e "\n${BLUE}🔌 API Endpoints:${NC}"
    echo -e "  ${GREEN}Meta-Geniusz API:${NC}   http://localhost/api/mgs"
    echo -e "  ${GREEN}Drift Money API:${NC}    http://localhost/api/drift" 
    echo -e "  ${GREEN}GOK-AI API:${NC}         http://localhost/api/ai"
    echo -e "  ${GREEN}SpiralMind API:${NC}     http://localhost/api/spiral"
    
    echo -e "\n${BLUE}🛠️  Useful commands:${NC}"
    echo -e "  ${GREEN}View logs:${NC}          make logs"
    echo -e "  ${GREEN}Check status:${NC}       make status"
    echo -e "  ${GREEN}Stop services:${NC}      make dev-down"
    echo -e "  ${GREEN}Restart all:${NC}        make restart"
    
    echo -e "\n${YELLOW}💡 Note: If you can't access *.localhost URLs, try:${NC}"
    echo -e "   - Add '127.0.0.1 app.localhost music.localhost dashboard.localhost' to /etc/hosts"
    echo -e "   - Or use 'localhost' instead of the subdomains"
}

# Function to wait for services to be healthy
wait_for_services() {
    echo -e "${YELLOW}⏳ Waiting for services to be healthy...${NC}"
    
    local max_wait=120  # 2 minutes
    local count=0
    
    while [ $count -lt $max_wait ]; do
        if curl -s http://localhost:8080/api/dashboard > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Gateway is responding${NC}"
            break
        fi
        
        echo -e "${BLUE}   Waiting... ($count/$max_wait)${NC}"
        sleep 5
        count=$((count + 5))
    done
    
    if [ $count -ge $max_wait ]; then
        echo -e "${YELLOW}⚠️  Services are still starting up. You can check status with: make status${NC}"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}Starting MIGI UDE setup process...${NC}\n"
    
    # Pre-flight checks
    check_docker
    check_resources
    check_project_directories
    
    # Setup
    setup_environment
    create_directories
    
    # Launch
    start_services
    
    # Wait and verify
    wait_for_services
    show_status
    
    # Show access info
    show_access_info
    
    echo -e "\n${GREEN}🎉 Setup completed successfully!${NC}"
    echo -e "${YELLOW}🚀 Your Meta-Geniusz ecosystem is now running!${NC}\n"
}

# Handle Ctrl+C
trap 'echo -e "\n${RED}❌ Setup interrupted${NC}"; exit 1' INT

# Run main function
main "$@"