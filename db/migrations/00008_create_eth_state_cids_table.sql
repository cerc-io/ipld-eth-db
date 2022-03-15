-- +goose Up
CREATE TABLE eth.state_cids (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL REFERENCES eth.header_cids (block_hash) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    state_leaf_key        VARCHAR(66),
    cid                   TEXT NOT NULL,
    state_path            BYTEA NOT NULL,
    node_type             INTEGER NOT NULL,
    diff                  BOOLEAN NOT NULL DEFAULT FALSE,
    mh_key                TEXT NOT NULL,
    FOREIGN KEY (mh_key, block_number) REFERENCES public.blocks (key, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    PRIMARY KEY (header_id, state_path)
);

-- +goose Down
DROP TABLE eth.state_cids;
