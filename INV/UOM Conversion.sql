SELECT   apps.inv_convert.inv_um_convert (188993,
                                          '',
                                          1,
                                          'CTN',
                                          'SQM',
                                          '',
                                          '')
       * 1
  FROM DUAL;
  
--------------------------------------------------------------------------------
SELECT
*
FROM
MTL_UOM_CONVERSIONS
WHERE 1=1
AND UNIT_OF_MEASURE='Inch'
;

SELECT
MUC.*
FROM
MTL_UOM_CONVERSIONS  MUC
,MTL_SYSTEM_ITEMS_B MSI
WHERE 1=1
AND MUC.INVENTORY_ITEM_ID=MSI.INVENTORY_ITEM_ID
AND  MSI.SEGMENT1='SPRECONS000000022650'
AND MSI.ORGANIZATION_ID='193'

SELECT
MUCC.*
FROM
MTL_UOM_CLASS_CONVERSIONS  MUCC
,MTL_SYSTEM_ITEMS_B MSI
WHERE 1=1
AND MUCC.INVENTORY_ITEM_ID=MSI.INVENTORY_ITEM_ID
AND MSI.SEGMENT1='YRN14S100CVC53899978'
AND MSI.ORGANIZATION_ID='193'