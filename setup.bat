@echo off
setlocal enabledelayedexpansion

:: MIGI UDE Quick Setup Script for Windows
:: Automated setup for the entire Meta-Geniusz ecosystem

title MIGI Unified Dev Environment - Setup

:: Colors (Windows Terminal/PowerShell)
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

:: Banner
echo.
echo %BLUE%╔═══════════════════════════════════════════════════════════════╗%NC%
echo %BLUE%║                                                               ║%NC%
echo %BLUE%║            🧠 MIGI Unified Dev Environment                    ║%NC%
echo %BLUE%║              Quick Setup ^& Launch Script                     ║%NC%
echo %BLUE%║                                                               ║%NC%
echo %BLUE%║        Run entire Meta-Geniusz ecosystem in one command      ║%NC%
echo %BLUE%║                                                               ║%NC%
echo %BLUE%╚═══════════════════════════════════════════════════════════════╝%NC%
echo.

:: Check Docker
echo %YELLOW%🐳 Checking Docker...%NC%
docker --version >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ Docker is not installed!%NC%
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ Docker is not running!%NC%
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

docker compose version >nul 2>&1
if errorlevel 1 (
    echo %RED%❌ Docker Compose v2 is not available!%NC%
    echo Please update Docker Desktop to get Docker Compose v2.
    pause
    exit /b 1
)

echo %GREEN%✅ Docker is ready%NC%

:: Setup environment
echo %YELLOW%⚙️ Setting up environment...%NC%
if not exist .env (
    echo %BLUE%📝 Creating .env file from template...%NC%
    copy .env.example .env >nul
    echo %GREEN%✅ .env file created%NC%
    echo %YELLOW%💡 You can customize .env file with your settings%NC%
) else (
    echo %GREEN%✅ .env file already exists%NC%
)

:: Check project directories
echo %YELLOW%📁 Checking project directories...%NC%
set "missing_count=0"

if not exist "..\Meta_Geniusz_system-main" (
    echo %YELLOW%   ⚠️ ../Meta_Geniusz_system-main missing%NC%
    set /a missing_count+=1
)
if not exist "..\drift_money-main" (
    echo %YELLOW%   ⚠️ ../drift_money-main missing%NC%
    set /a missing_count+=1
)
if not exist "..\GOK-AI-MixTape-main" (
    echo %YELLOW%   ⚠️ ../GOK-AI-MixTape-main missing%NC%
    set /a missing_count+=1
)
if not exist "..\rocket_fuell_girls-main" (
    echo %YELLOW%   ⚠️ ../rocket_fuell_girls-main missing%NC%
    set /a missing_count+=1
)
if not exist "..\hip_hop_universe-main" (
    echo %YELLOW%   ⚠️ ../hip_hop_universe-main missing%NC%
    set /a missing_count+=1
)
if not exist "..\SpiralMind-Nexus-main" (
    echo %YELLOW%   ⚠️ ../SpiralMind-Nexus-main missing%NC%
    set /a missing_count+=1
)

if !missing_count! gtr 0 (
    echo %YELLOW%💡 Services for missing projects will not start, but others will work fine.%NC%
) else (
    echo %GREEN%✅ All project directories found%NC%
)

:: Create directories
echo %YELLOW%📂 Creating required directories...%NC%
if not exist "gateway\letsencrypt" mkdir "gateway\letsencrypt" >nul 2>&1
if not exist "gateway\logs" mkdir "gateway\logs" >nul 2>&1
if not exist "infra\sql\init" mkdir "infra\sql\init" >nul 2>&1
echo %GREEN%✅ Directories created%NC%

:: Start services
echo %YELLOW%🚀 Starting MIGI ecosystem...%NC%
echo %BLUE%This may take a few minutes on first run (downloading images)...%NC%

cd infra

:: Start infrastructure first
echo %BLUE%📊 Starting infrastructure services...%NC%
docker compose up -d postgres redis hardhat

:: Wait for databases
echo %BLUE%⏳ Waiting for databases to be ready...%NC%
timeout /t 10 /nobreak >nul

:: Start core services
echo %BLUE%🧠 Starting core services...%NC%
docker compose up -d meta_geniusz drift_money gok_ai spiralmind_nexus

:: Wait for core services
echo %BLUE%⏳ Waiting for core services...%NC%
timeout /t 15 /nobreak >nul

:: Start frontend services
echo %BLUE%🌐 Starting frontend services...%NC%
docker compose up -d rocket_fuel_girls hip_hop_universe

:: Start monitoring
echo %BLUE%📊 Starting monitoring services...%NC%
docker compose up -d prometheus grafana loki promtail

:: Start utilities
echo %BLUE%🛠️ Starting utility services...%NC%
docker compose up -d adminer redis_commander

:: Start gateway
echo %BLUE%🌐 Starting gateway...%NC%
docker compose up -d gateway

cd ..

echo %GREEN%✅ All services started!%NC%

:: Wait for services
echo %YELLOW%⏳ Waiting for services to be healthy...%NC%
timeout /t 30 /nobreak >nul

:: Show status
echo %YELLOW%📊 Service status:%NC%
cd infra
docker compose ps
cd ..

:: Show access info
echo.
echo %GREEN%🎉 MIGI Ecosystem is ready!%NC%
echo.
echo %BLUE%🌐 Access your services:%NC%
echo   %GREEN%Main App:%NC%           http://localhost
echo   %GREEN%Hip-Hop Universe:%NC%   http://music.localhost
echo   %GREEN%Grafana Dashboard:%NC%  http://dashboard.localhost
echo   %GREEN%Metrics:%NC%            http://metrics.localhost
echo   %GREEN%Traefik Dashboard:%NC%  http://localhost:8080
echo   %GREEN%Database Admin:%NC%     http://db.localhost
echo   %GREEN%Redis Commander:%NC%    http://redis.localhost
echo.
echo %BLUE%🔌 API Endpoints:%NC%
echo   %GREEN%Meta-Geniusz API:%NC%   http://localhost/api/mgs
echo   %GREEN%Drift Money API:%NC%    http://localhost/api/drift
echo   %GREEN%GOK-AI API:%NC%         http://localhost/api/ai
echo   %GREEN%SpiralMind API:%NC%     http://localhost/api/spiral
echo.
echo %BLUE%🛠️ Useful commands:%NC%
echo   %GREEN%View logs:%NC%          make logs
echo   %GREEN%Check status:%NC%       make status
echo   %GREEN%Stop services:%NC%      make dev-down
echo   %GREEN%Restart all:%NC%        make restart
echo.
echo %YELLOW%💡 Note: If you can't access *.localhost URLs, try:%NC%
echo    - Add '127.0.0.1 app.localhost music.localhost dashboard.localhost' to C:\Windows\System32\drivers\etc\hosts
echo    - Or use 'localhost' instead of the subdomains
echo.
echo %GREEN%🎉 Setup completed successfully!%NC%
echo %YELLOW%🚀 Your Meta-Geniusz ecosystem is now running!%NC%
echo.

pause