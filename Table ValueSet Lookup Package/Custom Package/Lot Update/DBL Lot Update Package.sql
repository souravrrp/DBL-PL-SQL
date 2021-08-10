/* Formatted on 7/28/2020 12:37:49 PM (QP5 v5.287) */
DECLARE
   v_org    NUMBER;
   v_item   NUMBER;



   CURSOR c1
   IS
      SELECT *
        FROM xxdbl.xxdbl_lot_dff_upd
       WHERE sts IS NULL;
BEGIN
   FOR i IN c1
   LOOP
      /* SELECT Organization_id
         INTO v_org
         FROM org_organization_definitions
        WHERE ORGANIZATION_NAME = i.organization_code;
        */



      /*   SELECT inventory_item_id
           INTO v_item
           FROM mtl_system_items_b
          WHERE segment1 = i.item_code AND organization_id = v_org;
          */



      UPDATE mtl_lot_numbers
         SET attribute1 = i.attribute1, attribute3 = i.attribute3
       WHERE     Organization_id = i.organization_code
             AND inventory_item_id = i.item_code
             AND attribute_category = 'Grey Yarn Information'
             AND lot_number = i.lot_number;

      --     AND ORIGINATION_DATE = '30-SEP-2017';



      UPDATE xxdbl.xxdbl_lot_dff_upd
         SET sts = 'Y'
       WHERE     ORGANIZATION_CODE = i.ORGANIZATION_CODE
             AND item_Code = i.item_code;
   END LOOP;
END;



SELECT *
  FROM mtl_lot_numbers
 WHERE lot_number IN (SELECT lot_number
                        FROM xxdbl.xxdbl_lot_dff_upd);

SELECT *
  --   INTO v_org
  FROM org_organization_definitions
 WHERE organization_id = 139;

SELECT *
  FROM mtl_lot_numbers
 WHERE Organization_id = 187 AND ORIGINATION_DATE = '30-SEP-2017';


ALTER TABLE xxdbl.xxdbl_lot_dff_upd
   ADD (MANUFACTURING_DATE DATE, EXPIRY_DATE DATE);

SELECT * FROM XXDBL.XXDBL_LOT_DFF_UPD

--Inventory
--Maintain Lot Numbers
--Dyes and Chemical Information