-- +goose Up
CREATE TABLE nodes (
  client_name   VARCHAR,
  genesis_block VARCHAR(66),
  network_id    VARCHAR,
  node_id       VARCHAR(128) NOT NULL,
  chain_id      INTEGER DEFAULT 1
);

-- +goose Down
DROP TABLE nodes;
