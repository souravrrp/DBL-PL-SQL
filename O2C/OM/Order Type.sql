select
--ott.*
OT.*
from
apps.oe_transaction_types_all OT,
apps.oe_transaction_types_tl ott,
WHERE 1=1
AND ORG_ID=126
AND ot.transaction_type_id=ott.transaction_type_id
AND TRANSACTION_TYPE_CODE='ORDER'
--AND ORDER_CATEGORY_CODE='MIXED'
AND ott.transaction_type_id IN (1006, 1014)
--and ott.transaction_type_id IN (
--'1010'
-- ,'1008'
--, '1030'
--)
--AND ott.transaction_type_id NOT IN (1008,
--                                           1010,
--                                           1030,
--                                           1032,
--                                           1034)