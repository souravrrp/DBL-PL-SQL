/* Formatted on 1/17/2021 4:33:18 PM (QP5 v5.287) */
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
                      AND (   :P_TRX_NUMBER IS NULL
                           OR (RCTA.TRX_NUMBER = :P_TRX_NUMBER)));