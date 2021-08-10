/* Formatted on 1/23/2021 4:50:50 PM (QP5 v5.287) */
SELECT qsl.list_header_id, qsl.name, qsl.description
  FROM qp_secu_list_headers_vl qsl
 WHERE     1 = 1
       AND EXISTS
              (SELECT 1
                 FROM APPS.RA_CUSTOMER_TRX_ALL RCTA,
                      APPS.RA_CUSTOMER_TRX_LINES_ALL RCTLA
                WHERE     1 = 1
                      AND RCTA.CUSTOMER_TRX_ID = RCTLA.CUSTOMER_TRX_ID
                      AND UPPER (REGEXP_SUBSTR (RCTLA.DESCRIPTION,
                                                '[^.]+',
                                                1,
                                                1)) LIKE
                             UPPER ('%' || qsl.name || '%')
                      AND (   :P_ORD_LINE_ID IS NULL
                           OR (RCTLA.INTERFACE_LINE_ATTRIBUTE6 =
                                  :P_ORD_LINE_ID)));



SELECT DECODE (UPPER (REGEXP_SUBSTR (RCTLA.DESCRIPTION,
                                     '[^.]+',
                                     1,
                                     1)),
               'CERAMIC DISCOUNT - SQFT WISE', 'LD',
               'SO HEADER ADHOC DISCOUNT', 'HD',
               'CSSM 2', 'CSSM',
               'Others')
          DISCOUNT_TYPE
  FROM APPS.RA_CUSTOMER_TRX_LINES_ALL RCTLA
 WHERE 1 = 1 AND CUSTOMER_TRX_LINE_ID = :P_TRX_LINE_ID;

SELECT xxdbl.xxdbl_get_mod_type_trx_ln ( :p_trx_line_id) line_type FROM DUAL;

SELECT apps.xxdbl_get_mod_type_trx_ln ( :p_trx_line_id) line_type FROM DUAL;

GRANT SELECT ON xxdbl.xxdbl_get_mod_type_trx_ln TO apps;


  SELECT *
    FROM RA_CUSTOMER_TRX_LINES_all
   WHERE     line_type IN ('LINE', 'CB', 'CHARGES')
         AND -1 = -1
         AND (CUSTOMER_TRX_ID = 866084)
         AND CUSTOMER_TRX_LINE_ID = :P_TRX_LINE_ID
         AND UPPER (DESCRIPTION) LIKE '%DIS%'
ORDER BY line_number