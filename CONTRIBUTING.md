# Contributing to Resql

Thank you for your interest in contributing to Resql! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

- Be respectful and professional
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Maintain high code quality standards

## Getting Started

### Prerequisites

See [Prerequisites](README.md#prerequisites) in the main README for required software and tools.

### Development Setup

1. Fork and clone the repository:
```bash
git clone https://github.com/your-username/Resql.git
cd Resql
```

2. Build and run tests:
```bash
./mvnw clean install
```

For detailed installation and setup instructions, see the [Installation](README.md#installation) section in the main README.

## Development Workflow

### Branching Strategy

- `main` - stable production-ready code
- `feature/*` - new features
- `bugfix/*` - bug fixes
- `hotfix/*` - urgent production fixes

### Making Changes

1. Create a feature branch:
```bash
git checkout -b feature/your-feature-name
```

2. Make your changes following code standards

3. Write or update tests

4. Ensure all tests pass:
```bash
./mvnw verify
```

5. Commit with clear messages:
```bash
git commit -m "Add feature: brief description"
```

## Code Standards

### Java Code Style

- Follow standard Java naming conventions
- Use meaningful variable and method names
- Keep methods focused and single-purpose
- Maximum line length: 120 characters
- Use Lombok annotations to reduce boilerplate
- Add JavaDoc for public APIs

### Testing Requirements

- Write unit tests for all new functionality
- Maintain or improve code coverage (target: 80%+)
- Use integration tests for controller endpoints
- Mock external dependencies in unit tests
- Use H2 in-memory database for test isolation

### Code Organization

```
src/
├── main/java/rig/sqlms/
│   ├── controller/     # REST controllers
│   ├── service/        # Business logic
│   ├── datasource/     # Database configuration
│   ├── config/         # Spring configuration
│   ├── model/          # Domain models
│   ├── dto/            # Data transfer objects
│   └── exception/      # Custom exceptions
└── test/java/rig/sqlms/
    └── controller/     # Integration tests
```

## Pull Request Process

### Before Submitting

- [ ] All tests pass locally
- [ ] Code follows project style guidelines
- [ ] New tests added for new functionality
- [ ] Documentation updated if needed
- [ ] Changelog updated with your changes
- [ ] No merge conflicts with main branch

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How to test the changes

## Related Issues
Fixes #(issue number)
```

### Review Process

1. At least one approval required
2. All CI checks must pass
3. Code coverage must not decrease
4. No unresolved review comments

## Testing Guidelines

### Unit Tests

```java
@Test
void testQueryExecution() {
    // Arrange
    QueryService service = new QueryService();

    // Act
    Result result = service.executeQuery("test-query", params);

    // Assert
    assertNotNull(result);
    assertEquals(expectedValue, result.getValue());
}
```

### Integration Tests

```java
@SpringBootTest
class QueryControllerIntegrationTest extends BaseIntegrationTest {
    @Test
    void testEndpointReturnsData() throws Exception {
        mockMvc.perform(post("/api/query/test")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"param\":\"value\"}"))
            .andExpect(status().isOk());
    }
}
```

## Running Quality Checks

### Code Coverage

```bash
./mvnw clean test jacoco:report
# View report at target/site/jacoco/index.html
```

### Static Analysis

```bash
./mvnw sonar:sonar
```

## Documentation

### When to Update Documentation

- Adding new features
- Changing existing APIs
- Modifying configuration options
- Adding new SQL file patterns

### Documentation Structure

- `README.md` - Quick start and overview
- `docs/architecture/` - System design
- `docs/how-to/` - Step-by-step guides
- `docs/reference/` - Detailed API docs
- `examples/` - Runnable examples

## Getting Help

- Open an issue for bugs or feature requests
- Ask questions in discussions
- Check existing issues before creating new ones

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
