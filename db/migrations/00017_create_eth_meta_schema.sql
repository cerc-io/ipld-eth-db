-- +goose Up
CREATE SCHEMA eth_meta;

-- +goose Down
DROP SCHEMA eth_meta;
