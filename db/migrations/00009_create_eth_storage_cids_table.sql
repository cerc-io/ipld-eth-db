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
    PRIMARY KEY (storage_path, state_path, header_id, block_number)
);

-- +goose Down
DROP TABLE eth.storage_cids;
