/* Formatted on 12/23/2020 10:10:13 AM (QP5 v5.287) */
  SELECT meaning bank_name
    FROM fnd_lookup_values_vl
   WHERE     1 = 1
         AND lookup_type LIKE 'XXDBL_OM_PI_BANK'
         AND NVL (enabled_flag, 'N') = 'Y'
         AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                        NVL (start_date_active, SYSDATE - 1))
                                 AND TRUNC (NVL (end_date_active, SYSDATE + 1))
ORDER BY 1