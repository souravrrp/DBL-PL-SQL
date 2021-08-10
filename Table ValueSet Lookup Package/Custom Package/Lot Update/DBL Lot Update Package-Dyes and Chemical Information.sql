/* Formatted on 8/25/2020 4:38:05 PM (QP5 v5.354) */
DECLARE
    v_org    NUMBER;
    v_item   NUMBER;



    CURSOR c1 IS
        SELECT *
          FROM xxdbl.xxdbl_lot_dff_upd
         WHERE sts IS NULL;
BEGIN
    FOR i IN c1
    LOOP
        SELECT Organization_id
          INTO v_org
          FROM org_organization_definitions
         WHERE ORGANIZATION_ID = i.organization_code;


        SELECT inventory_item_id
          INTO v_item
          FROM mtl_system_items_b
         WHERE segment1 = i.item_code AND organization_id = v_org;


        UPDATE mtl_lot_numbers
           SET attribute_category = i.attribute_category,
               attribute2 = TO_CHAR (i.EXPIRY_DATE, 'YYYY/MM/DD'),
               attribute3 = TO_CHAR (i.MANUFACTURING_DATE, 'YYYY/MM/DD')
         WHERE     Organization_id = v_org
               AND inventory_item_id = v_item
               AND lot_number = i.lot_number;



        UPDATE xxdbl.xxdbl_lot_dff_upd
           SET sts = 'Y'
         WHERE     ORGANIZATION_CODE = i.ORGANIZATION_CODE
               AND item_Code = i.item_code;

        COMMIT;
    END LOOP;
END;



SELECT *
  FROM mtl_lot_numbers
 WHERE lot_number IN (SELECT lot_number FROM xxdbl.xxdbl_lot_dff_upd);

SELECT *
  --   INTO v_org
  FROM org_organization_definitions
 WHERE organization_id = 139;

SELECT *
  FROM mtl_lot_numbers
 WHERE Organization_id = 187 AND ORIGINATION_DATE = '30-SEP-2017';


ALTER TABLE xxdbl.xxdbl_lot_dff_upd
    ADD (MANUFACTURING_DATE DATE, EXPIRY_DATE DATE);

ALTER TABLE xxdbl.xxdbl_lot_dff_upd
    MODIFY (MANUFACTURING_DATE VARCHAR2 (50), EXPIRY_DATE VARCHAR2 (50));

ALTER TABLE xxdbl.xxdbl_lot_dff_upd
    MODIFY (MANUFACTURING_DATE DATE, EXPIRY_DATE DATE);

ALTER TABLE xxdbl.xxdbl_lot_dff_upd
    ADD (MANUFACTURING_DATE VARCHAR2 (50), EXPIRY_DATE VARCHAR2 (50));

SELECT *
  FROM XXDBL.XXDBL_LOT_DFF_UPD
 WHERE 1 = 1
--and lot_number='58133700'
--AND ATTRIBUTE1 IS NULL
--and STS IS NULL
;

UPDATE XXDBL.XXDBL_LOT_DFF_UPD
   SET STS = NULL
 WHERE ATTRIBUTE1 IS NULL;

DELETE XXDBL.XXDBL_LOT_DFF_UPD
 WHERE STS IS NULL;

--Inventory
--Maintain Lot Numbers
--Dyes and Chemical Information

SELECT MSI.SEGMENT1 ITEM_CODE, msi.ORGANIZATION_ID ORGANIZATION_CODE, LOT.LOT_NUMBER LOT_NUMBER, 'Dyed Yarn Information' ATTRIBUTE_CATEGORY,lot.attribute2 MANUFACTURING_DATE, EXPIRY_DATE
  FROM mtl_lot_numbers lot, mtl_system_items_b msi
 WHERE     1 = 1
       AND msi.INVENTORY_ITEM_ID = lot.INVENTORY_ITEM_ID
       AND msi.ORGANIZATION_ID = lot.ORGANIZATION_ID
       --AND LOT_NUMBER = '58133700'
       AND (lot.attribute2 IS NOT NULL OR lot.attribute3 IS NOT NULL)
       AND msi.ORGANIZATION_ID = 159;

SELECT apps.fnd_date.canonical_to_date ('12/30/2024') FROM DUAL;

SELECT
*
FROM
xxdbl.xxdbl_lot_dff_upd
WHERE attribute_category='Dyes and Chemical Information'