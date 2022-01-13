-- +goose Up
CREATE TABLE eth.watched_addresses (
    address               VARCHAR(66) PRIMARY KEY,
    added_at              BIGINT NOT NULL
);

-- +goose Down
DROP TABLE eth.watched_addresses;
