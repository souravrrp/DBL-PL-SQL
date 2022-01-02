/* Formatted on 12/28/2021 4:24:41 PM (QP5 v5.374) */
SELECT *
  FROM xxdbl.xxdbl_invoice_tracking_system
 WHERE 1 = 1 AND itn_no = '1000130';

---All Status-----

SELECT DISTINCT invoice_status
  FROM xxdbl.xxdbl_invoice_tracking_system;