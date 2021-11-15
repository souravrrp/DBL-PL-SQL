CREATE OR REPLACE PACKAGE XX_APEX.XX_APEX_PKG_CNF_JOB_ENTRY
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
                                 p_USER_BY                     NUMBER);

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
                                   p_USER_BY                     NUMBER);



   PROCEDURE CNF_JOB_ENTRY_SUBMIT (p_JOB_MASTER_ID NUMBER, p_USER_BY NUMBER);
   PROCEDURE CNF_JOB_ENTRY_CTG_APPRV (p_JOB_MASTER_ID NUMBER, p_USER_BY NUMBER);
   PROCEDURE CNF_JOB_ENTRY_CORP_APPRV (p_JOB_MASTER_ID NUMBER, p_USER_BY NUMBER);
   PROCEDURE CNF_JOB_ENTRY_AUTHORIZE_APPRV (p_JOB_MASTER_ID NUMBER, p_USER_BY NUMBER);
END XX_APEX_PKG_CNF_JOB_ENTRY;
/