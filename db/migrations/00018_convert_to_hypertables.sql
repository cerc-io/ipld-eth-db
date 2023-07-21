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
