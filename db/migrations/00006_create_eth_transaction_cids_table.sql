-- +goose Up
CREATE TABLE IF NOT EXISTS eth.transaction_cids (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL REFERENCES eth.header_cids (block_hash) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    tx_hash               VARCHAR(66) PRIMARY KEY,
    cid                   TEXT NOT NULL,
    dst                   VARCHAR(66) NOT NULL,
    src                   VARCHAR(66) NOT NULL,
    index                 INTEGER NOT NULL,
    mh_key                TEXT NOT NULL,
    tx_data               BYTEA,
    tx_type               INTEGER,
    value                 NUMERIC,
    FOREIGN KEY (mh_key, block_number) REFERENCES public.blocks (key, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

-- +goose Down
DROP TABLE eth.transaction_cids;
