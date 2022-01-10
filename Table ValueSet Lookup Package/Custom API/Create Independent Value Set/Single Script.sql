/* Formatted on 9/15/2020 11:58:52 AM (QP5 v5.287) */
DECLARE
   x       VARCHAR2 (200);
   v_msg   VARCHAR2 (2000);
BEGIN
   fnd_global.apps_initialize (1090, 51007, 401);

   FND_FLEX_VAL_API.create_independent_vset_value ('XX_IND_VSET',
                                                   '10',
                                                   'Inserted from API',
                                                   'Y',
                                                   SYSDATE,
                                                   NULL,
                                                   'N',
                                                   NULL,
                                                   NULL,
                                                   X);
   DBMS_OUTPUT.PUT_LINE (X);
EXCEPTION
   WHEN OTHERS
   THEN
      v_msg := fnd_flex_val_api.MESSAGE;
      DBMS_OUTPUT.PUT_LINE (v_msg);
END;
/

COMMIT