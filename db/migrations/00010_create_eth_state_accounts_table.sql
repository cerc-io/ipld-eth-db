-- +goose Up
CREATE TABLE IF NOT EXISTS eth.state_accounts (
    block_number          BIGINT NOT NULL,
    header_id             VARCHAR(66) NOT NULL,
    state_path            BYTEA NOT NULL,
    balance               NUMERIC NOT NULL,
    nonce                 BIGINT NOT NULL,
    code_hash             BYTEA NOT NULL,
    storage_root          VARCHAR(66) NOT NULL,
    PRIMARY KEY (state_path, header_id, block_number),
    FOREIGN KEY (state_path, header_id, block_number) REFERENCES eth.state_cids (state_path, header_id, block_number) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

-- +goose Down
DROP TABLE eth.state_accounts;
