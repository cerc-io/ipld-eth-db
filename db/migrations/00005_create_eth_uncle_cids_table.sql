-- +goose Up
CREATE TABLE IF NOT EXISTS eth.uncle_cids (
    block_number          BIGINT NOT NULL,
    block_hash            VARCHAR(66) NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    parent_hash           VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    reward                NUMERIC NOT NULL,
    mh_key                TEXT NOT NULL,
    PRIMARY KEY (block_hash, block_number)
);

-- +goose Down
DROP TABLE eth.uncle_cids;
