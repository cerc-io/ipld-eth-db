-- +goose Up
CREATE TABLE IF NOT EXISTS eth.access_list_elements (
    block_number          BIGINT NOT NULL,
    tx_id                 VARCHAR(66) NOT NULL,
    index                 INTEGER NOT NULL,
    address               VARCHAR(66),
    storage_keys          VARCHAR(66)[],
    PRIMARY KEY (tx_id, index, block_number),
    FOREIGN KEY (tx_id, block_number) REFERENCES eth.transaction_cids (tx_hash, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

-- +goose Down
DROP TABLE eth.access_list_elements;
