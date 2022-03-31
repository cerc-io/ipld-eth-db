-- +goose Up
CREATE TABLE eth_meta.known_gaps (
     starting_block_number bigint PRIMARY KEY,
     ending_block_number bigint,
     checked_out boolean,
     processing_key bigint
);

-- +goose Down
DROP TABLE eth_meta.known_gaps;
