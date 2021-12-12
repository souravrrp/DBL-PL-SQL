CREATE OR REPLACE FUNCTION XX_APEX.XX_APEX_CNF_JOB_NO
   RETURN VARCHAR2
IS
   l_MaxCount      NUMBER := 0;
   l_MaxGenerate   NUMBER := 0;
BEGIN
   SELECT NVL (MAX (CAST (SUBSTR (JOB_NO, 6, 20) AS NUMBER)), 0) AS MaxCount
     INTO l_MaxCount
     FROM XX_APEX.XX_APEX_CNF_JOB_MASTER;

   IF l_MaxCount = 0
   THEN
      l_MaxGenerate := 1;
   ELSE
      l_MaxGenerate := l_MaxCount + 1;
   END IF;

   RETURN 'IMP-J' || CAST (l_MaxGenerate AS VARCHAR2);
END;
/