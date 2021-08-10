/* Formatted on 6/28/2020 5:26:18 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_item_assign_uom_conv
AS
   PROCEDURE item_assign_uom_conv (um_item_code IN VARCHAR2)
   IS
      p_from_uom_code   VARCHAR2 (200);
      p_to_uom_code     VARCHAR2 (200);
      p_item_id         NUMBER;
      p_uom_rate        NUMBER;
      x_return_status   VARCHAR2 (200);
      l_msg_data        VARCHAR2 (2000);
      v_context         VARCHAR2 (100);


      FUNCTION set_context (i_user_name   IN VARCHAR2,
                            i_resp_name   IN VARCHAR2,
                            i_org_id      IN NUMBER)
         RETURN VARCHAR2
      IS
         v_user_id        NUMBER;
         v_resp_id        NUMBER;
         v_resp_appl_id   NUMBER;
         v_lang           VARCHAR2 (100);
         v_session_lang   VARCHAR2 (100) := fnd_global.current_language;
         v_return         VARCHAR2 (10) := 'T';
         v_nls_lang       VARCHAR2 (100);
         v_org_id         NUMBER := i_org_id;

         /* Cursor to get the user id information based on the input user name */
         CURSOR cur_user
         IS
            SELECT user_id
              FROM fnd_user
             WHERE user_name = i_user_name;

         /* Cursor to get the responsibility information */
         CURSOR cur_resp
         IS
            SELECT responsibility_id, application_id, language
              FROM fnd_responsibility_tl
             WHERE responsibility_name = i_resp_name;

         /* Cursor to get the nls language information for setting the language context */
         CURSOR cur_lang (p_lang_code VARCHAR2)
         IS
            SELECT nls_language
              FROM fnd_languages
             WHERE language_code = p_lang_code;
      BEGIN
         /* To get the user id details */
         OPEN cur_user;

         FETCH cur_user INTO v_user_id;

         IF cur_user%NOTFOUND
         THEN
            v_return := 'F';
         END IF;                                        --IF cur_user%NOTFOUND

         CLOSE cur_user;

         /* To get the responsibility and responsibility application id */
         OPEN cur_resp;

         FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

         IF cur_resp%NOTFOUND
         THEN
            v_return := 'F';
         END IF;                                        --IF cur_resp%NOTFOUND

         CLOSE cur_resp;

         /* Setting the oracle applications context for the particular session */
         fnd_global.apps_initialize (user_id        => v_user_id,
                                     resp_id        => v_resp_id,
                                     resp_appl_id   => v_resp_appl_id);

         /* Setting the org context for the particular session */
         mo_global.set_policy_context ('S', v_org_id);

         /* setting the nls context for the particular session */
         IF v_session_lang != v_lang
         THEN
            OPEN cur_lang (v_lang);

            FETCH cur_lang INTO v_nls_lang;

            CLOSE cur_lang;

            fnd_global.set_nls_context (v_nls_lang);
         END IF;                                 --IF v_session_lang != v_lang

         RETURN v_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 'F';
      END set_context;
   BEGIN
      --1. Set applications context if not already set.
      BEGIN
         v_context := set_context ('100277', 'Inventory', 131);

         IF v_context = 'F'
         THEN
            DBMS_OUTPUT.PUT_LINE (
               'Error while setting the context' || SQLERRM (SQLCODE));
         END IF;
      END;

      SELECT inventory_item_id
        INTO um_Inventory_Item_Id
        FROM mtl_system_items_b
       WHERE segment1 = um_item_code AND organization_id = 138;

      p_from_uom_code := 'KG'; -- Should be a Base unit for Intra-class conversion
      p_to_uom_code := 'NO';
      p_item_id := um_Inventory_Item_Id;
      p_uom_rate := '50';

      INV_CONVERT.CREATE_UOM_CONVERSION (P_FROM_UOM_CODE   => p_from_uom_code,
                                         P_TO_UOM_CODE     => p_to_uom_code,
                                         P_ITEM_ID         => p_item_id,
                                         P_UOM_RATE        => p_uom_rate,
                                         X_RETURN_STATUS   => x_return_status);

      IF x_return_status = 'S'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Got Created Sucessfully ');
      ELSIF x_return_status = 'W'
      THEN
         DBMS_OUTPUT.put_line (' Conversion Already Exists ');
      ELSIF x_return_status = 'U'
      THEN
         DBMS_OUTPUT.put_line (' Unexpected Error Occured ');
      ELSIF x_return_status = 'E'
      THEN
         LOOP
            l_msg_data :=
               FND_MSG_PUB.Get (FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);

            IF l_msg_data IS NULL
            THEN
               EXIT;
            END IF;

            DBMS_OUTPUT.PUT_LINE ('Message' || l_msg_data);
         END LOOP;
      END IF;
   END item_assign_uom_conv;
END xxdbl_item_assign_uom_conv;
/