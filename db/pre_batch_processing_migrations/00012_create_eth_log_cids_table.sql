-- +goose Up
CREATE TABLE IF NOT EXISTS eth.log_cids (
    block_number        BIGINT NOT NULL,
    leaf_cid            TEXT NOT NULL,
    leaf_mh_key         TEXT NOT NULL,
    rct_id              VARCHAR(66) NOT NULL,
    address             VARCHAR(66) NOT NULL,
    index               INTEGER NOT NULL,
    topic0              VARCHAR(66),
    topic1              VARCHAR(66),
    topic2              VARCHAR(66),
    topic3              VARCHAR(66),
    log_data            BYTEA
);

-- +goose Down
-- log indexes
DROP TABLE eth.log_cids;
