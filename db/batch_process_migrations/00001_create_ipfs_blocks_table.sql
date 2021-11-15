-- +goose Up
CREATE TABLE IF NOT EXISTS public.blocks (
  key TEXT PRIMARY KEY,
  data BYTEA NOT NULL
);

-- +goose Down
DROP TABLE public.blocks;
