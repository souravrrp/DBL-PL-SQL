CREATE OR REPLACE PACKAGE APPS.XXDBL_ITEM_UPLOAD_WEBADI_PKG
IS

PROCEDURE cust_import_data_to_interface;

PROCEDURE cust_upload_data_to_staging (
      p_segment1                      VARCHAR2,
      p_description                   VARCHAR2,
      p_primary_uom_code              VARCHAR2,
      p_secondary_uom_code            VARCHAR2
   );

END XXDBL_ITEM_UPLOAD_WEBADI_PKG;
/
