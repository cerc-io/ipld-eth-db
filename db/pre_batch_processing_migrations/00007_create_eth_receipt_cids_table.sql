-- +goose Up
CREATE TABLE eth.receipt_cids (
    tx_id                 VARCHAR(66) NOT NULL,
    leaf_cid              TEXT NOT NULL,
    contract              VARCHAR(66),
    contract_hash         VARCHAR(66),
    leaf_mh_key           TEXT NOT NULL,
    post_state            VARCHAR(66),
    post_status           INTEGER,
    log_root              VARCHAR(66)
);

-- +goose Down
DROP TABLE eth.receipt_cids;
