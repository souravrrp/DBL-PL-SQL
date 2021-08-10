/* Formatted on 1/24/2021 11:52:29 AM (QP5 v5.354) */

--xxdbl_item_conv_prc_thread


SELECT *
  FROM xxdbl_item_conv_stg pw
 WHERE 1 = 1                        --AND ITEM_CATEGORY_SEGMENT3 = 'DYED YARN'
             AND STATUS IS NULL;

DELETE FROM xxdbl_item_conv_stg pw
      WHERE STATUS IS NULL;