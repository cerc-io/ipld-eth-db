-- +goose Up
CREATE SCHEMA ipld;

CREATE TABLE IF NOT EXISTS ipld.blocks (
    block_number BIGINT NOT NULL,
    key TEXT NOT NULL,
    data BYTEA NOT NULL,
    PRIMARY KEY (key, block_number)
);

-- +goose Down
DROP TABLE ipld.blocks;
DROP SCHEMA ipld;
