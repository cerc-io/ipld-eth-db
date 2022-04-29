#!/bin/sh
set -e

# https://docs.timescale.com/timescaledb/latest/how-to-guides/configuration/timescaledb-config/#timescaledb-last-tuned-string
# https://docs.timescale.com/timescaledb/latest/how-to-guides/multi-node-setup/required-configuration/

# It is necessary to change the parameter max_prepared_transactions to a non-zero value ('150' is recommended).
# https://www.postgresql.org/docs/12/runtime-config-resource.html#max_prepared_transactions
sed -ri "s!^#?(max_prepared_transactions)\s*=.*!\1 = 150!" /var/lib/postgresql/data/postgresql.conf
grep "max_prepared_transactions" /var/lib/postgresql/data/postgresql.conf

# Statement timeout should be disabled on the data nodes and managed through the access node configuration if desired.
# https://www.postgresql.org/docs/12/runtime-config-client.html#statement_timeout
sed -ri "s!^#?(statement_timeout)\s*=.*!\1 = 0!" /var/lib/postgresql/data/postgresql.conf
grep "statement_timeout" /var/lib/postgresql/data/postgresql.conf

# https://docs.timescale.com/timescaledb/latest/how-to-guides/multinode-timescaledb/multinode-auth/
# https://docs.timescale.com/timescaledb/latest/how-to-guides/multinode-timescaledb/multinode-auth/#password-authentication

# Set password_encryption = 'scram-sha-256' in postgresql.conf on the data node.
sed -ri "s!^#?(password_encryption)\s*=.*!\1 = 'scram-sha-256'!" /var/lib/postgresql/data/postgresql.conf
grep "password_encryption" /var/lib/postgresql/data/postgresql.conf
