-- +goose Up
UPDATE pg_index
SET indisready=true
WHERE indrelid = (
    SELECT oid
    FROM pg_class
    WHERE relname='eth.header_cids'
);
UPDATE pg_index
SET indisready=true
WHERE indrelid = (
    SELECT oid
    FROM pg_class
    WHERE relname='eth.transaction_cids'
);
UPDATE pg_index
SET indisready=true
WHERE indrelid = (
    SELECT oid
    FROM pg_class
    WHERE relname='eth.log_cids'
);

DROP INDEX eth.tx_header_id_index;
DROP INDEX eth.block_number_index;
DROP INDEX eth.log_mh_index;

-- +goose Down
CREATE INDEX log_mh_index ON eth.log_cids USING btree (leaf_mh_key);
CREATE INDEX block_number_index ON eth.header_cids USING brin (block_number);
CREATE INDEX tx_header_id_index ON eth.transaction_cids USING btree (header_id);

UPDATE pg_index
SET indisready=false
WHERE indrelid = (
    SELECT oid
    FROM pg_class
    WHERE relname='eth.log_cids'
);
UPDATE pg_index
SET indisready=false
WHERE indrelid = (
    SELECT oid
    FROM pg_class
    WHERE relname='eth.transaction_cids'
);
UPDATE pg_index
SET indisready=false
WHERE indrelid = (
    SELECT oid
    FROM pg_class
    WHERE relname='eth.header_cids'
);
