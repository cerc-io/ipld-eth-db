-- +goose Up
ALTER TABLE eth.log_cids
DROP CONSTRAINT log_cids_receipt_cids_fkey;

ALTER TABLE eth.log_cids
DROP CONSTRAINT log_cids_ipld_blocks_fkey;

ALTER TABLE eth.storage_cids
DROP CONSTRAINT storage_cids_state_cids_fkey;

ALTER TABLE eth.storage_cids
DROP CONSTRAINT storage_cids_ipld_blocks_fkey;

ALTER TABLE eth.state_cids
DROP CONSTRAINT state_cids_header_cids_fkey;

ALTER TABLE eth.state_cids
DROP CONSTRAINT state_cids_ipld_blocks_fkey;

ALTER TABLE eth.receipt_cids
DROP CONSTRAINT receipt_cids_transaction_cids_fkey;

ALTER TABLE eth.receipt_cids
DROP CONSTRAINT receipt_cids_ipld_blocks_fkey;

ALTER TABLE eth.transaction_cids
DROP CONSTRAINT transaction_cids_header_cids_fkey;

ALTER TABLE eth.transaction_cids
DROP CONSTRAINT transaction_cids_ipld_blocks_fkey;

ALTER TABLE eth.uncle_cids
DROP CONSTRAINT uncle_cids_header_cids_fkey;

ALTER TABLE eth.uncle_cids
DROP CONSTRAINT uncle_cids_ipld_blocks_fkey;

ALTER TABLE eth.header_cids
DROP CONSTRAINT header_cids_ipld_blocks_fkey;

-- +goose Down
ALTER TABLE eth.header_cids
ADD CONSTRAINT header_cids_ipld_blocks_fkey
FOREIGN KEY (cid, block_number)
REFERENCES ipld.blocks (key, block_number);

ALTER TABLE eth.uncle_cids
ADD CONSTRAINT uncle_cids_ipld_blocks_fkey
FOREIGN KEY (cid, block_number)
REFERENCES ipld.blocks (key, block_number);

ALTER TABLE eth.uncle_cids
ADD CONSTRAINT uncle_cids_header_cids_fkey
FOREIGN KEY (header_id, block_number)
REFERENCES eth.header_cids (block_hash, block_number);

ALTER TABLE eth.transaction_cids
ADD CONSTRAINT transaction_cids_ipld_blocks_fkey
FOREIGN KEY (cid, block_number)
REFERENCES ipld.blocks (key, block_number);

ALTER TABLE eth.transaction_cids
ADD CONSTRAINT transaction_cids_header_cids_fkey
FOREIGN KEY (header_id, block_number)
REFERENCES eth.header_cids (block_hash, block_number);

ALTER TABLE eth.receipt_cids
ADD CONSTRAINT receipt_cids_ipld_blocks_fkey
FOREIGN KEY (cid, block_number)
REFERENCES ipld.blocks (key, block_number);

ALTER TABLE eth.receipt_cids
ADD CONSTRAINT receipt_cids_transaction_cids_fkey
FOREIGN KEY (tx_id, header_id, block_number)
REFERENCES eth.transaction_cids (tx_hash, header_id, block_number);

ALTER TABLE eth.state_cids
ADD CONSTRAINT state_cids_ipld_blocks_fkey
FOREIGN KEY (cid, block_number)
REFERENCES ipld.blocks (key, block_number);

ALTER TABLE eth.state_cids
ADD CONSTRAINT state_cids_header_cids_fkey
FOREIGN KEY (header_id, block_number)
REFERENCES eth.header_cids (block_hash, block_number);

ALTER TABLE eth.storage_cids
ADD CONSTRAINT storage_cids_ipld_blocks_fkey
FOREIGN KEY (cid, block_number)
REFERENCES ipld.blocks (key, block_number);

ALTER TABLE eth.storage_cids
ADD CONSTRAINT storage_cids_state_cids_fkey
FOREIGN KEY (state_leaf_key, header_id, block_number)
REFERENCES eth.state_cids (state_leaf_key, header_id, block_number);

ALTER TABLE eth.log_cids
ADD CONSTRAINT log_cids_ipld_blocks_fkey
FOREIGN KEY (cid, block_number)
REFERENCES ipld.blocks (key, block_number);

ALTER TABLE eth.log_cids
ADD CONSTRAINT log_cids_receipt_cids_fkey
FOREIGN KEY (rct_id, header_id, block_number)
REFERENCES eth.receipt_cids (tx_id, header_id, block_number);
