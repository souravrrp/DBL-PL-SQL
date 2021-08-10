/* Formatted on 4/20/2021 12:28:27 PM (QP5 v5.287) */
DECLARE
   l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
   l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
   l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
   l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
   l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
   l_trx_number             NUMBER;
   l_customer_trx_id        NUMBER;
   l_trx_header_id          NUMBER;
   o_return_status          VARCHAR2 (1);
   o_msg_count              NUMBER;
   o_msg_data               VARCHAR2 (2000);
   l_err_msg                VARCHAR2 (1000);
   l_cnt                    NUMBER := 0;
   l_msg_index_out          NUMBER;
BEGIN
   /* Setting the oracle applications context for the particular session */
   fnd_global.apps_initialize (user_id        => 5958,
                               resp_id        => 51456,
                               resp_appl_id   => 222);
   /* Setting the org context for the particular session */
   mo_global.set_policy_context ('S', 126);

   BEGIN
      SELECT ra_customer_trx_s.NEXTVAL INTO l_trx_header_id FROM DUAL;
   END;

   l_trx_header_tbl (1).trx_header_id := l_trx_header_id;
   l_trx_header_tbl (1).trx_number := NULL;
   l_trx_header_tbl (1).bill_to_customer_id := 2660;
   l_trx_header_tbl (1).cust_trx_type_id := 1;
   l_trx_header_tbl (1).comments :=
      'Oraask.com - Header Test description to create new AR Invoice through API';

   l_batch_source_rec.batch_source_id := 1009;

   l_trx_lines_tbl (1).trx_header_id := l_trx_header_id;
   l_trx_lines_tbl (1).trx_line_id := ra_customer_trx_lines_s.NEXTVAL;
   l_trx_lines_tbl (1).line_number := 1;
   l_trx_lines_tbl (1).description :=
      'Oraask.com - Line Test description to create new AR Invoice through API';
   l_trx_lines_tbl (1).memo_line_id := NULL;
   l_trx_lines_tbl (1).quantity_invoiced := 10;
   l_trx_lines_tbl (1).unit_selling_price := 12;
   l_trx_lines_tbl (1).line_type := 'LINE';

   ar_invoice_api_pub.create_single_invoice (                -- std parameters
      p_api_version            => 1.0,
      p_init_msg_list          => fnd_api.g_false,
      p_commit                 => fnd_api.g_true-- api parameters
      ,
      p_batch_source_rec       => l_batch_source_rec,
      p_trx_header_tbl         => l_trx_header_tbl,
      p_trx_lines_tbl          => l_trx_lines_tbl,
      p_trx_dist_tbl           => l_trx_dist_tbl,
      p_trx_salescredits_tbl   => l_trx_salescredits_tbl-- Out parameters
      ,
      x_customer_trx_id        => l_customer_trx_id,
      x_return_status          => o_return_status,
      x_msg_count              => o_msg_count,
      x_msg_data               => o_msg_data);

   DBMS_OUTPUT.put_line ('********************************');

   IF    o_return_status = fnd_api.g_ret_sts_error
      OR o_return_status = fnd_api.g_ret_sts_unexp_error
   THEN
      DBMS_OUTPUT.put_line ('O_RETURN_STATUS = ' || o_return_status);
      DBMS_OUTPUT.put_line ('O_MSG_COUNT = ' || o_msg_count);

      IF o_msg_count > 0
      THEN
         FOR v_index IN 1 .. o_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index       => v_index,
                             p_encoded         => 'F',
                             p_data            => o_msg_data,
                             p_msg_index_out   => l_msg_index_out);
            o_msg_data := SUBSTR (o_msg_data, 1, 3950);
         END LOOP;

         DBMS_OUTPUT.put_line ('O_MSG_DATA = ' || o_msg_data);
      END IF;
   ELSE
      SELECT COUNT (*) INTO l_cnt FROM ar_trx_errors_gt;

      IF l_cnt = 0
      THEN
         BEGIN
            SELECT trx_number
              INTO l_trx_number
              FROM ra_customer_trx
             WHERE customer_trx_id = l_customer_trx_id;
         END;

         DBMS_OUTPUT.put_line ('Transaction Number: ' || l_trx_number);
         DBMS_OUTPUT.put_line ('Customer Trx id: ' || l_customer_trx_id);
         DBMS_OUTPUT.put_line ('Return Status: ' || o_return_status);
      ELSE
         DBMS_OUTPUT.put_line (
            'Transaction not Created, Please check ar_trx_errors_gt table');
      END IF;
   END IF;


   DBMS_OUTPUT.put_line ('********************************');
EXCEPTION
   WHEN OTHERS
   THEN
      l_err_msg := SUBSTR (SQLERRM, 0, 1000);
      DBMS_OUTPUT.put_line ('***************************');
      DBMS_OUTPUT.put_line (
            'There is an exception has been raised from API with error message: '
         || l_err_msg);
      DBMS_OUTPUT.put_line ('***************************');
END;