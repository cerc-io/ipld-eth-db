#!/bin/sh
set -e

# Default command is "goose up"
if [[ $# -eq 0 ]]; then
  set -- "up"
fi

# Construct the connection string for postgres
VDB_PG_CONNECT=postgresql://$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_HOSTNAME:$DATABASE_PORT/$DATABASE_NAME?sslmode=disable

# Run the DB migrations
set -x
exec ./goose -dir migrations postgres "$VDB_PG_CONNECT" "$@"
