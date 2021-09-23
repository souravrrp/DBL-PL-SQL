CREATE OR REPLACE PACKAGE APPS.xxdbl_resource_workbench_pkg
AS
/******************************************************************************
   NAME:
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/06/2018  PwC              1. Created this package Spec.
******************************************************************************/--
   --
   PROCEDURE ascp_main_prc (
      x_errbuff           OUT      VARCHAR2,
      x_retcode           OUT      VARCHAR2,
      p_organization_id   IN       NUMBER,
      --p_order_type        IN       VARCHAR2,
      p_plan_name         IN       VARCHAR2,
      p_transaction_id    IN       NUMBER
   );

   -- Added By Manas on 04-Oct-2018 Starts
   PROCEDURE ascp_inline_prc (
      p_organization_id     IN   NUMBER,
      p_plan_name           IN   VARCHAR2,
      p_transaction_id      IN   NUMBER,
      p_order_number        IN   VARCHAR2,
      p_quantity            IN   NUMBER,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   );

   PROCEDURE ascp_inline_prc_wo (
      p_organization_id     IN   NUMBER,
      p_plan_name           IN   VARCHAR2,
      p_transaction_id      IN   NUMBER,
      p_quantity            IN   NUMBER,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   );

   PROCEDURE ascp_inline_archive_prc (
      p_plan_name           IN   VARCHAR2,
      p_transaction_id      IN   NUMBER,
      p_order_number        IN   VARCHAR2,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   );

   PROCEDURE ascp_inline_archive_prc_wo (
      p_plan_name            IN   VARCHAR2,
      p_transaction_id       IN   NUMBER,
      p_transaction_source        VARCHAR2 DEFAULT 'ASCP',
      p_inventory_item_id    IN   NUMBER,
      p_item_number          IN   VARCHAR2,
      p_item_description     IN   VARCHAR2,
      p_organization_id      IN   NUMBER,
      p_organization_code    IN   VARCHAR2,
      p_lot_number           IN   VARCHAR2,
      p_customer_po_number   IN   VARCHAR2,
      p_customer_number      IN   VARCHAR2,
      p_customer_name        IN   VARCHAR2,
      p_customer_id          IN   NUMBER,
      p_order_number         IN   NUMBER,
      p_order_line_no        IN   VARCHAR2,
      p_order_header_id      IN   NUMBER,
      p_order_line_id        IN   NUMBER
   );

-- Added By Manas on 04-Oct-2018 Ends
   --
   PROCEDURE insert_row (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_secondary_plan_qty        IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   );

   PROCEDURE insert_row_new (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_secondary_plan_qty        IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   );

   --
   FUNCTION mtl_uom_conversion_qty (
      p_item_id    IN   NUMBER,
      p_from_qty   IN   NUMBER,
      p_from_um    IN   VARCHAR2,
      p_to_um      IN   VARCHAR2
   )
      RETURN NUMBER;

   --
   PROCEDURE mto_main_prc (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_factor                    IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   );

   PROCEDURE mto_merge_main_prc (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_factor                    IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   );

   PROCEDURE mto_main_prc_new (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_factor                    IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   );

--
   PROCEDURE ascp_archive_prc;

   FUNCTION get_remainning_quantity (
      p_order_number        IN   NUMBER,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION get_remainning_quantity_wo (
      p_transaction_source   IN   VARCHAR2 DEFAULT 'ASCP',
      p_lot_number           IN   VARCHAR2 DEFAULT NULL,
      p_customer_po_number   IN   VARCHAR2 DEFAULT NULL,
      p_customer_number      IN   VARCHAR2 DEFAULT NULL,
      p_customer_name        IN   VARCHAR2 DEFAULT NULL,
      p_customer_id          IN   NUMBER DEFAULT NULL,
      p_order_number         IN   NUMBER DEFAULT NULL,
      p_order_line_no        IN   VARCHAR2 DEFAULT NULL,
      p_order_header_id      IN   NUMBER DEFAULT NULL,
      p_order_line_id        IN   NUMBER DEFAULT NULL,
      p_inventory_item_id    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION get_remain_quantity_wo_mto (
      p_transaction_source   IN   VARCHAR2 DEFAULT 'MTO',
      p_lot_number           IN   VARCHAR2 DEFAULT NULL,
      p_customer_po_number   IN   VARCHAR2 DEFAULT NULL,
      p_customer_number      IN   VARCHAR2 DEFAULT NULL,
      p_customer_name        IN   VARCHAR2 DEFAULT NULL,
      p_customer_id          IN   NUMBER DEFAULT NULL,
      p_order_number         IN   NUMBER DEFAULT NULL,
      p_order_line_no        IN   VARCHAR2 DEFAULT NULL,
      p_order_header_id      IN   NUMBER DEFAULT NULL,
      p_order_line_id        IN   NUMBER DEFAULT NULL,
      p_inventory_item_id    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION get_remain_quantity_wo_ascp (
      p_transaction_source   IN   VARCHAR2 DEFAULT 'ASCP',
      p_inventory_item_id    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION get_remainning_quantity_sec (
      p_order_number        IN   NUMBER,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION get_remainning_uom_sec (p_uom_code IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION execute_immediate1 (p_ids IN VARCHAR2)
      RETURN DATE;

   FUNCTION execute_immediate2 (p_ids IN VARCHAR2)
      RETURN DATE;

   PROCEDURE execute_immediate3 (p_ids IN VARCHAR2);

   FUNCTION get_yarn_process_loss (p_article_ticket_mumber IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE parent_child_form_qty (
      p_org_id      IN       NUMBER,
      p_item_id     IN       NUMBER,
      x_error_msg   OUT      VARCHAR2,
      x_factor      OUT      NUMBER
   );
--
END xxdbl_resource_workbench_pkg;
/