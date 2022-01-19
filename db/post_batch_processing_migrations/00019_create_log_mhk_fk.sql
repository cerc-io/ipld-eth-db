-- +goose Up
ALTER TABLE eth.log_cids
ADD CONSTRAINT fk_log_leaf_mh_key
    FOREIGN KEY (leaf_mh_key) REFERENCES public.blocks (key)
    ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

-- +goose Down
ALTER TABLE eth.log_cids
DROP CONSTRAINT fk_log_leaf_mh_key;
