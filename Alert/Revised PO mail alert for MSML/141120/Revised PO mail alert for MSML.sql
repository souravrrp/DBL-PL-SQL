/* Formatted on 11/14/2020 2:53:58 PM (QP5 v5.354) */
  SELECT PHA.ORG_ID,
         PHA.SEGMENT1                  PO_NUM,
         PHA.REVISION_NUM,
         PLA.LINE_NUM                  PO_LINE_NUM,
         PLLA.SHIPMENT_NUM,
         PLA.ITEM_DESCRIPTION,
         PLA.UNIT_MEAS_LOOKUP_CODE     UOM,
         PLA.LIST_PRICE_PER_UNIT,
         PLA.QUANTITY                  PO_LINE_QUANTITY,
         PHA.AUTHORIZATION_STATUS      HEADER_APPROVAL_STATUS,
         PHA.APPROVED_DATE             HEADER_APPROVED_DATE,
         PV.VENDOR_NAME,
         APSS.VENDOR_SITE_CODE,
         NULL                          hr_full_name,
         NULL                          emp_no,
         NULL                          person_id,
         NULL                          user_name,
         NULL                          EMAIL_ADDRESS,
         NULL                          job,
         MAX (PAH.CREATION_DATE)       CREATION_DATE,
         NULL                          MODIFIED_DATE
    FROM PO.PO_LINE_LOCATIONS_ARCHIVE_ALL PLLA,
         PO.PO_LINES_ARCHIVE_ALL         PLA,
         PO.PO_HEADERS_ARCHIVE_ALL       PHA,
         APPS.PO_VENDORS                 PV,
         APPS.AP_SUPPLIER_SITES_ALL      APSS,
         PO.PO_ACTION_HISTORY            PAH,
         apps.fnd_user                   fu,
         hr.per_all_people_f             papf,
         hr.per_all_assignments_f        paaf,
         hr.per_jobs                     pj
   WHERE     1 = 1
         AND PAH.object_id = PHA.po_header_id
         AND pah.object_type_code = 'PO'
         AND pah.action_code = 'SUBMIT'
         AND pah.employee_id = fu.employee_id
         AND PLA.REVISION_NUM = pah.OBJECT_REVISION_NUM
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND papf.effective_end_date >= SYSDATE
         AND paaf.job_id = pj.job_id
         AND paaf.primary_flag = 'Y'
         AND paaf.effective_end_date >= SYSDATE
         AND EXISTS
                 (SELECT 1
                    FROM PO.PO_LINES_ARCHIVE_ALL PLA2
                   WHERE     PLA.PO_LINE_ID = PLA2.PO_LINE_ID
                         AND PLA.LINE_NUM = PLA2.LINE_NUM
                         AND PLA.REVISION_NUM < PLA2.REVISION_NUM)
         AND PLA.CANCEL_FLAG = 'N'
         AND PLA.PO_LINE_ID = PLLA.PO_LINE_ID
         AND PHA.VENDOR_ID = PV.VENDOR_ID
         AND PHA.VENDOR_SITE_ID = APSS.VENDOR_SITE_ID
         AND PLA.PO_HEADER_ID = PLLA.PO_HEADER_ID
         AND PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
         AND pha.VENDOR_ID = '2550'
         --AND PHA.VENDOR_SITE_ID = '9873'
         AND PHA.SEGMENT1 IN ('10233000799')
         AND PHA.REVISION_NUM = PLA.REVISION_NUM
         AND PLA.REVISION_NUM = PLLA.REVISION_NUM
         AND PHA.REVISION_NUM = PLLA.REVISION_NUM
GROUP BY PHA.ORG_ID,
         PHA.SEGMENT1,
         PHA.REVISION_NUM,
         PLA.LINE_NUM,
         PLLA.SHIPMENT_NUM,
         PLA.ITEM_DESCRIPTION,
         PLA.UNIT_MEAS_LOOKUP_CODE,
         PLA.LIST_PRICE_PER_UNIT,
         PLA.QUANTITY,
         PHA.AUTHORIZATION_STATUS,
         PHA.APPROVED_DATE,
         PV.VENDOR_NAME,
         APSS.VENDOR_SITE_CODE
UNION ALL
  SELECT PHA.ORG_ID,
         PHA.SEGMENT1                  PO_NUM,
         PHA.REVISION_NUM,
         PLA.LINE_NUM                  PO_LINE_NUM,
         PLLA.SHIPMENT_NUM,
         PLA.ITEM_DESCRIPTION,
         PLA.UNIT_MEAS_LOOKUP_CODE     UOM,
         PLA.LIST_PRICE_PER_UNIT,
         PLA.QUANTITY                  PO_LINE_QUANTITY,
         PHA.AUTHORIZATION_STATUS      HEADER_APPROVAL_STATUS,
         PHA.APPROVED_DATE             HEADER_APPROVED_DATE,
         PV.VENDOR_NAME,
         APSS.VENDOR_SITE_CODE,
         papf.full_name                hr_full_name,
         papf.employee_number          emp_no,
         papf.person_id,
         fu.user_name,
         fu.EMAIL_ADDRESS,
         pj.NAME                       job,
         NULL                          CREATED_DATE,
         MIN (PAH.CREATION_DATE)       MODIFIED_DATE
    FROM PO.PO_LINE_LOCATIONS_ARCHIVE_ALL PLLA,
         PO.PO_LINES_ARCHIVE_ALL         PLA,
         PO.PO_HEADERS_ARCHIVE_ALL       PHA,
         APPS.PO_VENDORS                 PV,
         APPS.AP_SUPPLIER_SITES_ALL      APSS,
         PO.PO_ACTION_HISTORY            PAH,
         apps.fnd_user                   fu,
         hr.per_all_people_f             papf,
         hr.per_all_assignments_f        paaf,
         hr.per_jobs                     pj
   WHERE     1 = 1
         AND PAH.object_id = PHA.po_header_id
         AND pah.object_type_code = 'PO'
         AND pah.action_code = 'SUBMIT'
         AND pah.employee_id = fu.employee_id
         AND PLA.REVISION_NUM = pah.OBJECT_REVISION_NUM
         AND fu.employee_id = papf.person_id
         AND papf.person_id = paaf.person_id
         AND papf.effective_end_date >= SYSDATE
         AND paaf.job_id = pj.job_id
         AND paaf.primary_flag = 'Y'
         AND paaf.effective_end_date >= SYSDATE
         AND EXISTS
                 (SELECT 1
                    FROM PO.PO_LINES_ARCHIVE_ALL PLA2
                   WHERE     PLA.PO_LINE_ID = PLA2.PO_LINE_ID
                         AND PLA.LINE_NUM = PLA2.LINE_NUM
                         AND PLA.REVISION_NUM > PLA2.REVISION_NUM)
         AND PLA.CANCEL_FLAG = 'N'
         AND PLA.PO_LINE_ID = PLLA.PO_LINE_ID
         AND PHA.VENDOR_ID = PV.VENDOR_ID
         AND PHA.VENDOR_SITE_ID = APSS.VENDOR_SITE_ID
         AND PLA.PO_HEADER_ID = PLLA.PO_HEADER_ID
         AND PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
         AND pha.VENDOR_ID = '2550'
         --AND PHA.VENDOR_SITE_ID = '9873'
         AND PHA.SEGMENT1 IN ('10233000799')
         AND PHA.REVISION_NUM = PLA.REVISION_NUM
         AND PLA.REVISION_NUM = PLLA.REVISION_NUM
         AND PHA.REVISION_NUM = PLLA.REVISION_NUM
GROUP BY PHA.ORG_ID,
         PHA.SEGMENT1,
         PHA.REVISION_NUM,
         PLA.LINE_NUM,
         PLLA.SHIPMENT_NUM,
         PLA.ITEM_DESCRIPTION,
         PLA.UNIT_MEAS_LOOKUP_CODE,
         PLA.LIST_PRICE_PER_UNIT,
         PLA.QUANTITY,
         PHA.AUTHORIZATION_STATUS,
         PHA.APPROVED_DATE,
         PV.VENDOR_NAME,
         APSS.VENDOR_SITE_CODE,
         papf.full_name,
         papf.employee_number,
         papf.person_id,
         fu.user_name,
         fu.EMAIL_ADDRESS,
         pj.NAME