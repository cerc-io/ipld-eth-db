-- +goose Up
-- peer tx represents a tx that has been seen by a peer
-- the same tx (hash) can be seen by different peers
-- or received by different probes
-- so the primary key is a composite on (raw_peer_id, tx_hash, received_by_probe)
-- this table is persistent, and continues to map probe/peer meta_data to transaction hashes
-- whether they are in the canonical tx table or the pending tx table
CREATE TABLE eth_meta.peer_tx (
    raw_peer_id bytea NOT NULL,
    tx_hash VARCHAR(66) NOT NULL,
    received timestamp with time zone NOT NULL,
    received_by_probe integer NOT NULL
);

CREATE TABLE eth_meta.asn (
    id BIGINT NOT NULL,
    asn INTEGER NOT NULL,
    registry TEXT NOT NULL,
    country_code TEXT NOT NULL,
    name TEXT NOT NULL
);

CREATE TABLE eth_meta.peer (
    asn_id BIGINT NOT NULL,
    prefix CIDR NOT NULL,
    rdns TEXT,
    raw_dht_peer_id BIGINT,
    city TEXT,
    country TEXT,
    coords JSONB
);

CREATE TABLE eth_meta.peer_dht (
    dht_peer_id BIGINT NOT NULL,
    neighbor_id BIGINT NOT NULL,
    seen TIMESTAMP WITH TIME ZONE NOT NULL,
    seen_by_probe INTEGER NOT NULL
);

CREATE TABLE eth_meta.peer_seen (
    raw_peer_id BYTEA NOT NULL,
    first_seen TIMESTAMP WITH TIME ZONE NOT NULL,
    probe_id INTEGER NOT NULL
);

CREATE TABLE eth_meta.probe (
    id INTEGER NOT NULL,
    ip INET NOT NULL,
    deployed TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE eth_meta.raw_dht_peer (
   id BIGINT NOT NULL,
   pubkey BYTEA NOT NULL,
   ip INET NOT NULL,
   port INTEGER NOT NULL,
   client_id TEXT,
   network_id BYTEA,
   genesis_hash BYTEA,
   forks JSONB,
   created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
   updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE TABLE eth_meta.raw_peer (
   id BYTEA NOT NULL,
   ip INET NOT NULL,
   port INTEGER NOT NULL,
   client_id TEXT NOT NULL,
   created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE TABLE eth_meta.site (
   id INTEGER NOT NULL,
   provider TEXT NOT NULL,
   az TEXT NOT NULL,
   probe_id INTEGER NOT NULL,
   privkey BYTEA NOT NULL
);

CREATE TABLE eth_meta.tx_chain (
   id BYTEA NOT NULL,
   height INTEGER NOT NULL,
   ts TIMESTAMP WITH TIME ZONE NOT NULL
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
DROP TABLE eth_meta.peer_tx;
