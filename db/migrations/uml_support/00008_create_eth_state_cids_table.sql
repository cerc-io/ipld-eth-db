-- +goose Up
CREATE TABLE IF NOT EXISTS eth.state_cids (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    state_leaf_key        VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    diff                  BOOLEAN NOT NULL DEFAULT FALSE,
    balance               NUMERIC,      -- NULL if "removed"
    nonce                 BIGINT,       -- NULL if "removed"
    code_hash             VARCHAR(66),  -- NULL if "removed"
    storage_root          VARCHAR(66),  -- NULL if "removed"
    removed               BOOLEAN NOT NULL,
    FOREIGN KEY (cid, block_number) REFERENCES ipld.blocks (key, block_number),
    FOREIGN KEY (header_id, block_number) REFERENCES eth.header_cids (block_hash, block_number),
    PRIMARY KEY (state_leaf_key, header_id, block_number)
);

-- +goose Down
DROP TABLE eth.state_cids;
