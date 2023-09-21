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
    docker-compose -f docker-compose.test.yml up --build
    ```

## Example queries

Note that searching by block_number in addition to block_hash is optional in the below queries where both are provided,
but since the tables are partitioned by block_number doing so will improve query performance by informing the query
planner which partition it needs to search.

### Headers

Retrieve header RLP (IPLD block) and CID for a given block hash

```sql
SELECT header_cids.cid,
       blocks.data
FROM ipld.blocks,
     eth.header_cids
WHERE header_cids.block_hash = {block_hash}
    AND header_cids.block_number = {block_number}
	AND header_cids.canonical
	AND blocks.key = header_cids.cid
	AND blocks.block_number = header_cids.block_number
LIMIT 1
```

###  Uncles
Retrieve the uncle list RLP (IPLD block) and CID for a given block hash

```sql
SELECT uncle_cids.cid,
       blocks.data
FROM eth.uncle_cids
INNER JOIN eth.header_cids ON (
    uncle_cids.header_id = header_cids.block_hash
    AND uncle_cids.block_number = header_cids.block_number)
INNER JOIN ipld.blocks ON (
    uncle_cids.cid = blocks.key
    AND uncle_cids.block_number = blocks.block_number)
WHERE header_cids.block_hash = {block_hash}
    AND header_cids.block_number = {block_number}
ORDER BY uncle_cids.parent_hash
LIMIT 1
```

### Transactions

Retrieve an ordered list of all the RLP encoded transactions (IPLD blocks) and their CIDs for a given block hash

```sql
SELECT transaction_cids.cid,
       blocks.data
FROM eth.transaction_cids,
     eth.header_cids,
     ipld.blocks
WHERE header_cids.block_hash = {block_hash}
    AND header_cids.block_number = {block_number}
	AND header_cids.canonical
	AND transaction_cids.block_number = header_cids.block_number
	AND transaction_cids.header_id = header_cids.block_hash
	AND blocks.block_number = header_cids.block_number
	AND blocks.key = transaction_cids.cid
ORDER BY eth.transaction_cids.index ASC
```

Retrieve an RLP encoded transaction (IPLD block), the block hash and block number for the block it belongs to, and its position in the transaction
for that block for a provided transaction hash

```sql
SELECT blocks.data,
       transaction_cids.header_id,
       transaction_cids.block_number,
       transaction_cids.index
FROM eth.transaction_cids,
     ipld.blocks,
     eth.header_cids
WHERE transaction_cids.tx_hash = {transaction_hash}
	AND header_cids.block_hash = transaction_cids.header_id
	AND header_cids.block_number = transaction_cids.block_number
	AND header_cids.canonical
    AND blocks.key = transaction_cids.cid
	AND blocks.block_number = transaction_cids.block_number
```

### Receipts

Retrieve an ordered list of all the RLP encoded receipts (IPLD blocks), their CIDs, and their corresponding transaction
hashes for a given block hash

```sql
SELECT receipt_cids.cid,
       blocks.data,
       eth.transaction_cids.tx_hash
FROM eth.receipt_cids,
     eth.transaction_cids,
     eth.header_cids,
     ipld.blocks
WHERE header_cids.block_hash = {block_hash}
    AND header_cids.block_number = {block_number}
	AND header_cids.canonical
	AND receipt_cids.block_number = header_cids.block_number
	AND receipt_cids.header_id = header_cids.block_hash
	AND receipt_cids.TX_ID = transaction_cids.TX_HASH
	AND transaction_cids.block_number = header_cids.block_number
	AND transaction_cids.header_id = header_cids.block_hash
	AND blocks.block_number = header_cids.block_number
	AND blocks.key = receipt_cids.cid
ORDER BY eth.transaction_cids.index ASC
```

Retrieve the RLP encoded receipt (IPLD) and CID corresponding to a provided transaction hash

```sql
SELECT receipt_cids.cid,
       blocks.data
FROM eth.receipt_cids
INNER JOIN eth.transaction_cids ON (
    receipt_cids.tx_id = transaction_cids.tx_hash
    AND receipt_cids.block_number = transaction_cids.block_number)
INNER JOIN ipld.blocks ON (
    receipt_cids.cid = blocks.key
    AND receipt_cids.block_number = blocks.block_number)
WHERE transaction_cids.tx_hash = {transaction_hash}
```

### Logs 

Retrieve all the logs and their associated transaction hashes at a given block with that were emitted from
any of the provided contract addresses and which match on any of the provided topics

```sql
SELECT blocks.data,
       eth.transaction_cids.tx_hash
FROM eth.log_cids
INNER JOIN eth.transaction_cids ON (
    log_cids.rct_id = transaction_cids.tx_hash
    AND log_cids.header_id = transaction_cids.header_id
    AND log_cids.block_number = transaction_cids.block_number)
INNER JOIN ipld.blocks ON (
    log_cids.cid = blocks.key
    AND log_cids.block_number = blocks.block_number)
WHERE log_cids.header_id = {block_hash}
    AND log_cids.block_number = {block_number}
    AND eth.log_cids.address = ANY ({list,of,addresses})
    AND eth.log_cids.topic0 = ANY ({list,of,topic0s})
    AND eth.log_cids.topic1 = ANY ({list,of,topic1s})
    AND eth.log_cids.topic2 = ANY ({list,of,topic2s})
    AND eth.log_cids.topic3 = ANY ({list,of,topic3s})
ORDER BY eth.transaction_cids.index, eth.log_cids.index
```

Retrieve all the logs and their associated transaction hashes within a provided block range that were emitted from
any of the provided contract addresses and which match on any of the provided topics

```sql
SELECT blocks.data,
       eth.transaction_cids.tx_hash
FROM eth.log_cids
INNER JOIN eth.transaction_cids ON (
    log_cids.rct_id = transaction_cids.tx_hash
    AND log_cids.header_id = transaction_cids.header_id
    AND log_cids.block_number = transaction_cids.block_number)
INNER JOIN eth.header_cids ON (
    transaction_cids.header_id = header_cids.block_hash
    AND transaction_cids.block_number = header_cids.block_number)
INNER JOIN ipld.blocks ON (
    log_cids.cid = blocks.key
    AND log_cids.block_number = blocks.block_number)
WHERE eth.header_cids.block_number >= {range_start} AND eth.header_cids.block_number <= {range_stop}
    AND eth.header_cids.canonical
    AND eth.log_cids.address = ANY ({list,of,addresses})
    AND eth.log_cids.topic0 = ANY ({list,of,topic0s})
    AND eth.log_cids.topic1 = ANY ({list,of,topic1s})
    AND eth.log_cids.topic2 = ANY ({list,of,topic2s})
    AND eth.log_cids.topic3 = ANY ({list,of,topic3s})
ORDER BY eth.header_cids.block_number, eth.transaction_cids.index, eth.log_cids.index
```

### State and storage

Retrieve the state account for a given address hash at a provided block hash. If `state_cids.removed == true` then
the account is empty.

```sql
SELECT state_cids.nonce,
       state_cids.balance,
       state_cids.storage_root,
       state_cids.code_hash,
       state_cids.removed
FROM eth.state_cids,
     eth.header_cids
WHERE state_cids.state_leaf_key = {address_hash}
	AND state_cids.block_number <=
		(SELECT block_number
			FROM eth.header_cids
			WHERE block_hash = {block_hash}
			LIMIT 1)
	AND header_cids.canonical
	AND state_cids.header_id = header_cids.block_hash
	AND state_cids.block_number = header_cids.block_number
ORDER BY state_cids.block_number DESC
LIMIT 1
```

Retrieve a storage value, as well as the RLP encoded leaf node that stores it, for a given contract address hash and
storage leaf key (storage slot hash) at a provided block hash. If `state_leaf_removed == true`
or `storage_cids.removed == true` then the slot is empty

```sql
SELECT storage_cids.cid,
       storage_cids.val,
       storage_cids.block_number,
       storage_cids.removed,
       was_state_leaf_removed_by_number(storage_cids.state_leaf_key, storage_cids.block_number) AS state_leaf_removed,
       blocks.data
FROM eth.storage_cids,
     eth.header_cids,
     ipld.blocks
WHERE header_cids.block_number <= (SELECT block_number from eth.header_cids where block_hash = $3 LIMIT 1)
    AND header_cids.canonical
    AND storage_cids.block_number = header_cids.block_number
    AND storage_cids.header_id = header_cids.block_hash
    AND storage_cids.storage_leaf_key = {storage_slot_hash}
    AND storage_cids.state_leaf_key = {contract_address_hash}
    AND blocks.key = storage_cids.cid
    AND blocks.block_number = storage_cids.block_number
ORDER BY storage_cids.block_number DESC LIMIT 1
```


