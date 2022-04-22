FROM timescale/timescaledb:latest-pg14

COPY ./schema.sql /docker-entrypoint-initdb.d/init.sql