#!/bin/sh
set -e

# https://docs.timescale.com/timescaledb/latest/how-to-guides/multinode-timescaledb/multinode-config/

# To achieve good query performance you need to enable partition-wise aggregation on the access node. This pushes down aggregation queries to the data nodes.
# https://www.postgresql.org/docs/12/runtime-config-query.html#enable_partitionwise_aggregate
sed -ri "s!^#?(enable_partitionwise_aggregate)\s*=.*!\1 = on!" /var/lib/postgresql/data/postgresql.conf
grep "enable_partitionwise_aggregate" /var/lib/postgresql/data/postgresql.conf

# JIT should be set to off on the access node as JIT currently doesn't work well with distributed queries.
# https://www.postgresql.org/docs/12/runtime-config-query.html#jit
sed -ri "s!^#?(jit)\s*=.*!\1 = off!" /var/lib/postgresql/data/postgresql.conf
grep "jit" /var/lib/postgresql/data/postgresql.conf

# https://docs.timescale.com/timescaledb/latest/how-to-guides/multinode-timescaledb/multinode-auth/
# https://docs.timescale.com/timescaledb/latest/how-to-guides/multinode-timescaledb/multinode-auth/#password-authentication

# Set password_encryption = 'scram-sha-256' in postgresql.conf on the access node.
sed -ri "s!^#?(password_encryption)\s*=.*!\1 = 'scram-sha-256'!" /var/lib/postgresql/data/postgresql.conf
grep "password_encryption" /var/lib/postgresql/data/postgresql.conf

# Append to data/passfile *:*:*:ROLE:ROLE_PASSWORD
# This file stores the passwords for each role that the access node connects to on the data nodes.
echo "*:*:*:postgres:password">>/var/lib/postgresql/data/passfile
chmod 0600 /var/lib/postgresql/data/passfile

# Add "host  all  all  ACCESS_NODE_IP  scram-sha-256" pg_hba.conf on the data nodes.
# Skipped. Using default "host  all  all  all  scram-sha-256" for now.
