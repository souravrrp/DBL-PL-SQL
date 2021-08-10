/* Formatted on 9/10/2020 11:45:06 AM (QP5 v5.287) */
SELECT *
  FROM xxdbl_move_order_v mov
 WHERE mov.line_status = 3
 AND REQUEST_NUMBER='727652'
 ORDER BY line_number;
 
 
 SELECT
 *
 FROM
 XXDBL_RCV_TRANSACTIONS_V
 WHERE 1=1
 --AND PO_DISTRIBUTION_ID = :xxdbl_move_order_v.PO_DISTRIBUTION_ID OR (PO_DISTRIBUTION_ID IS NULL AND po_line_location_id = :xxdbl_move_order_v.line_location_id)
 --ORDER BY RECEIPT_DATE DESC, TRANSACTION_DATE DESC
 ;


SELECT *
  FROM xxdbl_mov_ord_items_tmp mot;

  SELECT *
    FROM mtl_system_items_kfv mstk
   WHERE     1 = 1
         AND mstk.organization_id = :parameter.org_id
         AND mstk.purchasing_enabled_flag = 'Y'
         AND mstk.inventory_item_status_code = 'Active'
ORDER BY mstk.concatenated_segments;



  SELECT mov.*
    FROM xxdbl_move_order_v mov
   WHERE     mov.line_status = 3
         AND mov.quantity > NVL (mov.quantity_delivered, 0)
         AND mov.requisition_num IS NULL
         AND EXISTS
                (SELECT 1
                   FROM xxdbl_mov_ord_items_tmp mot
                  WHERE     mov.organization_id = mot.organization_id
                        AND mov.inventory_item_id = mot.inventory_item_id)
         AND NOT EXISTS
                (SELECT 1
                   FROM po_req_distributions_all prd,
                        po_requisition_lines_all prl,
                        po_requisition_headers_all prh
                  WHERE     prd.attribute14 = mov.line_id
                        AND prl.requisition_line_id = prd.requisition_line_id
                        AND NVL (prl.cancel_flag, 'N') != 'Y'
                        AND prh.requisition_header_id =
                               prl.requisition_header_id
                        AND NVL (prh.cancel_flag, 'N') != 'Y')
ORDER BY mov.request_number, mov.line_number;


------------------CHANGE ON 10-SEP-20 ------------------------------------------

--BLOCK NAME: SYSTEM_ITEMS
--ORDER BY mstk.concatenated_segments

--BLOCK NAME: XXDBL_MOVE_ORDER_V
--ORDER BY xmo.CREATION_DATE desc

--BLOCK NAME: XXDBL_RCV_TRANSACTIONS_V
--WHERE CLASUE: PO_DISTRIBUTION_ID = :xxdbl_move_order_v.PO_DISTRIBUTION_ID OR (PO_DISTRIBUTION_ID IS NULL AND po_line_location_id = :xxdbl_move_order_v.line_location_id)
--ORDER BY RECEIPT_DATE DESC, TRANSACTION_DATE DESC