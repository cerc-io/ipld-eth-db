-- +goose Up
CREATE TABLE eth_meta.asn (
    id bigint NOT NULL,
    asn integer NOT NULL,
    registry text NOT NULL,
    country_code text NOT NULL,
    name text NOT NULL
);

CREATE TABLE eth_meta.peer (
     asn_id bigint NOT NULL,
     prefix cidr NOT NULL,
     rdns text,
     raw_dht_peer_id bigint,
     city text,
     country text,
     coords jsonb
);

CREATE TABLE eth_meta.peer_dht (
     dht_peer_id bigint NOT NULL,
     neighbor_id bigint NOT NULL,
     seen timestamp with time zone NOT NULL,
     seen_by_probe integer NOT NULL
);

CREATE TABLE eth_meta.peer_seen (
      raw_peer_id bytea NOT NULL,
      first_seen timestamp with time zone NOT NULL,
      probe_id integer NOT NULL
);

CREATE TABLE eth_meta.probe (
      id integer NOT NULL,
      ip inet NOT NULL,
      deployed timestamp with time zone NOT NULL
);

CREATE TABLE eth_meta.raw_dht_peer (
     id bigint NOT NULL,
     pubkey bytea NOT NULL,
     ip inet NOT NULL,
     port integer NOT NULL,
     client_id text,
     network_id bytea,
     genesis_hash bytea,
     forks jsonb,
     created_at timestamp with time zone DEFAULT now() NOT NULL,
     updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE eth_meta.raw_peer (
     id bytea NOT NULL,
     ip inet NOT NULL,
     port integer NOT NULL,
     client_id text NOT NULL,
     created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE eth_meta.site (
     id integer NOT NULL,
     provider text NOT NULL,
     az text NOT NULL,
     probe_id integer NOT NULL,
     privkey bytea NOT NULL
);

CREATE TABLE eth_meta.tx_chain (
     id bytea NOT NULL,
     height integer NOT NULL,
     ts timestamp with time zone NOT NULL
);

-- +goose Down
DROP TABLE eth_meta.tx_chain;
DROP TABLE eth_meta.site;
DROP TABLE eth_meta.raw_peer;
DROP TABLE eth_meta.raw_dht_peer;
DROP TABLE eth_meta.probe;
DROP TABLE eth_meta.peer_seen;
DROP TABLE eth_meta.peer_dht;
DROP TABLE eth_meta.peer;
DROP TABLE eth_meta.asn;
