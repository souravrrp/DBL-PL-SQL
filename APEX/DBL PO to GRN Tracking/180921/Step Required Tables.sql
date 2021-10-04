/* Formatted on 9/12/2021 11:59:58 AM (QP5 v5.354) */
-----------------------------------STEP-SYS-------------------------------------

SELECT *
  FROM applsys.fnd_user fu;

SELECT SYSDATE FROM DUAL;

-----------------------------------STEP-1---------------------------------------

SELECT *
  FROM apps.hr_operating_units hou;

SELECT pha.po_header_id,
       pha.segment1,
       pha.creation_date,
       pha.approved_date,
       pha.*
  FROM apps.po_headers_all pha;

-----------------------------------STEP-2---------------------------------------

SELECT aps.segment1, aps.vendor_name, aps.*
  FROM ap.ap_suppliers aps;
  
  
SELECT msi.segment1, msi.description, msi.*
  FROM inv.mtl_system_items_b msi;
  
-----------------------------------STEP-2---------------------------------------

SELECT lc.*
  FROM xxdbl.xx_lc_details lc;