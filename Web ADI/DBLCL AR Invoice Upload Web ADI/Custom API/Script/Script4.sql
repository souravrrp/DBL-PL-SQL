/* Formatted on 4/20/2021 1:11:55 PM (QP5 v5.287) */
DECLARE
   l_return_status          VARCHAR2 (1);
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
BEGIN
   --c.SET the applications context
   mo_global.init ('AR');
   mo_global.set_policy_context ('S', '126');
   fnd_global.apps_initialize (5958,
                               51456,
                               222,
                               0);
   --d.Populate batch source information.
   l_batch_source_rec.batch_source_id := 1009;
   --e.Populate header information.
   l_trx_header_tbl (1).trx_header_id := 101;
   l_trx_header_tbl (1).bill_to_customer_id := 2660;
   l_trx_header_tbl (1).cust_trx_type_id := 1;
   --f.Populate line 1 information.
   l_trx_lines_tbl (1).trx_header_id := 101;
   l_trx_lines_tbl (1).trx_line_id := 401;
   l_trx_lines_tbl (1).line_number := 1;
   l_trx_lines_tbl (1).description := 'Product Description 1';
   l_trx_lines_tbl (1).quantity_invoiced := 10;
   l_trx_lines_tbl (1).unit_selling_price := 12;
   l_trx_lines_tbl (1).line_type := 'LINE';
   --g.Populate line 2 information.
   l_trx_lines_tbl (2).trx_header_id := 101;
   l_trx_lines_tbl (2).trx_line_id := 402;
   l_trx_lines_tbl (2).line_number := 2;
   l_trx_lines_tbl (2).description := 'Product Description 2';
   l_trx_lines_tbl (2).quantity_invoiced := 12;
   l_trx_lines_tbl (2).unit_selling_price := 15;
   l_trx_lines_tbl (2).line_type := 'LINE';
   --h.Populate freight information and link it to line 1.
   l_trx_lines_tbl (3).trx_header_id := 101;
   l_trx_lines_tbl (3).trx_line_id := 403;
   l_trx_lines_tbl (3).link_to_trx_line_id := 401;
   l_trx_lines_tbl (3).line_number := 3;
   l_trx_lines_tbl (3).line_type := 'FREIGHT';
   l_trx_lines_tbl (3).amount := 25;
   --i.Call the invoice api to create the invoice
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

   --j.Check for errors
   IF    l_return_status = fnd_api.g_ret_sts_error
      OR l_return_status = fnd_api.g_ret_sts_unexp_error
   THEN
      DBMS_OUTPUT.put_line ('unexpected errors found!');
   ELSE
      SELECT COUNT (*) INTO l_cnt FROM ar_trx_errors_gt;

      IF l_cnt = 0
      THEN
         DBMS_OUTPUT.put_line (
            'SUCCESS: Created customer_trx_id = ' || l_customer_trx_id);
      ELSE
         --k.List errors
         DBMS_OUTPUT.put_line (
            'FAILURE: Errors encountered, see list below:');

         FOR i IN list_errors
         LOOP
            DBMS_OUTPUT.put_line ('');
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
            DBMS_OUTPUT.put_line ('');
         END LOOP;
      END IF;
   END IF;
END;