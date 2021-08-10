/* Formatted on 11/4/2020 12:47:12 PM (QP5 v5.287) */
ALTER TABLE xxdbl.xxdbl_proforma_headers
   ADD (corrected_date DATE, correction_version NUMBER);

DROP SYNONYM XXDBL_PROFORMA_HEADERS;

CREATE OR REPLACE PUBLIC SYNONYM XXDBL_PROFORMA_HEADERS FOR XXDBL.XXDBL_PROFORMA_HEADERS;

--CREATE OR REPLACE PUBLIC SYNONYM XXDBL_BILL_STAT_HEADERS FOR XXDBL.XXDBL_BILL_STAT_HEADERS;

Column Name:
Corrected Date CORRECTED_DATE

Correction Version CORRECTION_VERSION

/*
	------------------------------------------------------------
         SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.CORRECTED_DATE',
                            insert_allowed,
                            property_true
                           );
         SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.CORRECTED_DATE',
                            update_allowed,
                            property_true
                           );
         SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.CORRECTION_VERSION',
                            insert_allowed,
                            property_true
                           );
         SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.CORRECTION_VERSION',
                            update_allowed,
                            property_true
                           );
*/

/*------------------------------------------------------------
   SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.CORRECTED_DATE',
                      enabled,
                      property_true);
   SET_ITEM_PROPERTY ('XXDBL_PROFORMA_HEADERS.CORRECTION_VERSION',
                      enabled,
                      property_true);
*/
