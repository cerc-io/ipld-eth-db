-- +goose Up
-- Name: graphql_subscription(); Type: FUNCTION; Schema: eth; Owner: -

-- +goose StatementBegin
CREATE FUNCTION eth.graphql_subscription() RETURNS TRIGGER AS $$
DECLARE
obj jsonb;
BEGIN
    IF (TG_TABLE_NAME = 'state_cids') OR (TG_TABLE_NAME = 'state_accounts') THEN
             obj := json_build_array(
                        TG_TABLE_NAME,
                        NEW.header_id,
                        NEW.state_path
                    );
    ELSIF (TG_TABLE_NAME = 'storage_cids') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.header_id,
                    NEW.state_path,
                    NEW.storage_path
                );
    ELSIF (TG_TABLE_NAME = 'log_cids')w THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.rct_id,
                    NEW.index
                );
    ELSIF (TG_TABLE_NAME = 'receipt_cids') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.tx_id
                );
    ELSIF (TG_TABLE_NAME = 'transaction_cids') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.tx_hash
                );
    ELSIF (TG_TABLE_NAME = 'access_list_elements') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.tx_id,
                    NEW.index
                );
    ELSIF (TG_TABLE_NAME = 'uncle_cids') OR (TG_TABLE_NAME = 'header_cids') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.block_hash
                );
END IF;

    perform pg_notify('postgraphile:' || TG_RELNAME , json_build_object(
            '__node__', obj
            )::text
        );
RETURN NEW;
END;
$$ language plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_eth_header_cids
    AFTER INSERT ON eth.header_cids
    FOR EACH ROW
    EXECUTE PROCEDURE eth.graphql_subscription();

CREATE TRIGGER trg_uncle_cids
    AFTER INSERT ON eth.uncle_cids
    FOR EACH ROW
    EXECUTE PROCEDURE eth.graphql_subscription();

CREATE TRIGGER trg_eth_transaction_cids
    AFTER INSERT ON eth.transaction_cids
    FOR EACH ROW
    EXECUTE PROCEDURE eth.graphql_subscription();

CREATE TRIGGER trg_eth_receipt_cids
    AFTER INSERT ON eth.receipt_cids
    FOR EACH ROW
    EXECUTE PROCEDURE eth.graphql_subscription();

CREATE TRIGGER trg_eth_state_cids
    AFTER INSERT ON eth.state_cids
    FOR EACH ROW
    EXECUTE PROCEDURE eth.graphql_subscription();

CREATE TRIGGER trg_eth_log_cids
    AFTER INSERT ON eth.log_cids
    FOR EACH ROW
    EXECUTE PROCEDURE eth.graphql_subscription();

CREATE TRIGGER trg_eth_storage_cids
    AFTER INSERT ON eth.storage_cids
    FOR EACH ROW
    EXECUTE PROCEDURE eth.graphql_subscription();

CREATE TRIGGER trg_eth_state_accounts
    AFTER INSERT ON eth.state_accounts
    FOR EACH ROW
    EXECUTE PROCEDURE eth.graphql_subscription();

CREATE TRIGGER trg_eth_access_list_elements
    AFTER INSERT ON eth.access_list_elements
    FOR EACH ROW
    EXECUTE PROCEDURE eth.graphql_subscription();

-- +goose Down
DROP TRIGGER trg_eth_uncle_cids ON eth.uncle_cids;
DROP TRIGGER trg_eth_transaction_cids ON eth.transaction_cids;
DROP TRIGGER trg_eth_storage_cids ON eth.storage_cids;
DROP TRIGGER trg_eth_state_cids ON eth.state_cids;
DROP TRIGGER trg_eth_state_accounts ON eth.state_accounts;
DROP TRIGGER trg_eth_receipt_cids ON eth.receipt_cids;
DROP TRIGGER trg_eth_header_cids ON eth.header_cids;
DROP TRIGGER trg_eth_log_cids ON eth.log_cids;
DROP TRIGGER trg_eth_access_list_elements ON eth.access_list_elements;

DROP FUNCTION eth.graphql_subscription();