select
 hu.legal_entity_name unit_name,
 pha.segment1 "PO Number",
 pla.line_num,
 pha.po_header_id,
 pha.org_id,
 pha.authorization_status,
 pha.creation_date,
 pha.approved_date,
 pha.currency_code,
 sup.vendor_name,
 sups.vendor_site_code,
 pll.ship_to_organization_id,
  decode(pha.attribute_category,'STANDARD',pha.attribute13,pha.attribute13) buyer_id,
 sysdate,
 loc.address_line_1||' '||loc.address_line_2||' '||loc.address_line_3||' '||loc.region_1||' '||loc.region_2||' '||loc.region_3||' '||loc.town_or_city||' '||'Bangladesh' location,
 msi.segment1 "Item Code",
 substr(msi.description,6,500) ||' '||pla.note_to_vendor description,
 substr(msi.description,1,4) "Yarn Count",
 substr (to_char(sysdate ,'DD-MON-YYYY'),8,11 ) "Year",
 'MSML'||'/'||hu.unit_name||'/'||substr (to_char(sysdate ,'DD-MON-YYYY'),8,11 )||'/'||nvl(pi.fucn1,0) "PI Number",
 pla.unit_meas_lookup_code uom,
 pll.quantity,
 pla.unit_price,
 pll.quantity*pla.unit_price total_amount,
-- :bank
 case  :bank
 when 'HSBC Limited' then 'HSBC Limited, Global Trade and receivable finance transaction services. Level-12, Shanta western tower, 186 Bir Uttam Mir Shawkat Ali road, Tejgoan, I/A, Dhaka-1208.'
 when 'The City Bank Limited' then 'The City Bank Limited , Trade Service Division, Al Amin Center,7th Floor, 25/1 Dilkusha C/A, Dhaka-100'
 when 'BRACK Bank Limited' then 'BRACK Bank Ltd., Anik Tower,220/B,Tejgoan Link Road, Gulshan-01, Dhaka-1208' 
 else
 null
 end Bank_address,
 case :bank
 when 'HSBC Limited' then 'HSBCBDDH'
 when 'The City Bank Limited' then 'CIBLBDDHXX'
 when 'BRACK Bank Limited' then 'BRAKBDDHXX' 
 else
 'No Swift Code Selected'
 end Swift,
 :Tenor_number||' '||'Days'  Tenor,
 :at_shight shight,
 :p_revised Revised_name,
 :p_max_number MAX
from
 apps.po_headers_all pha,
 apps.ap_suppliers sup,
 apps.ap_supplier_sites_all sups,
 apps.po_lines_all pla,
 apps.po_line_locations_all pll,
 apps.mtl_system_items_b msi,
 apps.hr_organization_units hou,
 apps.xxdbl_company_le_mapping_v hu,
 apps.hr_locations_all_v loc,
 apps.xx_dbl_po_recv_adjust pi
  where 
       pha.po_header_id=pla.po_header_id
 and pha.org_id=hu.org_id
 and pha.org_id=pla.org_id
 and pha.vendor_id=sup.vendor_id
 and sup.vendor_id=sups.vendor_id
 and pha.vendor_site_id=sups.vendor_site_id(+)
 and pha.po_header_id=pll.po_header_id
 and pla.po_line_id=pll.po_line_id
 and pla.item_id=msi.inventory_item_id(+)
 and pll.ship_to_organization_id=msi.organization_id(+)
 and pll.ship_to_organization_id=hou.organization_id(+)
 and hou.location_id=loc.location_id(+)
 and pha.segment1=pi.po_no(+)
 and nvl(pll.cancel_flag,'N')='N'
 and pll.cancel_date is null
-- and pha.org_id=:p_org
 and pha.segment1=:p_po_number
 order by pla.line_num