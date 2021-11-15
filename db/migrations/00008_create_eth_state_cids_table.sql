-- +goose Up
CREATE TABLE eth.state_cids (
    header_id             VARCHAR(66) NOT NULL REFERENCES eth.header_cids (block_hash) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    state_leaf_key        VARCHAR(66),
    cid                   TEXT NOT NULL,
    mh_key                TEXT NOT NULL REFERENCES public.blocks (key) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    state_path            BYTEA NOT NULL,
    node_type             INTEGER NOT NULL,
    diff                  BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (header_id, state_path)
);

-- +goose Down
DROP TABLE eth.state_cids;
