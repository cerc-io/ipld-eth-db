-- +goose Up
CREATE TABLE eth.receipt_cids (
    block_number          BIGINT NOT NULL,
    tx_id                 VARCHAR(66) PRIMARY KEY REFERENCES eth.transaction_cids (tx_hash) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    leaf_cid              TEXT NOT NULL,
    contract              VARCHAR(66),
    contract_hash         VARCHAR(66),
    leaf_mh_key           TEXT NOT NULL,
    post_state            VARCHAR(66),
    post_status           INTEGER,
    log_root              VARCHAR(66),
    FOREIGN KEY (leaf_mh_key, block_number) REFERENCES public.blocks (key, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

-- +goose Down
DROP TABLE eth.receipt_cids;
