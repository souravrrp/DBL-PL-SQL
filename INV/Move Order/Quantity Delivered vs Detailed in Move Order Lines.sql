SELECT lookup_code, substr(meaning, 1, 60) "Meaning"
FROM mfg_lookups
WHERE lookup_type = 'MTL_TXN_REQUEST_STATUS'
ORDER BY lookup_code;

SELECT mmt.transaction_id,
  tol.organization_id,
  toh.request_number,
  toh.header_id,
  tol.line_number,
  tol.line_id,
  tol.inventory_item_id,
  toh.description,
  toh.move_order_type,
  tol.line_status,
  tol.quantity,
  tol.quantity_delivered,
  tol.quantity_detailed
FROM mtl_txn_request_headers toh,
  mtl_txn_request_lines tol,
  mtl_material_transactions mmt
WHERE toh.header_id = tol.header_id
 AND toh.organization_id = tol.organization_id
 AND tol.line_id = mmt.move_order_line_id
 AND toh.request_number = '&EnterMONumber' ;
 
 
 SELECT mmtt.transaction_temp_id,
  tol.organization_id,
  toh.request_number,
  toh.header_id,
  tol.line_number,
  tol.line_id,
  tol.inventory_item_id,
  toh.description,
  toh.move_order_type,
  tol.line_status,
  tol.quantity,
  tol.quantity_delivered,
  tol.quantity_detailed
FROM mtl_txn_request_headers toh,
  mtl_txn_request_lines tol,
  APPS.mtl_material_transactions_temp mmtt
WHERE toh.header_id = tol.header_id
 AND toh.organization_id = tol.organization_id
 AND tol.line_id = mmtt.move_order_line_id ;
 
 SELECT quantity, quantity_delivered, quantity_detailed, required_quantity, line_status
FROM mtl_txn_request_lines
WHERE line_id = &enterlineid;