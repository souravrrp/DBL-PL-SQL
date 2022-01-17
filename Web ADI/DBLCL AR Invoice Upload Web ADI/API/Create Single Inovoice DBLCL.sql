/* Formatted on 5/3/2021 11:57:46 AM (QP5 v5.287) */
DECLARE
   p_org_id                 NUMBER := 126;
   l_error_message          VARCHAR2 (3000);
   l_error_code             VARCHAR2 (3000);

   --Matin Spinning Mills Ltd.

   -- Master Cursor
   CURSOR mcur
   IS
      SELECT DISTINCT SL_NO,
                      operating_unit,
                      TRUNC (trx_date) trx_date,
                      TRUNC (gl_date) gl_date,
                      'BDT' invoice_currency_code,
                      NVL (exchange_rate, '1') exchance_rate,
                      'DBLCL Invoice Uplaod' comments,
                      customer_id,
                      'R' customer_type,
                      cust_trx_type_id
        FROM xxdbl.xxdbl_cer_ar_inv_upld_stg stg
       WHERE flag IS NULL AND operating_unit = 126;

   CURSOR cur (p_header_id NUMBER)
   IS
      SELECT operating_unit,
             TRUNC (trx_date) trx_date,
             TRUNC (gl_date) gl_date,
             'BDT' invoice_currency_code,
             NVL (exchange_rate, 1) exchange_rate,
             'DBLCL Invoice Uplaod' comments,
             customer_id,
             item_description,
             uom_code,
             quantity,
             unit_selling_price,
             amount,
             customer_number,
             bill_to_site_id,
             ship_to_site_id,
             territory_id,
             cust_trx_type_id,
             line_description
        FROM xxdbl.xxdbl_cer_ar_inv_upld_stg stg
       WHERE flag IS NULL AND operating_unit = 126 AND sl_no = p_header_id;

   l_return_status          VARCHAR2 (1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2 (2000);
   l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
   l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
   l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
   l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
   l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
   v_batch_source_id        NUMBER;
   l_cust_trx_id            NUMBER;
   p_msg_count              NUMBER;
   p_msg_data               VARCHAR2 (2000);
   l_cnt                    NUMBER := 0;
   v_record_count           NUMBER := 1;
   v_cust_trx_type_id       NUMBER;
   v_error_msg              VARCHAR2 (4000);
   i                        NUMBER := 0;
   l_msml_ou                VARCHAR2 (240) := 'DBLCL';
   l_ctt_lookup             VARCHAR2 (100) := 'DBL_BILL_CATEGORY';
--'DBL_BILL_ENTRY_TO_TRX_TYPES';
BEGIN
   xx_com_pkg.writelog (
         CHR (10)
      || '+----------------------------Information Log---------------------------------+'
      || CHR (10));

   BEGIN
      SELECT organization_id
        INTO p_org_id
        FROM hr_all_organization_units org
       WHERE NAME = l_msml_ou;
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_com_pkg.writelog ('Unable to find OU ' || l_msml_ou);
         raise_application_error (-20001, 'Unable to find OU ' || l_msml_ou);
   END;

   mo_global.set_policy_context ('S', p_org_id);

   BEGIN
      SELECT batch_source_id
        INTO v_batch_source_id
        FROM ra_batch_sources_all
       WHERE UPPER (NAME) = UPPER ('DBLCL - Manual');
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_com_pkg.writelog (
            'Unable to find batch_source_id for DBLCL - Manual');
         raise_application_error (
            -20002,
            'Unable to find batch_source_id for DBLCL - Manual');
   END;

   FOR mrec IN mcur
   LOOP
      l_return_status := NULL;
      l_cust_trx_id := NULL;
      i := 0;
      l_batch_source_rec.batch_source_id := v_batch_source_id;
      l_trx_header_tbl (1).trx_header_id := ra_customer_trx_s.NEXTVAL;
      l_trx_header_tbl (1).interface_header_attribute1 :=
         'DBLCL-' || ra_customer_trx_s.CURRVAL;
      l_trx_header_tbl (1).trx_date := mrec.trx_date;
      l_trx_header_tbl (1).gl_date := mrec.gl_date;
      l_trx_header_tbl (1).trx_currency := mrec.invoice_currency_code;
      l_trx_header_tbl (1).exchange_rate_type :=
         CASE
            WHEN mrec.invoice_currency_code = 'BDT' THEN NULL
            ELSE 'User'
         END;
      l_trx_header_tbl (1).exchange_date :=
         CASE
            WHEN mrec.invoice_currency_code = 'BDT' THEN NULL
            ELSE mrec.trx_date
         END;
      l_trx_header_tbl (1).exchange_rate :=
         CASE
            WHEN mrec.invoice_currency_code = 'BDT' THEN NULL
            ELSE mrec.exchance_rate
         END;

      BEGIN
         SELECT CTT.CUST_TRX_TYPE_ID
           INTO l_trx_header_tbl (1).cust_trx_type_id
           FROM RA_CUST_TRX_TYPES_ALL CTT
          WHERE CTT.CUST_TRX_TYPE_ID = mrec.cust_trx_type_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Cust_Trx_Type Name info.';
            l_error_code := 'E';
      END;

      xx_com_pkg.writelog (
            'derived cust_trx_type_id = '
         || l_trx_header_tbl (1).cust_trx_type_id);
      l_trx_header_tbl (1).bill_to_customer_id := mrec.customer_id;
      l_trx_header_tbl (1).term_id := 5;
      l_trx_header_tbl (1).finance_charges := 'N';
      l_trx_header_tbl (1).status_trx := 'OP';
      l_trx_header_tbl (1).printing_option := 'PRI';
      l_trx_header_tbl (1).comments := mrec.comments;
      l_trx_header_tbl (1).org_id := mrec.operating_unit;

      FOR rec IN cur (mrec.SL_NO)
      LOOP
         i := i + 1;
         -- Lines (Main Product)
         l_trx_lines_tbl (i).trx_header_id := ra_customer_trx_s.CURRVAL;
         l_trx_lines_tbl (i).trx_line_id := ra_customer_trx_lines_s.NEXTVAL;
         l_trx_lines_tbl (i).line_number := i;
         l_trx_lines_tbl (i).description :=
            NVL (rec.item_description, rec.line_description);
         l_trx_lines_tbl (i).uom_code := rec.uom_code;
         l_trx_lines_tbl (i).quantity_invoiced := rec.quantity;
         l_trx_lines_tbl (i).unit_selling_price := rec.unit_selling_price;
         l_trx_lines_tbl (i).line_type := 'LINE';
         l_trx_lines_tbl (i).interface_line_context := 'DBL_IC_INVOICE';
         l_trx_lines_tbl (i).interface_line_attribute1 := rec.customer_number;
         l_trx_lines_tbl (i).interface_line_attribute2 := rec.trx_date;
         l_trx_lines_tbl (i).interface_line_attribute3 := rec.bill_to_site_id;
         l_trx_lines_tbl (i).interface_line_attribute4 := rec.ship_to_site_id;
         l_trx_lines_tbl (i).interface_line_attribute5 := rec.territory_id;
      END LOOP;

      ar_invoice_api_pub.create_single_invoice (
         p_api_version            => 1.0,
         x_return_status          => l_return_status,
         x_msg_count              => l_msg_count,
         x_msg_data               => l_msg_data,
         x_customer_trx_id        => l_cust_trx_id,
         p_commit                 => fnd_api.g_true,
         p_batch_source_rec       => l_batch_source_rec,
         p_trx_header_tbl         => l_trx_header_tbl,
         p_trx_lines_tbl          => l_trx_lines_tbl,
         p_trx_dist_tbl           => l_trx_dist_tbl,
         p_trx_salescredits_tbl   => l_trx_salescredits_tbl);
      v_record_count := NVL (v_record_count, 0) + 1;
      xx_com_pkg.writelog ('Msg ' || SUBSTR (p_msg_data, 1, 225));
      xx_com_pkg.writelog ('Status ' || l_return_status);
      xx_com_pkg.writelog ('Cust Trx Id ' || l_cust_trx_id);
      xx_com_pkg.writelog ('ORGANIZATION Id ' || p_org_id);
      xx_com_pkg.writelog ('Record Successes ' || v_record_count);
      v_error_msg :=
            'Message '
         || SUBSTR (l_msg_data, 1, 225)
         || '   Status '
         || l_return_status
         || '   Cust Trx Id  '
         || l_cust_trx_id;
      xx_com_pkg.writelog (CHR (10) || v_error_msg);

      IF l_return_status = 'S' AND l_cust_trx_id IS NOT NULL
      THEN
         UPDATE xxdbl_cer_ar_inv_upld_stg
            SET FLAG = 'Y'
          WHERE SL_NO = mrec.SL_NO;

         COMMIT;
      END IF;

      IF    l_return_status = fnd_api.g_ret_sts_error
         OR l_return_status = fnd_api.g_ret_sts_unexp_error
      THEN
         xx_com_pkg.writelog ('unexpected errors found!');
      ELSE
         SELECT COUNT (*) INTO l_cnt FROM ar_trx_errors_gt;

         IF l_cnt = 0
         THEN
            xx_com_pkg.writelog ('Customer Trx id ' || l_cust_trx_id);
         ELSE
            xx_com_pkg.writelog (
                  'Transaction not Created, Please check ar_trx_errors_gt table '
               || mrec.customer_id);
         END IF;
      END IF;
   END LOOP;
END;