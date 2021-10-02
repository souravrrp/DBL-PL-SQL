

INSERT INTO apps.po_requisitions_interface_all (
                            interface_source_code,
                            org_id,
                            destination_type_code,
                            authorization_status,
                            preparer_id,
                            charge_account_id,
                            source_type_code,
                            unit_of_measure,
                            line_type_id,
                            quantity,
                            destination_organization_id,
                            deliver_to_location_id,
                            deliver_to_requestor_id,
                            item_id,
                            need_by_date,
                            suggested_vendor_name,
                            unit_price,
                            line_attribute6)
                 VALUES ('IMPORT_INV',                 --interface_source_code
                         NVL (l_org_id, p_org_id),                    --org_id
                         'INVENTORY',                  --destination_type_code
                         'INCOMPLETE',                  --authorization_status
                         NVL (p_user_id, 0),                     --preparer_id
                         l_expense_account,                --charge_account_id
                         'VENDOR',                          --source_type_code
                         l_primary_unit_of_measure,          --unit_of_measure
                         l_line_type_id,                        --line_type_id
                         NVL (p_quantity, 1),                       --quantity
                         l_destination_organization_id, --destination_organization_id
                         l_deliver_to_location_id,   --deliver_to_location_id,
                         NVL (p_user_id),            --deliver_to_requestor_id
                         l_inventory_item_id,                        --item_id
                         SYSDATE,                               --need_by_date
                         NULL,                         --suggested_vendor_name
                         NVL (p_unit_price, 1),                   --unit_price
                         p_specification       --line_attribute6 --specication
                                        );

Oracle has provided these below three interface tables in the PO conversion.
 
1.po_headers_interface
2.po_lines_interface
3.po_distributions_interface

INSERT INTO po.po_headers_interface
 (interface_header_id,
 comments,
 process_code,
 action,
 org_id,
 document_type_code,
 currency_code,
 agent_id,
 vendor_id,
 vendor_name,
 vendor_site_code,
 ship_to_location_id,
 bill_to_location_id,
 effective_date,
 reference_num,
 last_update_date
 )
SELECT apps.po_headers_interface_s.NEXTVAL,
 INFORMATION,
 ‘PENDING’,
 ‘ORIGINAL’,
 85,
 ‘STANDARD’,
 ‘INR’,
 81,
 SUPPLIER_ID,
 SUPPLIER,
 VENDOR_SITE,
 SHIP_ID,
 BILL_ID
 TRUNC(SYSDATE),
 ‘PO’||apps.po_headers_interface_s.NEXTVAL,
 SYSDATE
 FROM
 XX_PO_HDR_STAGING;

/****** INSERTING DATA INTO PO_LINES_INTERFACE ******/

TRUNCATE TABLE po.po_lines_interface
INSERT INTO po.po_lines_interface
 (interface_header_id,
 interface_line_id,
 line_num,
 shipment_num,
 line_type,
 item,
 item_description,
 uom_code,
 quantity,
 unit_price,
 organization_id,
 need_by_date,
 ship_to_organization_id,
 ship_to_location
 )
 SELECT
 apps.po_headers_interface_s.CURRVAL,
 APPS.PO_LINES_INTERFACE_S.NEXTVAL,
 LINE_NUMBER,
SHIP_NUMBER,
 ‘Goods’,
 ICODE,
 ITEM,
 UOM,
 QUANTITY,
 PRICE,
 SHIP_TO_ORGID,
 TRUNC(SYSDATE),
 M.SHIP_ORGID,
 M.SHIP_TO_LOC
 FROM
 XX_PO_LINE_STAGING;

/******* INSERTING DATA INTO PO_DISTRIBUTIONS_INTERFACE ******/


 INSERT INTO po.po_distributions_interface
 (interface_header_id,
 interface_line_id,
 interface_distribution_id,
 distribution_num,
 quantity_ordered
 )
 — CHARGE_ACCOUNT_ID)
 SELECT apps.po_headers_interface_s.CURRVAL
 APPS.PO_LINES_INTERFACE_S.CURRVAL,
 po.po_distributions_interface_s.NEXTVAL,
 SHIPMENT_NUM,
 QUANTITY
 FROM
 XX_PO_SHIP_STAGING;
To check the rejected records in the PO conversion we can see in this below table.

 po.po_interface_errors
 

 

Update purchase order api in oracle apps r12
 
DECLARE

v_result        NUMBER;
v_api_errors    po_api_errors_rec_type;
 
v_revision_num  po_headers_all.revision_num%TYPE;
v_price         po_lines_all.unit_price%TYPE;
v_quantity      po_line_locations_all.quantity%TYPE;
v_po_number     po_headers_all.segment1%TYPE;
v_line_num      po_lines_all.line_num%TYPE;
v_shipment_num  po_line_locations_all.shipment_num%TYPE;
v_promised_date DATE;
v_need_by_date  DATE;
v_org_id        NUMBER;
 
v_context       VARCHAR2(10);
 
BEGIN
 
v_context := set_context (‘&user’, ‘&responsibility’, 2038);
 
IF v_context = ‘F’
   THEN
   DBMS_OUTPUT.PUT_LINE (‘Error in the context’);
END IF;
 
MO_GLOBAL.INIT (‘PO’);
 
v_po_number     :=’10000678’;
v_line_num      := 1;
v_shipment_num  := 1;
v_revision_num  := 0;
v_promised_date := ’01-APR-2016';
v_need_by_date  := ’11-MAY-2016';
v_quantity      := 456;
v_price         := 12;
v_org_id        := 85;
 
DBMS_OUTPUT.put_line (‘Calling API To Update PO’);
 
v_result :=
 
    PO_CHANGE_API1_S.UPDATE_PO
         (x_po_number          => v_po_number,
          x_release_number     => NULL,
          x_revision_number    => v_revision_num,
          x_line_number        => v_line_num,
          x_shipment_number    => v_shipment_num,
          new_quantity         => v_quantity,
          new_price            => v_price,
          new_promised_date    => v_promised_date,
          new_need_by_date     => v_need_by_date,
          launch_approvals_flag=> ‘Y’,
          update_source        => NULL,
          VERSION              => ‘1.0’,
          x_override_date      => NULL,
          x_api_errors         => v_api_errors,
          p_buyer_name         => NULL,
          p_secondary_quantity => NULL,
          p_preferred_grade    => NULL,
          p_org_id             => v_org_id
         );
 
DBMS_OUTPUT.put_line (‘RESULT :’ ||v_result);
 
IF (v_result = 1)
THEN
 DBMS_OUTPUT.put_line(‘Updating PO is Successful ‘);
ELSE
 DBMS_OUTPUT.put_line (‘Updating PO failed’);
 
 FOR j IN 1 .. v_api_errors.MESSAGE_TEXT.COUNT
 LOOP
 DBMS_OUTPUT.put_line (v_api_errors.MESSAGE_TEXT (j));
 END LOOP;
END IF;
 
END;
Update purchase requisition api in oracle apps r12

 
DECLARE
  l_req_hdr      PO_REQUISITION_UPDATE_PUB.req_hdr;
  l_req_line_tbl PO_REQUISITION_UPDATE_PUB.req_line_tbl;
  l_req_dist_dtl PO_REQUISITION_UPDATE_PUB.req_dist_tbl;
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
 BEGIN
   l_req_hdr.requisition_header_id             := 35554;
  l_req_hdr.org_id                            := 85;
  l_req_line_tbl(1).requisition_header_id     := 35554;
  l_req_line_tbl(1).requisition_line_id       := 6778995;
  l_req_line_tbl(1).suggested_vendor_name     := ‘TPT’;
  l_req_line_tbl(1).suggested_vendor_location :=’DELHI’;
 
  PO_REQUISITION_UPDATE_PUB.update_requisition
  (p_init_msg_list   => ‘T’,
   p_commit          => ‘F’,
   x_return_status   => l_return_status,
   x_msg_count       => l_msg_count,
   x_msg_data        => l_msg_data,
   p_submit_approval => ‘N’,
   p_req_hdr         => l_req_hdr,
   p_req_line_tbl    => l_req_line_tbl,
   p_req_dist_tbl    => l_req_dist_dtl
   );
  DBMS_OUTPUT.PUT_LINE(‘Return Status :’ || l_return_status);
  DBMS_OUTPUT.PUT_LINE(‘Msg Count :’ || l_msg_count);
  DBMS_OUTPUT.PUT_LINE(‘Msg Data :’ || l_msg_data);
 
END;



DECLARE
  lrec_req_hdr      PO_REQUISITION_UPDATE_PUB.req_hdr;
  ltab_req_line_tbl PO_REQUISITION_UPDATE_PUB.req_line_tbl;
  ltab_req_dist_dtl PO_REQUISITION_UPDATE_PUB.req_dist_tbl;
  lv_return_status  VARCHAR2(1);
  ln_msg_count      NUMBER;
  lv_msg_data       VARCHAR2(2000);
 
BEGIN
 
  lrec_req_hdr.requisition_header_id             := 115001;
  lrec_req_hdr.org_id                            := 85;
  ltab_req_line_tbl(1).requisition_header_id     := 115001;
  ltab_req_line_tbl(1).requisition_line_id       := 126332;
  ltab_req_line_tbl(1).suggested_vendor_name     := 'SHARE_ORACLE';
  ltab_req_line_tbl(1).suggested_vendor_location := 'SHARE_ORACLE_LOC';
 
  PO_REQUISITION_UPDATE_PUB.update_requisition
  (p_init_msg_list   => 'T',
   p_commit          => 'F',
   x_return_status   => lv_return_status,
   x_msg_count       => ln_msg_count,
   x_msg_data        => lv_msg_data,
   p_submit_approval => 'N',
   p_req_hdr         => lrec_req_hdr,
   p_req_line_tbl    => ltab_req_line_tbl,
   p_req_dist_tbl    => ltab_req_dist_dtl
   );
 
  DBMS_OUTPUT.PUT_LINE('Return Status :' || lv_return_status);
  DBMS_OUTPUT.PUT_LINE('Msg Count :' || ln_msg_count);
  DBMS_OUTPUT.PUT_LINE('Msg Data :' || lv_msg_data);
 
END;

Step:1  Validate all the entities and insert in PO_REQUISITIONS_INTERFACE_ALL

INSERT
INTO apps.PO_REQUISITIONS_INTERFACE_ALL
  (
    interface_source_code,
    org_id,
    destination_type_code,
    authorization_status,
    preparer_id,
    charge_account_id,
    source_type_code,
    unit_of_measure,
    line_type_id,
    quantity,
    destination_organization_id,
    deliver_to_location_id,
    deliver_to_requestor_id,
    item_id,
    need_by_date,
    suggested_vendor_name,
    unit_price
  )
  VALUES
  (
    'IMPORT_INV',
    204,                        --(Validate against apps.org_organization_definitions table)
    'INVENTORY',
    'INCOMPLETE',
    25,                         --(Validate against apps.per_all_people_f tabel)
    13185,                   --(Vlidate against apps.mtl_system_items_b corresponding to item and inv org),
    'VENDOR',           --SOURCE_TYPE_CODE,
    'METRICTON',   --UNIT_OF_MEASURE
    1,                           --(Validate against PO_LINE_TYPES)
    100,                       --QUANTITY
    204,                       --DESTINATION_ORGANIZATION_ID,
    27108,                   --DELIVER_TO_LOCATION_ID,
    25,                         --DELIVER_TO_REQUESTOR_ID
    208955,                 --(Validate against mtl_system_items_b)
    SYSDATE,           --NEED_BY_DATE
    'Staples',               --SUGGESTED_VENDOR_NAME
    1                             --UNIT_PRICE
  );

Step:2 Submit "Requisition Import" program.

BEGIN
  APPS.FND_GLOBAL.APPS_INITIALIZE ( USER_ID => 1318, RESP_ID => 50578, RESP_APPL_ID => 201 );
  APPS.FND_REQUEST.SET_ORG_ID('204');
  V_REQUEST_ID := APPS.FND_REQUEST.SUBMIT_REQUEST (APPLICATION => 'PO' --Application,
                                                  ,PROGRAM => 'REQIMPORT'    --Program,
                                                  ,ARGUMENT1 => ''                       --Interface Source code,
                                                  ,ARGUMENT2 => ''                       --Batch ID,
                                                  ,ARGUMENT3 => 'ALL'               --Group By,
                                                  ,ARGUMENT4 => ''                       --Last Req Number,
                                                  ,ARGUMENT5 => 'N'                    --Multi Distributions,
                                                  ,ARGUMENT6 => 'Y'                    --Initiate Approval after ReqImport
                                                  );
  COMMIT;
END;