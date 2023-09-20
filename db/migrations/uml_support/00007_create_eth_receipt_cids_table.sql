-- +goose Up
CREATE TABLE IF NOT EXISTS eth.receipt_cids (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    tx_id                 VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    contract              VARCHAR(66),
    post_state            VARCHAR(66),
    post_status           SMALLINT,
    FOREIGN KEY (cid, block_number) REFERENCES ipld.blocks (key, block_number),
    FOREIGN KEY (header_id, block_number) REFERENCES eth.header_cids (block_hash, block_number),
    PRIMARY KEY (tx_id, header_id, block_number)
);

-- +goose Down
DROP TABLE eth.receipt_cids;
