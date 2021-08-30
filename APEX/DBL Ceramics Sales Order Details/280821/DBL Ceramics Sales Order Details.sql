/* Formatted on 8/28/2021 5:48:07 PM (QP5 v5.287) */
SELECT DISTINCT mc.segment2 item_category
  FROM inv.mtl_categories_b mc
 WHERE mc.segment3 IS NOT NULL;

SELECT DISTINCT mc.segment3 item_type
  FROM inv.mtl_categories_b mc
 WHERE mc.segment3 IS NOT NULL;


SELECT 'A' PREFERRED_GRADE FROM DUAL
UNION ALL
SELECT 'B' PREFERRED_GRADE FROM DUAL;

--XXDBL_CERAMICS_ITEM_CATEGORY

SELECT DISTINCT
       CATEGORY_CONCAT_SEGS AS DISPLAY_VALUE,
       CATEGORY_CONCAT_SEGS AS RETURN_VALUE
  FROM MTL_ITEM_CATEGORIES_V
 WHERE ORGANIZATION_ID = 152 AND CATEGORY_SET_ID = 1100000061;

SELECT customer_id,
       customer_number,
       customer_name,
       customer_category_code customer_category,
       DECODE (customer_type,  'I', 'Internal',  'R', 'External')
          customer_type,
       ac.*
  FROM ar_customers ac
 WHERE 1 = 1 AND customer_number = '100130';

SELECT DISTINCT SEGMENT3 AS DISPLAY_VALUE, SEGMENT3 AS RETURN_VALUE
  FROM MTL_ITEM_CATEGORIES_V
 WHERE ORGANIZATION_ID = 152 AND SEGMENT2 = 'FINISH GOODS';
 
 SELECT
 MEANING AS DISPLAY_VALUE, LOOKUP_TYPE AS RETURN_VALUE
 FROM
 APPS.AR_LOOKUPS
 where lookup_type = 'CUSTOMER_CATEGORY'
    order by meaning
    
    AR_BR_CUSTOMER_CATEGORY