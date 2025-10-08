# Configuration Reference

Complete reference for Resql configuration options.

## Configuration Files

### application.yml

Main configuration file location:
```
src/main/resources/application.yml
```

### Profile-Specific Configuration

- `application-dev.yml` - Development
- `application-prod.yml` - Production
- `application-test.yml` - Testing

Activate with:
```bash
java -jar sql-ms.war --spring.profiles.active=prod
```

## DataSource Configuration

### Single DataSource

```yaml
datasource:
  configs:
    - name: primary
      url: jdbc:postgresql://localhost:5432/mydb
      username: dbuser
      password: dbpass
      driver-class-name: org.postgresql.Driver
```

### Multiple DataSources

```yaml
datasource:
  configs:
    - name: primary
      url: jdbc:postgresql://primary-db:5432/app
      username: app_user
      password: ${DB_PRIMARY_PASSWORD}
      driver-class-name: org.postgresql.Driver
      hikari:
        maximum-pool-size: 20
        minimum-idle: 5

    - name: readonly
      url: jdbc:postgresql://replica-db:5432/app
      username: readonly_user
      password: ${DB_READONLY_PASSWORD}
      driver-class-name: org.postgresql.Driver
      hikari:
        maximum-pool-size: 10
        minimum-idle: 2

    - name: analytics
      url: jdbc:postgresql://analytics-db:5432/warehouse
      username: analytics_user
      password: ${DB_ANALYTICS_PASSWORD}
      driver-class-name: org.postgresql.Driver
```

### DataSource Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `name` | String | Required | Unique datasource identifier |
| `url` | String | Required | JDBC connection URL |
| `username` | String | Required | Database username |
| `password` | String | Required | Database password |
| `driver-class-name` | String | Auto | JDBC driver class |

## Connection Pool (HikariCP)

### Basic Pool Configuration

```yaml
datasource:
  configs:
    - name: primary
      url: jdbc:postgresql://localhost:5432/db
      username: user
      password: pass
      hikari:
        maximum-pool-size: 10
        minimum-idle: 2
        connection-timeout: 30000
        idle-timeout: 600000
        max-lifetime: 1800000
```

### HikariCP Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `maximum-pool-size` | Integer | 10 | Maximum pool size |
| `minimum-idle` | Integer | 10 | Minimum idle connections |
| `connection-timeout` | Long | 30000 | Connection timeout (ms) |
| `idle-timeout` | Long | 600000 | Idle timeout (ms) |
| `max-lifetime` | Long | 1800000 | Max connection lifetime (ms) |
| `connection-test-query` | String | null | Test query |
| `pool-name` | String | Auto | Pool name |
| `auto-commit` | Boolean | true | Auto-commit mode |
| `read-only` | Boolean | false | Read-only mode |

### Performance Tuning

**Low Traffic:**
```yaml
hikari:
  maximum-pool-size: 5
  minimum-idle: 1
  connection-timeout: 30000
```

**Medium Traffic:**
```yaml
hikari:
  maximum-pool-size: 20
  minimum-idle: 5
  connection-timeout: 30000
```

**High Traffic:**
```yaml
hikari:
  maximum-pool-size: 50
  minimum-idle: 10
  connection-timeout: 20000
  leak-detection-threshold: 60000
```

## Server Configuration

### Basic Server Settings

```yaml
server:
  port: 8080
  servlet:
    context-path: /api
  compression:
    enabled: true
    mime-types: application/json,text/plain
    min-response-size: 1024
```

### Server Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `server.port` | Integer | 8080 | HTTP port |
| `server.servlet.context-path` | String | / | Application context path |
| `server.compression.enabled` | Boolean | false | Enable gzip compression |
| `server.tomcat.max-threads` | Integer | 200 | Max request threads |
| `server.tomcat.accept-count` | Integer | 100 | Max queue size |

### Tomcat Configuration

```yaml
server:
  tomcat:
    max-threads: 200
    min-spare-threads: 10
    accept-count: 100
    max-connections: 10000
    connection-timeout: 20000
    max-http-form-post-size: 2097152
```

## Security Configuration

### Basic Authentication

```yaml
spring:
  security:
    user:
      name: admin
      password: ${ADMIN_PASSWORD}
```

### Security Properties

```yaml
security:
  # Disable security (not recommended for production)
  basic:
    enabled: false

  # Configure endpoints
  ignored: /heartbeat,/health
```

### CORS Configuration

```yaml
spring:
  web:
    cors:
      allowed-origins:
        - https://example.com
        - https://app.example.com
      allowed-methods:
        - GET
        - POST
        - PUT
        - DELETE
      allowed-headers: "*"
      allow-credentials: true
      max-age: 3600
```

## Logging Configuration

### Log Levels

```yaml
logging:
  level:
    root: INFO
    rig.sqlms: DEBUG
    org.springframework: WARN
    org.hibernate: WARN
    com.zaxxer.hikari: DEBUG
```

### Log File

```yaml
logging:
  file:
    name: /var/log/resql/application.log
    max-size: 10MB
    max-history: 30
    total-size-cap: 1GB
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
```

### JSON Logging

```yaml
logging:
  pattern:
    console: '{"timestamp":"%d{yyyy-MM-dd HH:mm:ss}","level":"%p","logger":"%c","message":"%m"}%n'
```

## OpenAPI / Swagger Configuration

### Swagger Settings

```yaml
springdoc:
  api-docs:
    path: /api-docs
    enabled: true
  swagger-ui:
    path: /swagger-ui.html
    enabled: true
    operationsSorter: method
    tagsSorter: alpha
```

### API Documentation

```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
    disable-swagger-default-url: true
  info:
    title: Resql API
    version: 1.0.0
    description: SQL-to-REST API
```

## Query Configuration

### SQL File Location

```yaml
resql:
  query:
    base-path: /app/sql
    file-pattern: "**/*.sql"
    reload-on-change: false
```

### Query Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `resql.query.base-path` | String | sql/ | SQL files directory |
| `resql.query.file-pattern` | String | **/*.sql | File matching pattern |
| `resql.query.reload-on-change` | Boolean | false | Auto-reload queries |
| `resql.query.cache-enabled` | Boolean | true | Cache queries in memory |

## Spring Boot Actuator

### Enable Actuator

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
      base-path: /actuator
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true
```

### Health Checks

```yaml
management:
  health:
    db:
      enabled: true
    diskspace:
      enabled: true
      threshold: 10GB
```

## OpenTelemetry Configuration

### Tracing

```yaml
otel:
  traces:
    exporter: logging
  metrics:
    exporter: logging
  instrumentation:
    spring-web:
      enabled: true
    jdbc:
      enabled: true
```

## Environment Variables

### Variable Substitution

Use `${VARIABLE_NAME}` syntax:

```yaml
datasource:
  configs:
    - name: primary
      url: ${DB_URL}
      username: ${DB_USER}
      password: ${DB_PASSWORD}
```

### Default Values

Provide fallback values:

```yaml
datasource:
  configs:
    - name: primary
      url: ${DB_URL:jdbc:postgresql://localhost:5432/defaultdb}
      username: ${DB_USER:postgres}
      password: ${DB_PASSWORD:postgres}
```

## Profile-Specific Configuration

### Development Profile

`application-dev.yml`:
```yaml
spring:
  profiles:
    active: dev

datasource:
  configs:
    - name: primary
      url: jdbc:h2:mem:devdb
      username: sa
      password:

logging:
  level:
    rig.sqlms: DEBUG

resql:
  query:
    reload-on-change: true
```

### Production Profile

`application-prod.yml`:
```yaml
spring:
  profiles:
    active: prod

datasource:
  configs:
    - name: primary
      url: ${DB_URL}
      username: ${DB_USER}
      password: ${DB_PASSWORD}
      hikari:
        maximum-pool-size: 50
        minimum-idle: 10

logging:
  level:
    rig.sqlms: INFO
  file:
    name: /var/log/resql/app.log

server:
  port: 8080
  compression:
    enabled: true
```

## Docker Environment Variables

### docker-compose.yml

```yaml
services:
  resql:
    environment:
      # Server
      - SERVER_PORT=8080

      # DataSource
      - DATASOURCE_CONFIGS_0_NAME=primary
      - DATASOURCE_CONFIGS_0_URL=jdbc:postgresql://db:5432/app
      - DATASOURCE_CONFIGS_0_USERNAME=user
      - DATASOURCE_CONFIGS_0_PASSWORD=pass

      # Pool
      - DATASOURCE_CONFIGS_0_HIKARI_MAXIMUM_POOL_SIZE=20
      - DATASOURCE_CONFIGS_0_HIKARI_MINIMUM_IDLE=5

      # Logging
      - LOGGING_LEVEL_RIG_SQLMS=DEBUG

      # JVM
      - JAVA_OPTS=-Xmx2g -Xms512m
```

## JVM Options

### Memory Settings

```bash
JAVA_OPTS=-Xmx2g -Xms512m -XX:MaxMetaspaceSize=256m
```

### Garbage Collection

```bash
JAVA_OPTS=-XX:+UseG1GC -XX:MaxGCPauseMillis=200
```

### Debug Mode

```bash
JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
```

## Complete Example

### application.yml

```yaml
# Server Configuration
server:
  port: 8080
  compression:
    enabled: true

# DataSource Configuration
datasource:
  configs:
    - name: primary
      url: ${DB_URL:jdbc:postgresql://localhost:5432/mydb}
      username: ${DB_USER:postgres}
      password: ${DB_PASSWORD:postgres}
      driver-class-name: org.postgresql.Driver
      hikari:
        maximum-pool-size: ${DB_POOL_SIZE:20}
        minimum-idle: 5
        connection-timeout: 30000

# Security
spring:
  security:
    user:
      name: ${ADMIN_USER:admin}
      password: ${ADMIN_PASSWORD:changeme}

# Logging
logging:
  level:
    root: INFO
    rig.sqlms: ${LOG_LEVEL:DEBUG}
  file:
    name: logs/application.log

# OpenAPI
springdoc:
  swagger-ui:
    enabled: true
    path: /swagger-ui.html

# Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
```

## Validation

### Check Configuration

```bash
# Validate YAML syntax
yamllint application.yml

# Test configuration
./mvnw spring-boot:run --spring.profiles.active=dev --debug
```

### View Active Configuration

```bash
curl http://localhost:8080/actuator/configprops
```
