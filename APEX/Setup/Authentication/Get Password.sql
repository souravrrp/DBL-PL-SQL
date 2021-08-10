/* Formatted on 5/18/2021 9:47:31 AM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION f_Password (p_username   IN VARCHAR2,
                                       p_password   IN VARCHAR2)
   RETURN VARCHAR2
IS
BEGIN
   RETURN DBMS_OBFUSCATION_TOOLKIT.md5 (
             input   => UTL_RAW.cast_to_raw (
                          UPPER (p_Username) || '/' || p_password));
END f_Password;
/