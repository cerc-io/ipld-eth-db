# ipld-eth-db

Schemas and utils for IPLD ETH Postgres database

## Database UML

![](vulcanize_db.png)

# Updating the DB

Please utilize the following as a reference when creating a DB schema.

- VARCHAR(66) for "0x" prefixed 32 byte (64 nibble + 2 nibbles for "0x") hashes.
- BIGINTs for big ints that can't fit in INT but don't need NUMERIC's capacity.
- NUMERIC for ints that can only fit in NUMERIC.
- INTs for ints small enough to fit in them.
- BYTEA for columns that are non-hex-encoded byte strings.
- TEXT or TINYTEXT for variable length strings (hex or otherwise).
