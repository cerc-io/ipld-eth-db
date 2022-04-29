-- +goose Up
CREATE TABLE ethcl.slots (
  "epoch" bigint NOT NULL,
  "slot" bigint NOT NULL,
  "block_root" VARCHAR(66) UNIQUE,
  "state_root" VARCHAR(66) UNIQUE,
  "status" bytea NOT NULL,
  mh_key text NOT NULL,
  PRIMARY KEY (slot, block_root)
);

-- +goose Down
DROP TABLE ethcl.slots;
