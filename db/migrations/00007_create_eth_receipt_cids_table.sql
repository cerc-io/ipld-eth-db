-- +goose Up
CREATE TABLE eth.receipt_cids (
    tx_id                 VARCHAR(66) PRIMARY KEY REFERENCES eth.transaction_cids (tx_hash) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    leaf_cid              TEXT NOT NULL,
    leaf_mh_key           TEXT NOT NULL REFERENCES public.blocks (key) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    contract              VARCHAR(66),
    contract_hash         VARCHAR(66),
    post_state            VARCHAR(66),
    post_status           INTEGER,
    log_root              VARCHAR(66)
);

-- +goose Down
DROP TABLE eth.receipt_cids;
