-- +goose Up
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

ALTER TABLE eth.log_cids
DROP CONSTRAINT fk_log_leaf_mh_key;

-- +goose Down
ALTER TABLE eth.log_cids
ADD CONSTRAINT fk_log_leaf_mh_key
    FOREIGN KEY (leaf_mh_key, block_number) REFERENCES public.blocks (key, block_number)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

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
