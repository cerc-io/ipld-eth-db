-- +goose Up
-- pending tx isn't tightly associated with a block height, so we can't insert the RLP encoded tx as an IPLD block
-- in ipld.blocks since it is denormalized by block number (we could do something hacky like using head height
-- when the block was seen, or 0 or -1 or something)
-- instead, what we are doing for the time being is embedding the RLP here
CREATE TABLE IF NOT EXISTS eth.pending_txs (
    tx_hash               VARCHAR(66) NOT NULL PRIMARY KEY,
    block_hash            VARCHAR(66) NOT NULL, -- references block_hash in pending_blocks for the pending block this tx belongs to
    timestamp             BIGINT NOT NULL,
    raw                   BYTEA NOT NULL
);

CREATE TABLE IF NOT EXISTS eth.pending_blocks (
    block_hash VARCHAR(66) NOT NULL PRIMARY KEY,
    block_number BIGINT NOT NULL,
    raw_header BYTEA NOT NULL
)

-- +goose Down
DROP TABLE eth.pending_blocks;
DROP TABLE eth.pending_txs;
