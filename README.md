# Resql

A lightweight, generic REST API microservice that transforms SQL files into HTTP endpoints with zero boilerplate.

**Maintained by:** Architecture Team
**Status:** Draft (v0.0.1-SNAPSHOT)

## About

Resql is a Spring Boot-based microservice that automatically converts `.sql` files in a directory into REST endpoints. Instead of writing controllers, services, and repositories for every database query, you simply write SQL files and Resql exposes them as REST APIs with automatic parameter binding, multiple datasource support, and OpenTelemetry instrumentation.

**Key Features:**
- **File-based API creation**: `.sql` files automatically become REST endpoints
- **Multi-datasource routing**: Support for multiple database connections with runtime selection
- **Security built-in**: Spring Security integration for authentication/authorization
- **Zero-code REST APIs**: No Java code needed for basic CRUD operations
- **OpenTelemetry ready**: Distributed tracing support out of the box
- **PostgreSQL & H2 support**: Production PostgreSQL and testing H2 databases

## Quick Start

**Time to first API: < 5 minutes**

### Prerequisites
- Java 17+
- Maven 3.6+
- PostgreSQL (or use embedded H2 for testing)

### Run with Docker

```bash
docker-compose up
```

The service will be available at `http://localhost:8080`

### Run locally

```bash
./mvnw spring-boot:run
```

## Installation

### 1. Clone and build

```bash
git clone <repository-url>
cd Resql
./mvnw clean package
```

### 2. Configure datasources

Create an `application.yml` or use environment variables:

```yaml
datasource:
  configs:
    - name: primary
      url: jdbc:postgresql://localhost:5432/mydb
      username: user
      password: pass
```

### 3. Add SQL files

Place `.sql` files in the configured directory (default: `sql/`):

```sql
-- sql/users/get-all-users.sql
SELECT * FROM users WHERE status = :status;
```

### 4. Call your API

```bash
curl -X POST http://localhost:8080/api/query/users/get-all-users \
  -H "Content-Type: application/json" \
  -d '{"status": "active"}'
```

## Basic Usage

### Creating Endpoints

Each `.sql` file becomes an endpoint:
- **File path**: `sql/customers/find-by-email.sql`
- **Endpoint**: `POST /api/query/customers/find-by-email`

### Parameter Binding

Use named parameters in SQL with `:paramName` syntax:

```sql
SELECT id, name, email
FROM customers
WHERE email = :email AND status = :status;
```

Call with JSON body:
```json
{
  "email": "user@example.com",
  "status": "active"
}
```

### Multi-datasource Support

Specify datasource in request header:
```bash
curl -X POST http://localhost:8080/api/query/my-query \
  -H "X-Datasource: secondary" \
  -H "Content-Type: application/json"
```

## Documentation

- [Architecture Overview](docs/architecture/overview.md) - System design and components
- [Data Flow](docs/architecture/data-flow.md) - Request processing pipeline
- [File Structure](docs/architecture/file-structure.md) - Project organization
- [How-to Guides](docs/how-to/) - Step-by-step tutorials
- [API Reference](docs/reference/) - Detailed API documentation
- [Examples](examples/) - Runnable code examples

### API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI Spec**: http://localhost:8080/v3/api-docs

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines, code standards, and how to submit pull requests.

## License

See [LICENSE](LICENSE) for license information.
