CREATE OR REPLACE PACKAGE APPS.xxdbl_shiping_tran_crp_pkg
IS
   FUNCTION available_to_transact (
      p_organization_id     IN   NUMBER,
      p_inventory_item_id   IN   NUMBER,
      p_subinventory_code   IN   VARCHAR2 DEFAULT NULL,
      p_locator_id          IN   NUMBER DEFAULT NULL,
      p_lot_number          IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION available_onhand (
      p_organization_id     IN   NUMBER,
      p_inventory_item_id   IN   NUMBER,
      p_subinventory_code   IN   VARCHAR2 DEFAULT NULL,
      p_locator_id          IN   NUMBER DEFAULT NULL,
      p_lot_number          IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION available_to_reserve (
      p_organization_id     IN   NUMBER,
      p_inventory_item_id   IN   NUMBER,
      p_subinventory_code   IN   VARCHAR2 DEFAULT NULL,
      p_locator_id          IN   NUMBER DEFAULT NULL,
      p_lot_number          IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER;

   PROCEDURE split_line (
      p_transaction_hdr_id   IN       NUMBER,
      x_message              OUT      VARCHAR2
   );

   PROCEDURE create_update_reservations (
      p_transaction_hdr_id   IN       NUMBER,
      x_message              OUT      VARCHAR2
   );

   PROCEDURE create_update_reservations_new (
      p_omshipping_hdr_id   IN       NUMBER,
      x_message             OUT      VARCHAR2
   );

   PROCEDURE create_update_ool_reserv (
      p_omshipping_header_id   IN       NUMBER,
      p_omshipping_line_id     IN       NUMBER,
      x_message                OUT      VARCHAR2
   );

   PROCEDURE split_line_new (
      p_omshipping_header_id   IN       NUMBER,
      p_omshipping_line_id     IN       NUMBER,
      x_message                OUT      VARCHAR2
   );

   PROCEDURE split_line_new1 (
      p_omshipping_hdr_id   IN       NUMBER,
      x_message             OUT      VARCHAR2
   );

   PROCEDURE transact_move_order (
      p_move_order_line_id   IN       NUMBER,
      p_api                  IN       VARCHAR2,
      p_trx_temp_id          IN       NUMBER,
      p_transaction_date     IN       DATE,
      p_return_status        OUT      VARCHAR2,
      p_return_message       OUT      VARCHAR2
   );

   PROCEDURE ship_confirm (
      p_delivery_id      IN       NUMBER,
      p_return_status    OUT      VARCHAR2,
      p_return_message   OUT      VARCHAR2
   );

   PROCEDURE pick_release_pick_rule (
      p_delivery_id      IN       NUMBER,
      p_return_status    OUT      VARCHAR2,
      p_return_message   OUT      VARCHAR2
   );

   PROCEDURE pick_ship_process (
      p_transaction_hdr_id   IN       NUMBER,
      x_message              OUT      VARCHAR2
   );

   FUNCTION get_sales_channel (
      p_header_id        IN   NUMBER,
      p_sold_to_org_id   IN   NUMBER
   )
      RETURN VARCHAR2;

   PROCEDURE is_line_in_bs (
      p_application_id                 IN              NUMBER,
      p_entity_short_name              IN              VARCHAR2,
      p_validation_entity_short_name   IN              VARCHAR2,
      p_validation_tmplt_short_name    IN              VARCHAR2,
      p_record_set_tmplt_short_name    IN              VARCHAR2,
      p_scope                          IN              VARCHAR2,
      p_result                         OUT NOCOPY      NUMBER
   );

   FUNCTION return_available_quantity (
      p_inevntory_item_id   IN   NUMBER,
      p_ship_from_org_id    IN   NUMBER,
      p_item_code           IN   VARCHAR2,
      p_pri_uom             IN   VARCHAR2,
      p_sec_uom             IN   VARCHAR2,
      p_preferred_grade     IN   VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION return_avail_quantity_new (
      p_inevntory_item_id   IN   NUMBER,
      p_ship_from_org_id    IN   NUMBER,
      p_item_code           IN   VARCHAR2,
      p_pri_uom             IN   VARCHAR2,
      p_sec_uom             IN   VARCHAR2,
      p_preferred_grade     IN   VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION total_order_quantity (p_header_id IN NUMBER, p_org_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION execute_immediate1 (p_ids IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_split_line_exists (
      p_order_header_id   IN   NUMBER,
      p_order_line_id     IN   NUMBER
   )
      RETURN NUMBER;
END xxdbl_shiping_tran_crp_pkg;
/
