/* Formatted on 2/26/2020 2:07:53 PM (QP5 v5.287) */
  SELECT b.RECIPE_DESCRIPTION,
         a.RECIPE_VALIDITY_RULE_ID,
         c.INVENTORY_ITEM_ID,
         d.SEGMENT1 ITEM_CODE,
         d.description,
         DECODE (c.line_type, -1, 'Ingredient', 'Product') TYPE,
         SUM (e.TRANSACTION_QUANTITY) quantity
    FROM apps.GME_BATCH_HEADER a,
         apps.gmd_recipes b,
         gmd_recipe_validity_rules grr,
         apps.gme_material_details c,
         apps.mtl_system_items d,
         apps.mtl_material_transactions e
   WHERE     a.FORMULA_ID = b.FORMULA_ID
         AND a.ROUTING_ID = b.ROUTING_ID
         AND a.RECIPE_VALIDITY_RULE_ID = grr.RECIPE_VALIDITY_RULE_ID
         AND grr.RECIPE_ID = b.recipe_id
         AND a.BATCH_ID = c.BATCH_ID
         AND a.ORGANIZATION_ID = c.ORGANIZATION_ID
         AND c.INVENTORY_ITEM_ID = d.INVENTORY_ITEM_ID
         AND c.ORGANIZATION_ID = d.organization_id
         AND a.batch_id = e.TRANSACTION_SOURCE_ID
         AND a.ORGANIZATION_ID = e.ORGANIZATION_ID
         AND c.INVENTORY_ITEM_ID = e.INVENTORY_ITEM_ID
         AND a.batch_no IN ('68061') --(SELECT batch_no FROM apps.GME_BATCH_HEADER WHERE TRUNC (plan_start_date) BETWEEN :from_date AND :TO_DATE)
--AND a.ORGANIZATION_ID = :your_org_id
--AND TRUNC (e.transaction_date) BETWEEN :from_date AND :TO_DATE
GROUP BY b.RECIPE_DESCRIPTION,
         a.RECIPE_VALIDITY_RULE_ID,
         c.INVENTORY_ITEM_ID,
         d.SEGMENT1,
         d.description,
         c.line_type
ORDER BY RECIPE_DESCRIPTION