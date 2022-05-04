FROM timescale/timescaledb:latest-pg14

COPY ./schema.bak /schema.bak
COPY ./scripts/tsdb-import.sh /docker-entrypoint-initdb.d/002_tsdb_import.sh
