CREATE OR REPLACE PACKAGE APPS.cust_webadi_item_upload_pkg
IS
l_segment1_len NUMBER;
l_segment2_len NUMBER;
l_segment3_len NUMBER;
l_segment4_len NUMBER;
l_segment5_len NUMBER;
l_segment6_len NUMBER;
l_segment7_len NUMBER;
l_segment8_len NUMBER;

PROCEDURE initialize_segment_len;

PROCEDURE cust_import_data_to_interface;

PROCEDURE cust_upload_data_to_staging (
      p_segment1                      VARCHAR2,
      p_segment2                      VARCHAR2,
      p_segment3                      VARCHAR2,
      p_segment4                      VARCHAR2,
      p_segment5                      VARCHAR2,
      p_segment6                      VARCHAR2,
      p_segment7                      VARCHAR2,
      p_segment8                      VARCHAR2,
      p_organization_name             VARCHAR2,
      p_description                   VARCHAR2,
      p_inventory_item_status_code    VARCHAR2,
      p_template_name                 VARCHAR2,
      p_primary_uom_code              VARCHAR2,
      p_tracking_quantity_ind         VARCHAR2,
      p_ont_pricing_qty_source        VARCHAR2,
      p_secondary_uom_code            VARCHAR2,
      p_secondary_default_ind         VARCHAR2,
      p_attribute_category            VARCHAR2,
      p_attribute1                    VARCHAR2,
      p_attribute2                    VARCHAR2,
      p_attribute3                    VARCHAR2,
      p_attribute4                    VARCHAR2,
      p_attribute5                    VARCHAR2,
      p_attribute6                    VARCHAR2,
      p_attribute7                    VARCHAR2,
      p_attribute8                    VARCHAR2,
      p_attribute9                    VARCHAR2,
      p_attribute10                   VARCHAR2,
      p_attribute11                   VARCHAR2,
      p_attribute12                   VARCHAR2,
      p_attribute13                   VARCHAR2,
      p_attribute14                   VARCHAR2,
      p_attribute15                   VARCHAR2,
      p_purchasing_item_flag          VARCHAR2,
      p_shippable_item_flag           VARCHAR2,
      p_customer_order_flag           VARCHAR2,
      p_internal_order_flag           VARCHAR2,
      p_service_item_flag             VARCHAR2,
      p_inventory_item_flag           VARCHAR2,
      p_inventory_asset_flag          VARCHAR2,
      p_purchasing_enabled_flag       VARCHAR2,
      p_customer_order_enabled_flag   VARCHAR2,
      p_internal_order_enabled_flag   VARCHAR2,
      p_so_transactions_flag          VARCHAR2,
      p_mtl_transactions_enab_flag    VARCHAR2,
      p_stock_enabled_flag            VARCHAR2,
      p_bom_enabled_flag              VARCHAR2,
      p_build_in_wip_flag             VARCHAR2,
      p_returnable_flag               VARCHAR2,
      p_taxable_flag                  VARCHAR2,
      p_allow_item_desc_update_flag   VARCHAR2,
      p_inspection_required_flag      VARCHAR2,
      p_receipt_required_flag         VARCHAR2
   );

END cust_webadi_item_upload_pkg;
/
