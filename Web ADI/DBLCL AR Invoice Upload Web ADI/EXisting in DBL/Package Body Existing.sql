PROCEDURE create_ic_ar_invoice (errbuf             OUT NOCOPY VARCHAR2,
                                   retcode            OUT NOCOPY NUMBER,
                                   --    P_ORG_ID                 IN NUMBER,
                                   p_period_name   IN            VARCHAR2)
   AS
      p_org_id                 NUMBER := 110;

      --Matin Spinning Mills Ltd.

      -- Master Cursor
      CURSOR mcur
      IS
           SELECT DISTINCT bh.org_id,
                           bh.bill_header_id invoice_id,
                           bh.bill_number,
                           TRUNC (bh.bill_date) trx_date,
                           TRUNC (bh.bill_date) gl_date,
                           bh.bill_currency invoice_currency_code,
                           NVL (bh.exchance_rate, 1) exchance_rate,
                           'Bill Invoice' attribute_category,
                           bh.bill_header_id attribute6,
                           bh.bill_header_id attribute10,
                           'Sales of Yarn' comments,
                           bh.customer_id,
                           bh.customer_type,
                           bh.bill_category
             FROM xx_ar_bills_headers_all bh,
                  xx_ar_bills_lines_all bl,
                  xx_ar_bills_line_details_all bld
            WHERE     bh.bill_header_id = bl.bill_header_id
                  AND bl.bill_line_id = bld.bill_line_id
                  AND bh.bill_status = 'CONFIRMED'
                  AND bh.org_id = p_org_id
                  AND NVL (bh.process_status, 'U') = 'U'
                  --       AND BH.BILL_NUMBER IN ('MSML/1805')
                  AND TRUNC (bh.bill_date) >= '01-JAN-2015'
                  AND TO_CHAR (bh.bill_date, 'MON-YY') = p_period_name
                  AND NOT EXISTS
                             (SELECT 1
                                FROM ra_customer_trx_all ra
                               WHERE     ra.attribute6 =
                                            TO_CHAR (bh.bill_header_id)
                                     AND ra.org_id = bh.org_id)
         ORDER BY invoice_id;

      CURSOR cur (
         p_header_id NUMBER)
      IS
           SELECT bh.org_id,
                  bh.bill_header_id invoice_id,
                  bl.bill_line_id line_id,
                  bld.bill_line_detail_id,
                  TRUNC (bh.bill_date) trx_date,
                  TRUNC (bh.bill_date) gl_date,
                  bh.bill_currency invoice_currency_code,
                  NVL (bh.exchance_rate, 1) exchance_rate,
                  'Bill Invoice' attribute_category,
                  bh.bill_header_id attribute6,
                  bh.bill_header_id attribute10,
                  'Sales of Yarn' comments,
                  bh.customer_id,
                  bld.item_description,
                  bld.uom uom_code,
                  bld.finishing_weight quantity,
                  bld.unit_selling_price,
                  bld.total_price,
                  bl.challan_number,
                  bl.challan_date,
                  bld.pi_number,
                  bld.order_number,
                  bh.bill_category
             FROM xx_ar_bills_headers_all bh,
                  xx_ar_bills_lines_all bl,
                  xx_ar_bills_line_details_all bld
            WHERE     bh.bill_header_id = bl.bill_header_id
                  AND bl.bill_line_id = bld.bill_line_id
                  AND bh.bill_status = 'CONFIRMED'
                  AND bh.bill_header_id = p_header_id
                  AND bh.org_id = p_org_id
                  AND NVL (bh.process_status, 'U') = 'U'
                  AND TRUNC (bh.bill_date) >= '01-JAN-2015'
                  AND TO_CHAR (bh.bill_date, 'MON-YY') = p_period_name
                  AND NOT EXISTS
                             (SELECT 1
                                FROM ra_customer_trx_all ra
                               WHERE     ra.attribute6 =
                                            TO_CHAR (bh.bill_header_id)
                                     AND ra.org_id = bh.org_id)
         ORDER BY trx_date,
                  invoice_id,
                  line_id,
                  bill_line_detail_id;

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
      l_msml_ou                VARCHAR2 (240) := 'MSML';
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
            raise_application_error (-20001,
                                     'Unable to find OU ' || l_msml_ou);
      END;

      --         v_error_msg := 'Ord ID ' ||P_org_id|| ' Date From ' ||V_DATE_FROM||'   Date To :'||V_DATE_TO;
      --         XX_COM_PKG.WRITELOG (CHR (10)||v_error_msg||CHR (10));

      --      fnd_global.apps_initialize (FND_PROFILE.VALUE('USER_ID'), FND_PROFILE.VALUE('RESP_ID'), 222, 0);
      mo_global.set_policy_context ('S', p_org_id);

      --          v_error_msg := 'Ord ID ' ||P_org_id|| ' User ID ' ||FND_PROFILE.VALUE('USER_ID')||'   RESP_ID :'||FND_PROFILE.VALUE('RESP_ID');
      --             XX_COM_PKG.WRITELOG (CHR (10)||v_error_msg||CHR (10));
      BEGIN
         SELECT batch_source_id
           INTO v_batch_source_id
           FROM ra_batch_sources_all
          WHERE     UPPER (NAME) = UPPER ('DBL Export Sales')
                AND org_id = p_org_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            xx_com_pkg.writelog (
               'Unable to find batch_source_id for DBL Export Sales');
            raise_application_error (
               -20002,
               'Unable to find batch_source_id for DBL Export Sales');
      END;

      FOR mrec IN mcur
      LOOP
         l_return_status := NULL;
         l_cust_trx_id := NULL;
         i := 0;
         l_batch_source_rec.batch_source_id := v_batch_source_id;
         l_trx_header_tbl (1).trx_header_id := mrec.invoice_id;
         l_trx_header_tbl (1).interface_header_attribute1 := mrec.bill_number;
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

         --ADDED BY SMNAYEEM
         /*l_trx_header_tbl (1).cust_trx_type_id :=case when (mrec.customer_type='Internal'
         AND MREC.BILL_CATEGORY='Yarn Export Melange') then 3264
          when (mrec.customer_type<>'Internal'
         AND MREC.BILL_CATEGORY='Yarn Export Melange') then 3265
           when (mrec.customer_type='Internal'
         AND MREC.BILL_CATEGORY='Yarn Export Synthatic') then 3266
           when (mrec.customer_type<>'Internal'
         AND MREC.BILL_CATEGORY='Yarn Export Synthatic') then 3267
           when (mrec.customer_type='Internal'
         AND MREC.BILL_CATEGORY not in ('Yarn Export Synthatic','Yarn Export Melange')) then 1238
         else 1237 end ; */
         -- Org ID - 94, Type Name - Yarn Sales Int. INV  1237 -- org id =94  Type Name : Yarn Sales INV
         --ADDED BY SMNAYEEM
         BEGIN
            SELECT ctt.cust_trx_type_id
              INTO l_trx_header_tbl (1).cust_trx_type_id
              FROM fnd_lookup_values_vl lv,
                   ra_cust_trx_types_all ctt,
                   hr_operating_units ou
             WHERE     lv.lookup_type = l_ctt_lookup
                   AND lv.meaning = mrec.bill_category
                   AND lv.description = ctt.NAME
                   AND lv.tag = ou.NAME
                   AND ctt.org_id = ou.organization_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               xx_com_pkg.writelog (
                  SUBSTRB (
                        'Unable to find Trx Type for  '
                     || l_msml_ou
                     || ' and category '
                     || mrec.bill_category
                     || ' - '
                     || SQLERRM,
                     1,
                     255));
               raise_application_error (
                  -20003,
                  SUBSTRB (
                        'Unable to find Trx Type for  '
                     || l_msml_ou
                     || ' and category '
                     || mrec.bill_category
                     || ' - '
                     || SQLERRM,
                     1,
                     255));
         END;

         xx_com_pkg.writelog (
               'derived cust_trx_type_id = '
            || l_trx_header_tbl (1).cust_trx_type_id);
         --  l_trx_header_tbl (1).cust_trx_type_id :=case when mrec.customer_type='Internal' then  1238 else 1237 end ;
         l_trx_header_tbl (1).bill_to_customer_id := mrec.customer_id;
         l_trx_header_tbl (1).term_id := 5;                        --IMMEDIATE
         l_trx_header_tbl (1).finance_charges := 'N';
         l_trx_header_tbl (1).status_trx := 'OP';
         l_trx_header_tbl (1).printing_option := 'PRI';
         l_trx_header_tbl (1).comments := mrec.comments;
         l_trx_header_tbl (1).attribute_category := mrec.attribute_category;
         l_trx_header_tbl (1).attribute6 := mrec.attribute6;
         l_trx_header_tbl (1).attribute10 := mrec.attribute10;
         l_trx_header_tbl (1).org_id := mrec.org_id;

         FOR rec IN cur (mrec.invoice_id)
         LOOP
            i := i + 1;
            -- Lines (Main Product)
            l_trx_lines_tbl (i).trx_header_id := rec.invoice_id;
            l_trx_lines_tbl (i).trx_line_id := rec.bill_line_detail_id;
            l_trx_lines_tbl (i).line_number := i;
            l_trx_lines_tbl (i).description := rec.item_description;
            l_trx_lines_tbl (i).uom_code := rec.uom_code;
            l_trx_lines_tbl (i).quantity_invoiced := rec.quantity;
            l_trx_lines_tbl (i).unit_selling_price := rec.unit_selling_price;
            l_trx_lines_tbl (i).line_type := 'LINE';
            l_trx_lines_tbl (i).interface_line_context := 'DBL_IC_INVOICE';
            l_trx_lines_tbl (i).interface_line_attribute1 :=
               rec.challan_number;
            l_trx_lines_tbl (i).interface_line_attribute2 := rec.challan_date;
            l_trx_lines_tbl (i).interface_line_attribute3 := rec.pi_number;
            l_trx_lines_tbl (i).interface_line_attribute4 := rec.order_number;
            l_trx_lines_tbl (i).interface_line_attribute5 :=
               rec.bill_line_detail_id;
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
            UPDATE xx_ar_bills_headers_all
               SET process_status = 'P'
             WHERE bill_header_id = mrec.invoice_id;

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