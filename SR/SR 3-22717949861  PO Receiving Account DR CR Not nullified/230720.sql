select receipt_side.rcv_transaction_id receipt_txn,
deliver_side.rcv_transaction_id deliver_txn,
rct.po_line_location_id line_loc_id,
rct.po_header_id po_header_id,
receipt_side.rcv_val,
deliver_side.del_val,
receipt_side.rcv_qty,
deliver_side.del_qty,
receipt_side.rcv_ratio,
deliver_side.del_ratio
from
( select rct.transaction_id rcv_transaction_id,
rct.primary_quantity rcv_qty,
sum(nvl(accounted_dr,0) - nvl(accounted_cr,0)) rcv_val,
abs(sum(nvl(accounted_dr,0) -
nvl(accounted_cr,0))/rct.primary_quantity) rcv_ratio
from rcv_receiving_sub_ledger rrsl,
rcv_transactions rct
where rct.organization_id = &&organization_id
and rrsl.rcv_transaction_id = rct.transaction_id
and rrsl.code_combination_id = &&recv_insp_account_id
group by rct.transaction_id,
rct.primary_quantity
) Receipt_side,
( select mmt.rcv_transaction_id,
mmt.primary_quantity del_qty,
sum(nvl(mta.base_transaction_value,0)) del_val,
abs(sum(nvl(mta.base_transaction_value,0))/mmt.primary_quantity) del_ratio
from mtl_transaction_accounts mta,
mtl_material_transactions mmt,
mtl_parameters mp
where mmt.organization_id = mp.cost_organization_id
and mp.organization_id =&&organization_id
and mmt.transaction_id = mta.transaction_id
and mta.reference_account = &&recv_insp_account_id
and mmt.transaction_source_type_id = 1
and mmt.transaction_action_id in (27,1,29)
and mta.organization_id = mmt.organization_id
and mta.accounting_line_type = 5
group by mmt.rcv_transaction_id,
mmt.primary_quantity
) Deliver_side,
rcv_transactions rct
where receipt_side.rcv_transaction_id in ( select rcth.transaction_id
from rcv_transactions rcth
where rcth.organization_id = &&organization_id
and rcth.transaction_type in ('RECEIVE','MATCH')
START WITH rcth.transaction_id = deliver_side.rcv_transaction_id
CONNECT BY rcth.transaction_id = prior rcth.parent_transaction_id
)
and rct.transaction_id = receipt_side.rcv_transaction_id
and receipt_side.rcv_ratio <> deliver_side.del_ratio;

select rrsl.rcv_transaction_id txn,
rt.ttype,
rt.po_line_location_id,
rt.sd_qty,
rt.po_pr,
rt.rt_pr,
rt.rt_rate,
rt.mo,
rt.po_rate,
rt.po_header_id,
abs(round(nvl(rrsl.accounted_dr,0)- nvl(rrsl.accounted_cr,0)))
rrsl_val,
rrsl.accounted_dr rrs_dr,
rrsl.accounted_cr rrs_cr,
rrsl.accounted_nr_tax rrs_tax,
rt.tax,
rt.value_rt,
rt.value_po
from (select rct.transaction_id,
rct.transaction_type ttype,
rct.po_line_location_id,
poll.price_override po_pr,
rct.po_unit_price rt_pr,
rct.source_doc_quantity sd_qty,
nvl(rct.currency_conversion_rate,1) rt_rate,
poll.match_option mo,
nvl(poh.rate,1) po_rate,
poh.po_header_id po_header_id,
temp_po_tax(rct.transaction_id) tax,
sum(rct.source_doc_quantity *
(rct.po_unit_price + temp_po_tax(rct.transaction_id)) *
nvl(rct.currency_conversion_rate,1)
) value_rt,
sum(rct.source_doc_quantity *
(poll.price_override+temp_po_tax(rct.transaction_id)) *
nvl(rct.currency_conversion_rate,1)
) value_po
from rcv_transactions rct,
po_line_locations_all poll,
po_headers_all poh
where rct.po_line_location_id = poll.line_location_id
and rct.transaction_type in ( 'RECEIVE','MATCH','RETURN TO
VENDOR','CORRECT')
and not (rct.transaction_type = 'CORRECT'
and (rct.destination_type_code = 'INVENTORY'
or rct.destination_type_code = 'SHOP FLOOR')
)
and rct.organization_id = &&organization_id
and poh.po_header_id = poll.po_header_id
and exists ( select 'X'
from po_distributions_all pod
where pod.line_location_id = poll.line_location_id
and pod.destination_organization_id = &&organization_id
and pod.accrue_on_receipt_flag = 'Y'
)
group by rct.transaction_id,
rct.transaction_type,
rct.po_line_location_id,
poll.price_override ,
rct.po_unit_price,
rct.source_doc_quantity ,
nvl(rct.currency_conversion_rate,1),
poll.match_option ,
nvl(poh.rate,1),
poh.po_header_id,
temp_po_tax(rct.transaction_id)) rt,
( select rrsl2.rcv_transaction_id,
rrsl2.code_combination_id,
sum(nvl(rrsl2.accounted_cr,0)) accounted_cr,
sum(nvl(rrsl2.accounted_dr,0)) accounted_dr,
sum(nvl(rrsl2.accounted_nr_tax,0)) accounted_nr_tax
from rcv_receiving_sub_ledger rrsl2
where rrsl2.code_combination_id = &&recv_insp_account_id
and rrsl2.rcv_transaction_id <> 0
and rrsl2.actual_flag = 'A'
group by rrsl2.rcv_transaction_id,
rrsl2.code_combination_id
) rrsl
where rrsl.code_combination_id = &&recv_insp_account_id
and rrsl.rcv_transaction_id = rt.transaction_id
and ( abs(round(rt.value_rt)) <>
abs(round(nvl(rrsl.accounted_dr,0)- nvl(rrsl.accounted_cr,0)))
or abs(round(rt.value_po))<>
abs(round(nvl(rrsl.accounted_dr,0)- nvl(rrsl.accounted_cr,0)))
);