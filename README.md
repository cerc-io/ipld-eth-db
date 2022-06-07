# ipld-eth-db
Schemas and utils for IPLD ETH Postgres database

## Database UML
![](vulcanize_db.png)

## Run

* Remove any existing containers / volumes:

  ```bash
  docker-compose down -v --remove-orphans
  ```

* Spin up `ipld-eth-db` using an existing image:

  * Update image source used for running the migrations in [docker-compose.yml](./docker-compose.yml) (if required).

  * Run:

    ```
    docker-compose -f docker-compose.yml up
    ```

* Spin up `ipld-eth-db` using a locally built image:

  * Update [Dockerfile](./Dockerfile) (if required).

  * Update build context used for running the migrations in [docker-compose.test.yml](./docker-compose.test.yml) (if required).

  * Run:

    ```
    docker-compose -f docker-compose.test.yml up
    ```
