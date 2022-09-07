-- +goose Up
-- pending tx isn't tightly associated with a block height, so we can't insert the RLP encoded tx as an IPLD block
-- in public.blocks since it is denormalized by block number (we could do something hacky like using head height
-- when the block was seen, or 0 or -1 or something)
-- instead, what we are doing for the time being is embedding the RLP here
CREATE TABLE IF NOT EXISTS eth.pending_txs (
    tx_hash               VARCHAR(66) NOT NULL PRIMARY KEY,
    raw                   BYTEA NOT NULL
);

-- +goose Down
DROP TABLE eth.pending_txs;
