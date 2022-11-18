-- +goose Up
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION public.was_state_leaf_removed_by_number(key character varying, blockNo bigint)
    RETURNS boolean AS $$
SELECT state_cids.node_type = 3
FROM eth.state_cids
         INNER JOIN eth.header_cids ON (state_cids.header_id = header_cids.block_hash)
WHERE state_leaf_key = key
  AND state_cids.block_number <= blockNo
ORDER BY state_cids.block_number DESC LIMIT 1;
$$
language sql;

CREATE OR REPLACE FUNCTION public.get_storage_at_by_number(stateLeafKey text, storageLeafKey text, blockNo bigint)
    RETURNS TABLE
            (
                cid                text,
                mh_key             text,
                block_number       bigint,
                node_type          integer,
                state_leaf_removed bool
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    statePath             bytea;
    temp_header           text;
    temp_canonical_header text;
BEGIN
    CREATE TEMP TABLE tmp_tt_stg2
    (
        header_id          text,
        cid                text,
        mh_key             text,
        block_number       bigint,
        node_type          integer,
        state_leaf_removed bool
    ) ON COMMIT DROP;

    SELECT state_path, STATE_CIDS.block_number
    INTO statePath, blockNo
    FROM ETH.STATE_CIDS
    WHERE STATE_LEAF_KEY = stateLeafKey
      AND STATE_CIDS.BLOCK_NUMBER <= blockNo
    ORDER BY STATE_CIDS.BLOCK_NUMBER DESC
    LIMIT 1;

    INSERT INTO tmp_tt_stg2
    SELECT STORAGE_CIDS.HEADER_ID,
           STORAGE_CIDS.CID,
           STORAGE_CIDS.MH_KEY,
           STORAGE_CIDS.BLOCK_NUMBER,
           STORAGE_CIDS.NODE_TYPE,
           was_state_leaf_removed_by_number(
                   stateLeafKey,
                   blockNo
               ) AS STATE_LEAF_REMOVED
    FROM eth.storage_cids
             INNER JOIN ETH.STATE_CIDS ON (
                STORAGE_CIDS.HEADER_ID = STATE_CIDS.HEADER_ID
            AND STORAGE_CIDS.BLOCK_NUMBER = STATE_CIDS.BLOCK_NUMBER
        )
    WHERE storage_leaf_key = storageLeafKey
      AND storage_cids.block_number <= blockNo
      AND storage_cids.state_path = statePath
      AND state_leaf_key = stateLeafKey
      AND storage_cids.block_number <= blockNo
    ORDER BY state_cids.block_number DESC
    LIMIT 1;

    SELECT header_id, canonical_header_hash(tmp_tt_stg2.block_number), tmp_tt_stg2.block_number
    into temp_header, temp_canonical_header, blockNo
    from tmp_tt_stg2;
    IF temp_header IS NOT NULL AND temp_header != temp_canonical_header THEN
        raise notice 'get_storage_at_by_number (% is NULL OR % != %), falling back to full check.', temp_header, temp_header, temp_canonical_header;
        TRUNCATE tmp_tt_stg2;
        -- There is a slim chance of a false negative, if there is a common state_path at a lower height than we picked above,
        -- or a different one at the same height.  The disadvantage is that this is very uncommon, and the join on
        -- STORAGE_CIDS.STATE_PATH = STATE_CIDS.STATE_PATH is quite expensive when there are a lot of candidate rows,
        -- so we wish to avoid this more expensive check when possible.
        INSERT INTO tmp_tt_stg2
        SELECT STORAGE_CIDS.HEADER_ID,
               STORAGE_CIDS.CID,
               STORAGE_CIDS.MH_KEY,
               STORAGE_CIDS.BLOCK_NUMBER,
               STORAGE_CIDS.NODE_TYPE,
               was_state_leaf_removed_by_number(
                       stateLeafKey,
                       blockNo
                   ) AS STATE_LEAF_REMOVED
        FROM ETH.STORAGE_CIDS
                 INNER JOIN ETH.STATE_CIDS ON (
                    STORAGE_CIDS.HEADER_ID = STATE_CIDS.HEADER_ID
                AND STORAGE_CIDS.BLOCK_NUMBER = STATE_CIDS.BLOCK_NUMBER
                AND STORAGE_CIDS.STATE_PATH = STATE_CIDS.STATE_PATH
            )
                 INNER JOIN ETH.HEADER_CIDS ON (
                    STATE_CIDS.HEADER_ID = HEADER_CIDS.BLOCK_HASH
                AND STATE_CIDS.BLOCK_NUMBER = HEADER_CIDS.BLOCK_NUMBER
            )
        WHERE STATE_LEAF_KEY = stateLeafKey
          AND STATE_CIDS.BLOCK_NUMBER = blockNo
          AND STORAGE_LEAF_KEY = storageLeafKey
          AND STORAGE_CIDS.BLOCK_NUMBER = blockNo
          AND HEADER_CIDS.BLOCK_NUMBER = blockNo
          AND HEADER_CIDS.BLOCK_HASH = temp_canonical_header
        ORDER BY HEADER_CIDS.BLOCK_NUMBER DESC
        LIMIT 1;
    END IF;

    RETURN QUERY SELECT t.cid, t.mh_key, t.block_number, t.node_type, t.state_leaf_removed from tmp_tt_stg2 as t;
END
$$;

CREATE OR REPLACE FUNCTION public.get_storage_at_by_hash(stateLeafKey text, storageLeafKey text, blockHash text)
    RETURNS TABLE(cid text, mh_key text, block_number bigint, node_type integer, state_leaf_removed bool) LANGUAGE plpgsql
AS $$
DECLARE
    blockNo bigint;
BEGIN
    SELECT h.BLOCK_NUMBER INTO blockNo FROM ETH.HEADER_CIDS as h WHERE BLOCK_HASH = blockHash limit 1;
    IF blockNo IS NULL THEN
        RETURN;
    END IF;
    RETURN QUERY SELECT * FROM get_storage_at_by_number(stateLeafKey, storageLeafKey, blockNo);
END
$$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP FUNCTION public.was_state_leaf_removed_by_number;
DROP FUNCTION public.get_storage_at_by_number;
DROP FUNCTION public.get_storage_at_by_hash;
-- +goose StatementEnd
