-- +goose Up
-- Name: increment_duplicate_blocks(); Type: FUNCTION; Schema: eth; Owner: -

-- +goose StatementBegin
CREATE FUNCTION eth.increment_duplicate_blocks() RETURNS TRIGGER AS $$
DECLARE
duplicate_row_count integer;
BEGIN
    SELECT INTO duplicate_row_count COUNT(*) FROM eth.header_cids WHERE block_number=NEW.block_number;
    IF duplicate_row_count > 0 THEN
        UPDATE eth.header_cids SET duplicate_block_number=(duplicate_row_count+1) WHERE block_number=NEW.block_number;
        NEW.duplicate_block_number=(duplicate_row_count+1);
END IF;
RETURN NEW;
END;
$$ language plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_eth_header_cids_duplicate
    BEFORE INSERT ON eth.header_cids
    FOR EACH ROW
    EXECUTE PROCEDURE eth.increment_duplicate_blocks();


-- +goose Down
DROP TRIGGER trg_eth_header_cids_duplicate ON eth.header_cids;
DROP FUNCTION eth.increment_duplicate_blocks();
