/* Formatted on 6/10/2020 3:02:15 PM (QP5 v5.287) */
SELECT bha.*
  FROM xx_ar_bills_headers_all bha,
       xx_ar_bills_lines_all bla,
       xx_ar_bills_line_details_all bda
 WHERE     bha.org_id = 131
       AND bha.bill_header_id = bla.bill_header_id
       AND bla.bill_line_id = bda.bill_line_id
       AND bill_number = 'MSML/2006'
       


SELECT bha.*
  FROM xx_ar_bills_headers_all bha
  where 1=1
  AND bill_header_id='26890'
  --AND bill_number = 'MSML/4099'   --'MSML/2006'
  ORDER BY CREATION_DATE DESC
  
--DELETE
--FROM
--    xx_ar_bills_headers_all
--WHERE
--    bill_header_id = 26862;
  


  
  
  select OPERATING_UNIT,
   ORG_ID,
   CUSTOMER_NUMBER,
   CUSTOMER_ID,
   CUSTOMER_NAME,
   CUSTOMER_TYPE,
   BILL_CURRENCY,
   BILL_CATEGORY,
   EXCHANCE_RATE,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
       CREATED_BY,
   CREATION_DATE,
   BILL_TYPE
  from 
  xx_ar_bills_headers_all
  where bill_number='MSML/4099'
  
  select
  *
  from
  xx_ar_bills_lines_all bla
  where 1=1
  and bill_header_id='26890'
  --and challan_number='MSML/11965'
  --ORDER BY CREATION_DATE DESC
  
  
  SELECT
  *
  FROM
   xx_ar_bills_line_details_all bda
   where 1=1
   and BILL_LINE_ID in ('27342')--,'27335')
   ORDER BY CREATION_DATE DESC
   
   
   
