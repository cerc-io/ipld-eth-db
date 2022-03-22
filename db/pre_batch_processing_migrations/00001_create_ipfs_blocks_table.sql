-- +goose Up
CREATE TABLE IF NOT EXISTS public.blocks (
    block_number BIGINT NOT NULL,
    key TEXT NOT NULL,
    data BYTEA NOT NULL
);

-- +goose Down
DROP TABLE public.blocks;
