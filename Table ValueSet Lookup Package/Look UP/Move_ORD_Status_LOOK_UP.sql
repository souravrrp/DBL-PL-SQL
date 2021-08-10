/* Formatted on 10/5/2020 11:05:08 AM (QP5 v5.287) */
  SELECT lookup_code, SUBSTR (meaning, 1, 60) "Meaning"
    FROM mfg_lookups
   WHERE lookup_type = 'MTL_TXN_REQUEST_STATUS'
ORDER BY lookup_code