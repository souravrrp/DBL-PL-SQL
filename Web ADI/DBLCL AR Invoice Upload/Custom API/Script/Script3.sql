-- a. Turn on DBMS_OUTPUT to display messages on screen
set serveroutput on size 1000000

-- b. Declaration section
DECLARE
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);
   l_batch_id             number;
   l_batch_source_rec     ar_invoice_api_pub.batch_source_rec_type;
   l_trx_header_tbl       ar_invoice_api_pub.trx_header_tbl_type;
   l_trx_lines_tbl        ar_invoice_api_pub.trx_line_tbl_type;
   l_trx_dist_tbl         ar_invoice_api_pub.trx_dist_tbl_type;
   l_trx_salescredits_tbl ar_invoice_api_pub.trx_salescredits_tbl_type;
   l_trx_created          number;
   l_cnt                  number;

   cursor cbatch IS
   select customer_trx_id
   from ra_customer_trx_all
   where batch_id = l_batch_id;

   cursor list_errors is
   SELECT trx_header_id, trx_line_id, trx_salescredit_id, trx_dist_id,
   trx_contingency_id, error_message, invalid_value
   FROM ar_trx_errors_gt;

BEGIN
   -- c. Set the applications context
   mo_global.init('AR');
   mo_global.set_policy_context('S','126');
   fnd_global.apps_initialize(5958, 51456, 222,0);

   -- d. Populate batch source information.
   l_batch_source_rec.batch_source_id := 1009;

   -- e. Populate header information for first invoice
   l_trx_header_tbl(1).trx_header_id := 101;
   l_trx_header_tbl(1).bill_to_customer_id := 2660;
   l_trx_header_tbl(1).cust_trx_type_id := 1;

   -- f. Populate lines information for first invoice
   l_trx_lines_tbl(1).trx_header_id := 101;
   l_trx_lines_tbl(1).trx_line_id := 401;
   l_trx_lines_tbl(1).line_number := 1;
   l_trx_lines_tbl(1).description := 'Product Description 1';
   l_trx_lines_tbl(1).quantity_invoiced := 1;
   l_trx_lines_tbl(1).unit_selling_price := 150;
   l_trx_lines_tbl(1).line_type := 'LINE';

   -- k. Call the invoice api to create multiple invoices in a batch.
   AR_INVOICE_API_PUB.create_invoice(
       p_api_version          => 1.0,
       p_batch_source_rec     => l_batch_source_rec,
       p_trx_header_tbl       => l_trx_header_tbl,
       p_trx_lines_tbl        => l_trx_lines_tbl,
       p_trx_dist_tbl         => l_trx_dist_tbl,
       p_trx_salescredits_tbl => l_trx_salescredits_tbl,
       x_return_status        => l_return_status,
       x_msg_count            => l_msg_count,
       x_msg_data             => l_msg_data);

   -- l. check for errors
   IF l_return_status = fnd_api.g_ret_sts_error OR
      l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      dbms_output.put_line('FAILURE: Unexpected errors were raised!');
   ELSE
      -- m. check batch/invoices created
      select distinct batch_id
      into l_batch_id
      from ar_trx_header_gt;

      IF l_batch_id IS NOT NULL THEN
         dbms_output.put_line('SUCCESS: Created batch_id = ' || l_batch_id || ' containing the following customer_trx_id:');

         for c in cBatch loop
             dbms_output.put_line (' ' || c.customer_trx_id );
         end loop;
      END IF;
    END IF;

    -- n. Within the batch, check if some invoices raised errors
    SELECT count(*)
    INTO l_cnt
    FROM ar_trx_errors_gt;

    IF l_cnt > 0 THEN
      dbms_output.put_line('FAILURE: Errors encountered, see list below:');
      FOR i in list_errors LOOP
         dbms_output.put_line('----------------------------------------------------');
         dbms_output.put_line('Header ID = ' || to_char(i.trx_header_id));
         dbms_output.put_line('Line ID = ' || to_char(i.trx_line_id));
         dbms_output.put_line('Sales Credit ID = ' || to_char(i.trx_salescredit_id));
         dbms_output.put_line('Dist Id = ' || to_char(i.trx_dist_id));
         dbms_output.put_line('Contingency ID = ' || to_char(i.trx_contingency_id));
         dbms_output.put_line('Message = ' || substr(i.error_message,1,80));
         dbms_output.put_line('Invalid Value = ' || substr(i.invalid_value,1,80));
         dbms_output.put_line('----------------------------------------------------');
      END LOOP;
   END IF;
END;
/