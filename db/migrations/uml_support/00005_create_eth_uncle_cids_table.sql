-- +goose Up
CREATE TABLE IF NOT EXISTS eth.uncle_cids (
    block_number          BIGINT NOT NULL,
    block_hash            VARCHAR(66) NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    parent_hash           VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    reward                NUMERIC NOT NULL,
    index                 INT NOT NULL,
    FOREIGN KEY (cid, block_number) REFERENCES ipld.blocks (key, block_number),
    FOREIGN KEY (header_id, block_number) REFERENCES eth.header_cids (block_hash, block_number),
    PRIMARY KEY (block_hash, block_number)
);

-- +goose Down
DROP TABLE eth.uncle_cids;
