# 🧠 MIGI Unified Dev Environment (UDE)

> **Run entire Meta-Geniusz ecosystem in one command**

## 🌟 Overview

MIGI UDE (Unified Dev Environment) is a complete Docker-based development environment that orchestrates all Meta-Geniusz ecosystem projects in one unified platform:

- **Meta-Geniusz System** - Central Intelligence & Consciousness Engine
- **Drift Money** - Economic Engine & Tokenization Platform  
- **GOK-AI MixTape** - AI Services & Intelligence Layer
- **Rocket Fuel Girls** - Community Frontend & User Interface
- **Hip-Hop Universe** - Music Platform & NFT Marketplace
- **SpiralMind Nexus** - Advanced Analytics & Data Processing

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose v2+
- Make (optional, for convenience commands)
- 8GB+ RAM recommended
- 10GB+ free disk space

### One-Command Setup

```bash
git clone https://github.com/sobieranskip95patryk/MIGI_UDE.git
cd MIGI_UDE
cp .env.example .env
make dev-up
```

**That's it!** 🎉 The entire ecosystem will be running in ~2-3 minutes.

## 🌐 Access Points

Once running, access your services at:

| Service | URL | Description |
|---------|-----|-------------|
| **Main App** | http://localhost | Rocket Fuel Girls Frontend |
| **Hip-Hop Universe** | http://music.localhost | Music Platform |
| **Grafana Dashboard** | http://dashboard.localhost | Monitoring & Analytics |
| **Metrics** | http://metrics.localhost | Prometheus Metrics |
| **Traefik Dashboard** | http://localhost:8080 | Gateway Management |
| **Database Admin** | http://db.localhost | PostgreSQL Admin |
| **Redis Commander** | http://redis.localhost | Redis Management |

### API Endpoints

| API | URL | Description |
|-----|-----|-------------|
| **Meta-Geniusz** | http://localhost/api/mgs | Core Intelligence API |
| **Drift Money** | http://localhost/api/drift | Economic Engine API |
| **GOK-AI** | http://localhost/api/ai | AI Services API |
| **SpiralMind** | http://localhost/api/spiral | Analytics API |

## 🛠️ Development Commands

### Essential Commands

```bash
# Start entire ecosystem
make dev-up

# Stop ecosystem
make dev-down

# View logs
make logs

# Check status
make status

# Clean restart
make restart
```

### Service-Specific Commands

```bash
# Restart specific service
make restart-service service=meta_geniusz

# View service logs
make logs-service service=drift_money

# Execute bash in service
make exec service=gok_ai

# Rebuild service
make rebuild-service service=rocket_fuel_girls
```

### Database Operations

```bash
# Connect to database
make db-connect

# Backup database
make db-backup

# Restore database
make db-restore file=backup_file.sql
```

### Blockchain Operations

```bash
# Deploy smart contracts
make blockchain-deploy

# Check blockchain status
make blockchain-status
```

### Quick Access

```bash
# Open services in browser
make app        # Main application
make dashboard  # Grafana dashboard
make music      # Hip-Hop Universe
make traefik    # Traefik dashboard
```

## 🏗️ Architecture

### Service Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Traefik Gateway                         │
│           (Reverse Proxy & Load Balancer)                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────┼───────────────────────────────────────┐
│                     │           Frontend Layer              │
│  ┌─────────────────┐│┌─────────────────┐ ┌─────────────────┐│
│  │ Rocket Fuel     │││  Hip-Hop        │ │   Grafana       ││
│  │ Girls :3000     │││  Universe :3001 │ │ Dashboard :3000 ││
│  └─────────────────┘│└─────────────────┘ └─────────────────┘│
└─────────────────────┼───────────────────────────────────────┘
                      │
┌─────────────────────┼───────────────────────────────────────┐
│                     │          Backend Services             │
│  ┌─────────────────┐│┌─────────────────┐ ┌─────────────────┐│
│  │ Meta-Geniusz    │││  Drift Money    │ │    GOK-AI       ││
│  │ Core :8805      │││  Engine :8801   │ │  MixTape :8802  ││
│  └─────────────────┘│└─────────────────┘ └─────────────────┘│
│  ┌─────────────────┐│                                       │
│  │ SpiralMind      ││                                       │
│  │ Nexus :8806     ││                                       │
│  └─────────────────┘│                                       │
└─────────────────────┼───────────────────────────────────────┘
                      │
┌─────────────────────┼───────────────────────────────────────┐
│                     │        Infrastructure Layer           │
│  ┌─────────────────┐│┌─────────────────┐ ┌─────────────────┐│
│  │ PostgreSQL      │││     Redis       │ │    Hardhat      ││
│  │ Database        │││     Cache       │ │  Blockchain     ││
│  └─────────────────┘│└─────────────────┘ └─────────────────┘│
│  ┌─────────────────┐│┌─────────────────┐ ┌─────────────────┐│
│  │  Prometheus     │││      Loki       │ │   Promtail      ││
│  │   Metrics       │││      Logs       │ │ Log Collector   ││
│  └─────────────────┘│└─────────────────┘ └─────────────────┘│
└─────────────────────┴───────────────────────────────────────┘
```

### Network Architecture

- **Network**: `migi_net` (172.20.0.0/16)
- **Gateway**: Traefik with automatic service discovery
- **SSL**: Let's Encrypt certificates (production)
- **Monitoring**: Prometheus + Grafana + Loki stack

## 📊 Monitoring & Observability

### Metrics Collection

- **Prometheus**: Metrics scraping from all services
- **Grafana**: Pre-configured dashboards
- **Custom Metrics**: Business logic tracking

### Log Aggregation

- **Loki**: Centralized log storage
- **Promtail**: Log collection from containers
- **Grafana**: Log visualization and searching

### Health Checks

All services include:
- HTTP health endpoints
- Docker health checks
- Dependency checks
- Automatic restart on failure

## 🔧 Configuration

### Environment Variables

Key configurations in `.env`:

```bash
# Domain & Network
DOMAIN=localhost
NODE_ENV=development

# Database
POSTGRES_DB=migi_ecosystem
POSTGRES_USER=migi
POSTGRES_PASSWORD=secure_password

# Authentication
JWT_SECRET=your_jwt_secret
NEXTAUTH_SECRET=your_nextauth_secret

# AI Services
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key

# Blockchain
BLOCKCHAIN_RPC_URL=http://hardhat:8545
DRIFT_PRIVATE_KEY=0x...
```

### Service Configuration

Each service can be configured through:
- Environment variables in `.env`
- Service-specific config files
- Docker Compose overrides

## 🧪 Development Workflow

### Local Development

1. **Start ecosystem**: `make dev-up`
2. **Code changes**: Edit files in original project directories
3. **Hot reload**: Most services support hot reload
4. **Restart if needed**: `make restart-service service=SERVICE_NAME`
5. **View logs**: `make logs-service service=SERVICE_NAME`

### Debugging

1. **Check service status**: `make status`
2. **View service logs**: `make logs-service service=SERVICE_NAME`
3. **Execute into container**: `make exec service=SERVICE_NAME`
4. **Check health**: `make health`

### Testing

```bash
# Run tests for all services
make test

# Run linting
make lint

# Update dependencies
make update-deps
```

## 🔒 Security

### Development Security

- Default passwords (change in production!)
- Local-only access
- No external exposure by default

### Production Security

- Strong passwords required
- SSL/TLS encryption
- Network isolation
- Regular security updates

## 🚀 Production Deployment

### Kubernetes (Recommended)

```bash
# Deploy to Kubernetes cluster
helm upgrade --install migi ./infra/k8s/charts -n migi --create-namespace
```

### Docker Swarm

```bash
# Deploy to Docker Swarm
docker stack deploy -c docker-compose.prod.yml migi
```

### Cloud Providers

Pre-configured for:
- AWS ECS/EKS
- Google Cloud Run/GKE  
- Azure Container Instances/AKS
- DigitalOcean App Platform

## 📦 Service Details

### Meta-Geniusz System
- **Port**: 8805
- **Type**: Node.js + Python hybrid
- **Purpose**: Central intelligence and consciousness engine
- **APIs**: Consciousness tracking, AI insights, user management

### Drift Money
- **Port**: 8801
- **Type**: Node.js backend
- **Purpose**: Economic engine and tokenization
- **APIs**: Token management, staking, rewards, market signals

### GOK-AI MixTape
- **Port**: 8802
- **Type**: Vite frontend + AI backend
- **Purpose**: AI services and intelligence layer
- **APIs**: AI processing, model interactions, analytics

### Rocket Fuel Girls
- **Port**: 3000
- **Type**: Next.js frontend
- **Purpose**: Main user interface and community platform
- **Features**: User dashboard, social features, integrations

### Hip-Hop Universe
- **Port**: 3001
- **Type**: Next.js frontend
- **Purpose**: Music platform and NFT marketplace
- **Features**: Music streaming, NFT trading, artist tools

### SpiralMind Nexus
- **Port**: 8806
- **Type**: Python FastAPI
- **Purpose**: Advanced analytics and data processing
- **APIs**: Data analysis, machine learning, reporting

## 🤝 Contributing

### Development Setup

1. Fork the repository
2. Clone your fork
3. Create feature branch
4. Make changes in respective service directories
5. Test with `make test`
6. Submit pull request

### Adding New Services

1. Create Dockerfile in service directory
2. Add service to `docker-compose.yml`
3. Update Traefik labels for routing
4. Add monitoring endpoints
5. Update documentation

## 🆘 Troubleshooting

### Common Issues

**Services not starting:**
```bash
# Check logs
make logs-service service=SERVICE_NAME

# Rebuild service
make rebuild-service service=SERVICE_NAME
```

**Database connection issues:**
```bash
# Check database status
make db-connect

# Reset database
make clean && make dev-up
```

**Port conflicts:**
```bash
# Check what's using ports
lsof -i :80
lsof -i :8080

# Change ports in .env file
```

**Memory issues:**
```bash
# Check Docker resources
docker system df

# Clean up
make clean
```

### Debug Mode

```bash
# Enable debug logging
export DEBUG=true
export VERBOSE_LOGGING=true
make dev-up
```

### Reset Everything

```bash
# Nuclear option - reset everything
make clean-all
make dev-up
```

## 📚 Documentation

- [Architecture Guide](./docs/ARCHITECTURE.md)
- [API Documentation](./docs/API.md)
- [Deployment Guide](./docs/DEPLOYMENT.md)
- [Contributing Guide](./docs/CONTRIBUTING.md)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Docker** for containerization
- **Traefik** for reverse proxy
- **Prometheus & Grafana** for monitoring
- **All contributors** to the Meta-Geniusz ecosystem

---

## 🎯 What's Next?

- [ ] Kubernetes Helm charts
- [ ] CI/CD pipeline integration
- [ ] Auto-scaling configuration
- [ ] Multi-environment support
- [ ] Advanced monitoring dashboards
- [ ] Performance optimization
- [ ] Security hardening
- [ ] Documentation improvements

---

**Made with ❤️ by the Meta-Geniusz Team**

*"One command to rule them all, one command to find them, one command to bring them all, and in the Docker bind them."*

🚀 **[Start your Meta-Geniusz ecosystem now!](https://github.com/sobieranskip95patryk/MIGI_UDE)**