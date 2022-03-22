-- +goose Up
CREATE TABLE IF NOT EXISTS eth.log_cids (
    block_number        BIGINT NOT NULL,
    leaf_cid            TEXT NOT NULL,
    leaf_mh_key         TEXT NOT NULL,
    rct_id              VARCHAR(66) NOT NULL REFERENCES eth.receipt_cids (tx_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    address             VARCHAR(66) NOT NULL,
    index               INTEGER NOT NULL,
    topic0              VARCHAR(66),
    topic1              VARCHAR(66),
    topic2              VARCHAR(66),
    topic3              VARCHAR(66),
    log_data            BYTEA,
    FOREIGN KEY (leaf_mh_key, block_number) REFERENCES public.blocks (key, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    PRIMARY KEY (rct_id, index)
);

-- +goose Down
-- log indexes
DROP TABLE eth.log_cids;
