-- +goose Up
CREATE TABLE ethcl.non_finalized_slots (
  "slot" bigint NOT NULL,
  "block_root" VARCHAR(66) UNIQUE,
  "state_root" VARCHAR(66) UNIQUE,
  "status" bytea NOT NULL
);

-- +goose Down
DROP TABLE ethcl.non_finalized_slots;
