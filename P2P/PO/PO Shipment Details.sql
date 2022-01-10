select distinct
--        ish.*,
        ish.ship_num,
        ish.ship_header_id,
        ish.organization_id,
        ish.ship_type_id,
        ist.ship_type_code,
        ish.ship_status_code,
        ish.pending_matching_flag,
        hou.name operating_unit,
        isl.poo_organization_id,
        hl.location_code,
        to_char( trunc( ish.ship_date ), 'DD-MON-YYYY') ship_date,
        islg.ship_line_group_num,
        islg.src_type_code,
        hp.party_name,
        hps.party_site_name,
        isl.ship_line_num,
        pha.segment1,
        msi.segment1||'.'||msi.segment2||'.'||msi.segment3 item,
        msi.description,
        isl.txn_qty,
        isl.txn_uom_code,
        isl.txn_unit_price,
        isl.txn_qty*isl.txn_unit_price amount,
        isl.currency_code,
        ima.match_type_code,
        icl.charge_line_num,
        icl.charge_line_type_id,
        ppet.price_element_code,
        ima.matched_amt after_allocation,
        icl.charge_amt before_allocation,
        nvl2(ima.matched_amt,'YES','NO') amount_match_flag
--        ima.match_amount_id
from 
        apps.inl_ship_headers_all ish
        ,apps.inl_ship_lines_all isl
        ,apps.inl_ship_types_b ist
        ,apps.inl_ship_line_groups islg
        ,apps.hr_operating_units hou
        ,apps.hr_locations hl
        ,apps.hz_parties hp
        ,apps.hz_party_sites hps
        ,apps.po_headers_all pha
        ,apps.po_distributions_all pda
        ,apps.mtl_system_items msi
        ,apps.inl_associations ias
        ,apps.inl_charge_lines icl
        ,apps.pon_price_element_types ppet
        ,apps.inl_matches ima
where 1=1
--        and ish.ship_num in (431,432)
--        and ish.ship_header_id=231212
--        and ish.org_id=84
--        and ist.ship_type_code='Imported'
--        and hou.name='SHAH CEMENT OPERATING UNIT'
--        and isl.poo_organization_id=1105
--        and ish.pending_matching_flag!='N'
--        and ppet.price_element_code is not null
--        and pha.segment1 in ('L/RMCOU/006234')
--and hp.party_name='Swift Printers'
--        and ish.ship_date between '01-JAN-2018' and '31-MAR-2018'
        and ish.org_id=hou.organization_id
        and ish.ship_type_id=ist.ship_type_id
        and ish.location_id=hl.location_id
        and ish.ship_header_id=islg.ship_header_id
        and islg.party_id=hp.party_id
        and islg.party_site_id=hps.party_site_id
        and ish.ship_header_id=isl.ship_header_id
        and ish.org_id=isl.org_id
        and isl.ship_line_source_id=pda.line_location_id
        and pda.po_header_id=pha.po_header_id
        and isl.inventory_item_id=msi.inventory_item_id
        and isl.poo_organization_id=msi.organization_id
        and ish.ship_header_id=ias.ship_header_id(+)
        and ias.from_parent_table_id=icl.charge_line_id(+)
        and icl.charge_line_type_id=ppet.price_element_type_id(+)
        and ima.charge_line_type_id(+)=ppet.price_element_type_id
        and icl.charge_line_type_id= ima.charge_line_type_id(+)
        and ish.ship_header_id=ima.ship_header_id(+)
        and ias.ship_header_id=ima.ship_header_id(+)
        and ima.match_id(+)=icl.match_id        /*commit this join to see the unmatched amount*/
        and isl.ship_header_id=ima.ship_header_id(+)
order by ish.ship_num,icl.charge_line_num

select * from apps.inl_ship_headers_all
where ship_header_id='229908'
        