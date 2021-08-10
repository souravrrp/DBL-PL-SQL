Select 
-- rt.transaction_id,
rsh.shipment_header_id,
rt.transaction_date,
 poh.segment1 po_number,
 lc.lc_number,
 poh.approved_Date,
 sup.vendor_name,
 sup.segment1 vendor_id, 
 sus.vendor_site_code,
 rsh.receipt_num grn_no,
 rsh.attribute3,
 rsh.creation_date,
 rsh.comments remarks,
 rsh.shipment_num Shipment_Number,
 ash.ship_date,
 ood.organization_code,
 ood.organization_name, 
 rsl.to_organization_id Organization_id,
 rd.subinventory to_subinventory ,
 msi.segment1   item_code,
 rsl.item_description ,
 muom.uom_code uom,
 sum(rt1.quantity)-nvl(sum(rr.quantity),0) rcv_qty ,
 sum(rt1.quantity)-nvl(sum(rr.quantity),0)  Ins_qty,   
 nvl(sum(rd.quantity),0) del_qty,
 sum(to_number(rd.acctual_qty))acctual_qty
from
 apps.rcv_shipment_headers rsh,
 apps.rcv_shipment_lines rsl,
 apps.ap_suppliers sup,
 apps.ap_supplier_sites_all sus,
 apps.po_headers_all poh,
 apps.po_lines_all pol,
 apps.org_organization_definitions ood,
 apps.rcv_transactions rt,
 (select r.shipment_line_id, r.shipment_header_id,sum(to_number(r.attribute3))acctual_qty, max(r.transaction_date) transaction_date,
  sum(rd1.quantity) quantity,subinventory
  from apps.rcv_transactions r,( select transaction_id,sum(quantity) quantity from
  (select rcv.transaction_id transaction_id,sum(rcv.quantity) quantity from apps.rcv_transactions rcv 
  where rcv.transaction_type='DELIVER' 
  group by rcv.transaction_id    
  union all
  select r1.parent_transaction_id transaction_id,sum(r1.quantity) from apps.rcv_transactions r1,apps.rcv_transactions r2
  where r1.parent_transaction_id=r2.transaction_id
  and r1.shipment_header_id=r2.shipment_header_id
  and r1.shipment_line_id=r2.shipment_line_id
  and r1.transaction_type ='CORRECT'
  and r2.transaction_type='DELIVER'
  group by r1.parent_transaction_id
  union all
  select r1.parent_transaction_id transaction_id,sum(r1.quantity)*-1 from apps.rcv_transactions r1,apps.rcv_transactions r2
  where r1.parent_transaction_id=r2.transaction_id
  and r1.shipment_header_id=r2.shipment_header_id
  and r1.shipment_line_id=r2.shipment_line_id
  and r1.transaction_type  ='RETURN TO RECEIVING'
  and r2.transaction_type='DELIVER'
  group by r1.parent_transaction_id)
  group by transaction_id having sum(quantity)>0) rd1 
  where transaction_type = 'DELIVER' 
  and r.transaction_id=rd1.transaction_id 
 group BY r.shipment_line_id, r.shipment_header_id,   subinventory) rd,
 (select transaction_id,sum(quantity) quantity from
 (select rcv.transaction_id transaction_id,sum(rcv.quantity) quantity from apps.rcv_transactions rcv 
 where rcv.transaction_type in ('RECEIVE', 'MATCH')
 group by rcv.transaction_id    
 union all
 select r1.parent_transaction_id transaction_id,sum(r1.quantity) from apps.rcv_transactions r1,apps.rcv_transactions r2
 where r1.parent_transaction_id=r2.transaction_id
 and r1.shipment_header_id=r2.shipment_header_id
 and r1.shipment_line_id=r2.shipment_line_id
 and r1.transaction_type ='CORRECT'
 and r2.transaction_type IN ('RECEIVE', 'MATCH')
 group by r1.parent_transaction_id)
 group by transaction_id having sum(quantity)>0) rt1,
 (select shipment_header_id,shipment_line_id,transaction_id,sum(quantity)quantity from rcv_transactions 
 where transaction_type  ='RETURN TO VENDOR' group by shipment_header_id,transaction_id,shipment_line_id) RR,
 apps.mtl_system_items_b msi,
 apps.mtl_units_of_measure_tl muom,
 apps.po_line_locations_all pll,
 (SELECT                                         --rsh.ship_to_org_id,
                 --  isha.ship_num,
                 rsh.shipment_header_id, shipped_date AS ship_date
            FROM rcv_shipment_headers rsh)ash,---Ashraful
  (select po_number, lc_number, lc_opening_date,bank_name from xx_lc_details lc where lc_status='Y') lc
 where rsh.shipment_header_id = rsl.shipment_header_id
   and rsh.shipment_header_id=Ash.shipment_header_id(+) 
   and rsl.po_header_id = poh.po_header_id(+)
   and rsl.po_line_id = pol.po_line_id(+)
   and poh.segment1=lc.po_number(+)
   and sup.vendor_id = sus.vendor_id
   and rsh.vendor_id(+) = sup.vendor_id
   and rt.vendor_site_id = sus.vendor_site_id(+)
   and rsl.to_organization_id = ood.organization_id
   and rsl.shipment_header_id = rt.shipment_header_id
   and rsl.shipment_line_id = rt.shipment_line_id
   and rt.transaction_type IN ('RECEIVE', 'MATCH')
   and rt.transaction_id=rt1.transaction_id(+)
   and rsl.shipment_header_id = rd.shipment_header_id(+)
   and rsl.shipment_line_id = rd.shipment_line_id(+)
   and rsl.item_id = msi.inventory_item_id
   and msi.organization_id = rsl.to_organization_id
   and rsl.unit_of_measure = muom.unit_of_measure
   and rsl.po_line_location_id = pll.line_location_id(+)
   and rsh.shipment_header_id=rr.shipment_header_id(+)
--   and rt.transaction_id=rr.transaction_id(+)
   and rt.shipment_line_id=rr.shipment_line_id(+)
   and rsl.to_organization_id=:p_organization_id
   and rsh.shipment_header_id between nvl(:p_grn_f,rsh.shipment_header_id) and  nvl(:p_grn_t,rsh.shipment_header_id)
   group by 
rsh.shipment_header_id,
-- rt.transaction_id,
rt.transaction_date,
 poh.segment1,
  lc.lc_number,
 poh.approved_Date, 
 sup.vendor_name,
 sup.segment1, 
 sus.vendor_site_code,
 rsh.receipt_num ,
 rsh.attribute3,
 rsh.creation_date,
 rsh.COMMENTS ,
 rsh.shipment_num ,
 ash.ship_date,
 ood.organization_code,
 ood.organization_name, 
 rsl.to_organization_id,
 rd.subinventory  ,
 msi.segment1 ,
 rsl.item_description ,
 muom.uom_code  
 union all
 select 
 rsh.shipment_header_id,
 rsh.creation_date  transaction_date,
 pha.segment1 po_number,
 null  lc_number,
 pha.approved_Date,
 sup.vendor_name,
 sup.segment1 vendor_id, 
 sus.vendor_site_code,
 rsh.receipt_num grn_no,
 rsh.attribute3,
 rsh.creation_date,
 rsh.comments remarks,
 rsh.shipment_num Shipment_Number,
 null ship_date,
 ood.organization_code,
 ood.organization_name, 
 rsl.to_organization_id Organization_id,
 null to_subinventory ,
 'NA'   item_code,
 rsl.item_description ,
 rsl.unit_of_measure uom,
 pll.quantity_received rcv_qty ,
 pll.quantity_received Ins_qty,   
 pll.quantity_received del_qty,
 null acctual_qty
from 
rcv_shipment_headers rsh,
rcv_shipment_lines rsl,
po_headers_all pha,
po_lines_all pla,
po_line_locations_all  pll,
org_organization_definitions ood,
ap_suppliers sup,
ap_supplier_sites_all sus
where 
rsh.shipment_header_id=rsl.shipment_header_id
and pha.po_header_id=rsl.po_header_id
and pha.po_header_id=pla.po_header_id
and rsl.po_line_id=pla.po_line_id
and pha.po_header_id=pll.po_header_id
and pla.po_line_id=pll.po_line_id
and pll.po_line_id=rsl.po_line_id
and rsl.to_organization_id =ood.organization_id
and pha.vendor_id=sup.vendor_id
and sup.vendor_id = sus.vendor_id
and rsl.item_id is null
and pll.quantity_received <>0
--and receipt_num='10324200129'
and rsl.to_organization_id=:p_organization_id
and rsh.shipment_header_id between nvl(:p_grn_f,rsh.shipment_header_id) and  nvl(:p_grn_t,rsh.shipment_header_id)
group by
 rsh.shipment_header_id,
 rsh.creation_date ,
 pha.segment1 ,
 pha.approved_Date,
 sup.vendor_name,
 sup.segment1 , 
 sus.vendor_site_code,
 rsh.receipt_num ,
 rsh.attribute3,
 rsh.creation_date,
 rsh.comments ,
 rsh.shipment_num ,
 ood.organization_code,
 ood.organization_name, 
 rsl.to_organization_id ,
 rsl.item_description ,
 rsl.unit_of_measure ,
 pll.quantity_received  ,
 pll.quantity_received ,   
 pll.quantity_received 