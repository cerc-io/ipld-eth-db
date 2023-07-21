--
-- PostgreSQL database dump
--

-- Dumped from database version 14.8
-- Dumped by pg_dump version 14.8 (Ubuntu 14.8-0ubuntu0.22.04.1)

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

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data (Community Edition)';


--
-- Name: eth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA eth;


--
-- Name: eth_meta; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA eth_meta;


--
-- Name: ipld; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ipld;


--
-- Name: header_result; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.header_result AS (
	block_number bigint,
	block_hash character varying(66),
	parent_hash character varying(66),
	cid text,
	td numeric,
	node_ids character varying(128)[],
	reward numeric,
	state_root character varying(66),
	tx_root character varying(66),
	receipt_root character varying(66),
	uncles_hash character varying(66),
	bloom bytea,
	"timestamp" bigint,
	coinbase character varying(66),
	canonical boolean
);


--
-- Name: child_result; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.child_result AS (
	has_child boolean,
	children public.header_result[]
);


--
-- Name: canonical_header_hash(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.canonical_header_hash(height bigint) RETURNS character varying
    LANGUAGE sql
    AS $$
    SELECT block_hash from eth.header_cids WHERE block_number = height AND canonical = true LIMIT 1;
$$;


--
-- Name: get_child(character varying, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_child(hash character varying, height bigint) RETURNS public.child_result
    LANGUAGE plpgsql
    AS $$
DECLARE
  child_height INT;
  temp_child header_result;
  new_child_result child_result;
BEGIN
  child_height = height + 1;
  -- short circuit if there are no children
  SELECT exists(SELECT 1
              FROM eth.header_cids
              WHERE parent_hash = hash
                AND block_number = child_height
                AND canonical = true
              LIMIT 1)
  INTO new_child_result.has_child;
  -- collect all the children for this header
  IF new_child_result.has_child THEN
    FOR temp_child IN
    SELECT * FROM eth.header_cids WHERE parent_hash = hash AND block_number = child_height AND canonical = true
    LOOP
      new_child_result.children = array_append(new_child_result.children, temp_child);
    END LOOP;
  END IF;
  RETURN new_child_result;
END
$$;


--
-- Name: get_storage_at_by_hash(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_storage_at_by_hash(v_state_leaf_key text, v_storage_leaf_key text, v_block_hash text) RETURNS TABLE(cid text, val bytea, block_number bigint, removed boolean, state_leaf_removed boolean)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_block_no BIGINT;
BEGIN
    SELECT h.block_number INTO v_block_no FROM eth.header_cids AS h WHERE block_hash = v_block_hash LIMIT 1;
    IF v_block_no IS NULL THEN
        RETURN;
    END IF;
    RETURN QUERY SELECT * FROM get_storage_at_by_number(v_state_leaf_key, v_storage_leaf_key, v_block_no);
END
$$;


--
-- Name: get_storage_at_by_number(text, text, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_storage_at_by_number(v_state_leaf_key text, v_storage_leaf_key text, v_block_no bigint) RETURNS TABLE(cid text, val bytea, block_number bigint, removed boolean, state_leaf_removed boolean)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_state_path       BYTEA;
    v_header           TEXT;
    v_canonical_header TEXT;
BEGIN
    CREATE TEMP TABLE tmp_tt_stg2
    (
        header_id          TEXT,
        cid                TEXT,
        val                BYTEA,
        block_number       BIGINT,
        removed            BOOL,
        state_leaf_removed BOOL
    ) ON COMMIT DROP;
    -- in best case scenario, the latest record we find for the provided keys is for a canonical block
    INSERT INTO tmp_tt_stg2
    SELECT storage_cids.header_id,
           storage_cids.cid,
           storage_cids.val,
           storage_cids.block_number,
           storage_cids.removed,
           was_state_leaf_removed_by_number(v_state_leaf_key, v_block_no) AS state_leaf_removed
    FROM eth.storage_cids
    WHERE storage_leaf_key = v_storage_leaf_key
      AND storage_cids.state_leaf_key = v_state_leaf_key -- can lookup directly on the leaf key in v5
      AND storage_cids.block_number <= v_block_no
    ORDER BY storage_cids.block_number DESC LIMIT 1;
    -- check if result is from canonical state
    SELECT header_id, canonical_header_hash(tmp_tt_stg2.block_number)
    INTO v_header, v_canonical_header
    FROM tmp_tt_stg2 LIMIT 1;
    IF v_header IS NULL OR v_header != v_canonical_header THEN
        RAISE NOTICE 'get_storage_at_by_number: chosen header NULL OR % != canonical header % for block number %, trying again.', v_header, v_canonical_header, v_block_no;
        TRUNCATE tmp_tt_stg2;
        -- If we hit on a non-canonical block, we need to go back and do a comprehensive check.
        -- We try to avoid this to avoid joining between storage_cids and header_cids
        INSERT INTO tmp_tt_stg2
        SELECT storage_cids.header_id,
               storage_cids.cid,
               storage_cids.val,
               storage_cids.block_number,
               storage_cids.removed,
               was_state_leaf_removed_by_number(
                       v_state_leaf_key,
                       v_block_no
                   ) AS state_leaf_removed
        FROM eth.storage_cids
                 INNER JOIN eth.header_cids ON (
                    storage_cids.header_id = header_cids.block_hash
                AND storage_cids.block_number = header_cids.block_number
            )
        WHERE state_leaf_key = v_state_leaf_key
          AND storage_leaf_key = v_storage_leaf_key
          AND storage_cids.block_number <= v_block_no
          AND header_cids.block_number <= v_block_no
          AND header_cids.block_hash = (SELECT canonical_header_hash(header_cids.block_number))
        ORDER BY header_cids.block_number DESC LIMIT 1;
    END IF;
    RETURN QUERY SELECT t.cid, t.val, t.block_number, t.removed, t.state_leaf_removed
                    FROM tmp_tt_stg2 AS t LIMIT 1;
END
$$;


--
-- Name: was_state_leaf_removed(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.was_state_leaf_removed(v_key character varying, v_hash character varying) RETURNS boolean
    LANGUAGE sql
    AS $$
    SELECT state_cids.removed = true
    FROM eth.state_cids
             INNER JOIN eth.header_cids ON (state_cids.header_id = header_cids.block_hash)
    WHERE state_leaf_key = v_key
      AND state_cids.block_number <= (SELECT block_number
                           FROM eth.header_cids
                           WHERE block_hash = v_hash)
    ORDER BY state_cids.block_number DESC LIMIT 1;
$$;


--
-- Name: was_state_leaf_removed_by_number(character varying, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.was_state_leaf_removed_by_number(v_key character varying, v_block_no bigint) RETURNS boolean
    LANGUAGE sql
    AS $$
    SELECT state_cids.removed = true
    FROM eth.state_cids
             INNER JOIN eth.header_cids ON (state_cids.header_id = header_cids.block_hash)
    WHERE state_leaf_key = v_key
      AND state_cids.block_number <= v_block_no
    ORDER BY state_cids.block_number DESC LIMIT 1;
$$;


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
    node_ids character varying(128)[] NOT NULL,
    reward numeric NOT NULL,
    state_root character varying(66) NOT NULL,
    tx_root character varying(66) NOT NULL,
    receipt_root character varying(66) NOT NULL,
    uncles_hash character varying(66) NOT NULL,
    bloom bytea NOT NULL,
    "timestamp" bigint NOT NULL,
    coinbase character varying(66) NOT NULL,
    canonical boolean DEFAULT true NOT NULL
);


--
-- Name: TABLE header_cids; Type: COMMENT; Schema: eth; Owner: -
--

COMMENT ON TABLE eth.header_cids IS '@name EthHeaderCids';


--
-- Name: COLUMN header_cids.node_ids; Type: COMMENT; Schema: eth; Owner: -
--

COMMENT ON COLUMN eth.header_cids.node_ids IS '@name EthNodeIDs';


--
-- Name: log_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.log_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    cid text NOT NULL,
    rct_id character varying(66) NOT NULL,
    address character varying(66) NOT NULL,
    index integer NOT NULL,
    topic0 character varying(66),
    topic1 character varying(66),
    topic2 character varying(66),
    topic3 character varying(66)
);


--
-- Name: receipt_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.receipt_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    tx_id character varying(66) NOT NULL,
    cid text NOT NULL,
    contract character varying(66),
    post_state character varying(66),
    post_status smallint
);


--
-- Name: state_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.state_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    state_leaf_key character varying(66) NOT NULL,
    cid text NOT NULL,
    diff boolean DEFAULT false NOT NULL,
    balance numeric,
    nonce bigint,
    code_hash character varying(66),
    storage_root character varying(66),
    removed boolean NOT NULL
);


--
-- Name: storage_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.storage_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    state_leaf_key character varying(66) NOT NULL,
    storage_leaf_key character varying(66) NOT NULL,
    cid text NOT NULL,
    diff boolean DEFAULT false NOT NULL,
    val bytea,
    removed boolean NOT NULL
);


--
-- Name: transaction_cids; Type: TABLE; Schema: eth; Owner: -
--

CREATE TABLE eth.transaction_cids (
    block_number bigint NOT NULL,
    header_id character varying(66) NOT NULL,
    tx_hash character varying(66) NOT NULL,
    cid text NOT NULL,
    dst character varying(66),
    src character varying(66) NOT NULL,
    index integer NOT NULL,
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
    index integer NOT NULL
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
-- Name: blocks; Type: TABLE; Schema: ipld; Owner: -
--

CREATE TABLE ipld.blocks (
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
-- Name: state_cids state_cids_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.state_cids
    ADD CONSTRAINT state_cids_pkey PRIMARY KEY (state_leaf_key, header_id, block_number);


--
-- Name: storage_cids storage_cids_pkey; Type: CONSTRAINT; Schema: eth; Owner: -
--

ALTER TABLE ONLY eth.storage_cids
    ADD CONSTRAINT storage_cids_pkey PRIMARY KEY (storage_leaf_key, state_leaf_key, header_id, block_number);


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
-- Name: watched_addresses watched_addresses_pkey; Type: CONSTRAINT; Schema: eth_meta; Owner: -
--

ALTER TABLE ONLY eth_meta.watched_addresses
    ADD CONSTRAINT watched_addresses_pkey PRIMARY KEY (address);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: ipld; Owner: -
--

ALTER TABLE ONLY ipld.blocks
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
-- Name: header_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX header_block_number_index ON eth.header_cids USING btree (block_number);


--
-- Name: header_cid_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE UNIQUE INDEX header_cid_block_number_index ON eth.header_cids USING btree (cid, block_number);


--
-- Name: log_address_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_address_index ON eth.log_cids USING btree (address);


--
-- Name: log_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_block_number_index ON eth.log_cids USING btree (block_number);


--
-- Name: log_cid_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_cid_block_number_index ON eth.log_cids USING btree (cid, block_number);


--
-- Name: log_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX log_header_id_index ON eth.log_cids USING btree (header_id);


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

CREATE INDEX rct_block_number_index ON eth.receipt_cids USING btree (block_number);


--
-- Name: rct_cid_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX rct_cid_block_number_index ON eth.receipt_cids USING btree (cid, block_number);


--
-- Name: rct_contract_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX rct_contract_index ON eth.receipt_cids USING btree (contract);


--
-- Name: rct_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX rct_header_id_index ON eth.receipt_cids USING btree (header_id);


--
-- Name: state_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_block_number_index ON eth.state_cids USING btree (block_number);


--
-- Name: state_cid_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_cid_block_number_index ON eth.state_cids USING btree (cid, block_number);


--
-- Name: state_code_hash_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_code_hash_index ON eth.state_cids USING btree (code_hash);


--
-- Name: state_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_header_id_index ON eth.state_cids USING btree (header_id);


--
-- Name: state_leaf_key_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_leaf_key_block_number_index ON eth.state_cids USING btree (state_leaf_key, block_number DESC);


--
-- Name: state_removed_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_removed_index ON eth.state_cids USING btree (removed);


--
-- Name: state_root_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX state_root_index ON eth.header_cids USING btree (state_root);


--
-- Name: storage_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_block_number_index ON eth.storage_cids USING btree (block_number);


--
-- Name: storage_cid_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_cid_block_number_index ON eth.storage_cids USING btree (cid, block_number);


--
-- Name: storage_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_header_id_index ON eth.storage_cids USING btree (header_id);


--
-- Name: storage_leaf_key_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_leaf_key_block_number_index ON eth.storage_cids USING btree (storage_leaf_key, block_number DESC);


--
-- Name: storage_removed_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_removed_index ON eth.storage_cids USING btree (removed);


--
-- Name: storage_state_leaf_key_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX storage_state_leaf_key_index ON eth.storage_cids USING btree (state_leaf_key);


--
-- Name: timestamp_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX timestamp_index ON eth.header_cids USING btree ("timestamp");


--
-- Name: tx_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_block_number_index ON eth.transaction_cids USING btree (block_number);


--
-- Name: tx_cid_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_cid_block_number_index ON eth.transaction_cids USING btree (cid, block_number);


--
-- Name: tx_dst_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_dst_index ON eth.transaction_cids USING btree (dst);


--
-- Name: tx_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_header_id_index ON eth.transaction_cids USING btree (header_id);


--
-- Name: tx_src_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX tx_src_index ON eth.transaction_cids USING btree (src);


--
-- Name: uncle_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX uncle_block_number_index ON eth.uncle_cids USING btree (block_number);


--
-- Name: uncle_cid_block_number_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE UNIQUE INDEX uncle_cid_block_number_index ON eth.uncle_cids USING btree (cid, block_number, index);


--
-- Name: uncle_header_id_index; Type: INDEX; Schema: eth; Owner: -
--

CREATE INDEX uncle_header_id_index ON eth.uncle_cids USING btree (header_id);


--
-- Name: blocks_block_number_idx; Type: INDEX; Schema: ipld; Owner: -
--

CREATE INDEX blocks_block_number_idx ON ipld.blocks USING btree (block_number DESC);


--
-- Name: log_cids ts_insert_blocker; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON eth.log_cids FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: receipt_cids ts_insert_blocker; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON eth.receipt_cids FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: state_cids ts_insert_blocker; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON eth.state_cids FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: storage_cids ts_insert_blocker; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON eth.storage_cids FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: transaction_cids ts_insert_blocker; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON eth.transaction_cids FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: uncle_cids ts_insert_blocker; Type: TRIGGER; Schema: eth; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON eth.uncle_cids FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: blocks ts_insert_blocker; Type: TRIGGER; Schema: ipld; Owner: -
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON ipld.blocks FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- PostgreSQL database dump complete
--

