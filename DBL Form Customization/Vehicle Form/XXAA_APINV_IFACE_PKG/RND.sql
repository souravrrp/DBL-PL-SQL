/* Formatted on 3/9/2020 5:52:08 PM (QP5 v5.287) */
SET SERVEROUTPUT ON

DECLARE
   p_source                   VARCHAR2 (100) := '71755';

   CURSOR c_inv
   IS
        SELECT DISTINCT api.source,
                        api.org_id,
                        api.invoice_type,
                        api.vendor_id,
                        api.vendor_site_id,
                        api.invoice_date,
                        api.invoice_number,
                        api.line_description,
                        api.invoice_amount,
                        api.term_id,
                        api.invoice_currency,
                        api.gl_date,
                        api.payment_currency,
                        api.payment_method,
                        api.voucher_no
          FROM xxaa_apinv_iface_tbl api
         WHERE api.ERROR_CODE = 'V' AND voucher_no = p_source
      ORDER BY api.org_id,
               api.invoice_type,
               api.vendor_id,
               api.vendor_site_id,
               api.invoice_number;


   CURSOR c_lin (x_invoice_number VARCHAR2)
   IS
        SELECT apl.line_num,
               apl.line_type,
               apl.line_amount,
               apl.code_combination_id,
               apl.line_description,
               apl.maintanance_area,                                      --31
               apl.item_dtl,
               apl.vehicle_number
          FROM xxaa_apinv_iface_tbl apl
         WHERE apl.ERROR_CODE = 'V' AND apl.voucher_no = p_source
      ORDER BY apl.line_num;



   l_batch_name               VARCHAR2 (100) := TO_CHAR (SYSDATE, 'DD-MON-RR:HH24MISS');
   l_conc_request_id          NUMBER;
   l_phase                    VARCHAR2 (25);
   l_status                   VARCHAR2 (25);
   l_dev_phase                VARCHAR2 (25);
   l_dev_status               VARCHAR2 (25);
   l_message                  VARCHAR2 (25);
   l_request_status           BOOLEAN;
   l_count                    NUMBER;
   l_inv_seq                  NUMBER;
   --l_inv_seq_l                NUMBER;
   l_count_inv                NUMBER;
   l_organization_id          NUMBER;
   l_retval                   BOOLEAN;
   p_batch_error_flag         VARCHAR2 (200);
   p_invoices_fetched         NUMBER;
   p_invoices_created         NUMBER;
   p_total_invoice_amount     NUMBER;
   p_print_batch              VARCHAR2 (200);
   p_calling_sequence         VARCHAR2 (200);
   p_invoice_interface_id     NUMBER;
   p_needs_invoice_approval   VARCHAR2 (200);
   p_commit                   VARCHAR2 (200);
   l_invoice_number           VARCHAR2 (50);
   l_stat                     VARCHAR2 (200);
-- v_attribute_category       VARCHAR2 (100) := 'Vehicle Repair';    -- Fuel';
BEGIN
   DBMS_OUTPUT.put_line ('Start');
   l_count := 1;
   DBMS_OUTPUT.put_line (l_count);


   /*  SELECT COUNT (*)
       INTO l_count
       FROM xxdbl.xxaa_apinv_iface_tbl
      WHERE voucher_no = p_source;

  */



   IF l_count > 0
   THEN
      FOR h_inv IN c_inv
      LOOP
         SELECT ap_invoices_interface_s.NEXTVAL INTO l_inv_seq FROM DUAL;

         INSERT INTO ap_invoices_interface (invoice_id,
                                            source,
                                            org_id,
                                            invoice_type_lookup_code,
                                            vendor_id,
                                            vendor_site_id,
                                            invoice_date,
                                            invoice_num,
                                            description,
                                            invoice_amount,
                                            terms_id,
                                            invoice_currency_code,
                                            gl_date,
                                            payment_currency_code,
                                            payment_method_lookup_code)
              VALUES (l_inv_seq,
                      h_inv.source,
                      h_inv.org_id,
                      h_inv.invoice_type,
                      h_inv.vendor_id,
                      h_inv.vendor_site_id,
                      h_inv.invoice_date,
                      h_inv.invoice_number,
                      h_inv.line_description,
                      h_inv.invoice_amount,
                      h_inv.term_id,
                      h_inv.invoice_currency,
                      h_inv.gl_date,
                      h_inv.payment_currency,
                      h_inv.payment_method);

         DBMS_OUTPUT.put_line (h_inv.invoice_number);

         FOR l_lin IN c_lin (h_inv.invoice_number)
         LOOP
            --SELECT ap_invoices_interface_s.NEXTVAL INTO l_inv_seq_l FROM DUAL;
            --DBMS_OUTPUT.put_line (l_inv_seq_l);

            DBMS_OUTPUT.put_line (l_lin.vehicle_number);

            INSERT INTO ap_invoice_lines_interface (invoice_id,
                                                    invoice_line_id,
                                                    line_number,
                                                    line_type_lookup_code,
                                                    amount,
                                                    dist_code_combination_id,
                                                    description,
                                                    attribute_category,
                                                    attribute1,
                                                    attribute2,
                                                    attribute3)
                 VALUES (l_inv_seq,
                         ap_invoice_lines_interface_s.NEXTVAL,
                         l_lin.line_num,
                         l_lin.line_type,
                         l_lin.line_amount,
                         l_lin.code_combination_id,
                         l_lin.line_description,
                         NULL,                        -- v_attribute_category,
                         l_lin.maintanance_area,
                         l_lin.vehicle_number,
                         l_lin.item_dtl);
         /* l_conc_request_id :=
             fnd_request.submit_request (
                application   => 'SQLAP',
                program       => 'APXIIMPT',
                argument1     => h_inv.org_id,
                argument2     => 'MANUAL INVOICE ENTRY',
                argument4     => l_batch_name);
                */

         END LOOP;
      --update ap_invoices_interface
      --SET STATUS = 'REJECTED'
      --where invoice_num=h_inv.invoice_number;
      --commit;
      --       and vendor_id=h_inv.vendor_id;
      --
      END LOOP;

      --UPDATE ap_invoices_interface
        -- SET STATUS = 'REJECTED'
       --WHERE invoice_num = p_source;

      --COMMIT;


      SELECT status
        INTO l_stat
        FROM ap_invoices_interface
       WHERE invoice_num = p_source;

      DBMS_OUTPUT.put_line (l_stat);

      --DBMS_OUTPUT.put_line (p_source);

      DBMS_OUTPUT.put_line (p_total_invoice_amount);

      COMMIT;

      l_conc_request_id :=
         fnd_request.submit_request (application   => 'SQLAP',
                                     program       => 'APXIIMPT',
                                     argument1     => l_organization_id,
                                     argument2     => 'MANUAL INVOICE ENTRY',
                                     argument4     => l_batch_name);
      COMMIT;

      l_request_status :=
         fnd_concurrent.wait_for_request (l_conc_request_id,
                                          60,
                                          0,
                                          l_phase,
                                          l_status,
                                          l_dev_phase,
                                          l_dev_status,
                                          l_message);
      COMMIT;


      SELECT COUNT (invoice_num)
        INTO l_count_inv
        FROM ap_invoices_interface
       WHERE invoice_num = p_source;

      SELECT DISTINCT org_id, invoice_amount
        INTO l_organization_id, p_total_invoice_amount
        FROM xxaa_apinv_iface_tbl
       WHERE voucher_no = p_source;

      DBMS_OUTPUT.put_line (l_count_inv);
      DBMS_OUTPUT.put_line (p_total_invoice_amount);

      IF l_count_inv > 0
      THEN
         --mo_global.init ('SQLAP');
         -- mo_global.set_org_context (l_organization_id, NULL, 'SQLAP');
         l_retval :=
            ap_import_invoices_pkg.import_invoices (
               p_batch_name             => NULL,
               p_gl_date                => NULL,
               p_hold_code              => NULL,
               p_hold_reason            => NULL,
               p_commit_cycles          => NULL,
               p_source                 => 'AP_INVOICES',
               p_group_id               => NULL,
               p_conc_request_id        => NULL, --fnd_global.conc_request_id,
               p_debug_switch           => 'N',
               p_org_id                 => l_organization_id,
               p_batch_error_flag       => p_batch_error_flag,
               p_invoices_fetched       => p_invoices_fetched,
               p_invoices_created       => p_invoices_created,
               p_total_invoice_amount   => p_total_invoice_amount,
               p_print_batch            => p_print_batch,
               p_calling_sequence       => NULL --                            p_invoice_interface_id        => NULL,
                                               --                            p_needs_invoice_approval      => 'N',
                                               --                            p_commit                      => 'Y'
               );
      END IF;

      DBMS_OUTPUT.put_line (p_source);

      -------- end ----
      SELECT doc_sequence_value
        INTO l_invoice_number
        FROM ap_invoices_all
       WHERE invoice_num = p_source;

      DBMS_OUTPUT.put_line (l_invoice_number);

      IF l_invoice_number IS NOT NULL
      THEN
         UPDATE xx_vms_bill_mst
            SET voucher_number = l_invoice_number,
                bill_status = 'Invoice Created'
          WHERE VMS_BILL_ID = p_source;

         UPDATE xxaa_apinv_iface_tbl
            SET ERROR_CODE = 'P'
          WHERE voucher_no = p_source;

         COMMIT;

         DELETE FROM ap_invoice_lines_interface
               WHERE invoice_id IN (SELECT invoice_id
                                      FROM ap_invoices_interface
                                     WHERE source = 'AP_INVOICES');

         DELETE FROM ap_invoices_interface
               WHERE source = 'AP_INVOICES';

         DELETE FROM xxaa_apinv_iface_tbl
               WHERE voucher_no = p_source;

         COMMIT;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      raise_application_error (-20103, 'Error-' || SQLCODE || '-' || SQLERRM);
END;
/