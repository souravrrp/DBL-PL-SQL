/* Formatted on 7/13/2020 1:17:18 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_ar_invoice_upld_adi_pkg
IS
   FUNCTION check_error_log_to_import_data
      RETURN NUMBER
   IS
   BEGIN
      DECLARE
         vl_bill_header_id_seq   NUMBER (10);
         vl_bill_line_id         NUMBER (10);
         vl_challan_number       VARCHAR (20);

         CURSOR int_trans
         IS
              SELECT DISTINCT SL_NO,
                              BILL_HEADER_ID,
                              OPERATING_UNIT,
                              ORG_ID,
                              CUSTOMER_NUMBER,
                              CUSTOMER_ID,
                              CUSTOMER_NAME,
                              CUSTOMER_TYPE,
                              BILL_CURRENCY,
                              BILL_CATEGORY,
                              BILL_DATE,
                              EXCHANCE_RATE,
                              BILL_TYPE,
                              last_updated_by,
                              last_update_login,
                              created_by,
                              status,
                              FLAG,
                              CHALLAN_QTY,
                              CHALLAN_DATE
                FROM ar_bill_upload_adi_stg
               WHERE flag IS NULL
            ORDER BY SL_NO ASC;
      BEGIN
         FOR r_int_trans IN int_trans
         LOOP
            -- Bill Header info insert

            vl_bill_header_id_seq :=
               XX_COM_PKG.GET_SEQUENCE_VALUE ('XX_AR_BILLS_HEADERS_ALL',
                                              'BILL_HEADER_ID');

            vl_challan_number :=
                  r_int_trans.OPERATING_UNIT
               || '/'
               || TRIM (LPAD (xxdbl_bill_chalan_no_s.NEXTVAL, 5, '0'));
            vl_bill_line_id :=
               xx_com_pkg.get_sequence_value ('XX_AR_BILLS_LINES_ALL',
                                              'BILL_LINE_ID');



            INSERT INTO XX_AR_BILLS_HEADERS_ALL (BILL_HEADER_ID,
                                                 OPERATING_UNIT,
                                                 ORG_ID,
                                                 CUSTOMER_NUMBER,
                                                 CUSTOMER_ID,
                                                 CUSTOMER_NAME,
                                                 CUSTOMER_TYPE,
                                                 BILL_CURRENCY,
                                                 BILL_CATEGORY,
                                                 EXCHANCE_RATE,
                                                 BILL_TYPE,
                                                 BILL_DATE,
                                                 last_update_date,
                                                 last_updated_by,
                                                 last_update_login,
                                                 created_by,
                                                 creation_date,
                                                 BILL_STATUS)
                 VALUES (vl_bill_header_id_seq,
                         r_int_trans.OPERATING_UNIT,
                         r_int_trans.ORG_ID,
                         r_int_trans.CUSTOMER_NUMBER,
                         r_int_trans.CUSTOMER_ID,
                         r_int_trans.CUSTOMER_NAME,
                         r_int_trans.CUSTOMER_TYPE,
                         r_int_trans.BILL_CURRENCY,
                         r_int_trans.BILL_CATEGORY,
                         r_int_trans.EXCHANCE_RATE,
                         r_int_trans.BILL_TYPE,
                         r_int_trans.BILL_DATE,
                         SYSDATE,
                         r_int_trans.LAST_UPDATED_BY,
                         r_int_trans.LAST_UPDATE_LOGIN,
                         r_int_trans.CREATED_BY,
                         SYSDATE,
                         r_int_trans.STATUS);

            COMMIT;

            -- Bill header info insert into stgein table

            UPDATE apps.ar_bill_upload_adi_stg
               SET BILL_HEADER_ID = vl_bill_header_id_seq
             WHERE SL_NO = r_int_trans.SL_NO AND flag IS NULL;

            COMMIT;

            -- Bill Lines info insert

            INSERT INTO XX_AR_BILLS_LINES_ALL (BILL_HEADER_ID,
                                               CHALLAN_TYPE,
                                               APPLY_FLAG,
                                               BILL_CATEGORY_NAME,
                                               last_update_date,
                                               last_updated_by,
                                               last_update_login,
                                               created_by,
                                               creation_date,
                                               BILL_LINE_ID,
                                               CHALLAN_NUMBER,
                                               CHALLAN_QTY,
                                               CHALLAN_DATE)
                 VALUES (vl_bill_header_id_seq,
                         'Move Order Issue',
                         'N',
                         r_int_trans.BILL_CATEGORY,
                         SYSDATE,
                         r_int_trans.LAST_UPDATED_BY,
                         r_int_trans.LAST_UPDATE_LOGIN,
                         r_int_trans.CREATED_BY,
                         SYSDATE,
                         vl_bill_line_id,
                         vl_challan_number,
                         r_int_trans.CHALLAN_QTY,
                         r_int_trans.CHALLAN_DATE);

            COMMIT;


            -- Bill Line info insert into stgein table
            UPDATE apps.ar_bill_upload_adi_stg
               SET BILL_LINE_ID = vl_bill_line_id,
                   CHALLAN_NUMBER = vl_challan_number
             WHERE BILL_HEADER_ID = vl_bill_header_id_seq AND FLAG IS NULL;

            COMMIT;

            BEGIN
               DECLARE
                  CURSOR int_trans_lines
                  IS
                     SELECT DISTINCT BILL_HEADER_ID,
                                     last_update_date,
                                     last_updated_by,
                                     last_update_login,
                                     created_by,
                                     creation_date,
                                     CHALLAN_NUMBER,
                                     CHALLAN_QTY,
                                     CHALLAN_DATE,
                                     BILL_CATEGORY,
                                     BILL_LINE_ID
                       FROM ar_bill_upload_adi_stg
                      WHERE     BILL_HEADER_ID = vl_bill_header_id_seq
                            AND flag IS NULL;
               BEGIN
                  -----------------------------------------------------------------------------
                  FOR r_int_trans_lines IN int_trans_lines
                  LOOP
                     -- Bill Lines info insert


                     BEGIN
                        DECLARE
                           v_bill_line_id   NUMBER (10)
                              := r_int_trans_lines.BILL_LINE_ID;

                           CURSOR int_trans_details
                           IS
                              SELECT DISTINCT BILL_LINE_ID,
                                              last_update_date,
                                              last_updated_by,
                                              last_update_login,
                                              created_by,
                                              creation_date,
                                              ITEM_CODE,
                                              FINISHING_WEIGHT,
                                              UNIT_SELLING_PRICE,
                                              ITEM_NAME,
                                              PO_NUMBER,
                                              PI_NUMBER,
                                              UOM
                                FROM ar_bill_upload_adi_stg
                               WHERE BILL_LINE_ID = v_bill_line_id;
                        BEGIN
                           -----------------------------------------------------------------------------
                           FOR r_int_trans_details IN int_trans_details
                           LOOP
                              -- Bill Lines details info insert
                              INSERT
                                INTO XX_AR_BILLS_LINE_DETAILS_ALL (
                                        BILL_LINE_ID,
                                        last_update_date,
                                        last_updated_by,
                                        last_update_login,
                                        created_by,
                                        creation_date,
                                        BILL_LINE_DETAIL_ID,
                                        ITEM_CODE,
                                        FINISHING_WEIGHT,
                                        UNIT_SELLING_PRICE,
                                        ITEM_DESCRIPTION,
                                        PO_NUMBER,
                                        PI_NUMBER,
                                        UOM)
                                 VALUES (
                                           r_int_trans_details.BILL_LINE_ID,
                                           r_int_trans_details.LAST_UPDATE_DATE,
                                           r_int_trans_details.LAST_UPDATED_BY,
                                           r_int_trans_details.LAST_UPDATE_LOGIN,
                                           r_int_trans_details.CREATED_BY,
                                           r_int_trans_details.CREATION_DATE,
                                           XX_COM_PKG.GET_SEQUENCE_VALUE (
                                              'XX_AR_BILLS_LINE_DETAILS_ALL',
                                              'BILL_LINE_DETAIL_ID'),
                                           r_int_trans_details.ITEM_CODE,
                                           r_int_trans_details.FINISHING_WEIGHT,
                                           r_int_trans_details.UNIT_SELLING_PRICE,
                                           r_int_trans_details.ITEM_NAME,
                                           r_int_trans_details.PO_NUMBER,
                                           r_int_trans_details.PI_NUMBER,
                                           r_int_trans_details.UOM);
                           END LOOP;
                        END;
                     END;

                     COMMIT;
                  END LOOP;
               END;



               COMMIT;
            END;

            UPDATE apps.ar_bill_upload_adi_stg
               SET flag = 'Y'
             WHERE SL_NO = r_int_trans.SL_NO;
         END LOOP;
      END;

      --BEGIN
      --XXDBL_MSML_CREATE_AR_INVOICE;
      --END;

      RETURN 0;
   END;

   PROCEDURE import_data_to_ar_tbl (ERRBUF    OUT VARCHAR2,
                                    RETCODE   OUT VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := check_error_log_to_import_data;

      IF L_Retcode = 0
      THEN
         RETCODE := 'Success';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
      ELSIF L_Retcode = 1
      THEN
         RETCODE := 'Warning';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
      ELSIF L_Retcode = 2
      THEN
         RETCODE := 'Error';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error := 'error while executing the procedure ' || SQLERRM;
         errbuf := l_error;
         RETCODE := 1;
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
   END import_data_to_ar_tbl;


   PROCEDURE upload_data_to_staging (P_SL_NO               NUMBER,
                                     P_OPERATING_UNIT      VARCHAR2,
                                     P_CUSTOMER_NUMBER     VARCHAR2,
                                     P_BILL_CURRENCY       VARCHAR2,
                                     P_BILL_CATEGORY       VARCHAR2,
                                     P_EXCHANCE_RATE       NUMBER,
                                     P_BILL_DATE           DATE,
                                     P_BILL_TYPE           VARCHAR2,
                                     P_CHALLAN_DATE        DATE,
                                     P_CHALLAN_QTY         NUMBER,
                                     P_ITEM_CODE           VARCHAR2,
                                     P_FINISHING_WEIGHT    NUMBER,
                                     P_PO_NUMBER           VARCHAR2,
                                     P_PI_NUMBER           VARCHAR2)
   IS
      l_error_message        VARCHAR2 (3000);
      l_error_code           VARCHAR2 (3000);
      l_organization_id      NUMBER;
      l_operating_unit       VARCHAR2 (100);
      l_customer_id          NUMBER;
      l_customer_number      NUMBER;
      L_CUSTOMER_TYPE        VARCHAR2 (10);
      l_customer_name        VARCHAR2 (500);
      l_item_description     VARCHAR2 (500);
      l_uom                  VARCHAR2 (10);
      l_po_number            VARCHAR2 (50);
      l_unit_selling_price   NUMBER;
   BEGIN
      ------------------------------------BILL HEADER-----------------------------
      ----------------------------------------
      ----------Select Org ID-----------------
      ----------------------------------------
      BEGIN
         SELECT hou.ORGANIZATION_ID, hou.NAME
           INTO l_organization_id, l_operating_unit
           FROM hr_organization_units hou
          WHERE hou.NAME = P_OPERATING_UNIT;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Operating Unit';
            l_error_code := 'E';
      END;



      ----------------------------------------
      ----------Select Customer Info------------
      ----------------------------------------

      IF P_CUSTOMER_NUMBER IS NOT NULL
      THEN
         BEGIN
            SELECT CUSTOMER_ID,
                   CUSTOMER_NUMBER,
                   CUSTOMER_NAME,
                   DECODE (CUSTOMER_TYPE,  'R', 'External',  'I', 'Internal')
              INTO l_CUSTOMER_ID,
                   l_CUSTOMER_NUMBER,
                   l_CUSTOMER_NAME,
                   L_CUSTOMER_TYPE
              FROM ar_customers ac
             WHERE CUSTOMER_NUMBER = P_CUSTOMER_NUMBER;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'Please enter correct customer number';
               l_error_code := 'E';
         END;
      END IF;



      ------------------------------------BILL LINE DETAILS-----------------------------

      ----------------------------------------
      ----------ITEM INFO------------
      ----------------------------------------

      BEGIN
         SELECT xfi.item_name, xfi.uom
           INTO l_item_description, l_uom
           FROM xxdbl_fg_items_v xfi
          WHERE     1 = 1
                AND xfi.item_code = P_ITEM_CODE
                AND l_operating_unit LIKE '%' || xfi.ORGANIZATION || '%';
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Item Code';
            l_error_code := 'E';
      END;



      ----------------------------------------
      -----------------PO Number--------------
      ----------------------------------------

      BEGIN
         SELECT NVL (pha.segment1, NULL), NVL (pla.unit_price, 1)
           INTO l_po_number, l_unit_selling_price
           FROM po_headers_all pha,
                apps.po_lines_all pla,
                po_vendors pv,
                xxdbl_company_le_mapping_v cl
          WHERE     pha.type_lookup_code IN ('BLANKET', 'STANDARD')
                AND NVL (pha.authorization_status, 'INCOMPLETE') = 'APPROVED'
                AND pha.approved_flag = 'Y'
                AND NVL (pha.cancel_flag, 'N') = 'N'
                AND pha.vendor_id = pv.vendor_id(+)
                AND cl.org_id = pha.org_id
                AND pla.po_header_id = pha.po_header_id
                AND pha.segment1 = P_PO_NUMBER
                AND EXISTS
                       (SELECT 1
                          FROM apps.mtl_system_items_vl msi
                         WHERE     msi.inventory_item_id = pla.item_id
                               AND msi.segment1 = P_ITEM_CODE)
                AND UPPER (cl.legal_entity_name) LIKE
                       RTRIM (UPPER (l_CUSTOMER_NAME), '.') || '%'
                AND EXISTS
                       (SELECT 1
                          FROM xx_dbl_po_recv_adjust x
                         WHERE x.po_no = pha.segment1);
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct PO Number and Item Code in according customer.';
            l_error_code := 'E';
      END;

      --------------------------------------------------------------------------------------------------------------
      --------Condition to show error if any of the above validation picks up a data entry error--------------------
      --------Condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------


      IF l_error_code = 'E'
      THEN
         raise_application_error (-20101, l_error_message);
      ELSIF NVL (l_error_code, 'A') <> 'E'
      THEN
         INSERT INTO apps.ar_bill_upload_adi_stg (SL_NO,
                                                  OPERATING_UNIT,
                                                  ORG_ID,
                                                  CUSTOMER_NUMBER,
                                                  CUSTOMER_ID,
                                                  CUSTOMER_NAME,
                                                  CUSTOMER_TYPE,
                                                  BILL_CURRENCY,
                                                  BILL_CATEGORY,
                                                  EXCHANCE_RATE,
                                                  BILL_TYPE,
                                                  BILL_DATE,
                                                  last_update_date,
                                                  last_updated_by,
                                                  last_update_login,
                                                  created_by,
                                                  creation_date,
                                                  CHALLAN_QTY,
                                                  CHALLAN_DATE,
                                                  FINISHING_WEIGHT,
                                                  UNIT_SELLING_PRICE,
                                                  STATUS,
                                                  ITEM_CODE,
                                                  ITEM_NAME,
                                                  PO_NUMBER,
                                                  PI_NUMBER,
                                                  UOM)
              VALUES (TRIM (P_SL_NO),
                      TRIM (P_OPERATING_UNIT),
                      TRIM (l_organization_id),
                      TRIM (P_CUSTOMER_NUMBER),
                      TRIM (l_customer_id),
                      TRIM (l_customer_name),
                      TRIM (L_CUSTOMER_TYPE),
                      TRIM (P_BILL_CURRENCY),
                      TRIM (P_BILL_CATEGORY),
                      TRIM (P_EXCHANCE_RATE),
                      TRIM (P_BILL_TYPE),
                      TRIM (P_BILL_DATE),
                      SYSDATE,
                      '5429',
                      '0',
                      '5429',
                      SYSDATE,
                      TRIM (P_CHALLAN_QTY),
                      TRIM (P_CHALLAN_DATE),
                      TRIM (P_FINISHING_WEIGHT),
                      TRIM (l_unit_selling_price),
                      'NEW',
                      TRIM (P_ITEM_CODE),
                      TRIM (l_item_description),
                      TRIM (l_po_number),
                      TRIM (P_PI_NUMBER),
                      TRIM (l_uom));
      END IF;

      COMMIT;
   --      BEGIN
   --         cust_import_data_to_interface;
   --      END;
   --
   --      COMMIT;
   END upload_data_to_staging;


   PROCEDURE XXDBL_MSML_CREATE_AR_INVOICE
   AS
      p_org_id                 NUMBER := 110;

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
                  AND TRUNC (bh.bill_date) >= '01-JAN-2015'
                  AND NOT EXISTS
                         (SELECT 1
                            FROM ra_customer_trx_all ra
                           WHERE     ra.attribute6 =
                                        TO_CHAR (bh.bill_header_id)
                                 AND ra.org_id = bh.org_id)
         ORDER BY invoice_id;

      CURSOR cur (
         p_header_id    NUMBER)
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

      mo_global.set_policy_context ('S', p_org_id);

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
         l_trx_header_tbl (1).bill_to_customer_id := mrec.customer_id;
         l_trx_header_tbl (1).term_id := 5;
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
   END XXDBL_MSML_CREATE_AR_INVOICE;
END xxdbl_ar_invoice_upld_adi_pkg;
/