CREATE OR REPLACE PACKAGE BODY XX_APEX.XX_APEX_PKG_CNF_JOB_ENTRY
AS
   PROCEDURE CNF_JOB_ENTRY_SAVE (p_OPERATING_UNIT              NUMBER,
                                 p_BUYER                       VARCHAR2,
                                 p_NUMBER_OF_CONTAINER         NUMBER,
                                 p_LC_NO                       VARCHAR2,
                                 p_LC_DATE                     DATE,
                                 p_CONTAINER_SIZE              VARCHAR2,
                                 p_COMMERCIAL_INVOICE_NO       VARCHAR2,
                                 p_COMMERCIAL_INVOICE_DATE     DATE,
                                 p_COMMERCIAL_INVOICE_VALUE    NUMBER,
                                 p_PRIMARY_QTY                 NUMBER,
                                 p_PRIMARY_UOM                 VARCHAR2,
                                 p_SECONDARY_QTY               NUMBER,
                                 p_SECONDARY_UOM               VARCHAR2,
                                 p_ITEM                        VARCHAR2,
                                 p_SCAN_COPY_URL               VARCHAR2,
                                 p_B_E_OR_S_B_NO               VARCHAR2,
                                 p_B_E_OR_S_B_DATE             DATE,
                                 p_DEPARTURE_FROM              VARCHAR2,
                                 p_DEPARTURE_FROM_DATE         DATE,
                                 p_CURRENCY                    VARCHAR2,
                                 p_DEPOT_NAME                  VARCHAR2,
                                 p_TRANSPORTER                 VARCHAR2,
                                 p_ASSESSABLE_VALUE_TK         NUMBER,
                                 p_USER_BY                     NUMBER,
                                 -----------------------------------------
                                 p_ASSESSMENT_BY               VARCHAR2,
                                 p_ASSESSMENT_BY_NAME          VARCHAR2,
                                 p_ASSESSMENT_DATE             DATE,
                                 p_ASSESSMENT_AMOUNT           NUMBER,
                                 p_DELIVERY_ORDER_BY           VARCHAR2,
                                 p_DELIVERY_ORDER_BY_NAME      VARCHAR2,
                                 p_DELIVERY_ORDER_DATE         DATE,
                                 p_DELIVERY_ORDER_AMOUNT       NUMBER,
                                 p_DELIVERY_BY                 VARCHAR2,
                                 p_DELIVERY_BY_NAME            VARCHAR2,
                                 p_DELIVERY_DATE               DATE,
                                 p_DELIVERY_AMOUNT             NUMBER,
                                 p_ON_CHASSIS_DELIVERY         VARCHAR2)
   IS
      ref_JOB_MASTER_ID   NUMBER;
      iBILL_NO            VARCHAR2 (100);
      iJOB_NO             VARCHAR2 (100);
   BEGIN
      -- GET BILL NO
      SELECT XX_APEX.XX_APEX_CNF_BILL_NO (p_OPERATING_UNIT)
        INTO iBILL_NO
        FROM DUAL;

      -- GET JOB NO
      SELECT XX_APEX.XX_APEX_CNF_JOB_NO INTO iJOB_NO FROM DUAL;

      INSERT INTO XX_APEX.XX_APEX_CNF_JOB_MASTER (OPERATING_UNIT,
                                                  BILL_NO,
                                                  BUYER,
                                                  JOB_NO,
                                                  JOB_DATE,
                                                  NUMBER_OF_CONTAINER,
                                                  LC_NO,
                                                  LC_DATE,
                                                  CONTAINER_SIZE,
                                                  COMMERCIAL_INVOICE_NO,
                                                  COMMERCIAL_INVOICE_DATE,
                                                  COMMERCIAL_INVOICE_VALUE,
                                                  PRIMARY_QTY,
                                                  PRIMARY_UOM,
                                                  SECONDARY_QTY,
                                                  SECONDARY_UOM,
                                                  ITEM,
                                                  SCAN_COPY_URL,
                                                  B_E_OR_S_B_NO,
                                                  B_E_OR_S_B_DATE,
                                                  DEPARTURE_FROM,
                                                  DEPARTURE_FROM_DATE,
                                                  CURRENCY,
                                                  DEPOT_NAME,
                                                  TRANSPORTER,
                                                  ASSESSABLE_VALUE_TK,
                                                  JOB_STATUS,
                                                  ASSESSMENT_BY,
                                                  ASSESSMENT_BY_NAME,
                                                  ASSESSMENT_DATE,
                                                  ASSESSMENT_AMOUNT,
                                                  DELIVERY_ORDER_BY,
                                                  DELIVERY_ORDER_BY_NAME,
                                                  DELIVERY_ORDER_DATE,
                                                  DELIVERY_ORDER_AMOUNT,
                                                  DELIVERY_BY,
                                                  DELIVERY_BY_NAME,
                                                  DELIVERY_DATE,
                                                  DELIVERY_AMOUNT,
                                                  ON_CHASSIS_DELIVERY,
                                                  CREATED_BY,
                                                  CREATION_DATE,
                                                  LAST_UPDATED_BY,
                                                  LAST_UPDATE_DATE)
           VALUES (p_OPERATING_UNIT,
                   iBILL_NO,
                   p_BUYER,
                   iJOB_NO,
                   SYSDATE,
                   p_NUMBER_OF_CONTAINER,
                   p_LC_NO,
                   p_LC_DATE,
                   p_CONTAINER_SIZE,
                   p_COMMERCIAL_INVOICE_NO,
                   p_COMMERCIAL_INVOICE_DATE,
                   p_COMMERCIAL_INVOICE_VALUE,
                   p_PRIMARY_QTY,
                   p_PRIMARY_UOM,
                   p_SECONDARY_QTY,
                   p_SECONDARY_UOM,
                   p_ITEM,
                   p_SCAN_COPY_URL,
                   p_B_E_OR_S_B_NO,
                   p_B_E_OR_S_B_DATE,
                   p_DEPARTURE_FROM,
                   p_DEPARTURE_FROM_DATE,
                   p_CURRENCY,
                   p_DEPOT_NAME,
                   p_TRANSPORTER,
                   p_ASSESSABLE_VALUE_TK,
                   'New',
                   p_ASSESSMENT_BY,
                   p_ASSESSMENT_BY_NAME,
                   p_ASSESSMENT_DATE,
                   p_ASSESSMENT_AMOUNT,
                   p_DELIVERY_ORDER_BY,
                   p_DELIVERY_ORDER_BY_NAME,
                   p_DELIVERY_ORDER_DATE,
                   p_DELIVERY_ORDER_AMOUNT,
                   p_DELIVERY_BY,
                   p_DELIVERY_BY_NAME,
                   p_DELIVERY_DATE,
                   p_DELIVERY_AMOUNT,
                   p_ON_CHASSIS_DELIVERY,
                   p_USER_BY,
                   SYSDATE,
                   p_USER_BY,
                   SYSDATE)
        RETURNING JOB_MASTER_ID
             INTO ref_JOB_MASTER_ID;

      COMMIT;


      INSERT INTO XX_APEX.XX_APEX_CNF_JOB_DETAILS (JOB_MASTER_ID,
                                                   EXPENSE_LIST_ID,
                                                   AMOUNT,
                                                   DAMURRAGE_AMOUNT,
                                                   EXPENSE_ITEM_QTY,
                                                   REMARKS,
                                                   CREATED_BY,
                                                   CREATION_DATE,
                                                   LAST_UPDATED_BY,
                                                   LAST_UPDATE_DATE)
         SELECT ref_JOB_MASTER_ID,
                EXPENSE_LIST_ID,
                NULL,
                NULL,
                NULL,
                NULL,
                p_USER_BY,
                SYSDATE,
                p_USER_BY,
                SYSDATE
           FROM XX_APEX.XX_APEX_CNF_EXPENSE_LIST;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20001,
               'An error was encountered - '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
   END CNF_JOB_ENTRY_SAVE;

   PROCEDURE CNF_JOB_ENTRY_UPDATE (p_JOB_MASTER_ID               NUMBER,
                                   p_BUYER                       VARCHAR2,
                                   p_NUMBER_OF_CONTAINER         NUMBER,
                                   p_CONTAINER_SIZE              VARCHAR2,
                                   p_COMMERCIAL_INVOICE_NO       VARCHAR2,
                                   p_COMMERCIAL_INVOICE_DATE     DATE,
                                   p_COMMERCIAL_INVOICE_VALUE    NUMBER,
                                   p_PRIMARY_QTY                 NUMBER,
                                   p_PRIMARY_UOM                 VARCHAR2,
                                   p_SECONDARY_QTY               NUMBER,
                                   p_SECONDARY_UOM               VARCHAR2,
                                   p_ITEM                        VARCHAR2,
                                   p_SCAN_COPY_URL               VARCHAR2,
                                   p_B_E_OR_S_B_NO               VARCHAR2,
                                   p_B_E_OR_S_B_DATE             DATE,
                                   p_DEPARTURE_FROM              VARCHAR2,
                                   p_DEPARTURE_FROM_DATE         DATE,
                                   p_CURRENCY                    VARCHAR2,
                                   p_DEPOT_NAME                  VARCHAR2,
                                   p_TRANSPORTER                 VARCHAR2,
                                   p_ASSESSABLE_VALUE_TK         NUMBER,
                                   p_USER_BY                     NUMBER,
                                   -----------------------------------------
                                   p_ASSESSMENT_BY               VARCHAR2,
                                   p_ASSESSMENT_BY_NAME          VARCHAR2,
                                   p_ASSESSMENT_DATE             DATE,
                                   p_ASSESSMENT_AMOUNT           NUMBER,
                                   p_DELIVERY_ORDER_BY           VARCHAR2,
                                   p_DELIVERY_ORDER_BY_NAME      VARCHAR2,
                                   p_DELIVERY_ORDER_DATE         DATE,
                                   p_DELIVERY_ORDER_AMOUNT       NUMBER,
                                   p_DELIVERY_BY                 VARCHAR2,
                                   p_DELIVERY_BY_NAME            VARCHAR2,
                                   p_DELIVERY_DATE               DATE,
                                   p_DELIVERY_AMOUNT             NUMBER,
                                   p_ON_CHASSIS_DELIVERY         VARCHAR2)
   IS
      ref_JOB_MASTER_ID   NUMBER;
      iBILL_NO            VARCHAR2 (100);
      iJOB_NO             VARCHAR2 (100);
   BEGIN
      UPDATE XX_APEX.XX_APEX_CNF_JOB_MASTER
         SET                                                 --OPERATING_UNIT,
             --BILL_NO,
             BUYER = p_BUYER,
             --JOB_NO,
             --JOB_DATE = p_JOB_DATE,
             NUMBER_OF_CONTAINER = p_NUMBER_OF_CONTAINER,
             --LC_NO,
             --LC_DATE,
             CONTAINER_SIZE = p_CONTAINER_SIZE,
             COMMERCIAL_INVOICE_NO = p_COMMERCIAL_INVOICE_NO,
             COMMERCIAL_INVOICE_DATE = p_COMMERCIAL_INVOICE_DATE,
             COMMERCIAL_INVOICE_VALUE = p_COMMERCIAL_INVOICE_VALUE,
             PRIMARY_QTY = p_PRIMARY_QTY,
             PRIMARY_UOM = p_PRIMARY_UOM,
             SECONDARY_QTY = p_SECONDARY_QTY,
             SECONDARY_UOM = p_SECONDARY_UOM,
             ITEM = p_ITEM,
             SCAN_COPY_URL = p_SCAN_COPY_URL,
             B_E_OR_S_B_NO = p_B_E_OR_S_B_NO,
             B_E_OR_S_B_DATE = p_B_E_OR_S_B_DATE,
             DEPARTURE_FROM = p_DEPARTURE_FROM,
             DEPARTURE_FROM_DATE = p_DEPARTURE_FROM_DATE,
             CURRENCY = p_CURRENCY,
             DEPOT_NAME = p_DEPOT_NAME,
             TRANSPORTER = p_TRANSPORTER,
             ASSESSABLE_VALUE_TK = p_ASSESSABLE_VALUE_TK,
             ASSESSMENT_BY = p_ASSESSMENT_BY,
             ASSESSMENT_BY_NAME = p_ASSESSMENT_BY_NAME,
             ASSESSMENT_DATE = p_ASSESSMENT_DATE,
             ASSESSMENT_AMOUNT = p_ASSESSMENT_AMOUNT,
             DELIVERY_ORDER_BY = p_DELIVERY_ORDER_BY,
             DELIVERY_ORDER_BY_NAME = p_DELIVERY_ORDER_BY_NAME,
             DELIVERY_ORDER_DATE = p_DELIVERY_ORDER_DATE,
             DELIVERY_ORDER_AMOUNT = p_DELIVERY_ORDER_AMOUNT,
             DELIVERY_BY = p_DELIVERY_BY,
             DELIVERY_BY_NAME = p_DELIVERY_BY_NAME,
             DELIVERY_DATE = p_DELIVERY_DATE,
             DELIVERY_AMOUNT = p_DELIVERY_AMOUNT,
             ON_CHASSIS_DELIVERY = p_ON_CHASSIS_DELIVERY,
             LAST_UPDATED_BY = p_USER_BY,
             LAST_UPDATE_DATE = SYSDATE
       WHERE JOB_MASTER_ID = p_JOB_MASTER_ID;

      COMMIT;


      INSERT INTO XX_APEX.XX_APEX_CNF_JOB_DETAILS (JOB_MASTER_ID,
                                                   EXPENSE_LIST_ID,
                                                   AMOUNT,
                                                   DAMURRAGE_AMOUNT,
                                                   EXPENSE_ITEM_QTY,
                                                   REMARKS,
                                                   CREATED_BY,
                                                   CREATION_DATE,
                                                   LAST_UPDATED_BY,
                                                   LAST_UPDATE_DATE)
         SELECT p_JOB_MASTER_ID,
                EXPENSE_LIST_ID,
                NULL,
                NULL,
                NULL,
                NULL,
                p_USER_BY,
                SYSDATE,
                p_USER_BY,
                SYSDATE
           FROM XX_APEX.XX_APEX_CNF_EXPENSE_LIST
          WHERE NOT EXISTS
                       (SELECT EXPENSE_LIST_ID
                          FROM XX_APEX.XX_APEX_CNF_JOB_DETAILS);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20001,
               'An error was encountered - '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
   END CNF_JOB_ENTRY_UPDATE;


   PROCEDURE CNF_JOB_ENTRY_SUBMIT (p_JOB_MASTER_ID NUMBER, p_USER_BY NUMBER)
   IS
   BEGIN
      UPDATE XX_APEX.XX_APEX_CNF_JOB_MASTER
         SET JOB_STATUS = 'Submitted',
             LAST_UPDATED_BY = p_USER_BY,
             LAST_UPDATE_DATE = SYSDATE
       WHERE JOB_MASTER_ID = p_JOB_MASTER_ID;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20001,
               'An error was encountered - '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
   END CNF_JOB_ENTRY_SUBMIT;

   PROCEDURE CNF_JOB_ENTRY_CTG_APPRV (p_JOB_MASTER_ID    NUMBER,
                                      p_USER_BY          NUMBER)
   IS
   BEGIN
      UPDATE XX_APEX.XX_APEX_CNF_JOB_MASTER
         SET JOB_STATUS = 'Approved_CTG',
             LAST_UPDATED_BY = p_USER_BY,
             LAST_UPDATE_DATE = SYSDATE
       WHERE JOB_MASTER_ID = p_JOB_MASTER_ID;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20001,
               'An error was encountered - '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
   END CNF_JOB_ENTRY_CTG_APPRV;
   PROCEDURE CNF_JOB_ENTRY_CORP_CHECK (p_JOB_MASTER_ID    NUMBER,
                                       p_USER_BY          NUMBER)
   IS
   BEGIN
      UPDATE XX_APEX.XX_APEX_CNF_JOB_MASTER
         SET JOB_STATUS = 'Checked_CORP',
             LAST_UPDATED_BY = p_USER_BY,
             LAST_UPDATE_DATE = SYSDATE
       WHERE JOB_MASTER_ID = p_JOB_MASTER_ID;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20001,
               'An error was encountered - '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
   END CNF_JOB_ENTRY_CORP_CHECK;

   PROCEDURE CNF_JOB_ENTRY_CORP_APPRV (p_JOB_MASTER_ID    NUMBER,
                                       p_USER_BY          NUMBER)
   IS
   BEGIN
      UPDATE XX_APEX.XX_APEX_CNF_JOB_MASTER
         SET JOB_STATUS = 'Approved_CORP',
             LAST_UPDATED_BY = p_USER_BY,
             LAST_UPDATE_DATE = SYSDATE
       WHERE JOB_MASTER_ID = p_JOB_MASTER_ID;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20001,
               'An error was encountered - '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
   END CNF_JOB_ENTRY_CORP_APPRV;

   PROCEDURE CNF_JOB_ENTRY_AUTHORIZE_APPRV (p_JOB_MASTER_ID    NUMBER,
                                            p_USER_BY          NUMBER)
   IS
   BEGIN
      UPDATE XX_APEX.XX_APEX_CNF_JOB_MASTER
         SET JOB_STATUS = 'Authorized',
             LAST_UPDATED_BY = p_USER_BY,
             LAST_UPDATE_DATE = SYSDATE
       WHERE JOB_MASTER_ID = p_JOB_MASTER_ID;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20001,
               'An error was encountered - '
            || SQLCODE
            || ' -ERROR- '
            || SQLERRM);
   END CNF_JOB_ENTRY_AUTHORIZE_APPRV;
END XX_APEX_PKG_CNF_JOB_ENTRY;
/