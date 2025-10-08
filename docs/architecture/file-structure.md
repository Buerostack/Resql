# File Structure

This document describes the organization of the Resql codebase and how files relate to system functionality.

## Project Overview

```
Resql/
├── src/                    # Source code
├── sql/                    # SQL query files (runtime)
├── docs/                   # Documentation
├── examples/               # Runnable examples
├── templates/              # Configuration templates
├── .github/                # GitHub workflows
├── pom.xml                 # Maven configuration
└── docker-compose.yml      # Docker setup
```

## Source Code Structure

### Main Application Code

```
src/main/java/rig/sqlms/
├── SqlmsApplication.java           # Spring Boot entry point
├── H2Conf.java                     # H2 test database config
├── GlobalExceptionHandler.java    # Centralized error handling
│
├── controller/                     # REST API Controllers
│   ├── QueryController.java       # Main query execution endpoint
│   ├── DataSourceController.java  # DataSource management
│   └── HeartBeatController.java   # Health check endpoint
│
├── service/                        # Business Logic
│   ├── QueryService.java          # Query execution orchestration
│   ├── SavedQueryService.java     # SQL file loading/caching
│   ├── HeartBeatService.java      # Health check logic
│   └── ServerInfoService.java     # Server metadata
│
├── datasource/                     # Database Connection Management
│   ├── DataSourceConfiguration.java      # Spring datasource beans
│   ├── RoutingDataSource.java           # Dynamic datasource routing
│   ├── DataSourceContextHolder.java     # ThreadLocal context
│   └── ResqlJdbcTemplate.java          # Custom JDBC template
│
├── config/                         # Spring Configuration
│   ├── SecurityConfiguration.java       # Security settings
│   ├── RestConfiguration.java          # REST/CORS config
│   ├── PackageInfoConfiguration.java   # Build info
│   └── PackageVersionConfiguration.java # Version tracking
│
├── properties/                     # Configuration Properties
│   └── DataSourceConfigProperties.java  # Datasource configs
│
├── model/                          # Domain Models
│   └── SavedQuery.java            # Cached query representation
│
├── dto/                            # Data Transfer Objects
│   └── HeartBeatInfo.java         # Health check response
│
└── exception/                      # Custom Exceptions
    ├── ResqlRuntimeException.java          # Base exception
    ├── InvalidQueryException.java          # Bad SQL query
    ├── InvalidDirectoryException.java      # Bad file path
    └── UnknownDataSourceNameException.java # Unknown datasource
```

### Test Code Structure

```
src/test/java/rig/sqlms/
├── BaseIntegrationTest.java                        # Test base class
│
└── controller/                                     # Integration Tests
    ├── QueryControllerIntegrationTest.java        # Query endpoint tests
    ├── DataSourceControllerIntegrationTest.java   # Datasource tests
    └── HeartBeatControllerIntegrationTest.java    # Health check tests
```

### Resources

```
src/main/resources/
├── application.yml              # Default configuration
├── application-dev.yml          # Development config
├── application-prod.yml         # Production config
├── logback-spring.xml          # Logging configuration
└── META-INF/
    └── spring.factories        # Auto-configuration
```

## SQL Query Files

### Structure

```
sql/
├── {project}/                  # Project namespace
│   ├── POST/                   # POST endpoint queries
│   │   └── {query-name}.sql
│   └── GET/                    # GET endpoint queries
│       └── {query-name}.sql
│
└── 10-schema/                  # Example: Schema migrations
    └── 010-create-table.sql
```

### File Naming Convention

**Pattern:**
```
sql/{project}/{method}/{path/to/query}.sql
```

**Example:**
```
sql/api/POST/users/find-by-email.sql
→ Endpoint: POST /api/users/find-by-email
```

### Query File Format

```sql
-- datasource: primary
-- description: Find user by email address
SELECT id, name, email, created_at
FROM users
WHERE email = :email
  AND status = :status;
```

**Metadata Headers:**
- `datasource:` - Target database connection
- `description:` - Query purpose (optional)
- `author:` - Query creator (optional)

## Documentation Structure

```
docs/
├── architecture/               # Architecture Documentation
│   ├── overview.md            # System design & components
│   ├── data-flow.md           # Request processing flow
│   └── file-structure.md      # This file
│
├── how-to/                     # Step-by-step Guides
│   ├── create-query.md        # How to add a new query
│   ├── configure-datasource.md # DataSource setup
│   └── deploy-docker.md       # Deployment guide
│
└── reference/                  # API Reference
    ├── rest-api.md            # REST endpoint docs
    ├── configuration.md       # Config properties
    └── sql-syntax.md          # SQL file syntax
```

## Examples Structure

```
examples/
├── basic-crud/                 # Basic CRUD operations
│   ├── README.md
│   ├── queries/
│   └── test.sh
│
├── multi-datasource/           # Multiple databases
│   ├── README.md
│   ├── docker-compose.yml
│   └── queries/
│
└── batch-operations/           # Batch processing
    ├── README.md
    └── example.sh
```

## Configuration Files

### Root Configuration

```
Resql/
├── pom.xml                    # Maven dependencies & plugins
├── docker-compose.yml         # Local development setup
├── docker-compose.override.yml # Local overrides
├── Dockerfile                 # Production image
├── Dockerfile.dev             # Development image
├── .env                       # Environment variables
└── release.env                # Release configuration
```

### Build Scripts

```
Resql/
├── mvnw                       # Maven wrapper (Unix)
├── mvnw.cmd                   # Maven wrapper (Windows)
├── bump-version.sh            # Version bumping script
├── sync-version.sh            # Version synchronization
└── generate-changelog.sh      # Changelog generation
```

### CI/CD

```
.github/
└── workflows/
    ├── build.yml              # Build & test workflow
    ├── release.yml            # Release automation
    └── docker.yml             # Docker image builds
```

## Key File Descriptions

### Entry Point

**SqlmsApplication.java**
- Spring Boot main class
- Excludes default datasource auto-configuration
- Servlet initializer for WAR deployment

### Controllers

**QueryController.java** (Lines: 75)
- Maps `/{project}/**` to query execution
- Supports GET, POST, and batch operations
- Extracts query name from URL path
- Parameter binding from request body/query

**DataSourceController.java**
- Lists configured datasources
- Health check per datasource
- Connection pool statistics

**HeartBeatController.java**
- `/heartbeat` endpoint
- Application health status
- Build version information

### Services

**QueryService.java** (Lines: 57)
- Core business logic
- Loads SQL queries
- Sets datasource context
- Executes queries with parameters

**SavedQueryService.java**
- File system scanning
- Query caching
- Metadata extraction
- Path-to-endpoint mapping

### DataSource Management

**RoutingDataSource.java**
- Extends AbstractRoutingDataSource
- Routes to datasource based on ThreadLocal
- Enables multi-tenancy

**DataSourceContextHolder.java**
- ThreadLocal storage
- Set datasource for current request
- Cleared after request completion

**ResqlJdbcTemplate.java**
- Custom JDBC template
- Named parameter support (`:paramName`)
- Automatic result mapping
- Handles SELECT and DML

### Configuration

**DataSourceConfiguration.java**
- Creates datasource beans
- HikariCP pool configuration
- Transaction manager setup
- Multiple datasource support

**SecurityConfiguration.java**
- Spring Security setup
- Authentication configuration
- Endpoint protection rules
- CORS configuration

## Build Artifacts

### Maven Output

```
target/
├── sql-ms.war                 # Deployable WAR file
├── classes/                   # Compiled classes
├── test-classes/              # Test classes
├── site/
│   └── jacoco/               # Code coverage reports
└── surefire-reports/         # Test results
```

### Docker Images

```
resql:latest                   # Production image
resql:dev                      # Development image with hot reload
```

## Configuration Loading Order

1. `src/main/resources/application.yml` (defaults)
2. `src/main/resources/application-{profile}.yml`
3. Environment variables
4. `.env` file (development)
5. Command-line arguments

**Example:**
```bash
# Override with environment variable
export DATASOURCE_CONFIGS_0_URL=jdbc:postgresql://localhost/db

# Override with profile
./mvnw spring-boot:run -Dspring.profiles.active=dev

# Override with command-line
./mvnw spring-boot:run --datasource.configs[0].url=jdbc:...
```

## Development Files

### Local Development

```
.husky/                        # Git hooks
├── pre-commit                 # Run tests before commit
└── commit-msg                # Validate commit message

.mvn/                          # Maven wrapper config
└── wrapper/
    └── maven-wrapper.properties
```

### IDE Configuration

```
.idea/                         # IntelliJ IDEA
.vscode/                       # Visual Studio Code
.eclipse/                      # Eclipse
```

## Deployment Structure

### Standalone Deployment

```
deployment/
├── sql-ms.war
├── application.yml            # External config
└── sql/                       # Query files
    └── {project}/
```

### Docker Deployment

```
docker-compose.yml
├── service: resql
├── volumes:
│   ├── ./sql:/app/sql
│   └── ./config:/app/config
└── networks:
    └── backend
```

### Kubernetes Deployment

```
k8s/
├── deployment.yaml            # Deployment spec
├── service.yaml               # Service definition
├── configmap.yaml             # Configuration
└── secret.yaml                # Credentials
```

## File Conventions

### Java Files
- Package structure follows domain logic
- One public class per file
- File name matches class name
- Lombok annotations preferred

### SQL Files
- `.sql` extension required
- UTF-8 encoding
- Unix line endings (LF)
- Metadata in comment header

### Documentation
- Markdown format (`.md`)
- Mermaid for diagrams
- Code examples in fenced blocks
- Relative links for navigation

### Configuration
- YAML for Spring configuration
- `.env` for local development
- `.properties` for Java-style config
