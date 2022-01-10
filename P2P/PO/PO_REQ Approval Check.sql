--For Requisition
select pos.name
from po_requisition_headers_all rh, wf_item_attribute_values av, per_position_structures pos
where av.item_type = rh.wf_item_type
and av.item_key = rh.wf_item_key
and av.name = 'APPROVAL_PATH_ID'
and to_number(av.NUMBER_VALUE) = pos.position_structure_id
--and rh.segment1 = '' ;
--and rh.org_id = 172;   — You can use your org_id if necessary

-- For Purchase Order
select pos.name
from po_headers_all poh, wf_item_attribute_values av, per_position_structures pos
where av.item_type = poh.wf_item_type
and av.item_key = poh.wf_item_key
and av.name = 'APPROVAL_PATH_ID'
and to_number(av.NUMBER_VALUE) = pos.position_structure_id
and poh.org_id = 103
and poh.po_header_id = 1324; 
--You need to retrieve your PO_HEADER_ID

--------------------------------------------------------------------------------

SELECT
*
from 
   po_action_history pah
   WHERE 1=1
   AND OBJECT_TYPE_CODE NOT IN ('REQUISITION')
   AND OBJECT_ID='301843'
ORDER BY OBJECT_ID DESC


--------------------------------------------------------------------------------