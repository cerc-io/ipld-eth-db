-- +goose Up
CREATE TABLE IF NOT EXISTS eth.access_list_elements (
    block_number          BIGINT NOT NULL,
    tx_id                 VARCHAR(66) NOT NULL,
    index                 INTEGER NOT NULL,
    address               VARCHAR(66),
    storage_keys          VARCHAR(66)[]
);

-- +goose Down
DROP TABLE eth.access_list_elements;
