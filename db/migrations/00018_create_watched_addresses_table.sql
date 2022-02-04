-- +goose Up
CREATE TABLE eth_meta.watched_addresses (
    address                 VARCHAR(66) PRIMARY KEY,
    created_at              BIGINT NOT NULL,
    watched_at              BIGINT NOT NULL,
    last_filled_at          BIGINT NOT NULL DEFAULT 0
);

-- +goose Down
DROP TABLE eth_meta.watched_addresses;
