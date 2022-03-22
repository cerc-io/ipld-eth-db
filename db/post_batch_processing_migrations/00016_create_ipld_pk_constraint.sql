-- +goose Up
ALTER TABLE public.blocks
ADD CONSTRAINT pk_public_blocks PRIMARY KEY (key, block_number);

-- +goose Down
ALTER TABLE public.blocks
DROP CONSTRAINT pk_public_blocks;
