/* Formatted on 6/30/2020 12:04:47 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.XXDBL_ITEM_UPLOAD_WEBADI_PKG
IS
   PROCEDURE cust_import_data_to_interface;

   PROCEDURE cust_upload_data_to_staging (p_item_code      VARCHAR2,
                                          p_description    VARCHAR2);
END XXDBL_ITEM_UPLOAD_WEBADI_PKG;
/