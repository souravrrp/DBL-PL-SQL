/* Formatted on 8/23/2021 12:14:58 PM (QP5 v5.354) */
  SELECT DISTINCT
         POH.ORG_ID,
         APPS.XX_COM_PKG.GET_HR_OPERATING_UNIT (POH.ORG_ID)
             UNIT_NAME,
         POH.SEGMENT1
             PO_NUM,
         PHA.REVISION_NUM,
         POL.LINE_NUM
             PO_LINE_NUM,
         POL.ITEM_DESCRIPTION,
         PLH.UNIT_MEAS_LOOKUP_CODE
             UOM,
         PLH.LIST_PRICE_PER_UNIT,
         PLH.QUANTITY
             PO_LINE_QUANTITY,
         POH.CREATION_DATE,
         PHA.REVISED_DATE,
         APPS.XX_COM_PKG.GET_EMP_NAME_FROM_USER_ID (PHA.LAST_UPDATED_BY)
             UPDATED_BY,
         POH.TYPE_LOOKUP_CODE||' PO'
             REMARKS
    FROM PO_HEADERS_ALL                    POH,
         PO_LINES_ALL                      POL,
         PO_HEADERS_ARCHIVE_ALL            PHA,
         PO_LINES_ARCHIVE_ALL              PLH,
         APPS.PO_LINE_LOCATIONS_ARCHIVE_ALL PLLA,
         PO_LINE_LOCATIONS_ALL             PLL,
         PO_DISTRIBUTIONS_ARCHIVE_ALL      PDAA,
         PO_DISTRIBUTIONS_ALL              PDA
   --        GL_CODE_COMBINATIONS_KFV GCC
   WHERE     POH.PO_HEADER_ID = POL.PO_HEADER_ID
         AND POH.PO_HEADER_ID = PHA.PO_HEADER_ID
         AND PHA.PO_HEADER_ID = PLH.PO_HEADER_ID
         AND POL.PO_LINE_ID = PLH.PO_LINE_ID
         AND POL.PO_HEADER_ID = PLLA.PO_HEADER_ID
         AND POL.PO_LINE_ID = PLLA.PO_LINE_ID
         AND POL.PO_LINE_ID = PLL.PO_LINE_ID
         AND POL.PO_LINE_ID = PDAA.PO_LINE_ID
         AND PDA.PO_LINE_ID = PDAA.PO_LINE_ID
         AND PDA.PO_DISTRIBUTION_ID = PDAA.PO_DISTRIBUTION_ID
         --AND     PDA.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
         --AND POH.SEGMENT1 = '10233006955'
         AND TO_CHAR (PHA.REVISED_DATE, 'MON-RRRR') = 'AUG-2021'
         AND PHA.REVISION_NUM >0
         AND PHA.VENDOR_ID = '2550'
         AND (PLH.CANCEL_FLAG IS NULL OR PLH.CANCEL_FLAG = 'N')
GROUP BY POH.ORG_ID,
         POH.SEGMENT1,
         POL.LINE_NUM,
         PHA.REVISION_NUM,
         PHA.REVISED_DATE,
         POH.CREATION_DATE,
         POH.TYPE_LOOKUP_CODE,
         POL.ITEM_DESCRIPTION,
         PLH.UNIT_MEAS_LOOKUP_CODE,
         PLH.LIST_PRICE_PER_UNIT,
         PLH.QUANTITY,
         PHA.LAST_UPDATED_BY
         HAVING MAX(PHA.REVISION_NUM) =PHA.REVISION_NUM
ORDER BY PHA.REVISED_DATE DESC,POH.SEGMENT1, POL.LINE_NUM ASC;

--------------------------------------------------------------------------------
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