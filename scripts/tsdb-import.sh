#!/bin/bash

pre_restore_sql=`mktemp`
post_restore_sql=`mktemp`

cat <<EOF >${pre_restore_sql}
SELECT timescaledb_pre_restore();
EOF

cat <<EOF >${post_restore_sql}
SELECT timescaledb_post_restore();
EOF

psql -U "${POSTGRES_USER}" "${POSTGRES_DB}" -f ${pre_restore_sql}

pg_restore -U "${POSTGRES_USER}" -Fc -d "${POSTGRES_DB}" /schema.bak

psql -U "${POSTGRES_USER}" "${POSTGRES_DB}" -f ${post_restore_sql}
