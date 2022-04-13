-- +goose Up
-- +goose StatementBegin
-- returns if a state leaf node was removed within the provided block number
CREATE OR REPLACE FUNCTION was_state_leaf_removed(key character varying, hash character varying)
    RETURNS boolean AS $$
    SELECT state_cids.node_type = 3
    FROM eth.state_cids
             INNER JOIN eth.header_cids ON (state_cids.header_id = header_cids.block_hash)
    WHERE state_leaf_key = key
      AND state_cids.block_number <= (SELECT block_number
                           FROM eth.header_cids
                           WHERE block_hash = hash)
    ORDER BY state_cids.block_number DESC LIMIT 1;
$$
language sql;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TYPE child_result AS (
    has_child BOOLEAN,
    children eth.header_cids[]
);

CREATE OR REPLACE FUNCTION has_child(hash VARCHAR(66), height BIGINT) RETURNS child_result AS
$BODY$
DECLARE
  child_height INT;
  temp_child eth.header_cids;
  new_child_result child_result;
BEGIN
  child_height = height + 1;
  -- short circuit if there are no children
  SELECT exists(SELECT 1
              FROM eth.header_cids
              WHERE parent_hash = hash
                AND block_number = child_height
              LIMIT 1)
  INTO new_child_result.has_child;
  -- collect all the children for this header
  IF new_child_result.has_child THEN
    FOR temp_child IN
    SELECT * FROM eth.header_cids WHERE parent_hash = hash AND block_number = child_height
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
CREATE OR REPLACE FUNCTION canonical_header_from_array(headers eth.header_cids[]) RETURNS eth.header_cids AS
$BODY$
DECLARE
  canonical_header eth.header_cids;
  canonical_child eth.header_cids;
  header eth.header_cids;
  current_child_result child_result;
  child_headers eth.header_cids[];
  current_header_with_child eth.header_cids;
  has_children_count INT DEFAULT 0;
BEGIN
  -- for each header in the provided set
  FOREACH header IN ARRAY headers
  LOOP
    -- check if it has any children
    current_child_result = has_child(header.block_hash, header.block_number);
    IF current_child_result.has_child THEN
      -- if it does, take note
      has_children_count = has_children_count + 1;
      current_header_with_child = header;
      -- and add the children to the growing set of child headers
      child_headers = array_cat(child_headers, current_child_result.children);
    END IF;
  END LOOP;
  -- if none of the headers had children, none is more canonical than the other
  IF has_children_count = 0 THEN
    -- return the first one selected
    SELECT * INTO canonical_header FROM unnest(headers) LIMIT 1;
  -- if only one header had children, it can be considered the heaviest/canonical header of the set
  ELSIF has_children_count = 1 THEN
    -- return the only header with a child
    canonical_header = current_header_with_child;
  -- if there are multiple headers with children
  ELSE
    -- find the canonical header from the child set
    canonical_child = canonical_header_from_array(child_headers);
    -- the header that is parent to this header, is the canonical header at this level
    SELECT * INTO canonical_header FROM unnest(headers)
    WHERE block_hash = canonical_child.parent_hash;
  END IF;
  RETURN canonical_header;
END
$BODY$
LANGUAGE 'plpgsql';
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION canonical_header_hash(height BIGINT) RETURNS character varying AS
$BODY$
DECLARE
  canonical_header eth.header_cids;
  headers eth.header_cids[];
  header_count INT;
  temp_header eth.header_cids;
BEGIN
  -- collect all headers at this height
  FOR temp_header IN
  SELECT * FROM eth.header_cids WHERE block_number = height
  LOOP
    headers = array_append(headers, temp_header);
  END LOOP;
  -- count the number of headers collected
  header_count = array_length(headers, 1);
  -- if we have less than 1 header, return NULL
  IF header_count IS NULL OR header_count < 1 THEN
    RETURN NULL;
  -- if we have one header, return its hash
  ELSIF header_count = 1 THEN
    RETURN headers[1].block_hash;
  -- if we have multiple headers we need to determine which one is canonical
  ELSE
    canonical_header = canonical_header_from_array(headers);
    RETURN canonical_header.block_hash;
  END IF;
END
$BODY$
LANGUAGE 'plpgsql';
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TYPE state_node_result AS (
    data                  BYTEA,
    state_leaf_key        VARCHAR(66),
    cid                   TEXT,
    state_path            BYTEA,
    node_type             INTEGER,
    mh_key                TEXT
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION state_snapshot(starting_height BIGINT, ending_height BIGINT) RETURNS void AS
$BODY$
DECLARE
    canonical_hash VARCHAR(66);
    results state_node_result[];
BEGIN
    -- get the canonical hash for the header at ending_height
    canonical_hash = canonical_header_hash(ending_height);
    IF canonical_hash IS NULL THEN
        RAISE EXCEPTION 'cannot create state snapshot, no header can be found at height %', ending_height;
    END IF;

    -- select all of the state nodes for this snapshot: the latest state node record at every unique path, that is not a
    -- "removed" node-type entry
    SELECT DISTINCT ON (state_path) blocks.data, state_cids.state_leaf_key, state_cids.cid, state_cids.state_path,
        state_cids.node_type, state_cids.mh_key
    INTO results
    FROM eth.state_cids
        INNER JOIN public.blocks
            ON (state_cids.mh_key, state_cids.block_number) = (blocks.key, blocks.block_number)
    WHERE state_cids.block_number BETWEEN starting_height AND ending_height
    ORDER BY state_path, block_number DESC;

    -- from the set returned above, insert public.block records at the ending_height block number
    INSERT INTO public.blocks (block_number, key, data)
    SELECT ending_height, r.mh_key, r.data
    FROM results r;

    -- from the set returned above, insert eth.state_cids records at the ending_height block number
    -- anchoring all the records to the canonical header found at ending_height
    INSERT INTO eth.state_cids (block_number, header_id, state_leaf_key, cid, state_path, node_type, diff, mh_key)
    SELECT ending_height, canonical_hash, r.state_leaf_key, r.cid, r.state_path, r.node_type, false, r.mh_key
    FROM results r
    ON CONFLICT (state_path, header_id) DO NOTHING;
END
$BODY$
LANGUAGE 'plpgsql';
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TYPE storage_node_result AS (
    data                  BYTEA,
    state_path            BYTEA,
    storage_leaf_key      VARCHAR(66),
    cid                   TEXT,
    storage_path          BYTEA,
    node_type             INTEGER,
    mh_key                TEXT
);
-- +goose StatementEnd

-- +goose StatementBegin
-- this should only be ran after a state_snapshot has been completed
-- this should probably be rolled together with state_snapshot into a single procedure...
CREATE OR REPLACE FUNCTION storage_snapshot(starting_height BIGINT, ending_height BIGINT) RETURNS void AS
$BODY$
DECLARE
    canonical_hash VARCHAR(66);
    results storage_node_result[];
BEGIN
    -- get the canonical hash for the header at ending_height
    SELECT canonical_header_hash(ending_height) INTO canonical_hash;
    IF canonical_hash IS NULL THEN
        RAISE EXCEPTION 'cannot create state snapshot, no header can be found at height %', ending_height;
    END IF;

    -- select all of the storage nodes for this snapshot: the latest storage node record at every unique path, that is not a
    -- "removed" node-type entry
    SELECT DISTINCT ON (state_path, storage_path) block.data, storage_cids.state_path, storage_cids.storage_leaf_key,
     storage_cids.cid, storage_cids.storage_path, storage_cids.node_type, storage_cids.mh_key
    INTO results
    FROM eth.storage_cids
        INNER JOIN public.blocks
        ON (storage_cids.mh_key, storage_cids.block_number) = (blocks.key, blocks.block_number)
    WHERE storage_cids.block_number BETWEEN starting_height AND ending_height
    ORDER BY state_path, storage_path, block_number DESC;

    -- from the set returned above, insert public.block records at the ending_height block number
    INSERT INTO public.blocks (block_number, key, data)
    SELECT ending_height, r.mh_key, r.data
    FROM results r;

    -- from the set returned above, insert eth.state_cids records at the ending_height block number
    -- anchoring all the records to the canonical header found at ending_height
    INSERT INTO eth.storage_cids (block_number, header_id, state_path, storage_leaf_key, cid, storage_path,
                              node_type, diff, mh_key)
    SELECT ending_height, canonical_hash, r.state_path, r.storage_leaf_key, r.cid, r.storage_path, r.node_type, false, r.mh_key
    FROM results r
    ON CONFLICT (storage_path, state_path, header_id) DO NOTHING;
END
$BODY$
LANGUAGE 'plpgsql';
-- +goose StatementEnd

-- +goose Down
DROP FUNCTION storage_snapshot;
DROP TYPE storage_node_result;
DROP FUNCTION state_snapshot;
DROP TYPE state_node_result;
DROP FUNCTION was_state_leaf_removed;
DROP FUNCTION canonical_header_hash;
DROP FUNCTION canonical_header_from_array;
DROP FUNCTION has_child;
DROP TYPE child_result;
