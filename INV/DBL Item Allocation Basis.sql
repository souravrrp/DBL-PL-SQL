/* Formatted on 12/15/2021 9:29:29 AM (QP5 v5.374) */
SELECT ood.organization_code,
       a.inventory_item_id,
       a.segment1       AS item_code,
       a.description,
       t.long_description,
       b.segment1       "product_line",
       b.segment2       "article",
       b.segment3       "color_group",
       b.segment4       "item_type",
       a.attribute5     h_s_code,
       a.creation_date
  FROM apps.mtl_system_items_b_kfv        a,
       inv.mtl_system_items_tl            t,
       apps.mtl_item_categories_v         b,
       apps.org_organization_definitions  ood,
       apps.gl_code_combinations_kfv      cc,
       apps.mtl_parameters                mp,
       applsys.fnd_user                   fnu,
       (SELECT q1.*, haou.name
          FROM hr.per_all_people_f           q1,
               hr.per_all_assignments_f      paaf,
               hr.hr_all_organization_units  haou
         WHERE     SYSDATE BETWEEN q1.effective_start_date
                               AND q1.effective_end_date
               AND SYSDATE BETWEEN paaf.effective_start_date
                               AND paaf.effective_end_date
               AND q1.person_id = paaf.person_id
               AND paaf.organization_id = haou.organization_id) pp
 WHERE     a.inventory_item_id = b.inventory_item_id
       AND a.organization_id = b.organization_id
       AND a.organization_id = ood.organization_id
       AND a.expense_account = cc.code_combination_id
       AND mp.organization_id = a.organization_id
       AND a.created_by = fnu.user_id
       AND a.inventory_item_id = t.inventory_item_id
       AND a.organization_id = t.organization_id
       AND pp.party_id(+) = NVL (fnu.person_party_id, 0)
       AND inventory_item_status_code = 'Active'
       AND category_set_id = 1
       --AND b.segment1 || b.segment2 || b.segment3 || b.segment4='NANANANA'
       --AND mp.process_enabled_flag = 'Y'
       --AND item_type =
       --AND set_of_books_id = '2095'
       --AND mp.organization_code='193'
       --AND a.creation_date like '%10%oct%'
       AND a.organization_id = 150
       AND b.segment2 = 'FINISH GOODS'
       AND b.segment3 = 'DYED YARN' -- not in ('DYED FIBER','SEWING THREAD','DYED YARN')  --DYED FIBER    --SEWING THREAD    --DYED YARN
/*AND a.segment1 LIKE 'RIBON000000000000079'
       AND process_yield_subinventory IS NULL
       AND NOT EXISTS
               (SELECT 1
                  FROM gl_aloc_bas                x,
                       apps.mtl_system_items_kfv  y,
                       gl_aloc_mst                z
                 WHERE     x.inventory_item_id = y.inventory_item_id
                       AND x.organization_id = y.organization_id
                       AND x.organization_id = a.organization_id
                       AND x.alloc_id = z.alloc_id
                       AND (   :p_alloc_code IS NULL
                            OR (alloc_code = UPPER ( :p_alloc_code)))
                       --AND alloc_code not like '%silo'
                       AND x.delete_mark = 0
                       --AND concatenated_segments like 'ft%'
                       AND a.segment1 = y.concatenated_segments)*/;

----------------------------alloc code wise count-------------------------------

  SELECT alloc_code,                       --substr(alloc_code,0,2) item_type,
                     COUNT (concatenated_segments) no_of_segments
    FROM gl_aloc_bas a, apps.mtl_system_items_kfv b, gl_aloc_mst c
   WHERE     a.inventory_item_id = b.inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.organization_id = 150
         AND a.alloc_id = c.alloc_id
         --AND alloc_code not like '%silo'
         --AND concatenated_segments not like 'ft%'
         AND a.delete_mark = 0
GROUP BY alloc_code
--,a.delete_mark
ORDER BY SUBSTR (alloc_code, 0, 2);

  SELECT alloc_code,
         concatenated_segments,
         --substr(alloc_code,0,2) item_type,
         COUNT (concatenated_segments)     no_of_segments
    FROM gl_aloc_bas a, apps.mtl_system_items_kfv b, gl_aloc_mst c
   WHERE     a.inventory_item_id = b.inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.organization_id = 150
         AND a.alloc_id = c.alloc_id
         --AND alloc_code not like '%silo'
         --AND concatenated_segments not like 'ft%'
         AND a.delete_mark = 0
GROUP BY alloc_code, concatenated_segments
--,a.delete_mark
ORDER BY SUBSTR (alloc_code, 0, 2);

--------------------------------------------------------------------------------

SELECT alloc_code, concatenated_segments
  FROM gl_aloc_bas a, apps.mtl_system_items_kfv b, gl_aloc_mst c
 WHERE     a.inventory_item_id = b.inventory_item_id
       AND a.organization_id = b.organization_id
       AND (   ( :p_organization_id IS NULL AND a.organization_id IN (152))
            OR (a.organization_id = :p_organization_id))
       AND a.alloc_id = c.alloc_id
       AND ( :p_alloc_code IS NULL OR (alloc_code = UPPER ( :p_alloc_code)))
       --AND A.ORGANIZATION_ID IN (152)
       --AND ALLOC_CODE IN ('SALARY WAGES-FT-2')
       --AND ALLOC_CODE NOT LIKE '%SILO'
       --AND B.CONCATENATED_SEGMENTS LIKE 'FT%'
       AND a.delete_mark = 0
       AND ( :p_item_code IS NULL OR (b.segment1 = :p_item_code))
       AND (   :p_item_desc IS NULL
            OR (UPPER (b.description) LIKE UPPER ('%' || :p_item_desc || '%')));


--------------------------------------------------------------------------------

  SELECT alloc_code, SUM (a.fixed_percent) basis_value
    FROM gl_aloc_bas a, apps.mtl_system_items_kfv b, gl_aloc_mst c
   WHERE     a.inventory_item_id = b.inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.alloc_id = c.alloc_id
         --AND ALLOC_CODE LIKE 'ST-DEPRECIATION%'
         --AND alloc_code like 'ST%'
         AND (   ( :p_organization_id IS NULL AND a.organization_id IN (150))
              OR (a.organization_id = :p_organization_id))
GROUP BY alloc_code;

-----------------------------------------------------------------------------


  SELECT alloc_code,
         concatenated_segments,
         COUNT (concatenated_segments)     no_of_segments
    FROM gl_aloc_bas a, apps.mtl_system_items_kfv b, gl_aloc_mst c
   WHERE     a.inventory_item_id = b.inventory_item_id
         AND a.organization_id = b.organization_id
         AND a.organization_id = 150
         AND a.alloc_id = c.alloc_id
         --AND alloc_code = :p_alloc_code
         --AND alloc_code like 'ft%'
         --AND concatenated_segments like 'ft%'
         AND a.delete_mark = 0
GROUP BY alloc_code, concatenated_segments
  HAVING COUNT (concatenated_segments) > 1
ORDER BY alloc_code
--SUBSTR (alloc_code, 0, 2)
;
--------------------------------------------------------------------------------

SELECT *
  FROM gl_aloc_bas a
 WHERE     a.delete_mark = 1
       AND EXISTS
               (SELECT 1
                  FROM apps.mtl_system_items_kfv b, gl_aloc_mst c
                 WHERE     a.inventory_item_id = b.inventory_item_id
                       AND a.organization_id = b.organization_id
                       AND a.organization_id = 150
                       AND a.alloc_id = c.alloc_id)