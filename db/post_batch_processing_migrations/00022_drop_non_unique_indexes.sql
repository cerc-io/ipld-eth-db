-- +goose Up
DROP INDEX eth.log_cids_index;
DROP INDEX eth.tx_tx_hash_index;
DROP INDEX eth.header_block_hash_index;

-- +goose Down
CREATE INDEX header_block_hash_index ON eth.header_cids USING btree (block_hash);
CREATE INDEX tx_tx_hash_index ON eth.transaction_cids USING btree (tx_hash);
CREATE INDEX log_cids_index ON eth.log_cids USING btree (rct_id, index);
