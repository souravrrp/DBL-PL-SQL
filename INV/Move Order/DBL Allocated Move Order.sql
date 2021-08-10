/* Formatted on 10/5/2020 12:08:09 PM (QP5 v5.287) */
SELECT mth.request_number Move_Order_Number,
       mtl.line_number Line_Number,
       mmtt.organization_id,
       mth.move_order_type,
       mth.transaction_Type_id,
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
       mmtt.transaction_temp_id,
       mmtt.allocated_lpn_id,
       wlpn.license_plate_number,
       wlpn.lpn_context,
       msnt.fm_serial_number,
       msnt.to_serial_number
  FROM mtl_material_transactions_temp mmtt,
       mtl_txn_request_lines mtl,
       mtl_txn_request_headers mth,
       mtl_serial_numbers_temp msnt,
       wms_license_plate_numbers wlpn
 WHERE     mmtt.move_order_line_id = mtl.line_id
       AND mth.header_id = mtl.header_id
       AND wlpn.lpn_id(+) = mmtt.allocated_lpn_id
       AND msnt.transaction_temp_id(+) = mmtt.transaction_temp_id