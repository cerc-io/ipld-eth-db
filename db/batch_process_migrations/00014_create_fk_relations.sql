-- +goose Up
ALTER TABLE eth.header_cids
ADD CONSTRAINT fk_header_mh_key
    FOREIGN KEY (mh_key) REFERENCES public.blocks (key)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.header_cids
ADD CONSTRAINT fk_header_node_id
    FOREIGN KEY (node_id) REFERENCES public.nodes (node_id)
    ON DELETE CASCADE;

ALTER TABLE eth.uncle_cids
ADD CONSTRAINT fk_uncle_mh_key
    FOREIGN KEY (mh_key) REFERENCES public.blocks (key)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.uncle_cids
ADD CONSTRAINT fk_uncle_header_id
    FOREIGN KEY (header_id) REFERENCES eth.header_cids (block_hash)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.transaction_cids
ADD CONSTRAINT fk_tx_mh_key
    FOREIGN KEY (mh_key) REFERENCES public.blocks (key)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.transaction_cids
ADD CONSTRAINT fk_tx_header_id
    FOREIGN KEY (header_id) REFERENCES eth.header_cids (block_hash)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.receipt_cids
ADD CONSTRAINT fk_rct_leaf_mh_key
    FOREIGN KEY (leaf_mh_key) REFERENCES public.blocks (key)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.receipt_cids
ADD CONSTRAINT fk_rct_tx_id
    FOREIGN KEY (tx_id) REFERENCES eth.transaction_cids (tx_hash)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.state_cids
ADD CONSTRAINT fk_state_mh_key
    FOREIGN KEY (mh_key) REFERENCES public.blocks (key)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.state_cids
ADD CONSTRAINT fk_state_header_id
    FOREIGN KEY (header_id) REFERENCES eth.header_cids (block_hash)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.storage_cids
ADD CONSTRAINT fk_storage_mh_key
    FOREIGN KEY (mh_key) REFERENCES public.blocks (key)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.storage_cids
ADD CONSTRAINT fk_storage_header_id_state_path
    FOREIGN KEY (header_id, state_path) REFERENCES eth.state_cids (header_id, state_path)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.state_accounts
ADD CONSTRAINT fk_account_header_id_state_path
    FOREIGN KEY (header_id, state_path) REFERENCES eth.state_cids (header_id, state_path)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.access_list_elements
ADD CONSTRAINT fk_access_list_tx_id
    FOREIGN KEY (tx_id) REFERENCES eth.transaction_cids (tx_hash)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.log_cids
ADD CONSTRAINT fk_log_leaf_mh_key
    FOREIGN KEY (leaf_mh_key) REFERENCES public.blocks (key)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE eth.log_cids
ADD CONSTRAINT fk_log_rct_id
    FOREIGN KEY (rct_id) REFERENCES eth.receipt_cids (tx_id)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

-- +goose Down
ALTER TABLE eth.header_cids
DROP CONSTRAINT fk_header_mh_key;

ALTER TABLE eth.header_cids
DROP CONSTRAINT fk_header_node_id;

ALTER TABLE eth.uncle_cids
DROP CONSTRAINT fk_uncle_mh_key;

ALTER TABLE eth.uncle_cids
DROP CONSTRAINT fk_uncle_header_id;

ALTER TABLE eth.transaction_cids
DROP CONSTRAINT fk_tx_mh_key;

ALTER TABLE eth.transaction_cids
DROP CONSTRAINT fk_tx_header_id;

ALTER TABLE eth.receipt_cids
DROP CONSTRAINT fk_rct_leaf_mh_key;

ALTER TABLE eth.receipt_cids
DROP CONSTRAINT fk_rct_tx_id;

ALTER TABLE eth.state_cids
DROP CONSTRAINT fk_state_mh_key;

ALTER TABLE eth.state_cids
DROP CONSTRAINT fk_state_header_id;

ALTER TABLE eth.storage_cids
DROP CONSTRAINT fk_storage_mh_key;

ALTER TABLE eth.storage_cids
DROP CONSTRAINT fk_storage_header_id_state_path;

ALTER TABLE eth.state_accounts
DROP CONSTRAINT fk_account_header_id_state_path;

ALTER TABLE eth.access_list_elements
DROP CONSTRAINT fk_access_list_tx_id;

ALTER TABLE eth.log_cids
DROP CONSTRAINT fk_log_leaf_mh_key;

ALTER TABLE eth.log_cids
DROP CONSTRAINT fk_log_rct_id;
