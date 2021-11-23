-- +goose Up
ALTER TABLE public.blocks SET UNLOGGED;
ALTER TABLE public.nodes SET UNLOGGED;
ALTER TABLE eth.header_cids SET UNLOGGED;
ALTER TABLE eth.uncle_cids SET UNLOGGED;
ALTER TABLE eth.transaction_cids SET UNLOGGED;
ALTER TABLE eth.receipt_cids SET UNLOGGED;
ALTER TABLE eth.state_cids SET UNLOGGED;
ALTER TABLE eth.storage_cids SET UNLOGGED;
ALTER TABLE eth.state_accounts SET UNLOGGED;
ALTER TABLE eth.access_list_elements SET UNLOGGED;
ALTER TABLE eth.log_cids SET UNLOGGED;

-- +goose Down
ALTER TABLE public.blocks SET LOGGED;
ALTER TABLE public.nodes SET LOGGED;
ALTER TABLE eth.header_cids SET LOGGED;
ALTER TABLE eth.uncle_cids SET LOGGED;
ALTER TABLE eth.transaction_cids SET LOGGED;
ALTER TABLE eth.receipt_cids SET LOGGED;
ALTER TABLE eth.state_cids SET LOGGED;
ALTER TABLE eth.storage_cids SET LOGGED;
ALTER TABLE eth.state_accounts SET LOGGED;
ALTER TABLE eth.access_list_elements SET LOGGED;
ALTER TABLE eth.log_cids SET LOGGED;
