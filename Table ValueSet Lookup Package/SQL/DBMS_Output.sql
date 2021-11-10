/* Formatted on 11/9/2021 10:36:24 AM (QP5 v5.365) */
DECLARE
    v_output   VARCHAR2 (500) := 'My name is Sourav Paul';
    v_result   VARCHAR2 (500) := v_output;
BEGIN
    DBMS_OUTPUT.put_line (v_result);
END;