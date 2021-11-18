-- +goose Up
CREATE TABLE eth.access_list_element (
    tx_id                 VARCHAR(66) NOT NULL,
    index                 INTEGER NOT NULL,
    address               VARCHAR(66),
    storage_keys          VARCHAR(66)[],
    PRIMARY KEY (tx_id, index)
);

-- +goose Down
DROP TABLE eth.access_list_element;
