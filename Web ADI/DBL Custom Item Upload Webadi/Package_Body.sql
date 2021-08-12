/* Formatted on 8/12/2021 9:39:11 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY apps.xxdbl_item_upload_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 05-AUG-2020
   -- LAST UPDATE DATE :22-OCT-2020
   -- PURPOSE : EMAIL DATA UPLOAD INTO STAGING TABLE

   PROCEDURE cust_upload_data_to_staging (
      P_COGS_ACCOUNT              VARCHAR2,
      P_DISCRETE_OR_PROCESS       VARCHAR2,
      P_DUAL_SINGLE_UOM           VARCHAR2,
      P_EXPENSE_ACCOUNT           VARCHAR2,
      P_INVENTORY_ITEM_ID         NUMBER,
      P_ITEM_CATEGORY_SEGMENT1    VARCHAR2,
      P_ITEM_CATEGORY_SEGMENT2    VARCHAR2,
      P_ITEM_CATEGORY_SEGMENT3    VARCHAR2,
      P_ITEM_CATEGORY_SEGMENT4    VARCHAR2,
      P_ITEM_CODE                 VARCHAR2,
      P_ITEM_CONVERSION_FACTOR    NUMBER,
      P_ITEM_DESCRIPTION          VARCHAR2,
      P_ITEM_TYPE                 VARCHAR2,
      P_LCM_ENABLED               VARCHAR2,
      P_LEAD_TIME                 NUMBER,
      P_LEGACY_ITEM_CODE          VARCHAR2,
      P_LIST_PRICE                NUMBER,
      P_LOT_CONTROLLED            VARCHAR2,
      P_LOT_DIVISIBLE             VARCHAR2,
      P_MAX_ORDER_QTY             VARCHAR2,
      P_MIN_MAX_PLANNING          VARCHAR2,
      P_MIN_ORDER_QTY             VARCHAR2,
      P_ORGANIZATION_CODE         VARCHAR2,
      P_ORGANIZATION_ID           NUMBER,
      P_ORG_HIERARCHY             VARCHAR2,
      P_PLANNER                   VARCHAR2,
      P_PRIMARY_UOM               VARCHAR2,
      P_SAFETY_STOCK              VARCHAR2,
      P_SALES_ACCOUNT             VARCHAR2,
      P_SECONDARY_UOM             VARCHAR2,
      P_SERIAL_CONTROLLED         VARCHAR2,
      P_SHELF_LIFE                VARCHAR2,
      P_SHELF_LIFE_DAY            VARCHAR2,
      P_STATUS                    VARCHAR2,
      P_STATUS_MESSAGE            VARCHAR2,
      P_TEMPLATE                  VARCHAR2)
   IS
      l_error_message   VARCHAR2 (3000);
      l_error_code      VARCHAR2 (3000);
   BEGIN
      --------------------------------------------------------------------------------------------------------------
      --------Condition to show error if any of the above validation picks up a data entry error--------------------
      --------Condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------


      IF l_error_code = 'E'
      THEN
         raise_application_error (-20101, l_error_message);
      ELSIF NVL (l_error_code, 'A') <> 'E'
      THEN
         INSERT INTO XXDBL.XXDBL_ITEM_MASTER_CONV (COGS_ACCOUNT,
                                                   DISCRETE_OR_PROCESS,
                                                   DUAL_SINGLE_UOM,
                                                   EXPENSE_ACCOUNT,
                                                   INVENTORY_ITEM_ID,
                                                   ITEM_CATEGORY_SEGMENT1,
                                                   ITEM_CATEGORY_SEGMENT2,
                                                   ITEM_CATEGORY_SEGMENT3,
                                                   ITEM_CATEGORY_SEGMENT4,
                                                   ITEM_CODE,
                                                   ITEM_CONVERSION_FACTOR,
                                                   ITEM_DESCRIPTION,
                                                   ITEM_TYPE,
                                                   LCM_ENABLED,
                                                   LEAD_TIME,
                                                   LEGACY_ITEM_CODE,
                                                   LIST_PRICE,
                                                   LOT_CONTROLLED,
                                                   LOT_DIVISIBLE,
                                                   MAX_ORDER_QTY,
                                                   MIN_MAX_PLANNING,
                                                   MIN_ORDER_QTY,
                                                   ORGANIZATION_CODE,
                                                   ORGANIZATION_ID,
                                                   ORG_HIERARCHY,
                                                   PLANNER,
                                                   PRIMARY_UOM,
                                                   SAFETY_STOCK,
                                                   SALES_ACCOUNT,
                                                   SECONDARY_UOM,
                                                   SERIAL_CONTROLLED,
                                                   SHELF_LIFE,
                                                   SHELF_LIFE_DAY,
                                                   STATUS,
                                                   STATUS_MESSAGE   --TEMPLATE
                                                                 )
              VALUES (P_COGS_ACCOUNT,
                      P_DISCRETE_OR_PROCESS,
                      P_DUAL_SINGLE_UOM,
                      P_EXPENSE_ACCOUNT,
                      P_INVENTORY_ITEM_ID,
                      P_ITEM_CATEGORY_SEGMENT1,
                      P_ITEM_CATEGORY_SEGMENT2,
                      P_ITEM_CATEGORY_SEGMENT3,
                      P_ITEM_CATEGORY_SEGMENT4,
                      P_ITEM_CODE,
                      P_ITEM_CONVERSION_FACTOR,
                      P_ITEM_DESCRIPTION,
                      P_ITEM_TYPE,
                      P_LCM_ENABLED,
                      P_LEAD_TIME,
                      P_LEGACY_ITEM_CODE,
                      P_LIST_PRICE,
                      P_LOT_CONTROLLED,
                      P_LOT_DIVISIBLE,
                      P_MAX_ORDER_QTY,
                      P_MIN_MAX_PLANNING,
                      P_MIN_ORDER_QTY,
                      P_ORGANIZATION_CODE,
                      P_ORGANIZATION_ID,
                      P_ORG_HIERARCHY,
                      P_PLANNER,
                      P_PRIMARY_UOM,
                      P_SAFETY_STOCK,
                      P_SALES_ACCOUNT,
                      P_SECONDARY_UOM,
                      P_SERIAL_CONTROLLED,
                      P_SHELF_LIFE,
                      P_SHELF_LIFE_DAY,
                      P_STATUS,
                      P_STATUS_MESSAGE                            --P_TEMPLATE
                                      );

         ----------------------------------------------------------------------------------------------------
         -----------Insert data into MTL_SYSTEM_ITEMS_INTERFACE after loading into staging table-------------
         ----------------------------------------------------------------------------------------------------

         BEGIN
            APPS.xxdbl_item_conv_prc;
         END;
      END IF;
   END cust_upload_data_to_staging;



   /*
   PROCEDURE cust_import_data_to_interface
   IS
   BEGIN
      APPS.xxdbl_item_conv_prc;
   END cust_import_data_to_interface;
   */
   PROCEDURE assign_item_org_and_category (ERRBUF    OUT VARCHAR2,
                                           RETCODE   OUT VARCHAR2)
   IS
      L_Retcode              NUMBER;
      CONC_STATUS            BOOLEAN;
      l_error                VARCHAR2 (100);

      ln_req_id              NUMBER;
      lv_req_phase           VARCHAR2 (240);
      lv_req_status          VARCHAR2 (240);
      lv_req_dev_phase       VARCHAR2 (240);
      lv_req_dev_status      VARCHAR2 (240);
      lv_req_message         VARCHAR2 (240);
      lv_req_return_status   BOOLEAN;
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      BEGIN
         fnd_file.put_line (fnd_file.output,
                            '*** Call The Item Import Program  ***');
         FND_GLOBAL.APPS_INITIALIZE (0, 20634, 401);
         MO_GLOBAL.SET_POLICY_CONTEXT ('S', '138');
         FND_GLOBAL.SET_NLS_CONTEXT ('AMERICAN');
         MO_GLOBAL.INIT ('INV');
         ln_req_id :=
            fnd_request.submit_request (application   => 'INV',
                                        Program       => 'INCOIN',
                                        description   => NULL,
                                        start_time    => SYSDATE,
                                        sub_request   => FALSE,
                                        argument1     => 138,
                                        argument2     => 1,
                                        argument3     => 1,
                                        argument4     => 1,
                                        argument5     => 1,
                                        argument6     => vl_set_process_id,
                                        argument7     => 1);
         COMMIT;

         IF ln_req_id = 0
         THEN
            fnd_file.put_line (
               fnd_file.LOG,
               'Request Not Submitted due to "' || fnd_message.get || '".');
         ELSE
            fnd_file.put_line (
               fnd_file.LOG,
                  'The Item Import Program submitted - Request id :'
               || ln_req_id);
         END IF;

         IF ln_req_id > 0
         THEN
            LOOP
               lv_req_return_status :=
                  fnd_concurrent.wait_for_request (ln_req_id,
                                                   60,
                                                   0,
                                                   lv_req_phase,
                                                   lv_req_status,
                                                   lv_req_dev_phase,
                                                   lv_req_dev_status,
                                                   lv_req_message);
               EXIT WHEN    UPPER (lv_req_phase) = 'COMPLETED'
                         OR UPPER (lv_req_status) IN
                               ('CANCELLED', 'ERROR', 'TERMINATED');
            END LOOP;

            DBMS_OUTPUT.PUT_LINE ('Request Phase  : ' || lv_req_dev_phase);
            DBMS_OUTPUT.PUT_LINE ('Request Status : ' || lv_req_dev_status);
            DBMS_OUTPUT.PUT_LINE ('Request id     : ' || ln_req_id);
            Fnd_File.PUT_LINE (
               Fnd_File.LOG,
                  'The Item Import Program Completion Phase: '
               || lv_req_dev_phase);
            Fnd_File.PUT_LINE (
               Fnd_File.LOG,
                  'The Item Import Program Completion Status: '
               || lv_req_dev_status);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            fnd_file.put_line (
               fnd_file.LOG,
                  'OTHERS exception while submitting The Item  Import Program: '
               || SQLERRM);
      END;

      --L_Retcode := check_error_log_to_assign_data;



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
   END assign_item_org_and_category;
END xxdbl_item_upload_pkg;
/