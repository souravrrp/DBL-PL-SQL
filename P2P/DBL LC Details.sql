/* Formatted on 11/14/2020 10:01:37 AM (QP5 v5.287) */
SELECT 'Master LC' LC_TYPE,
       lc.org_id,
       --led.UNIT_NAME OU_Name,
       led.legal_entity_id,
       led.legal_entity_name,
       led.LEDGER_ID,
       TO_CHAR (lc.lc_number) lc_no,
       TO_CHAR (lc.LC_OPENING_DATE) LC_OPENING_DATE
  --, LC.*
  FROM apps.po_headers_all pha,
       xx_lc_details lc,
       apps.xxdbl_company_le_mapping_v led
 WHERE     1 = 1
       AND ( :p_lc_number IS NULL OR lc.lc_number = :p_lc_number)
       AND ( :p_po_number IS NULL OR pha.segment1 = :p_po_number)
       --AND lc.legal_entity_id IN ( '23280')
       --AND lc_number IN ( 'DCDAK880769')
       AND pha.org_id = led.org_id(+)
       AND lc.po_header_id = pha.po_header_id(+)
       AND lc.po_number = pha.segment1(+)
UNION ALL
SELECT 'B2B LC' LC_TYPE,
       b2b.org_id,
       led.legal_entity_id,
       led.legal_entity_name,
       led.LEDGER_ID,
       TO_CHAR (b2b.btb_lc_no) lc_no,
       TO_CHAR (b2b.CREATION_DATE) LC_OPENING_DATE
  --, b2b.*
  --,b2b2.*
  FROM apps.po_headers_all pha,
       xxdbl.xx_explc_btb_req_link b2b,
       xxdbl.xx_explc_btb_mst b2b2,
       apps.xxdbl_company_le_mapping_v led
 WHERE     1 = 1
       AND b2b.btb_lc_no = b2b2.btb_lc_no(+)
       AND ( :p_lc_number IS NULL OR TO_CHAR (b2b.btb_lc_no) = :p_lc_number)
       AND ( :p_po_number IS NULL OR pha.segment1 = :p_po_number)
       --AND led.legal_entity_id IN ( '23280')
       --AND b2b.btb_lc_noIN ( 'DCDAK880769')
       AND b2b.po_header_id = pha.po_header_id(+)
       AND b2b.po_number = pha.segment1(+);


--------------------------------------------------------------------------------

  SELECT *
    FROM xx_lc_details
   WHERE 1 = 1 AND lc_number = 'DPCDAK211710'
ORDER BY creation_date DESC