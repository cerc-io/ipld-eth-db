-- +goose Up
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION was_state_leaf_removed_by_number(key character varying, blockNo bigint)
    RETURNS boolean AS $$
SELECT state_cids.node_type = 3
FROM eth.state_cids
         INNER JOIN eth.header_cids ON (state_cids.header_id = header_cids.block_hash)
WHERE state_leaf_key = key
  AND state_cids.block_number <= blockNo
ORDER BY state_cids.block_number DESC LIMIT 1;
$$
language sql;

CREATE OR REPLACE FUNCTION get_storage_at_by_number(stateLeafKey text, storageLeafKey text, blockNo bigint)
    RETURNS TABLE(cid text, mh_key text, block_number bigint, node_type integer, state_leaf_removed bool) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT STORAGE_CIDS.CID,
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
                         AND STORAGE_CIDS.BLOCK_NUMBER <= blockNo
                     )
                          INNER JOIN ETH.HEADER_CIDS ON (
                             STATE_CIDS.HEADER_ID = HEADER_CIDS.BLOCK_HASH
                         AND STATE_CIDS.BLOCK_NUMBER = HEADER_CIDS.BLOCK_NUMBER
                         AND STATE_CIDS.BLOCK_NUMBER <= blockNo
                     )
                 WHERE STATE_LEAF_KEY = stateLeafKey
                   AND STATE_CIDS.BLOCK_NUMBER <= blockNo
                   AND STORAGE_LEAF_KEY = storageLeafKey
                   AND STORAGE_CIDS.BLOCK_NUMBER <= blockNo
                   AND HEADER_CIDS.BLOCK_NUMBER <= blockNo
                   AND HEADER_CIDS.BLOCK_HASH = (SELECT CANONICAL_HEADER_HASH(HEADER_CIDS.BLOCK_NUMBER))
                 ORDER BY HEADER_CIDS.BLOCK_NUMBER DESC
                 LIMIT 1;
END
$$;

CREATE OR REPLACE FUNCTION get_storage_at_by_hash(stateLeafKey text, storageLeafKey text, blockHash text)
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
DROP FUNCTION was_state_leaf_removed_by_number;
DROP FUNCTION get_storage_at_by_number;
DROP FUNCTION get_storage_at_by_hash;
-- +goose StatementEnd
