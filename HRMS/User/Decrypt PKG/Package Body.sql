CREATE OR REPLACE PACKAGE BODY get_pwd
AS
   FUNCTION decrypt (KEY IN VARCHAR2, VALUE IN VARCHAR2)
      RETURN VARCHAR2
   AS
      LANGUAGE JAVA
      NAME 'oracle.apps.fnd.security.WebSessionManagerProc.decrypt(java.lang.String,java.lang.String) return java.lang.String';
END get_pwd;
/