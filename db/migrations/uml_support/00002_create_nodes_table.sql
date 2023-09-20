-- +goose Up
CREATE TABLE IF NOT EXISTS nodes (
    genesis_block VARCHAR(66),
    network_id    VARCHAR,
    node_id       VARCHAR(128) PRIMARY KEY,
    client_name   VARCHAR,
    chain_id      INTEGER DEFAULT 1
);

-- +goose Down
DROP TABLE nodes;
