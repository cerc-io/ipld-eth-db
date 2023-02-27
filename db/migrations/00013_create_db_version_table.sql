-- +goose Up
CREATE TABLE IF NOT EXISTS public.db_version (
    singleton BOOLEAN NOT NULL DEFAULT TRUE UNIQUE CHECK (singleton),
    version TEXT NOT NULL,
    tstamp TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

INSERT INTO public.db_version (singleton, version) VALUES (true, 'v5.0.0')
    ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v5.0.0', NOW());

-- +goose Down
DROP TABLE public.db_version;
