-- +goose Up
ALTER TABLE public.nodes
ADD CONSTRAINT pk_public_nodes PRIMARY KEY (node_id);

ALTER TABLE eth.header_cids
ADD CONSTRAINT pk_eth_header_cids PRIMARY KEY (block_hash);

ALTER TABLE eth.uncle_cids
ADD CONSTRAINT pk_eth_uncle_cids PRIMARY KEY (block_hash);

ALTER TABLE eth.transaction_cids
ADD CONSTRAINT pk_eth_transaction_cids PRIMARY KEY (tx_hash);

-- +goose Down
ALTER TABLE eth.transaction_cids
DROP CONSTRAINT pk_eth_transaction_cids;

ALTER TABLE eth.uncle_cids
DROP CONSTRAINT pk_eth_uncle_cids;

ALTER TABLE eth.header_cids
DROP CONSTRAINT pk_eth_header_cids;

ALTER TABLE public.nodes
DROP CONSTRAINT pk_public_nodes;
