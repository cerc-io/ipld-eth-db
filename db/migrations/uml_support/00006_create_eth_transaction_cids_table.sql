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
    FOREIGN KEY (cid, block_number) REFERENCES ipld.blocks (key, block_number),
    FOREIGN KEY (header_id, block_number) REFERENCES eth.header_cids (block_hash, block_number),
    PRIMARY KEY (tx_hash, header_id, block_number)
);

-- +goose Down
DROP TABLE eth.transaction_cids;
