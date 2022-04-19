CREATE TABLE "slots" (
  "slot" "bigint unsigned" NOT NULL,
  "block_root" VARCHAR(66) UNIQUE,
  "state_root" VARCHAR(66) UNIQUE,
  "status" bytea NOT NULL,
  "epoch" "bigint unsigned" NOT NULL,
  PRIMARY KEY ("slot", "block_root")
);

CREATE TABLE "signed_beacon_block" (
  "block_root" VARCHAR(66) PRIMARY KEY,
  "slot" "bigint unsigned",
  "proposer_index" "bigint unsigned",
  "parent_root" VARCHAR(66),
  "body_root" VARCHAR(66),
  "randao_reveal" TINYTEXT,
  "eth1_data" VARCHAR(66),
  "graffiti" bytea,
  "proposer_slashings" VARCHAR(66),
  "attester_slashings" VARCHAR(66),
  "attestations" VARCHAR(66),
  "deposits" VARCHAR(66),
  "voluntary_exits" VARCHAR(66),
  "signature" VARCHAR(98),
  "sync_committee_bits" bytea,
  "sync_committee_signature" VARCHAR(98),
  "execution_payload" VARCHAR(66)
);

CREATE TABLE "validator" (
  "validator_index" "bigint unsigned" PRIMARY KEY,
  "pubkey" VARCHAR(98),
  "withdrawal_credentials" VARCHAR(66),
  "slashed" boolean,
  "effective_balance" "bigint unsigned",
  "slashes_at_slot" "bigint unsigned",
  "activation_eligibility_epoch" "bigint unsigned",
  "activation_epoch" "bigint unsigned",
  "exit_epoch" "bigint unsigned",
  "withdrawable_epoch" "bigint unsigned"
);

CREATE TABLE "eth1_data" (
  "block_root" VARCHAR(66) PRIMARY KEY,
  "deposit_root" VARCHAR(66),
  "deposit_count" "bigint unsigned",
  "block_hash" VARCHAR(66)
);

CREATE TABLE "validator_effective_balance" (
  "validator_index" "bigint unsigned",
  "block" VARCHAR(66),
  "gwei" "bigint unsigned",
  PRIMARY KEY ("validator_index", "block")
);

CREATE TABLE "proposer_slashings" (
  "block_root" VARCHAR(66),
  "proposer_slashing_index" INT(255),
  "proposer_slashing" VARCHAR(66),
  PRIMARY KEY ("block_root", "proposer_slashing_index")
);

CREATE TABLE "proposer_slashing" (
  "block_root" VARCHAR(66) PRIMARY KEY,
  "signed_header_1" VARCHAR(98),
  "signed_header_2" VARCHAR(98)
);

CREATE TABLE "signed_beacon_block_header" (
  "message" VARCHAR(66) PRIMARY KEY,
  "signature" VARCHAR(98) UNIQUE
);

CREATE TABLE "attester_slashings" (
  "block_root" VARCHAR(66),
  "attester_slashing_index" INT(255),
  "attester_slashing" VARCHAR(66),
  PRIMARY KEY ("block_root", "attester_slashing_index")
);

CREATE TABLE "attester_slashing" (
  "block_root" VARCHAR(66) PRIMARY KEY,
  "attestation_1" VARCHAR(66),
  "attestation_2" VARCHAR(66)
);

CREATE TABLE "attestation" (
  "block_root" VARCHAR(66),
  "attesting_indices" VARCHAR(66),
  "slot" "bigint unsigned",
  "index" INT(255),
  "beacon_block_root" VARCHAR(66),
  "source_epoch" "bigint unsigned",
  "source_root" VARCHAR(66),
  "target_epoch" "bigint unsigned",
  "target_root" VARCHAR(66),
  "signature" VARCHAR(98),
  PRIMARY KEY ("block_root", "attesting_indices")
);

CREATE TABLE "attesting_indices" (
  "block_root" VARCHAR(66),
  "attesting_indices_index" INT(255) PRIMARY KEY,
  "validator" "bigint unsigned"
);

CREATE TABLE "attestations" (
  "block_root" VARCHAR(66),
  "aggregation_index" INT(255),
  "aggregation_bits" VARCHAR(4),
  "signature" VARCHAR(98),
  "data" VARCHAR(66),
  PRIMARY KEY ("block_root", "aggregation_index")
);

CREATE TABLE "attestations_data" (
  "block_root" VARCHAR(66) PRIMARY KEY,
  "slot" "bigint unsigned",
  "committee_index" "bigint unsigned",
  "source_epoch" "bigint unsigned",
  "source_root" VARCHAR(66),
  "target_epoch" "bigint unsigned",
  "target_root" VARCHAR(66)
);

CREATE TABLE "deposits" (
  "block_root" VARCHAR(66),
  "deposit_index" INT(255),
  "deposit" VARCHAR(66),
  PRIMARY KEY ("block_root", "deposit_index")
);

CREATE TABLE "deposit" (
  "block_root" VARCHAR(66),
  "proofs" VARCHAR(66),
  "pubkey" VARCHAR(98),
  "withdrawal_credentials" VARCHAR(66),
  "amount" "bigint unsigned",
  "signature" VARCHAR(98),
  PRIMARY KEY ("block_root", "proofs")
);

CREATE TABLE "voluntary_exits" (
  "block_root" VARCHAR(66),
  "voluntary_exit_index" INT(255),
  "epoch" "bigint unsigned",
  "validator_index" "bigint unsigned",
  "signature" VARCHAR(98),
  PRIMARY KEY ("block_root", "voluntary_exit_index")
);

CREATE TABLE "execution_payloads" (
  "block_root" VARCHAR(66) PRIMARY KEY,
  "block_hash" VARCHAR(66),
  "parent_hash" VARCHAR(66),
  "coinbase" VARCHAR(42),
  "state_root" VARCHAR(66),
  "receipt_root" VARCHAR(66),
  "logs_bloom" VARCHAR(514),
  "random" VARCHAR(66),
  "block_number" "bigint unsigned",
  "gas_limit" "bigint unsigned",
  "gas_used" "bigint unsigned",
  "timestamp" "bigint unsigned",
  "extra_data" bytea,
  "base_fee_per_gas" VARCHAR(66),
  "transaction" INT(255)
);

CREATE TABLE "transactions" (
  "block_root" VARCHAR(66),
  "index" INT(255),
  "transaction" TINYTEXT,
  PRIMARY KEY ("block_root", "index")
);

CREATE TABLE "beacon_state" (
  "block_root" VARCHAR(66) PRIMARY KEY,
  "slot" INT(255),
  "genesis_time" "bigint unsigned",
  "genesis_validators_root" VARCHAR(66),
  "fork_previous_version" VARCHAR(10),
  "fork_current_version" VARCHAR(10),
  "fork_epoch" "bigint unsigned",
  "latest_block_header" VARCHAR(66),
  "eth1_data" VARCHAR(66),
  "eth1_data_votes" VARCHAR(66),
  "eth1_deposit_index" "bigint unsigned",
  "validators" VARCHAR(66),
  "balances" VARCHAR(66),
  "randao_mixes" VARCHAR(66),
  "slashings" VARCHAR(66),
  "previous_epoch_attestations" VARCHAR(66),
  "current_epoch_attestations" VARCHAR(66),
  "justification_bits" VARCHAR(4),
  "previous_justified_checkpoint" VARCHAR(66),
  "current_justified_checkpoint" VARCHAR(66),
  "finalized_checkpoint" VARCHAR(66),
  "inactivity_scores_slot" VARCHAR(66),
  "current_sync_committee_slot" VARCHAR(66),
  "next_sync_committee_slot" VARCHAR(66),
  "latest_execution_payload_header_parent_hash" INT(255)
);

CREATE TABLE "beacon_block_header" (
  "state_root" VARCHAR(66) PRIMARY KEY,
  "proposer_index" "bigint unsigned",
  "parent_root" VARCHAR(66),
  "body_root" VARCHAR(66)
);

CREATE TABLE "eth1_data_votes" (
  "block_root" VARCHAR(66),
  "eth1_data" VARCHAR(66),
  PRIMARY KEY ("block_root", "eth1_data")
);

CREATE TABLE "validator_state" (
  "block_root" VARCHAR(66),
  "validator" "bigint unsigned",
  PRIMARY KEY ("block_root", "validator")
);

CREATE TABLE "balances" (
  "block_root" VARCHAR(66),
  "index" INT(255),
  "gwei" "bigint unsigned",
  PRIMARY KEY ("block_root", "index")
);

CREATE TABLE "randao_mixes" (
  "block_root" VARCHAR(66),
  "index" INT(255),
  "randao_value" VARCHAR(66),
  PRIMARY KEY ("block_root", "index")
);

CREATE TABLE "slashings" (
  "block_root" VARCHAR(66),
  "index" INT(255),
  "gwei" "bigint unsigned",
  PRIMARY KEY ("block_root", "index")
);

CREATE TABLE "pending_attestations" (
  "block_root" VARCHAR(66),
  "index" INT(255),
  "data" VARCHAR(66),
  "aggregation_bits" VARCHAR(4),
  "inclusion_delay" "bigint unsigned",
  "proposer_index" "bigint unsigned",
  PRIMARY KEY ("block_root", "index")
);

CREATE TABLE "checkpoint" (
  "block_root" VARCHAR(66),
  "epoch" "bigint unsigned",
  "root" VARCHAR(66),
  PRIMARY KEY ("block_root", "epoch")
);

CREATE TABLE "inactivity_scores" (
  "block_root" VARCHAR(66),
  "index" "bigint unsigned",
  PRIMARY KEY ("block_root", "index")
);

CREATE TABLE "sync_committee" (
  "block_root" VARCHAR(66) PRIMARY KEY,
  "pubkeys" VARCHAR(66),
  "aggregate_pubkey" VARCHAR(98)
);

CREATE TABLE "sync_committee_pubkeys" (
  "block_root" VARCHAR(66),
  "index" VARCHAR(98),
  PRIMARY KEY ("block_root", "index")
);

CREATE TABLE "pubkeys" (
  "pubkey" VARCHAR(98) PRIMARY KEY
);

CREATE TABLE "execution_payload_header" (
  "block_root" VARCHAR(66) PRIMARY KEY,
  "parent_hash" VARCHAR(66),
  "coinbase" VARCHAR(42),
  "state_root" VARCHAR(66),
  "receipt_root" VARCHAR(66),
  "logs_bloom" VARCHAR(514),
  "random" VARCHAR(66),
  "block_number" "bigint unsigned",
  "gas_limit" "bigint unsigned",
  "gas_used" "bigint unsigned",
  "timestamp" "bigint unsigned",
  "extra_data" bytea,
  "base_fee_per_gas" VARCHAR(66),
  "block_hash" VARCHAR(66),
  "transactions_root" VARCHAR(66)
);

COMMENT ON COLUMN "slots"."status" IS 'proposed || missed || forked';

COMMENT ON COLUMN "signed_beacon_block"."block_root" IS 'this value is not provided in the SignedBeaconBlock, we get it when listening to head';

COMMENT ON COLUMN "signed_beacon_block"."slot" IS 'ex: 139';

COMMENT ON COLUMN "signed_beacon_block"."proposer_index" IS 'ex: 2185';

COMMENT ON COLUMN "signed_beacon_block"."parent_root" IS 'ex: 0x19c7252f6150f964fa62cc94e7ff9df79b74c552bf3d134b1f7a317c01662c1d';

COMMENT ON COLUMN "signed_beacon_block"."randao_reveal" IS 'ex: 0x820574e5514420659826e18b183d7d0478389bce4a08464427168c97e67884c5d38839675313688d4ada52259becb1a40b8ee7ccaf983c9ae56d69c0000a7114006c6bb640a515075b7610b8bdf21506d4146787550ddd89a5ed8956ce470bb6';

COMMENT ON COLUMN "signed_beacon_block"."graffiti" IS 'ex: 0x53746566616e2333393137000000000000000000000000000000000000000000';

COMMENT ON COLUMN "signed_beacon_block"."proposer_slashings" IS 'ex: ';

COMMENT ON COLUMN "signed_beacon_block"."attester_slashings" IS 'ex: ';

COMMENT ON COLUMN "signed_beacon_block"."attestations" IS 'ex: ';

COMMENT ON COLUMN "signed_beacon_block"."deposits" IS 'ex: ';

COMMENT ON COLUMN "signed_beacon_block"."voluntary_exits" IS 'ex: ';

COMMENT ON COLUMN "signed_beacon_block"."signature" IS 'ex: 0xaa4bba19b1c185002f446cc79e24bcf917808569394669b4fea9b855f2f49e6f76c2408384d8ded3d151ed5ab238951a137a777958525bdf58c6fa75d6418ae4f5e67177747040919f81a86a1065355b2d1abb1553bc94630a6c06e4a67e5fe4';

COMMENT ON COLUMN "validator"."validator_index" IS 'ex: 2185';

COMMENT ON COLUMN "validator"."slashes_at_slot" IS 'allows us to know which slot this validator was slashed';

COMMENT ON COLUMN "eth1_data"."deposit_root" IS 'ex: 0x53d90f778f975dcca3f30e072b5c1a85cfd7a1b977b78620d94f143d06432f9b';

COMMENT ON COLUMN "eth1_data"."deposit_count" IS 'ex: 22637';

COMMENT ON COLUMN "eth1_data"."block_hash" IS 'ex: 0xe0c057333355956e8fb8d88382f5676bbe083fbf8b978f0db719b4d02ae70777';

COMMENT ON COLUMN "proposer_slashings"."proposer_slashing_index" IS 'ex: 1';

COMMENT ON COLUMN "proposer_slashings"."proposer_slashing" IS 'ex: ';

COMMENT ON COLUMN "proposer_slashing"."signed_header_1" IS 'ex: ';

COMMENT ON COLUMN "proposer_slashing"."signed_header_2" IS 'ex: ';

COMMENT ON COLUMN "signed_beacon_block_header"."signature" IS 'ex: 0xa5e55750045079ee500ce6176c3ea83ae1ceb415357e6019a43641cf15a961bc7cc799923a1b0d019be0a6c6138b89e7025a57cedabbd262ceefe44931052b083e99d92624a91ace8f16acd6647f7234391df2e3e3f77a68816072793e8a718d';

COMMENT ON COLUMN "attester_slashings"."attester_slashing_index" IS 'ex: ';

COMMENT ON COLUMN "attester_slashings"."attester_slashing" IS 'ex: ';

COMMENT ON COLUMN "attester_slashing"."attestation_1" IS 'ex: ';

COMMENT ON COLUMN "attester_slashing"."attestation_2" IS 'ex: ';

COMMENT ON COLUMN "attestation"."attesting_indices" IS 'ex: ';

COMMENT ON COLUMN "attestation"."index" IS 'ex: 0';

COMMENT ON COLUMN "attestation"."beacon_block_root" IS 'ex: 0x69f3e09fa4fdc8b6e6162588a488606175069c396d215d44f0a8fb7565d911e4';

COMMENT ON COLUMN "attestation"."source_epoch" IS 'ex: 19';

COMMENT ON COLUMN "attestation"."source_root" IS 'ex: 0xf7f25edf9ead6eaf17d1dfaa4c3259dcc3d4897986fa4141577695793b90240f';

COMMENT ON COLUMN "attestation"."target_epoch" IS 'ex: 20';

COMMENT ON COLUMN "attestation"."target_root" IS 'ex: 0x9f3af8c4ef4b38e82617e1d82ca868f785d015a2de45e112a398f6748ea4d6dc';

COMMENT ON COLUMN "attestation"."signature" IS 'ex: 0xb2883dffd3fd8668e410d55915ee5e72dd08a423a2c28033adec54f0178062ea9ac3f47fa0ef952ae50494c9705b911215d8c5c9da5619760004f59c09a58077eb0ba6fb2fd2135265b465d27be536eeabd40bb61df4742a438c7e6723b6c18a';

COMMENT ON COLUMN "attesting_indices"."attesting_indices_index" IS 'ex: 1';

COMMENT ON COLUMN "attesting_indices"."validator" IS 'ex: 183';

COMMENT ON COLUMN "attestations"."aggregation_index" IS 'ex: 1';

COMMENT ON COLUMN "attestations_data"."slot" IS 'previous slot';

COMMENT ON COLUMN "attestations_data"."source_epoch" IS 'ex: 19';

COMMENT ON COLUMN "attestations_data"."source_root" IS 'ex: 0xf7f25edf9ead6eaf17d1dfaa4c3259dcc3d4897986fa4141577695793b90240f';

COMMENT ON COLUMN "attestations_data"."target_epoch" IS 'ex: 20';

COMMENT ON COLUMN "attestations_data"."target_root" IS 'ex: 0x9f3af8c4ef4b38e82617e1d82ca868f785d015a2de45e112a398f6748ea4d6dc';

COMMENT ON COLUMN "deposits"."deposit_index" IS 'ex: ';

COMMENT ON COLUMN "deposits"."deposit" IS 'ex: ';

COMMENT ON COLUMN "deposit"."pubkey" IS 'ex: 0xa0d46f3e977da3c53d46dcff9a4f7e6b4895cf9fb66ea76d82fd5462d3ed32c378d733017640dfaa2a9012de7a71d9b9';

COMMENT ON COLUMN "deposit"."withdrawal_credentials" IS 'ex: 0x00f51a03211451f1cbb0a6b609cfefdb777b837e33442141cae67ff4b9297a6f';

COMMENT ON COLUMN "deposit"."signature" IS 'ex: 0x96155845317fcd242b38051dc873b6614601daf997691454c28d882df5b2086dde861b2357b773d2f2a9a8487296306f03269fade98b4610dbabfdbc70aba26485fa2519b55c22629aad4e93e7dd1bb1e16a80d1dc9c896134f01029540bfa69';

COMMENT ON COLUMN "voluntary_exits"."voluntary_exit_index" IS 'ex: 1';

COMMENT ON COLUMN "voluntary_exits"."epoch" IS 'ex: 929';

COMMENT ON COLUMN "voluntary_exits"."validator_index" IS 'ex: 5194';

COMMENT ON COLUMN "voluntary_exits"."signature" IS 'ex: 0x93f39045a23a8fd9818cbc0514a678415d8af96fb8f81322d4615c7398efc8a0835576aa7924be089a424ea0be1ea6470e732c3c62ac71c600981c90f7a1fe6d2856b7fa18afb46559fc449f0237bd6b07c368fefcf31ed6c5118aaefbaa7b47';

COMMENT ON COLUMN "execution_payloads"."random" IS 'could be a different type';

COMMENT ON COLUMN "beacon_state"."block_root" IS 'this value is not provided in the SignedBeaconBlock, we get it when listening to head';

COMMENT ON COLUMN "beacon_block_header"."state_root" IS 'ex: 0xb9739996c890b47251eecab6643b7400ff992bf76ed75b26f0b04146ea4cd640';

COMMENT ON COLUMN "beacon_block_header"."proposer_index" IS 'ex: 2185';

COMMENT ON COLUMN "beacon_block_header"."parent_root" IS 'ex: 0x19c7252f6150f964fa62cc94e7ff9df79b74c552bf3d134b1f7a317c01662c1d';

COMMENT ON COLUMN "eth1_data_votes"."block_root" IS 'this value is not provided in the SignedBeaconBlock, we get it when listening to head';

COMMENT ON COLUMN "checkpoint"."root" IS 'first block in the epoch';

COMMENT ON COLUMN "execution_payload_header"."random" IS 'could be a different type';

ALTER TABLE "signed_beacon_block" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "signed_beacon_block" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "signed_beacon_block" ADD FOREIGN KEY ("proposer_index") REFERENCES "validator" ("validator_index");

ALTER TABLE "signed_beacon_block" ADD FOREIGN KEY ("eth1_data") REFERENCES "eth1_data" ("block_root");

ALTER TABLE "proposer_slashings" ADD FOREIGN KEY ("block_root") REFERENCES "signed_beacon_block" ("proposer_slashings");

ALTER TABLE "attester_slashings" ADD FOREIGN KEY ("block_root") REFERENCES "signed_beacon_block" ("attester_slashings");

ALTER TABLE "attestations" ADD FOREIGN KEY ("block_root") REFERENCES "signed_beacon_block" ("attestations");

ALTER TABLE "deposits" ADD FOREIGN KEY ("block_root") REFERENCES "signed_beacon_block" ("deposits");

ALTER TABLE "voluntary_exits" ADD FOREIGN KEY ("block_root") REFERENCES "signed_beacon_block" ("voluntary_exits");

ALTER TABLE "signed_beacon_block" ADD FOREIGN KEY ("execution_payload") REFERENCES "execution_payloads" ("block_root");

ALTER TABLE "validator" ADD FOREIGN KEY ("pubkey") REFERENCES "pubkeys" ("pubkey");

ALTER TABLE "validator" ADD FOREIGN KEY ("effective_balance") REFERENCES "validator_effective_balance" ("validator_index");

ALTER TABLE "validator" ADD FOREIGN KEY ("slashes_at_slot") REFERENCES "slots" ("slot");

ALTER TABLE "validator" ADD FOREIGN KEY ("activation_eligibility_epoch") REFERENCES "slots" ("epoch");

ALTER TABLE "validator" ADD FOREIGN KEY ("activation_epoch") REFERENCES "slots" ("epoch");

ALTER TABLE "validator" ADD FOREIGN KEY ("exit_epoch") REFERENCES "slots" ("epoch");

ALTER TABLE "validator" ADD FOREIGN KEY ("withdrawable_epoch") REFERENCES "slots" ("epoch");

ALTER TABLE "eth1_data" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "validator_effective_balance" ADD FOREIGN KEY ("validator_index") REFERENCES "validator" ("validator_index");

ALTER TABLE "validator_effective_balance" ADD FOREIGN KEY ("block") REFERENCES "slots" ("block_root");

ALTER TABLE "proposer_slashings" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "proposer_slashings" ADD FOREIGN KEY ("proposer_slashing") REFERENCES "proposer_slashing" ("block_root");

ALTER TABLE "proposer_slashing" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "proposer_slashing" ADD FOREIGN KEY ("signed_header_1") REFERENCES "signed_beacon_block_header" ("signature");

ALTER TABLE "proposer_slashing" ADD FOREIGN KEY ("signed_header_2") REFERENCES "signed_beacon_block_header" ("signature");

ALTER TABLE "signed_beacon_block_header" ADD FOREIGN KEY ("message") REFERENCES "beacon_block_header" ("state_root");

ALTER TABLE "attester_slashings" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "attester_slashings" ADD FOREIGN KEY ("attester_slashing") REFERENCES "attester_slashing" ("block_root");

ALTER TABLE "attester_slashing" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "attestation" ADD FOREIGN KEY ("block_root") REFERENCES "attester_slashing" ("attestation_1");

ALTER TABLE "attestation" ADD FOREIGN KEY ("block_root") REFERENCES "attester_slashing" ("attestation_2");

ALTER TABLE "attestation" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "attesting_indices" ADD FOREIGN KEY ("block_root") REFERENCES "attestation" ("attesting_indices");

ALTER TABLE "attestation" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "attestation" ADD FOREIGN KEY ("beacon_block_root") REFERENCES "signed_beacon_block" ("block_root");

ALTER TABLE "attestation" ADD FOREIGN KEY ("source_root") REFERENCES "signed_beacon_block" ("block_root");

ALTER TABLE "attestation" ADD FOREIGN KEY ("target_root") REFERENCES "signed_beacon_block" ("block_root");

ALTER TABLE "attesting_indices" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "attesting_indices" ADD FOREIGN KEY ("validator") REFERENCES "validator" ("validator_index");

ALTER TABLE "attestations" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "attestations" ADD FOREIGN KEY ("data") REFERENCES "attestations_data" ("block_root");

ALTER TABLE "attestations_data" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "attestations_data" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "attestations_data" ADD FOREIGN KEY ("source_root") REFERENCES "signed_beacon_block" ("block_root");

ALTER TABLE "attestations_data" ADD FOREIGN KEY ("target_root") REFERENCES "signed_beacon_block" ("block_root");

ALTER TABLE "deposits" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "deposit" ADD FOREIGN KEY ("block_root") REFERENCES "deposits" ("deposit");

ALTER TABLE "deposit" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "deposit" ADD FOREIGN KEY ("pubkey") REFERENCES "validator" ("pubkey");

ALTER TABLE "deposit" ADD FOREIGN KEY ("withdrawal_credentials") REFERENCES "validator" ("withdrawal_credentials");

ALTER TABLE "voluntary_exits" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "voluntary_exits" ADD FOREIGN KEY ("validator_index") REFERENCES "validator" ("validator_index");

ALTER TABLE "execution_payloads" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "execution_payloads" ADD FOREIGN KEY ("transaction") REFERENCES "transactions" ("block_root");

ALTER TABLE "transactions" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("slot") REFERENCES "slots" ("slot");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("fork_epoch") REFERENCES "slots" ("epoch");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("latest_block_header") REFERENCES "beacon_block_header" ("state_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("eth1_data") REFERENCES "eth1_data" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("eth1_data_votes") REFERENCES "eth1_data_votes" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("validators") REFERENCES "validator_state" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("balances") REFERENCES "balances" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("randao_mixes") REFERENCES "randao_mixes" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("slashings") REFERENCES "slashings" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("previous_epoch_attestations") REFERENCES "pending_attestations" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("current_epoch_attestations") REFERENCES "pending_attestations" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("previous_justified_checkpoint") REFERENCES "checkpoint" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("current_justified_checkpoint") REFERENCES "checkpoint" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("finalized_checkpoint") REFERENCES "checkpoint" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("inactivity_scores_slot") REFERENCES "inactivity_scores" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("current_sync_committee_slot") REFERENCES "sync_committee" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("next_sync_committee_slot") REFERENCES "sync_committee" ("block_root");

ALTER TABLE "beacon_state" ADD FOREIGN KEY ("latest_execution_payload_header_parent_hash") REFERENCES "execution_payload_header" ("block_root");

ALTER TABLE "beacon_block_header" ADD FOREIGN KEY ("state_root") REFERENCES "slots" ("state_root");

ALTER TABLE "beacon_block_header" ADD FOREIGN KEY ("proposer_index") REFERENCES "validator" ("validator_index");

ALTER TABLE "eth1_data_votes" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "eth1_data_votes" ADD FOREIGN KEY ("eth1_data") REFERENCES "eth1_data" ("block_root");

ALTER TABLE "validator_state" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "validator_state" ADD FOREIGN KEY ("validator") REFERENCES "validator" ("validator_index");

ALTER TABLE "balances" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "randao_mixes" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "slashings" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "pending_attestations" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "pending_attestations" ADD FOREIGN KEY ("data") REFERENCES "attestations_data" ("block_root");

ALTER TABLE "pending_attestations" ADD FOREIGN KEY ("inclusion_delay") REFERENCES "slots" ("slot");

ALTER TABLE "pending_attestations" ADD FOREIGN KEY ("proposer_index") REFERENCES "validator" ("validator_index");

ALTER TABLE "checkpoint" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "checkpoint" ADD FOREIGN KEY ("epoch") REFERENCES "slots" ("epoch");

ALTER TABLE "checkpoint" ADD FOREIGN KEY ("root") REFERENCES "slots" ("block_root");

ALTER TABLE "inactivity_scores" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "sync_committee" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "sync_committee" ADD FOREIGN KEY ("pubkeys") REFERENCES "sync_committee_pubkeys" ("block_root");

ALTER TABLE "sync_committee_pubkeys" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");

ALTER TABLE "sync_committee_pubkeys" ADD FOREIGN KEY ("index") REFERENCES "pubkeys" ("pubkey");

ALTER TABLE "execution_payload_header" ADD FOREIGN KEY ("block_root") REFERENCES "slots" ("block_root");
