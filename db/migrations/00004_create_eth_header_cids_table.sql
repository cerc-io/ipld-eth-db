-- +goose Up
CREATE TABLE IF NOT EXISTS eth.header_cids (
    block_number          BIGINT NOT NULL,
    block_hash            VARCHAR(66) NOT NULL,
    parent_hash           VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    td                    NUMERIC NOT NULL,
    node_id               VARCHAR(128)[] NOT NULL,
    reward                NUMERIC NOT NULL,
    state_root            VARCHAR(66) NOT NULL,
    tx_root               VARCHAR(66) NOT NULL,
    receipt_root          VARCHAR(66) NOT NULL,
    uncle_root            VARCHAR(66) NOT NULL,
    bloom                 BYTEA NOT NULL,
    timestamp             BIGINT NOT NULL,
    mh_key                TEXT NOT NULL,
    times_validated       INTEGER NOT NULL DEFAULT 1,
    duplicate_block_number INTEGER DEFAULT 0 NOT NULL,
    coinbase              VARCHAR(66) NOT NULL,
    PRIMARY KEY (block_hash, block_number)
);

-- +goose Down
DROP TABLE eth.header_cids;
