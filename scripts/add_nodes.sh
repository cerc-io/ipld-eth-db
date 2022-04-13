#!/bin/bash
# Guards
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]
  then
    echo "Env variables not provided"
    echo "Usage: ./ipfs_postgres.sh <MIGRATION_FILE_PATH:string> <NODE_NAME:string> <NODE_HOST:string> <NODE_PORT:numeric/string> <NODE_DATABASE:string> <EXECUTE_SQ:bool>"
    echo "Only <EXECUTE_SQL> is optional"
    exit 1
fi
if [ -z "$6" ]
  then
    echo "EXECUTE_SQL not set, will not run statements against an access server"
  else
    echo "EXECUTE_SQL is set, will run stataments against an access server"
    echo "Note: this mode is not recommended except in the case when the migration has already been applied with previous
    nodes and we need/want to add more while still recording them in the existing migration (and adding their Down statements to said migration)"
    echo "Expected environment variables:"
    echo "DATABASE_HOSTNAME, DATABASE_NAME, DATABASE_PORT, DATABASE_USER"
    echo "For now, DATABASE_PASSWORD will be prompted for on each psql call"
fi

# Remote DB node info
export MIGRATION_FILE_PATH=$1
export NODE_NAME=$2
export NODE_HOST=$3
export NODE_PORT=$4
export NODE_DATABASE=$5
printf "Enter the ${NODE_HOST} database password:\n"
stty -echo
read NODE_PASSWORD
stty echo
export NODE_PASSWORD

if ! [ -z "$6" ]
  then
    # Access DB info
    echo "heeeeey"
    export DATABASE_HOSTNAME=localhost
    export DATABASE_PORT=5432
    export DATABASE_USER=vdbm
    export DATABASE_NAME=vulcanize_db
fi

# Array of distributed hypertable names
declare -a tables_names=("public.blocks" "eth.header_cid" "eth.uncle_cids" "eth.transaction_cids"
                "eth.receipt_cids" "eth.state_cid" "eth.storage_cids" "eth.state_accounts"
                "eth.access_list_elements" "eth.log_cids"
                )
# Array to append Up statements to for later (optional) execution
declare -a up_stmts=()

echo "Writing Up and Down statements to provided migration file at ${migration_file_path}"

# Create add node statement
up_add_pg_str="SELECT add_data_node('${NODE_NAME}', host => '${NODE_HOST}', port => ${NODE_PORT}, database => '${NODE_DATABASE}', password => '${NODE_PASSWORD}');"
up_stmts+=(${up_add_pg_str})

# Insert at the 3rd line of the file
sed -i.bak '3 i\
'"${up_add_pg_str}"'
' "${MIGRATION_FILE_PATH}"

# Check for error
if [[ $? -eq 0 ]]; then
    echo "Wrote Up add node statement ${up_add_pg_str}"
else
    echo "Could not write Up add node statement ${up_add_pg_str}. Is the migration file path correct?"
    exit 1
fi

# Create attach node statements
for table_name in "${tables_names[@]}"
do
  up_attach_pg_str="SELECT attach_data_node('${NODE_NAME}', '${table_name}', if_not_attached => true);"
  up_stmts+=(${up_attach_pg_str})
  # Insert at the 4th line of the file
  sed -i.bak '4 i\
'"${up_attach_pg_str}"'
' "${MIGRATION_FILE_PATH}"
  # Check for error
  if [[ $? -eq 0 ]]; then
      echo "Wrote Up attach node statement ${up_attach_pg_str}"
  else
      echo "Could not write Up attach node statement ${up_attach_pg_str}. Is the migration file path correct?"
      exit 1
  fi
done

## Create detach and remove node statement
down_attach_pg_str="SELECT detach_data_node('${NODE_NAME}', force => true, if_attached = true);"
down_add_pg_str="SELECT delete_data_node('${NODE_NAME}', force => true, if_attached => true);"

# Append them at the last line in the file
sed -i.bak '$ a\
'"${down_attach_pg_str}"'
' "${MIGRATION_FILE_PATH}"
# Check for error
if [[ $? -eq 0 ]]; then
    echo "Wrote Down attach node statement ${down_attach_pg_str}"
else
    echo "Could not write Down attach node statement ${down_attach_pg_str}. Is the migration file path correct?"
    exit 1
fi
# Append them at the last line in the file
sed -i.bak '$ a\
'"${down_add_pg_str}"'
' "${MIGRATION_FILE_PATH}"
# Check for error
if [[ $? -eq 0 ]]; then
    echo "Wrote Down add node statement ${down_add_pg_str}"
else
    echo "Could not write Down add node statement ${down_add_pg_str}. Is the migration file path correct?"
    exit 1
fi

# Execute Up statements on the server if we are in that mode
if [ -z "$6" ]
  then
    echo "Done!"
    exit 0
fi

echo "Executing Up statements against provided server"

for up_stmt in "${up_stmts[@]}"
do
  psql -c '\x' -c "${up_stmt}" -h $DATABASE_HOSTNAME -p $DATABASE_PORT -U $DATABASE_USER -d $DATABASE_NAME -W
  # Check for error
  if [[ $? -eq 0 ]]; then
      echo "Executed Up statement ${up_stmt}}"
  else
      echo "Could not execute Up statement ${up_stmt}. Is the migration file path correct?"
      exit 1
  fi
done

echo "Done!"
exit 0
