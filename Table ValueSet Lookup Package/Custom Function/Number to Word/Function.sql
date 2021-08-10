/* Formatted on 11/9/2020 10:52:37 AM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION XXDBL_NUMBER_CONVERSION (NUM NUMBER)
   RETURN VARCHAR2
IS
   A       VARCHAR2 (1000);
   B       VARCHAR2 (20);
   X       NUMBER;
   Y       NUMBER := 1;
   Z       NUMBER;
   LSIGN   NUMBER;
   NO      NUMBER;
BEGIN
   X := INSTR (NUM, '.');
   LSIGN := SIGN (NUM);
   NO := ABS (NUM);

   IF X = 0
   THEN
      SELECT TO_CHAR (TO_DATE (NO, 'J'), 'JSP') INTO A FROM DUAL;
   ELSE
      SELECT TO_CHAR (
                TO_DATE (
                   SUBSTR (NO, 1, NVL (INSTR (NO, '.') - 1, LENGTH (NO))),
                   'J'),
                'JSP')
        INTO A
        FROM DUAL;

      SELECT LENGTH (SUBSTR (NO, INSTR (NO, '.') + 1)) INTO Z FROM DUAL;

      A := A || ' POINT ';

      WHILE Y < Z + 1
      LOOP
         SELECT TO_CHAR (
                   TO_DATE (SUBSTR (NO, (INSTR (NO, '.') + Y), 1), 'J'),
                   'JSP')
           INTO B
           FROM DUAL;

         A := A || B || ' ';
         y := y + 1;
      END LOOP;
   END IF;

   IF LSIGN = -1
   THEN
      RETURN 'NEGATIVE ' || A;
   ELSE
      RETURN A;
   END IF;
END;
/

SHOW ERRORS;