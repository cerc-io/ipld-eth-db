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
-- duplicate of eth.header_cids as a separate type: if we use the table directly, dropping the hypertables
-- on downgrade of step 00018 will fail due to the dependency on this type.
CREATE TYPE header_result AS (
    block_number bigint,
    block_hash character varying(66),
    parent_hash character varying(66),
    cid text,
    td numeric,
    node_ids character varying(128)[],
    reward numeric,
    state_root character varying(66),
    tx_root character varying(66),
    receipt_root character varying(66),
    uncles_hash character varying(66),
    bloom bytea,
    "timestamp" bigint,
    coinbase character varying(66),
    canonical bool
);

CREATE TYPE child_result AS (
    has_child BOOLEAN,
    children header_result[]
);

CREATE OR REPLACE FUNCTION get_child(hash VARCHAR(66), height BIGINT) RETURNS child_result AS
$BODY$
DECLARE
  child_height INT;
  temp_child header_result;
  new_child_result child_result;
BEGIN
  child_height = height + 1;
  -- short circuit if there are no children
  SELECT exists(SELECT 1
              FROM eth.header_cids
              WHERE parent_hash = hash
                AND block_number = child_height
                AND canonical = true
              LIMIT 1)
  INTO new_child_result.has_child;
  -- collect all the children for this header
  IF new_child_result.has_child THEN
    FOR temp_child IN
    SELECT * FROM eth.header_cids WHERE parent_hash = hash AND block_number = child_height AND canonical = true
    LOOP
      new_child_result.children = array_append(new_child_result.children, temp_child);
    END LOOP;
  END IF;
  RETURN new_child_result;
END
$BODY$
LANGUAGE 'plpgsql';
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
DROP FUNCTION get_child;
DROP TYPE child_result;
