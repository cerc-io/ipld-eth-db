-- +goose Up
CREATE TABLE IF NOT EXISTS eth.state_leaf_cids (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    state_leaf_key        VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    state_path            BYTEA NOT NULL,
    diff                  BOOLEAN NOT NULL DEFAULT FALSE,
    mh_key                TEXT NOT NULL,
    balance               NUMERIC NOT NULL,
    nonce                 BIGINT NOT NULL,
    code_hash             BYTEA NOT NULL,
    storage_root          VARCHAR(66) NOT NULL,
    PRIMARY KEY (state_path, header_id, block_number)
);

-- +goose Down
DROP TABLE eth.state_leaf_cids;
