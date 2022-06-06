-- +goose Up
SELECT create_hypertable('public.blocks', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.header_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.uncle_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.transaction_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.receipt_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.state_leaf_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.storage_leaf_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.state_accounts', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.access_list_elements', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.log_cids', 'block_number', migrate_data => true, chunk_time_interval => 32768);

-- update version
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v4.0.0-h')
    ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v4.0.0-h', NOW());

-- +goose Down
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v4.0.0')
    ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v4.0.0', NOW());

-- reversing conversion to hypertable requires migrating all data from every chunk back to a single table
-- create new regular tables
CREATE TABLE eth.log_cids_i (LIKE eth.log_cids INCLUDING ALL);
CREATE TABLE eth.access_list_elements_i (LIKE eth.access_list_elements INCLUDING ALL);
CREATE TABLE eth.state_accounts_i (LIKE eth.state_accounts INCLUDING ALL);
CREATE TABLE eth.storage_leaf_cids_i (LIKE eth.storage_leaf_cids INCLUDING ALL);
CREATE TABLE eth.state_leaf_cids_i (LIKE eth.state_leaf_cids INCLUDING ALL);
CREATE TABLE eth.receipt_cids_i (LIKE eth.receipt_cids INCLUDING ALL);
CREATE TABLE eth.transaction_cids_i (LIKE eth.transaction_cids INCLUDING ALL);
CREATE TABLE eth.uncle_cids_i (LIKE eth.uncle_cids INCLUDING ALL);
CREATE TABLE eth.header_cids_i (LIKE eth.header_cids INCLUDING ALL);
CREATE TABLE public.blocks_i (LIKE public.blocks INCLUDING ALL);

-- migrate data
INSERT INTO eth.log_cids_i (SELECT * FROM eth.log_cids);
INSERT INTO eth.access_list_elements_i (SELECT * FROM eth.access_list_elements);
INSERT INTO eth.state_accounts_i (SELECT * FROM eth.state_accounts);
INSERT INTO eth.storage_leaf_cids_i (SELECT * FROM eth.storage_leaf_cids);
INSERT INTO eth.state_leaf_cids_i (SELECT * FROM eth.state_leaf_cids);
INSERT INTO eth.receipt_cids_i (SELECT * FROM eth.receipt_cids);
INSERT INTO eth.transaction_cids_i (SELECT * FROM eth.transaction_cids);
INSERT INTO eth.uncle_cids_i (SELECT * FROM eth.uncle_cids);
INSERT INTO eth.header_cids_i (SELECT * FROM eth.header_cids);
INSERT INTO public.blocks_i (SELECT * FROM public.blocks);

-- drop hypertables
DROP TABLE eth.log_cids;
DROP TABLE eth.access_list_elements;
DROP TABLE eth.state_accounts;
DROP TABLE eth.storage_leaf_cids;
DROP TABLE eth.state_leaf_cids;
DROP TABLE eth.receipt_cids;
DROP TABLE eth.transaction_cids;
DROP TABLE eth.uncle_cids;
DROP TABLE eth.header_cids;
DROP TABLE public.blocks;

-- rename new tables
ALTER TABLE eth.log_cids_i RENAME TO log_cids;
ALTER TABLE eth.access_list_elements_i RENAME TO access_list_elements;
ALTER TABLE eth.state_accounts_i RENAME TO state_accounts;
ALTER TABLE eth.storage_leaf_cids_i RENAME TO storage_leaf_cids;
ALTER TABLE eth.state_leaf_cids_i RENAME TO state_leaf_cids;
ALTER TABLE eth.receipt_cids_i RENAME TO receipt_cids;
ALTER TABLE eth.transaction_cids_i RENAME TO transaction_cids;
ALTER TABLE eth.uncle_cids_i RENAME TO uncle_cids;
ALTER TABLE eth.header_cids_i RENAME TO header_cids;
ALTER TABLE public.blocks_i RENAME TO blocks;
