/* Formatted on 6/22/2020 4:47:35 PM (QP5 v5.287) */
CREATE TABLE erps_item_import
(
   segment1            VARCHAR2 (100),
   organization_id     NUMBER,
   process_flag        VARCHAR2 (100),
   set_process_id      NUMBER,
   transaction_type    VARCHAR2 (100),
   description         VARCHAR2 (100),
   primary_UOM_code    VARCHAR2 (100),
   validation_flag     VARCHAR2 (10),
   validation_errors   VARCHAR2 (100)
);