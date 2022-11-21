-- +goose Up
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION public.was_state_leaf_removed_by_number(v_key character varying, v_block_no bigint)
    RETURNS BOOLEAN AS
$$
SELECT STATE_CIDS.NODE_TYPE = 3
FROM ETH.STATE_CIDS
         INNER JOIN ETH.HEADER_CIDS ON (STATE_CIDS.HEADER_ID = HEADER_CIDS.BLOCK_HASH)
WHERE STATE_LEAF_KEY = v_key
  AND STATE_CIDS.BLOCK_NUMBER <= v_block_no
ORDER BY STATE_CIDS.BLOCK_NUMBER DESC
LIMIT 1;
$$
language sql;

CREATE OR REPLACE FUNCTION public.get_storage_at_by_number(v_state_leaf_key text, v_storage_leaf_key text, v_block_no bigint)
    RETURNS TABLE
            (
                cid                TEXT,
                mh_key             TEXT,
                block_number       BIGINT,
                node_type          INTEGER,
                state_leaf_removed BOOL
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_state_path       BYTEA;
    v_header           TEXT;
    v_canonical_header TEXT;
BEGIN
    CREATE TEMP TABLE tmp_tt_stg2
    (
        header_id          TEXT,
        cid                TEXT,
        mh_key             TEXT,
        block_number       BIGINT,
        node_type          INTEGER,
        state_leaf_removed BOOL
    ) ON COMMIT DROP;

    -- In the best case scenario, the state_path is stable, and we can cheaply look that up via the state_leaf_key
    -- and then use it (plus storage_leaf_key and block_number) to zero in on the storage_cid.
    SELECT STATE_PATH, STATE_CIDS.BLOCK_NUMBER
    INTO v_state_path, v_block_no
    FROM ETH.STATE_CIDS
    WHERE STATE_LEAF_KEY = v_state_leaf_key
      AND STATE_CIDS.BLOCK_NUMBER <= v_block_no
    ORDER BY STATE_CIDS.BLOCK_NUMBER DESC
    LIMIT 1;

    INSERT INTO tmp_tt_stg2
    SELECT STORAGE_CIDS.HEADER_ID,
           STORAGE_CIDS.CID,
           STORAGE_CIDS.MH_KEY,
           STORAGE_CIDS.BLOCK_NUMBER,
           STORAGE_CIDS.NODE_TYPE,
           WAS_STATE_LEAF_REMOVED_BY_NUMBER(
                   v_state_leaf_key,
                   v_block_no
               ) AS STATE_LEAF_REMOVED
    FROM ETH.STORAGE_CIDS
    WHERE STORAGE_LEAF_KEY = v_storage_leaf_key
      AND STORAGE_CIDS.BLOCK_NUMBER <= v_block_no
      AND STORAGE_CIDS.STATE_PATH = v_state_path
      AND STORAGE_CIDS.BLOCK_NUMBER <= v_block_no
    ORDER BY STORAGE_CIDS.BLOCK_NUMBER DESC
    LIMIT 1;

    SELECT header_id, CANONICAL_HEADER_HASH(tmp_tt_stg2.block_number), tmp_tt_stg2.block_number
    INTO v_header, v_canonical_header, v_block_no
    FROM tmp_tt_stg2
    LIMIT 1;
    IF v_header IS NULL OR v_header != v_canonical_header THEN
        RAISE NOTICE 'get_storage_at_by_number: chosen header NULL OR % != canonical header % for block number %, trying again.', v_header, v_canonical_header, v_block_no;
        TRUNCATE tmp_tt_stg2;
        -- If we missed on the above, or hit on a non-canonical block, we need to go back and do a comprehensive check.
        -- We try to avoid this because joining on STORAGE_CIDS.STATE_PATH = STATE_CIDS.STATE_PATH is quite
        -- expensive whenever there are a lot of candidate rows, as is often the case when the state_path only
        -- changes very infrequently (if ever).
        INSERT INTO tmp_tt_stg2
        SELECT STORAGE_CIDS.HEADER_ID,
               STORAGE_CIDS.CID,
               STORAGE_CIDS.MH_KEY,
               STORAGE_CIDS.BLOCK_NUMBER,
               STORAGE_CIDS.NODE_TYPE,
               WAS_STATE_LEAF_REMOVED_BY_NUMBER(
                       v_state_leaf_key,
                       v_block_no
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
        WHERE STATE_LEAF_KEY = v_state_leaf_key
          AND STATE_CIDS.BLOCK_NUMBER <= v_block_no
          AND STORAGE_LEAF_KEY = v_storage_leaf_key
          AND STORAGE_CIDS.BLOCK_NUMBER <= v_block_no
          AND HEADER_CIDS.BLOCK_NUMBER <= v_block_no
          AND HEADER_CIDS.BLOCK_HASH = (SELECT CANONICAL_HEADER_HASH(HEADER_CIDS.BLOCK_NUMBER))
        ORDER BY HEADER_CIDS.BLOCK_NUMBER DESC
        LIMIT 1;
    END IF;

    RETURN QUERY SELECT t.cid, t.mh_key, t.block_number, t.node_type, t.state_leaf_removed
                 fROM tmp_tt_stg2 AS t
                 LIMIT 1;
END
$$;

CREATE OR REPLACE FUNCTION public.get_storage_at_by_hash(v_state_leaf_key TEXT, v_storage_leaf_key text, v_block_hash text)
    RETURNS TABLE
            (
                cid                TEXT,
                mh_key             TEXT,
                block_number       BIGINT,
                node_type          INTEGER,
                state_leaf_removed BOOL
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_block_no BIGINT;
BEGIN
    SELECT h.BLOCK_NUMBER INTO v_block_no FROM ETH.HEADER_CIDS AS h WHERE BLOCK_HASH = v_block_hash LIMIT 1;
    IF v_block_no IS NULL THEN
        RETURN;
    END IF;
    RETURN QUERY SELECT * FROM get_storage_at_by_number(v_state_leaf_key, v_storage_leaf_key, v_block_no);
END
$$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP FUNCTION public.was_state_leaf_removed_by_number;
DROP FUNCTION public.get_storage_at_by_number;
DROP FUNCTION public.get_storage_at_by_hash;
-- +goose StatementEnd
