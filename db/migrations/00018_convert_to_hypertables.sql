-- +goose Up
SELECT create_hypertable('ipld.blocks', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.uncle_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.transaction_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.receipt_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.state_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.storage_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.log_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);

-- update version
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v5.0.0-h')
    ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v5.0.0-h', NOW());

-- +goose Down
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v5.0.0')
    ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v5.0.0', NOW());

-- reversing conversion to hypertable requires migrating all data from every chunk back to a single table
-- create new regular tables
CREATE TABLE eth.log_cids_i (LIKE eth.log_cids INCLUDING ALL);
CREATE TABLE eth.storage_cids_i (LIKE eth.storage_cids INCLUDING ALL);
CREATE TABLE eth.state_cids_i (LIKE eth.state_cids INCLUDING ALL);
CREATE TABLE eth.receipt_cids_i (LIKE eth.receipt_cids INCLUDING ALL);
CREATE TABLE eth.transaction_cids_i (LIKE eth.transaction_cids INCLUDING ALL);
CREATE TABLE eth.uncle_cids_i (LIKE eth.uncle_cids INCLUDING ALL);
CREATE TABLE ipld.blocks_i (LIKE ipld.blocks INCLUDING ALL);

-- migrate data
INSERT INTO eth.log_cids_i (SELECT * FROM eth.log_cids);
INSERT INTO eth.storage_cids_i (SELECT * FROM eth.storage_cids);
INSERT INTO eth.state_cids_i (SELECT * FROM eth.state_cids);
INSERT INTO eth.receipt_cids_i (SELECT * FROM eth.receipt_cids);
INSERT INTO eth.transaction_cids_i (SELECT * FROM eth.transaction_cids);
INSERT INTO eth.uncle_cids_i (SELECT * FROM eth.uncle_cids);
INSERT INTO ipld.blocks_i (SELECT * FROM ipld.blocks);

-- drop hypertables
DROP TABLE eth.log_cids;
DROP TABLE eth.storage_cids;
DROP TABLE eth.state_cids;
DROP TABLE eth.receipt_cids;
DROP TABLE eth.transaction_cids;
DROP TABLE eth.uncle_cids;
DROP TABLE ipld.blocks;

-- rename new tables
ALTER TABLE eth.log_cids_i RENAME TO log_cids;
ALTER TABLE eth.storage_cids_i RENAME TO storage_cids;
ALTER TABLE eth.state_cids_i RENAME TO state_cids;
ALTER TABLE eth.receipt_cids_i RENAME TO receipt_cids;
ALTER TABLE eth.transaction_cids_i RENAME TO transaction_cids;
ALTER TABLE eth.uncle_cids_i RENAME TO uncle_cids;
ALTER TABLE ipld.blocks_i RENAME TO blocks;

-- rename indexes:
-- log indexes
ALTER INDEX eth.log_cids_i_topic3_idx RENAME TO log_topic3_index;
ALTER INDEX eth.log_cids_i_topic2_idx RENAME TO log_topic2_index;
ALTER INDEX eth.log_cids_i_topic1_idx RENAME TO log_topic1_index;
ALTER INDEX eth.log_cids_i_topic0_idx RENAME TO log_topic0_index;
ALTER INDEX eth.log_cids_i_address_idx RENAME TO log_address_index;
ALTER INDEX eth.log_cids_i_cid_block_number_idx RENAME TO log_cid_block_number_index;
ALTER INDEX eth.log_cids_i_header_id_idx RENAME TO log_header_id_index;
ALTER INDEX eth.log_cids_i_block_number_idx RENAME TO log_block_number_index;

-- storage node indexes                                            -- storage node indexes
ALTER INDEX eth.storage_cids_i_removed_idx RENAME TO storage_removed_index;
ALTER INDEX eth.storage_cids_i_header_id_idx RENAME TO storage_header_id_index;
ALTER INDEX eth.storage_cids_i_cid_block_number_idx RENAME TO storage_cid_block_number_index;
ALTER INDEX eth.storage_cids_i_state_leaf_key_idx RENAME TO storage_state_leaf_key_index;
ALTER INDEX eth.storage_cids_i_block_number_idx RENAME TO storage_block_number_index;
ALTER INDEX eth.storage_cids_i_storage_leaf_key_block_number_idx RENAME TO storage_leaf_key_block_number_index;

-- state node indexes                                                 -- state node indexes
ALTER INDEX eth.state_cids_i_code_hash_idx RENAME TO state_code_hash_index;
ALTER INDEX eth.state_cids_i_removed_idx RENAME TO state_removed_index;
ALTER INDEX eth.state_cids_i_header_id_idx RENAME TO state_header_id_index;
ALTER INDEX eth.state_cids_i_cid_block_number_idx RENAME TO state_cid_block_number_index;
ALTER INDEX eth.state_cids_i_block_number_idx RENAME TO state_block_number_index;
ALTER INDEX eth.state_cids_i_state_leaf_key_block_number_idx RENAME TO state_leaf_key_block_number_index;

-- receipt indexes                                                    -- receipt indexes
ALTER INDEX eth.receipt_cids_i_contract_idx RENAME TO rct_contract_index;
ALTER INDEX eth.receipt_cids_i_cid_block_number_idx RENAME TO rct_cid_block_number_index;
ALTER INDEX eth.receipt_cids_i_header_id_idx RENAME TO rct_header_id_index;
ALTER INDEX eth.receipt_cids_i_block_number_idx RENAME TO rct_block_number_index;

-- transaction indexes                                                -- transaction indexes
ALTER INDEX eth.transaction_cids_i_src_idx RENAME TO tx_src_index;
ALTER INDEX eth.transaction_cids_i_dst_idx RENAME TO tx_dst_index;
ALTER INDEX eth.transaction_cids_i_cid_block_number_idx RENAME TO tx_cid_block_number_index;
ALTER INDEX eth.transaction_cids_i_header_id_idx RENAME TO tx_header_id_index;
ALTER INDEX eth.transaction_cids_i_block_number_idx RENAME TO tx_block_number_index;

-- uncle indexes                                                      -- uncle indexes
ALTER INDEX eth.uncle_cids_i_block_number_idx RENAME TO uncle_block_number_index;
ALTER INDEX eth.uncle_cids_i_cid_block_number_index_idx RENAME TO uncle_cid_block_number_index;
ALTER INDEX eth.uncle_cids_i_header_id_idx RENAME TO uncle_header_id_index;
