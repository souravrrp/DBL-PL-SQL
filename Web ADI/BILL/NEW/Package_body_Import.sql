/* Formatted on 6/18/2020 10:48:50 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.ar_bill_import_adi_pkg
IS
   PROCEDURE import_data_to_ar_tbl
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
             WHERE flag IS NULL;
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
   END import_data_to_ar_tbl;

END ar_bill_import_adi_pkg;
/

DROP PACKAGE BODY ar_bill_import_adi_pkg;