# How to Configure DataSources

This guide explains how to configure database connections in Resql.

## Configuration Methods

Resql supports multiple ways to configure datasources:

1. YAML configuration files
2. Environment variables
3. External configuration

## Method 1: YAML Configuration

### Single DataSource

Edit `src/main/resources/application.yml`:

```yaml
datasource:
  configs:
    - name: primary
      url: jdbc:postgresql://localhost:5432/mydb
      username: dbuser
      password: dbpass
      driver-class-name: org.postgresql.Driver
      hikari:
        maximum-pool-size: 10
        minimum-idle: 2
        connection-timeout: 30000
```

### Multiple DataSources

```yaml
datasource:
  configs:
    - name: primary
      url: jdbc:postgresql://prod-db:5432/app_db
      username: app_user
      password: ${DB_PRIMARY_PASSWORD}
      driver-class-name: org.postgresql.Driver

    - name: analytics
      url: jdbc:postgresql://analytics-db:5432/analytics
      username: analytics_user
      password: ${DB_ANALYTICS_PASSWORD}
      driver-class-name: org.postgresql.Driver
      hikari:
        maximum-pool-size: 5

    - name: cache
      url: jdbc:h2:mem:cache
      driver-class-name: org.h2.Driver
```

## Method 2: Environment Variables

Set environment variables following Spring Boot conventions:

```bash
# Primary datasource
export DATASOURCE_CONFIGS_0_NAME=primary
export DATASOURCE_CONFIGS_0_URL=jdbc:postgresql://localhost:5432/mydb
export DATASOURCE_CONFIGS_0_USERNAME=dbuser
export DATASOURCE_CONFIGS_0_PASSWORD=secret123

# Secondary datasource
export DATASOURCE_CONFIGS_1_NAME=secondary
export DATASOURCE_CONFIGS_1_URL=jdbc:postgresql://localhost:5432/otherdb
export DATASOURCE_CONFIGS_1_USERNAME=otheruser
export DATASOURCE_CONFIGS_1_PASSWORD=secret456
```

## Method 3: External Configuration File

Create an external `application.yml`:

```bash
# Create config directory
mkdir -p /etc/resql

# Create configuration
cat > /etc/resql/application.yml <<EOF
datasource:
  configs:
    - name: primary
      url: jdbc:postgresql://localhost:5432/mydb
      username: dbuser
      password: dbpass
EOF

# Run with external config
java -jar sql-ms.war --spring.config.location=/etc/resql/application.yml
```

## DataSource Properties

### Required Properties

| Property | Description | Example |
|----------|-------------|---------|
| `name` | Unique identifier | `primary` |
| `url` | JDBC connection URL | `jdbc:postgresql://host:5432/db` |
| `username` | Database user | `app_user` |
| `password` | Database password | `secret123` |

### Optional Properties

| Property | Description | Default |
|----------|-------------|---------|
| `driver-class-name` | JDBC driver class | Auto-detected |
| `hikari.maximum-pool-size` | Max connections | 10 |
| `hikari.minimum-idle` | Min idle connections | 2 |
| `hikari.connection-timeout` | Timeout (ms) | 30000 |
| `hikari.idle-timeout` | Idle timeout (ms) | 600000 |
| `hikari.max-lifetime` | Max connection lifetime (ms) | 1800000 |

## Supported Databases

### PostgreSQL

```yaml
- name: postgres-db
  url: jdbc:postgresql://hostname:5432/database
  username: user
  password: pass
  driver-class-name: org.postgresql.Driver
```

**Connection URL Format:**
```
jdbc:postgresql://host:port/database?param=value
```

**Common Parameters:**
- `ssl=true` - Enable SSL
- `sslmode=require` - Require SSL
- `currentSchema=myschema` - Default schema

### H2 (In-Memory)

```yaml
- name: h2-memory
  url: jdbc:h2:mem:testdb
  driver-class-name: org.h2.Driver
```

### H2 (File-Based)

```yaml
- name: h2-file
  url: jdbc:h2:file:/data/appdb
  driver-class-name: org.h2.Driver
```

## Using DataSources in Queries

### Default DataSource

If only one datasource is configured, it's used automatically:

```sql
SELECT * FROM users WHERE id = :id;
```

### Explicit DataSource

Specify datasource in query file:

```sql
-- datasource: analytics
SELECT COUNT(*) as total_users FROM users;
```

### Runtime DataSource Selection

Use header to override datasource:

```bash
curl -X POST http://localhost:8080/api/query/users/list \
  -H "X-Datasource: secondary" \
  -H "Content-Type: application/json"
```

## Connection Pool Configuration

Resql uses HikariCP for connection pooling. You can configure pool settings for each datasource:

```yaml
datasource:
  configs:
    - name: primary
      url: jdbc:postgresql://db:5432/app
      username: user
      password: pass
      hikari:
        maximum-pool-size: 20
        minimum-idle: 5
```

For complete HikariCP configuration options and performance tuning recommendations, see the [Configuration Reference](../reference/configuration.md#connection-pool-hikaricp).

## Docker Configuration

### docker-compose.yml

```yaml
version: '3.8'

services:
  resql:
    image: resql:latest
    environment:
      - DATASOURCE_CONFIGS_0_NAME=primary
      - DATASOURCE_CONFIGS_0_URL=jdbc:postgresql://postgres:5432/appdb
      - DATASOURCE_CONFIGS_0_USERNAME=appuser
      - DATASOURCE_CONFIGS_0_PASSWORD=apppass
    depends_on:
      - postgres

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppass
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

### Using Secrets

```yaml
services:
  resql:
    image: resql:latest
    environment:
      - DATASOURCE_CONFIGS_0_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

## Security Best Practices

### 1. Never Commit Passwords

Use environment variables or secrets:

```yaml
datasource:
  configs:
    - name: primary
      password: ${DB_PASSWORD}  # From environment
```

### 2. Use Read-Only Users

For analytics or reporting queries:

```sql
-- In PostgreSQL
CREATE USER readonly_user WITH PASSWORD 'secret';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;
```

```yaml
- name: reporting
  username: readonly_user
  password: ${READONLY_PASSWORD}
```

### 3. Enable SSL

```yaml
- name: secure-db
  url: jdbc:postgresql://db:5432/app?ssl=true&sslmode=require
```

### 4. Connection Encryption

```yaml
- name: encrypted
  url: jdbc:postgresql://db:5432/app?ssl=true&sslmode=verify-full&sslcert=/path/to/cert.pem
```

## Troubleshooting

### Connection Refused

**Error:** `Connection refused`

**Solutions:**
- Verify database is running
- Check hostname and port
- Verify firewall rules
- Check database accepts remote connections

### Authentication Failed

**Error:** `FATAL: password authentication failed`

**Solutions:**
- Verify username and password
- Check `pg_hba.conf` on PostgreSQL
- Ensure user has database access

### Pool Exhausted

**Error:** `Connection pool exhausted`

**Solutions:**
- Increase `maximum-pool-size`
- Reduce `connection-timeout`
- Check for connection leaks
- Monitor active connections

### Driver Not Found

**Error:** `Driver class not found`

**Solutions:**
- Add JDBC driver to `pom.xml`
- Verify driver version compatibility
- Check `driver-class-name` spelling

## Testing Connection

### Health Check Endpoint

```bash
curl http://localhost:8080/datasources
```

Response:
```json
[
  {
    "name": "primary",
    "status": "UP",
    "activeConnections": 3,
    "idleConnections": 7
  }
]
```

### Manual Test Query

```bash
curl -X POST http://localhost:8080/api/test \
  -H "Content-Type: application/json" \
  -d '{}'
```

With test query in `sql/api/POST/test.sql`:
```sql
-- datasource: primary
SELECT 1 as test;
```

## Next Steps

- [Create Your First Query](create-your-first-query.md) - Get started with SQL queries
- [Deploy with Docker](deploy-docker.md) - Docker deployment guide
- [Configuration Reference](../reference/configuration.md) - Complete configuration options
- [Architecture Overview](../architecture/overview.md) - Understanding datasource routing
