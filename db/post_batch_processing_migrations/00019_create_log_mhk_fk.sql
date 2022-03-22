-- +goose Up
ALTER TABLE eth.log_cids
ADD CONSTRAINT fk_log_leaf_mh_key
    FOREIGN KEY (leaf_mh_key, block_number) REFERENCES public.blocks (key, block_number)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

-- +goose Down
ALTER TABLE eth.log_cids
DROP CONSTRAINT fk_log_leaf_mh_key;
