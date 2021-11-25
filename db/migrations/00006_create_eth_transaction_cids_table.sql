-- +goose Up
CREATE TABLE eth.transaction_cids (
    tx_hash               VARCHAR(66) PRIMARY KEY,
    header_id             VARCHAR(66) NOT NULL REFERENCES eth.header_cids (block_hash) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    index                 INTEGER NOT NULL,
    cid                   TEXT NOT NULL,
    mh_key                TEXT NOT NULL REFERENCES public.blocks (key) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    dst                   VARCHAR(66) NOT NULL,
    src                   VARCHAR(66) NOT NULL,
    tx_data               BYTEA,
    tx_type               INTEGER,
    value                 NUMERIC
);

-- +goose Down
DROP TABLE eth.transaction_cids;
