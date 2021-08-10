/* Formatted on 10/5/2020 12:16:30 PM (QP5 v5.287) */
SELECT mth.request_number Move_Order_Number,
       mtl.line_number Line_Number,
       mmtt.transaction_quantity Allocated_Quantity_MMTT,
       mtl.quantity,
       mtl.quantity_delivered transacted_quantity,
       mtl.quantity_detailed allocated_quantity,
       DECODE (mtl.line_status,
               1, 'Incomplete ',
               2, 'Pending Approval',
               3, 'Approved',
               4, 'Not Approved',
               5, 'Closed',
               6, 'Canceled',
               7, 'Pre Approved',
               8, 'Partially Approved',
               9, 'Canceled by Source',
               'Other Unknown')
          MO_Line_Status,
       DECODE (mth.move_order_type,
               1, 'Requisition',
               2, 'Replenishment',
               3, 'Pick Wave',
               4, 'Receipt',
               5, 'Manufacturing Pick',
               'Other Unknown')
          MO_Type,
       mth.header_id,
       mtl.line_id,
       mmtt.transaction_status,
       mmtt.transaction_header_id,
       mmtt.transaction_temp_id
  FROM mtl_material_transactions_temp mmtt,
       mtl_txn_request_lines mtl,
       mtl_txn_request_headers mth
 WHERE     mmtt.move_order_line_id = mtl.line_id
       AND mth.header_id = mtl.header_id