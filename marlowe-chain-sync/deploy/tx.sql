-- Deploy chain:tx to pg
-- requires: block

BEGIN;

SET client_min_messages = 'warning';

CREATE TABLE chain.tx
  ( id BYTEA NOT NULL
  , blockId BYTEA NOT NULL
  , slotNo BIGINT NOT NULL
  , validityLowerBound BIGINT
  , validityUpperBound BIGINT
  , metadataKey1564 BYTEA
  , isValid BOOLEAN NOT NULL
  ) PARTITION BY RANGE (slotNo);

CREATE INDEX tx_slotNo ON chain.tx USING BRIN (slotNo);
CREATE INDEX tx_slotNo_blockId ON chain.tx USING BTREE (slotNo, blockId);
CREATE INDEX tx_id ON chain.tx USING BTREE (id);

CREATE TABLE chain.tx_0
PARTITION OF chain.tx
FOR VALUES FROM (-1) TO (10000000);

CREATE TABLE chain.tx_1m
PARTITION OF chain.tx
FOR VALUES FROM (10000000) TO (20000000);

CREATE TABLE chain.tx_2m
PARTITION OF chain.tx
FOR VALUES FROM (20000000) TO (30000000);

CREATE TABLE chain.tx_3m
PARTITION OF chain.tx
FOR VALUES FROM (30000000) TO (40000000);

CREATE TABLE chain.tx_4m
PARTITION OF chain.tx
FOR VALUES FROM (40000000) TO (50000000);

CREATE TABLE chain.tx_5m
PARTITION OF chain.tx
FOR VALUES FROM (50000000) TO (60000000);

CREATE TABLE chain.tx_6m
PARTITION OF chain.tx
FOR VALUES FROM (60000000) TO (70000000);

CREATE TABLE chain.tx_7m
PARTITION OF chain.tx
FOR VALUES FROM (70000000) TO (80000000);

CREATE TABLE chain.tx_8m
PARTITION OF chain.tx
FOR VALUES FROM (80000000) TO (90000000);

CREATE TABLE chain.tx_9m
PARTITION OF chain.tx
FOR VALUES FROM (90000000) TO (100000000);

CREATE TABLE chain.tx_10m
PARTITION OF chain.tx
FOR VALUES FROM (100000000) TO (110000000);

CREATE TABLE chain.txOut
  ( txId BYTEA NOT NULL
  , txIx BIGINT NOT NULL
  , slotNo BIGINT NOT NULL
  , address BYTEA NOT NULL
  , lovelace BIGINT NOT NULL
  , datumHash BYTEA
  , datumBytes BYTEA
  , isCollateral BOOLEAN NOT NULL
  ) PARTITION BY RANGE (slotNo);

CREATE INDEX txOut_slotNo ON chain.txOut USING BRIN (slotNo);
CREATE INDEX txOut_txId ON chain.txOut USING BTREE (txId);
CREATE INDEX txOut_txId_txIx ON chain.txOut USING BTREE (txId, txIx);
CREATE INDEX txOut_address ON chain.txOut USING BTREE (address);

CREATE TABLE chain.txOut_0
PARTITION OF chain.txOut
FOR VALUES FROM (-1) TO (10000000);

CREATE TABLE chain.txOut_1m
PARTITION OF chain.txOut
FOR VALUES FROM (10000000) TO (20000000);

CREATE TABLE chain.txOut_2m
PARTITION OF chain.txOut
FOR VALUES FROM (20000000) TO (30000000);

CREATE TABLE chain.txOut_3m
PARTITION OF chain.txOut
FOR VALUES FROM (30000000) TO (40000000);

CREATE TABLE chain.txOut_4m
PARTITION OF chain.txOut
FOR VALUES FROM (40000000) TO (50000000);

CREATE TABLE chain.txOut_5m
PARTITION OF chain.txOut
FOR VALUES FROM (50000000) TO (60000000);

CREATE TABLE chain.txOut_6m
PARTITION OF chain.txOut
FOR VALUES FROM (60000000) TO (70000000);

CREATE TABLE chain.txOut_7m
PARTITION OF chain.txOut
FOR VALUES FROM (70000000) TO (80000000);

CREATE TABLE chain.txOut_8m
PARTITION OF chain.txOut
FOR VALUES FROM (80000000) TO (90000000);

CREATE TABLE chain.txOut_9m
PARTITION OF chain.txOut
FOR VALUES FROM (90000000) TO (100000000);

CREATE TABLE chain.txOut_10m
PARTITION OF chain.txOut
FOR VALUES FROM (100000000) TO (110000000);

CREATE TABLE chain.txIn
  ( txOutId BYTEA NOT NULL
  , txOutIx BIGINT NOT NULL
  , txInId BYTEA NOT NULL
  , slotNo BIGINT NOT NULL
  , redeemerDatumBytes BYTEA
  , isCollateral BOOLEAN NOT NULL
  ) PARTITION BY RANGE (slotNo);

CREATE INDEX txIn_slotNo ON chain.txIn USING BRIN (slotNo);
CREATE INDEX txIn_txId ON chain.txIn USING BTREE (txInId);
CREATE INDEX txIn_txId_txIx ON chain.txIn USING BTREE (txOutId, txOutIx);

CREATE TABLE chain.txIn_0
PARTITION OF chain.txIn
FOR VALUES FROM (-1) TO (10000000);

CREATE TABLE chain.txIn_1m
PARTITION OF chain.txIn
FOR VALUES FROM (10000000) TO (20000000);

CREATE TABLE chain.txIn_2m
PARTITION OF chain.txIn
FOR VALUES FROM (20000000) TO (30000000);

CREATE TABLE chain.txIn_3m
PARTITION OF chain.txIn
FOR VALUES FROM (30000000) TO (40000000);

CREATE TABLE chain.txIn_4m
PARTITION OF chain.txIn
FOR VALUES FROM (40000000) TO (50000000);

CREATE TABLE chain.txIn_5m
PARTITION OF chain.txIn
FOR VALUES FROM (50000000) TO (60000000);

CREATE TABLE chain.txIn_6m
PARTITION OF chain.txIn
FOR VALUES FROM (60000000) TO (70000000);

CREATE TABLE chain.txIn_7m
PARTITION OF chain.txIn
FOR VALUES FROM (70000000) TO (80000000);

CREATE TABLE chain.txIn_8m
PARTITION OF chain.txIn
FOR VALUES FROM (80000000) TO (90000000);

CREATE TABLE chain.txIn_9m
PARTITION OF chain.txIn
FOR VALUES FROM (90000000) TO (100000000);

CREATE TABLE chain.txIn_10m
PARTITION OF chain.txIn
FOR VALUES FROM (100000000) TO (110000000);

COMMIT;
