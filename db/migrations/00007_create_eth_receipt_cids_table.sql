-- +goose Up
CREATE TABLE IF NOT EXISTS eth.receipt_cids (
    block_number          BIGINT NOT NULL,
    tx_id                 VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    contract              VARCHAR(66),
    contract_hash         VARCHAR(66),
    mh_key                TEXT NOT NULL,
    post_state            VARCHAR(66),
    post_status           INTEGER,
    PRIMARY KEY (tx_id, block_number)
);

-- +goose Down
DROP TABLE eth.receipt_cids;
