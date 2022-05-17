# ipld-eth-db
Schemas and utils for IPLD ETH Postgres database

## Database UML
![](vulcanize_db.png)

## Run

* Remove any existing containers / volumes:

  ```bash
  docker-compose down -v --remove-orphans
  ```

* Spin up a TimescaleDB instance using [docker-compose.test.yml](./docker-compose.test.yml):

  ```bash
  docker-compose -f docker-compose.test.yml up
  ```

  Following final output should be seen:

    ```
    LOG:  TimescaleDB background worker launcher connected to shared catalogs
    ```

* In another `ipld-eth-db` terminal window, build an image `migrations-test` using [Dockerfile](./db/Dockerfile):

  ```bash
  docker build -t migrations-test -f ./db/Dockerfile .
  ```

* Start a container using `migrations-test` image to run the db migrations:

  ```bash
  # Here, we are running the container using host network.
  # So connect to TimescaleDB on 127.0.0.1:8066
  docker run --rm --network host -e DATABASE_USER=vdbm -e DATABASE_PASSWORD=password -e DATABASE_HOSTNAME=127.0.0.1 -e DATABASE_PORT=8066 -e DATABASE_NAME=vulcanize_testing_v4 migrations-test
  ```
