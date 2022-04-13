-- +goose Up
CREATE TABLE IF NOT EXISTS eth.storage_cids (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    state_leaf_key            BYTEA NOT NULL,
    storage_leaf_key      VARCHAR(66),
    cid                   TEXT NOT NULL,
    storage_path          BYTEA NOT NULL,
    node_type             INTEGER NOT NULL,
    diff                  BOOLEAN NOT NULL DEFAULT FALSE,
    mh_key                TEXT NOT NULL,
    FOREIGN KEY (mh_key, block_number) REFERENCES public.blocks (key, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    FOREIGN KEY (state_leaf_key, header_id) REFERENCES eth.state_cids (state_leaf_key, header_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    PRIMARY KEY (storage_path, state_leaf_key, header_id)
);

-- +goose Down
DROP TABLE eth.storage_cids;
