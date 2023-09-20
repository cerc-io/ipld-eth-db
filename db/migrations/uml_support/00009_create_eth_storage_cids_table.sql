-- +goose Up
CREATE TABLE IF NOT EXISTS eth.storage_cids (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    state_leaf_key        VARCHAR(66) NOT NULL,
    storage_leaf_key      VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    diff                  BOOLEAN NOT NULL DEFAULT FALSE,
    val                   BYTEA,  -- NULL if "removed"
    removed               BOOLEAN NOT NULL,
    FOREIGN KEY (cid, block_number) REFERENCES ipld.blocks (key, block_number),
    FOREIGN KEY (state_leaf_key, header_id, block_number) REFERENCES eth.state_cids (state_leaf_key, header_id, block_number),
    PRIMARY KEY (storage_leaf_key, state_leaf_key, header_id, block_number)
);

-- +goose Down
DROP TABLE eth.storage_cids;
