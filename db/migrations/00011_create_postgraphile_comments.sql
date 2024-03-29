-- +goose Up
COMMENT ON TABLE public.nodes IS E'@name NodeInfo';
COMMENT ON TABLE eth.transaction_cids IS E'@name EthTransactionCids';
COMMENT ON TABLE eth.header_cids IS E'@name EthHeaderCids';
COMMENT ON COLUMN public.nodes.node_id IS E'@name ChainNodeID';
COMMENT ON COLUMN eth.header_cids.node_ids IS E'@name EthNodeIDs';

-- +goose Down

COMMENT ON TABLE public.nodes IS NULL;
COMMENT ON TABLE eth.transaction_cids IS NULL;
COMMENT ON TABLE eth.header_cids IS NULL;
COMMENT ON COLUMN public.nodes.node_id IS NULL;
COMMENT ON COLUMN eth.header_cids.node_ids IS NULL;
