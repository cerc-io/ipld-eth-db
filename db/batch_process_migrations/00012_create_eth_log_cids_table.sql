-- +goose Up
CREATE TABLE eth.log_cids (
    rct_id              VARCHAR(66) NOT NULL,
    leaf_cid            TEXT NOT NULL,
    leaf_mh_key         TEXT NOT NULL,
    address             VARCHAR(66) NOT NULL,
    log_data            BYTEA,
    index               INTEGER NOT NULL,
    topic0              VARCHAR(66),
    topic1              VARCHAR(66),
    topic2              VARCHAR(66),
    topic3              VARCHAR(66),
    PRIMARY KEY (rct_id, index)
);

-- +goose Down
-- log indexes
DROP TABLE eth.log_cids;
