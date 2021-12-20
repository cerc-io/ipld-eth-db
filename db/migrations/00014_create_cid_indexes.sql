-- +goose Up
-- header indexes
CREATE INDEX block_number_index ON eth.header_cids USING brin (block_number);
CREATE INDEX header_cid_index ON eth.header_cids USING btree (cid);
CREATE INDEX header_mh_index ON eth.header_cids USING btree (mh_key);
CREATE INDEX state_root_index ON eth.header_cids USING btree (state_root);
CREATE INDEX timestamp_index ON eth.header_cids USING brin (timestamp);

-- uncle indexes
CREATE INDEX uncle_header_id_index ON eth.uncle_cids USING btree (header_id);

-- transaction indexes
CREATE INDEX tx_header_id_index ON eth.transaction_cids USING btree (header_id);
CREATE INDEX tx_cid_index ON eth.transaction_cids USING btree (cid);
CREATE INDEX tx_mh_index ON eth.transaction_cids USING btree (mh_key);
CREATE INDEX tx_dst_index ON eth.transaction_cids USING btree (dst);
CREATE INDEX tx_src_index ON eth.transaction_cids USING btree (src);

-- receipt indexes
CREATE INDEX rct_leaf_cid_index ON eth.receipt_cids USING btree (leaf_cid);
CREATE INDEX rct_leaf_mh_index ON eth.receipt_cids USING btree (leaf_mh_key);
CREATE INDEX rct_contract_index ON eth.receipt_cids USING btree (contract);
CREATE INDEX rct_contract_hash_index ON eth.receipt_cids USING btree (contract_hash);

-- state node indexes
CREATE INDEX state_leaf_key_index ON eth.state_cids USING btree (state_leaf_key);
CREATE INDEX state_cid_index ON eth.state_cids USING btree (cid);
CREATE INDEX state_mh_index ON eth.state_cids USING btree (mh_key);
CREATE INDEX state_path_index ON eth.state_cids USING btree (state_path);
CREATE INDEX state_node_type_index ON eth.state_cids USING btree (node_type);

-- storage node indexes
CREATE INDEX storage_state_path_index ON eth.storage_cids USING btree (state_path);
CREATE INDEX storage_leaf_key_index ON eth.storage_cids USING btree (storage_leaf_key);
CREATE INDEX storage_cid_index ON eth.storage_cids USING btree (cid);
CREATE INDEX storage_mh_index ON eth.storage_cids USING btree (mh_key);
CREATE INDEX storage_path_index ON eth.storage_cids USING btree (storage_path);
CREATE INDEX storage_node_type_index ON eth.storage_cids USING btree (node_type);

-- state accounts indexes
CREATE INDEX account_state_path_index ON eth.state_accounts USING btree (state_path);
CREATE INDEX storage_root_index ON eth.state_accounts USING btree (storage_root);

-- access list indexes
CREATE INDEX access_list_element_address_index ON eth.access_list_elements USING btree (address);
CREATE INDEX access_list_storage_keys_index ON eth.access_list_elements USING gin (storage_keys);

-- log indexes
CREATE INDEX log_mh_index ON eth.log_cids USING btree (leaf_mh_key);
CREATE INDEX log_cid_index ON  eth.log_cids USING btree (leaf_cid);
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
DROP INDEX eth.log_mh_index;

-- access list indexes
DROP INDEX eth.access_list_storage_keys_index;
DROP INDEX eth.access_list_element_address_index;

-- state account indexes
DROP INDEX eth.storage_root_index;
DROP index eth.account_state_path_index;

-- storage node indexes
DROP INDEX eth.storage_node_type_index;
DROP INDEX eth.storage_path_index;
DROP INDEX eth.storage_mh_index;
DROP INDEX eth.storage_cid_index;
DROP INDEX eth.storage_leaf_key_index;
DROP INDEX eth.storage_state_path_index;

-- state node indexes
DROP INDEX eth.state_node_type_index;
DROP INDEX eth.state_path_index;
DROP INDEX eth.state_mh_index;
DROP INDEX eth.state_cid_index;
DROP INDEX eth.state_leaf_key_index;

-- receipt indexes
DROP INDEX eth.rct_contract_hash_index;
DROP INDEX eth.rct_contract_index;
DROP INDEX eth.rct_leaf_mh_index;
DROP INDEX eth.rct_leaf_cid_index;

-- transaction indexes
DROP INDEX eth.tx_src_index;
DROP INDEX eth.tx_dst_index;
DROP INDEX eth.tx_mh_index;
DROP INDEX eth.tx_cid_index;
DROP INDEX eth.tx_header_id_index;

-- uncle indexes
DROP INDEX eth.uncle_header_id_index;

-- header indexes
DROP INDEX eth.timestamp_index;
DROP INDEX eth.state_root_index;
DROP INDEX eth.header_mh_index;
DROP INDEX eth.header_cid_index;
DROP INDEX eth.block_number_index;
