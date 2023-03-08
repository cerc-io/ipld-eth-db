-- +goose Up
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION public.get_storage_at_by_number(v_state_leaf_key text, v_storage_leaf_key text, v_block_no bigint)
    RETURNS TABLE
            (
                cid                TEXT,
                block_number       BIGINT,
                removed            BOOL,
                state_leaf_removed BOOL
            )
AS
$BODY$
DECLARE
    v_state_path       BYTEA;
    v_header           TEXT;
    v_canonical_header TEXT;
BEGIN
    CREATE TEMP TABLE tmp_tt_stg2
    (
        header_id          TEXT,
        cid                TEXT,
        block_number       BIGINT,
        removed            BOOL,
        state_leaf_removed BOOL
    ) ON COMMIT DROP;

    -- in best case scenario, the latest record we find for the provided keys is for a canonical block
    INSERT INTO tmp_tt_stg2
    SELECT storage_cids.header_id,
           storage_cids.cid,
           storage_cids.block_number,
           storage_cids.removed,
           was_state_leaf_removed_by_number(v_state_leaf_key, v_block_no) AS state_leaf_removed
    FROM eth.storage_cids
    WHERE storage_leaf_key = v_storage_leaf_key
      AND storage_cids.state_leaf_key = v_state_leaf_key -- can lookup directly on the leaf key in v5
      AND storage_cids.block_number <= v_block_no
    ORDER BY storage_cids.block_number DESC LIMIT 1;

    -- check if result is from canonical state
    SELECT header_id, canonical_header_hash(tmp_tt_stg2.block_number), tmp_tt_stg2.block_number
    INTO v_header, v_canonical_header, v_block_no
    FROM tmp_tt_stg2 LIMIT 1;

    IF v_header IS NULL OR v_header != v_canonical_header THEN
        RAISE NOTICE 'get_storage_at_by_number: chosen header NULL OR % != canonical header % for block number %, trying again.', v_header, v_canonical_header, v_block_no;
        TRUNCATE tmp_tt_stg2;
        -- If we hit on a non-canonical block, we need to go back and do a comprehensive check.
        -- We try to avoid this to avoid joining between storage_cids, state_cids, and header_cids
        INSERT INTO tmp_tt_stg2
        SELECT storage_cids.header_id,
               storage_cids.cid,
               storage_cids.block_number,
               storage_cids.removed,
               was_state_leaf_removed_by_number(
                       v_state_leaf_key,
                       v_block_no
                   ) AS state_leaf_removed
        FROM eth.storage_cids
                 INNER JOIN eth.state_cids ON (
                    storage_cids.header_id = state_cids.header_id
                AND storage_cids.block_number = state_cids.block_number
                AND storage_cids.state_leaf_key = state_cids.state_leaf_key
            )
                 INNER JOIN eth.header_cids ON (
                    state_cids.header_id = header_cids.block_hash
                AND state_cids.block_number = header_cids.block_number
            )
        WHERE state_leaf_key = v_state_leaf_key
          AND storage_leaf_key = v_storage_leaf_key
          AND state_cids.block_number <= v_block_no
          AND storage_cids.block_number <= v_block_no
          AND header_cids.block_number <= v_block_no
          AND header_cids.block_hash = (SELECT canonical_header_hash(header_cids.block_number))
        ORDER BY header_cids.block_number DESC LIMIT 1;
    END IF;

    RETURN QUERY SELECT t.cid, t.block_number, t.removed, t.state_leaf_removed
                    FROM tmp_tt_stg2 AS t
                    LIMIT 1;
END
$BODY$
language 'plpgsql';
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION public.get_storage_at_by_hash(v_state_leaf_key TEXT, v_storage_leaf_key text, v_block_hash text)
    RETURNS TABLE
            (
                cid                TEXT,
                block_number       BIGINT,
                node_type          INTEGER,
                state_leaf_removed BOOL
            )
AS
$BODY$
DECLARE
    v_block_no BIGINT;
BEGIN
    SELECT h.block_number INTO v_block_no FROM eth.header_cids AS h WHERE block_hash = v_block_hash LIMIT 1;
    IF v_block_no IS NULL THEN
        RETURN;
    END IF;
    RETURN QUERY SELECT * FROM get_storage_at_by_number(v_state_leaf_key, v_storage_leaf_key, v_block_no);
END
$BODY$
LANGUAGE 'plpgsql';
-- +goose StatementEnd

-- +goose Down
DROP FUNCTION get_storage_at_by_hash;
DROP FUNCTION get_storage_at_by_number;
