-- +goose Up
CREATE TABLE eth.known_gaps (
  starting_block_number bigint PRIMARY KEY,
  ending_block_number bigint,
  checked_out boolean,
  processing_key bigint
);

-- +goose Down
DROP TABLE eth.known_gaps;