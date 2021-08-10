/* Formatted on 2/8/2020 12:47:26 PM (QP5 v5.287) */
SELECT --TR.*
MLT.*
  FROM MTL_MATERIAL_TRANSACTIONS TR
  ,APPS.MTL_TRANSACTION_LOT_NUMBERS MLT
 WHERE     TR.ATTRIBUTE_CATEGORY = 'Grey Yarn Issue for Knitting'
       AND TR.transaction_id = '258291'
       and TR.transaction_id = MLT.transaction_id