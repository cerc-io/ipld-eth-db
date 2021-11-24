-- +goose Up
CREATE TABLE eth.state_accounts (
    header_id             VARCHAR(66) NOT NULL,
    state_path            BYTEA NOT NULL,
    balance               NUMERIC NOT NULL,
    nonce                 BIGINT NOT NULL,
    code_hash             BYTEA NOT NULL,
    storage_root          VARCHAR(66) NOT NULL,
    FOREIGN KEY (header_id, state_path) REFERENCES eth.state_cids (header_id, state_path) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    PRIMARY KEY (header_id, state_path)
);

-- +goose Down
DROP TABLE eth.state_accounts;
