/* Formatted on 10/2/2021 10:27:57 AM (QP5 v5.365) */
--p_organization_code
--p_line_type
--p_item_code
--p_quantity
--p_unit_price
--p_vendor_name--
--p_specification

  SELECT *
    FROM apps.po_requisitions_interface_all
   WHERE 1 = 1 AND TO_CHAR (need_by_date, 'DD-MON-RRRR') = '04-OCT-2021'
ORDER BY creation_date DESC;

DELETE apps.po_requisitions_interface_all
 WHERE 1 = 1 AND TO_CHAR (need_by_date, 'DD-MON-RRRR') = '30-SEP-2021';



SELECT ood.operating_unit      l_org_id,
       ood.organization_id     l_destination_organization_id,
       aou.location_id         deliver_to_location_id
  FROM apps.org_organization_definitions  ood,
       hr.hr_all_organization_units       aou
 WHERE     ood.organization_code = :p_organization_code
       AND ood.organization_id = aou.organization_id;

SELECT plt.line_type_id     l_line_type_id
  FROM apps.po_line_types plt
 WHERE 1 = 1 AND plt.line_type = :p_line_type;

SELECT msi.inventory_item_id,
       msi.primary_uom_code,
       msi.primary_unit_of_measure,
       msi.expense_account,
       cat.category_id
  --l_inventory_item_id, l_primary_uom_code, l_expense_account, l_category_id
  FROM apps.mtl_system_items_b msi, apps.mtl_item_categories_v cat
 WHERE     msi.inventory_item_id = cat.inventory_item_id
       AND msi.organization_id = cat.organization_id
       AND msi.segment1 = 'SPRECONS000000044929'                 --p_item_code
       AND msi.organization_id = :l_destination_organization_id;


SELECT aps.vendor_name l_vendor_name, aps.vendor_id l_vendor_id, aps.*
  FROM ap.ap_suppliers aps
 WHERE     1 = 1
       AND aps.enabled_flag = 'Y'
       AND UPPER (aps.vendor_name) LIKE UPPER ('%' || :p_vendor_name || '%');

SELECT employee_id     l_person_id
  FROM applsys.fnd_user
 WHERE user_id = :p_user_id;



--------------------------------------------------------------------------------    

  SELECT *
    FROM apps.po_requisition_headers_all prh
ORDER BY creation_date DESC;

  SELECT *
    FROM apps.po_requisition_lines_all prl
ORDER BY creation_date DESC;

SELECT inventory_item_id,
       primary_uom_code,
       primary_unit_of_measure,
       expense_account,
       msi.*
  --l_inventory_item_id, l_primary_uom_code, l_expense_account
  FROM apps.mtl_system_items_b msi
 WHERE     segment1 = 'SPRECONS000000044929'                     --p_item_code
       AND msi.organization_id = :l_destination_organization_id;

SELECT hou.name UNIT_NAME, ood.organization_id, ood.*
  FROM hr_operating_units hou, apps.org_organization_definitions ood
 WHERE     1 = 1
       AND hou.organization_id = ood.operating_unit
       AND ood.organization_code = :p_organization_code;

SELECT ood.operating_unit, ood.organization_id
  FROM apps.org_organization_definitions  ood,
       hr.hr_all_organization_units       aou,
       hr.hr_locations_all                hla
 WHERE     ood.organization_code = :p_organization_code
       AND ood.organization_id = aou.organization_id
       AND aou.location_id = hla.location_id;

SELECT ood.operating_unit, ood.organization_id
  FROM apps.org_organization_definitions ood
 WHERE ood.organization_code = :p_organization_code;



SELECT *
  FROM hr_all_organization_units aou;


SELECT *
  FROM apps.mtl_system_items_b msi
 WHERE     segment1 = 'SPRECONS000000044929'
       AND msi.organization_id = :l_destination_organization_id;

SELECT *
  FROM apps.po_vendors apv
 WHERE 1 = 1;


--------------------------------------------------------------------------------

  SELECT prh.org_id,
         hou.name,
         --ou.ledger_name,
         --ou.legal_entity_name,
         msi.organization_id,
         hla.location_code               location,
         prl.destination_subinventory    department,
         prh.requisition_header_id       req_hdr_id,
         prh.segment1                    requisition_number,
         prh.description                 req_hdr_description,
         prh.type_lookup_code            req_type,
         prh.authorization_status        req_status,
         msi.inventory_item_id,
         msi.segment1                    item_code,
         prl.line_num                    pr_line_num,
         prl.item_description            req_line_desc,
         prl.unit_meas_lookup_code       uom,
         prl.quantity,
         prl.unit_price                  "Unit cost",
         mic.segment1                    line_of_business,
         mic.segment2                    item_micegory,
         mic.segment3                    item_type,
         mic.segment4                    micelog,
            mic.segment1
         || '.'
         || mic.segment2
         || '.'
         || mic.segment3
         || '.'
         || mic.segment4                 item_micegory,
         prl.currency_code               currency,
         prh.creation_date               req_creation_date,
         prh.approved_date               req_approved_date,
         ppf.employee_number             requestor_id,
         ppf.employee_name               requestor_name,
         prl.suggested_buyer_id,
         prl.to_person_id,
         prh.preparer_id,
         prh.created_by,
         prl.attribute6                  pr_specification,
         prl.source_type_code,
         prl.destination_organization_id
    --,prh.*
    --prl.*
    FROM apps.po_requisition_headers_all prh,
         apps.po_requisition_lines_all  prl,
         apps.mtl_system_items_b        msi,
         apps.mtl_categories_v          mic,
         apps.hr_locations_all          hla,
         apps.hr_operating_units        hou,
         org_organization_definitions   ood,
         xxdbl_company_le_mapping_v     ou,
         apps.xx_employee_info_v        ppf
   WHERE     1 = 1
         AND prl.requisition_header_id = prh.requisition_header_id(+)
         AND prh.org_id = hou.organization_id(+)
         AND ood.operating_unit = ou.org_id(+)
         AND hou.organization_id = ood.operating_unit(+)
         AND prl.destination_organization_id = ood.organization_id(+)
         AND prl.deliver_to_location_id = hla.location_id(+)
         AND prl.item_id = msi.inventory_item_id(+)
         AND prl.destination_organization_id = msi.organization_id(+)
         AND prl.category_id = mic.category_id(+)
         AND NVL (prh.preparer_id, prl.to_person_id) = ppf.person_id(+)
         --AND prh.authorization_status not in ('RETURNED', 'APPROVED')
         --AND NVL (prh2.cancel_flag, 'N') <> 'Y'
         --AND NVL (prl2.cancel_flag, 'N') <> 'Y'
         --AND TRUNC (sysdate) BETWEEN ppf2.effective_start_date(+) AND ppf2.effective_end_date(+)
         AND (( :p_org_id IS NULL) OR (prh.org_id = :p_org_id))
         AND ( :p_ou_name IS NULL OR (hou.name = :p_ou_name))
         AND (   :p_organization_code IS NULL
              OR (ood.organization_code = :p_organization_code))
         AND ( :p_req_no IS NULL OR (prh.segment1 = :p_req_no))
         AND (( :p_emp_id IS NULL) OR (ppf.employee_number = :p_emp_id))
         AND ( :p_item_code IS NULL OR (msi.segment1 = :p_item_code))
         AND (   :p_item_desc IS NULL
              OR (UPPER (msi.description) LIKE
                      UPPER ('%' || :p_item_desc || '%')))
ORDER BY prh.segment1, prl.line_num;

EXECUTE APPS.xxdbl_pr_creation_pkg.cust_upload_data_to_staging ('194','Goods','SPRECONS000000080531','','10',1,'Not Applicable');


BEGIN
    INSERT INTO apps.po_requisitions_interface_all (
                    INTERFACE_SOURCE_CODE,
                    ORG_ID,
                    DESTINATION_TYPE_CODE,
                    AUTHORIZATION_STATUS,
                    PREPARER_ID,
                    CHARGE_ACCOUNT_ID,
                    SOURCE_TYPE_CODE,
                    UNIT_OF_MEASURE,
                    LINE_TYPE_ID,
                    QUANTITY,
                    DESTINATION_ORGANIZATION_ID,
                    DELIVER_TO_LOCATION_ID,
                    DELIVER_TO_REQUESTOR_ID,
                    ITEM_ID,
                    NEED_BY_DATE,
                    LINE_ATTRIBUTE6)
         VALUES ('IMPORT_INV',                         --interface_source_code
                 125,                                                 --org_id
                 'INVENTORY',                          --destination_type_code
                 'INCOMPLETE',                          --authorization_status
                 1725,                                           --preparer_id
                 409150,                                   --charge_account_id
                 'VENDOR',                                  --source_type_code
                 'Piece',                                    --unit_of_measure
                 1,                                             --line_type_id
                 10,                                                --quantity
                 151,                            --destination_organization_id
                 155,                                --deliver_to_location_id,
                 1725,                               --deliver_to_requestor_id
                 584299,                                             --item_id
                 SYSDATE + 2,                                   --need_by_date
                 'Not Applicable'              --line_attribute6 --specication
                                 );
END;