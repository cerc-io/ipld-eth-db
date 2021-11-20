-- +goose Up
CREATE TABLE eth.header_cids (
    block_hash            VARCHAR(66) NOT NULL,
    block_number          BIGINT NOT NULL,
    parent_hash           VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    mh_key                TEXT NOT NULL,
    td                    BIGINT NOT NULL,
    node_id               VARCHAR(128) NOT NULL,
    reward                BIGINT NOT NULL,
    state_root            VARCHAR(66) NOT NULL,
    tx_root               VARCHAR(66) NOT NULL,
    receipt_root          VARCHAR(66) NOT NULL,
    uncle_root            VARCHAR(66) NOT NULL,
    bloom                 BYTEA NOT NULL,
    timestamp             BIGINT NOT NULL,
    times_validated       INTEGER NOT NULL DEFAULT 1,
    base_fee              BIGINT
);

-- +goose Down
DROP TABLE eth.header_cids;
