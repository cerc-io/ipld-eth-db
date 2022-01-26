-- +goose Up
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
