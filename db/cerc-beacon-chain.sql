CREATE TABLE "slots" (
  "slot" SERIAL,
  "epoch" INT(255),
  PRIMARY KEY ("slot", "epoch")
);

CREATE TABLE "signed_beacon_block" (
  "root" TINYTEXT UNIQUE PRIMARY KEY,
  "slot" INT(255),
  "beacon_block_header" INT(255),
  "randao_reveal" TINYTEXT,
  "deposit_root" TINYTEXT,
  "deposit_count" TINYTEXT,
  "block_hash" TINYTEXT,
  "graffiti" TINYTEXT,
  "proposer_slashings" INT(255),
  "attester_slashings" INT(255),
  "attestations" INT(255),
  "deposits" INT(255),
  "voluntary_exits" INT(255),
  "signature" TINYTEXT,
  "sync_committee_bits" TINYTEXT,
  "sync_committee_signature" TINYTEXT,
  "execution_payload" INT(255)
);

CREATE TABLE "beacon_block_header" (
  "slot" INT(255) PRIMARY KEY,
  "proposer_index" INT(255),
  "parent_root" TINYTEXT,
  "state_root" TINYTEXT,
  "body_root" TINYTEXT
);

CREATE TABLE "validator" (
  "index" INT(255) PRIMARY KEY,
  "pubkey" TINYTEXT,
  "withdrawal_credentials" TINYTEXT,
  "slashed" boolean,
  "activation_eligibility_epoch" INT(255)
);

CREATE TABLE "proposer_slashings" (
  "slot" INT(255),
  "proposer_slashing_index" INT(255),
  "proposer_slashing" INT(255),
  PRIMARY KEY ("slot", "proposer_slashing_index")
);

CREATE TABLE "proposer_slashing" (
  "slot" INT(255) PRIMARY KEY,
  "signed_header_1" INT(255),
  "signed_header_2" INT(255)
);

CREATE TABLE "signed_beacon_block_header" (
  "message" INT(255) PRIMARY KEY,
  "signature" TINYTEXT UNIQUE
);

CREATE TABLE "attester_slashings" (
  "slot" INT(255),
  "attester_slashing_index" INT(255),
  "attester_slashing" INT(255),
  PRIMARY KEY ("slot", "attester_slashing_index")
);

CREATE TABLE "attester_slashing" (
  "slot" INT(255) PRIMARY KEY,
  "attestation_1" INT(255),
  "attestation_2" INT(255)
);

CREATE TABLE "attestation" (
  "slot" INT(255),
  "attesting_indices" INT(255) PRIMARY KEY,
  "index" INT(255),
  "beacon_block_root" TINYTEXT,
  "source_epoch" INT(255),
  "source_root" TINYTEXT,
  "target_epoch" INT(255),
  "target_root" TINYTEXT,
  "signature" TINYTEXT
);

CREATE TABLE "attesting_indices" (
  "slot" INT(255),
  "attesting_indices_index" INT(255) PRIMARY KEY,
  "validator" INT(255)
);

CREATE TABLE "attestations" (
  "slot" INT(255),
  "aggregation_index" INT(255) PRIMARY KEY,
  "aggregation_bits_hash" TINYTEXT
);

CREATE TABLE "aggregation_bits" (
  "hash" TINYTEXT UNIQUE,
  "slot" INT(255),
  "index" INT(255),
  "beacon_block_root" TINYTEXT,
  "source_epoch" INT(255),
  "source_root" TINYTEXT,
  "target_epoch" INT(255),
  "target_root" TINYTEXT,
  "signature" TINYTEXT,
  PRIMARY KEY ("hash", "index")
);

CREATE TABLE "deposits" (
  "slot" INT(255),
  "deposit_index" INT(255) PRIMARY KEY,
  "deposit" INT(255)
);

CREATE TABLE "deposit" (
  "slot" INT(255),
  "proofs" TINYTEXT,
  "pubkey" TINYTEXT,
  "withdrawal_credentials" TINYTEXT,
  "amount" INT(255),
  "signature" TINYTEXT,
  PRIMARY KEY ("slot", "proofs")
);

CREATE TABLE "voluntary_exits" (
  "slot" INT(255),
  "voluntary_exit_index" INT(255),
  "epoch" INT(255),
  "validator_index" INT(255),
  "signature" TINYTEXT,
  PRIMARY KEY ("slot", "voluntary_exit_index")
);

CREATE TABLE "execution_payloads" (
  "slot" INT(255) PRIMARY KEY,
  "block_hash" TINYTEXT,
  "parent_hash" TINYTEXT,
  "coinbase" TINYTEXT,
  "state_root" TINYTEXT,
  "receipt_root" TINYTEXT,
  "logs_bloom" TINYTEXT,
  "random" TINYTEXT,
  "block_number" INT(255),
  "gas_limit" INT(255),
  "gas_used" INT(255),
  "timestamp" INT(255),
  "extra_data" TINYTEXT,
  "base_fee_per_gas" TINYTEXT,
  "transaction" INT(255)
);

CREATE TABLE "transactions" (
  "slot" INT(255),
  "index" INT(255),
  "transaction" TINYTEXT,
  PRIMARY KEY ("slot", "index")
);

CREATE TABLE "beacon_state" (
  "slot" INT(255) PRIMARY KEY,
  "genesis_time" INT(255),
  "genesis_validators_root" TINYTEXT,
  "fork_previous_version" TINYTEXT,
  "fork_current_version" TINYTEXT,
  "fork_epoch" INT(255),
  "latest_block_header_slot" INT(255),
  "deposit_root" TINYTEXT,
  "deposit_count" TINYTEXT,
  "block_hash" TINYTEXT,
  "eth1_deposit_index" INT(225),
  "validator_slot" INT(255),
  "balances_slot" INT(255),
  "randao_mixes_slot" INT(255),
  "slashings_slot" INT(255),
  "previous_epoch_attestations_id" INT(255),
  "current_epoch_attestations_id" INT(255),
  "justification_bits" INT(255),
  "previous_justified_checkpoint" INT(255),
  "current_justified_checkpoint" INT(255),
  "finalized_checkpoint" INT(255),
  "inactivity_scores_slot" INT(255),
  "current_sync_committee_slot" INT(255),
  "next_sync_committee_slot" INT(255),
  "latest_execution_payload_header_parent_hash" INT(255)
);

CREATE TABLE "validator_state" (
  "slot" INT(255),
  "validator" INT(255),
  PRIMARY KEY ("slot", "validator")
);

CREATE TABLE "balances" (
  "slot" INT(256),
  "index" INT(255),
  "gwei" INT(255),
  PRIMARY KEY ("slot", "index")
);

CREATE TABLE "randao_mixes" (
  "slot" INT(255),
  "index" INT(255),
  "randao_value" TINYTEXT,
  PRIMARY KEY ("slot", "index")
);

CREATE TABLE "slashings" (
  "slot" INT(255),
  "index" INT(255),
  "gwei" INT(255),
  PRIMARY KEY ("slot", "index")
);

CREATE TABLE "pending_attestations" (
  "slot" INT(255),
  "index" INT(255),
  "data_slot" INT(255),
  "aggregation_bits" TINYTEXT,
  "inclusion_delay" INT(255),
  "proposer_index" INT(255),
  PRIMARY KEY ("slot", "index")
);

CREATE TABLE "attestations_data" (
  "slot" INT(255) PRIMARY KEY,
  "index" INT(255),
  "beacon_block_root" TINYTEXT,
  "source" INT(255),
  "target" INT(255)
);

CREATE TABLE "checkpoint" (
  "slot" INT(255),
  "epoch" INT(255),
  "root" TINYTEXT,
  PRIMARY KEY ("slot", "epoch")
);

CREATE TABLE "inactivity_scores" (
  "slot" INT(255),
  "hash" INT(255),
  PRIMARY KEY ("slot", "hash")
);

CREATE TABLE "sync_committee" (
  "slot" INT(255) PRIMARY KEY,
  "pubkeys" INT(255),
  "aggregate_pubkey" TINYTEXT
);

CREATE TABLE "sync_committee_pubkeys" (
  "slot" INT(255),
  "hash" TINYTEXT,
  PRIMARY KEY ("slot", "hash")
);

CREATE TABLE "pubkeys" (
  "hash" TINYTEXT PRIMARY KEY
);

CREATE TABLE "execution_payload_header" (
  "parent_hash" TINYTEXT PRIMARY KEY,
  "coinbase" TINYTEXT,
  "state_root" TINYTEXT,
  "receipt_root" TINYTEXT,
  "logs_bloom" TINYTEXT,
  "random" TINYTEXT,
  "block_number" INT(255),
  "gas_limit" INT(255),
  "gas_used" INT(255),
  "timestamp" INT(255),
  "extra_data" TINYTEXT,
  "base_fee_per_gas" TINYTEXT,
  "block_hash" TINYTEXT,
  "transactions_root" TINYTEXT
);

ALTER TABLE "signed_beacon_block" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "signed_beacon_block" ADD FOREIGN KEY ("beacon_block_header") REFERENCES "beacon_block_header" ("slot");

ALTER TABLE "proposer_slashings" ADD FOREIGN KEY ("slot") REFERENCES "signed_beacon_block" ("proposer_slashings");

ALTER TABLE "attester_slashings" ADD FOREIGN KEY ("slot") REFERENCES "signed_beacon_block" ("attester_slashings");

ALTER TABLE "attestations" ADD FOREIGN KEY ("slot") REFERENCES "signed_beacon_block" ("attestations");

ALTER TABLE "deposits" ADD FOREIGN KEY ("slot") REFERENCES "signed_beacon_block" ("deposits");

ALTER TABLE "voluntary_exits" ADD FOREIGN KEY ("slot") REFERENCES "signed_beacon_block" ("voluntary_exits");

ALTER TABLE "signed_beacon_block" ADD FOREIGN KEY ("execution_payload") REFERENCES "execution_payloads" ("slot");

ALTER TABLE "beacon_block_header" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "beacon_block_header" ADD FOREIGN KEY ("proposer_index") REFERENCES "validator" ("index");

ALTER TABLE "beacon_block_header" ADD FOREIGN KEY ("parent_root") REFERENCES "signed_beacon_block" ("root");

ALTER TABLE "proposer_slashings" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "proposer_slashings" ADD FOREIGN KEY ("proposer_slashing") REFERENCES "proposer_slashing" ("slot");

ALTER TABLE "proposer_slashing" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "proposer_slashing" ADD FOREIGN KEY ("signed_header_1") REFERENCES "signed_beacon_block_header" ("signature");

ALTER TABLE "proposer_slashing" ADD FOREIGN KEY ("signed_header_2") REFERENCES "signed_beacon_block_header" ("signature");

ALTER TABLE "signed_beacon_block_header" ADD FOREIGN KEY ("message") REFERENCES "beacon_block_header" ("slot");

ALTER TABLE "attester_slashings" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "attester_slashings" ADD FOREIGN KEY ("attester_slashing") REFERENCES "attester_slashing" ("slot");

ALTER TABLE "attester_slashing" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "attestation" ADD FOREIGN KEY ("slot") REFERENCES "attester_slashing" ("attestation_1");

ALTER TABLE "attestation" ADD FOREIGN KEY ("slot") REFERENCES "attester_slashing" ("attestation_2");

ALTER TABLE "attestation" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "attesting_indices" ADD FOREIGN KEY ("slot") REFERENCES "attestation" ("attesting_indices");

ALTER TABLE "attestation" ADD FOREIGN KEY ("beacon_block_root") REFERENCES "signed_beacon_block" ("root");

ALTER TABLE "attestation" ADD FOREIGN KEY ("source_root") REFERENCES "signed_beacon_block" ("root");

ALTER TABLE "attestation" ADD FOREIGN KEY ("target_root") REFERENCES "signed_beacon_block" ("root");

ALTER TABLE "attesting_indices" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "attesting_indices" ADD FOREIGN KEY ("validator") REFERENCES "validator" ("index");

ALTER TABLE "attestations" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "attestations" ADD FOREIGN KEY ("aggregation_bits_hash") REFERENCES "aggregation_bits" ("hash");

ALTER TABLE "aggregation_bits" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "aggregation_bits" ADD FOREIGN KEY ("beacon_block_root") REFERENCES "signed_beacon_block" ("root");

ALTER TABLE "aggregation_bits" ADD FOREIGN KEY ("source_root") REFERENCES "signed_beacon_block" ("root");

ALTER TABLE "aggregation_bits" ADD FOREIGN KEY ("target_root") REFERENCES "signed_beacon_block" ("root");

ALTER TABLE "deposits" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "deposit" ADD FOREIGN KEY ("slot") REFERENCES "deposits" ("deposit");

ALTER TABLE "deposit" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "deposit" ADD FOREIGN KEY ("pubkey") REFERENCES "validator" ("pubkey");

ALTER TABLE "deposit" ADD FOREIGN KEY ("withdrawal_credentials") REFERENCES "validator" ("withdrawal_credentials");

ALTER TABLE "voluntary_exits" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "voluntary_exits" ADD FOREIGN KEY ("validator_index") REFERENCES "validator" ("index");

ALTER TABLE "execution_payloads" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "execution_payloads" ADD FOREIGN KEY ("transaction") REFERENCES "transactions" ("slot");

ALTER TABLE "transactions" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("latest_block_header_slot") REFERENCES "beacon_block_header" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("deposit_root") REFERENCES "signed_beacon_block" ("deposit_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("deposit_count") REFERENCES "signed_beacon_block" ("deposit_count");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("block_hash") REFERENCES "signed_beacon_block" ("block_hash");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("validator_slot") REFERENCES "validator_state" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("balances_slot") REFERENCES "balances" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("randao_mixes_slot") REFERENCES "randao_mixes" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("slashings_slot") REFERENCES "slashings" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("previous_epoch_attestations_id") REFERENCES "pending_attestations" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("current_epoch_attestations_id") REFERENCES "pending_attestations" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("previous_justified_checkpoint") REFERENCES "checkpoint" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("current_justified_checkpoint") REFERENCES "checkpoint" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("finalized_checkpoint") REFERENCES "checkpoint" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("inactivity_scores_slot") REFERENCES "inactivity_scores" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("current_sync_committee_slot") REFERENCES "sync_committee" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("next_sync_committee_slot") REFERENCES "sync_committee" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("latest_execution_payload_header_parent_hash") REFERENCES "execution_payload_header" ("parent_hash");

ALTER TABLE "validator_state" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "validator_state" ADD FOREIGN KEY ("validator") REFERENCES "validator" ("index");

ALTER TABLE "balances" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "randao_mixes" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "slashings" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "pending_attestations" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "pending_attestations" ADD FOREIGN KEY ("data_slot") REFERENCES "attestations_data" ("slot");

ALTER TABLE "pending_attestations" ADD FOREIGN KEY ("proposer_index") REFERENCES "validator" ("index");

ALTER TABLE "attestations_data" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "attestations_data" ADD FOREIGN KEY ("beacon_block_root") REFERENCES "signed_beacon_block" ("root");

ALTER TABLE "attestations_data" ADD FOREIGN KEY ("source") REFERENCES "checkpoint" ("slot");

ALTER TABLE "attestations_data" ADD FOREIGN KEY ("target") REFERENCES "checkpoint" ("slot");

ALTER TABLE "checkpoint" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "checkpoint" ADD FOREIGN KEY ("epoch") REFERENCES "slots" ("epoch");

ALTER TABLE "checkpoint" ADD FOREIGN KEY ("root") REFERENCES "signed_beacon_block" ("root");

ALTER TABLE "inactivity_scores" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "sync_committee" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "sync_committee" ADD FOREIGN KEY ("pubkeys") REFERENCES "sync_committee_pubkeys" ("slot");

ALTER TABLE "sync_committee_pubkeys" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "sync_committee_pubkeys" ADD FOREIGN KEY ("hash") REFERENCES "pubkeys" ("hash");
