-- +goose Up
CREATE TABLE IF NOT EXISTS eth.transaction_cids (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    tx_hash               VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    dst                   VARCHAR(66),
    src                   VARCHAR(66) NOT NULL,
    index                 INTEGER NOT NULL,
    tx_type               INTEGER,
    value                 NUMERIC,
    PRIMARY KEY (tx_hash, header_id, block_number)
);

-- +goose Down
DROP TABLE eth.transaction_cids;
