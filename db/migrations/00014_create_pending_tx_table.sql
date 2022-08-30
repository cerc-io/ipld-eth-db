-- +goose Up
CREATE TABLE IF NOT EXISTS eth.pending_txs (
    tx_hash               VARCHAR(66) NOT NULL PRIMARY KEY,
    mh_key                TEXT NOT NULL
);

-- +goose Down
DROP TABLE eth.pending_txs;
