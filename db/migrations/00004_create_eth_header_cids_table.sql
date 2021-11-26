-- +goose Up
CREATE TABLE eth.header_cids (
    block_number          BIGINT NOT NULL,
    block_hash            VARCHAR(66) PRIMARY KEY,
    parent_hash           VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    td                    NUMERIC NOT NULL,
    node_id               VARCHAR(128) NOT NULL REFERENCES nodes (node_id) ON DELETE CASCADE,
    reward                NUMERIC NOT NULL,
    state_root            VARCHAR(66) NOT NULL,
    tx_root               VARCHAR(66) NOT NULL,
    receipt_root          VARCHAR(66) NOT NULL,
    uncle_root            VARCHAR(66) NOT NULL,
    bloom                 BYTEA NOT NULL,
    timestamp             BIGINT NOT NULL,
    mh_key                TEXT NOT NULL REFERENCES public.blocks (key) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    times_validated       INTEGER NOT NULL DEFAULT 1,
    coinbase              VARCHAR(66) NOT NULL
);

-- +goose Down
DROP TABLE eth.header_cids;
