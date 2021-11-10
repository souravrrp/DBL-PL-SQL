/* Formatted on 11/9/2021 10:54:36 AM (QP5 v5.365) */
DECLARE
    v_output   VARCHAR2 (500) := 'My name is Sourav Paul';
    v_result   VARCHAR2 (500) := v_output;
BEGIN
    fnd_file.put_line (fnd_file.LOG, 'Error ' || v_result);
    --fnd_file.put_line (fnd_file.LOG, 'Error ' || SUBSTR (SQLERRM, 1, 200));
    DBMS_OUTPUT.put_line (v_result);
END;