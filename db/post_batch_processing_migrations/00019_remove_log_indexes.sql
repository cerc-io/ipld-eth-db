-- +goose Up
DROP INDEX eth.log_tx_hash_index;
DROP INDEX eth.transaction_hash_index;
DROP INDEX eth.tx_header_hash_index;
DROP INDEX eth.header_hash_index;
DROP INDEX eth.block_number_index;
DROP INDEX eth.log_mh_index_index;

-- +goose Down
CREATE INDEX log_mh_index_index ON eth.log_cids USING btree (leaf_mh_key);
CREATE INDEX block_number_index ON eth.header_cids USING brin (block_number);
CREATE INDEX header_hash_index ON eth.header_cids USING btree (block_hash);
CREATE INDEX tx_header_hash_index ON eth.transaction_cids USING btree (header_id);
CREATE INDEX transaction_hash_index ON eth.transaction_cids USING btree (tx_hash);
CREATE INDEX log_tx_hash_index ON eth.log_cids USING btree (rct_id);
