/* Formatted on 6/11/2020 5:29:55 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.ar_bill_upload_pkg
IS
   PROCEDURE cust_import_data_to_interface;

   PROCEDURE cust_upload_data_to_staging (P_OPERATING_UNIT        VARCHAR2,
                                          P_CUSTOMER_NUMBER       VARCHAR2,
                                          P_BILL_CURRENCY         VARCHAR2,
                                          P_BILL_CATEGORY         VARCHAR2,
                                          P_EXCHANCE_RATE         NUMBER,
                                          P_BILL_DATE             DATE,
                                          P_BILL_TYPE             VARCHAR2,
                                          P_CHALLAN_QTY           NUMBER,
                                          P_CHALLAN_DATE          DATE,
                                          P_ITEM_CODE             VARCHAR2,
                                          P_FINISHING_WEIGHT      NUMBER,
                                          P_UNIT_SELLING_PRICE    NUMBER,
                                          P_SL_NO                 NUMBER);
END ar_bill_upload_pkg;
/