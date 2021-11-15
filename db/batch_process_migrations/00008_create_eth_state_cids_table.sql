-- +goose Up
CREATE TABLE eth.state_cids (
    header_id             VARCHAR(66) NOT NULL,
    state_leaf_key        VARCHAR(66),
    cid                   TEXT NOT NULL,
    mh_key                TEXT NOT NULL,
    state_path            BYTEA NOT NULL,
    node_type             INTEGER NOT NULL,
    diff                  BOOLEAN NOT NULL DEFAULT FALSE
);

-- +goose Down
DROP TABLE eth.state_cids;
