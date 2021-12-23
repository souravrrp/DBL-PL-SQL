/* Formatted on 12/19/2021 1:41:12 PM (QP5 v5.374) */
    SELECT REGEXP_SUBSTR (str,
                          '[^,]+',
                          1,
                          LEVEL)    val
      FROM (SELECT 'a,b,c,d' str FROM DUAL)
CONNECT BY LEVEL <= LENGTH (str) - LENGTH (REPLACE (str, ',')) + 1;



 --TRANSACTION_TYPE_ID NOT IN (80, 98, 99, 120, 52, 26, 64)

SELECT REGEXP_REPLACE ((80,
                        98,
                        99,
                        120,
                        52,
                        26,
                        64),
                       '(.)',
                       '\1 ')    "REGEXP_REPLACE"
  FROM DUAL;

    SELECT REGEXP_SUBSTR (str,
                          '[^,]+',
                          1,
                          LEVEL)    val
      FROM (SELECT '80,98,99,120,52,26,64' str FROM DUAL)
CONNECT BY LEVEL <= LENGTH (str) - LENGTH (REPLACE (str, ',')) + 1;

    SELECT REGEXP_SUBSTR ('80,98,99,120,52,26,64',
                          '[^,]+',
                          1,
                          LEVEL)    COLMN
      FROM DUAL
CONNECT BY REGEXP_SUBSTR ('80,98,99,120,52,26,64',
                          '[^,]+',
                          1,
                          LEVEL)
               IS NOT NULL;

SELECT *
  FROM emp
 WHERE ename IN (    SELECT REGEXP_SUBSTR ('SMITH,ALLEN,WARD,JONES',
                                           '[^,]+',
                                           1,
                                           LEVEL)
                       FROM DUAL
                 CONNECT BY REGEXP_SUBSTR ('SMITH,ALLEN,WARD,JONES',
                                           '[^,]+',
                                           1,
                                           LEVEL)
                                IS NOT NULL);


SELECT REGEXP_SUBSTR ('TechOnTheNet',
                      'a|e|i|o|u',
                      1,
                      3,
                      'i')
  FROM DUAL;