-- +goose Up
-- create new regular tables
CREATE TABLE eth.log_cids_i (LIKE eth.log_cids INCLUDING ALL);
CREATE TABLE eth.access_list_elements_i (LIKE eth.access_list_elements INCLUDING ALL);
CREATE TABLE eth.state_accounts_i (LIKE eth.state_accounts INCLUDING ALL);
CREATE TABLE eth.storage_cids_i (LIKE eth.storage_cids INCLUDING ALL);
CREATE TABLE eth.state_cids_i (LIKE eth.state_cids INCLUDING ALL);
CREATE TABLE eth.receipt_cids_i (LIKE eth.receipt_cids INCLUDING ALL);
CREATE TABLE eth.transaction_cids_i (LIKE eth.transaction_cids INCLUDING ALL);
CREATE TABLE eth.uncle_cids_i (LIKE eth.uncle_cids INCLUDING ALL);
CREATE TABLE eth.header_cids_i (LIKE eth.header_cids INCLUDING ALL);
CREATE TABLE public.blocks_i (LIKE public.blocks INCLUDING ALL);

-- turn them into distributed hypertables
SELECT create_distributed_hypertable('public.blocks_i', 'block_number', migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);
SELECT create_distributed_hypertable('eth.header_cids_i', 'block_number' migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);
SELECT create_distributed_hypertable('eth.uncle_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);
SELECT create_distributed_hypertable('eth.transaction_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);
SELECT create_distributed_hypertable('eth.receipt_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);
SELECT create_distributed_hypertable('eth.state_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);
SELECT create_distributed_hypertable('eth.storage_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);
SELECT create_distributed_hypertable('eth.state_accounts_i', 'block_number', migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);
SELECT create_distributed_hypertable('eth.access_list_elements_i', 'block_number', migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);
SELECT create_distributed_hypertable('eth.log_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768, replication_factor => 3);

-- migrate data
INSERT INTO eth.log_cids_i (SELECT * FROM eth.log_cids);
INSERT INTO eth.access_list_elements_i (SELECT eth.access_list_elements);
INSERT INTO eth.state_accounts_i (SELECT eth.state_accounts);
INSERT INTO eth.storage_cids_i (SELECT eth.storage_cids);
INSERT INTO eth.state_cids_i (SELECT eth.state_cids);
INSERT INTO eth.receipt_cids_i (SELECT eth.receipt_cids);
INSERT INTO eth.transaction_cids_i (SELECT eth.transaction_cids);
INSERT INTO eth.uncle_cids_i (SELECT eth.uncle_cids);
INSERT INTO eth.header_cids_i (SELECT eth.header_cids);
INSERT INTO public.blocks_i (SELECT public.blocks);

-- drops hypertables
DROP TABLE eth.log_cids;
DROP TABLE eth.access_list_elements;
DROP TABLE eth.state_accounts;
DROP TABLE eth.storage_cids;
DROP TABLE eth.state_cids;
DROP TABLE eth.receipt_cids;
DROP TABLE eth.transaction_cids;
DROP TABLE eth.uncle_cids;
DROP TABLE eth.header_cids;
DROP TABLE public.blocks;

-- rename distributed hypertables
ALTER TABLE eth.log_cids_i RENAME TO eth.log_cids;
ALTER TABLE eth.access_list_elements_i RENAME TO eth.access_list_elements;
ALTER TABLE eth.state_accounts_i RENAME TO eth.state_accounts;
ALTER TABLE eth.storage_cids_i RENAME TO eth.storage_cids;
ALTER TABLE eth.state_cids_i RENAME TO eth.state_cids;
ALTER TABLE eth.receipt_cids_i RENAME TO eth.receipt_cids;
ALTER TABLE eth.transaction_cids_i RENAME TO eth.transaction_cids;
ALTER TABLE eth.uncle_cids_i RENAME TO eth.uncle_cids;
ALTER TABLE eth.header_cids_i RENAME TO eth.header_cids;
ALTER TABLE public.blocks_i RENAME TO public.blocks;

-- update version
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v4.0.00-dh')
    ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v4.0.0-dh', NOW());

-- +goose Down
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v4.0.0-h')
    ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v4.0.0-h', NOW());
-- reversing conversion to hypertable requires migrating all data from every chunk back to a single table
-- create new regular tables
CREATE TABLE eth.log_cids_i (LIKE eth.log_cids INCLUDING ALL);
CREATE TABLE eth.access_list_elements_i (LIKE eth.access_list_elements INCLUDING ALL);
CREATE TABLE eth.state_accounts_i (LIKE eth.state_accounts INCLUDING ALL);
CREATE TABLE eth.storage_cids_i (LIKE eth.storage_cids INCLUDING ALL);
CREATE TABLE eth.state_cids_i (LIKE eth.state_cids INCLUDING ALL);
CREATE TABLE eth.receipt_cids_i (LIKE eth.receipt_cids INCLUDING ALL);
CREATE TABLE eth.transaction_cids_i (LIKE eth.transaction_cids INCLUDING ALL);
CREATE TABLE eth.uncle_cids_i (LIKE eth.uncle_cids INCLUDING ALL);
CREATE TABLE eth.header_cids_i (LIKE eth.header_cids INCLUDING ALL);
CREATE TABLE public.blocks_i (LIKE public.blocks INCLUDING ALL);

-- turn them into hypertables
SELECT create_hypertable('public.blocks_i', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.header_cids_i', 'block_number' migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.uncle_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.transaction_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.receipt_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.state_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.storage_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.state_accounts_i', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.access_list_elements_i', 'block_number', migrate_data => true, chunk_time_interval => 32768);
SELECT create_hypertable('eth.log_cids_i', 'block_number', migrate_data => true, chunk_time_interval => 32768);

-- migrate data
INSERT INTO eth.log_cids_i (SELECT * FROM eth.log_cids);
INSERT INTO eth.access_list_elements_i (SELECT eth.access_list_elements);
INSERT INTO eth.state_accounts_i (SELECT eth.state_accounts);
INSERT INTO eth.storage_cids_i (SELECT eth.storage_cids);
INSERT INTO eth.state_cids_i (SELECT eth.state_cids);
INSERT INTO eth.receipt_cids_i (SELECT eth.receipt_cids);
INSERT INTO eth.transaction_cids_i (SELECT eth.transaction_cids);
INSERT INTO eth.uncle_cids_i (SELECT eth.uncle_cids);
INSERT INTO eth.header_cids_i (SELECT eth.header_cids);
INSERT INTO public.blocks_i (SELECT public.blocks);

-- drops distributed hypertables
DROP TABLE eth.log_cids;
DROP TABLE eth.access_list_elements;
DROP TABLE eth.state_accounts;
DROP TABLE eth.storage_cids;
DROP TABLE eth.state_cids;
DROP TABLE eth.receipt_cids;
DROP TABLE eth.transaction_cids;
DROP TABLE eth.uncle_cids;
DROP TABLE eth.header_cids;
DROP TABLE public.blocks;

-- rename hypertable tables
ALTER TABLE eth.log_cids_i RENAME TO eth.log_cids;
ALTER TABLE eth.access_list_elements_i RENAME TO eth.access_list_elements;
ALTER TABLE eth.state_accounts_i RENAME TO eth.state_accounts;
ALTER TABLE eth.storage_cids_i RENAME TO eth.storage_cids;
ALTER TABLE eth.state_cids_i RENAME TO eth.state_cids;
ALTER TABLE eth.receipt_cids_i RENAME TO eth.receipt_cids;
ALTER TABLE eth.transaction_cids_i RENAME TO eth.transaction_cids;
ALTER TABLE eth.uncle_cids_i RENAME TO eth.uncle_cids;
ALTER TABLE eth.header_cids_i RENAME TO eth.header_cids;
ALTER TABLE public.blocks_i RENAME TO public.blocks;
