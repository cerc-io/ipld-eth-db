-- +goose Up
-- +goose StatementBegin
-- returns whether the state leaf key is vacated (previously existed but now is empty) at the provided block hash
CREATE OR REPLACE FUNCTION was_state_leaf_removed(v_key VARCHAR(66), v_hash VARCHAR)
    RETURNS boolean AS $$
    SELECT state_cids.removed = true
    FROM eth.state_cids
             INNER JOIN eth.header_cids ON (state_cids.header_id = header_cids.block_hash)
    WHERE state_leaf_key = v_key
      AND state_cids.block_number <= (SELECT block_number
                           FROM eth.header_cids
                           WHERE block_hash = v_hash)
    ORDER BY state_cids.block_number DESC LIMIT 1;
$$
language sql;
-- +goose StatementEnd

-- +goose StatementBegin
-- returns whether the state leaf key is vacated (previously existed but now is empty) at the provided block height
CREATE OR REPLACE FUNCTION public.was_state_leaf_removed_by_number(v_key VARCHAR(66), v_block_no BIGINT)
    RETURNS BOOLEAN AS $$
    SELECT state_cids.removed = true
    FROM eth.state_cids
             INNER JOIN eth.header_cids ON (state_cids.header_id = header_cids.block_hash)
    WHERE state_leaf_key = v_key
      AND state_cids.block_number <= v_block_no
    ORDER BY state_cids.block_number DESC LIMIT 1;
$$
language sql;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION canonical_header_hash(height BIGINT) RETURNS character varying AS
$BODY$
    SELECT block_hash from eth.header_cids WHERE block_number = height AND canonical = true LIMIT 1;
$BODY$
LANGUAGE sql;
-- +goose StatementEnd

-- +goose Down
DROP FUNCTION was_state_leaf_removed;
DROP FUNCTION was_state_leaf_removed_by_number;
DROP FUNCTION canonical_header_hash;
