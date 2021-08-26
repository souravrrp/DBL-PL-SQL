CREATE OR REPLACE FUNCTION APPS.xxdbl_get_mod_type_trx_ln (
   p_trx_ln_desc   IN VARCHAR2)
   RETURN VARCHAR2
IS
   l_mod_type   VARCHAR2 (10);
BEGIN
   SELECT DISTINCT DECODE (UPPER (REGEXP_SUBSTR (rctla.description,
                                                 '[^.]+',
                                                 1,
                                                 1)),
                           'CERAMIC DISCOUNT - SQFT WISE', 'LD',
                           'SO HEADER ADHOC DISCOUNT', 'HD',
                           'CSSM', 'CSSM',
                           'DBL CERAMIC CORPORATE DISCOUNT','CD',
                           'Others')
     INTO l_mod_type
     FROM apps.ra_customer_trx_lines_all rctla
    WHERE     1 = 1
          AND UPPER (rctla.description) LIKE
                 UPPER ('%' || p_trx_ln_desc || '%');

 

   RETURN l_mod_type;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('ERROR: ' || SQLERRM);
END;
/
