-- +goose Up
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v5.0.0')
ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v5.0.0', NOW());

-- +goose Down
DELETE FROM public.db_version WHERE version = 'v5.0.0';
