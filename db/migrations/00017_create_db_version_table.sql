-- +goose Up
CREATE TABLE IF NOT EXISTS public.db_version (
    singleton BOOLEAN NOT NULL DEFAULT TRUE UNIQUE CHECK (singleton),
    version TEXT NOT NULL,
    tstamp TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- +goose Down
DROP TABLE public.db_version;
