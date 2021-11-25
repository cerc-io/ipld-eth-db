-- +goose Up
CREATE TABLE eth.transaction_cids (
    header_id             VARCHAR(66) NOT NULL REFERENCES eth.header_cids (block_hash) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    tx_hash               VARCHAR(66) PRIMARY KEY,
    cid                   TEXT NOT NULL,
    dst                   VARCHAR(66) NOT NULL,
    src                   VARCHAR(66) NOT NULL,
    index                 INTEGER NOT NULL,
    mh_key                TEXT NOT NULL REFERENCES public.blocks (key) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    tx_data               BYTEA,
    tx_type               INTEGER,
    value                 NUMERIC
);

-- +goose Down
DROP TABLE eth.transaction_cids;
