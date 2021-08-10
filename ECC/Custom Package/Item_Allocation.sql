/* Formatted on 5/5/2020 3:33:22 PM (QP5 v5.287) */
SELECT ood.organization_code,
       a.inventory_item_id,
       a.segment1 AS item_code,
       a.description,
       t.long_description,
       b.segment1 "product_line",
       b.segment2 "article",
       b.segment3 "color_group",
       b.segment4 "item_type",
       a.attribute5 h_s_code,
       a.creation_date
  FROM apps.mtl_system_items_b_kfv a,
       inv.mtl_system_items_tl t,
       apps.mtl_item_categories_v b,
       apps.org_organization_definitions ood,
       apps.gl_code_combinations_kfv cc,
       apps.mtl_parameters mp,
       applsys.fnd_user fnu,
       (SELECT q1.*, haou.name
          FROM hr.per_all_people_f q1,
               hr.per_all_assignments_f paaf,
               hr.hr_all_organization_units haou
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
       AND a.organization_id = 150
       AND b.segment2 = 'FINISH GOODS'
       AND b.segment3 IN ('DYED FIBER', 'SEWING THREAD', 'DYED YARN');



SELECT ALLOC_CODE, CONCATENATED_SEGMENTS
  FROM GL_ALOC_BAS A, APPS.MTL_SYSTEM_ITEMS_KFV B, GL_ALOC_MST C
 WHERE     A.INVENTORY_ITEM_ID = B.INVENTORY_ITEM_ID
       AND A.ORGANIZATION_ID = B.ORGANIZATION_ID
       AND A.ALLOC_ID = C.ALLOC_ID
       AND A.DELETE_MARK = 0