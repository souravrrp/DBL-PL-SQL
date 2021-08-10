SELECT NVL (MAX (TRUNC (A.TRANSACTION_DATE)), '30-SEP-2017')
                      FROM INV.MTL_MATERIAL_TRANSACTIONS A,
                           MTL_TRANSACTION_LOT_NUMBERS b
                     WHERE     A.transaction_id = b.transaction_id(+)
                           AND A.INVENTORY_ITEM_ID = 4281
                           AND A.ORGANIZATION_ID = 166
                           --AND LOT.LOT_NUMBER = B.LOT_NUMBER(+)
                           AND B.LOT_NUMBER='0059696500'
                           AND SIGN (a.TRANSACTION_QUANTITY) = 1
                           AND TRUNC (A.TRANSACTION_DATE) <= :P_TO_DATE + .99999
                           AND A.TRANSACTION_TYPE_ID NOT IN (2,
                                                             80,
                                                             98,
                                                             50,
                                                             51,
                                                             53,
                                                             99,
                                                             120,
                                                             52,
                                                             26,
                                                             64)