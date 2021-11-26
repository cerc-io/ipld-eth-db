-- +goose Up
CREATE TABLE eth.uncle_cids (
    block_hash            VARCHAR(66) PRIMARY KEY,
    header_id             VARCHAR(66) NOT NULL REFERENCES eth.header_cids (block_hash) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    parent_hash           VARCHAR(66) NOT NULL,
    cid                   TEXT NOT NULL,
    reward                NUMERIC NOT NULL,
    mh_key                TEXT NOT NULL REFERENCES public.blocks (key) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

-- +goose Down
DROP TABLE eth.uncle_cids;
