-- +goose Up
CREATE TABLE IF NOT EXISTS eth.pending_txs (
    tx_hash               VARCHAR(66) PRIMARY KEY,
    received              timestamp with time zone NOT NULL,
    mh_key                TEXT NOT NULL,
    raw_peer_id           BYTEA NOT NULL
);

-- +goose Down
DROP TABLE eth.pending_txs;
