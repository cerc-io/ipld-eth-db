-- +goose Up
CREATE TABLE ethcl.non_finalized_slots (
  "slot" bigint NOT NULL,
  "block_root" VARCHAR(66) UNIQUE,
  "state_root" VARCHAR(66) UNIQUE,
  FOREIGN KEY (slot, block_root) REFERENCES ethcl.slots (slot, block_root) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  PRIMARY KEY (slot, block_root)
);

-- +goose Down
DROP TABLE ethcl.non_finalized_slots;
