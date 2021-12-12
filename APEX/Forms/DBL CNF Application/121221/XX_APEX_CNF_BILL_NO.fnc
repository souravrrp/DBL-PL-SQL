CREATE OR REPLACE FUNCTION XX_APEX.XX_APEX_CNF_BILL_NO (
    p_OPERATING_UNIT   VARCHAR2)
    RETURN VARCHAR2
IS
    l_YY                   VARCHAR2 (2);
    l_MM                   VARCHAR2 (2);
    l_MNo                  VARCHAR2 (2);
    l_MaxCount             NUMBER := 0;
    l_MaxGenerate          NUMBER := 0;
    iOPERATING_UNIT_NAME   VARCHAR2 (100) := NULL;
BEGIN
    SELECT SHORT_CODE                                                   --NAME
      INTO iOPERATING_UNIT_NAME
      FROM APPS.HR_OPERATING_UNITS
     WHERE ORGANIZATION_ID = p_OPERATING_UNIT;

    SELECT TO_CHAR (SYSDATE, 'mm'), TO_CHAR (SYSDATE, 'YY')
      INTO l_MM, l_YY
      FROM DUAL;

    SELECT NVL (MAX (CAST (SUBSTR (REGEXP_SUBSTR (BILL_NO,
                                                  '[^-]+',
                                                  1,
                                                  2),
                                   3,
                                   6) AS NUMBER)),
                0)    AS MaxCount
      INTO l_MaxCount
      FROM XX_APEX.XX_APEX_CNF_JOB_MASTER
     WHERE     SUBSTR (REGEXP_SUBSTR (BILL_NO,
                                      '[^-]+',
                                      1,
                                      2),
                       1,
                       2) = l_YY
           AND REGEXP_SUBSTR (BILL_NO, '[^-]+') = iOPERATING_UNIT_NAME; --AND SUBSTR (BILL_NO, 4, 2) = l_MM;

    IF l_MaxCount = 0
    THEN
        l_MaxGenerate := 1;
    ELSE
        l_MaxGenerate := l_MaxCount + 1;
    END IF;

    RETURN    iOPERATING_UNIT_NAME
           || '-'
           || l_YY
           || SUBSTR ('0000', 0, 6 - LENGTH (l_MaxGenerate))
           || CAST (l_MaxGenerate AS VARCHAR2);
END;
/