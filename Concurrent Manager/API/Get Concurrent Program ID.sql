/* Formatted on 9/15/2020 10:04:39 AM (QP5 v5.287) */
DECLARE
   l_request_id   NUMBER;
   l_user_id      NUMBER;
BEGIN
   l_user_id := NVL (fnd_global.user_id, -1);
   FND_GLOBAL.apps_initialize (user_id        => l_user_id,
                               resp_id        => FND_GLOBAL.RESP_ID,
                               resp_appl_id   => FND_GLOBAL.RESP_APPL_ID);
   l_request_id := 0;
   COMMIT;
   DBMS_OUTPUT.put_line (l_request_id);
   l_request_id := fnd_global.conc_request_id;
   --l_request_id:=fnd_profile.value('conc_request_id');
   --fnd_profile.value('conc_request_id',l_request_id);
   DBMS_OUTPUT.put_line ('conc_request_id is' || l_request_id);

   IF l_request_id > 0
   THEN
      -- htp.p('Successfully submitted');
      DBMS_OUTPUT.put_line ('Successfully submitted');
   ELSE
      DBMS_OUTPUT.put_line ('Not Submitted');
   END IF;
END;