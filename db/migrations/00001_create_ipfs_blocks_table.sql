-- +goose Up
CREATE TABLE IF NOT EXISTS public.blocks (
    block_number BIGINT NOT NULL,
    key TEXT UNIQUE NOT NULL,
    data BYTEA NOT NULL,
    PRIMARY KEY (key, block_number)
);

-- +goose Down
DROP TABLE public.blocks;
