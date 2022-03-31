-- +goose Up
ALTER TABLE public.nodes
ADD CONSTRAINT pk_public_nodes PRIMARY KEY (node_id);

ALTER TABLE eth.header_cids
ADD CONSTRAINT pk_eth_header_cids PRIMARY KEY (block_hash);

ALTER TABLE eth.uncle_cids
ADD CONSTRAINT pk_eth_uncle_cids PRIMARY KEY (block_hash);

ALTER TABLE eth.transaction_cids
ADD CONSTRAINT pk_eth_transaction_cids PRIMARY KEY (tx_hash);

ALTER TABLE eth.receipt_cids
ADD CONSTRAINT pk_eth_receipt_cids PRIMARY KEY (tx_id);

ALTER TABLE eth.access_list_elements
ADD CONSTRAINT pk_eth_access_list_elements PRIMARY KEY (tx_id, index);

ALTER TABLE eth.log_cids
ADD CONSTRAINT pk_eth_log_cids PRIMARY KEY (rct_id, index);

ALTER TABLE eth.state_cids
ADD CONSTRAINT pk_eth_state_cids PRIMARY KEY (header_id, state_path);

ALTER TABLE eth.storage_cids
ADD CONSTRAINT pk_eth_storage_cids PRIMARY KEY (header_id, state_path, storage_path);

ALTER TABLE eth.state_accounts
ADD CONSTRAINT pk_eth_state_accounts PRIMARY KEY (header_id, state_path);

-- +goose Down
ALTER TABLE eth.state_accounts
DROP CONSTRAINT pk_eth_state_accounts;

ALTER TABLE eth.storage_cids
DROP CONSTRAINT pk_eth_storage_cids;

ALTER TABLE eth.state_cids
DROP CONSTRAINT pk_eth_state_cids;

ALTER TABLE eth.log_cids
DROP CONSTRAINT pk_eth_log_cids;

ALTER TABLE eth.access_list_elements
DROP CONSTRAINT pk_eth_access_list_elements;

ALTER TABLE eth.receipt_cids
DROP CONSTRAINT pk_eth_receipt_cids;

ALTER TABLE eth.transaction_cids
DROP CONSTRAINT pk_eth_transaction_cids;

ALTER TABLE eth.uncle_cids
DROP CONSTRAINT pk_eth_uncle_cids;

ALTER TABLE eth.header_cids
DROP CONSTRAINT pk_eth_header_cids;

ALTER TABLE public.nodes
DROP CONSTRAINT pk_public_nodes;
