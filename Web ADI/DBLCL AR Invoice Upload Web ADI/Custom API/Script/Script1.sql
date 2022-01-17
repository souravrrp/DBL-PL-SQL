/* Formatted on 4/20/2021 12:27:11 PM (QP5 v5.287) */
DECLARE
   l_return_status          VARCHAR2 (1);
   p_count                  NUMBER;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2 (2000);
   l_batch_id               NUMBER;
   l_cnt                    NUMBER := 0;
   l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
   l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
   l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
   l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
   l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
   l_customer_trx_id        NUMBER;
   cnt                      NUMBER;
   v_context                VARCHAR2 (100);

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
      END IF;                                           --IF cur_user%NOTFOUND

      CLOSE cur_user;

      /* To get the responsibility and responsibility application id */
      OPEN cur_resp;

      FETCH cur_resp INTO v_resp_id, v_resp_appl_id, v_lang;

      IF cur_resp%NOTFOUND
      THEN
         v_return := 'F';
      END IF;                                           --IF cur_resp%NOTFOUND

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
      END IF;                                    --IF v_session_lang != v_lang

      RETURN v_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'F';
   END set_context;
BEGIN
   DBMS_OUTPUT.PUT_LINE ('1');

   --1. Set applications context if not already set.
   BEGIN
      v_context := set_context ('103908', 'DBLCL : AR - Manager', 126);

      IF v_context = 'F'
      THEN
         DBMS_OUTPUT.PUT_LINE ('Error while setting the context');
      END IF;

      DBMS_OUTPUT.PUT_LINE ('2');
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error in Crea_cm:' || SQLERRM);
   END;

   -- Populate header information.
   l_trx_header_tbl (1).trx_header_id := ra_customer_trx_s.NEXTVAL;
   l_trx_header_tbl (1).trx_number := 'Test_inv';
   l_trx_header_tbl (1).bill_to_customer_id := 2660;
   l_trx_header_tbl (1).cust_trx_type_id := 17162;
   --l_trx_header_tbl (1).primary_salesrep_id := -3;
   -- Populate batch source information.
   l_batch_source_rec.batch_source_id := 1009;
   -- Populate line 1 information.
   l_trx_lines_tbl (1).trx_header_id := ra_customer_trx_s.NEXTVAL;
   l_trx_lines_tbl (1).trx_line_id := ra_customer_trx_lines_s.NEXTVAL;
   l_trx_lines_tbl (1).line_number := 1;
   l_trx_lines_tbl (1).description := 'Test';
   l_trx_lines_tbl (1).quantity_invoiced := 10;
   l_trx_lines_tbl (1).unit_selling_price := 120;
   l_trx_lines_tbl (1).line_type := 'LINE';
   -- Populate Distribution Information
   l_trx_dist_tbl (1).trx_dist_id := RA_CUST_TRX_LINE_GL_DIST_S.NEXTVAL;
   l_trx_dist_tbl (1).trx_header_id := ra_customer_trx_s.NEXTVAL;
   l_trx_dist_tbl (1).trx_LINE_ID := ra_customer_trx_lines_s.NEXTVAL;
   l_trx_dist_tbl (1).ACCOUNT_CLASS := 'REV';
   l_trx_dist_tbl (1).AMOUNT := 1200;
   l_trx_dist_tbl (1).CODE_COMBINATION_ID := 195346;
   -- CAll the api
   AR_INVOICE_API_PUB.create_single_invoice (
      p_api_version            => 1.0,
      p_batch_source_rec       => l_batch_source_rec,
      p_trx_header_tbl         => l_trx_header_tbl,
      p_trx_lines_tbl          => l_trx_lines_tbl,
      p_trx_dist_tbl           => l_trx_dist_tbl,
      p_trx_salescredits_tbl   => l_trx_salescredits_tbl,
      x_customer_trx_id        => l_customer_trx_id,
      x_return_status          => l_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data);

   DBMS_OUTPUT.PUT_LINE ('l_return_status : ' || l_return_status);

   IF l_return_status = 'S'
   THEN
      DBMS_OUTPUT.put_line ('unexpected errors found!');

      IF l_msg_count = 1
      THEN
         DBMS_OUTPUT.put_line ('l_msg_data ' || l_msg_data);
      ELSIF l_msg_count > 1
      THEN
         LOOP
            p_count := p_count + 1;
            l_msg_data :=
               FND_MSG_PUB.Get (FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);

            IF l_msg_data IS NULL
            THEN
               EXIT;
            END IF;

            DBMS_OUTPUT.put_line ('Message' || p_count || '.' || l_msg_data);
         END LOOP;
      END IF;
   ELSE
      DBMS_OUTPUT.put_line (
         ' Got Created Sucessfully : ' || l_customer_trx_id);
   END IF;
END;