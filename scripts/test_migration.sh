#!/bin/bash

docker rm -f $(docker ps -a -q)

docker volume rm $(docker volume ls -q)

docker-compose -f docker-compose.test.yml up -d test-db
sleep 5s

export HOST_NAME=localhost
export PORT=8066
export USER=vdbm
export TEST_DB=vulcanize_testing
export TEST_CONNECT_STRING=postgresql://$USER@$HOST_NAME:$PORT/$TEST_DB?sslmode=disable
export PGPASSWORD=password

# Get count of total number of migrations
Count=$(find ./db/migrations -name "*sql" -type f | wc -l | awk '{print $1}')

goose -dir ./db/migrations postgres "$TEST_CONNECT_STRING" status

clean_up () {
    rm schema*.sql
}
trap clean_up EXIT

while true;
do
    pg_dump -h localhost -p $PORT -U $USER $TEST_DB --no-owner --schema-only > schema1.sql

    # take action on each file. $f store current file name
    goose -dir ./db/migrations postgres "$TEST_CONNECT_STRING" up-by-one

    goose -dir ./db/migrations postgres "$TEST_CONNECT_STRING" down

    pg_dump -h localhost -p $PORT -U $USER $TEST_DB  --no-owner --schema-only > schema2.sql

    if ! ./scripts/check_diff.sh schema1.sql schema2.sql &> /dev/null;
    then
        # Column names are reordered when they are added back.
        sed "s/\,//" schema1.sql | sort > schema1-sorted.sql
        sed "s/\,//" schema2.sql | sort > schema2-sorted.sql
        if ! ./scripts/check_diff.sh schema1-sorted.sql schema2-sorted.sql &> /dev/null;
        then
            echo "Up and Down migrations doesn't match for this migrations"
            exit 1
        fi
    fi

    goose -dir ./db/migrations postgres "$TEST_CONNECT_STRING" up-by-one

    Version=$(goose -dir ./db/migrations postgres "$TEST_CONNECT_STRING" version 2>&1 | sed 's/.*version //')
    if [ "$Count" = "$Version" ]
    then
        exit 0
    fi
done