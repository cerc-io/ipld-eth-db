-- +goose Up
CREATE TABLE IF NOT EXISTS eth.state_accounts (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    state_path            BYTEA NOT NULL,
    balance               NUMERIC NOT NULL,
    nonce                 BIGINT NOT NULL,
    code_hash             BYTEA NOT NULL,
    storage_root          VARCHAR(66) NOT NULL
);

-- +goose Down
DROP TABLE eth.state_accounts;
