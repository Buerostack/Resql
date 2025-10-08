# How to Deploy with Docker

This guide covers deploying Resql using Docker and Docker Compose.

## Quick Start with Docker Compose

### 1. Create docker-compose.yml

```yaml
version: '3.8'

services:
  resql:
    image: resql:latest
    ports:
      - "8080:8080"
    environment:
      - DATASOURCE_CONFIGS_0_NAME=primary
      - DATASOURCE_CONFIGS_0_URL=jdbc:postgresql://postgres:5432/myapp
      - DATASOURCE_CONFIGS_0_USERNAME=appuser
      - DATASOURCE_CONFIGS_0_PASSWORD=apppass
    volumes:
      - ./sql:/app/sql
    depends_on:
      - postgres
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppass
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

volumes:
  postgres-data:
```

### 2. Create SQL Directory

```bash
mkdir -p sql/api/POST
```

### 3. Start Services

```bash
docker-compose up -d
```

### 4. Verify Deployment

```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f resql

# Test health endpoint
curl http://localhost:8080/heartbeat
```

## Building Docker Image

### Build from Source

```bash
# Clone repository
git clone <repository-url>
cd Resql

# Build with Maven
./mvnw clean package

# Build Docker image
docker build -t resql:latest .
```

### Dockerfile

```dockerfile
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy WAR file
COPY target/sql-ms.war /app/app.war

# Create directories
RUN mkdir -p /app/sql /app/config

# Expose port
EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "/app/app.war"]
```

### Multi-stage Build

```dockerfile
# Build stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /build/target/sql-ms.war /app/app.war
RUN mkdir -p /app/sql
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.war"]
```

Build:
```bash
docker build -t resql:latest -f Dockerfile .
```

## Running Standalone Container

### Basic Run

```bash
docker run -d \
  --name resql \
  -p 8080:8080 \
  -e DATASOURCE_CONFIGS_0_NAME=primary \
  -e DATASOURCE_CONFIGS_0_URL=jdbc:postgresql://host.docker.internal:5432/db \
  -e DATASOURCE_CONFIGS_0_USERNAME=user \
  -e DATASOURCE_CONFIGS_0_PASSWORD=pass \
  -v $(pwd)/sql:/app/sql \
  resql:latest
```

### With External Config

```bash
docker run -d \
  --name resql \
  -p 8080:8080 \
  -v $(pwd)/application.yml:/app/config/application.yml \
  -v $(pwd)/sql:/app/sql \
  resql:latest \
  --spring.config.location=/app/config/application.yml
```

## Production Deployment

### docker-compose.prod.yml

```yaml
version: '3.8'

services:
  resql:
    image: resql:${VERSION:-latest}
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DATASOURCE_CONFIGS_0_NAME=primary
      - DATASOURCE_CONFIGS_0_URL=${DB_URL}
      - DATASOURCE_CONFIGS_0_USERNAME=${DB_USER}
      - DATASOURCE_CONFIGS_0_PASSWORD=${DB_PASSWORD}
      - JAVA_OPTS=-Xmx2g -Xms512m
    volumes:
      - ./sql:/app/sql:ro
      - resql-logs:/app/logs
    secrets:
      - db_password
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/heartbeat"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - backend
      - frontend

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
    secrets:
      - db_password
    networks:
      - backend
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - resql
    networks:
      - frontend
    restart: unless-stopped

volumes:
  postgres-data:
  resql-logs:

secrets:
  db_password:
    file: ./secrets/db_password.txt

networks:
  backend:
    driver: bridge
  frontend:
    driver: bridge
```

### .env File

```bash
VERSION=1.0.0
DB_URL=jdbc:postgresql://postgres:5432/myapp
DB_NAME=myapp
DB_USER=appuser
DB_PASSWORD=changeme
```

### Deploy

```bash
docker-compose -f docker-compose.prod.yml up -d
```

## Environment Variables

### Application Configuration

```bash
# Server
SERVER_PORT=8080
SERVER_SERVLET_CONTEXT_PATH=/api

# DataSource
DATASOURCE_CONFIGS_0_NAME=primary
DATASOURCE_CONFIGS_0_URL=jdbc:postgresql://db:5432/app
DATASOURCE_CONFIGS_0_USERNAME=user
DATASOURCE_CONFIGS_0_PASSWORD=pass

# Connection Pool
DATASOURCE_CONFIGS_0_HIKARI_MAXIMUM_POOL_SIZE=20
DATASOURCE_CONFIGS_0_HIKARI_MINIMUM_IDLE=5

# Logging
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_RIG_SQLMS=DEBUG

# Security
SECURITY_USER_NAME=admin
SECURITY_USER_PASSWORD=changeme
```

### JVM Options

```bash
JAVA_OPTS=-Xmx2g -Xms512m -XX:+UseG1GC
```

## Volume Mounts

### SQL Files

```yaml
volumes:
  - ./sql:/app/sql:ro  # Read-only in production
```

### Logs

```yaml
volumes:
  - ./logs:/app/logs
```

### External Config

```yaml
volumes:
  - ./config:/app/config:ro
```

## Networking

### Bridge Network

```yaml
networks:
  backend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
```

### Host Network

```yaml
services:
  resql:
    network_mode: host
```

## Health Checks

### Docker Health Check

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/heartbeat"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Manual Check

```bash
docker inspect --format='{{.State.Health.Status}}' resql
```

## Logging

### JSON File Driver

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Syslog

```yaml
logging:
  driver: "syslog"
  options:
    syslog-address: "tcp://192.168.0.100:514"
```

### View Logs

```bash
# Follow logs
docker-compose logs -f resql

# Last 100 lines
docker-compose logs --tail=100 resql

# Specific time range
docker-compose logs --since="2024-01-01T00:00:00"
```

## Secrets Management

### Docker Secrets

```yaml
secrets:
  db_password:
    external: true

services:
  resql:
    secrets:
      - db_password
    environment:
      - DATASOURCE_CONFIGS_0_PASSWORD_FILE=/run/secrets/db_password
```

Create secret:
```bash
echo "supersecret" | docker secret create db_password -
```

### Environment File

```yaml
services:
  resql:
    env_file:
      - .env.prod
```

## Reverse Proxy (Nginx)

### nginx.conf

```nginx
upstream resql_backend {
    server resql:8080;
}

server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://resql_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Scaling

### Horizontal Scaling

```yaml
services:
  resql:
    deploy:
      replicas: 3
```

### Load Balancing

```yaml
services:
  nginx:
    depends_on:
      - resql
    environment:
      - BACKEND_SERVERS=resql:8080
```

## Monitoring

### Prometheus Metrics

Add to docker-compose.yml:

```yaml
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

### Grafana Dashboard

```yaml
services:
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs resql

# Inspect container
docker inspect resql

# Check entrypoint
docker run --rm --entrypoint sh resql:latest
```

### Database Connection Issues

```bash
# Test from container
docker exec -it resql sh
nc -zv postgres 5432

# Check DNS resolution
docker exec -it resql nslookup postgres
```

### Permission Issues

```bash
# Fix volume permissions
docker exec -it resql chown -R 1000:1000 /app/sql
```

## Cleanup

```bash
# Stop and remove containers
docker-compose down

# Remove volumes
docker-compose down -v

# Remove images
docker rmi resql:latest
```

## Next Steps

- [Configure DataSource](configure-datasource.md) - Database configuration
- [Create Your First Query](create-your-first-query.md) - Write your first SQL query
- [Configuration Reference](../reference/configuration.md) - Complete configuration options
- [Architecture Overview](../architecture/overview.md) - System design and components
