CREATE OR REPLACE PROCEDURE SEND_SMS (P_Output OUT VARCHAR2)
IS
   V_message    VARCHAR2 (2000) := 'message';
   url          VARCHAR2 (2000);
   V_RECEIVER   VARCHAR2 (15) := NULL;
   Vmsg         VARCHAR2 (2000);
   Vmsg1        VARCHAR2 (2000);
   Vsts         VARCHAR2 (20);

BEGIN
   V_RECEIVER:='01701213941';---------------Sample Mobile Number
   V_RECEIVER := '88' || SUBSTR (V_RECEIVER, -11);
   V_MESSAGE := 'This is testing message.';-----------------This is sample message

   V_MESSAGE := REPLACE (V_MESSAGE, ' ', '%20');----------------Remove Space From Message


   IF V_RECEIVER IS NOT NULL AND V_RECEIVER!= 'N'   --AND V_RECEIVER=! 'N'
   THEN--------------Check Validation
    
      -------------------------------------------For HTTP -------------------------
      url :=
         UTL_HTTP.
          request (
               'http://api.mobireach.com.bd/SendTextMessage?username=jal'   --... SMS API
            || CHR (38)
            || 'password=J@D9367in'---------------------Password
            || CHR (38)
            || 'number='
            || V_RECEIVER
            || CHR (38)
            || 'sender=JAL_Info'
            || CHR (38)
            || 'type=0'
            || CHR (38)
            || 'message='
            || V_MESSAGE);

      DBMS_OUTPUT.put_line (URL);

      Vmsg := url;
   
      --SELECT LENGTH (Vmsg) INTO Vsts FROM DUAL;
      Vmsg1 := SUBSTR (Vmsg, 121, 1); 
---------------------------Checking Return Message ---------
    IF TO_CHAR (SUBSTR (URL, 1, 4)) = '1101'
      THEN
         P_Output := 'S';--------------
      ELSIF TO_CHAR (SUBSTR (URL, 1, 4)) = '1001'
      THEN
         P_Output := 'F_NO';
      ELSIF TO_CHAR (SUBSTR (URL, 1, 4)) = '1002'
      THEN
         P_Output := 'F_SN';
      ELSIF TO_CHAR (SUBSTR (URL, 1, 4)) = '1003'
      THEN
         P_Output := 'F_MS';
      ELSIF TO_CHAR (SUBSTR (URL, 1, 4)) = '1004'
      THEN
         P_Output := 'F_PRM';
      ELSIF TO_CHAR (SUBSTR (URL, 1, 4)) = '1005'
      THEN
         P_Output := 'F_UP';
      ELSIF TO_CHAR (SUBSTR (URL, 1, 4)) = '1006'
      THEN
         P_Output := 'F_BAL';
      ELSIF TO_CHAR (SUBSTR (URL, 1, 4)) = '1007'
      THEN
         P_Output := 'F_AV';
      ELSIF TO_CHAR (SUBSTR (URL, 1, 4)) = '1008'
      THEN
         P_Output := 'F_OS';
      ELSIF TO_CHAR (SUBSTR (URL, 1, 4)) = '1009'
      THEN
         P_Output := 'F_AS';
      ELSE
         P_Output := 'F_OT';
      END IF;

      P_Output := Vmsg1;
   ELSE
      RAISE_APPLICATION_ERROR (-20001, SQLERRM);
      NULL;
   END IF;
--END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      RAISE_APPLICATION_ERROR (-20001, SQLERRM);
END;
/