/* Formatted on 1/12/2020 10:18:04 AM (QP5 v5.287) */
  SELECT msib.segment1,
         a.item_id,
         cad.whse_code,
         SUM (cad.ADJUST_COST)
    FROM ic_item_mst_b iimb,
         mtl_system_items_b msib,
         org_organization_definitions ood,
         ic_loct_inv a,
         CM_ADJS_DTL CAD
   WHERE     1 = 1
         --*-- msib.inventory_item_id = cad.item_id*
         AND a.item_id = cad.item_id
         AND iimb.item_no = msib.segment1
         AND a.whse_code = cad.whse_code(+)
         AND a.ITEM_ID(+) = iimb.ITEM_ID
         AND msib.organization_id = OOD.ORGANIZATION_ID
         --AND msib.ORGANIZATION_ID = 106
         --AND iimb.inv_type = NVL (:p_inv_type, iimb.inv_type)
         --AND a.LOCT_ONHAND <> 0
         AND a.LOCT_ONHAND IS NOT NULL
        --AND a.whse_code LIKE NVL (:whse_code, a.whse_code)
        --AND iimb.item_no = NVL (:p_item_no, iimb.item_no) --*--'0101172409'*
        --AND iimb.attribute4 = NVL (:p_attr4, iimb.attribute4)
        --AND a.creation_date LIKE
        --NVL (TRUNC (TO_DATE (:p_trans_date, 'dd/mm/yy')),a.creation_date)
        --AND a.item_id = 14702
        GROUP BY cad.whse_code,
         a.item_id,
         msib.segment1,
         cad.ADJUST_COST
ORDER BY 1