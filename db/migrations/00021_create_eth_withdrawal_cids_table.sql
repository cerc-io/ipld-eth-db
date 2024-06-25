-- +goose Up
CREATE TABLE IF NOT EXISTS eth.withdrawal_cids (
    block_number    BIGINT NOT NULL,
    header_id       VARCHAR(66) NOT NULL,
    cid             TEXT NOT NULL,
    index           INTEGER NOT NULL,
    validator       INTEGER NOT NULL,
    address         VARCHAR(66) NOT NULL,
    amount          NUMERIC NOT NULL,
    PRIMARY KEY (index, header_id, block_number)
);

SELECT create_hypertable('eth.withdrawal_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);

-- +goose Down
DROP TABLE eth.withdrawal_cids;
