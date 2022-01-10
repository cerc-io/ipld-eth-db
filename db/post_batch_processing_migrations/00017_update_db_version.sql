-- +goose Up
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v3.0.0')
ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v3.0.0', NOW());

-- +goose Down
DELETE FROM public.db_version WHERE version = 'v3.0.0';
INSERT INTO public.db_version (singleton, version) VALUES (true, 'v0.3.2')
ON CONFLICT (singleton) DO UPDATE SET (version, tstamp) = ('v0.3.2', NOW());
