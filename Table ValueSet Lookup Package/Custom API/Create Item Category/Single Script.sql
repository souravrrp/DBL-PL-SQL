/* Formatted on 9/15/2020 6:04:05 PM (QP5 v5.287) */
SET SERVEROUTPUT ON;

DECLARE
   v_return_status   VARCHAR2 (1) := NULL;
   v_msg_count       NUMBER := 0;
   v_msg_data        VARCHAR2 (2000);
   v_errorcode       VARCHAR2 (1000);
   v_category_rec    INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE;
   v_category_id     NUMBER;

   v_context         VARCHAR2 (2);

   FUNCTION set_context (i_user_name   IN VARCHAR2,
                         i_resp_name   IN VARCHAR2,
                         i_org_id      IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      NULL;
   -- Inorder to reduce the content of the post I moved the implementation part of this function to another post and it is available here
   END set_context;
BEGIN
   -- Setting the context ----

   v_context := set_context ('&user', '&responsibility', 2038);

   IF v_context = 'F'
   THEN
      DBMS_OUTPUT.put_line ('Error while setting the context');
   END IF;

   --- context done ------------

   v_category_rec := NULL;
   v_category_rec.structure_id := 50415;
   v_category_rec.summary_flag := 'N';
   v_category_rec.enabled_flag := 'Y';
   v_category_rec.segment1 := 'ENGINEERING';
   v_category_rec.segment2 := 'BAG';
   v_category_rec.segment3 := 'DEFAULT';

   -- Calling the api to create category --

   INV_ITEM_CATEGORY_PUB.CREATE_CATEGORY (
      p_api_version     => 1.0,
      p_init_msg_list   => fnd_api.g_true,
      p_commit          => fnd_api.g_false,
      x_return_status   => v_return_status,
      x_errorcode       => v_errorcode,
      x_msg_count       => v_msg_count,
      x_msg_data        => v_msg_data,
      p_category_rec    => v_category_rec,
      x_category_id     => v_category_id                 --returns category id
                                        );

   IF v_return_status = fnd_api.g_ret_sts_success
   THEN
      COMMIT;
      DBMS_OUTPUT.put_line (
         'Creation of Item Category is Successful : ' || v_CATEGORY_ID);
   ELSE
      DBMS_OUTPUT.put_line (
         'Creation of Item Category Failed with the error :' || v_ERRORCODE);
      ROLLBACK;

      FOR i IN 1 .. v_msg_count
      LOOP
         v_msg_data := oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
         DBMS_OUTPUT.put_line (i || ') ' || v_msg_data);
      END LOOP;
   END IF;
END;