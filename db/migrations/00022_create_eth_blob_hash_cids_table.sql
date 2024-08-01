-- +goose Up
CREATE TABLE eth.blob_hashes (
  tx_hash   VARCHAR(66) NOT NULL,
  index     INTEGER NOT NULL,
  blob_hash BYTEA NOT NULL
);

CREATE UNIQUE INDEX blob_hashes_tx_hash_index ON eth.blob_hashes(tx_hash, index);

-- +goose Down
DROP INDEX eth.blob_hashes_tx_hash_index;
DROP TABLE eth.blob_hashes;
