-- +goose Up
CREATE TABLE IF NOT EXISTS eth.storage_cids (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    state_path            BYTEA NOT NULL,
    storage_leaf_key      VARCHAR(66),
    cid                   TEXT NOT NULL,
    storage_path          BYTEA NOT NULL,
    node_type             INTEGER NOT NULL,
    diff                  BOOLEAN NOT NULL DEFAULT FALSE,
    mh_key                TEXT NOT NULL,
    FOREIGN KEY (mh_key, block_number) REFERENCES public.blocks (key, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    FOREIGN KEY (header_id, state_path) REFERENCES eth.state_cids (header_id, state_path) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    PRIMARY KEY (header_id, state_path, storage_path)
);

-- +goose Down
DROP TABLE eth.storage_cids;
