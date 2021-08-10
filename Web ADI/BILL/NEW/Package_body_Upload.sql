/* Formatted on 6/18/2020 1:28:23 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.ar_bill_upload_adi_pkg
IS
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
      l_unit_selling_price   FLOAT;
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
END ar_bill_upload_adi_pkg;
/