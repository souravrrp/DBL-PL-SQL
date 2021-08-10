/* Formatted on 5/3/2021 11:47:02 AM (QP5 v5.287) */
DECLARE
   l_return_status          VARCHAR2 (1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2 (2000);
   l_batch_id               NUMBER;
   l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
   l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
   l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
   l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
   l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
   l_trx_created            NUMBER;
   l_cnt                    NUMBER;

   CURSOR cbatch
   IS
      SELECT customer_trx_id
        FROM ra_customer_trx_all
       WHERE batch_id = l_batch_id;

   CURSOR list_errors
   IS
      SELECT trx_header_id,
             trx_line_id,
             trx_salescredit_id,
             trx_dist_id,
             trx_contingency_id,
             error_message,
             invalid_value
        FROM ar_trx_errors_gt;

   CURSOR cur_stg
   IS
      SELECT *
        FROM apps.xxdbl_cer_ar_inv_upld_stg
       WHERE FLAG IS NULL AND OPERATING_UNIT = 126;
BEGIN
   FOR ln_cur_stg IN cur_stg
   LOOP
      BEGIN
         -- c. Set the applications context
         mo_global.init ('AR');
         mo_global.set_policy_context ('S', ln_cur_stg.OPERATING_UNIT);
         --fnd_global.apps_initialize (p_user_id, p_responsibility_id, p_respappl_id, 0);
         --mo_global.set_policy_context ('S', '126');
         fnd_global.apps_initialize (5958,
                                     51915,
                                     222,
                                     0);

         -- d. Populate batch source information.
         l_batch_source_rec.batch_source_id := ln_cur_stg.BATCH_SOURCE_ID;

         -- e. Populate header information for first invoice
         l_trx_header_tbl (1).trx_header_id := ra_customer_trx_s.NEXTVAL;
         l_trx_header_tbl (1).bill_to_customer_id := ln_cur_stg.CUSTOMER_ID;
         l_trx_header_tbl (1).cust_trx_type_id := ln_cur_stg.CUST_TRX_TYPE_ID;

         -- f. Populate lines information for first invoice
         l_trx_lines_tbl (1).trx_header_id := ra_customer_trx_s.CURRVAL;
         l_trx_lines_tbl (1).trx_line_id := ra_customer_trx_lines_s.NEXTVAL;
         l_trx_lines_tbl (1).line_number := 1;
         l_trx_lines_tbl (1).description :=
            NVL (ln_cur_stg.ITEM_DESCRIPTION, ln_cur_stg.LINE_DESCRIPTION);
         l_trx_lines_tbl (1).quantity_invoiced := ln_cur_stg.QUANTITY;
         l_trx_lines_tbl (1).unit_selling_price :=
            ln_cur_stg.UNIT_SELLING_PRICE;
         l_trx_lines_tbl (1).line_type := 'LINE';



         -- Populate Distribution Information
         l_trx_dist_tbl (1).trx_dist_id := RA_CUST_TRX_LINE_GL_DIST_S.NEXTVAL;
         l_trx_dist_tbl (1).trx_header_id := ra_customer_trx_s.NEXTVAL;
         l_trx_dist_tbl (1).trx_LINE_ID := ra_customer_trx_lines_s.NEXTVAL;
         l_trx_dist_tbl (1).ACCOUNT_CLASS := 'REV';
         l_trx_dist_tbl (1).AMOUNT := ln_cur_stg.AMOUNT;                --150;
         l_trx_dist_tbl (1).CODE_COMBINATION_ID := 1236; --ln_cur_stg.GL_ID_REV; --195346;



         -- k. Call the invoice api to create multiple invoices in a batch.
         AR_INVOICE_API_PUB.create_invoice (
            p_api_version            => 1.0,
            p_batch_source_rec       => l_batch_source_rec,
            p_trx_header_tbl         => l_trx_header_tbl,
            p_trx_lines_tbl          => l_trx_lines_tbl,
            p_trx_dist_tbl           => l_trx_dist_tbl,
            p_trx_salescredits_tbl   => l_trx_salescredits_tbl,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data);

         -- l. check for errors
         IF    l_return_status = fnd_api.g_ret_sts_error
            OR l_return_status = fnd_api.g_ret_sts_unexp_error
         THEN
            DBMS_OUTPUT.put_line ('FAILURE: Unexpected errors were raised!');
         ELSE
            -- m. check batch/invoices created
            SELECT DISTINCT batch_id
              INTO l_batch_id
              FROM ar_trx_header_gt;

            IF l_batch_id IS NOT NULL
            THEN
               UPDATE xxdbl_cer_ar_inv_upld_stg
                  SET FLAG = 'Y'
                WHERE SL_NO = ln_cur_stg.SL_NO;

               DBMS_OUTPUT.put_line (
                     'SUCCESS: Created batch_id = '
                  || l_batch_id
                  || ' containing the following customer_trx_id:');

               FOR c IN cBatch
               LOOP
                  DBMS_OUTPUT.put_line (' ' || c.customer_trx_id);
               END LOOP;
            END IF;
         END IF;

         -- n. Within the batch, check if some invoices raised errors
         SELECT COUNT (*) INTO l_cnt FROM ar_trx_errors_gt;

         IF l_cnt > 0
         THEN
            DBMS_OUTPUT.put_line (
               'FAILURE: Errors encountered, see list below:');

            FOR i IN list_errors
            LOOP
               DBMS_OUTPUT.put_line (
                  '----------------------------------------------------');
               DBMS_OUTPUT.put_line (
                  'Header ID = ' || TO_CHAR (i.trx_header_id));
               DBMS_OUTPUT.put_line ('Line ID = ' || TO_CHAR (i.trx_line_id));
               DBMS_OUTPUT.put_line (
                  'Sales Credit ID = ' || TO_CHAR (i.trx_salescredit_id));
               DBMS_OUTPUT.put_line ('Dist Id = ' || TO_CHAR (i.trx_dist_id));
               DBMS_OUTPUT.put_line (
                  'Contingency ID = ' || TO_CHAR (i.trx_contingency_id));
               DBMS_OUTPUT.put_line (
                  'Message = ' || SUBSTR (i.error_message, 1, 80));
               DBMS_OUTPUT.put_line (
                  'Invalid Value = ' || SUBSTR (i.invalid_value, 1, 80));
               DBMS_OUTPUT.put_line (
                  '----------------------------------------------------');
            END LOOP;
         END IF;
      END;
   END LOOP;
END;