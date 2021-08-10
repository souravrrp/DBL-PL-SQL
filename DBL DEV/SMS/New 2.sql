/* Formatted on 3/14/2020 9:26:29 AM (QP5 v5.287) */
--SET SERVEROUTPUT ON
SET DEFINE OFF


--Execute the below code to create function for creating session.

FUNCTION create_session (p_user VARCHAR2, p_pass VARCHAR2)
   RETURN VARCHAR2
IS
   HTTP_REQ       UTL_HTTP.REQ;
   HTTP_RESP      UTL_HTTP.RESP;
   URL_TEXT       VARCHAR2 (32767);                                         --
   URL            VARCHAR2 (2000)
      :=    'http://mobilecompany.com/sms/api/auth.jsp?id='
         || p_user
         || '&&password='
         || p_pass;
   v_response     VARCHAR2 (1000);
   v_session_id   VARCHAR2 (1000);
   v_data         VARCHAR2 (1000);
BEGIN
   HTTP_REQ := UTL_HTTP.BEGIN_REQUEST (URL);
   UTL_HTTP.SET_HEADER (HTTP_REQ, 'User-Agent', 'Mozilla/34.0.5');
   HTTP_RESP := UTL_HTTP.GET_RESPONSE (HTTP_REQ);

   -- Process Request
   LOOP
      BEGIN
         URL_TEXT := NULL;
         UTL_HTTP.READ_LINE (HTTP_RESP, URL_TEXT, TRUE);

         IF v_response IS NULL
         THEN
            v_response := REGEXP_SUBSTR (URL_TEXT, '<response>[^</]+');
            v_response := REGEXP_REPLACE (v_response, '<response>', '');
         END IF;

         IF v_session_id IS NULL
         THEN
            v_session_id := REGEXP_SUBSTR (URL_TEXT, '<data>[^</]+');
            v_session_id := REGEXP_REPLACE (v_session_id, '<data>', '');
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            EXIT;
      END;
   END LOOP;

   UTL_HTTP.END_RESPONSE (HTTP_RESP);

   IF v_response = 'OK'
   THEN
      RETURN (v_session_id);
   ELSE
      RETURN ('NO');
   END IF;
EXCEPTION
   WHEN UTL_HTTP.end_of_body
   THEN
      UTL_HTTP.END_RESPONSE (HTTP_RESP);
      RETURN ('NO' || SQLERRM);
   WHEN UTL_HTTP.TOO_MANY_REQUESTS
   THEN
      UTL_HTTP.END_RESPONSE (HTTP_RESP);
      RETURN ('NO' || SQLERRM);
   WHEN OTHERS
   THEN
      UTL_HTTP.END_RESPONSE (HTTP_RESP);
      RETURN ('NO' || SQLERRM);
END;
--Execute the below code to create function for creating session and Sending SMS.

FUNCTION send_sms (p_cell_no NUMBER, p_msg VARCHAR2)
   RETURN VARCHAR2
IS
   HTTP_REQ       UTL_HTTP.REQ;
   HTTP_RESP      UTL_HTTP.RESP;
   URL_TEXT       VARCHAR2 (32767);
   URL            VARCHAR2 (2000);
   v_response     VARCHAR2 (1000);
   v_session_id   VARCHAR2 (1000);
   v_data         VARCHAR2 (1000);
   MASK           VARCHAR2 (50);
BEGIN
   v_session_id := ODS.SIH_SEND_RECIEVE_SMS.create_session ('jal', 'J@D9367in');
   MASK := 'Company Name';

   IF v_session_id NOT LIKE 'NO%'
   THEN
      BEGIN
         URL :=
               'https://api.mobireach.com.bd/SendTextMessage?id='
            || v_session_id
            || '&&to='
            || p_cell_no
            || '&&text='
            || UTL_URL.Escape (p_msg, TRUE)
            || '&&mask='
            || UTL_URL.Escape (MASK, TRUE);
         HTTP_REQ := UTL_HTTP.BEGIN_REQUEST (URL);
         UTL_HTTP.SET_HEADER (HTTP_REQ, 'User-Agent', 'Mozilla/34.0.5');
         HTTP_RESP := UTL_HTTP.GET_RESPONSE (HTTP_REQ);

         -- Process Request
         LOOP
            BEGIN
               URL_TEXT := NULL;
               UTL_HTTP.READ_LINE (HTTP_RESP, URL_TEXT, TRUE);

               IF v_response IS NULL
               THEN
                  v_response := REGEXP_SUBSTR (URL_TEXT, '<response>[^</]+');
                  v_response := REGEXP_REPLACE (v_response, '<response>', '');
               END IF;

               IF v_session_id IS NULL
               THEN
                  v_session_id := REGEXP_SUBSTR (URL_TEXT, '<data>[^</]+');
                  v_session_id := REGEXP_REPLACE (v_session_id, '<data>', '');
               END IF;

               IF v_data IS NULL
               THEN
                  v_data := REGEXP_SUBSTR (URL_TEXT, '<data>[^</]+');
                  v_data := REGEXP_REPLACE (v_data, '<data>', '');
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  EXIT;
            END;
         END LOOP;

         UTL_HTTP.END_RESPONSE (HTTP_RESP);

         IF v_response = 'OK'
         THEN
            RETURN (v_response);
         ELSE
            v_data := TRIM (REGEXP_REPLACE (v_data, 'Error', ''));
            RETURN (SQLERRM);
         END IF;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.END_RESPONSE (HTTP_RESP);
            RETURN ('NO' || SQLERRM);
         WHEN UTL_HTTP.TOO_MANY_REQUESTS
         THEN
            UTL_HTTP.END_RESPONSE (HTTP_RESP);
            RETURN ('NO' || SQLERRM);
         WHEN OTHERS
         THEN
            UTL_HTTP.END_RESPONSE (HTTP_RESP);
            RETURN ('NO' || SQLERRM);
      END;
   ELSE
      RETURN ('Session not Created..');
   END IF;

   NULL;
END;
--- Test Code to send SMS

DECLARE
   -- Local variables here
   V_reply   VARCHAR2 (1000);
   msg       VARCHAR2 (250) := 'Text Message';
BEGIN
   -- Test statements here
   V_reply := send_sms (p_cell_no => 01701213941, p_msg => msg);
   DBMS_OUTPUT.put_line ('Message:   ' || V_reply);
END;