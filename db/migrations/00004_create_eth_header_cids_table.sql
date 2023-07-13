-- +goose Up
CREATE TABLE IF NOT EXISTS eth.header_cids (
    block_number          BIGINT NOT NULL,
    block_hash            VARCHAR(66) NOT NULL,
    parent_hash           VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    td                    NUMERIC NOT NULL,
    node_ids              VARCHAR(128)[] NOT NULL,
    reward                NUMERIC NOT NULL,
    state_root            VARCHAR(66) NOT NULL,
    tx_root               VARCHAR(66) NOT NULL,
    receipt_root          VARCHAR(66) NOT NULL,
    uncles_hash           VARCHAR(66) NOT NULL,
    bloom                 BYTEA NOT NULL,
    timestamp             BIGINT NOT NULL,
    coinbase              VARCHAR(66) NOT NULL,
    canonical             BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (block_hash, block_number)
);

-- +goose Down
DROP TABLE eth.header_cids;
