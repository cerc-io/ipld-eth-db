-- +goose Up
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v0.3.2')
ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v0.3.2', NOW());

-- +goose Down
DELETE FROM public.db_version WHERE version = 'v0.3.2';
