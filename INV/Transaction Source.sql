/* Formatted on 5/5/2021 10:12:32 AM (QP5 v5.354) */
  SELECT c.lookup_type,
         a.transaction_type_id,
         a.transaction_type_name,
         a.transaction_source_type_id,
         b.transaction_source_type_name,
         a.transaction_action_id,
         c.meaning
    FROM mtl_transaction_types a, mtl_txn_source_types b, mfg_lookups c
   WHERE     a.transaction_source_type_id = b.transaction_source_type_id
         AND a.transaction_action_id = c.lookup_code
         --AND transaction_type_id < 1000
         AND c.lookup_type = 'MTL_TRANSACTION_ACTION'
ORDER BY transaction_type_id;