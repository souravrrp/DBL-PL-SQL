below mentioned outputs by passing the receipt number and org.id

1.
SELECT *
FROM rcv_shipment_headers
WHERE Receipt_Num ='&Receipt_Number'
AND ship_to_org_id IN
(SELECT organization_id FROM mtl_parameters WHERE organization_code='&Org_Code'
)



2.
SELECT *
FROM rcv_shipment_lines
WHERE shipment_header_id IN
(SELECT shipment_header_id
FROM rcv_shipment_headers
WHERE Receipt_Num ='&Receipt_Number'
AND ship_to_org_id IN
(SELECT organization_id FROM mtl_parameters WHERE organization_code='&Org_Code'
)
) 3.
SELECT *
FROM mtl_supply
WHERE shipment_header_id IN
(SELECT shipment_header_id
FROM rcv_shipment_headers
WHERE Receipt_Num ='&Receipt_Number'
AND ship_to_org_id IN
(SELECT organization_id FROM mtl_parameters WHERE organization_code='&Org_Code'
)
) 4.
SELECT *
FROM rcv_supply
WHERE shipment_header_id IN
(SELECT shipment_header_id
FROM rcv_shipment_headers
WHERE Receipt_Num ='&Receipt_Number'
AND ship_to_org_id IN
(SELECT organization_id FROM mtl_parameters WHERE organization_code='&Org_Code'
)
)

5.
SELECT *
FROM rcv_transactions
WHERE shipment_header_id IN
(SELECT shipment_header_id
FROM rcv_shipment_headers
WHERE Receipt_Num ='&Receipt_Number'
AND ship_to_org_id IN
(SELECT organization_id FROM mtl_parameters WHERE organization_code='&Org_Code'
)
)


6.
SELECT *
FROM mtl_material_transactions
WHERE shipment_number IN
(SELECT shipment_num
FROM rcv_shipment_headers
WHERE Receipt_Num ='&Receipt_Number'
AND ship_to_org_id IN
(SELECT organization_id FROM mtl_parameters WHERE organization_code='&Org_Code'
)
)


7.
SELECT *
from mtl_transaction_accounts
where transaction_id in
(SELECT transaction_id
FROM mtl_material_transactions
WHERE shipment_number IN
(SELECT shipment_num
FROM rcv_shipment_headers
WHERE Receipt_Num ='&Receipt_Number'
AND ship_to_org_id IN
(SELECT organization_id FROM mtl_parameters WHERE organization_code='&Org_Code'
)
))
