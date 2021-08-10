/* Formatted on 1/23/2021 4:47:21 PM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION xxdbl.xxdbl_get_mod_type_trx_ln (
   p_trx_line_id   IN NUMBER)
   RETURN VARCHAR2
IS
   l_mod_type   VARCHAR2 (10);
BEGIN
   SELECT DECODE (UPPER (REGEXP_SUBSTR (rctla.description,
                                        '[^.]+',
                                        1,
                                        1)),
                  'CERAMIC DISCOUNT - SQFT WISE', 'LD',
                  'SO HEADER ADHOC DISCOUNT', 'HD',
                  'CSSM 2', 'CSSM',
                  'Others')
     INTO l_mod_type
     FROM apps.ra_customer_trx_lines_all rctla
    WHERE 1 = 1 AND customer_trx_line_id = p_trx_line_id;

   RETURN l_mod_type;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('ERROR: ' || SQLERRM);
END;
/