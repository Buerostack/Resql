#!/usr/bin/env bash
set -euo pipefail

# Wait until Postgres is ready
until pg_isready -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${PGDATABASE}" >/dev/null 2>&1; do
  echo "waiting for postgres..."
  sleep 1
done

# Execute all .sql files in lexicographic order
find /sql -type f -name '*.sql' | sort | while read -r f; do
  echo ">> ${f}"
  psql -v ON_ERROR_STOP=1 -f "${f}"
done