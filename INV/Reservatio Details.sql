/* Formatted on 9/2/2020 12:05:58 PM (QP5 v5.354) */
SELECT                  --SUM (primary_reservation_quantity) reserve_quantity,
       inventory_item_id, organization_id, MR.*
  FROM Mtl_Reservations MR
 WHERE Organization_Id = '152' AND INVENTORY_ITEM_ID = 189536
--AND subinventory_code = XXXX
--GROUP BY Organization_Id, inventory_item_id
;


SELECT MMT.ORGANIZATION_ID,
       MMT.INVENTORY_ITEM_ID,
       MMT.TRANSACTION_ID,
       MMT.SUBINVENTORY_CODE,
       MMT.TRANSACTION_QUANTITY,
       MMT.PRIMARY_QUANTITY
  FROM MTL_MATERIAL_TRANSACTIONS MMT, MTL_ONHAND_QUANTITIES MOQ
 WHERE     MMT.ORGANIZATION_ID = MOQ.ORGANIZATION_ID
       AND MMT.INVENTORY_ITEM_ID = MOQ.INVENTORY_ITEM_ID
       AND MMT.TRANSACTION_ID = MOQ.CREATE_TRANSACTION_ID
       AND MMT.INVENTORY_ITEM_ID = 189536
       AND MMT.ORGANIZATION_ID IN (152);



SELECT moq.inventory_item_id                              inventory_item_id,
       moq.organization_id,
       moq.transaction_quantity,
       mr.reserve_quantity,
       moq.transaction_quantity - mr.reserve_quantity     unreserved_qty
  FROM (  SELECT moq.inventory_item_id                     inventory_item_id,
                 moq.organization_id                       organization_id,
                 SUM (moq.primary_transaction_quantity)    transaction_quantity
            FROM mtl_onhand_quantities_detail moq
           WHERE Moq.Organization_Id = '152' --AND moq.subinventory_code = 'XXXX'
        GROUP BY moq.inventory_item_id, moq.organization_id) moq,
       (  SELECT SUM (primary_reservation_quantity)     reserve_quantity,
                 inventory_item_id,
                 organization_id
            FROM Mtl_Reservations
           WHERE Organization_Id = '152'        --AND subinventory_code = XXXX
        GROUP BY Organization_Id, inventory_item_id) mr
 WHERE     moq.inventory_item_id = mr.inventory_item_id
       AND Moq.Organization_Id = Mr.Organization_Id
       AND MR.INVENTORY_ITEM_ID = 189536;

SELECT ORGANIZATION_CODE                         From_Organization,
       SUBSTR (SHIPMENT_PRIORITY_CODE, 1, 3)     to_organization,
       wdd.SOURCE_HEADER_NUMBER                  Order_number,
       wdd.SOURCE_LINE_NUMBER                    Line_no,
       SOURCE_LINE_ID,
       msib.segment1                             parts,
       rs.RESERVATION_QUANTITY,
       wdd.organization_id,
       RESERVATION_ID
  FROM mtl_reservations              rs,
       wsh_delivery_details          wdd,
       mtl_system_items_b            msib,
       org_organization_definitions  ord
 WHERE     rs.DEMAND_SOURCE_LINE_ID = wdd.SOURCE_LINE_ID
       AND wdd.RELEASED_STATUS = 'B'
       AND wdd.SOURCE_HEADER_TYPE_NAME LIKE 'Internal%Order%'
       AND STAGED_FLAG IS NULL
       AND wdd.REQUESTED_QUANTITY = RESERVATION_QUANTITY
       AND DETAILED_QUANTITY = 0
       AND msib.inventory_item_id = wdd.inventory_item_id
       AND msib.organization_id = wdd.organization_id
       AND ord.organization_id = wdd.organization_id