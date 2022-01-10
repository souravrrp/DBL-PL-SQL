/* Formatted on 9/15/2020 11:56:59 AM (QP5 v5.287) */
---——    INSERTING CHILD DEPENDENT VALUE SET VALUES ——————————-

DECLARE
   x       VARCHAR2 (200);
   v_msg   VARCHAR2 (2000);
BEGIN
   fnd_global.apps_initialize (1090, 51007, 401);


   FND_FLEX_VAL_API.create_dependent_vset_value (
      'XX_DEP_VSET',
      '10',
      '10.1',
      'Dependent Value inserted through API',
      'Y',
      SYSDATE,
      NULL,
      NULL,
      x);
   DBMS_OUTPUT.PUT_LINE (X);
EXCEPTION
   WHEN OTHERS
   THEN
      v_msg := fnd_flex_val_api.MESSAGE;
      DBMS_OUTPUT.PUT_LINE (v_msg);
END;
/