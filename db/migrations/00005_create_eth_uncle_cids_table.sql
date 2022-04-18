-- +goose Up
CREATE TABLE IF NOT EXISTS eth.uncle_cids (
    block_number          BIGINT NOT NULL,
    block_hash            VARCHAR(66) NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    parent_hash           VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    reward                NUMERIC NOT NULL,
    mh_key                TEXT NOT NULL,
    PRIMARY KEY (block_hash, block_number),
    FOREIGN KEY (header_id, block_number) REFERENCES eth.header_cids (block_hash, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    FOREIGN KEY (mh_key, block_number) REFERENCES public.blocks (key, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

-- +goose Down
DROP TABLE eth.uncle_cids;
