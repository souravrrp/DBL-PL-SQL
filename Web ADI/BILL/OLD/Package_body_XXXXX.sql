/* Formatted on 6/17/2020 11:33:33 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.ar_bill_upload_pkg
IS
   PROCEDURE cust_import_data_to_interface
   IS
   BEGIN
      DECLARE
         vl_bill_header_id_seq   NUMBER (10);

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
                            last_update_date,
                            last_updated_by,
                            last_update_login,
                            created_by,
                            creation_date,
                            status,
                            FLAG
              FROM ar_bill_upload_stg
             WHERE flag IS NULL;
      BEGIN
         FOR r_int_trans IN int_trans
         LOOP
            -- Bill Header info insert

            vl_bill_header_id_seq :=
               XX_COM_PKG.GET_SEQUENCE_VALUE ('XX_AR_BILLS_HEADERS_ALL',
                                              'BILL_HEADER_ID');

            --vl_bill_header_id_seq := vl_bill_header_id_seq + 1;
            --vl_bill_header_id_seq := r_int_trans.BILL_HEADER_ID;



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



            -- Bill header info insert into stgein table
            UPDATE apps.ar_bill_upload_stg
               SET BILL_HEADER_ID = vl_bill_header_id_seq
             WHERE SL_NO = r_int_trans.SL_NO AND flag IS NULL;

            COMMIT;

            --vl_bill_header_id_seq:=r_int_trans.BILL_HEADER_ID;
            --vl_bill_header_id_seq := vl_bill_header_id_seq + 1;



            BEGIN
               DECLARE
                  -- Bill Lines info insert
                  v_bill_header_id_seq   NUMBER (10) := vl_bill_header_id_seq; --
                  vl_bill_line_id        NUMBER (10)
                     := xx_com_pkg.get_sequence_value (
                           'XX_AR_BILLS_LINES_ALL',
                           'BILL_LINE_ID');

                  CURSOR int_trans_lines_seq
                  IS
                     SELECT BILL_HEADER_ID,
                            BILL_LINE_ID,
                            CHALLAN_QTY,
                            CHALLAN_DATE,
                               OPERATING_UNIT
                            || '/'
                            || TRIM (
                                  LPAD (xxdbl_bill_chalan_no_s.NEXTVAL,
                                        5,
                                        '0'))
                               CHALLAN_NUMBER
                       FROM ar_bill_upload_stg
                      WHERE     BILL_HEADER_ID = v_bill_header_id_seq
                            AND flag IS NULL --                         GROUP BY BILL_HEADER_ID,
                                            --                         BILL_LINE_ID,
                                            --                         CHALLAN_QTY,
                                            --                         CHALLAN_DATE,
                                            --                         CHALLAN_NUMBER
               ;
               BEGIN
                  -----------------------------------------------------------------------------
                  FOR r_int_trans_lines_seq IN int_trans_lines_seq
                  LOOP
                     --IF r_int_trans_lines_seq.BILL_LINE_ID IS NULL
                     --THEN
                     -- BILL_LINE_ID AND CHALLAN_NO record insert into Stagein Table


                     UPDATE apps.ar_bill_upload_stg
                        SET BILL_LINE_ID = vl_bill_line_id,
                            CHALLAN_NUMBER =
                               r_int_trans_lines_seq.CHALLAN_NUMBER
                      WHERE     BILL_HEADER_ID =
                                   r_int_trans_lines_seq.BILL_HEADER_ID
                            --AND CHALLAN_NUMBER IS NULL
                            --AND BILL_LINE_ID IS NULL
                            AND FLAG IS NULL                  --AND ROWNUM = 1
                                            ;
                  --END IF;


                  --vl_bill_line_id := vl_bill_line_id + 1;
                  END LOOP;
               END;
            END;

            BEGIN
               DECLARE
                  -- Bill Lines info insert
                  v_bill_header_id   NUMBER (10) := vl_bill_header_id_seq;  --

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
                       FROM ar_bill_upload_stg
                      WHERE     BILL_HEADER_ID = vl_bill_header_id_seq
                            AND flag IS NULL;
               BEGIN
                  -----------------------------------------------------------------------------
                  FOR r_int_trans_lines IN int_trans_lines
                  LOOP
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
                          VALUES (r_int_trans_lines.BILL_HEADER_ID,
                                  'Move Order Issue',
                                  'N',
                                  r_int_trans_lines.BILL_CATEGORY,
                                  r_int_trans_lines.LAST_UPDATE_DATE,
                                  r_int_trans_lines.LAST_UPDATED_BY,
                                  r_int_trans_lines.LAST_UPDATE_LOGIN,
                                  r_int_trans_lines.CREATED_BY,
                                  r_int_trans_lines.CREATION_DATE,
                                  r_int_trans_lines.BILL_LINE_ID,
                                  r_int_trans_lines.CHALLAN_NUMBER,
                                  r_int_trans_lines.CHALLAN_QTY,
                                  r_int_trans_lines.CHALLAN_DATE);

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
                                FROM ar_bill_upload_stg
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

            UPDATE apps.ar_bill_upload_stg
               SET flag = 'Y'
             WHERE SL_NO = r_int_trans.SL_NO;
         END LOOP;
      END;
   END cust_import_data_to_interface;


   PROCEDURE cust_upload_data_to_staging (P_SL_NO               NUMBER,
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

      ------------------------------------BILL LINE-----------------------------

      /*
      ----------------------------------------
      ----------Challan Sequence------------
      ----------------------------------------

      BEGIN
         SELECT    ou.short_code
                || '/'
                || TRIM (LPAD (xxdbl_bill_chalan_no_s.NEXTVAL, 5, '0'))
           INTO l_challan_number
           FROM hr_operating_units ou
          WHERE ou.NAME = l_operating_unit;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Operating Unit';
            l_error_code := 'E';
      END;
*/



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
         SELECT pha.segment1, pla.unit_price
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

      /*

      BEGIN
         SELECT pha.segment1
           INTO l_po_number
           FROM po_headers_all pha,
                po_vendors pv,
                xxdbl_company_le_mapping_v cl
          WHERE     pha.type_lookup_code IN ('BLANKET', 'STANDARD')
                AND NVL (pha.authorization_status, 'INCOMPLETE') = 'APPROVED'
                AND pha.approved_flag = 'Y'
                AND NVL (pha.cancel_flag, 'N') = 'N'
                AND pha.vendor_id = pv.vendor_id(+)
                AND cl.org_id = pha.org_id
                AND pha.segment1 = P_PO_NUMBER
                AND UPPER (cl.legal_entity_name) LIKE
                       RTRIM (UPPER (P_CUSTOMER_NUMBER), '.') || '%'
                AND EXISTS
                       (SELECT 1
                          FROM xx_dbl_po_recv_adjust x
                         WHERE x.po_no = pha.segment1);
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct PO Number';
            l_error_code := 'E';
      END;
      */



      --------------------------------------------------------------------------------------------------------------
      --------Condition to show error if any of the above validation picks up a data entry error--------------------
      --------Condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------


      IF l_error_code = 'E'
      THEN
         raise_application_error (-20101, l_error_message);
      ELSIF NVL (l_error_code, 'A') <> 'E'
      THEN
         INSERT INTO apps.ar_bill_upload_stg (SL_NO,
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
                      '1113',
                      '0',
                      '1113',
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
   END cust_upload_data_to_staging;
END ar_bill_upload_pkg;
/