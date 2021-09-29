CREATE OR REPLACE function APPS.GET_BULK_PRO_LOT_IN_ING(P_BATCH_ID IN NUMBER) return NVARCHAR2 is

v_lot NVARCHAR2(10); 
 begin
 SELECT
                LOT_NUMBER into v_lot
                
                FROM( 
                            SELECT gbh.BATCH_ID,
                            gbh.batch_no,
                          mtlot.LOT_NUMBER,
                          itm.DESCRIPTION PROD_DESCRIPTION,
                          ITM.ITEM_TYPE,
                          itm.PRIMARY_UOM_CODE,
                          ROUND (
                             NVL ( (DECODE (gmd.line_type, 1, gmd.actual_qty)),
                                  0),
                             5)
                             AS Actual_Products,
                          gbh.actual_start_date,
                          gbh.ACTUAL_CMPLT_DATE
                           FROM mtl_material_transactions mmt,
                          gme_material_details gmd,
                          gme_batch_header gbh,
                          org_organization_definitions ood,
                          apps.MTL_SYSTEM_ITEMS_FVL itm,
                          apps.mtl_item_categories_v cat,
                          mtl_transaction_lot_numbers mtlot,
                          APPS.fm_form_mst F
                    WHERE     mmt.transaction_source_type_id = 5
                          AND ood.organization_id = 158
                          AND gbh.organization_id = ood.organization_id
                          AND gbh.organization_id = itm.organization_id
                          AND gbh.organization_id = cat.organization_id
                          AND gmd.INVENTORY_ITEM_ID = itm.INVENTORY_ITEM_ID
                          AND itm.INVENTORY_ITEM_ID = cat.INVENTORY_ITEM_ID
                          AND gmd.INVENTORY_ITEM_ID = cat.INVENTORY_ITEM_ID
                          AND cat.CATEGORY_SET_NAME = 'Inventory'
                          AND mmt.trx_source_line_id = gmd.material_detail_id
                          AND mmt.transaction_source_id = gbh.batch_id
                          AND gbh.Formula_ID = F.Formula_ID
                          AND F.FORMULA_CLASS = 'BULK'
                          AND cat.SEGMENT3='BULK'
                         --AND ITM.ITEM_TYPE='BULK'
                          AND mtlot.transaction_id = mmt.TRANSACTION_ID
                          AND gmd.batch_id = gbh.batch_id
                          AND gmd.batch_id =NVL(P_BATCH_ID,gmd.batch_id)
                           )
                           WHERE Actual_Products !=0;
                           --AND  LOT_NUMBER='AE0001'

            return v_lot;
 END;
                        -- SELECT APPS.GET_BULK_PRO_LOT_IN_ING(:P_BATCH_ID) FROM DUAL;--638327
/
