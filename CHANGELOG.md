# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation following ADR-001 software publishing rules
  - Enhanced README.md with origin and ownership information
  - CHANGELOG.md for version history
  - CONTRIBUTING.md with development guidelines
  - Architecture documentation (overview, data-flow, file-structure)
  - How-to guides (create-your-first-query, configure-datasource, deploy-docker)
  - Reference documentation (rest-api, sql-syntax, configuration)
  - Runnable examples (basic-crud with test scripts)
- Documentation deduplication and cross-referencing
  - Removed ~172 lines of duplicate content
  - Added cross-references between related documentation
  - Established single source of truth for each concept

### Changed
- Updated README.md with proper attribution to Bürokratt and original repository
- Simplified component descriptions in file-structure.md with references to overview.md
- Condensed HikariCP configuration examples with references to configuration.md

## [0.0.1-SNAPSHOT] - 2025-10-08

### Added
- Initial development snapshot
- Basic microservice architecture
- Query controller for REST endpoints
- Datasource configuration management
- Heartbeat endpoint for health checks
- Global exception handling
- File-based SQL query loading
- Named parameter binding support

### Technical Details
- Spring Boot 3.2.5
- Java 17
- Maven build system
- JUnit 5 for testing
- Jacoco for code coverage
