-- +goose Up
-- header indexes
CREATE INDEX header_block_number_index ON eth.header_cids USING brin (block_number);
CREATE UNIQUE INDEX header_cid_index ON eth.header_cids USING btree (cid, block_number);
CREATE UNIQUE INDEX header_mh_block_number_index ON eth.header_cids USING btree (mh_key, block_number);
CREATE INDEX state_root_index ON eth.header_cids USING btree (state_root);
CREATE INDEX timestamp_index ON eth.header_cids USING brin (timestamp);

-- uncle indexes
CREATE INDEX uncle_block_number_index ON eth.uncle_cids USING brin (block_number);
CREATE UNIQUE INDEX uncle_mh_block_number_index ON eth.uncle_cids USING btree (mh_key, block_number);
CREATE INDEX uncle_header_id_index ON eth.uncle_cids USING btree (header_id);

-- transaction indexes
CREATE INDEX tx_block_number_index ON eth.transaction_cids USING brin (block_number);
CREATE INDEX tx_header_id_index ON eth.transaction_cids USING btree (header_id);
CREATE INDEX tx_cid_index ON eth.transaction_cids USING btree (cid, block_number);
CREATE INDEX tx_mh_block_number_index ON eth.transaction_cids USING btree (mh_key, block_number);
CREATE INDEX tx_dst_index ON eth.transaction_cids USING btree (dst);
CREATE INDEX tx_src_index ON eth.transaction_cids USING btree (src);

-- receipt indexes
CREATE INDEX rct_block_number_index ON eth.receipt_cids USING brin (block_number);
CREATE INDEX rct_header_id_index ON eth.receipt_cids USING btree (header_id);
CREATE INDEX rct_cid_index ON eth.receipt_cids USING btree (cid);
CREATE INDEX rct_mh_block_number_index ON eth.receipt_cids USING btree (mh_key, block_number);
CREATE INDEX rct_contract_index ON eth.receipt_cids USING btree (contract);
CREATE INDEX rct_contract_hash_index ON eth.receipt_cids USING btree (contract_hash);

-- state node indexes
CREATE INDEX state_block_number_index ON eth.state_cids USING brin (block_number);
CREATE INDEX state_cid_index ON eth.state_cids USING btree (cid);
CREATE INDEX state_mh_block_number_index ON eth.state_cids USING btree (mh_key, block_number);
CREATE INDEX state_header_id_index ON eth.state_cids USING btree (header_id);
CREATE INDEX state_path_index ON eth.state_cids USING btree (state_path);
CREATE INDEX state_removed_index ON eth.state_cids USING btree (removed);
CREATE INDEX state_code_hash_index ON eth.state_cids USING btree (code_hash); -- could be useful for e.g. selecting all the state accounts with the same contract bytecode deployed
CREATE INDEX state_leaf_key_block_number_index ON eth.state_cids(state_leaf_key, block_number DESC);

-- storage node indexes
CREATE INDEX storage_block_number_index ON eth.storage_cids USING brin (block_number);
CREATE INDEX storage_state_leaf_key_index ON eth.storage_cids USING btree (state_leaf_key);
CREATE INDEX storage_cid_index ON eth.storage_cids USING btree (cid);
CREATE INDEX storage_mh_block_number_index ON eth.storage_cids USING btree (mh_key, block_number);
CREATE INDEX storage_header_id_index ON eth.storage_cids USING btree (header_id);
CREATE INDEX storage_path_index ON eth.storage_cids USING btree (storage_path);
CREATE INDEX storage_removed_index ON eth.storage_cids USING btree (removed);
CREATE INDEX storage_leaf_key_block_number_index ON eth.storage_cids(storage_leaf_key, block_number DESC);

-- access list indexes
CREATE INDEX access_list_block_number_index ON eth.access_list_elements USING brin (block_number);
CREATE INDEX access_list_element_address_index ON eth.access_list_elements USING btree (address);
CREATE INDEX access_list_storage_keys_index ON eth.access_list_elements USING gin (storage_keys);

-- log indexes
CREATE INDEX log_block_number_index ON eth.log_cids USING brin (block_number);
CREATE INDEX log_header_id_index ON eth.log_cids USING btree (header_id);
CREATE INDEX log_mh_block_number_index ON eth.log_cids USING btree (mh_key, block_number);
CREATE INDEX log_cid_index ON  eth.log_cids USING btree (cid);
CREATE INDEX log_address_index ON eth.log_cids USING btree (address);
CREATE INDEX log_topic0_index ON eth.log_cids USING btree (topic0);
CREATE INDEX log_topic1_index ON eth.log_cids USING btree (topic1);
CREATE INDEX log_topic2_index ON eth.log_cids USING btree (topic2);
CREATE INDEX log_topic3_index ON eth.log_cids USING btree (topic3);

-- +goose Down
-- log indexes
DROP INDEX eth.log_topic3_index;
DROP INDEX eth.log_topic2_index;
DROP INDEX eth.log_topic1_index;
DROP INDEX eth.log_topic0_index;
DROP INDEX eth.log_address_index;
DROP INDEX eth.log_cid_index;
DROP INDEX eth.log_mh_block_number_index;
DROP INDEX eth.log_header_id_index;
DROP INDEX eth.log_block_number_index;

-- access list indexes
DROP INDEX eth.access_list_storage_keys_index;
DROP INDEX eth.access_list_element_address_index;
DROP INDEX eth.access_list_block_number_index;

-- storage node indexes
DROP INDEX eth.storage_removed_index;
DROP INDEX eth.storage_path_index;
DROP INDEX eth.storage_header_id_index;
DROP INDEX eth.storage_mh_block_number_index;
DROP INDEX eth.storage_cid_index;
DROP INDEX eth.storage_leaf_key_index;
DROP INDEX eth.storage_state_leaf_key_index;
DROP INDEX eth.storage_block_number_index;
DROP INDEX eth.storage_leaf_key_block_number_index;

-- state node indexes
DROP INDEX eth.state_code_hash_index;
DROP INDEX eth.state_removed_index;
DROP INDEX eth.state_path_index;
DROP INDEX eth.state_header_id_index;
DROP INDEX eth.state_mh_block_number_index;
DROP INDEX eth.state_cid_index;
DROP INDEX eth.state_block_number_index;
DROP INDEX eth.state_leaf_key_block_number_index;

-- receipt indexes
DROP INDEX eth.rct_contract_hash_index;
DROP INDEX eth.rct_contract_index;
DROP INDEX eth.rct_mh_block_number_index;
DROP INDEX eth.rct_cid_index;
DROP INDEX eth.rct_header_id_index;
DROP INDEX eth.rct_block_number_index;

-- transaction indexes
DROP INDEX eth.tx_src_index;
DROP INDEX eth.tx_dst_index;
DROP INDEX eth.tx_mh_block_number_index;
DROP INDEX eth.tx_cid_index;
DROP INDEX eth.tx_header_id_index;
DROP INDEX eth.tx_block_number_index;

-- uncle indexes
DROP INDEX eth.uncle_block_number_index;
DROP INDEX eth.uncle_mh_block_number_index;
DROP INDEX eth.uncle_header_id_index;

-- header indexes
DROP INDEX eth.timestamp_index;
DROP INDEX eth.state_root_index;
DROP INDEX eth.header_mh_block_number_index;
DROP INDEX eth.header_cid_index;
DROP INDEX eth.header_block_number_index;
