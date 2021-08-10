CREATE OR REPLACE PACKAGE BODY APPS.xxaa_apinv_iface_pkg
IS
   PROCEDURE xxaa_apinv_iface_load_prc (p_source VARCHAR2)
   IS
      l_error_message         VARCHAR2 (3000);
      l_error_code            VARCHAR2 (2);
      l_invoice_type          VARCHAR2 (30);
      l_source                VARCHAR2 (30);
      l_term_name             VARCHAR2 (30);
      l_org_id                NUMBER;
      l_invoice_num           VARCHAR2 (60);
      l_vendor_id             NUMBER;
      l_vendor_site_id        NUMBER;
      l_term_id               NUMBER;
      l_code_combination_id   NUMBER;
      l_currency              VARCHAR2 (10);
      l_payment_method        VARCHAR2 (30);
      l_line_type             VARCHAR2 (20);
      l_count                 NUMBER;
      v_bill_amount           NUMBER;

      --
      -- v_ou               varchar2(30);
      -- v_org_id           number;
      -- v_supplier_num     varchar2(10);
      -- v_vendor_id        number;
      -- v_vendor_name      varchar2(500);
      -- v_vendor_site_id   number;
      -- v_bill_date        date;
      -- v_remarks          varchar2(200);
      -- v_invoice_amount   number;
      -- v_sl               number;
      -- v_bill_amount      number;
      -- v_dr_ccid          number;
      -- v_remarks_line     varchar2(500) ;
      --
      -- v_source           varchar2(100);


      CURSOR cur_1
      IS
         SELECT api.purch_ou,
                api.org_id,
                api.vandor_name,
                api.vendor_id,
                api.vendor_site_id,
                api.bill_date,
                api.voucher_no,
                api.remarks,
                api.maintaince_type,
                api.invoice_amount,
                apl.sl,
                  --         apl.bill_amount,
                  (NVL (apl.item_qty, 1) * NVL (apl.unit_price, 1))
                - NVL (discount_amount, 0)
                + NVL (VAT_AMNT, 0)
                   bill_amount,
                apl.item_dtl,
                apl.vehicle_number,
                apl.dr_ccid
           --         apl.remarks
           FROM xx_vms_bill_mst api, xx_vms_bill_dtl apl
          WHERE     api.VMS_BILL_ID = apl.VMS_BILL_ID
                AND ledger_name IS NOT NULL
                AND vendor_id IS NOT NULL
                AND vendor_site_id IS NOT NULL
                AND voucher_no = p_source;
   BEGIN
      l_error_message := '100';
      l_error_code := 'V';
      l_source := 'AP_INVOICES';
      l_invoice_type := 'STANDARD';
      l_term_name := 'Immediate';
      l_term_id := 10006;
      l_currency := 'BDT';
      l_payment_method := 'CHECK';
      l_line_type := 'ITEM';


      SELECT NVL (COUNT (voucher_no), 100)
        INTO l_count
        FROM xxaa_apinv_iface_tbl
       WHERE voucher_no = p_source;

      SELECT SUM (
                  (NVL (apl.item_qty, 1) * NVL (apl.unit_price, 1))
                - NVL (discount_amount, 0)
                + NVL (VAT_AMNT, 0))
        INTO v_bill_amount
        FROM xx_vms_bill_dtl apl, xx_vms_bill_mst api
       WHERE api.VMS_BILL_ID = apl.VMS_BILL_ID AND VOUCHER_NO = p_source;

      IF l_count = 0
      THEN
         FOR c_custom IN cur_1
         LOOP
            INSERT INTO xxaa_apinv_iface_tbl (source,                     --1,
                                              organization,               --2,
                                              invoice_type,               --3,
                                              supplier_name,              --4,
                                              --   supplier_num, ---5,
                                              invoice_date,               --7,
                                              invoice_number,             --8,
                                              invoice_amount,              --9
                                              term,                       --10
                                              invoice_currency,           --11
                                              gl_date,                    --12
                                              payment_currency,           --13
                                              payment_method,             --14
                                              line_num,                   --15
                                              line_type,                  --16
                                              line_amount,                --17
                                              line_description,           --18
                                              org_id,                     --19
                                              vendor_id,                  --20
                                              vendor_site_id,             --21
                                              term_id,                    --22
                                              code_combination_id,        --23
                                              last_update_date,           --24
                                              last_updated_by,            --25
                                              creation_date,              --26
                                              created_by,                 --27
                                              last_update_login,          --28
                                              status,                     --29
                                              ERROR_CODE,                 --30
                                              error_message,              --31
                                              maintanance_area,
                                              item_dtl,
                                              vehicle_number,
                                              voucher_no)
                 VALUES (l_source,                                        --1,
                         c_custom.purch_ou,                               --2,
                         l_invoice_type,                                  --3,
                         c_custom.vandor_name,                            --4,
                         --  v_supplier_num,  --5
                         c_custom.bill_date,                              --7,
                         p_source,                                        ---8
                         --c_custom.invoice_amount, --9
                         v_bill_amount,                                  ---9,
                         l_term_name,                                     --10
                         l_currency,                                      --11
                         c_custom.bill_date,                              --12
                         l_currency,                                      --13
                         l_payment_method,                                --14
                         c_custom.sl,                                     --15
                         l_line_type,                                     --16
                         c_custom.bill_amount,                            --17
                         c_custom.remarks,                                --18
                         c_custom.org_id,                                 --19
                         c_custom.vendor_id,                              --20
                         c_custom.vendor_site_id,                         --21
                         l_term_id,                                       --22
                         c_custom.dr_ccid,                                --23
                         SYSDATE,                                         --24
                         fnd_global.user_id,                              --25
                         SYSDATE,                                         --26
                         fnd_global.user_id,                              --27
                         fnd_global.login_id,                             --28
                         'NEW',                                           --29
                         l_error_code,                                    --30
                         SUBSTR (l_error_message, 2),
                         c_custom.maintaince_type,                        --31
                         c_custom.item_dtl,
                         c_custom.vehicle_number,
                         c_custom.voucher_no);

            COMMIT;
         END LOOP;
      ELSE
         NULL;
      END IF;


      IF (l_error_code = 'E')
      THEN
         raise_application_error (-20101, SUBSTR (l_error_message, 2));
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (-20101,
                                  'Error-' || SQLCODE || '-' || SQLERRM);
         COMMIT;
   END xxaa_apinv_iface_load_prc;

   --->Insert Interface table

   PROCEDURE xxaa_apinv_iface_import_prc (p_source VARCHAR2)
   IS
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
            WHERE api.ERROR_CODE = 'V'
         ORDER BY api.org_id,
                  api.invoice_type,
                  api.vendor_id,
                  api.vendor_site_id,
                  api.invoice_number;


      CURSOR c_lin (
         x_invoice_number    VARCHAR2)
      IS
           SELECT apl.line_num,
                  apl.line_type,
                  apl.line_amount,
                  apl.code_combination_id,
                  apl.line_description,
                  apl.maintanance_area,                                   --31
                  apl.item_dtl,
                  apl.vehicle_number
             FROM xxaa_apinv_iface_tbl apl
            WHERE     apl.ERROR_CODE = 'V'
                  AND apl.invoice_number = x_invoice_number
         ORDER BY apl.line_num;

      l_batch_name               VARCHAR2 (100)
                                    := TO_CHAR (SYSDATE, 'DD-MON-RR:HH24MISS');
      l_conc_request_id          NUMBER;
      l_phase                    VARCHAR2 (25);
      l_status                   VARCHAR2 (25);
      l_dev_phase                VARCHAR2 (25);
      l_dev_status               VARCHAR2 (25);
      l_message                  VARCHAR2 (25);
      l_request_status           BOOLEAN;
      l_count                    NUMBER;
      l_inv_seq                  NUMBER;
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
      v_attribute_category       VARCHAR2 (100) := 'Vehicle Repair & Fuel';
   BEGIN
      SELECT COUNT (voucher_no)
        INTO l_count
        FROM xxaa_apinv_iface_tbl
       WHERE voucher_no = p_source;

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

            FOR l_lin IN c_lin (h_inv.invoice_number)
            LOOP
               INSERT
                 INTO ap_invoice_lines_interface (invoice_id,
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
                       v_attribute_category,
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
         --       update xxaa_apinv_iface_tbl
         --       set  error_code='P'
         --       where invoice_number=h_inv.invoice_number
         --       and vendor_id=h_inv.vendor_id;
         --
         END LOOP;

         COMMIT;

         l_conc_request_id :=
            fnd_request.submit_request (
               application   => 'SQLAP',
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

         -------- end ----
         SELECT doc_sequence_value
           INTO l_invoice_number
           FROM ap_invoices_all
          WHERE invoice_num = p_source;

         IF l_invoice_number IS NOT NULL
         THEN
            UPDATE xx_vms_bill_mst
               SET voucher_number = l_invoice_number,
                   bill_status = 'Invoice Created'
             WHERE voucher_no = p_source;

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
         raise_application_error (-20103,
                                  'Error-' || SQLCODE || '-' || SQLERRM);
   END xxaa_apinv_iface_import_prc;
END xxaa_apinv_iface_pkg;
/