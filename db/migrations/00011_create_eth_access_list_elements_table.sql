-- +goose Up
CREATE TABLE IF NOT EXISTS eth.access_list_elements (
    block_number          BIGINT NOT NULL,
    tx_id                 VARCHAR(66) NOT NULL REFERENCES eth.transaction_cids (tx_hash) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    index                 INTEGER NOT NULL,
    address               VARCHAR(66),
    storage_keys          VARCHAR(66)[],
    PRIMARY KEY (tx_id, index)
);

-- +goose Down
DROP TABLE eth.access_list_elements;
