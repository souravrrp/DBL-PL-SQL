CREATE OR REPLACE TRIGGER DBL_TEST_SMS  
AFTER INSERT OR UPDATE OF FLAG ON XXDBL.XXDBL_UPDATE_RESPONSIBILITIES  
FOR EACH ROW  
--WHEN (NEW.FLAG='Y') 
--SET SERVEROUTPUT ON
--SET DEFINE OFF

DECLARE
   HTTP_REQ    UTL_HTTP.REQ;
   HTTP_RESP   UTL_HTTP.RESP;
   URL_TEXT    VARCHAR2 (32767);
   URL         VARCHAR2 (2000);

   SMS_MSG     VARCHAR2 (160)
      := 'Congratulations! Your database has been configured propoerly for sending SMS through a 3rd party SMS Gateway';
BEGIN
   DBMS_OUTPUT.ENABLE (1000000);
   --Based on your service provider, the following link format may differ from
   --What we have specified below!

   URL :=
         'https://api.mobireach.com.bd/SendTextMessage?username=jal&password=J@D9367in&to=8801701213941&sender=ODBSMS&message=Test%20Message'
      || UTL_URL.Escape (SMS_MSG, TRUE);
   --UTL_URL.Escape manages escape characters like SPACE between words in a message.



   HTTP_REQ := UTL_HTTP.BEGIN_REQUEST (URL);

   UTL_HTTP.SET_HEADER (HTTP_REQ, 'User-Agent', 'Mozilla/4.0');
   HTTP_RESP := UTL_HTTP.GET_RESPONSE (HTTP_REQ);

   -- Process Request
   LOOP
      BEGIN
         URL_TEXT := NULL;
         UTL_HTTP.READ_LINE (HTTP_RESP, URL_TEXT, TRUE);
         DBMS_OUTPUT.PUT_LINE (URL_TEXT);
      EXCEPTION
         WHEN OTHERS
         THEN
            EXIT;
      END;
   END LOOP;

   UTL_HTTP.END_RESPONSE (HTTP_RESP);
END;  
/