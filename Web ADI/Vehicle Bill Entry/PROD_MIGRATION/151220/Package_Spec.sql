CREATE OR REPLACE PACKAGE APPS.XXDBL_VEHICLE_BILL_ENTRY
IS
   PROCEDURE SP_IMPORT_DATA_TO_VEHICLE_TBL (ERRBUF    OUT VARCHAR2,
                                            RETCODE   OUT VARCHAR2);

   PROCEDURE SP_TMP_VEHICLE_BILL_ENTRY (p_M_BILL_DATE          IN DATE,
                                        p_M_DESC_WORK          IN VARCHAR2,
                                        p_M_CURRENT_KM         IN NUMBER,
                                        p_M_NEXT_KM            IN NUMBER,
                                        p_M_REMARKS            IN VARCHAR2,
                                        p_M_VANDOR_NAME        IN VARCHAR2,
                                        p_M_PURCH_OU           IN VARCHAR2,
                                        p_M_MAINTAINCE_TYPE    IN VARCHAR2,
                                        p_M_VOUCHER_NO         IN VARCHAR2,
                                        --p_M_LEGAL_ENTITY_NAME   IN VARCHAR2,
                                        p_M_ALTERNATE_VENDOR   IN VARCHAR2,
                                        -- Detail Table
                                        p_D_BILL_ITEM_TYPE     IN VARCHAR2,
                                        p_D_ITEM_DTL           IN VARCHAR2,
                                        p_D_REMARKS            IN VARCHAR2,
                                        p_D_ITEM_QTY           IN NUMBER,
                                        p_D_UNIT_PRICE         IN NUMBER,
                                        p_D_DISCOUNT_AMOUNT    IN NUMBER,
                                        p_D_DR_CODE_COMB       IN VARCHAR2,
                                        p_D_VEHICLE_NUMBER     IN VARCHAR2,
                                        p_D_PR_NUMBER          IN VARCHAR2,
                                        p_D_VAT_AMNT           IN NUMBER);
END XXDBL_VEHICLE_BILL_ENTRY;
/
