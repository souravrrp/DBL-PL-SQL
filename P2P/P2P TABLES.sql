/* Formatted on 1/9/2022 10:00:24 AM (QP5 v5.374) */
----------------------------------PO Checking-----------------------------------

SELECT *
  FROM apps.po_headers_all
 WHERE segment1 IN ('10213000238');

SELECT *
  FROM apps.po_lines_all
 WHERE po_header_id = 81461;

SELECT *
  FROM apps.po_distributions_all
 WHERE 1 = 1 AND po_header_id = 81461 AND po_line_id = 1472565;

SELECT *
  FROM apps.po_line_locations_all
 WHERE po_header_id = 81461;


SELECT *
  FROM apps.pa_projects_all
 WHERE 1 = 1;

--------------------------------------------------------------------------------

SELECT * FROM AP_INVOICE_PAYMENTS_ALL;

SELECT * FROM AP_PAYMENT_SCHEDULES_ALL;

SELECT * FROM AP_CHECKS_ALL;

SELECT * FROM AP_CHECK_FORMATS;

SELECT * FROM AP_BANK_BRANCHES;

SELECT * FROM AP_TERMS;

----------------------------------------PR----------------------------------------

SELECT * FROM XXDBL_MO_TO_PR;

SELECT * FROM XXDBL_MO_TO_PR_QTY;

--------------------------------------------------------------------------------

SELECT *
  FROM XLA_EVENTS
 WHERE 1 = 1 AND EVENT_ID = 43063;

SELECT *
  FROM XLA_AE_HEADERS
 WHERE 1 = 1 AND EVENT_ID = 43063;

SELECT *
  FROM XLA_AE_LINES
 WHERE 1 = 1
--AND EVENT_ID=43063
;
SELECT *
  FROM GL_INTERFACE
 WHERE 1 = 1
--AND REFERENCE26='43063'
;
SELECT                                                                     --*
       ACCOUNTING_EVENT_ID FROM AP_INVOICE_DISTRIBUTIONS_ALL;

SELECT * FROM AP_INVOICE_PAYMENTS_ALL;


SELECT * FROM AP_PAYMENT_SCHEDULES_ALL;

SELECT * FROM AP_CHECK_FORMATS;

SELECT *
  --DISTINCT DOCUMENT_TYPE_CODE
  FROM PO_DOCUMENT_TYPES_ALL_B QUOT
 WHERE 1 = 1 AND DOCUMENT_TYPE_CODE = 'RFQ' AND ORG_ID = '131';

SELECT *
  FROM PO_HEADERS_ALL QUOT
 WHERE 1 = 1 AND quot.type_lookup_code = 'RFQ';

SELECT * FROM PO_HEADERS_ARCHIVE_ALL;