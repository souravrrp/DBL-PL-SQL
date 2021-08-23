select  distinct
         poh.po_header_id,
         poh.segment1 po_num,
         pol.line_num,
         pha.revision_num,
         pha.REVISED_DATE,
         poh.creation_date,
         poh.TYPE_LOOKUP_CODE po_type,
         decode(plh.amount,pol.amount,null,plh.amount) from_unit_price,
         decode(pol.amount,plh.amount,null,pol.amount) to_unit_price,
         decode(plh.RETAINAGE_RATE,pol.RETAINAGE_RATE,null,plh.RETAINAGE_RATE) from_RETAINAGE_RATE,
         decode(pol.RETAINAGE_RATE,plh.RETAINAGE_RATE,null,pol.RETAINAGE_RATE) to_RETAINAGE_RATE,
         decode(plh.RECOUPMENT_RATE,pol.RECOUPMENT_RATE,null,plh.RECOUPMENT_RATE) from_RECOUPMENT_RATE,
         decode(pol.RECOUPMENT_RATE,plh.RECOUPMENT_RATE,null,pol.RECOUPMENT_RATE) to_RECOUPMENT_RATE,
         decode(plla.NEED_BY_DATE,pll.NEED_BY_DATE,null,plla.NEED_BY_DATE)from_NEED_BY_DATE,
         decode(pll.NEED_BY_DATE,plla.NEED_BY_DATE,null,pll.NEED_BY_DATE)to_NEED_BY_DATE,
         decode((select sum(amount) from po_lines_archive_all where po_header_id=poh.po_header_id),
             (select sum(amount) from po_lines_all where po_header_id=poh.po_header_id),null,
             (select sum(amount) from po_lines_archive_all where po_header_id=poh.po_header_id))Total_amount_changed_from,
         decode((select sum(amount) from po_lines_all where po_header_id=poh.po_header_id),
         (select sum(amount) from po_lines_archive_all where po_header_id=poh.po_header_id),null,
         (select sum(amount) from po_lines_all where po_header_id=poh.po_header_id))total_amount_changed_to,
         decode((select CONCATENATED_SEGMENTS from gl_code_combinations_kfv where CODE_COMBINATION_ID = pda.CODE_COMBINATION_ID),
         (select CONCATENATED_SEGMENTS from gl_code_combinations_kfv where CODE_COMBINATION_ID = pdaa.CODE_COMBINATION_ID),null,
         (select CONCATENATED_SEGMENTS from gl_code_combinations_kfv where CODE_COMBINATION_ID = pda.CODE_COMBINATION_ID))from_charge_account,
         decode((select CONCATENATED_SEGMENTS from gl_code_combinations_kfv where CODE_COMBINATION_ID = pdaa.CODE_COMBINATION_ID),
         (select CONCATENATED_SEGMENTS from gl_code_combinations_kfv where CODE_COMBINATION_ID = pda.CODE_COMBINATION_ID),null,
         (select CONCATENATED_SEGMENTS from gl_code_combinations_kfv where CODE_COMBINATION_ID = pdaa.CODE_COMBINATION_ID))to_charge_account,
         pol.item_description
 from    po_headers_all poh,
         po_lines_All pol,
         PO_HEADERS_ARCHIVE_ALL pha,
         po_lines_archive_all plh,
         apps.po_line_locations_archive_all plla,
         po_line_locations_all pll,
         po_distributions_archive_all pdaa,
         po_distributions_all pda
 --        gl_code_combinations_kfv gcc
 where   poh.po_header_id = pol.po_header_id
 and     poh.po_header_id = pha.po_header_id
 and     pha.PO_HEADER_ID = plh.PO_HEADER_ID
 and     pol.PO_LINE_ID = plh.PO_LINE_ID
 and     pol.PO_HEADER_ID = plla.PO_HEADER_ID
 and     pol.PO_LINE_ID = plla.PO_LINE_ID
 and     pol.PO_LINE_ID = pll.PO_LINE_ID
 and     pol.PO_LINE_ID = pdaa.PO_LINE_ID
 and     pda.PO_LINE_ID = pdaa.PO_LINE_ID
 and     pda.PO_DISTRIBUTION_ID = pdaa.PO_DISTRIBUTION_ID
 --and     pda.CODE_COMBINATION_ID = gcc.CODE_COMBINATION_ID
 and     poh.segment1='10523015504'
 --and     pha.revision_num = 1
 order by poh.segment1,pol.line_num,pha.revision_num;