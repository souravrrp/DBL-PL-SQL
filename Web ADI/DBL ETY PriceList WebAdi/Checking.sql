/* Formatted on 1/13/2021 10:38:45 AM (QP5 v5.287) */
xxdbl_active_prc_list_wadi_pkg.load_pl_adi_prc

SELECT *
  FROM apps.xxdbl_bill_customer_account
 WHERE ORG_ID = 125 AND account_number = '45037';

  SELECT *
    FROM xxdbl_price_list_stg
   WHERE 1 = 1
--AND CUSTOMER_NUMBER IN ('100361', '45037')
ORDER BY record_id DESC;

SELECT name, description, attribute2
  FROM qp_list_headers
 WHERE 1 = 1
--AND name ='ECO-THREAD-YARN-PRICE LIST'