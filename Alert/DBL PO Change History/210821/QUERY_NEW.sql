/* Formatted on 8/23/2021 12:14:58 PM (QP5 v5.354) */
  SELECT DISTINCT poh.po_header_id,
                  poh.segment1             po_num,
                  pol.line_num,
                  --pha.revision_num,
                  pha.REVISED_DATE,
                  poh.creation_date,
                  poh.TYPE_LOOKUP_CODE     po_type,
                  pol.item_description
    FROM po_headers_all                    poh,
         po_lines_All                      pol,
         PO_HEADERS_ARCHIVE_ALL            pha,
         po_lines_archive_all              plh,
         apps.po_line_locations_archive_all plla,
         po_line_locations_all             pll,
         po_distributions_archive_all      pdaa,
         po_distributions_all              pda
   --        gl_code_combinations_kfv gcc
   WHERE     poh.po_header_id = pol.po_header_id
         AND poh.po_header_id = pha.po_header_id
         AND pha.PO_HEADER_ID = plh.PO_HEADER_ID
         AND pol.PO_LINE_ID = plh.PO_LINE_ID
         AND pol.PO_HEADER_ID = plla.PO_HEADER_ID
         AND pol.PO_LINE_ID = plla.PO_LINE_ID
         AND pol.PO_LINE_ID = pll.PO_LINE_ID
         AND pol.PO_LINE_ID = pdaa.PO_LINE_ID
         AND pda.PO_LINE_ID = pdaa.PO_LINE_ID
         AND pda.PO_DISTRIBUTION_ID = pdaa.PO_DISTRIBUTION_ID
         --and     pda.CODE_COMBINATION_ID = gcc.CODE_COMBINATION_ID
         AND poh.segment1 = '10523015504'
         AND pha.revision_num = 1
GROUP BY poh.po_header_id,
         poh.segment1,
         pol.line_num,
         --pha.revision_num,
         pha.REVISED_DATE,
         poh.creation_date,
         poh.TYPE_LOOKUP_CODE,
         pol.item_description
ORDER BY poh.segment1, pol.line_num                      --, pha.revision_num;