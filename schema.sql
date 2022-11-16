--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2
-- Dumped by pg_dump version 14.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data';


--
-- Name: eth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA eth;


--
-- Name: eth_meta; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA eth_meta;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: header_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.header_cids (
    block_number bigint NOT NULL,
    block_hash character varying(66) NOT NULL,
    parent_hash character varying(66) NOT NULL,
    cid text NOT NULL,
    td numeric NOT NULL,
    node_id character varying(128) NOT NULL,
    reward numeric NOT NULL,
    state_root character varying(66) NOT NULL,
    tx_root character varying(66) NOT NULL,
    receipt_root character varying(66) NOT NULL,
    uncle_root character varying(66) NOT NULL,
    bloom bytea NOT NULL,
    "timestamp" bigint NOT NULL,
    mh_key text NOT NULL,
    times_validated integer DEFAULT 1 NOT NULL,
    coinbase character varying(66) NOT NULL
);


--
-- Name: TABLE header_cids; Type: COMMENT; Schema: eth; Owner: -
--

COMMENT ON TABLE eth.header_cids IS '@name EthHeaderCids';


--
-- Name: COLUMN header_cids.node_id; Type: COMMENT; Schema: eth; Owner: -
--

COMMENT ON COLUMN eth.header_cids.node_id IS '@name EthNodeID';


--
-- Name: child_result; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.child_result AS (
	has_child boolean,
	children eth.header_cids[]
);


--
-- Name: state_node_result; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.state_node_result AS (
	data bytea,
	state_leaf_key character varying(66),
	cid text,
	state_path bytea,
	node_type integer,
	mh_key text
);


--
-- Name: storage_node_result; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.storage_node_result AS (
	data bytea,
	state_path bytea,
	storage_leaf_key character varying(66),
	cid text,
	storage_path bytea,
	node_type integer,
	mh_key text
);


--
-- Name: graphql_subscription(); Type: FUNCTION; Schema: eth; Owner: -
--

CREATE FUNCTION eth.graphql_subscription() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
obj jsonb;
BEGIN
    IF (TG_TABLE_NAME = 'state_cids') OR (TG_TABLE_NAME = 'state_accounts') THEN
             obj := json_build_array(
                        TG_TABLE_NAME,
                        NEW.header_id,
                        NEW.state_path
                    );
    ELSIF (TG_TABLE_NAME = 'storage_cids') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.header_id,
                    NEW.state_path,
                    NEW.storage_path
                );
    ELSIF (TG_TABLE_NAME = 'log_cids') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.header_id,
                    NEW.rct_id,
                    NEW.index
                );
    ELSIF (TG_TABLE_NAME = 'receipt_cids') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.header_id,
                    NEW.tx_id
                );
    ELSIF (TG_TABLE_NAME = 'transaction_cids') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.header_id,
                    NEW.tx_hash
                );
    ELSIF (TG_TABLE_NAME = 'access_list_elements') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.tx_id,
                    NEW.index
                );
    ELSIF (TG_TABLE_NAME = 'uncle_cids') OR (TG_TABLE_NAME = 'header_cids') THEN
         obj := json_build_array(
                    TG_TABLE_NAME,
                    NEW.block_hash
                );
END IF;
    perform pg_notify('postgraphile:' || TG_RELNAME , json_build_object(
            '__node__', obj
            )::text
        );
RETURN NEW;
END;
$$;


--
-- Name: canonical_header_from_array(eth.header_cids[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.canonical_header_from_array(headers eth.header_cids[]) RETURNS eth.header_cids
    LANGUAGE plpgsql
    AS $$
DECLARE
  canonical_header eth.header_cids;
  canonical_child eth.header_cids;
  header eth.header_cids;
  current_child_result child_result;
  child_headers eth.header_cids[];
  current_header_with_child eth.header_cids;
  has_children_count INT DEFAULT 0;
BEGIN
  -- for each header in the provided set
  FOREACH header IN ARRAY headers
  LOOP
    -- check if it has any children
    current_child_result = has_child(header.block_hash, header.block_number);
    IF current_child_result.has_child THEN
      -- if it does, take note
      has_children_count = has_children_count + 1;
      current_header_with_child = header;
      -- and add the children to the growing set of child headers
      child_headers = array_cat(child_headers, current_child_result.children);
    END IF;
  END LOOP;
  -- if none of the headers had children, none is more canonical than the other
  IF has_children_count = 0 THEN
    -- return the first one selected
    SELECT * INTO canonical_header FROM unnest(headers) LIMIT 1;
  -- if only one header had children, it can be considered the heaviest/canonical header of the set
  ELSIF has_children_count = 1 THEN
    -- return the only header with a child
    canonical_header = current_header_with_child;
  -- if there are multiple headers with children
  ELSE
    -- find the canonical header from the child set
    canonical_child = canonical_header_from_array(child_headers);
    -- the header that is parent to this header, is the canonical header at this level
    SELECT * INTO canonical_header FROM unnest(headers)
    WHERE block_hash = canonical_child.parent_hash;
  END IF;
  RETURN canonical_header;
END
$$;


--
-- Name: canonical_header_hash(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.canonical_header_hash(height bigint) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
  canonical_header eth.header_cids;
  headers eth.header_cids[];
  header_count INT;
  temp_header eth.header_cids;
BEGIN
  -- collect all headers at this height
  FOR temp_header IN
  SELECT * FROM eth.header_cids WHERE block_number = height
  LOOP
    headers = array_append(headers, temp_header);
  END LOOP;
  -- count the number of headers collected
  header_count = array_length(headers, 1);
  -- if we have less than 1 header, return NULL
  IF header_count IS NULL OR header_count < 1 THEN
    RETURN NULL;
  -- if we have one header, return its hash
  ELSIF header_count = 1 THEN
    RETURN headers[1].block_hash;
  -- if we have multiple headers we need to determine which one is canonical
  ELSE
    canonical_header = canonical_header_from_array(headers);
    RETURN canonical_header.block_hash;
  END IF;
END
$$;


--
-- Name: get_storage_at_by_hash(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_storage_at_by_hash(stateleafkey text, storageleafkey text, blockhash text) RETURNS TABLE(cid text, mh_key text, block_number bigint, node_type integer, state_leaf_removed boolean)
    LANGUAGE plpgsql
    AS $$
DECLARE
    blockNo bigint;
BEGIN
    SELECT h.BLOCK_NUMBER INTO blockNo FROM ETH.HEADER_CIDS as h WHERE BLOCK_HASH = blockHash limit 1;
    IF blockNo IS NULL THEN
        RETURN;
    END IF;
    RETURN QUERY SELECT * FROM get_storage_at_by_number(stateLeafKey, storageLeafKey, blockNo);
END
$$;


--
-- Name: get_storage_at_by_number(text, text, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_storage_at_by_number(stateleafkey text, storageleafkey text, blockno bigint) RETURNS TABLE(cid text, mh_key text, block_number bigint, node_type integer, state_leaf_removed boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT STORAGE_CIDS.CID,
                        STORAGE_CIDS.MH_KEY,
                        STORAGE_CIDS.BLOCK_NUMBER,
                        STORAGE_CIDS.NODE_TYPE,
                        was_state_leaf_removed_by_number(
                                stateLeafKey,
                                blockNo
                            ) AS STATE_LEAF_REMOVED
                 FROM ETH.STORAGE_CIDS
                          INNER JOIN ETH.STATE_CIDS ON (
                             STORAGE_CIDS.HEADER_ID = STATE_CIDS.HEADER_ID
                         AND STORAGE_CIDS.BLOCK_NUMBER = STATE_CIDS.BLOCK_NUMBER
                         AND STORAGE_CIDS.STATE_PATH = STATE_CIDS.STATE_PATH
                         AND STORAGE_CIDS.BLOCK_NUMBER <= blockNo
                     )
                          INNER JOIN ETH.HEADER_CIDS ON (
                             STATE_CIDS.HEADER_ID = HEADER_CIDS.BLOCK_HASH
                         AND STATE_CIDS.BLOCK_NUMBER = HEADER_CIDS.BLOCK_NUMBER
                         AND STATE_CIDS.BLOCK_NUMBER <= blockNo
                     )
                 WHERE STATE_LEAF_KEY = stateLeafKey
                   AND STATE_CIDS.BLOCK_NUMBER <= blockNo
                   AND STORAGE_LEAF_KEY = storageLeafKey
                   AND STORAGE_CIDS.BLOCK_NUMBER <= blockNo
                   AND HEADER_CIDS.BLOCK_NUMBER <= blockNo
                   AND HEADER_CIDS.BLOCK_HASH = (SELECT CANONICAL_HEADER_HASH(HEADER_CIDS.BLOCK_NUMBER))
                 ORDER BY HEADER_CIDS.BLOCK_NUMBER DESC
                 LIMIT 1;
END
$$;


--
-- Name: has_child(character varying, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_child(hash character varying, height bigint) RETURNS public.child_result
    LANGUAGE plpgsql
    AS $$
DECLARE
  child_height INT;
  temp_child eth.header_cids;
  new_child_result child_result;
BEGIN
  child_height = height + 1;
  -- short circuit if there are no children
  SELECT exists(SELECT 1
              FROM eth.header_cids
              WHERE parent_hash = hash
                AND block_number = child_height
              LIMIT 1)
  INTO new_child_result.has_child;
  -- collect all the children for this header
  IF new_child_result.has_child THEN
    FOR temp_child IN
    SELECT * FROM eth.header_cids WHERE parent_hash = hash AND block_number = child_height
    LOOP
      new_child_result.children = array_append(new_child_result.children, temp_child);
    END LOOP;
  END IF;
  RETURN new_child_result;
END
$$;


--
-- Name: state_snapshot(bigint, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.state_snapshot(starting_height bigint, ending_height bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    canonical_hash VARCHAR(66);
    results state_node_result[];
BEGIN
    -- get the canonical hash for the header at ending_height
    canonical_hash = canonical_header_hash(ending_height);
    IF canonical_hash IS NULL THEN
        RAISE EXCEPTION 'cannot create state snapshot, no header can be found at height %', ending_height;
    END IF;
    -- select all of the state nodes for this snapshot: the latest state node record at every unique path
    SELECT ARRAY (SELECT DISTINCT ON (state_path) ROW (blocks.data, state_cids.state_leaf_key, state_cids.cid, state_cids.state_path,
        state_cids.node_type, state_cids.mh_key)
    FROM eth.state_cids
        INNER JOIN public.blocks
            ON (state_cids.mh_key, state_cids.block_number) = (blocks.key, blocks.block_number)
    WHERE state_cids.block_number BETWEEN starting_height AND ending_height
    ORDER BY state_path, state_cids.block_number DESC)
    INTO results;
    -- from the set returned above, insert public.block records at the ending_height block number
    INSERT INTO public.blocks (block_number, key, data)
    SELECT ending_height, r.mh_key, r.data
    FROM unnest(results) r;
    -- from the set returned above, insert eth.state_cids records at the ending_height block number
    -- anchoring all the records to the canonical header found at ending_height
    INSERT INTO eth.state_cids (block_number, header_id, state_leaf_key, cid, state_path, node_type, diff, mh_key)
    SELECT ending_height, canonical_hash, r.state_leaf_key, r.cid, r.state_path, r.node_type, false, r.mh_key
    FROM unnest(results) r
    ON CONFLICT (state_path, header_id, block_number) DO NOTHING;
END
$$;


--
-- Name: storage_snapshot(bigint, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.storage_snapshot(starting_height bigint, ending_height bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    canonical_hash VARCHAR(66);
    results storage_node_result[];
BEGIN
    -- get the canonical hash for the header at ending_height
    SELECT canonical_header_hash(ending_height) INTO canonical_hash;
    IF canonical_hash IS NULL THEN
        RAISE EXCEPTION 'cannot create state snapshot, no header can be found at height %', ending_height;
    END IF;
    -- select all of the storage nodes for this snapshot: the latest storage node record at every unique state leaf key
    SELECT ARRAY (SELECT DISTINCT ON (state_leaf_key, storage_path) ROW (blocks.data, storage_cids.state_path, storage_cids.storage_leaf_key,
     storage_cids.cid, storage_cids.storage_path, storage_cids.node_type, storage_cids.mh_key)
    FROM eth.storage_cids
        INNER JOIN public.blocks
        ON (storage_cids.mh_key, storage_cids.block_number) = (blocks.key, blocks.block_number)
        INNER JOIN eth.state_cids
        ON (storage_cids.state_path, storage_cids.header_id) = (state_cids.state_path, state_cids.header_id)
    WHERE storage_cids.block_number BETWEEN starting_height AND ending_height
    ORDER BY state_leaf_key, storage_path, storage_cids.state_path, storage_cids.block_number DESC)
    INTO results;
    -- from the set returned above, insert public.block records at the ending_height block number
    INSERT INTO public.blocks (block_number, key, data)
    SELECT ending_height, r.mh_key, r.data
    FROM unnest(results) r;
    -- from the set returned above, insert eth.state_cids records at the ending_height block number
    -- anchoring all the records to the canonical header found at ending_height
    INSERT INTO eth.storage_cids (block_number, header_id, state_path, storage_leaf_key, cid, storage_path,
                              node_type, diff, mh_key)
    SELECT ending_height, canonical_hash, r.state_path, r.storage_leaf_key, r.cid, r.storage_path, r.node_type, false, r.mh_key
    FROM unnest(results) r
    ON CONFLICT (storage_path, state_path, header_id, block_number) DO NOTHING;
END
$$;


--
-- Name: was_state_leaf_removed(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.was_state_leaf_removed(key character varying, hash character varying) RETURNS boolean
    LANGUAGE sql
    AS $$
    SELECT state_cids.node_type = 3
    FROM eth.state_cids
             INNER JOIN eth.header_cids ON (state_cids.header_id = header_cids.block_hash)
    WHERE state_leaf_key = key
      AND state_cids.block_number <= (SELECT block_number
                           FROM eth.header_cids
                           WHERE block_hash = hash)
    ORDER BY state_cids.block_number DESC LIMIT 1;
$$;


--
-- Name: was_state_leaf_removed_by_number(character varying, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.was_state_leaf_removed_by_number(key character varying, blockno bigint) RETURNS boolean
    LANGUAGE sql
    AS $$
SELECT state_cids.node_type = 3
FROM eth.state_cids
         INNER JOIN eth.header_cids ON (state_cids.header_id = header_cids.block_hash)
WHERE state_leaf_key = key
  AND state_cids.block_number <= blockNo
ORDER BY state_cids.block_number DESC LIMIT 1;
$$;


--
-- Name: access_list_elements; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.access_list_elements (
    block_number bigint NOT NULL,
    tx_id character varying(66) NOT NULL,
    index integer NOT NULL,
    address character varying(66),
    storage_keys character varying(66)[]
);


--
-- Name: log_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.log_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    leaf_cid text NOT NULL,
    leaf_mh_key text NOT NULL,
    rct_id character varying(66) NOT NULL,
    address character varying(66) NOT NULL,
    index integer NOT NULL,
    topic0 character varying(66),
    topic1 character varying(66),
    topic2 character varying(66),
    topic3 character varying(66),
    log_data bytea
);


--
-- Name: receipt_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.receipt_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    tx_id character varying(66) NOT NULL,
    leaf_cid text NOT NULL,
    contract character varying(66),
    contract_hash character varying(66),
    leaf_mh_key text NOT NULL,
    post_state character varying(66),
    post_status integer,
    log_root character varying(66)
);


--
-- Name: state_accounts; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.state_accounts (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    state_path bytea NOT NULL,
    balance numeric NOT NULL,
    nonce bigint NOT NULL,
    code_hash bytea NOT NULL,
    storage_root character varying(66) NOT NULL
);


--
-- Name: state_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.state_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    state_leaf_key character varying(66),
    cid text NOT NULL,
    state_path bytea NOT NULL,
    node_type integer NOT NULL,
    diff boolean DEFAULT false NOT NULL,
    mh_key text NOT NULL
);


--
-- Name: storage_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.storage_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    state_path bytea NOT NULL,
    storage_leaf_key character varying(66),
    cid text NOT NULL,
    storage_path bytea NOT NULL,
    node_type integer NOT NULL,
    diff boolean DEFAULT false NOT NULL,
    mh_key text NOT NULL
);


--
-- Name: transaction_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.transaction_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    tx_hash character varying(66) NOT NULL,
    cid text NOT NULL,
    dst character varying(66) NOT NULL,
    src character varying(66) NOT NULL,
    index integer NOT NULL,
    mh_key text NOT NULL,
    tx_data bytea,
    tx_type integer,
    value numeric
);


--
-- Name: TABLE transaction_cids; Type: COMMENT; Schema: eth; Owner: -
--

COMMENT ON TABLE eth.transaction_cids IS '@name EthTransactionCids';


--
-- Name: uncle_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.uncle_cids (
    block_number bigint NOT NULL,
    block_hash character varying(66) NOT NULL,
    header_id character varying(66) NOT NULL,
    parent_hash character varying(66) NOT NULL,
    cid text NOT NULL,
    reward numeric NOT NULL,
    mh_key text NOT NULL
);


--
-- Name: known_gaps; Type: TABLE; Schema: eth_meta; Owner: -
--

CREATE TABLE eth_meta.known_gaps (
    starting_block_number bigint NOT NULL,
    ending_block_number bigint,
    checked_out boolean,
    processing_key bigint
);


--
-- Name: watched_addresses; Type: TABLE; Schema: eth_meta; Owner: -
--

CREATE TABLE eth_meta.watched_addresses (
    address character varying(66) NOT NULL,
    created_at bigint NOT NULL,
    watched_at bigint NOT NULL,
    last_filled_at bigint DEFAULT 0 NOT NULL
);


--
-- Name: blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocks (
    block_number bigint NOT NULL,
    key text NOT NULL,
    data bytea NOT NULL
);


--
-- Name: db_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.db_version (
    singleton boolean DEFAULT true NOT NULL,
    version text NOT NULL,
    tstamp timestamp without time zone DEFAULT now(),
    CONSTRAINT db_version_singleton_check CHECK (singleton)
);


--
-- Name: goose_db_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.goose_db_version (
    id integer NOT NULL,
    version_id bigint NOT NULL,
    is_applied boolean NOT NULL,
    tstamp timestamp without time zone DEFAULT now()
);


--
-- Name: goose_db_version_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.goose_db_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: goose_db_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.goose_db_version_id_seq OWNED BY public.goose_db_version.id;


--
-- Name: nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nodes (
    genesis_block character varying(66),
    network_id character varying,
    node_id character varying(128) NOT NULL,
    client_name character varying,
    chain_id integer DEFAULT 1
);


--
-- Name: TABLE nodes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.nodes IS '@name NodeInfo';


--
-- Name: COLUMN nodes.node_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nodes.node_id IS '@name ChainNodeID';


--
-- Name: goose_db_version id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goose_db_version ALTER COLUMN id SET DEFAULT nextval('public.goose_db_version_id_seq'::regclass);


--
-- Name: access_list_elements access_list_elements_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.access_list_elements
    ADD CONSTRAINT access_list_elements_pkey PRIMARY KEY (tx_id, index, block_number);


--
-- Name: header_cids header_cids_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.header_cids
    ADD CONSTRAINT header_cids_pkey PRIMARY KEY (block_hash, block_number);


--
-- Name: log_cids log_cids_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.log_cids
    ADD CONSTRAINT log_cids_pkey PRIMARY KEY (rct_id, index, header_id, block_number);


--
-- Name: receipt_cids receipt_cids_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.receipt_cids
    ADD CONSTRAINT receipt_cids_pkey PRIMARY KEY (tx_id, header_id, block_number);


--
-- Name: state_accounts state_accounts_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.state_accounts
    ADD CONSTRAINT state_accounts_pkey PRIMARY KEY (state_path, header_id, block_number);


--
-- Name: state_cids state_cids_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.state_cids
    ADD CONSTRAINT state_cids_pkey PRIMARY KEY (state_path, header_id, block_number);


--
-- Name: storage_cids storage_cids_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.storage_cids
    ADD CONSTRAINT storage_cids_pkey PRIMARY KEY (storage_path, state_path, header_id, block_number);


--
-- Name: transaction_cids transaction_cids_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.transaction_cids
    ADD CONSTRAINT transaction_cids_pkey PRIMARY KEY (tx_hash, header_id, block_number);


--
-- Name: uncle_cids uncle_cids_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.uncle_cids
    ADD CONSTRAINT uncle_cids_pkey PRIMARY KEY (block_hash, block_number);


--
-- Name: known_gaps known_gaps_pkey; Type: CONSTRAINT; Schema: eth_meta; Owner: -
--

ALTER TABLE ONLY eth_meta.known_gaps
    ADD CONSTRAINT known_gaps_pkey PRIMARY KEY (starting_block_number);


--
-- Name: watched_addresses watched_addresses_pkey; Type: CONSTRAINT; Schema: eth_meta; Owner: -
--

ALTER TABLE ONLY eth_meta.watched_addresses
    ADD CONSTRAINT watched_addresses_pkey PRIMARY KEY (address);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (key, block_number);


--
-- Name: db_version db_version_singleton_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.db_version
    ADD CONSTRAINT db_version_singleton_key UNIQUE (singleton);


--
-- Name: goose_db_version goose_db_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goose_db_version
    ADD CONSTRAINT goose_db_version_pkey PRIMARY KEY (id);


--
-- Name: nodes nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (node_id);


--
-- Name: access_list_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX access_list_block_number_index ON eth.access_list_elements USING brin (block_number);


--
-- Name: access_list_element_address_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX access_list_element_address_index ON eth.access_list_elements USING btree (address);


--
-- Name: access_list_storage_keys_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX access_list_storage_keys_index ON eth.access_list_elements USING gin (storage_keys);


--
-- Name: account_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX account_block_number_index ON eth.state_accounts USING brin (block_number);


--
-- Name: account_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX account_header_id_index ON eth.state_accounts USING btree (header_id);


--
-- Name: account_storage_root_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX account_storage_root_index ON eth.state_accounts USING btree (storage_root);


--
-- Name: header_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX header_block_number_index ON eth.header_cids USING brin (block_number);


--
-- Name: header_cid_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE UNIQUE INDEX header_cid_index ON eth.header_cids USING btree (cid, block_number);


--
-- Name: header_mh_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE UNIQUE INDEX header_mh_block_number_index ON eth.header_cids USING btree (mh_key, block_number);


--
-- Name: log_address_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_address_index ON eth.log_cids USING btree (address);


--
-- Name: log_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_block_number_index ON eth.log_cids USING brin (block_number);


--
-- Name: log_cid_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_cid_index ON eth.log_cids USING btree (leaf_cid);


--
-- Name: log_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_header_id_index ON eth.log_cids USING btree (header_id);


--
-- Name: log_leaf_mh_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_leaf_mh_block_number_index ON eth.log_cids USING btree (leaf_mh_key, block_number);


--
-- Name: log_topic0_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_topic0_index ON eth.log_cids USING btree (topic0);


--
-- Name: log_topic1_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_topic1_index ON eth.log_cids USING btree (topic1);


--
-- Name: log_topic2_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_topic2_index ON eth.log_cids USING btree (topic2);


--
-- Name: log_topic3_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_topic3_index ON eth.log_cids USING btree (topic3);


--
-- Name: rct_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX rct_block_number_index ON eth.receipt_cids USING brin (block_number);


--
-- Name: rct_contract_hash_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX rct_contract_hash_index ON eth.receipt_cids USING btree (contract_hash);


--
-- Name: rct_contract_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX rct_contract_index ON eth.receipt_cids USING btree (contract);


--
-- Name: rct_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX rct_header_id_index ON eth.receipt_cids USING btree (header_id);


--
-- Name: rct_leaf_cid_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX rct_leaf_cid_index ON eth.receipt_cids USING btree (leaf_cid);


--
-- Name: rct_leaf_mh_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX rct_leaf_mh_block_number_index ON eth.receipt_cids USING btree (leaf_mh_key, block_number);


--
-- Name: state_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_block_number_index ON eth.state_cids USING brin (block_number);


--
-- Name: state_cid_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_cid_index ON eth.state_cids USING btree (cid);


--
-- Name: state_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_header_id_index ON eth.state_cids USING btree (header_id);


--
-- Name: state_leaf_key_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_leaf_key_block_number_index ON eth.state_cids USING btree (state_leaf_key, block_number DESC);


--
-- Name: state_leaf_key_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_leaf_key_index ON eth.state_cids USING btree (state_leaf_key);


--
-- Name: state_mh_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_mh_block_number_index ON eth.state_cids USING btree (mh_key, block_number);


--
-- Name: state_node_type_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_node_type_index ON eth.state_cids USING btree (node_type);


--
-- Name: state_root_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_root_index ON eth.header_cids USING btree (state_root);


--
-- Name: storage_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_block_number_index ON eth.storage_cids USING brin (block_number);


--
-- Name: storage_cid_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_cid_index ON eth.storage_cids USING btree (cid);


--
-- Name: storage_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_header_id_index ON eth.storage_cids USING btree (header_id);


--
-- Name: storage_leaf_key_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_leaf_key_block_number_index ON eth.storage_cids USING btree (storage_leaf_key, block_number DESC);


--
-- Name: storage_leaf_key_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_leaf_key_index ON eth.storage_cids USING btree (storage_leaf_key);


--
-- Name: storage_mh_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_mh_block_number_index ON eth.storage_cids USING btree (mh_key, block_number);


--
-- Name: storage_node_type_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_node_type_index ON eth.storage_cids USING btree (node_type);


--
-- Name: storage_state_path_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_state_path_index ON eth.storage_cids USING btree (state_path);


--
-- Name: timestamp_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX timestamp_index ON eth.header_cids USING brin ("timestamp");


--
-- Name: tx_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_block_number_index ON eth.transaction_cids USING brin (block_number);


--
-- Name: tx_cid_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_cid_index ON eth.transaction_cids USING btree (cid, block_number);


--
-- Name: tx_dst_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_dst_index ON eth.transaction_cids USING btree (dst);


--
-- Name: tx_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_header_id_index ON eth.transaction_cids USING btree (header_id);


--
-- Name: tx_mh_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_mh_block_number_index ON eth.transaction_cids USING btree (mh_key, block_number);


--
-- Name: tx_src_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_src_index ON eth.transaction_cids USING btree (src);


--
-- Name: uncle_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX uncle_block_number_index ON eth.uncle_cids USING brin (block_number);


--
-- Name: uncle_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX uncle_header_id_index ON eth.uncle_cids USING btree (header_id);


--
-- Name: uncle_mh_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE UNIQUE INDEX uncle_mh_block_number_index ON eth.uncle_cids USING btree (mh_key, block_number);


--
-- Name: blocks_block_number_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX blocks_block_number_idx ON public.blocks USING btree (block_number DESC);


--
-- Name: access_list_elements trg_eth_access_list_elements; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER trg_eth_access_list_elements AFTER INSERT ON eth.access_list_elements FOR EACH ROW EXECUTE FUNCTION eth.graphql_subscription();


--
-- Name: header_cids trg_eth_header_cids; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER trg_eth_header_cids AFTER INSERT ON eth.header_cids FOR EACH ROW EXECUTE FUNCTION eth.graphql_subscription();


--
-- Name: log_cids trg_eth_log_cids; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER trg_eth_log_cids AFTER INSERT ON eth.log_cids FOR EACH ROW EXECUTE FUNCTION eth.graphql_subscription();


--
-- Name: receipt_cids trg_eth_receipt_cids; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER trg_eth_receipt_cids AFTER INSERT ON eth.receipt_cids FOR EACH ROW EXECUTE FUNCTION eth.graphql_subscription();


--
-- Name: state_accounts trg_eth_state_accounts; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER trg_eth_state_accounts AFTER INSERT ON eth.state_accounts FOR EACH ROW EXECUTE FUNCTION eth.graphql_subscription();


--
-- Name: state_cids trg_eth_state_cids; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER trg_eth_state_cids AFTER INSERT ON eth.state_cids FOR EACH ROW EXECUTE FUNCTION eth.graphql_subscription();


--
-- Name: storage_cids trg_eth_storage_cids; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER trg_eth_storage_cids AFTER INSERT ON eth.storage_cids FOR EACH ROW EXECUTE FUNCTION eth.graphql_subscription();


--
-- Name: transaction_cids trg_eth_transaction_cids; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER trg_eth_transaction_cids AFTER INSERT ON eth.transaction_cids FOR EACH ROW EXECUTE FUNCTION eth.graphql_subscription();


--
-- Name: uncle_cids trg_eth_uncle_cids; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER trg_eth_uncle_cids AFTER INSERT ON eth.uncle_cids FOR EACH ROW EXECUTE FUNCTION eth.graphql_subscription();


--
-- PostgreSQL database dump complete
--

