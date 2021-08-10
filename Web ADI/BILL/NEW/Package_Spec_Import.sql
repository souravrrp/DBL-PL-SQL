/* Formatted on 6/18/2020 12:11:00 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.ar_bill_import_adi_pkg
IS
   PROCEDURE import_data_to_ar_tbl;

END ar_bill_import_adi_pkg;
/

DROP PACKAGE ar_bill_import_adi_pkg;