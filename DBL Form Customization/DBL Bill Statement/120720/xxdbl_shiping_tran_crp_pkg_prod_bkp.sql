CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_shiping_tran_crp_pkg
IS
   PROCEDURE create_update_ool_reserv1 (
      p_omshipping_header_id   IN       NUMBER,
      p_omshipping_line_id     IN       NUMBER,
      x_message                OUT      VARCHAR2
   );

   PROCEDURE create_resv_yarn (
      p_omshiping_line_id     IN       NUMBER,
      p_split_order_line_id   IN       NUMBER,
      p_resv_type             IN       VARCHAR2,
      x_message               OUT      VARCHAR2
   );

   FUNCTION available_to_transact (
      p_organization_id     IN   NUMBER,
      p_inventory_item_id   IN   NUMBER,
      p_subinventory_code   IN   VARCHAR2 DEFAULT NULL,
      p_locator_id          IN   NUMBER DEFAULT NULL,
      p_lot_number          IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_actual_quantity       NUMBER        := 0;
      x_return_status         VARCHAR2 (50);
      x_msg_count             VARCHAR2 (50);
      x_msg_data              VARCHAR2 (50);
      v_item_id               NUMBER;
      v_org_id                NUMBER;
      v_qoh                   NUMBER;
      v_rqoh                  NUMBER;
      v_atr                   NUMBER;
      v_att                   NUMBER;
      v_qr                    NUMBER;
      v_qs                    NUMBER;
      v_lot_control_code      BOOLEAN;
      v_serial_control_code   BOOLEAN;
   BEGIN
      BEGIN
         -- Set the variable values
         v_item_id := p_inventory_item_id;
         v_org_id := p_organization_id;
         v_qoh := NULL;
         v_rqoh := NULL;
         v_atr := NULL;

         IF p_lot_number IS NULL
         THEN
            v_lot_control_code := FALSE;
         ELSE
            v_lot_control_code := TRUE;
         END IF;

         v_serial_control_code := FALSE;
         -- Set the org context
         --fnd_client_info.set_org_context (:blk_hdr.org_id);
         -- Call API
         inv_quantity_tree_pub.query_quantities
                                (p_api_version_number       => 1.0,
                                 p_init_msg_lst             => 'F',
                                 x_return_status            => x_return_status,
                                 x_msg_count                => x_msg_count,
                                 x_msg_data                 => x_msg_data,
                                 p_organization_id          => v_org_id,
                                 p_inventory_item_id        => v_item_id,
                                 p_tree_mode                => 3,
                                 -- or 3
                                 p_is_revision_control      => FALSE,
                                 p_is_lot_control           => v_lot_control_code,
                                 -- is_lot_control,
                                 p_is_serial_control        => v_serial_control_code,
                                 p_revision                 => NULL,
                                 -- p_revision,
                                 p_lot_number               => p_lot_number,
                                 -- p_lot_number,
                                 p_lot_expiration_date      => SYSDATE,
                                 p_subinventory_code        => p_subinventory_code,
                                 -- p_subinventory_code,
                                 p_locator_id               => p_locator_id,
                                                               -- p_locator_id,
                                 -- p_cost_group_id            = NULL,       -- cg_id,
                                 --p_onhand_source            => 3,
                                 x_qoh                      => v_qoh,
                                 -- Quantity on-hand
                                 x_rqoh                     => v_rqoh,
                                 --reservable quantity on-hand
                                 x_qr                       => v_qr,
                                 x_qs                       => v_qs,
                                 x_att                      => v_att,
                                 -- available to transact
                                 x_atr                      => v_atr
                                -- available to reserve
                                );
         --DBMS_OUTPUT.put_line ('On-Hand Quantity: ' || v_qoh);
         --DBMS_OUTPUT.put_line ('Available to reserve: ' || v_atr);
         --DBMS_OUTPUT.put_line ('Quantity Reserved: ' || v_qr);
         --DBMS_OUTPUT.put_line ('Quantity Suggested: ' || v_qs);
         --DBMS_OUTPUT.put_line ('Available to Transact: ' || v_att);
         --DBMS_OUTPUT.put_line ('Available to Reserve: ' || v_atr);
         v_att := NVL (v_att, 0);
         v_qoh := NVL (v_qoh, 0);
         v_rqoh := NVL (v_rqoh, 0);
      EXCEPTION
         WHEN OTHERS
         THEN
            v_qoh := 0;
            v_att := 0;
            v_rqoh := 0;
      --DBMS_OUTPUT.put_line ('ERROR: ' || SQLERRM);
      END;

      RETURN v_att;
   END available_to_transact;

   FUNCTION available_onhand (
      p_organization_id     IN   NUMBER,
      p_inventory_item_id   IN   NUMBER,
      p_subinventory_code   IN   VARCHAR2 DEFAULT NULL,
      p_locator_id          IN   NUMBER DEFAULT NULL,
      p_lot_number          IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_actual_quantity       NUMBER        := 0;
      x_return_status         VARCHAR2 (50);
      x_msg_count             VARCHAR2 (50);
      x_msg_data              VARCHAR2 (50);
      v_item_id               NUMBER;
      v_org_id                NUMBER;
      v_qoh                   NUMBER;
      v_rqoh                  NUMBER;
      v_atr                   NUMBER;
      v_att                   NUMBER;
      v_qr                    NUMBER;
      v_qs                    NUMBER;
      v_lot_control_code      BOOLEAN;
      v_serial_control_code   BOOLEAN;
   BEGIN
      BEGIN
         -- Set the variable values
         v_item_id := p_inventory_item_id;
         v_org_id := p_organization_id;
         v_qoh := NULL;
         v_rqoh := NULL;
         v_atr := NULL;

         IF p_lot_number IS NULL
         THEN
            v_lot_control_code := FALSE;
         ELSE
            v_lot_control_code := TRUE;
         END IF;

         v_serial_control_code := FALSE;
         -- Set the org context
         --fnd_client_info.set_org_context (:blk_hdr.org_id);
         -- Call API
         inv_quantity_tree_pub.query_quantities
                                (p_api_version_number       => 1.0,
                                 p_init_msg_lst             => 'F',
                                 x_return_status            => x_return_status,
                                 x_msg_count                => x_msg_count,
                                 x_msg_data                 => x_msg_data,
                                 p_organization_id          => v_org_id,
                                 p_inventory_item_id        => v_item_id,
                                 p_tree_mode                => 3,
                                 -- or 3
                                 p_is_revision_control      => FALSE,
                                 p_is_lot_control           => v_lot_control_code,
                                 -- is_lot_control,
                                 p_is_serial_control        => v_serial_control_code,
                                 p_revision                 => NULL,
                                 -- p_revision,
                                 p_lot_number               => p_lot_number,
                                 -- p_lot_number,
                                 p_lot_expiration_date      => SYSDATE,
                                 p_subinventory_code        => p_subinventory_code,
                                 -- p_subinventory_code,
                                 p_locator_id               => p_locator_id,
                                                               -- p_locator_id,
                                 -- p_cost_group_id            = NULL,       -- cg_id,
                                 --p_onhand_source            => 3,
                                 x_qoh                      => v_qoh,
                                 -- Quantity on-hand
                                 x_rqoh                     => v_rqoh,
                                 --reservable quantity on-hand
                                 x_qr                       => v_qr,
                                 x_qs                       => v_qs,
                                 x_att                      => v_att,
                                 -- available to transact
                                 x_atr                      => v_atr
                                -- available to reserve
                                );
         --DBMS_OUTPUT.put_line ('On-Hand Quantity: ' || v_qoh);
         --DBMS_OUTPUT.put_line ('Available to reserve: ' || v_atr);
         --DBMS_OUTPUT.put_line ('Quantity Reserved: ' || v_qr);
         --DBMS_OUTPUT.put_line ('Quantity Suggested: ' || v_qs);
         --DBMS_OUTPUT.put_line ('Available to Transact: ' || v_att);
         --DBMS_OUTPUT.put_line ('Available to Reserve: ' || v_atr);
         v_att := NVL (v_att, 0);
         v_qoh := NVL (v_qoh, 0);
         v_rqoh := NVL (v_rqoh, 0);
      EXCEPTION
         WHEN OTHERS
         THEN
            v_qoh := 0;
            v_att := 0;
            v_rqoh := 0;
      --DBMS_OUTPUT.put_line ('ERROR: ' || SQLERRM);
      END;

      RETURN v_qoh;
   END available_onhand;

   FUNCTION available_to_reserve (
      p_organization_id     IN   NUMBER,
      p_inventory_item_id   IN   NUMBER,
      p_subinventory_code   IN   VARCHAR2 DEFAULT NULL,
      p_locator_id          IN   NUMBER DEFAULT NULL,
      p_lot_number          IN   VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_actual_quantity       NUMBER        := 0;
      x_return_status         VARCHAR2 (50);
      x_msg_count             VARCHAR2 (50);
      x_msg_data              VARCHAR2 (50);
      v_item_id               NUMBER;
      v_org_id                NUMBER;
      v_qoh                   NUMBER;
      v_rqoh                  NUMBER;
      v_atr                   NUMBER;
      v_att                   NUMBER;
      v_qr                    NUMBER;
      v_qs                    NUMBER;
      v_lot_control_code      BOOLEAN;
      v_serial_control_code   BOOLEAN;
   BEGIN
      BEGIN
         -- Set the variable values
         v_item_id := p_inventory_item_id;
         v_org_id := p_organization_id;
         v_qoh := NULL;
         v_rqoh := NULL;
         v_atr := NULL;

         IF p_lot_number IS NULL
         THEN
            v_lot_control_code := FALSE;
         ELSE
            v_lot_control_code := TRUE;
         END IF;

         v_serial_control_code := FALSE;
         -- Set the org context
         --fnd_client_info.set_org_context (:blk_hdr.org_id);
         -- Call API
         inv_quantity_tree_pub.query_quantities
                                (p_api_version_number       => 1.0,
                                 p_init_msg_lst             => 'F',
                                 x_return_status            => x_return_status,
                                 x_msg_count                => x_msg_count,
                                 x_msg_data                 => x_msg_data,
                                 p_organization_id          => v_org_id,
                                 p_inventory_item_id        => v_item_id,
                                 p_tree_mode                => 3,
                                 -- or 3
                                 p_is_revision_control      => FALSE,
                                 p_is_lot_control           => v_lot_control_code,
                                 -- is_lot_control,
                                 p_is_serial_control        => v_serial_control_code,
                                 p_revision                 => NULL,
                                 -- p_revision,
                                 p_lot_number               => p_lot_number,
                                 -- p_lot_number,
                                 p_lot_expiration_date      => SYSDATE,
                                 p_subinventory_code        => p_subinventory_code,
                                 -- p_subinventory_code,
                                 p_locator_id               => p_locator_id,
                                                               -- p_locator_id,
                                 -- p_cost_group_id            = NULL,       -- cg_id,
                                 --p_onhand_source            => 3,
                                 x_qoh                      => v_qoh,
                                 -- Quantity on-hand
                                 x_rqoh                     => v_rqoh,
                                 --reservable quantity on-hand
                                 x_qr                       => v_qr,
                                 x_qs                       => v_qs,
                                 x_att                      => v_att,
                                 -- available to transact
                                 x_atr                      => v_atr
                                -- available to reserve
                                );
         --DBMS_OUTPUT.put_line ('On-Hand Quantity: ' || v_qoh);
         --DBMS_OUTPUT.put_line ('Available to reserve: ' || v_atr);
         --DBMS_OUTPUT.put_line ('Quantity Reserved: ' || v_qr);
         --DBMS_OUTPUT.put_line ('Quantity Suggested: ' || v_qs);
         --DBMS_OUTPUT.put_line ('Available to Transact: ' || v_att);
         --DBMS_OUTPUT.put_line ('Available to Reserve: ' || v_atr);
         v_att := NVL (v_att, 0);
         v_qoh := NVL (v_qoh, 0);
         v_rqoh := NVL (v_atr, 0);                          --NVL (v_rqoh, 0);
      EXCEPTION
         WHEN OTHERS
         THEN
            v_qoh := 0;
            v_att := 0;
            v_rqoh := 0;
      --DBMS_OUTPUT.put_line ('ERROR: ' || SQLERRM);
      END;

      RETURN v_rqoh;
   END available_to_reserve;

--
   PROCEDURE split_line (p_transaction_hdr_id IN NUMBER, x_message OUT VARCHAR2)
   IS
      -- API variables
      l_header_rec                   oe_order_pub.header_rec_type;
      l_line_tbl                     oe_order_pub.line_tbl_type;
      l_line_tbl_nvl                 oe_order_pub.line_tbl_type;
      l_action_request_tbl           oe_order_pub.request_tbl_type;
      l_header_adj_tbl               oe_order_pub.header_adj_tbl_type;
      l_line_adj_tbl                 oe_order_pub.line_adj_tbl_type;
      l_header_scr_tbl               oe_order_pub.header_scredit_tbl_type;
      l_line_scredit_tbl             oe_order_pub.line_scredit_tbl_type;
      l_request_rec                  oe_order_pub.request_rec_type;
      l_return_status                VARCHAR2 (1000);
      l_msg_count                    NUMBER;
      l_msg_data                     VARCHAR2 (1000);
      l_wdd_delivery_detail_info     wsh_glbl_var_strct_grp.delivery_details_rec_type;
      l_wdd_update_status            VARCHAR2 (1000);
      p_api_version_number           NUMBER                            := 1.0;
      p_init_msg_list                VARCHAR2 (10)         := fnd_api.g_false;
      p_return_values                VARCHAR2 (10)         := fnd_api.g_false;
      p_action_commit                VARCHAR2 (10)         := fnd_api.g_false;
      x_return_status                VARCHAR2 (1);
      x_msg_count                    NUMBER;
      x_msg_data                     VARCHAR2 (100);
      p_header_rec                   oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      x_header_rec                   oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      p_old_header_rec               oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      p_header_val_rec               oe_order_pub.header_val_rec_type
                                        := oe_order_pub.g_miss_header_val_rec;
      p_old_header_val_rec           oe_order_pub.header_val_rec_type
                                        := oe_order_pub.g_miss_header_val_rec;
      p_header_adj_tbl               oe_order_pub.header_adj_tbl_type
                                        := oe_order_pub.g_miss_header_adj_tbl;
      p_old_header_adj_tbl           oe_order_pub.header_adj_tbl_type
                                        := oe_order_pub.g_miss_header_adj_tbl;
      p_header_adj_val_tbl           oe_order_pub.header_adj_val_tbl_type
                                    := oe_order_pub.g_miss_header_adj_val_tbl;
      p_old_header_adj_val_tbl       oe_order_pub.header_adj_val_tbl_type
                                    := oe_order_pub.g_miss_header_adj_val_tbl;
      p_header_price_att_tbl         oe_order_pub.header_price_att_tbl_type
                                  := oe_order_pub.g_miss_header_price_att_tbl;
      p_old_header_price_att_tbl     oe_order_pub.header_price_att_tbl_type
                                  := oe_order_pub.g_miss_header_price_att_tbl;
      p_header_adj_att_tbl           oe_order_pub.header_adj_att_tbl_type
                                    := oe_order_pub.g_miss_header_adj_att_tbl;
      p_old_header_adj_att_tbl       oe_order_pub.header_adj_att_tbl_type
                                    := oe_order_pub.g_miss_header_adj_att_tbl;
      p_header_adj_assoc_tbl         oe_order_pub.header_adj_assoc_tbl_type
                                  := oe_order_pub.g_miss_header_adj_assoc_tbl;
      p_old_header_adj_assoc_tbl     oe_order_pub.header_adj_assoc_tbl_type
                                  := oe_order_pub.g_miss_header_adj_assoc_tbl;
      p_header_scredit_tbl           oe_order_pub.header_scredit_tbl_type
                                    := oe_order_pub.g_miss_header_scredit_tbl;
      p_old_header_scredit_tbl       oe_order_pub.header_scredit_tbl_type
                                    := oe_order_pub.g_miss_header_scredit_tbl;
      p_header_scredit_val_tbl       oe_order_pub.header_scredit_val_tbl_type
                                := oe_order_pub.g_miss_header_scredit_val_tbl;
      p_old_header_scredit_val_tbl   oe_order_pub.header_scredit_val_tbl_type
                                := oe_order_pub.g_miss_header_scredit_val_tbl;
      x_line_tbl                     oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
      p_old_line_tbl                 oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
      p_line_val_tbl                 oe_order_pub.line_val_tbl_type
                                          := oe_order_pub.g_miss_line_val_tbl;
      p_old_line_val_tbl             oe_order_pub.line_val_tbl_type
                                          := oe_order_pub.g_miss_line_val_tbl;
      p_line_adj_tbl                 oe_order_pub.line_adj_tbl_type
                                          := oe_order_pub.g_miss_line_adj_tbl;
      p_old_line_adj_tbl             oe_order_pub.line_adj_tbl_type
                                          := oe_order_pub.g_miss_line_adj_tbl;
      p_line_adj_val_tbl             oe_order_pub.line_adj_val_tbl_type
                                      := oe_order_pub.g_miss_line_adj_val_tbl;
      p_old_line_adj_val_tbl         oe_order_pub.line_adj_val_tbl_type
                                      := oe_order_pub.g_miss_line_adj_val_tbl;
      p_line_price_att_tbl           oe_order_pub.line_price_att_tbl_type
                                    := oe_order_pub.g_miss_line_price_att_tbl;
      p_old_line_price_att_tbl       oe_order_pub.line_price_att_tbl_type
                                    := oe_order_pub.g_miss_line_price_att_tbl;
      p_line_adj_att_tbl             oe_order_pub.line_adj_att_tbl_type
                                      := oe_order_pub.g_miss_line_adj_att_tbl;
      p_old_line_adj_att_tbl         oe_order_pub.line_adj_att_tbl_type
                                      := oe_order_pub.g_miss_line_adj_att_tbl;
      p_line_adj_assoc_tbl           oe_order_pub.line_adj_assoc_tbl_type
                                    := oe_order_pub.g_miss_line_adj_assoc_tbl;
      p_old_line_adj_assoc_tbl       oe_order_pub.line_adj_assoc_tbl_type
                                    := oe_order_pub.g_miss_line_adj_assoc_tbl;
      p_line_scredit_tbl             oe_order_pub.line_scredit_tbl_type
                                      := oe_order_pub.g_miss_line_scredit_tbl;
      p_old_line_scredit_tbl         oe_order_pub.line_scredit_tbl_type
                                      := oe_order_pub.g_miss_line_scredit_tbl;
      p_line_scredit_val_tbl         oe_order_pub.line_scredit_val_tbl_type
                                  := oe_order_pub.g_miss_line_scredit_val_tbl;
      p_old_line_scredit_val_tbl     oe_order_pub.line_scredit_val_tbl_type
                                  := oe_order_pub.g_miss_line_scredit_val_tbl;
      p_lot_serial_tbl               oe_order_pub.lot_serial_tbl_type
                                        := oe_order_pub.g_miss_lot_serial_tbl;
      p_old_lot_serial_tbl           oe_order_pub.lot_serial_tbl_type
                                        := oe_order_pub.g_miss_lot_serial_tbl;
      p_lot_serial_val_tbl           oe_order_pub.lot_serial_val_tbl_type
                                    := oe_order_pub.g_miss_lot_serial_val_tbl;
      p_old_lot_serial_val_tbl       oe_order_pub.lot_serial_val_tbl_type
                                    := oe_order_pub.g_miss_lot_serial_val_tbl;
      p_action_request_tbl           oe_order_pub.request_tbl_type
                                           := oe_order_pub.g_miss_request_tbl;
      x_header_val_rec               oe_order_pub.header_val_rec_type;
      x_header_adj_tbl               oe_order_pub.header_adj_tbl_type;
      x_header_adj_val_tbl           oe_order_pub.header_adj_val_tbl_type;
      x_header_price_att_tbl         oe_order_pub.header_price_att_tbl_type;
      x_header_adj_att_tbl           oe_order_pub.header_adj_att_tbl_type;
      x_header_adj_assoc_tbl         oe_order_pub.header_adj_assoc_tbl_type;
      x_header_scredit_tbl           oe_order_pub.header_scredit_tbl_type;
      x_header_scredit_val_tbl       oe_order_pub.header_scredit_val_tbl_type;
      x_line_val_tbl                 oe_order_pub.line_val_tbl_type;
      x_line_adj_tbl                 oe_order_pub.line_adj_tbl_type;
      x_line_adj_val_tbl             oe_order_pub.line_adj_val_tbl_type;
      x_line_price_att_tbl           oe_order_pub.line_price_att_tbl_type;
      x_line_adj_att_tbl             oe_order_pub.line_adj_att_tbl_type;
      x_line_adj_assoc_tbl           oe_order_pub.line_adj_assoc_tbl_type;
      x_line_scredit_tbl             oe_order_pub.line_scredit_tbl_type;
      x_line_scredit_val_tbl         oe_order_pub.line_scredit_val_tbl_type;
      x_lot_serial_tbl               oe_order_pub.lot_serial_tbl_type;
      x_lot_serial_val_tbl           oe_order_pub.lot_serial_val_tbl_type;
      x_action_request_tbl           oe_order_pub.request_tbl_type;
      x_debug_file                   VARCHAR2 (100);
      p_line_tbl                     oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
                                                        -- added on 16aug PwC
      -- Local Variables
      l_msg_index_out                NUMBER (10);
      l_line_tbl_index               NUMBER;
      l_header_id                    NUMBER;
      l_item_id                      NUMBER;
      l_ordered_qty                  NUMBER;
      l_shp_pr_no                    NUMBER;
      l_item                         VARCHAR2 (2000);
      l_lookup_code                  VARCHAR2 (1000);
      l_order_num                    NUMBER;
      l_user_id                      NUMBER;
      l_appl_short_name              VARCHAR2 (100);
      l_resp_id                      NUMBER;
      l_appl_id                      NUMBER;
      l_cust_account_id              NUMBER;
      l_error_flag                   VARCHAR2 (1);
      l_unit_sell_price              NUMBER;
      l_uom                          VARCHAR2 (100);
      lv_ssrtl_oe_line_id            VARCHAR2 (10);
      lv_sec_uom_code                VARCHAR2 (10)                    := NULL;
      ln_conv_rate                   NUMBER;
      ln_sec_conv_rate               NUMBER;
      ln_base_uom_conv               NUMBER;
      ln_ship_from_org_id            NUMBER;
      lv_item_cat                    VARCHAR2 (100);
      ln_hold_count                  NUMBER;
   BEGIN
      BEGIN
         SELECT fnd.user_id, application.application_short_name,
                fresp.responsibility_id, fresp.application_id
           INTO l_user_id, l_appl_short_name,
                l_resp_id, l_appl_id
           FROM fnd_user fnd,
                fnd_responsibility_tl fresp,
                fnd_application application
          WHERE fnd.user_name = fnd_global.user_name
            AND fresp.application_id = application.application_id
            AND fresp.responsibility_name = fnd_profile.VALUE ('RESP_NAME');
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_flag := 'Y';
      END;

      -- Split Order Lines
      fnd_global.apps_initialize (l_user_id, l_resp_id, l_appl_id);
      oe_msg_pub.initialize;
      oe_debug_pub.initialize;
      mo_global.init (l_appl_short_name);                  -- Required for R12
      mo_global.set_org_context (fnd_profile.VALUE ('ORG_ID'),
                                 NULL,
                                 l_appl_short_name
                                );
      --fnd_global.set_nls_context ('AMERICAN');
      mo_global.set_policy_context ('S', fnd_profile.VALUE ('ORG_ID'));

      FOR rec_line IN
         (SELECT line.*, oola.ordered_quantity, oola.ordered_quantity2
            FROM xxdbl_transpoter_headers xxth,
                 xxdbl_transpoter_line xxtl,
                 xxdbl_omshipping_line line,
                 oe_order_lines_all oola
           WHERE 1 = 1
             AND xxth.transpoter_header_id = xxtl.transpoter_header_id
             AND xxth.transpoter_header_id = p_transaction_hdr_id
             AND xxtl.delivery_challan_number = line.delivery_challan_number
             AND line.order_line_id = oola.line_id
             AND ROUND (NVL (oola.ordered_quantity, 0), 5) <>
                                      ROUND (NVL (line.picking_qty_crt, 0), 5)
             AND line.omshipping_line_status NOT IN
                                       ('CANCELLED') --('CLOSED', 'CANCELLED')
             AND oola.flow_status_code = 'AWAITING_SHIPPING')
      LOOP
         --This is to UPDATE order line
         l_line_tbl_index := 1;
         -- Changed attributes
         l_header_rec := oe_order_pub.g_miss_header_rec;
         l_header_rec.header_id := rec_line.order_id;
         l_header_rec.operation := oe_globals.g_opr_update;
         l_line_tbl (l_line_tbl_index) := oe_order_pub.g_miss_line_rec;
         l_line_tbl (l_line_tbl_index).operation := oe_globals.g_opr_update;
         l_line_tbl (l_line_tbl_index).split_by := fnd_global.user_id;
         -- user_id
         l_line_tbl (l_line_tbl_index).split_action_code := 'SPLIT';
         l_line_tbl (l_line_tbl_index).header_id := rec_line.order_id;
         l_line_tbl (l_line_tbl_index).line_id :=
                                           TO_NUMBER (rec_line.order_line_id);
         l_line_tbl (l_line_tbl_index).attribute1 :=
                                                  rec_line.omshipping_line_id;
         --6431;
         l_line_tbl (l_line_tbl_index).ordered_quantity :=
                                         TO_NUMBER (rec_line.picking_qty_crt);
         l_line_tbl (l_line_tbl_index).ordered_quantity2 :=
                                         TO_NUMBER (rec_line.picking_qty_sft);
         l_line_tbl (l_line_tbl_index).change_reason := 'MISC';
         -- change reason code
         l_line_tbl_index := 2;
         l_line_tbl (l_line_tbl_index).header_id := rec_line.order_id;
         l_line_tbl (l_line_tbl_index) := oe_order_pub.g_miss_line_rec;
         l_line_tbl (l_line_tbl_index).operation := oe_globals.g_opr_create;
         l_line_tbl (l_line_tbl_index).split_by := fnd_global.user_id;
         -- user_id
         l_line_tbl (l_line_tbl_index).split_action_code := 'SPLIT';
         l_line_tbl (l_line_tbl_index).split_from_line_id :=
                                           TO_NUMBER (rec_line.order_line_id);
         l_line_tbl (l_line_tbl_index).inventory_item_id := rec_line.item_id;
         l_line_tbl (l_line_tbl_index).ordered_quantity :=
            (  NVL (rec_line.ordered_quantity, 0)
             --NVL (rec_line.attribute3, 0)
             - NVL (rec_line.picking_qty_crt, 0)
            );
         l_line_tbl (l_line_tbl_index).ordered_quantity2 :=
            (  NVL (rec_line.ordered_quantity2, 0)
             -- NVL (rec_line.attribute4, 0)
             - NVL (rec_line.picking_qty_sft, 0)
            );
         -- CALL TO PROCESS ORDER
         oe_order_pub.process_order
                        (p_api_version_number          => 1.0,
                         p_init_msg_list               => fnd_api.g_false,
                         p_return_values               => fnd_api.g_false,
                         p_action_commit               => fnd_api.g_false,
                         x_return_status               => l_return_status,
                         x_msg_count                   => l_msg_count,
                         x_msg_data                    => l_msg_data,
                         p_header_rec                  => l_header_rec,
                         p_line_tbl                    => l_line_tbl,
                         p_action_request_tbl          => l_action_request_tbl
                                                                              -- OUT PARAMETERS
         ,
                         x_header_rec                  => p_header_rec,
                         -- added on 16aug PwC
                         x_header_val_rec              => x_header_val_rec,
                         x_header_adj_tbl              => x_header_adj_tbl,
                         x_header_adj_val_tbl          => x_header_adj_val_tbl,
                         x_header_price_att_tbl        => x_header_price_att_tbl,
                         x_header_adj_att_tbl          => x_header_adj_att_tbl,
                         x_header_adj_assoc_tbl        => x_header_adj_assoc_tbl,
                         x_header_scredit_tbl          => x_header_scredit_tbl,
                         x_header_scredit_val_tbl      => x_header_scredit_val_tbl,
                         x_line_tbl                    => p_line_tbl,
                         -- added on 16aug PwC
                         x_line_val_tbl                => x_line_val_tbl,
                         x_line_adj_tbl                => x_line_adj_tbl,
                         x_line_adj_val_tbl            => x_line_adj_val_tbl,
                         x_line_price_att_tbl          => x_line_price_att_tbl,
                         x_line_adj_att_tbl            => x_line_adj_att_tbl,
                         x_line_adj_assoc_tbl          => x_line_adj_assoc_tbl,
                         x_line_scredit_tbl            => x_line_scredit_tbl,
                         x_line_scredit_val_tbl        => x_line_scredit_val_tbl,
                         x_lot_serial_tbl              => x_lot_serial_tbl,
                         x_lot_serial_val_tbl          => x_lot_serial_val_tbl,
                         x_action_request_tbl          => p_action_request_tbl
                        -- added on 16aug PwC
                        );

         --dbms_output.put_line('OM Debug file: ' ||oe_debug_pub.G_DIR||'/'||oe_debug_pub.G_FILE);
         FOR i IN 1 .. l_msg_count
         LOOP
            oe_msg_pub.get (p_msg_index          => i,
                            p_encoded            => fnd_api.g_false,
                            p_data               => l_msg_data,
                            p_msg_index_out      => l_msg_index_out
                           );
         -- DBMS_OUTPUT.put_line ('message is: ' || l_msg_data);
         -- DBMS_OUTPUT.put_line ('message index is: ' || l_msg_index_out);
         END LOOP;

         -- Check the return status
         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            x_message :=
                  x_message
               || CHR (10)
               || 'Split Line Failed for Sales Order: '
               || rec_line.order_number
               || ' and Order Line No: '
               || rec_line.order_line_no
               || ' and item: '
               || rec_line.item_code
               || '.'
               || l_msg_data;
         END IF;
      END LOOP;

      IF x_message IS NULL
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END split_line;

   PROCEDURE split_line_new (
      p_omshipping_header_id   IN       NUMBER,
      p_omshipping_line_id     IN       NUMBER,
      x_message                OUT      VARCHAR2
   )
   IS
      -- API variables
      l_header_rec                   oe_order_pub.header_rec_type;
      l_line_tbl                     oe_order_pub.line_tbl_type;
      l_line_tbl_nvl                 oe_order_pub.line_tbl_type;
      l_action_request_tbl           oe_order_pub.request_tbl_type;
      l_header_adj_tbl               oe_order_pub.header_adj_tbl_type;
      l_line_adj_tbl                 oe_order_pub.line_adj_tbl_type;
      l_header_scr_tbl               oe_order_pub.header_scredit_tbl_type;
      l_line_scredit_tbl             oe_order_pub.line_scredit_tbl_type;
      l_request_rec                  oe_order_pub.request_rec_type;
      l_return_status                VARCHAR2 (1000);
      l_msg_count                    NUMBER;
      l_msg_data                     VARCHAR2 (1000);
      l_wdd_delivery_detail_info     wsh_glbl_var_strct_grp.delivery_details_rec_type;
      l_wdd_update_status            VARCHAR2 (1000);
      p_api_version_number           NUMBER                            := 1.0;
      p_init_msg_list                VARCHAR2 (10)         := fnd_api.g_false;
      p_return_values                VARCHAR2 (10)         := fnd_api.g_false;
      p_action_commit                VARCHAR2 (10)         := fnd_api.g_false;
      x_return_status                VARCHAR2 (1);
      x_msg_count                    NUMBER;
      x_msg_data                     VARCHAR2 (100);
      p_header_rec                   oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      x_header_rec                   oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      p_old_header_rec               oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      p_header_val_rec               oe_order_pub.header_val_rec_type
                                        := oe_order_pub.g_miss_header_val_rec;
      p_old_header_val_rec           oe_order_pub.header_val_rec_type
                                        := oe_order_pub.g_miss_header_val_rec;
      p_header_adj_tbl               oe_order_pub.header_adj_tbl_type
                                        := oe_order_pub.g_miss_header_adj_tbl;
      p_old_header_adj_tbl           oe_order_pub.header_adj_tbl_type
                                        := oe_order_pub.g_miss_header_adj_tbl;
      p_header_adj_val_tbl           oe_order_pub.header_adj_val_tbl_type
                                    := oe_order_pub.g_miss_header_adj_val_tbl;
      p_old_header_adj_val_tbl       oe_order_pub.header_adj_val_tbl_type
                                    := oe_order_pub.g_miss_header_adj_val_tbl;
      p_header_price_att_tbl         oe_order_pub.header_price_att_tbl_type
                                  := oe_order_pub.g_miss_header_price_att_tbl;
      p_old_header_price_att_tbl     oe_order_pub.header_price_att_tbl_type
                                  := oe_order_pub.g_miss_header_price_att_tbl;
      p_header_adj_att_tbl           oe_order_pub.header_adj_att_tbl_type
                                    := oe_order_pub.g_miss_header_adj_att_tbl;
      p_old_header_adj_att_tbl       oe_order_pub.header_adj_att_tbl_type
                                    := oe_order_pub.g_miss_header_adj_att_tbl;
      p_header_adj_assoc_tbl         oe_order_pub.header_adj_assoc_tbl_type
                                  := oe_order_pub.g_miss_header_adj_assoc_tbl;
      p_old_header_adj_assoc_tbl     oe_order_pub.header_adj_assoc_tbl_type
                                  := oe_order_pub.g_miss_header_adj_assoc_tbl;
      p_header_scredit_tbl           oe_order_pub.header_scredit_tbl_type
                                    := oe_order_pub.g_miss_header_scredit_tbl;
      p_old_header_scredit_tbl       oe_order_pub.header_scredit_tbl_type
                                    := oe_order_pub.g_miss_header_scredit_tbl;
      p_header_scredit_val_tbl       oe_order_pub.header_scredit_val_tbl_type
                                := oe_order_pub.g_miss_header_scredit_val_tbl;
      p_old_header_scredit_val_tbl   oe_order_pub.header_scredit_val_tbl_type
                                := oe_order_pub.g_miss_header_scredit_val_tbl;
      x_line_tbl                     oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
      p_old_line_tbl                 oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
      p_line_val_tbl                 oe_order_pub.line_val_tbl_type
                                          := oe_order_pub.g_miss_line_val_tbl;
      p_old_line_val_tbl             oe_order_pub.line_val_tbl_type
                                          := oe_order_pub.g_miss_line_val_tbl;
      p_line_adj_tbl                 oe_order_pub.line_adj_tbl_type
                                          := oe_order_pub.g_miss_line_adj_tbl;
      p_old_line_adj_tbl             oe_order_pub.line_adj_tbl_type
                                          := oe_order_pub.g_miss_line_adj_tbl;
      p_line_adj_val_tbl             oe_order_pub.line_adj_val_tbl_type
                                      := oe_order_pub.g_miss_line_adj_val_tbl;
      p_old_line_adj_val_tbl         oe_order_pub.line_adj_val_tbl_type
                                      := oe_order_pub.g_miss_line_adj_val_tbl;
      p_line_price_att_tbl           oe_order_pub.line_price_att_tbl_type
                                    := oe_order_pub.g_miss_line_price_att_tbl;
      p_old_line_price_att_tbl       oe_order_pub.line_price_att_tbl_type
                                    := oe_order_pub.g_miss_line_price_att_tbl;
      p_line_adj_att_tbl             oe_order_pub.line_adj_att_tbl_type
                                      := oe_order_pub.g_miss_line_adj_att_tbl;
      p_old_line_adj_att_tbl         oe_order_pub.line_adj_att_tbl_type
                                      := oe_order_pub.g_miss_line_adj_att_tbl;
      p_line_adj_assoc_tbl           oe_order_pub.line_adj_assoc_tbl_type
                                    := oe_order_pub.g_miss_line_adj_assoc_tbl;
      p_old_line_adj_assoc_tbl       oe_order_pub.line_adj_assoc_tbl_type
                                    := oe_order_pub.g_miss_line_adj_assoc_tbl;
      p_line_scredit_tbl             oe_order_pub.line_scredit_tbl_type
                                      := oe_order_pub.g_miss_line_scredit_tbl;
      p_old_line_scredit_tbl         oe_order_pub.line_scredit_tbl_type
                                      := oe_order_pub.g_miss_line_scredit_tbl;
      p_line_scredit_val_tbl         oe_order_pub.line_scredit_val_tbl_type
                                  := oe_order_pub.g_miss_line_scredit_val_tbl;
      p_old_line_scredit_val_tbl     oe_order_pub.line_scredit_val_tbl_type
                                  := oe_order_pub.g_miss_line_scredit_val_tbl;
      p_lot_serial_tbl               oe_order_pub.lot_serial_tbl_type
                                        := oe_order_pub.g_miss_lot_serial_tbl;
      p_old_lot_serial_tbl           oe_order_pub.lot_serial_tbl_type
                                        := oe_order_pub.g_miss_lot_serial_tbl;
      p_lot_serial_val_tbl           oe_order_pub.lot_serial_val_tbl_type
                                    := oe_order_pub.g_miss_lot_serial_val_tbl;
      p_old_lot_serial_val_tbl       oe_order_pub.lot_serial_val_tbl_type
                                    := oe_order_pub.g_miss_lot_serial_val_tbl;
      p_action_request_tbl           oe_order_pub.request_tbl_type
                                           := oe_order_pub.g_miss_request_tbl;
      x_header_val_rec               oe_order_pub.header_val_rec_type;
      x_header_adj_tbl               oe_order_pub.header_adj_tbl_type;
      x_header_adj_val_tbl           oe_order_pub.header_adj_val_tbl_type;
      x_header_price_att_tbl         oe_order_pub.header_price_att_tbl_type;
      x_header_adj_att_tbl           oe_order_pub.header_adj_att_tbl_type;
      x_header_adj_assoc_tbl         oe_order_pub.header_adj_assoc_tbl_type;
      x_header_scredit_tbl           oe_order_pub.header_scredit_tbl_type;
      x_header_scredit_val_tbl       oe_order_pub.header_scredit_val_tbl_type;
      x_line_val_tbl                 oe_order_pub.line_val_tbl_type;
      x_line_adj_tbl                 oe_order_pub.line_adj_tbl_type;
      x_line_adj_val_tbl             oe_order_pub.line_adj_val_tbl_type;
      x_line_price_att_tbl           oe_order_pub.line_price_att_tbl_type;
      x_line_adj_att_tbl             oe_order_pub.line_adj_att_tbl_type;
      x_line_adj_assoc_tbl           oe_order_pub.line_adj_assoc_tbl_type;
      x_line_scredit_tbl             oe_order_pub.line_scredit_tbl_type;
      x_line_scredit_val_tbl         oe_order_pub.line_scredit_val_tbl_type;
      x_lot_serial_tbl               oe_order_pub.lot_serial_tbl_type;
      x_lot_serial_val_tbl           oe_order_pub.lot_serial_val_tbl_type;
      x_action_request_tbl           oe_order_pub.request_tbl_type;
      x_debug_file                   VARCHAR2 (100);
      p_line_tbl                     oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
                                                        -- added on 16aug PwC
      -- Local Variables
      l_msg_index_out                NUMBER (10);
      l_line_tbl_index               NUMBER;
      l_header_id                    NUMBER;
      l_item_id                      NUMBER;
      l_ordered_qty                  NUMBER;
      l_shp_pr_no                    NUMBER;
      l_item                         VARCHAR2 (2000);
      l_lookup_code                  VARCHAR2 (1000);
      l_order_num                    NUMBER;
      l_user_id                      NUMBER;
      l_appl_short_name              VARCHAR2 (100);
      l_resp_id                      NUMBER;
      l_appl_id                      NUMBER;
      l_cust_account_id              NUMBER;
      l_error_flag                   VARCHAR2 (1);
      l_unit_sell_price              NUMBER;
      l_uom                          VARCHAR2 (100);
      lv_ssrtl_oe_line_id            VARCHAR2 (10);
      lv_sec_uom_code                VARCHAR2 (10)                    := NULL;
      ln_conv_rate                   NUMBER;
      ln_sec_conv_rate               NUMBER;
      ln_base_uom_conv               NUMBER;
      ln_ship_from_org_id            NUMBER;
      lv_item_cat                    VARCHAR2 (100);
      ln_hold_count                  NUMBER;
   BEGIN
      BEGIN
         SELECT fnd.user_id, application.application_short_name,
                fresp.responsibility_id, fresp.application_id
           INTO l_user_id, l_appl_short_name,
                l_resp_id, l_appl_id
           FROM fnd_user fnd,
                fnd_responsibility_tl fresp,
                fnd_application application
          WHERE fnd.user_name = fnd_global.user_name
            AND fresp.application_id = application.application_id
            AND fresp.responsibility_name = fnd_profile.VALUE ('RESP_NAME');
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_flag := 'Y';
      END;

      -- Split Order Lines
      fnd_global.apps_initialize (l_user_id, l_resp_id, l_appl_id);
      oe_msg_pub.initialize;
      oe_debug_pub.initialize;
      mo_global.init (l_appl_short_name);                  -- Required for R12
      mo_global.set_org_context (fnd_profile.VALUE ('ORG_ID'),
                                 NULL,
                                 l_appl_short_name
                                );
      --fnd_global.set_nls_context ('AMERICAN');
      mo_global.set_policy_context ('S', fnd_profile.VALUE ('ORG_ID'));

      FOR rec_line IN
         (SELECT line.*, oola.ordered_quantity, oola.ordered_quantity2,
                 oola.unit_list_price, oola.unit_selling_price
            FROM xxdbl_omshipping_line line, oe_order_lines_all oola
           WHERE 1 = 1
             AND line.omshipping_header_id = p_omshipping_header_id
             AND line.omshipping_line_id = p_omshipping_line_id
             AND line.order_line_id = oola.line_id
             AND ROUND (NVL (oola.ordered_quantity, 0), 5) <>
                                      ROUND (NVL (line.picking_qty_crt, 0), 5)
             AND line.omshipping_line_status NOT IN
                                       ('CANCELLED') --('CLOSED', 'CANCELLED')
             AND oola.flow_status_code = 'AWAITING_SHIPPING')
      LOOP
         --This is to UPDATE order line
         /*debug_insert (   'rec_line.unit_list_price:       '
                       || rec_line.unit_list_price
                      );
         debug_insert (   'rec_line.unit_selling_price:       '
                       || rec_line.unit_selling_price
                      );
         debug_insert (   'TO_NUMBER (rec_line.order_line_id):       '
                       || TO_NUMBER (rec_line.order_line_id)
                      );
         debug_insert ('rec_line.order_id:       ' || rec_line.order_id);*/
         l_line_tbl_index := 1;
         -- Changed attributes
         l_header_rec := oe_order_pub.g_miss_header_rec;
         l_header_rec.header_id := rec_line.order_id;
         l_header_rec.operation := oe_globals.g_opr_update;
         l_line_tbl (l_line_tbl_index) := oe_order_pub.g_miss_line_rec;
         l_line_tbl (l_line_tbl_index).operation := oe_globals.g_opr_update;
         l_line_tbl (l_line_tbl_index).split_by := fnd_global.user_id;
         -- user_id
         l_line_tbl (l_line_tbl_index).split_action_code := 'SPLIT';
         l_line_tbl (l_line_tbl_index).header_id := rec_line.order_id;
         l_line_tbl (l_line_tbl_index).line_id :=
                                           TO_NUMBER (rec_line.order_line_id);
         l_line_tbl (l_line_tbl_index).global_attribute1 :=
                                                  rec_line.omshipping_line_id;
                                                          -- ADDED BY MONOJIT
         --6431;
         l_line_tbl (l_line_tbl_index).ordered_quantity :=
                                         TO_NUMBER (rec_line.picking_qty_crt);
         l_line_tbl (l_line_tbl_index).ordered_quantity2 :=
                                         TO_NUMBER (rec_line.picking_qty_sft);
         l_line_tbl (l_line_tbl_index).change_reason := 'MISC';
         -- change reason code
         l_line_tbl_index := 2;
         l_line_tbl (l_line_tbl_index).header_id := rec_line.order_id;
         l_line_tbl (l_line_tbl_index) := oe_order_pub.g_miss_line_rec;
         l_line_tbl (l_line_tbl_index).operation := oe_globals.g_opr_create;
         l_line_tbl (l_line_tbl_index).split_by := fnd_global.user_id;
         -- user_id
         l_line_tbl (l_line_tbl_index).split_action_code := 'SPLIT';
         l_line_tbl (l_line_tbl_index).split_from_line_id :=
                                           TO_NUMBER (rec_line.order_line_id);
         l_line_tbl (l_line_tbl_index).inventory_item_id := rec_line.item_id;
         l_line_tbl (l_line_tbl_index).unit_list_price :=
                                                     rec_line.unit_list_price;
         l_line_tbl (l_line_tbl_index).unit_selling_price :=
                                                  rec_line.unit_selling_price;
         l_line_tbl (l_line_tbl_index).ordered_quantity :=
            (  NVL (rec_line.ordered_quantity, 0)
             --NVL (rec_line.attribute3, 0)
             - NVL (rec_line.picking_qty_crt, 0)
            );
         l_line_tbl (l_line_tbl_index).ordered_quantity2 :=
            (  NVL (rec_line.ordered_quantity2, 0)
             -- NVL (rec_line.attribute4, 0)
             - NVL (rec_line.picking_qty_sft, 0)
            );
         -- CALL TO PROCESS ORDER
         oe_order_pub.process_order
                        (p_api_version_number          => 1.0,
                         p_init_msg_list               => fnd_api.g_false,
                         p_return_values               => fnd_api.g_false,
                         p_action_commit               => fnd_api.g_false,
                         x_return_status               => l_return_status,
                         x_msg_count                   => l_msg_count,
                         x_msg_data                    => l_msg_data,
                         p_header_rec                  => l_header_rec,
                         p_line_tbl                    => l_line_tbl,
                         p_action_request_tbl          => l_action_request_tbl
                                                                              -- OUT PARAMETERS
         ,
                         x_header_rec                  => p_header_rec,
                         -- added on 16aug PwC
                         x_header_val_rec              => x_header_val_rec,
                         x_header_adj_tbl              => x_header_adj_tbl,
                         x_header_adj_val_tbl          => x_header_adj_val_tbl,
                         x_header_price_att_tbl        => x_header_price_att_tbl,
                         x_header_adj_att_tbl          => x_header_adj_att_tbl,
                         x_header_adj_assoc_tbl        => x_header_adj_assoc_tbl,
                         x_header_scredit_tbl          => x_header_scredit_tbl,
                         x_header_scredit_val_tbl      => x_header_scredit_val_tbl,
                         x_line_tbl                    => p_line_tbl,
                         -- added on 16aug PwC
                         x_line_val_tbl                => x_line_val_tbl,
                         x_line_adj_tbl                => x_line_adj_tbl,
                         x_line_adj_val_tbl            => x_line_adj_val_tbl,
                         x_line_price_att_tbl          => x_line_price_att_tbl,
                         x_line_adj_att_tbl            => x_line_adj_att_tbl,
                         x_line_adj_assoc_tbl          => x_line_adj_assoc_tbl,
                         x_line_scredit_tbl            => x_line_scredit_tbl,
                         x_line_scredit_val_tbl        => x_line_scredit_val_tbl,
                         x_lot_serial_tbl              => x_lot_serial_tbl,
                         x_lot_serial_val_tbl          => x_lot_serial_val_tbl,
                         x_action_request_tbl          => p_action_request_tbl
                        -- added on 16aug PwC
                        );

         --debug_insert ('l_return_status:       ' || l_return_status);

         --dbms_output.put_line('OM Debug file: ' ||oe_debug_pub.G_DIR||'/'||oe_debug_pub.G_FILE);
         FOR i IN 1 .. l_msg_count
         LOOP
            oe_msg_pub.get (p_msg_index          => i,
                            p_encoded            => fnd_api.g_false,
                            p_data               => l_msg_data,
                            p_msg_index_out      => l_msg_index_out
                           );
         -- DBMS_OUTPUT.put_line ('message is: ' || l_msg_data);
         -- DBMS_OUTPUT.put_line ('message index is: ' || l_msg_index_out);
         END LOOP;

         -- Check the return status
         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            x_message :=
                  x_message
               || CHR (10)
               || 'Split Line Failed for Sales Order: '
               || rec_line.order_number
               || ' and Order Line No: '
               || rec_line.order_line_no
               || ' and item: '
               || rec_line.item_code
               || '.'
               || l_msg_data;
         END IF;
      END LOOP;

      IF x_message IS NULL
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END split_line_new;

   PROCEDURE create_update_reservations (
      p_transaction_hdr_id   IN       NUMBER,
      x_message              OUT      VARCHAR2
   )
   IS
      l_current_reservation_id   NUMBER                                 := -1;
      l_record_count             NUMBER                                  := 1;
      l_rsv                      inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_del                  inv_reservation_global.mtl_reservation_rec_type;
      l_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_msg_count                NUMBER;
      x_msg_data                 VARCHAR2 (240);
      x_rsv_id                   NUMBER;
      x_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_status                   VARCHAR2 (1);
      x_qty                      NUMBER;
      lx_status                  VARCHAR2 (1);
      lx_msg_count               NUMBER;
      lx_msg_data                VARCHAR2 (240);
      lv_rsv                     inv_reservation_global.mtl_reservation_rec_type;
      lv_dummy_sn                inv_reservation_global.serial_number_tbl_type;
      l_sales_order_id           NUMBER;
      l_current_atr              NUMBER                                  := 0;
   BEGIN
      FOR rec_line IN
         (SELECT lines.customer_number, lines.customer_name,
                 lines.customer_id, lines.order_number, lines.order_id,
                 lines.ship_to_warehouse, lines.warehouse_id,
                 lines.order_line_no,
                 NVL (lines.attribute3, 0) original_line_pri_qty,
                 ROUND (NVL (lines.picking_qty_crt, 0), 5) picking_qty_crt,
                 NVL (lines.attribute4, 0) original_line_sec_qty,
                 ROUND (NVL (lines.picking_qty_sft, 0), 5) picking_qty_sft,
                 lines.order_line_id, lines.attribute1 primary_uom,
                 lines.attribute2 sececondary_uom, line_lot.*
            FROM xxdbl_transpoter_headers xxth,
                 xxdbl_transpoter_line xxtl,
                 xxdbl_omshipping_line lines,
                 xxdbl_omshipping_lot_lines line_lot
           WHERE 1 = 1
             AND xxth.transpoter_header_id = xxtl.transpoter_header_id
             AND xxth.transpoter_header_id = p_transaction_hdr_id
             AND xxtl.delivery_challan_number = lines.delivery_challan_number
             AND NVL (lines.attribute5, '1') = '2'
             AND line_lot.attribute1 IS NULL
             AND lines.omshipping_line_status NOT IN
                                       ('CANCELLED') --('CLOSED', 'CANCELLED')
             AND lines.omshipping_line_id = line_lot.omshipping_line_id
             AND NOT EXISTS (
                    SELECT 'X'
                      FROM mtl_reservations mr
                     WHERE mr.demand_source_line_id = lines.order_line_id
                       AND mr.lot_number IS NOT NULL))
      LOOP
         --debug_insert ('rec_line.lot_number:        ' || rec_line.lot_number);
         SELECT xxdbl_shiping_tran_crp_pkg.available_to_reserve
                           (p_organization_id        => rec_line.warehouse_id,
                            p_inventory_item_id      => rec_line.item_id,
                            p_subinventory_code      => rec_line.subinventory_code,
                            p_locator_id             => rec_line.locator_id,
                            p_lot_number             => rec_line.lot_number
                           )
           INTO l_current_atr
           FROM DUAL;

         IF l_current_atr < rec_line.quantity_crt
         THEN
            IF x_message IS NULL
            THEN
               x_message :=
                     'Create Reservation Error: '
                  || 'Current Available to Reserve for the Item '
                  || rec_line.item_code
                  || ' and Lot Number '
                  || rec_line.lot_number
                  || ' is not sufficient to create reservation. ';
            ELSE
               x_message :=
                     x_message
                  || CHR (10)
                  || 'Current Available to Reserve for the Item '
                  || rec_line.item_code
                  || ' and Lot Number '
                  || rec_line.lot_number
                  || ' is not sufficient to create reservation. ';
            END IF;
         ELSE
            /*IF l_record_count = 1
            THEN*/
            BEGIN
               SELECT mr.reservation_id
                 INTO l_current_reservation_id
                 FROM mtl_reservations mr
                WHERE mr.organization_id = rec_line.warehouse_id
                  AND mr.inventory_item_id = rec_line.item_id
                  AND mr.demand_source_type_id = 2
                  --AND demand_source_header_id = rec_line.order_id
                  AND mr.demand_source_line_id = rec_line.order_line_id
                  AND mr.supply_source_type_id = 13
                  AND mr.orig_supply_source_type_id = 13
                  AND mr.orig_demand_source_type_id = 2
                  --AND orig_demand_source_header_id = rec_line.order_id
                  AND mr.orig_demand_source_line_id = rec_line.order_line_id
                  AND mr.lot_number IS NULL
                  AND NOT EXISTS (SELECT 'X'
                                    FROM xxdbl_omshipping_lot_lines xx
                                   WHERE xx.attribute1 = mr.reservation_id);
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_current_reservation_id := -1;
            END;

            --debug_insert (   'l_current_reservation_id:        '|| l_current_reservation_id);
            IF rec_line.original_line_pri_qty = rec_line.picking_qty_crt
            THEN
               -- Delete Reservation
               IF l_current_reservation_id > 0
               THEN
                  l_rsv_del.reservation_id := l_current_reservation_id;

                  INSERT INTO xxdbl.xxdbl_mtl_reservations
                     SELECT *
                       FROM mtl_reservations
                      WHERE reservation_id = l_current_reservation_id;

                  --debug_insert('inv_reservation_pub.delete_reservation:        ');
                  inv_reservation_pub.delete_reservation
                                           (p_api_version_number      => 1.0,
                                            p_init_msg_lst            => fnd_api.g_true,
                                            x_return_status           => lx_status,
                                            x_msg_count               => lx_msg_count,
                                            x_msg_data                => lx_msg_data,
                                            p_rsv_rec                 => l_rsv_del,
                                            p_serial_number           => lv_dummy_sn
                                           );

                  IF lx_status <> fnd_api.g_ret_sts_success
                  THEN
                     IF lx_msg_count > 1
                     THEN
                        FOR i IN 1 .. lx_msg_count
                        LOOP
                           IF x_message IS NULL
                           THEN
                              x_message :=
                                    'Delete Reservation Error: '
                                 || i
                                 || '. '
                                 || SUBSTR
                                       (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                        1,
                                        255
                                       );
                           ELSE
                              x_message :=
                                    x_message
                                 || 'Delete Reservation Error: '
                                 || i
                                 || '. '
                                 || SUBSTR
                                       (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                        1,
                                        255
                                       );
                           END IF;
                        END LOOP;
                     ELSIF lx_msg_count = 1
                     THEN
                        IF x_message IS NULL
                        THEN
                           x_message :=
                                  'Delete Reservation Error: ' || lx_msg_data;
                        ELSE
                           x_message :=
                                 x_message
                              || 'Delete Reservation Error: '
                              || lx_msg_data;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            ELSE
               -- Update Reservation
               NULL;
            END IF;

            --END IF;

            /*IF l_current_reservation_id > -2
            THEN*/
            --debug_insert ('rec_line.order_number:        ' || rec_line.order_number);
            BEGIN
               SELECT sales_order_id
                 INTO l_sales_order_id
                 FROM mtl_sales_orders
                WHERE segment1 = rec_line.order_number || '';
            EXCEPTION
               WHEN OTHERS
               THEN
                  --debug_insert ('Error:        ' || sqlerrm);
                  l_sales_order_id := -1;
            END;

            --debug_insert ('l_sales_order_id:        ' || l_sales_order_id);
            IF l_sales_order_id < 0
            THEN
               IF x_message IS NULL
               THEN
                  x_message :=
                        'Unable to find Sales Order '
                     || rec_line.order_number
                     || '  Lot Number:     '
                     || rec_line.lot_number;
               ELSE
                  x_message :=
                        x_message
                     || CHR (10)
                     || 'Unable to find Sales Order '
                     || rec_line.order_number
                     || '  Lot Number:     '
                     || rec_line.lot_number;
               END IF;
            ELSE
               l_rsv.requirement_date := SYSDATE;
               l_rsv.organization_id := rec_line.warehouse_id;
               --mtl_parameters.organization id
               l_rsv.inventory_item_id := rec_line.item_id;
               --mtl_system_items.Inventory_item_id;
               l_rsv.demand_source_name := NULL;
               l_rsv.demand_source_type_id := 2;
               l_rsv.demand_source_header_id := l_sales_order_id;
               --1334166 ; --mtl_sales_orders.sales_order_id
               l_rsv.demand_source_line_id := rec_line.order_line_id;
               --4912468 ; -- oe_order_lines.line_id
               l_rsv.primary_uom_code := rec_line.primary_uom;
               l_rsv.primary_uom_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.autodetail_group_id := NULL;
               l_rsv.external_source_code := NULL;
               l_rsv.external_source_line_id := NULL;
               l_rsv.supply_source_header_id := NULL;
               l_rsv.supply_source_line_id := NULL;
               l_rsv.supply_source_name := NULL;
               l_rsv.supply_source_line_detail := NULL;
               l_rsv.revision := NULL;
               l_rsv.subinventory_id := NULL;
               l_rsv.lot_number_id := NULL;
               l_rsv.pick_slip_number := NULL;
               l_rsv.lpn_id := NULL;
               l_rsv.attribute_category := NULL;
               l_rsv.attribute1 := NULL;
               l_rsv.attribute2 := NULL;
               l_rsv.attribute3 := NULL;
               l_rsv.attribute4 := NULL;
               l_rsv.attribute5 := NULL;
               l_rsv.attribute6 := NULL;
               l_rsv.attribute7 := NULL;
               l_rsv.attribute8 := NULL;
               l_rsv.attribute9 := NULL;
               l_rsv.attribute10 := NULL;
               l_rsv.attribute11 := NULL;
               l_rsv.attribute12 := NULL;
               l_rsv.attribute13 := NULL;
               l_rsv.attribute14 := NULL;
               l_rsv.attribute15 := NULL;
               l_rsv.demand_source_delivery := NULL;
               l_rsv.reservation_uom_code := rec_line.primary_uom;
               l_rsv.reservation_quantity := rec_line.quantity_crt;
               l_rsv.primary_reservation_quantity := rec_line.quantity_crt;
               l_rsv.secondary_uom_code := rec_line.sececondary_uom;

               IF NVL (rec_line.quantity_sft, 0) > 0
               THEN
                  l_rsv.secondary_reservation_quantity :=
                                                        rec_line.quantity_sft;
               ELSE
                  l_rsv.secondary_reservation_quantity := NULL;
               END IF;

               l_rsv.lot_number := rec_line.lot_number;        --p_lot_number;
               l_rsv.locator_id := rec_line.locator_id;
               l_rsv.supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.orig_supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.ship_ready_flag := 2;
               l_rsv.subinventory_code := rec_line.subinventory_code;
               /*l_rsv.primary_uom_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.subinventory_id := NULL;
               l_rsv.attribute15 := NULL;
               l_rsv.attribute14 := NULL;
               l_rsv.attribute13 := NULL;
               l_rsv.attribute12 := NULL;
               l_rsv.attribute11 := NULL;
               l_rsv.attribute10 := NULL;
               l_rsv.attribute9 := NULL;
               l_rsv.attribute8 := NULL;
               l_rsv.attribute7 := NULL;
               l_rsv.attribute6 := NULL;
               l_rsv.attribute5 := NULL;
               l_rsv.attribute4 := NULL;
               l_rsv.attribute3 := NULL;
               l_rsv.attribute2 := NULL;
               l_rsv.attribute1 := NULL;
               l_rsv.attribute_category := NULL;
               l_rsv.lpn_id := NULL;
               l_rsv.pick_slip_number := NULL;
               l_rsv.lot_number_id := NULL;
               l_rsv.revision := NULL;
               l_rsv.external_source_line_id := NULL;
               l_rsv.external_source_code := NULL;
               l_rsv.autodetail_group_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.primary_uom_id := NULL;
               l_rsv.demand_source_delivery := NULL;
               l_rsv.supply_source_line_detail := NULL;
               l_rsv.supply_source_name := NULL;
               l_rsv.supply_source_header_id := NULL;
               l_rsv.supply_source_line_id := NULL;*/
               x_status := NULL;
               x_msg_count := NULL;
               x_msg_data := NULL;
               inv_reservation_pub.create_reservation
                                               (p_api_version_number      => 1.0,
                                                x_return_status           => x_status,
                                                x_msg_count               => x_msg_count,
                                                x_msg_data                => x_msg_data,
                                                --p_init_msg_lst            => fnd_api.g_false,
                                                p_rsv_rec                 => l_rsv,
                                                p_serial_number           => l_dummy_sn,
                                                x_serial_number           => x_dummy_sn,
                                                x_quantity_reserved       => x_qty,
                                                x_reservation_id          => x_rsv_id
                                               );

               /*-- -- debug_insert (   'inv_reservation_pub.create_reservation:        '
                             || x_status
                            );
               -- -- debug_insert ('x_rsv_id:        ' || x_rsv_id);*/

               /*DBMS_OUTPUT.put_line ('Return status    = ' || x_status);
               DBMS_OUTPUT.put_line (   'msg count        = '
                                     || TO_CHAR (x_msg_count)
                                    );
               DBMS_OUTPUT.put_line ('msg data         = ' || x_msg_data);
               DBMS_OUTPUT.put_line ('Quantity reserved = ' || TO_CHAR (x_qty));
               DBMS_OUTPUT.put_line ('Reservation id   = ' || TO_CHAR (x_rsv_id));*/
               -- debug_insert (2.1 || ':' || x_msg_count);
               -- debug_insert (2.2 || ':' || x_status);
               IF x_status <> fnd_api.g_ret_sts_success
               THEN
                  -- debug_insert (3);
                  IF x_msg_count > 1
                  THEN
                     -- debug_insert (4);
                     FOR i IN 1 .. x_msg_count
                     LOOP
                        IF x_message IS NULL
                        THEN
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        ELSE
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 x_message
                              || CHR (10)
                              || 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        END IF;
                     END LOOP;
                  ELSIF x_msg_count = 1
                  THEN
                     -- debug_insert (5);
                     IF x_message IS NULL
                     THEN
                        x_message :=
                                   'Create Reservation Error: ' || x_msg_data;
                     ELSE
                        x_message :=
                              x_message
                           || CHR (10)
                           || 'Create Reservation Error: '
                           || x_msg_data;
                     END IF;
                  END IF;
               ELSE
                  UPDATE xxdbl_omshipping_lot_lines
                     SET attribute1 = x_rsv_id
                   WHERE omshipping_lot_id = rec_line.omshipping_lot_id;
               END IF;
            END IF;

            l_record_count := l_record_count + 1;
         END IF;
      /*ELSE
         EXIT;
      END IF;*/
      END LOOP;

      IF x_message IS NULL
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END create_update_reservations;

   PROCEDURE create_resv_yarn (
      p_omshiping_line_id     IN       NUMBER,
      p_split_order_line_id   IN       NUMBER,
      p_resv_type             IN       VARCHAR2,
      x_message               OUT      VARCHAR2
   )
   IS
      l_current_reservation_id   NUMBER                                 := -1;
      l_record_count             NUMBER                                  := 1;
      l_rsv                      inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_del                  inv_reservation_global.mtl_reservation_rec_type;
      l_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_msg_count                NUMBER;
      x_msg_data                 VARCHAR2 (240);
      x_rsv_id                   NUMBER;
      x_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_status                   VARCHAR2 (1);
      x_qty                      NUMBER;
      lx_status                  VARCHAR2 (1);
      lx_msg_count               NUMBER;
      lx_msg_data                VARCHAR2 (240);
      lv_rsv                     inv_reservation_global.mtl_reservation_rec_type;
      lv_dummy_sn                inv_reservation_global.serial_number_tbl_type;
      l_sales_order_id           NUMBER;
      l_current_atr              NUMBER                                  := 0;
      v_msg_index_out            VARCHAR2 (20);
   BEGIN
      IF p_resv_type = 'MAIN_LINE'
      THEN
         FOR rec_line IN
            (SELECT lines.customer_number, lines.customer_name,
                    lines.customer_id, lines.order_number, lines.order_id,
                    lines.ship_to_warehouse, lines.warehouse_id,
                    lines.order_line_no,
                    NVL (lines.attribute3, 0) original_line_pri_qty,
                    ROUND (NVL (lines.picking_qty_crt, 0), 5)
                                                             picking_qty_crt,
                    NVL (lines.attribute4, 0) original_line_sec_qty,
                    ROUND (NVL (lines.picking_qty_sft, 0), 5)
                                                             picking_qty_sft,
                    lines.order_line_id, lines.attribute1 primary_uom,
                    lines.attribute2 sececondary_uom, line_lot.*
               FROM xxdbl_omshipping_line lines,
                    xxdbl_omshipping_lot_lines line_lot
              WHERE 1 = 1
                AND lines.omshipping_line_id = p_omshiping_line_id
                AND NVL (lines.attribute5, '1') = '2'
                AND lines.omshipping_line_status NOT IN
                                       ('CANCELLED') --('CLOSED', 'CANCELLED')
                AND NVL (line_lot.quantity_crt, 0) > 0
                AND lines.omshipping_line_id = line_lot.omshipping_line_id)
         LOOP
            BEGIN
               SELECT sales_order_id
                 INTO l_sales_order_id
                 FROM mtl_sales_orders
                WHERE segment1 = rec_line.order_number || '';
            EXCEPTION
               WHEN OTHERS
               THEN
                  --debug_insert ('Error:        ' || sqlerrm);
                  l_sales_order_id := -1;
            END;

            --debug_insert ('l_sales_order_id:        ' || l_sales_order_id);
            IF l_sales_order_id < 0
            THEN
               IF x_message IS NULL
               THEN
                  x_message :=
                        'Unable to find Sales Order '
                     || rec_line.order_number
                     || '  Lot Number:     '
                     || rec_line.lot_number;
               ELSE
                  x_message :=
                        x_message
                     || CHR (10)
                     || 'Unable to find Sales Order '
                     || rec_line.order_number
                     || '  Lot Number:     '
                     || rec_line.lot_number;
               END IF;
            ELSE
               l_rsv.requirement_date := SYSDATE;
               l_rsv.organization_id := rec_line.warehouse_id;
               --mtl_parameters.organization id
               l_rsv.inventory_item_id := rec_line.item_id;
               --mtl_system_items.Inventory_item_id;
               l_rsv.demand_source_name := NULL;
               l_rsv.demand_source_type_id := 2;
               l_rsv.demand_source_header_id := l_sales_order_id;
               --1334166 ; --mtl_sales_orders.sales_order_id
               l_rsv.demand_source_line_id := rec_line.order_line_id;
               --4912468 ; -- oe_order_lines.line_id
               l_rsv.primary_uom_code := rec_line.primary_uom;
               l_rsv.primary_uom_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.autodetail_group_id := NULL;
               l_rsv.external_source_code := NULL;
               l_rsv.external_source_line_id := NULL;
               l_rsv.supply_source_header_id := NULL;
               l_rsv.supply_source_line_id := NULL;
               l_rsv.supply_source_name := NULL;
               l_rsv.supply_source_line_detail := NULL;
               l_rsv.revision := NULL;
               l_rsv.subinventory_id := NULL;
               l_rsv.lot_number_id := NULL;
               l_rsv.pick_slip_number := NULL;
               l_rsv.lpn_id := NULL;
               l_rsv.attribute_category := NULL;
               l_rsv.attribute1 := NULL;
               l_rsv.attribute2 := NULL;
               l_rsv.attribute3 := NULL;
               l_rsv.attribute4 := NULL;
               l_rsv.attribute5 := NULL;
               l_rsv.attribute6 := NULL;
               l_rsv.attribute7 := NULL;
               l_rsv.attribute8 := NULL;
               l_rsv.attribute9 := NULL;
               l_rsv.attribute10 := NULL;
               l_rsv.attribute11 := NULL;
               l_rsv.attribute12 := NULL;
               l_rsv.attribute13 := NULL;
               l_rsv.attribute14 := NULL;
               l_rsv.attribute15 := NULL;
               l_rsv.demand_source_delivery := NULL;
               l_rsv.reservation_uom_code := rec_line.primary_uom;
               l_rsv.reservation_quantity := rec_line.quantity_crt;
               l_rsv.primary_reservation_quantity := rec_line.quantity_crt;
               l_rsv.secondary_uom_code := rec_line.sececondary_uom;

               IF NVL (rec_line.quantity_sft, 0) > 0
               THEN
                  l_rsv.secondary_reservation_quantity :=
                                                        rec_line.quantity_sft;
               ELSE
                  l_rsv.secondary_reservation_quantity := NULL;
               END IF;

               l_rsv.lot_number := rec_line.lot_number;        --p_lot_number;
               l_rsv.locator_id := rec_line.locator_id;
               l_rsv.supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.orig_supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.ship_ready_flag := 2;
               l_rsv.subinventory_code := rec_line.subinventory_code;
               x_status := NULL;
               x_msg_count := NULL;
               x_msg_data := NULL;
               inv_reservation_pub.create_reservation
                                               (p_api_version_number      => 1.0,
                                                x_return_status           => x_status,
                                                x_msg_count               => x_msg_count,
                                                x_msg_data                => x_msg_data,
                                                --p_init_msg_lst            => fnd_api.g_false,
                                                p_rsv_rec                 => l_rsv,
                                                p_serial_number           => l_dummy_sn,
                                                x_serial_number           => x_dummy_sn,
                                                x_quantity_reserved       => x_qty,
                                                x_reservation_id          => x_rsv_id
                                               );

               IF x_status <> fnd_api.g_ret_sts_success
               THEN
                  FOR j IN 1 .. fnd_msg_pub.count_msg
                  LOOP
                     fnd_msg_pub.get (p_msg_index          => j,
                                      p_encoded            => 'F',
                                      p_data               => x_msg_data,
                                      p_msg_index_out      => v_msg_index_out
                                     );
                     x_message := 'Create Reservation Error20: ' || x_msg_data;
                  END LOOP;

                  -- debug_insert (3);
                  IF x_msg_count > 1
                  THEN
                     -- debug_insert (4);
                     FOR i IN 1 .. x_msg_count
                     LOOP
                        IF x_message IS NULL
                        THEN
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        ELSE
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 x_message
                              || CHR (10)
                              || 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        END IF;
                     END LOOP;
                  ELSIF x_msg_count = 1
                  THEN
                     -- debug_insert (5);
                     IF x_message IS NULL
                     THEN
                        x_message :=
                                   'Create Reservation Error: ' || x_msg_data;
                     ELSE
                        x_message :=
                              x_message
                           || CHR (10)
                           || 'Create Reservation Error: '
                           || x_msg_data;
                     END IF;
                  END IF;
               ELSE
                  UPDATE xxdbl_mtl_resv_shipping
                     SET reservation_quantity =
                              NVL (reservation_quantity, 0)
                            - rec_line.quantity_crt,
                         primary_reservation_quantity =
                              NVL (primary_reservation_quantity, 0)
                            - rec_line.quantity_crt,
                         secondary_reservation_quantity =
                            DECODE (secondary_reservation_quantity,
                                    NULL, NULL,
                                      NVL (secondary_reservation_quantity, 0)
                                    - rec_line.quantity_sft
                                   )
                   WHERE reservation_id = rec_line.attribute1;

                  UPDATE xxdbl_omshipping_lot_lines
                     SET attribute1 = x_rsv_id
                   WHERE omshipping_lot_id = rec_line.omshipping_lot_id;
               END IF;
            END IF;
         END LOOP;
      ELSIF p_resv_type = 'SPLIT_LINE'
      THEN
         FOR rec_line IN (SELECT *
                            FROM xxdbl_mtl_resv_shipping
                           WHERE 1 = 1
                             AND primary_reservation_quantity > 0
                             AND supply_source_type_id = 13)
         LOOP
            BEGIN
               SELECT sales_order_id
                 INTO l_sales_order_id
                 FROM mtl_sales_orders
                WHERE segment1 =
                         (SELECT ooh.order_number
                            FROM oe_order_lines_all ool,
                                 oe_order_headers_all ooh
                           WHERE 1 = 1
                             AND ool.line_id = p_split_order_line_id
                             AND ool.header_id = ooh.header_id
                             AND ool.org_id = ooh.org_id);
            EXCEPTION
               WHEN OTHERS
               THEN
                  --debug_insert ('Error:        ' || sqlerrm);
                  l_sales_order_id := -1;
            END;

            --debug_insert ('l_sales_order_id:        ' || l_sales_order_id);
            IF l_sales_order_id < 0
            THEN
               IF x_message IS NULL
               THEN
                  x_message := 'Unable to find Sales Order ';
               ELSE
                  x_message :=
                        x_message || CHR (10)
                        || 'Unable to find Sales Order ';
               END IF;
            ELSE
               l_rsv.requirement_date := SYSDATE;
               l_rsv.organization_id := rec_line.organization_id;
               --mtl_parameters.organization id
               l_rsv.inventory_item_id := rec_line.inventory_item_id;
               --mtl_system_items.Inventory_item_id;
               l_rsv.demand_source_name := NULL;
               l_rsv.demand_source_type_id := 2;
               l_rsv.demand_source_header_id := l_sales_order_id;
               --1334166 ; --mtl_sales_orders.sales_order_id
               l_rsv.demand_source_line_id := p_split_order_line_id;
               --4912468 ; -- oe_order_lines.line_id
               l_rsv.primary_uom_code := rec_line.primary_uom_code;
               l_rsv.primary_uom_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.autodetail_group_id := NULL;
               l_rsv.external_source_code := NULL;
               l_rsv.external_source_line_id := NULL;
               l_rsv.supply_source_header_id := NULL;
               l_rsv.supply_source_line_id := NULL;
               l_rsv.supply_source_name := NULL;
               l_rsv.supply_source_line_detail := NULL;
               l_rsv.revision := NULL;
               l_rsv.subinventory_id := NULL;
               l_rsv.lot_number_id := NULL;
               l_rsv.pick_slip_number := NULL;
               l_rsv.lpn_id := NULL;
               l_rsv.attribute_category := NULL;
               l_rsv.attribute1 := NULL;
               l_rsv.attribute2 := NULL;
               l_rsv.attribute3 := NULL;
               l_rsv.attribute4 := NULL;
               l_rsv.attribute5 := NULL;
               l_rsv.attribute6 := NULL;
               l_rsv.attribute7 := NULL;
               l_rsv.attribute8 := NULL;
               l_rsv.attribute9 := NULL;
               l_rsv.attribute10 := NULL;
               l_rsv.attribute11 := NULL;
               l_rsv.attribute12 := NULL;
               l_rsv.attribute13 := NULL;
               l_rsv.attribute14 := NULL;
               l_rsv.attribute15 := NULL;
               l_rsv.demand_source_delivery := NULL;
               l_rsv.reservation_uom_code := rec_line.reservation_uom_code;
               l_rsv.reservation_quantity := rec_line.reservation_quantity;
               l_rsv.primary_reservation_quantity :=
                                        rec_line.primary_reservation_quantity;
               l_rsv.secondary_uom_code := rec_line.secondary_uom_code;

               IF NVL (rec_line.secondary_reservation_quantity, 0) > 0
               THEN
                  l_rsv.secondary_reservation_quantity :=
                                      rec_line.secondary_reservation_quantity;
               ELSE
                  l_rsv.secondary_reservation_quantity := NULL;
               END IF;

               l_rsv.lot_number := rec_line.lot_number;        --p_lot_number;
               l_rsv.locator_id := rec_line.locator_id;
               l_rsv.supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.orig_supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.ship_ready_flag := 2;
               l_rsv.subinventory_code := rec_line.subinventory_code;
               x_status := NULL;
               x_msg_count := NULL;
               x_msg_data := NULL;
               inv_reservation_pub.create_reservation
                                               (p_api_version_number      => 1.0,
                                                x_return_status           => x_status,
                                                x_msg_count               => x_msg_count,
                                                x_msg_data                => x_msg_data,
                                                --p_init_msg_lst            => fnd_api.g_false,
                                                p_rsv_rec                 => l_rsv,
                                                p_serial_number           => l_dummy_sn,
                                                x_serial_number           => x_dummy_sn,
                                                x_quantity_reserved       => x_qty,
                                                x_reservation_id          => x_rsv_id
                                               );

               IF x_status <> fnd_api.g_ret_sts_success
               THEN
                  FOR j IN 1 .. fnd_msg_pub.count_msg
                  LOOP
                     fnd_msg_pub.get (p_msg_index          => j,
                                      p_encoded            => 'F',
                                      p_data               => x_msg_data,
                                      p_msg_index_out      => v_msg_index_out
                                     );
                     x_message := 'Create Reservation Error21: ' || x_msg_data;
                  END LOOP;

                  -- debug_insert (3);
                  IF x_msg_count > 1
                  THEN
                     -- debug_insert (4);
                     FOR i IN 1 .. x_msg_count
                     LOOP
                        IF x_message IS NULL
                        THEN
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        ELSE
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 x_message
                              || CHR (10)
                              || 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        END IF;
                     END LOOP;
                  ELSIF x_msg_count = 1
                  THEN
                     -- debug_insert (5);
                     IF x_message IS NULL
                     THEN
                        x_message :=
                                   'Create Reservation Error: ' || x_msg_data;
                     ELSE
                        x_message :=
                              x_message
                           || CHR (10)
                           || 'Create Reservation Error: '
                           || x_msg_data;
                     END IF;
                  END IF;
               ELSE
                  NULL;
               END IF;
            END IF;
         END LOOP;

         FOR rec_line IN (SELECT *
                            FROM xxdbl_mtl_resv_shipping
                           WHERE 1 = 1
                             AND primary_reservation_quantity > 0
                             AND supply_source_type_id = 5)
         LOOP
            INSERT INTO mtl_reservations
                        (reservation_id, requirement_date,
                         organization_id,
                         inventory_item_id,
                         demand_source_type_id,
                         demand_source_name,
                         demand_source_header_id,
                         demand_source_line_id,
                         demand_source_delivery,
                         primary_uom_code, primary_uom_id,
                         reservation_uom_code,
                         reservation_uom_id,
                         reservation_quantity,
                         primary_reservation_quantity,
                         autodetail_group_id,
                         external_source_code,
                         external_source_line_id,
                         supply_source_type_id,
                         supply_source_header_id,
                         supply_source_line_id,
                         supply_source_line_detail,
                         supply_source_name, revision,
                         subinventory_code,
                         subinventory_id, locator_id,
                         lot_number, lot_number_id,
                         serial_number, serial_number_id,
                         partial_quantities_allowed,
                         auto_detailed, pick_slip_number,
                         lpn_id, last_update_date,
                         last_updated_by, creation_date,
                         created_by, last_update_login,
                         request_id,
                         program_application_id,
                         program_id, program_update_date,
                         attribute_category, attribute1,
                         attribute2, attribute3,
                         attribute4, attribute5,
                         attribute6, attribute7,
                         attribute8, attribute9,
                         attribute10, attribute11,
                         attribute12, attribute13,
                         attribute14, attribute15,
                         ship_ready_flag, n_column1,
                         detailed_quantity, cost_group_id,
                         container_lpn_id, staged_flag,
                         secondary_detailed_quantity,
                         secondary_reservation_quantity,
                         secondary_uom_code,
                         secondary_uom_id, crossdock_flag,
                         crossdock_criteria_id,
                         demand_source_line_detail,
                         serial_reservation_quantity,
                         supply_receipt_date,
                         demand_ship_date, exception_code,
                         orig_supply_source_type_id,
                         orig_supply_source_header_id,
                         orig_supply_source_line_id,
                         orig_supply_source_line_detail,
                         orig_demand_source_type_id,
                         orig_demand_source_header_id,
                         orig_demand_source_line_id,
                         orig_demand_source_line_detail,
                         project_id, task_id,
                         mcc_code
                        )
                 VALUES (rec_line.reservation_id, rec_line.requirement_date,
                         rec_line.organization_id,
                         rec_line.inventory_item_id,
                         rec_line.demand_source_type_id,
                         rec_line.demand_source_name,
                         rec_line.demand_source_header_id,
                         p_split_order_line_id,
                         --rec_line.demand_source_line_id,
                         rec_line.demand_source_delivery,
                         rec_line.primary_uom_code, rec_line.primary_uom_id,
                         rec_line.reservation_uom_code,
                         rec_line.reservation_uom_id,
                         rec_line.reservation_quantity,
                         rec_line.primary_reservation_quantity,
                         rec_line.autodetail_group_id,
                         rec_line.external_source_code,
                         rec_line.external_source_line_id,
                         rec_line.supply_source_type_id,
                         rec_line.supply_source_header_id,
                         rec_line.supply_source_line_id,
                         rec_line.supply_source_line_detail,
                         rec_line.supply_source_name, rec_line.revision,
                         rec_line.subinventory_code,
                         rec_line.subinventory_id, rec_line.locator_id,
                         rec_line.lot_number, rec_line.lot_number_id,
                         rec_line.serial_number, rec_line.serial_number_id,
                         rec_line.partial_quantities_allowed,
                         rec_line.auto_detailed, rec_line.pick_slip_number,
                         rec_line.lpn_id, rec_line.last_update_date,
                         rec_line.last_updated_by, rec_line.creation_date,
                         rec_line.created_by, rec_line.last_update_login,
                         rec_line.request_id,
                         rec_line.program_application_id,
                         rec_line.program_id, rec_line.program_update_date,
                         rec_line.attribute_category, rec_line.attribute1,
                         rec_line.attribute2, rec_line.attribute3,
                         rec_line.attribute4, rec_line.attribute5,
                         rec_line.attribute6, rec_line.attribute7,
                         rec_line.attribute8, rec_line.attribute9,
                         rec_line.attribute10, rec_line.attribute11,
                         rec_line.attribute12, rec_line.attribute13,
                         rec_line.attribute14, rec_line.attribute15,
                         rec_line.ship_ready_flag, rec_line.n_column1,
                         rec_line.detailed_quantity, rec_line.cost_group_id,
                         rec_line.container_lpn_id, rec_line.staged_flag,
                         rec_line.secondary_detailed_quantity,
                         rec_line.secondary_reservation_quantity,
                         rec_line.secondary_uom_code,
                         rec_line.secondary_uom_id, rec_line.crossdock_flag,
                         rec_line.crossdock_criteria_id,
                         rec_line.demand_source_line_detail,
                         rec_line.serial_reservation_quantity,
                         rec_line.supply_receipt_date,
                         rec_line.demand_ship_date, rec_line.exception_code,
                         rec_line.orig_supply_source_type_id,
                         rec_line.orig_supply_source_header_id,
                         rec_line.orig_supply_source_line_id,
                         rec_line.orig_supply_source_line_detail,
                         rec_line.orig_demand_source_type_id,
                         rec_line.orig_demand_source_header_id,
                         rec_line.orig_demand_source_line_id,
                         rec_line.orig_demand_source_line_detail,
                         rec_line.project_id, rec_line.task_id,
                         rec_line.mcc_code
                        );
         END LOOP;
      ELSE
         NULL;
      END IF;
   --COMMIT;
   END create_resv_yarn;

   PROCEDURE create_update_ool_reserv (
      p_omshipping_header_id   IN       NUMBER,
      p_omshipping_line_id     IN       NUMBER,
      x_message                OUT      VARCHAR2
   )
   IS
      l_current_reservation_id   NUMBER                                 := -1;
      l_record_count             NUMBER                                  := 1;
      l_rsv                      inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_del                  inv_reservation_global.mtl_reservation_rec_type;
      l_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_msg_count                NUMBER;
      x_msg_data                 VARCHAR2 (240);
      x_rsv_id                   NUMBER;
      x_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_status                   VARCHAR2 (1);
      x_qty                      NUMBER;
      lx_status                  VARCHAR2 (1);
      lx_msg_count               NUMBER;
      lx_msg_data                VARCHAR2 (240);
      lv_rsv                     inv_reservation_global.mtl_reservation_rec_type;
      lv_dummy_sn                inv_reservation_global.serial_number_tbl_type;
      l_sales_order_id           NUMBER;
      l_current_atr              NUMBER                                  := 0;
      lx_message                 VARCHAR2 (4000)                      := NULL;
      l_shipset_error            NUMBER                                  := 0;
      v_msg_index_out            VARCHAR2 (20);
   BEGIN
      FOR rec_line IN
         (SELECT lines.customer_number, lines.customer_name,
                 lines.customer_id, lines.order_number, lines.order_id,
                 lines.ship_to_warehouse, lines.warehouse_id,
                 lines.order_line_no,
                 NVL (lines.attribute3, 0) original_line_pri_qty,
                 ROUND (NVL (lines.picking_qty_crt, 0), 5) picking_qty_crt,
                 NVL (lines.attribute4, 0) original_line_sec_qty,
                 ROUND (NVL (lines.picking_qty_sft, 0), 5) picking_qty_sft,
                 lines.order_line_id, lines.attribute1 primary_uom,
                 lines.attribute2 sececondary_uom, lines.item_id,
                 lines.omshipping_header_id, lines.omshipping_line_id,
                 lines.item_code, lines.ROWID xxrowid
            FROM xxdbl_omshipping_line lines
           WHERE 1 = 1
             AND lines.omshipping_header_id = p_omshipping_header_id
             AND lines.omshipping_line_id = p_omshipping_line_id)
      LOOP
         lx_message := NULL;
         x_message := NULL;

         /*debug_insert ('l_shipset_error1:     ' || l_shipset_error);
         debug_insert ('rec_line.order_id:     ' || rec_line.order_id);
         debug_insert ('rec_line.order_line_id:     '
                       || rec_line.order_line_id
                      );*/
         BEGIN
            SELECT COUNT (1)
              INTO l_shipset_error
              FROM (SELECT oola1.line_id, oola1.ship_from_org_id,
                           oola1.inventory_item_id, oola1.ordered_quantity
                      FROM oe_order_lines_all oola1
                     WHERE oola1.ship_set_id =
                              (SELECT oola.ship_set_id
                                 FROM oe_order_lines_all oola
                                WHERE oola.header_id = rec_line.order_id
                                  AND oola.line_id = rec_line.order_line_id)) xx
             WHERE 1 = 1
               AND ordered_quantity >
                      xxdbl_shiping_tran_crp_pkg.available_to_reserve
                                 (p_organization_id        => xx.ship_from_org_id,
                                  p_inventory_item_id      => xx.inventory_item_id,
                                  p_subinventory_code      => NULL,
                                  p_locator_id             => NULL,
                                  p_lot_number             => NULL
                                 )
               AND NOT EXISTS (SELECT 'X'
                                 FROM xxdbl_order_ship_set xxoss
                                WHERE 1 = 1 AND xxoss.line_id = xx.line_id);

            /*SELECT COUNT (1)
              INTO l_shipset_error
              FROM (SELECT   oola1.ship_from_org_id, oola1.inventory_item_id,
                             SUM (oola1.ordered_quantity) total_quanity
                        FROM oe_order_lines_all oola1
                       WHERE oola1.ship_set_id =
                                (SELECT oola.ship_set_id
                                   FROM oe_order_lines_all oola
                                  WHERE oola.header_id = rec_line.order_id
                                    AND oola.line_id = rec_line.order_line_id)
                      HAVING SUM (oola1.ordered_quantity) >
                                xxdbl_shiping_tran_crp_pkg.available_to_reserve
                                   (p_organization_id        => rec_line.warehouse_id,
                                    p_inventory_item_id      => rec_line.item_id,
                                    p_subinventory_code      => NULL,
                                    p_locator_id             => NULL,
                                    p_lot_number             => NULL
                                   )
                    GROUP BY oola1.ship_from_org_id, oola1.inventory_item_id);*/
            --debug_insert ('l_shipset_error2:     ' || l_shipset_error);
            INSERT INTO xxdbl_order_ship_set
                        (header_id, line_id
                        )
                 VALUES (rec_line.order_id, rec_line.order_line_id
                        );
         EXCEPTION
            WHEN OTHERS
            THEN
               --debug_insert ('l_shipset_error3:     ' || l_shipset_error);
               l_shipset_error := 0;
         END;

         IF l_shipset_error <= 0
         THEN
            --debug_insert ('l_shipset_error4:     ' || l_shipset_error);

            --debug_insert ('rec_line.lot_number:        ' || rec_line.lot_number);
            SELECT xxdbl_shiping_tran_crp_pkg.available_to_reserve
                                  (p_organization_id        => rec_line.warehouse_id,
                                   p_inventory_item_id      => rec_line.item_id,
                                   p_subinventory_code      => NULL,
                                   p_locator_id             => NULL,
                                   p_lot_number             => NULL
                                  )
              INTO l_current_atr
              FROM DUAL;

            --debug_insert ('l_current_atr1:     ' || l_current_atr);
            IF l_current_atr = 0
            THEN
               --debug_insert ('l_current_atr2:     ' || l_current_atr);
               DELETE      xxdbl_omshipping_line
                     WHERE omshipping_header_id = p_omshipping_header_id
                       AND omshipping_line_id = p_omshipping_line_id
                                                                    --ROWID = rec_line.xxrowid
               ;
            ELSIF l_current_atr < rec_line.picking_qty_crt
            THEN
               --debug_insert ('l_current_atr3:     ' || l_current_atr);
               UPDATE xxdbl_omshipping_line
                  SET picking_qty_crt = l_current_atr,
                      picking_qty_sft =
                           l_current_atr
                         * (rec_line.picking_qty_sft
                            / rec_line.picking_qty_crt
                           )
                WHERE omshipping_header_id = p_omshipping_header_id
                  AND omshipping_line_id = p_omshipping_line_id;

               xxdbl_shiping_tran_crp_pkg.split_line_new
                     (p_omshipping_header_id      => rec_line.omshipping_header_id,
                      p_omshipping_line_id        => rec_line.omshipping_line_id,
                      x_message                   => lx_message
                     );

               IF lx_message IS NOT NULL
               THEN
                  IF x_message IS NULL
                  THEN
                     x_message :=
                           'Split Line Error: '
                        || ' for the Item '
                        || rec_line.item_code
                        || ' '
                        || ' Order Line No '
                        || rec_line.order_line_no
                        || ' '
                        || lx_message;
                  ELSE
                     x_message :=
                           x_message
                        || CHR (10)
                        || 'Split Line Error: '
                        || ' for the Item '
                        || rec_line.item_code
                        || ' '
                        || ' Order Line No '
                        || rec_line.order_line_no
                        || ' '
                        || lx_message;
                  END IF;
               ELSE
                  create_update_ool_reserv1
                     (p_omshipping_header_id      => rec_line.omshipping_header_id,
                      p_omshipping_line_id        => rec_line.omshipping_line_id,
                      x_message                   => lx_message
                     );

                  IF lx_message IS NOT NULL
                  THEN
                     IF x_message IS NULL
                     THEN
                        x_message :=
                              'Create Reservation Error: '
                           || ' for the Item '
                           || rec_line.item_code
                           || ' '
                           || ' Order Line No '
                           || rec_line.order_line_no
                           || ' '
                           || lx_message;
                     ELSE
                        x_message :=
                              x_message
                           || CHR (10)
                           || 'Create Reservation Error: '
                           || ' for the Item '
                           || rec_line.item_code
                           || ' '
                           || ' Order Line No '
                           || rec_line.order_line_no
                           || ' '
                           || lx_message;
                     END IF;
                  END IF;
               END IF;
            ELSE
               /*IF l_record_count = 1
               THEN*/
               BEGIN
                  SELECT mr.reservation_id
                    INTO l_current_reservation_id
                    FROM mtl_reservations mr
                   WHERE mr.organization_id = rec_line.warehouse_id
                     AND mr.inventory_item_id = rec_line.item_id
                     AND mr.demand_source_type_id = 2
                     --AND demand_source_header_id = rec_line.order_id
                     AND mr.demand_source_line_id = rec_line.order_line_id
                     AND mr.supply_source_type_id = 13
                     AND mr.orig_supply_source_type_id = 13
                     AND mr.orig_demand_source_type_id = 2
                     --AND orig_demand_source_header_id = rec_line.order_id
                     AND mr.orig_demand_source_line_id =
                                                        rec_line.order_line_id
                     AND mr.lot_number IS NULL
                     AND NOT EXISTS (SELECT 'X'
                                       FROM xxdbl_omshipping_lot_lines xx
                                      WHERE xx.attribute1 = mr.reservation_id);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_current_reservation_id := -1;
               END;

               BEGIN
                  SELECT sales_order_id
                    INTO l_sales_order_id
                    FROM mtl_sales_orders
                   WHERE segment1 = rec_line.order_number || '';
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     --debug_insert ('Error:        ' || sqlerrm);
                     l_sales_order_id := -1;
               END;

               --debug_insert ('l_sales_order_id:        ' || l_sales_order_id);
               IF l_sales_order_id < 0
               THEN
                  IF x_message IS NULL
                  THEN
                     x_message :=
                        'Unable to find Sales Order '
                        || rec_line.order_number;
                  ELSE
                     x_message :=
                           x_message
                        || CHR (10)
                        || 'Unable to find Sales Order '
                        || rec_line.order_number;
                  END IF;
               ELSE
                  l_rsv.requirement_date := SYSDATE;
                  l_rsv.organization_id := rec_line.warehouse_id;
                  --mtl_parameters.organization id
                  l_rsv.inventory_item_id := rec_line.item_id;
                  --mtl_system_items.Inventory_item_id;
                  l_rsv.demand_source_name := NULL;
                  l_rsv.demand_source_type_id := 2;
                  l_rsv.demand_source_header_id := l_sales_order_id;
                  --1334166 ; --mtl_sales_orders.sales_order_id
                  l_rsv.demand_source_line_id := rec_line.order_line_id;
                  --4912468 ; -- oe_order_lines.line_id
                  l_rsv.primary_uom_code := rec_line.primary_uom;
                  l_rsv.primary_uom_id := NULL;
                  l_rsv.reservation_uom_id := NULL;
                  l_rsv.autodetail_group_id := NULL;
                  l_rsv.external_source_code := NULL;
                  l_rsv.external_source_line_id := NULL;
                  l_rsv.supply_source_header_id := NULL;
                  l_rsv.supply_source_line_id := NULL;
                  l_rsv.supply_source_name := NULL;
                  l_rsv.supply_source_line_detail := NULL;
                  l_rsv.revision := NULL;
                  l_rsv.subinventory_id := NULL;
                  l_rsv.lot_number_id := NULL;
                  l_rsv.pick_slip_number := NULL;
                  l_rsv.lpn_id := NULL;
                  l_rsv.attribute_category := NULL;
                  l_rsv.attribute1 := NULL;
                  l_rsv.attribute2 := NULL;
                  l_rsv.attribute3 := NULL;
                  l_rsv.attribute4 := NULL;
                  l_rsv.attribute5 := NULL;
                  l_rsv.attribute6 := NULL;
                  l_rsv.attribute7 := NULL;
                  l_rsv.attribute8 := NULL;
                  l_rsv.attribute9 := NULL;
                  l_rsv.attribute10 := NULL;
                  l_rsv.attribute11 := NULL;
                  l_rsv.attribute12 := NULL;
                  l_rsv.attribute13 := NULL;
                  l_rsv.attribute14 := NULL;
                  l_rsv.attribute15 := NULL;
                  l_rsv.demand_source_delivery := NULL;
                  l_rsv.reservation_uom_code := rec_line.primary_uom;
                  l_rsv.reservation_quantity := rec_line.picking_qty_crt;
                  l_rsv.primary_reservation_quantity :=
                                                     rec_line.picking_qty_crt;
                  l_rsv.secondary_uom_code := rec_line.sececondary_uom;

                  IF NVL (rec_line.picking_qty_sft, 0) > 0
                  THEN
                     l_rsv.secondary_reservation_quantity :=
                                                     rec_line.picking_qty_sft;
                  ELSE
                     l_rsv.secondary_reservation_quantity := NULL;
                  END IF;

                  l_rsv.lot_number := NULL;
                  --rec_line.lot_number;        --p_lot_number;
                  l_rsv.locator_id := NULL;             --rec_line.locator_id;
                  l_rsv.supply_source_type_id := 13;
                  --inv_reservation_global.g_source_type_inv;
                  l_rsv.orig_supply_source_type_id := 13;
                  --inv_reservation_global.g_source_type_inv;
                  l_rsv.ship_ready_flag := 2;
                  l_rsv.subinventory_code := NULL;
                                                 --rec_line.subinventory_code;
                  /*l_rsv.primary_uom_id := NULL;
                  l_rsv.reservation_uom_id := NULL;
                  l_rsv.subinventory_id := NULL;
                  l_rsv.attribute15 := NULL;
                  l_rsv.attribute14 := NULL;
                  l_rsv.attribute13 := NULL;
                  l_rsv.attribute12 := NULL;
                  l_rsv.attribute11 := NULL;
                  l_rsv.attribute10 := NULL;
                  l_rsv.attribute9 := NULL;
                  l_rsv.attribute8 := NULL;
                  l_rsv.attribute7 := NULL;
                  l_rsv.attribute6 := NULL;
                  l_rsv.attribute5 := NULL;
                  l_rsv.attribute4 := NULL;
                  l_rsv.attribute3 := NULL;
                  l_rsv.attribute2 := NULL;
                  l_rsv.attribute1 := NULL;
                  l_rsv.attribute_category := NULL;
                  l_rsv.lpn_id := NULL;
                  l_rsv.pick_slip_number := NULL;
                  l_rsv.lot_number_id := NULL;
                  l_rsv.revision := NULL;
                  l_rsv.external_source_line_id := NULL;
                  l_rsv.external_source_code := NULL;
                  l_rsv.autodetail_group_id := NULL;
                  l_rsv.reservation_uom_id := NULL;
                  l_rsv.primary_uom_id := NULL;
                  l_rsv.demand_source_delivery := NULL;
                  l_rsv.supply_source_line_detail := NULL;
                  l_rsv.supply_source_name := NULL;
                  l_rsv.supply_source_header_id := NULL;
                  l_rsv.supply_source_line_id := NULL;*/
                  x_status := NULL;
                  x_msg_count := NULL;
                  x_msg_data := NULL;
                  inv_reservation_pub.create_reservation
                                               (p_api_version_number      => 1.0,
                                                x_return_status           => x_status,
                                                x_msg_count               => x_msg_count,
                                                x_msg_data                => x_msg_data,
                                                --p_init_msg_lst            => fnd_api.g_false,
                                                p_rsv_rec                 => l_rsv,
                                                p_serial_number           => l_dummy_sn,
                                                x_serial_number           => x_dummy_sn,
                                                x_quantity_reserved       => x_qty,
                                                x_reservation_id          => x_rsv_id
                                               );

                  /*-- -- debug_insert (   'inv_reservation_pub.create_reservation:        '
                                || x_status
                               );
                  -- -- debug_insert ('x_rsv_id:        ' || x_rsv_id);*/

                  /*DBMS_OUTPUT.put_line ('Return status    = ' || x_status);
                  DBMS_OUTPUT.put_line (   'msg count        = '
                                        || TO_CHAR (x_msg_count)
                                       );
                  DBMS_OUTPUT.put_line ('msg data         = ' || x_msg_data);
                  DBMS_OUTPUT.put_line ('Quantity reserved = ' || TO_CHAR (x_qty));
                  DBMS_OUTPUT.put_line ('Reservation id   = ' || TO_CHAR (x_rsv_id));*/
                  -- debug_insert (2.1 || ':' || x_msg_count);
                  -- debug_insert (2.2 || ':' || x_status);
                  IF x_status <> fnd_api.g_ret_sts_success
                  THEN
                     FOR j IN 1 .. fnd_msg_pub.count_msg
                     LOOP
                        fnd_msg_pub.get (p_msg_index          => j,
                                         p_encoded            => 'F',
                                         p_data               => x_msg_data,
                                         p_msg_index_out      => v_msg_index_out
                                        );
                        x_message :=
                                  'Create Reservation Error23: ' || x_msg_data;
                     END LOOP;

                     -- debug_insert (3);
                     IF x_msg_count > 1
                     THEN
                        -- debug_insert (4);
                        FOR i IN 1 .. x_msg_count
                        LOOP
                           IF x_message IS NULL
                           THEN
                              x_msg_data :=
                                 SUBSTR
                                    (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                     1,
                                     255
                                    );
                              x_message :=
                                    'Create Reservation Error: '
                                 || i
                                 || '. '
                                 || x_msg_data;
                           ELSE
                              x_msg_data :=
                                 SUBSTR
                                    (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                     1,
                                     255
                                    );
                              x_message :=
                                    x_message
                                 || CHR (10)
                                 || 'Create Reservation Error: '
                                 || i
                                 || '. '
                                 || x_msg_data;
                           END IF;
                        END LOOP;
                     ELSIF x_msg_count = 1
                     THEN
                        -- debug_insert (5);
                        IF x_message IS NULL
                        THEN
                           x_message :=
                                   'Create Reservation Error: ' || x_msg_data;
                        ELSE
                           x_message :=
                                 x_message
                              || CHR (10)
                              || 'Create Reservation Error: '
                              || x_msg_data;
                        END IF;
                     END IF;
                  ELSE
                     UPDATE xxdbl_omshipping_lot_lines
                        SET attribute1 = x_rsv_id
                      WHERE omshipping_header_id = p_omshipping_header_id
                        AND omshipping_line_id = p_omshipping_line_id;

                     UPDATE xxdbl_omshipping_line
                        SET attribute15 = x_rsv_id
                      WHERE omshipping_header_id = p_omshipping_header_id
                        AND omshipping_line_id = p_omshipping_line_id;
                  END IF;
               END IF;

               l_record_count := l_record_count + 1;
            END IF;
         /*ELSE
            EXIT;
         END IF;*/
         ELSE
            --debug_insert ('l_current_atr5:     ' || l_current_atr);
            DELETE      xxdbl_omshipping_line
                  WHERE omshipping_header_id = p_omshipping_header_id
                    AND omshipping_line_id = p_omshipping_line_id;

            IF x_message IS NULL
            THEN
               x_message := 'Ship Set Grouping Error: ';
            ELSE
               x_message :=
                          x_message || CHR (10)
                          || 'Ship Set Grouping Error: ';
            END IF;
         END IF;
      END LOOP;

      IF x_message IS NULL
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END create_update_ool_reserv;

   PROCEDURE create_update_ool_reserv1 (
      p_omshipping_header_id   IN       NUMBER,
      p_omshipping_line_id     IN       NUMBER,
      x_message                OUT      VARCHAR2
   )
   IS
      l_current_reservation_id   NUMBER                                 := -1;
      l_record_count             NUMBER                                  := 1;
      l_rsv                      inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_del                  inv_reservation_global.mtl_reservation_rec_type;
      l_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_msg_count                NUMBER;
      x_msg_data                 VARCHAR2 (240);
      x_rsv_id                   NUMBER;
      x_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_status                   VARCHAR2 (1);
      x_qty                      NUMBER;
      lx_status                  VARCHAR2 (1);
      lx_msg_count               NUMBER;
      lx_msg_data                VARCHAR2 (240);
      lv_rsv                     inv_reservation_global.mtl_reservation_rec_type;
      lv_dummy_sn                inv_reservation_global.serial_number_tbl_type;
      l_sales_order_id           NUMBER;
      l_current_atr              NUMBER                                  := 0;
      lx_message                 VARCHAR2 (4000)                      := NULL;
      v_msg_index_out            VARCHAR2 (20);
   BEGIN
      FOR rec_line IN
         (SELECT lines.customer_number, lines.customer_name,
                 lines.customer_id, lines.order_number, lines.order_id,
                 lines.ship_to_warehouse, lines.warehouse_id,
                 lines.order_line_no,
                 NVL (lines.attribute3, 0) original_line_pri_qty,
                 ROUND (NVL (lines.picking_qty_crt, 0), 5) picking_qty_crt,
                 NVL (lines.attribute4, 0) original_line_sec_qty,
                 ROUND (NVL (lines.picking_qty_sft, 0), 5) picking_qty_sft,
                 lines.order_line_id, lines.attribute1 primary_uom,
                 lines.attribute2 sececondary_uom, lines.item_id,
                 lines.omshipping_header_id, lines.omshipping_line_id,
                 lines.item_code, lines.ROWID xxrowid
            FROM xxdbl_omshipping_line lines
           WHERE 1 = 1
             AND lines.omshipping_header_id = p_omshipping_header_id
             AND lines.omshipping_line_id = p_omshipping_line_id)
      LOOP
         lx_message := NULL;

         --debug_insert ('rec_line.lot_number:        ' || rec_line.lot_number);
         SELECT xxdbl_shiping_tran_crp_pkg.available_to_reserve
                                  (p_organization_id        => rec_line.warehouse_id,
                                   p_inventory_item_id      => rec_line.item_id,
                                   p_subinventory_code      => NULL,
                                   p_locator_id             => NULL,
                                   p_lot_number             => NULL
                                  )
           INTO l_current_atr
           FROM DUAL;

         IF l_current_atr = 0
         THEN
            DELETE      xxdbl_omshipping_line
                  WHERE omshipping_header_id = p_omshipping_header_id
                    AND omshipping_line_id = p_omshipping_line_id
                                                                 --ROWID = rec_line.xxrowid
            ;
         ELSIF l_current_atr < rec_line.picking_qty_crt
         THEN
            UPDATE xxdbl_omshipping_line
               SET picking_qty_crt = l_current_atr,
                   picking_qty_sft =
                        l_current_atr
                      * (rec_line.picking_qty_sft / rec_line.picking_qty_crt
                        )
             WHERE omshipping_header_id = p_omshipping_header_id
               AND omshipping_line_id = p_omshipping_line_id
                                                            --ROWID = rec_line.xxrowid
            ;

            xxdbl_shiping_tran_crp_pkg.split_line_new
                     (p_omshipping_header_id      => rec_line.omshipping_header_id,
                      p_omshipping_line_id        => rec_line.omshipping_line_id,
                      x_message                   => lx_message
                     );

            IF lx_message IS NOT NULL
            THEN
               IF x_message IS NULL
               THEN
                  x_message :=
                        'Split Line Error: '
                     || ' for the Item '
                     || rec_line.item_code
                     || ' '
                     || ' Order Line No '
                     || rec_line.order_line_no
                     || ' '
                     || lx_message;
               ELSE
                  x_message :=
                        x_message
                     || CHR (10)
                     || 'Split Line Error: '
                     || ' for the Item '
                     || rec_line.item_code
                     || ' '
                     || ' Order Line No '
                     || rec_line.order_line_no
                     || ' '
                     || lx_message;
               END IF;
            ELSE
               xxdbl_shiping_tran_crp_pkg.create_update_ool_reserv1
                    (p_omshipping_header_id      => rec_line.omshipping_header_id,
                     p_omshipping_line_id        => rec_line.omshipping_line_id,
                     x_message                   => lx_message
                    );

               IF lx_message IS NOT NULL
               THEN
                  IF x_message IS NULL
                  THEN
                     x_message :=
                           'Create Reservation Error: '
                        || ' for the Item '
                        || rec_line.item_code
                        || ' '
                        || ' Order Line No '
                        || rec_line.order_line_no
                        || ' '
                        || lx_message;
                  ELSE
                     x_message :=
                           x_message
                        || CHR (10)
                        || 'Create Reservation Error: '
                        || ' for the Item '
                        || rec_line.item_code
                        || ' '
                        || ' Order Line No '
                        || rec_line.order_line_no
                        || ' '
                        || lx_message;
                  END IF;
               END IF;
            END IF;
         ELSE
            /*IF l_record_count = 1
            THEN*/
            BEGIN
               SELECT mr.reservation_id
                 INTO l_current_reservation_id
                 FROM mtl_reservations mr
                WHERE mr.organization_id = rec_line.warehouse_id
                  AND mr.inventory_item_id = rec_line.item_id
                  AND mr.demand_source_type_id = 2
                  --AND demand_source_header_id = rec_line.order_id
                  AND mr.demand_source_line_id = rec_line.order_line_id
                  AND mr.supply_source_type_id = 13
                  AND mr.orig_supply_source_type_id = 13
                  AND mr.orig_demand_source_type_id = 2
                  --AND orig_demand_source_header_id = rec_line.order_id
                  AND mr.orig_demand_source_line_id = rec_line.order_line_id
                  AND mr.lot_number IS NULL
                  AND NOT EXISTS (SELECT 'X'
                                    FROM xxdbl_omshipping_lot_lines xx
                                   WHERE xx.attribute1 = mr.reservation_id);
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_current_reservation_id := -1;
            END;

            BEGIN
               SELECT sales_order_id
                 INTO l_sales_order_id
                 FROM mtl_sales_orders
                WHERE segment1 = rec_line.order_number || '';
            EXCEPTION
               WHEN OTHERS
               THEN
                  --debug_insert ('Error:        ' || sqlerrm);
                  l_sales_order_id := -1;
            END;

            --debug_insert ('l_sales_order_id:        ' || l_sales_order_id);
            IF l_sales_order_id < 0
            THEN
               IF x_message IS NULL
               THEN
                  x_message :=
                       'Unable to find Sales Order ' || rec_line.order_number;
               ELSE
                  x_message :=
                        x_message
                     || CHR (10)
                     || 'Unable to find Sales Order '
                     || rec_line.order_number;
               END IF;
            ELSE
               l_rsv.requirement_date := SYSDATE;
               l_rsv.organization_id := rec_line.warehouse_id;
               --mtl_parameters.organization id
               l_rsv.inventory_item_id := rec_line.item_id;
               --mtl_system_items.Inventory_item_id;
               l_rsv.demand_source_name := NULL;
               l_rsv.demand_source_type_id := 2;
               l_rsv.demand_source_header_id := l_sales_order_id;
               --1334166 ; --mtl_sales_orders.sales_order_id
               l_rsv.demand_source_line_id := rec_line.order_line_id;
               --4912468 ; -- oe_order_lines.line_id
               l_rsv.primary_uom_code := rec_line.primary_uom;
               l_rsv.primary_uom_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.autodetail_group_id := NULL;
               l_rsv.external_source_code := NULL;
               l_rsv.external_source_line_id := NULL;
               l_rsv.supply_source_header_id := NULL;
               l_rsv.supply_source_line_id := NULL;
               l_rsv.supply_source_name := NULL;
               l_rsv.supply_source_line_detail := NULL;
               l_rsv.revision := NULL;
               l_rsv.subinventory_id := NULL;
               l_rsv.lot_number_id := NULL;
               l_rsv.pick_slip_number := NULL;
               l_rsv.lpn_id := NULL;
               l_rsv.attribute_category := NULL;
               l_rsv.attribute1 := NULL;
               l_rsv.attribute2 := NULL;
               l_rsv.attribute3 := NULL;
               l_rsv.attribute4 := NULL;
               l_rsv.attribute5 := NULL;
               l_rsv.attribute6 := NULL;
               l_rsv.attribute7 := NULL;
               l_rsv.attribute8 := NULL;
               l_rsv.attribute9 := NULL;
               l_rsv.attribute10 := NULL;
               l_rsv.attribute11 := NULL;
               l_rsv.attribute12 := NULL;
               l_rsv.attribute13 := NULL;
               l_rsv.attribute14 := NULL;
               l_rsv.attribute15 := NULL;
               l_rsv.demand_source_delivery := NULL;
               l_rsv.reservation_uom_code := rec_line.primary_uom;
               l_rsv.reservation_quantity := rec_line.picking_qty_crt;
               l_rsv.primary_reservation_quantity := rec_line.picking_qty_crt;
               l_rsv.secondary_uom_code := rec_line.sececondary_uom;

               IF NVL (rec_line.picking_qty_sft, 0) > 0
               THEN
                  l_rsv.secondary_reservation_quantity :=
                                                     rec_line.picking_qty_sft;
               ELSE
                  l_rsv.secondary_reservation_quantity := NULL;
               END IF;

               l_rsv.lot_number := NULL;
               --rec_line.lot_number;        --p_lot_number;
               l_rsv.locator_id := NULL;                --rec_line.locator_id;
               l_rsv.supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.orig_supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.ship_ready_flag := 2;
               l_rsv.subinventory_code := NULL;  --rec_line.subinventory_code;
               /*l_rsv.primary_uom_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.subinventory_id := NULL;
               l_rsv.attribute15 := NULL;
               l_rsv.attribute14 := NULL;
               l_rsv.attribute13 := NULL;
               l_rsv.attribute12 := NULL;
               l_rsv.attribute11 := NULL;
               l_rsv.attribute10 := NULL;
               l_rsv.attribute9 := NULL;
               l_rsv.attribute8 := NULL;
               l_rsv.attribute7 := NULL;
               l_rsv.attribute6 := NULL;
               l_rsv.attribute5 := NULL;
               l_rsv.attribute4 := NULL;
               l_rsv.attribute3 := NULL;
               l_rsv.attribute2 := NULL;
               l_rsv.attribute1 := NULL;
               l_rsv.attribute_category := NULL;
               l_rsv.lpn_id := NULL;
               l_rsv.pick_slip_number := NULL;
               l_rsv.lot_number_id := NULL;
               l_rsv.revision := NULL;
               l_rsv.external_source_line_id := NULL;
               l_rsv.external_source_code := NULL;
               l_rsv.autodetail_group_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.primary_uom_id := NULL;
               l_rsv.demand_source_delivery := NULL;
               l_rsv.supply_source_line_detail := NULL;
               l_rsv.supply_source_name := NULL;
               l_rsv.supply_source_header_id := NULL;
               l_rsv.supply_source_line_id := NULL;*/
               x_status := NULL;
               x_msg_count := NULL;
               x_msg_data := NULL;
               inv_reservation_pub.create_reservation
                                               (p_api_version_number      => 1.0,
                                                x_return_status           => x_status,
                                                x_msg_count               => x_msg_count,
                                                x_msg_data                => x_msg_data,
                                                --p_init_msg_lst            => fnd_api.g_false,
                                                p_rsv_rec                 => l_rsv,
                                                p_serial_number           => l_dummy_sn,
                                                x_serial_number           => x_dummy_sn,
                                                x_quantity_reserved       => x_qty,
                                                x_reservation_id          => x_rsv_id
                                               );

               /*-- -- debug_insert (   'inv_reservation_pub.create_reservation:        '
                             || x_status
                            );
               -- -- debug_insert ('x_rsv_id:        ' || x_rsv_id);*/

               /*DBMS_OUTPUT.put_line ('Return status    = ' || x_status);
               DBMS_OUTPUT.put_line (   'msg count        = '
                                     || TO_CHAR (x_msg_count)
                                    );
               DBMS_OUTPUT.put_line ('msg data         = ' || x_msg_data);
               DBMS_OUTPUT.put_line ('Quantity reserved = ' || TO_CHAR (x_qty));
               DBMS_OUTPUT.put_line ('Reservation id   = ' || TO_CHAR (x_rsv_id));*/
               -- debug_insert (2.1 || ':' || x_msg_count);
               -- debug_insert (2.2 || ':' || x_status);
               IF x_status <> fnd_api.g_ret_sts_success
               THEN
                  FOR j IN 1 .. fnd_msg_pub.count_msg
                  LOOP
                     fnd_msg_pub.get (p_msg_index          => j,
                                      p_encoded            => 'F',
                                      p_data               => x_msg_data,
                                      p_msg_index_out      => v_msg_index_out
                                     );
                     x_message := 'Create Reservation Error24: ' || x_msg_data;
                  END LOOP;

                  -- debug_insert (3);
                  IF x_msg_count > 1
                  THEN
                     -- debug_insert (4);
                     FOR i IN 1 .. x_msg_count
                     LOOP
                        IF x_message IS NULL
                        THEN
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        ELSE
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 x_message
                              || CHR (10)
                              || 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        END IF;
                     END LOOP;
                  ELSIF x_msg_count = 1
                  THEN
                     -- debug_insert (5);
                     IF x_message IS NULL
                     THEN
                        x_message :=
                                   'Create Reservation Error: ' || x_msg_data;
                     ELSE
                        x_message :=
                              x_message
                           || CHR (10)
                           || 'Create Reservation Error: '
                           || x_msg_data;
                     END IF;
                  END IF;
               ELSE
                  UPDATE xxdbl_omshipping_lot_lines
                     SET attribute1 = x_rsv_id
                   WHERE omshipping_header_id = p_omshipping_header_id
                     AND omshipping_line_id = p_omshipping_line_id
                                                                  --ROWID = rec_line.xxrowid
                  ;

                  UPDATE xxdbl_omshipping_line
                     SET attribute15 = x_rsv_id
                   WHERE omshipping_header_id = p_omshipping_header_id
                     AND omshipping_line_id = p_omshipping_line_id;
               END IF;
            END IF;

            l_record_count := l_record_count + 1;
         END IF;
      /*ELSE
         EXIT;
      END IF;*/
      END LOOP;

      IF x_message IS NULL
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END create_update_ool_reserv1;

   PROCEDURE split_line_new1 (
      p_omshipping_hdr_id   IN       NUMBER,
      x_message             OUT      VARCHAR2
   )
   IS
      -- API variables
      l_header_rec                   oe_order_pub.header_rec_type;
      l_line_tbl                     oe_order_pub.line_tbl_type;
      l_line_tbl_nvl                 oe_order_pub.line_tbl_type;
      l_action_request_tbl           oe_order_pub.request_tbl_type;
      l_header_adj_tbl               oe_order_pub.header_adj_tbl_type;
      l_line_adj_tbl                 oe_order_pub.line_adj_tbl_type;
      l_header_scr_tbl               oe_order_pub.header_scredit_tbl_type;
      l_line_scredit_tbl             oe_order_pub.line_scredit_tbl_type;
      l_request_rec                  oe_order_pub.request_rec_type;
      l_return_status                VARCHAR2 (1000);
      l_msg_count                    NUMBER;
      l_msg_data                     VARCHAR2 (1000);
      l_wdd_delivery_detail_info     wsh_glbl_var_strct_grp.delivery_details_rec_type;
      l_wdd_update_status            VARCHAR2 (1000);
      p_api_version_number           NUMBER                            := 1.0;
      p_init_msg_list                VARCHAR2 (10)         := fnd_api.g_false;
      p_return_values                VARCHAR2 (10)         := fnd_api.g_false;
      p_action_commit                VARCHAR2 (10)         := fnd_api.g_false;
      x_return_status                VARCHAR2 (1);
      x_msg_count                    NUMBER;
      x_msg_data                     VARCHAR2 (100);
      p_header_rec                   oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      x_header_rec                   oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      p_old_header_rec               oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      p_header_val_rec               oe_order_pub.header_val_rec_type
                                        := oe_order_pub.g_miss_header_val_rec;
      p_old_header_val_rec           oe_order_pub.header_val_rec_type
                                        := oe_order_pub.g_miss_header_val_rec;
      p_header_adj_tbl               oe_order_pub.header_adj_tbl_type
                                        := oe_order_pub.g_miss_header_adj_tbl;
      p_old_header_adj_tbl           oe_order_pub.header_adj_tbl_type
                                        := oe_order_pub.g_miss_header_adj_tbl;
      p_header_adj_val_tbl           oe_order_pub.header_adj_val_tbl_type
                                    := oe_order_pub.g_miss_header_adj_val_tbl;
      p_old_header_adj_val_tbl       oe_order_pub.header_adj_val_tbl_type
                                    := oe_order_pub.g_miss_header_adj_val_tbl;
      p_header_price_att_tbl         oe_order_pub.header_price_att_tbl_type
                                  := oe_order_pub.g_miss_header_price_att_tbl;
      p_old_header_price_att_tbl     oe_order_pub.header_price_att_tbl_type
                                  := oe_order_pub.g_miss_header_price_att_tbl;
      p_header_adj_att_tbl           oe_order_pub.header_adj_att_tbl_type
                                    := oe_order_pub.g_miss_header_adj_att_tbl;
      p_old_header_adj_att_tbl       oe_order_pub.header_adj_att_tbl_type
                                    := oe_order_pub.g_miss_header_adj_att_tbl;
      p_header_adj_assoc_tbl         oe_order_pub.header_adj_assoc_tbl_type
                                  := oe_order_pub.g_miss_header_adj_assoc_tbl;
      p_old_header_adj_assoc_tbl     oe_order_pub.header_adj_assoc_tbl_type
                                  := oe_order_pub.g_miss_header_adj_assoc_tbl;
      p_header_scredit_tbl           oe_order_pub.header_scredit_tbl_type
                                    := oe_order_pub.g_miss_header_scredit_tbl;
      p_old_header_scredit_tbl       oe_order_pub.header_scredit_tbl_type
                                    := oe_order_pub.g_miss_header_scredit_tbl;
      p_header_scredit_val_tbl       oe_order_pub.header_scredit_val_tbl_type
                                := oe_order_pub.g_miss_header_scredit_val_tbl;
      p_old_header_scredit_val_tbl   oe_order_pub.header_scredit_val_tbl_type
                                := oe_order_pub.g_miss_header_scredit_val_tbl;
      x_line_tbl                     oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
      p_old_line_tbl                 oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
      p_line_val_tbl                 oe_order_pub.line_val_tbl_type
                                          := oe_order_pub.g_miss_line_val_tbl;
      p_old_line_val_tbl             oe_order_pub.line_val_tbl_type
                                          := oe_order_pub.g_miss_line_val_tbl;
      p_line_adj_tbl                 oe_order_pub.line_adj_tbl_type
                                          := oe_order_pub.g_miss_line_adj_tbl;
      p_old_line_adj_tbl             oe_order_pub.line_adj_tbl_type
                                          := oe_order_pub.g_miss_line_adj_tbl;
      p_line_adj_val_tbl             oe_order_pub.line_adj_val_tbl_type
                                      := oe_order_pub.g_miss_line_adj_val_tbl;
      p_old_line_adj_val_tbl         oe_order_pub.line_adj_val_tbl_type
                                      := oe_order_pub.g_miss_line_adj_val_tbl;
      p_line_price_att_tbl           oe_order_pub.line_price_att_tbl_type
                                    := oe_order_pub.g_miss_line_price_att_tbl;
      p_old_line_price_att_tbl       oe_order_pub.line_price_att_tbl_type
                                    := oe_order_pub.g_miss_line_price_att_tbl;
      p_line_adj_att_tbl             oe_order_pub.line_adj_att_tbl_type
                                      := oe_order_pub.g_miss_line_adj_att_tbl;
      p_old_line_adj_att_tbl         oe_order_pub.line_adj_att_tbl_type
                                      := oe_order_pub.g_miss_line_adj_att_tbl;
      p_line_adj_assoc_tbl           oe_order_pub.line_adj_assoc_tbl_type
                                    := oe_order_pub.g_miss_line_adj_assoc_tbl;
      p_old_line_adj_assoc_tbl       oe_order_pub.line_adj_assoc_tbl_type
                                    := oe_order_pub.g_miss_line_adj_assoc_tbl;
      p_line_scredit_tbl             oe_order_pub.line_scredit_tbl_type
                                      := oe_order_pub.g_miss_line_scredit_tbl;
      p_old_line_scredit_tbl         oe_order_pub.line_scredit_tbl_type
                                      := oe_order_pub.g_miss_line_scredit_tbl;
      p_line_scredit_val_tbl         oe_order_pub.line_scredit_val_tbl_type
                                  := oe_order_pub.g_miss_line_scredit_val_tbl;
      p_old_line_scredit_val_tbl     oe_order_pub.line_scredit_val_tbl_type
                                  := oe_order_pub.g_miss_line_scredit_val_tbl;
      p_lot_serial_tbl               oe_order_pub.lot_serial_tbl_type
                                        := oe_order_pub.g_miss_lot_serial_tbl;
      p_old_lot_serial_tbl           oe_order_pub.lot_serial_tbl_type
                                        := oe_order_pub.g_miss_lot_serial_tbl;
      p_lot_serial_val_tbl           oe_order_pub.lot_serial_val_tbl_type
                                    := oe_order_pub.g_miss_lot_serial_val_tbl;
      p_old_lot_serial_val_tbl       oe_order_pub.lot_serial_val_tbl_type
                                    := oe_order_pub.g_miss_lot_serial_val_tbl;
      p_action_request_tbl           oe_order_pub.request_tbl_type
                                           := oe_order_pub.g_miss_request_tbl;
      x_header_val_rec               oe_order_pub.header_val_rec_type;
      x_header_adj_tbl               oe_order_pub.header_adj_tbl_type;
      x_header_adj_val_tbl           oe_order_pub.header_adj_val_tbl_type;
      x_header_price_att_tbl         oe_order_pub.header_price_att_tbl_type;
      x_header_adj_att_tbl           oe_order_pub.header_adj_att_tbl_type;
      x_header_adj_assoc_tbl         oe_order_pub.header_adj_assoc_tbl_type;
      x_header_scredit_tbl           oe_order_pub.header_scredit_tbl_type;
      x_header_scredit_val_tbl       oe_order_pub.header_scredit_val_tbl_type;
      x_line_val_tbl                 oe_order_pub.line_val_tbl_type;
      x_line_adj_tbl                 oe_order_pub.line_adj_tbl_type;
      x_line_adj_val_tbl             oe_order_pub.line_adj_val_tbl_type;
      x_line_price_att_tbl           oe_order_pub.line_price_att_tbl_type;
      x_line_adj_att_tbl             oe_order_pub.line_adj_att_tbl_type;
      x_line_adj_assoc_tbl           oe_order_pub.line_adj_assoc_tbl_type;
      x_line_scredit_tbl             oe_order_pub.line_scredit_tbl_type;
      x_line_scredit_val_tbl         oe_order_pub.line_scredit_val_tbl_type;
      x_lot_serial_tbl               oe_order_pub.lot_serial_tbl_type;
      x_lot_serial_val_tbl           oe_order_pub.lot_serial_val_tbl_type;
      x_action_request_tbl           oe_order_pub.request_tbl_type;
      x_debug_file                   VARCHAR2 (100);
      p_line_tbl                     oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
                                                        -- added on 16aug PwC
      -- Local Variables
      l_msg_index_out                NUMBER (10);
      l_line_tbl_index               NUMBER;
      l_header_id                    NUMBER;
      l_item_id                      NUMBER;
      l_ordered_qty                  NUMBER;
      l_shp_pr_no                    NUMBER;
      l_item                         VARCHAR2 (2000);
      l_lookup_code                  VARCHAR2 (1000);
      l_order_num                    NUMBER;
      l_user_id                      NUMBER;
      l_appl_short_name              VARCHAR2 (100);
      l_resp_id                      NUMBER;
      l_appl_id                      NUMBER;
      l_cust_account_id              NUMBER;
      l_error_flag                   VARCHAR2 (1);
      l_unit_sell_price              NUMBER;
      l_uom                          VARCHAR2 (100);
      lv_ssrtl_oe_line_id            VARCHAR2 (10);
      lv_sec_uom_code                VARCHAR2 (10)                    := NULL;
      ln_conv_rate                   NUMBER;
      ln_sec_conv_rate               NUMBER;
      ln_base_uom_conv               NUMBER;
      ln_ship_from_org_id            NUMBER;
      lv_item_cat                    VARCHAR2 (100);
      ln_hold_count                  NUMBER;
      ln_message                     VARCHAR2 (4000)                  := NULL;
      l_split_line_id                NUMBER                             := -1;
   BEGIN
      DELETE      xxdbl_mtl_resv_shipping;

      BEGIN
         SELECT fnd.user_id, application.application_short_name,
                fresp.responsibility_id, fresp.application_id
           INTO l_user_id, l_appl_short_name,
                l_resp_id, l_appl_id
           FROM fnd_user fnd,
                fnd_responsibility_tl fresp,
                fnd_application application
          WHERE fnd.user_name = fnd_global.user_name
            AND fresp.application_id = application.application_id
            AND fresp.responsibility_name = fnd_profile.VALUE ('RESP_NAME');
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_flag := 'Y';
      END;

      -- Split Order Lines
      fnd_global.apps_initialize (l_user_id, l_resp_id, l_appl_id);
      oe_msg_pub.initialize;
      oe_debug_pub.initialize;
      mo_global.init (l_appl_short_name);                  -- Required for R12
      mo_global.set_org_context (fnd_profile.VALUE ('ORG_ID'),
                                 NULL,
                                 l_appl_short_name
                                );
      --fnd_global.set_nls_context ('AMERICAN');
      mo_global.set_policy_context ('S', fnd_profile.VALUE ('ORG_ID'));

      FOR rec_line IN
         (SELECT line.*, oola.ordered_quantity, oola.ordered_quantity2,
                 oola.schedule_ship_date line_schedule_ship_date,
                 oola.CONTEXT, oola.attribute1 oola_attribute1,
                 oola.attribute2 oola_attribute2,
                 oola.attribute3 oola_attribute3,
                 oola.attribute4 oola_attribute4,
                 oola.attribute5 oola_attribute5,
                 oola.attribute6 oola_attribute6,
                 oola.attribute7 oola_attribute7,
                 oola.attribute8 oola_attribute8,
                 oola.attribute9 oola_attribute9,
                 oola.attribute10 oola_attribute10,
                 oola.attribute11 oola_attribute11,
                 oola.attribute12 oola_attribute12,
                 oola.attribute13 oola_attribute13,
                 oola.attribute14 oola_attribute14,
                 oola.attribute15 oola_attribute15
            FROM xxdbl_omshipping_headers xxoh,
                 xxdbl_omshipping_line line,
                 oe_order_lines_all oola
           WHERE 1 = 1
             AND xxoh.omshipping_header_id = line.omshipping_header_id
             AND xxoh.omshipping_header_id = p_omshipping_hdr_id
             AND line.order_line_id = oola.line_id
             AND ROUND (NVL (oola.ordered_quantity, 0), 5) <>
                                      ROUND (NVL (line.picking_qty_crt, 0), 5)
             AND line.omshipping_line_status NOT IN
                                       ('CANCELLED') --('CLOSED', 'CANCELLED')
             AND oola.flow_status_code = 'AWAITING_SHIPPING')
      LOOP
         IF NVL (rec_line.attribute14, 'SEWING THREAD') != 'SEWING THREAD'
         THEN
            INSERT INTO xxdbl_mtl_resv_shipping
               SELECT *
                 FROM mtl_reservations
                WHERE 1 = 1
                  AND demand_source_line_id = rec_line.order_line_id
                  AND demand_source_type_id = 2
                  AND inventory_item_id = rec_line.item_id
                  AND organization_id = rec_line.warehouse_id;

            DELETE FROM mtl_reservations
                  WHERE 1 = 1
                    AND demand_source_line_id = rec_line.order_line_id
                    AND demand_source_type_id = 2
                    AND inventory_item_id = rec_line.item_id
                    AND organization_id = rec_line.warehouse_id;
         END IF;

         UPDATE oe_order_lines_all oola
            SET calculate_price_flag = 'N'
          WHERE oola.header_id = rec_line.order_id
            AND oola.line_id = TO_NUMBER (rec_line.order_line_id);

         --This is to UPDATE order line
         l_line_tbl_index := 1;
         -- Changed attributes
         l_header_rec := oe_order_pub.g_miss_header_rec;
         l_header_rec.header_id := rec_line.order_id;
         l_header_rec.operation := oe_globals.g_opr_update;
         l_line_tbl (l_line_tbl_index) := oe_order_pub.g_miss_line_rec;
         l_line_tbl (l_line_tbl_index).operation := oe_globals.g_opr_update;
         l_line_tbl (l_line_tbl_index).split_by := fnd_global.user_id;
         -- user_id
         l_line_tbl (l_line_tbl_index).split_action_code := 'SPLIT';
         l_line_tbl (l_line_tbl_index).header_id := rec_line.order_id;
         l_line_tbl (l_line_tbl_index).line_id :=
                                            TO_NUMBER (rec_line.order_line_id);
         l_line_tbl (l_line_tbl_index).global_attribute1 :=
                                                   rec_line.omshipping_line_id;
         --6431;
         l_line_tbl (l_line_tbl_index).ordered_quantity :=
                                          TO_NUMBER (rec_line.picking_qty_crt);
         l_line_tbl (l_line_tbl_index).ordered_quantity2 :=
                                          TO_NUMBER (rec_line.picking_qty_sft);
         l_line_tbl (l_line_tbl_index).change_reason := 'MISC';
         -- change reason code
         l_line_tbl_index := 2;
         l_line_tbl (l_line_tbl_index).header_id := rec_line.order_id;
         l_line_tbl (l_line_tbl_index) := oe_order_pub.g_miss_line_rec;
         l_line_tbl (l_line_tbl_index).operation := oe_globals.g_opr_create;
         l_line_tbl (l_line_tbl_index).split_by := fnd_global.user_id;
         -- user_id
         l_line_tbl (l_line_tbl_index).split_action_code := 'SPLIT';
         l_line_tbl (l_line_tbl_index).calculate_price_flag := 'Y';
         l_line_tbl (l_line_tbl_index).split_from_line_id :=
                                            TO_NUMBER (rec_line.order_line_id);
         l_line_tbl (l_line_tbl_index).inventory_item_id := rec_line.item_id;
         l_line_tbl (l_line_tbl_index).schedule_ship_date :=
                                              rec_line.line_schedule_ship_date;
         l_line_tbl (l_line_tbl_index).ordered_quantity :=
            (  NVL (rec_line.ordered_quantity, 0)
             --NVL (rec_line.attribute3, 0)
             - NVL (rec_line.picking_qty_crt, 0)
            );
         l_line_tbl (l_line_tbl_index).ordered_quantity2 :=
            (  NVL (rec_line.ordered_quantity2, 0)
             -- NVL (rec_line.attribute4, 0)
             - NVL (rec_line.picking_qty_sft, 0)
            );
         -- CALL TO PROCESS ORDER
         oe_order_pub.process_order
                        (p_api_version_number          => 1.0,
                         p_init_msg_list               => fnd_api.g_false,
                         p_return_values               => fnd_api.g_false,
                         p_action_commit               => fnd_api.g_false,
                         x_return_status               => l_return_status,
                         x_msg_count                   => l_msg_count,
                         x_msg_data                    => l_msg_data,
                         p_header_rec                  => l_header_rec,
                         p_line_tbl                    => l_line_tbl,
                         p_action_request_tbl          => l_action_request_tbl
                                                                              -- OUT PARAMETERS
         ,
                         x_header_rec                  => p_header_rec,
                         -- added on 16aug PwC
                         x_header_val_rec              => x_header_val_rec,
                         x_header_adj_tbl              => x_header_adj_tbl,
                         x_header_adj_val_tbl          => x_header_adj_val_tbl,
                         x_header_price_att_tbl        => x_header_price_att_tbl,
                         x_header_adj_att_tbl          => x_header_adj_att_tbl,
                         x_header_adj_assoc_tbl        => x_header_adj_assoc_tbl,
                         x_header_scredit_tbl          => x_header_scredit_tbl,
                         x_header_scredit_val_tbl      => x_header_scredit_val_tbl,
                         x_line_tbl                    => p_line_tbl,
                         -- added on 16aug PwC
                         x_line_val_tbl                => x_line_val_tbl,
                         x_line_adj_tbl                => x_line_adj_tbl,
                         x_line_adj_val_tbl            => x_line_adj_val_tbl,
                         x_line_price_att_tbl          => x_line_price_att_tbl,
                         x_line_adj_att_tbl            => x_line_adj_att_tbl,
                         x_line_adj_assoc_tbl          => x_line_adj_assoc_tbl,
                         x_line_scredit_tbl            => x_line_scredit_tbl,
                         x_line_scredit_val_tbl        => x_line_scredit_val_tbl,
                         x_lot_serial_tbl              => x_lot_serial_tbl,
                         x_lot_serial_val_tbl          => x_lot_serial_val_tbl,
                         x_action_request_tbl          => p_action_request_tbl
                        -- added on 16aug PwC
                        );

         --dbms_output.put_line('OM Debug file: ' ||oe_debug_pub.G_DIR||'/'||oe_debug_pub.G_FILE);
         FOR i IN 1 .. l_msg_count
         LOOP
            oe_msg_pub.get (p_msg_index          => i,
                            p_encoded            => fnd_api.g_false,
                            p_data               => l_msg_data,
                            p_msg_index_out      => l_msg_index_out
                           );
         -- DBMS_OUTPUT.put_line ('message is: ' || l_msg_data);
         -- DBMS_OUTPUT.put_line ('message index is: ' || l_msg_index_out);
         END LOOP;

         -- Check the return status
         IF l_return_status <> fnd_api.g_ret_sts_success
         THEN
            x_message :=
                  x_message
               || CHR (10)
               || 'Split Line Failed for Sales Order: '
               || rec_line.order_number
               || ' and Order Line No: '
               || rec_line.order_line_no
               || ' and item: '
               || rec_line.item_code
               || '.'
               || l_msg_data;
         /*ELSE
            IF     rec_line.attribute18 <> 'A+'
               AND rec_line.attribute14 = 'SEWING THREAD'
            THEN
               DELETE      mtl_reservations
                     WHERE 1 = 1
                       AND demand_source_type_id = 2
                       AND demand_source_line_id IN (
                              SELECT line_id
                                FROM oe_order_lines_all
                               WHERE 1 = 1
                                 AND split_from_line_id =
                                            TO_NUMBER (rec_line.order_line_id));
            END IF;

            UPDATE oe_order_lines_all oola
               SET calculate_price_flag = 'Y'
             WHERE oola.header_id = rec_line.order_id
               AND NVL (oola.cancelled_flag, 'N') = 'N'
               AND EXISTS (
                      SELECT 'X'
                        FROM oe_order_headers_all ooha,
                             oe_transaction_types_tl ottt
                       WHERE 1 = 1
                         AND ooha.header_id = oola.header_id
                         AND ooha.order_type_id = ottt.transaction_type_id
                         AND ottt.transaction_type_id IN (1090, 1092, 1094));

            DECLARE
                Initialize the proper Context
               l_org_id                   NUMBER         := fnd_global.org_id;
               l_application_id           NUMBER   := fnd_global.resp_appl_id;
               l_responsibility_id        NUMBER        := fnd_global.resp_id;
               l_user_id                  NUMBER        := fnd_global.user_id;
                Initialize the record to G_MISS to enable defaulting
               l_header_rec               oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
               l_old_header_rec           oe_order_pub.header_rec_type;
               l_line_tbl                 oe_order_pub.line_tbl_type;
               l_old_line_tbl             oe_order_pub.line_tbl_type;
               l_action_request_tbl       oe_order_pub.request_tbl_type;
               x_header_rec               oe_order_pub.header_rec_type;
               x_header_val_rec           oe_order_pub.header_val_rec_type;
               x_header_adj_tbl           oe_order_pub.header_adj_tbl_type;
               x_header_adj_val_tbl       oe_order_pub.header_adj_val_tbl_type;
               x_header_price_att_tbl     oe_order_pub.header_price_att_tbl_type;
               x_header_adj_att_tbl       oe_order_pub.header_adj_att_tbl_type;
               x_header_adj_assoc_tbl     oe_order_pub.header_adj_assoc_tbl_type;
               x_header_scredit_tbl       oe_order_pub.header_scredit_tbl_type;
               x_header_scredit_val_tbl   oe_order_pub.header_scredit_val_tbl_type;
               x_line_tbl                 oe_order_pub.line_tbl_type;
               x_line_val_tbl             oe_order_pub.line_val_tbl_type;
               x_line_adj_tbl             oe_order_pub.line_adj_tbl_type;
               x_line_adj_val_tbl         oe_order_pub.line_adj_val_tbl_type;
               x_line_price_att_tbl       oe_order_pub.line_price_att_tbl_type;
               x_line_adj_att_tbl         oe_order_pub.line_adj_att_tbl_type;
               x_line_adj_assoc_tbl       oe_order_pub.line_adj_assoc_tbl_type;
               x_line_scredit_tbl         oe_order_pub.line_scredit_tbl_type;
               x_line_scredit_val_tbl     oe_order_pub.line_scredit_val_tbl_type;
               x_lot_serial_tbl           oe_order_pub.lot_serial_tbl_type;
               x_lot_serial_val_tbl       oe_order_pub.lot_serial_val_tbl_type;
               x_action_request_tbl       oe_order_pub.request_tbl_type;
               l_return_status            VARCHAR2 (2000);
               l_msg_count                NUMBER;
               l_msg_data                 VARCHAR2 (2000);
               l_file_val                 VARCHAR2 (1000);
               l_msg_index_out            NUMBER (10);
               --Added --this statement
               l_line_cnt                 NUMBER                         := 0;
               l_top_model_line_index     NUMBER;
               l_link_to_line_index       NUMBER;
            BEGIN
                Set the appropriate context
               fnd_global.apps_initialize (l_user_id,
                                           l_responsibility_id,
                                           l_application_id,
                                           NULL
                                          );
               mo_global.init ('ONT');              --Muti-org context setting
               mo_global.set_policy_context ('S', l_org_id);         -- org_id
                Turn on OM Debug
               oe_debug_pub.debug_on;
               oe_debug_pub.initialize;
               oe_debug_pub.setdebuglevel (5);
               l_file_val := oe_debug_pub.set_debug_mode ('FILE');
               DBMS_OUTPUT.put_line ('Debug log is stored at: ' || l_file_val);
               oe_debug_pub.ADD ('START OF NEW DEBUG'); --Added this statement
                Populate the required Header Fields
               l_header_rec.operation := oe_globals.g_opr_update;
               l_header_rec.header_id := rec_line.order_id;
                                                          -- header_id of order to reprice
                Populate the Actions Table for Header
               l_action_request_tbl (1).request_type :=
                                                      oe_globals.g_price_order;
               l_action_request_tbl (1).entity_code :=
                                                    oe_globals.g_entity_header;
               l_action_request_tbl (1).entity_id := l_header_rec.header_id;
                Call the Process Order API with Header Rec and Line Tbl
               oe_order_pub.process_order
                        (p_api_version_number          => 1.0,
                         p_org_id                      => l_org_id  -- For R12
                                                                  ,
                         p_init_msg_list               => fnd_api.g_true,
                         p_return_values               => fnd_api.g_true,
                         p_action_commit               => fnd_api.g_true,
                         x_return_status               => l_return_status,
                         x_msg_count                   => l_msg_count,
                         x_msg_data                    => l_msg_data,
                         p_action_request_tbl          => l_action_request_tbl,
                         p_header_rec                  => l_header_rec,
                         p_old_header_rec              => l_old_header_rec,
                         p_line_tbl                    => l_line_tbl,
                         p_old_line_tbl                => l_old_line_tbl,
                         x_header_rec                  => x_header_rec,
                         x_header_val_rec              => x_header_val_rec,
                         x_header_adj_tbl              => x_header_adj_tbl,
                         x_header_adj_val_tbl          => x_header_adj_val_tbl,
                         x_header_price_att_tbl        => x_header_price_att_tbl,
                         x_header_adj_att_tbl          => x_header_adj_att_tbl,
                         x_header_adj_assoc_tbl        => x_header_adj_assoc_tbl,
                         x_header_scredit_tbl          => x_header_scredit_tbl,
                         x_header_scredit_val_tbl      => x_header_scredit_val_tbl,
                         x_line_tbl                    => x_line_tbl,
                         x_line_val_tbl                => x_line_val_tbl,
                         x_line_adj_tbl                => x_line_adj_tbl,
                         x_line_adj_val_tbl            => x_line_adj_val_tbl,
                         x_line_price_att_tbl          => x_line_price_att_tbl,
                         x_line_adj_att_tbl            => x_line_adj_att_tbl,
                         x_line_adj_assoc_tbl          => x_line_adj_assoc_tbl,
                         x_line_scredit_tbl            => x_line_scredit_tbl,
                         x_line_scredit_val_tbl        => x_line_scredit_val_tbl,
                         x_lot_serial_tbl              => x_lot_serial_tbl,
                         x_lot_serial_val_tbl          => x_lot_serial_val_tbl,
                         x_action_request_tbl          => x_action_request_tbl
                        );

               -- Retrieve messages
               FOR i IN 1 .. l_msg_count
               LOOP
                  oe_msg_pub.get (p_msg_index          => i,
                                  p_encoded            => fnd_api.g_false,
                                  p_data               => l_msg_data,
                                  p_msg_index_out      => l_msg_index_out
                                 );
                  DBMS_OUTPUT.put_line ('message is: ' || l_msg_data);
                  DBMS_OUTPUT.put_line ('message index is: '
                                        || l_msg_index_out
                                       );
               END LOOP;

               -- Check the return status
               added statements above
                Display the status and Order Number if successfully created
               IF l_return_status = 'S'
               THEN
                  DBMS_OUTPUT.put_line (   'Order Number : '
                                        || x_header_rec.order_number
                                        || '; Header Id : '
                                        || x_header_rec.header_id
                                       );
               ELSE
                  DBMS_OUTPUT.put_line ('Error(s) while repricing Order.');
                  DBMS_OUTPUT.put_line (l_msg_count || ';' || l_msg_data);
                  x_message :=
                        x_message
                     || CHR (10)
                     || 'Split Line Failed for Sales Order: '
                     || rec_line.order_number
                     || ' and Order Line No: '
                     || rec_line.order_line_no
                     || ' and item: '
                     || rec_line.item_code
                     || '.'
                     || l_msg_data;
               END IF;

                Display the messages in the message stack
               FOR i IN 1 .. oe_msg_pub.g_msg_tbl.COUNT
               LOOP
                  DBMS_OUTPUT.put_line (apps.oe_msg_pub.get (i, 'F'));
               END LOOP;

                Turn off OM Debug
               oe_debug_pub.debug_off;
               oe_msg_pub.g_msg_tbl.DELETE;
            END;*/
         ELSE
            IF rec_line.attribute14 = 'SEWING THREAD'
            THEN
               INSERT INTO xxdbl.xxdbl_mtl_reservations
                  SELECT *
                    FROM mtl_reservations mr
                   WHERE demand_source_line_id IN (
                            SELECT oola.line_id
                              FROM oe_order_lines_all oola
                             WHERE split_from_line_id =
                                                       rec_line.order_line_id);

               DELETE FROM mtl_reservations mr
                     WHERE demand_source_line_id IN (
                              SELECT oola.line_id
                                FROM oe_order_lines_all oola
                               WHERE split_from_line_id =
                                                       rec_line.order_line_id);
            ELSE
               create_resv_yarn
                         (p_omshiping_line_id        => rec_line.omshipping_line_id,
                          p_split_order_line_id      => NULL,
                          p_resv_type                => 'MAIN_LINE',
                          x_message                  => ln_message
                         );

               IF ln_message IS NOT NULL
               THEN
                  x_message := ln_message;
               ELSE
                  BEGIN
                     SELECT NVL (MAX (oola.line_id), -1)
                       INTO l_split_line_id
                       FROM oe_order_lines_all oola
                      WHERE split_from_line_id = rec_line.order_line_id;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_split_line_id := -1;
                  END;

                  IF l_split_line_id > 0
                  THEN
                     create_resv_yarn
                         (p_omshiping_line_id        => rec_line.omshipping_line_id,
                          p_split_order_line_id      => l_split_line_id,
                          p_resv_type                => 'SPLIT_LINE',
                          x_message                  => ln_message
                         );
                  ELSE
                     IF x_message IS NOT NULL
                     THEN
                        x_message :=
                              x_message
                           || CHR (10)
                           || 'Unable to get Split Line Information for Sales Order. ';
                     ELSE
                        x_message :=
                           'Unable to get Split Line Information for Sales Order. ';
                     END IF;
                  END IF;

                  IF ln_message IS NOT NULL
                  THEN
                     x_message := ln_message;
                  END IF;
               END IF;
            END IF;

            UPDATE oe_order_lines_all
               SET CONTEXT = rec_line.CONTEXT,
                   attribute1 = rec_line.oola_attribute1,
                   attribute2 = rec_line.oola_attribute2,
                   attribute3 = rec_line.oola_attribute3,
                   attribute4 = rec_line.oola_attribute4,
                   attribute5 = rec_line.oola_attribute5,
                   attribute6 = rec_line.oola_attribute6,
                   attribute7 = rec_line.oola_attribute7,
                   attribute8 = rec_line.oola_attribute8,
                   attribute9 = rec_line.oola_attribute9,
                   attribute10 = rec_line.oola_attribute10,
                   attribute11 = rec_line.oola_attribute11,
                   attribute12 = rec_line.oola_attribute12,
                   attribute13 = rec_line.oola_attribute13,
                   attribute14 = rec_line.oola_attribute14,
                   attribute15 = rec_line.oola_attribute15
             WHERE line_id IN (
                             SELECT oola.line_id
                               FROM oe_order_lines_all oola
                              WHERE split_from_line_id =
                                                        rec_line.order_line_id);
         END IF;
      END LOOP;

      IF x_message IS NULL
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END split_line_new1;

   PROCEDURE create_update_reservations_new (
      p_omshipping_hdr_id   IN       NUMBER,
      x_message             OUT      VARCHAR2
   )
   IS
      l_current_reservation_id   NUMBER                                 := -1;
      l_record_count             NUMBER                                  := 1;
      l_rsv                      inv_reservation_global.mtl_reservation_rec_type;
      l_rsv_del                  inv_reservation_global.mtl_reservation_rec_type;
      l_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_msg_count                NUMBER;
      x_msg_data                 VARCHAR2 (240);
      x_rsv_id                   NUMBER;
      x_dummy_sn                 inv_reservation_global.serial_number_tbl_type;
      x_status                   VARCHAR2 (1);
      x_qty                      NUMBER;
      lx_status                  VARCHAR2 (1);
      lx_msg_count               NUMBER;
      lx_msg_data                VARCHAR2 (240);
      lv_rsv                     inv_reservation_global.mtl_reservation_rec_type;
      lv_dummy_sn                inv_reservation_global.serial_number_tbl_type;
      l_sales_order_id           NUMBER;
      l_current_atr              NUMBER                                  := 0;
   BEGIN
      FOR rec_line IN
         (SELECT lines.customer_number, lines.customer_name,
                 lines.customer_id, lines.order_number, lines.order_id,
                 lines.ship_to_warehouse, lines.warehouse_id,
                 lines.order_line_no,
                 NVL (lines.attribute3, 0) original_line_pri_qty,
                 ROUND (NVL (lines.picking_qty_crt, 0), 5) picking_qty_crt,
                 NVL (lines.attribute4, 0) original_line_sec_qty,
                 ROUND (NVL (lines.picking_qty_sft, 0), 5) picking_qty_sft,
                 lines.order_line_id, lines.attribute1 primary_uom,
                 lines.attribute2 sececondary_uom, line_lot.*
            FROM xxdbl_omshipping_headers xxoh,
                 xxdbl_omshipping_line lines,
                 xxdbl_omshipping_lot_lines line_lot
           WHERE 1 = 1
             AND xxoh.omshipping_header_id = lines.omshipping_header_id
             AND xxoh.omshipping_header_id = p_omshipping_hdr_id
             AND NVL (lines.attribute5, '1') = '2'
             AND line_lot.attribute1 IS NULL
             AND lines.omshipping_line_status NOT IN
                                       ('CANCELLED') --('CLOSED', 'CANCELLED')
             AND lines.omshipping_line_id = line_lot.omshipping_line_id
             AND NOT EXISTS (
                    SELECT 'X'
                      FROM mtl_reservations mr
                     WHERE mr.demand_source_line_id = lines.order_line_id
                       AND mr.lot_number IS NOT NULL))
      LOOP
         --debug_insert ('rec_line.lot_number:        ' || rec_line.lot_number);
         SELECT xxdbl_shiping_transaction_pkg.available_to_reserve
                           (p_organization_id        => rec_line.warehouse_id,
                            p_inventory_item_id      => rec_line.item_id,
                            p_subinventory_code      => rec_line.subinventory_code,
                            p_locator_id             => rec_line.locator_id,
                            p_lot_number             => rec_line.lot_number
                           )
           INTO l_current_atr
           FROM DUAL;

         IF l_current_atr < rec_line.quantity_crt
         THEN
            IF x_message IS NULL
            THEN
               x_message :=
                     'Create Reservation Error: '
                  || 'Current Available to Reserve for the Item '
                  || rec_line.item_code
                  || ' and Lot Number '
                  || rec_line.lot_number
                  || ' is not sufficient to create reservation. ';
            ELSE
               x_message :=
                     x_message
                  || CHR (10)
                  || 'Current Available to Reserve for the Item '
                  || rec_line.item_code
                  || ' and Lot Number '
                  || rec_line.lot_number
                  || ' is not sufficient to create reservation. ';
            END IF;
         ELSE
            /*IF l_record_count = 1
            THEN*/
            BEGIN
               SELECT mr.reservation_id
                 INTO l_current_reservation_id
                 FROM mtl_reservations mr
                WHERE mr.organization_id = rec_line.warehouse_id
                  AND mr.inventory_item_id = rec_line.item_id
                  AND mr.demand_source_type_id = 2
                  --AND demand_source_header_id = rec_line.order_id
                  AND mr.demand_source_line_id = rec_line.order_line_id
                  AND mr.supply_source_type_id = 13
                  AND mr.orig_supply_source_type_id = 13
                  AND mr.orig_demand_source_type_id = 2
                  --AND orig_demand_source_header_id = rec_line.order_id
                  AND mr.orig_demand_source_line_id = rec_line.order_line_id
                  AND mr.lot_number IS NULL
                  AND NOT EXISTS (SELECT 'X'
                                    FROM xxdbl_omshipping_lot_lines xx
                                   WHERE xx.attribute1 = mr.reservation_id);
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_current_reservation_id := -1;
            END;

            --debug_insert (   'l_current_reservation_id:        '|| l_current_reservation_id);
            IF rec_line.original_line_pri_qty = rec_line.picking_qty_crt
            THEN
               -- Delete Reservation
               IF l_current_reservation_id > 0
               THEN
                  l_rsv_del.reservation_id := l_current_reservation_id;

                  INSERT INTO xxdbl.xxdbl_mtl_reservations
                     SELECT *
                       FROM mtl_reservations
                      WHERE reservation_id = l_current_reservation_id;

                  --debug_insert('inv_reservation_pub.delete_reservation:        ');
                  inv_reservation_pub.delete_reservation
                                           (p_api_version_number      => 1.0,
                                            p_init_msg_lst            => fnd_api.g_true,
                                            x_return_status           => lx_status,
                                            x_msg_count               => lx_msg_count,
                                            x_msg_data                => lx_msg_data,
                                            p_rsv_rec                 => l_rsv_del,
                                            p_serial_number           => lv_dummy_sn
                                           );

                  IF lx_status <> fnd_api.g_ret_sts_success
                  THEN
                     IF lx_msg_count > 1
                     THEN
                        FOR i IN 1 .. lx_msg_count
                        LOOP
                           IF x_message IS NULL
                           THEN
                              x_message :=
                                    'Delete Reservation Error: '
                                 || i
                                 || '. '
                                 || SUBSTR
                                       (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                        1,
                                        255
                                       );
                           ELSE
                              x_message :=
                                    x_message
                                 || 'Delete Reservation Error: '
                                 || i
                                 || '. '
                                 || SUBSTR
                                       (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                        1,
                                        255
                                       );
                           END IF;
                        END LOOP;
                     ELSIF lx_msg_count = 1
                     THEN
                        IF x_message IS NULL
                        THEN
                           x_message :=
                                  'Delete Reservation Error: ' || lx_msg_data;
                        ELSE
                           x_message :=
                                 x_message
                              || 'Delete Reservation Error: '
                              || lx_msg_data;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            ELSE
               -- Update Reservation
               NULL;
            END IF;

            --END IF;

            /*IF l_current_reservation_id > -2
            THEN*/
            --debug_insert ('rec_line.order_number:        ' || rec_line.order_number);
            BEGIN
               SELECT sales_order_id
                 INTO l_sales_order_id
                 FROM mtl_sales_orders
                WHERE segment1 = rec_line.order_number || '';
            EXCEPTION
               WHEN OTHERS
               THEN
                  --debug_insert ('Error:        ' || sqlerrm);
                  l_sales_order_id := -1;
            END;

            --debug_insert ('l_sales_order_id:        ' || l_sales_order_id);
            IF l_sales_order_id < 0
            THEN
               IF x_message IS NULL
               THEN
                  x_message :=
                        'Unable to find Sales Order '
                     || rec_line.order_number
                     || '  Lot Number:     '
                     || rec_line.lot_number;
               ELSE
                  x_message :=
                        x_message
                     || CHR (10)
                     || 'Unable to find Sales Order '
                     || rec_line.order_number
                     || '  Lot Number:     '
                     || rec_line.lot_number;
               END IF;
            ELSE
               l_rsv.requirement_date := SYSDATE;
               l_rsv.organization_id := rec_line.warehouse_id;
               --mtl_parameters.organization id
               l_rsv.inventory_item_id := rec_line.item_id;
               --mtl_system_items.Inventory_item_id;
               l_rsv.demand_source_name := NULL;
               l_rsv.demand_source_type_id := 2;
               l_rsv.demand_source_header_id := l_sales_order_id;
               --1334166 ; --mtl_sales_orders.sales_order_id
               l_rsv.demand_source_line_id := rec_line.order_line_id;
               --4912468 ; -- oe_order_lines.line_id
               l_rsv.primary_uom_code := rec_line.primary_uom;
               l_rsv.primary_uom_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.autodetail_group_id := NULL;
               l_rsv.external_source_code := NULL;
               l_rsv.external_source_line_id := NULL;
               l_rsv.supply_source_header_id := NULL;
               l_rsv.supply_source_line_id := NULL;
               l_rsv.supply_source_name := NULL;
               l_rsv.supply_source_line_detail := NULL;
               l_rsv.revision := NULL;
               l_rsv.subinventory_id := NULL;
               l_rsv.lot_number_id := NULL;
               l_rsv.pick_slip_number := NULL;
               l_rsv.lpn_id := NULL;
               l_rsv.attribute_category := NULL;
               l_rsv.attribute1 := NULL;
               l_rsv.attribute2 := NULL;
               l_rsv.attribute3 := NULL;
               l_rsv.attribute4 := NULL;
               l_rsv.attribute5 := NULL;
               l_rsv.attribute6 := NULL;
               l_rsv.attribute7 := NULL;
               l_rsv.attribute8 := NULL;
               l_rsv.attribute9 := NULL;
               l_rsv.attribute10 := NULL;
               l_rsv.attribute11 := NULL;
               l_rsv.attribute12 := NULL;
               l_rsv.attribute13 := NULL;
               l_rsv.attribute14 := NULL;
               l_rsv.attribute15 := NULL;
               l_rsv.demand_source_delivery := NULL;
               l_rsv.reservation_uom_code := rec_line.primary_uom;
               l_rsv.reservation_quantity := rec_line.quantity_crt;
               l_rsv.primary_reservation_quantity := rec_line.quantity_crt;
               l_rsv.secondary_uom_code := rec_line.sececondary_uom;

               IF NVL (rec_line.quantity_sft, 0) > 0
               THEN
                  l_rsv.secondary_reservation_quantity :=
                                                        rec_line.quantity_sft;
               ELSE
                  l_rsv.secondary_reservation_quantity := NULL;
               END IF;

               l_rsv.lot_number := rec_line.lot_number;        --p_lot_number;
               l_rsv.locator_id := rec_line.locator_id;
               l_rsv.supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.orig_supply_source_type_id := 13;
               --inv_reservation_global.g_source_type_inv;
               l_rsv.ship_ready_flag := 2;
               l_rsv.subinventory_code := rec_line.subinventory_code;
               /*l_rsv.primary_uom_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.subinventory_id := NULL;
               l_rsv.attribute15 := NULL;
               l_rsv.attribute14 := NULL;
               l_rsv.attribute13 := NULL;
               l_rsv.attribute12 := NULL;
               l_rsv.attribute11 := NULL;
               l_rsv.attribute10 := NULL;
               l_rsv.attribute9 := NULL;
               l_rsv.attribute8 := NULL;
               l_rsv.attribute7 := NULL;
               l_rsv.attribute6 := NULL;
               l_rsv.attribute5 := NULL;
               l_rsv.attribute4 := NULL;
               l_rsv.attribute3 := NULL;
               l_rsv.attribute2 := NULL;
               l_rsv.attribute1 := NULL;
               l_rsv.attribute_category := NULL;
               l_rsv.lpn_id := NULL;
               l_rsv.pick_slip_number := NULL;
               l_rsv.lot_number_id := NULL;
               l_rsv.revision := NULL;
               l_rsv.external_source_line_id := NULL;
               l_rsv.external_source_code := NULL;
               l_rsv.autodetail_group_id := NULL;
               l_rsv.reservation_uom_id := NULL;
               l_rsv.primary_uom_id := NULL;
               l_rsv.demand_source_delivery := NULL;
               l_rsv.supply_source_line_detail := NULL;
               l_rsv.supply_source_name := NULL;
               l_rsv.supply_source_header_id := NULL;
               l_rsv.supply_source_line_id := NULL;*/
               x_status := NULL;
               x_msg_count := NULL;
               x_msg_data := NULL;
               inv_reservation_pub.create_reservation
                                               (p_api_version_number      => 1.0,
                                                x_return_status           => x_status,
                                                x_msg_count               => x_msg_count,
                                                x_msg_data                => x_msg_data,
                                                --p_init_msg_lst            => fnd_api.g_false,
                                                p_rsv_rec                 => l_rsv,
                                                p_serial_number           => l_dummy_sn,
                                                x_serial_number           => x_dummy_sn,
                                                x_quantity_reserved       => x_qty,
                                                x_reservation_id          => x_rsv_id
                                               );

               /*-- -- debug_insert (   'inv_reservation_pub.create_reservation:        '
                             || x_status
                            );
               -- -- debug_insert ('x_rsv_id:        ' || x_rsv_id);*/

               /*DBMS_OUTPUT.put_line ('Return status    = ' || x_status);
               DBMS_OUTPUT.put_line (   'msg count        = '
                                     || TO_CHAR (x_msg_count)
                                    );
               DBMS_OUTPUT.put_line ('msg data         = ' || x_msg_data);
               DBMS_OUTPUT.put_line ('Quantity reserved = ' || TO_CHAR (x_qty));
               DBMS_OUTPUT.put_line ('Reservation id   = ' || TO_CHAR (x_rsv_id));*/
               -- debug_insert (2.1 || ':' || x_msg_count);
               -- debug_insert (2.2 || ':' || x_status);
               IF x_status <> fnd_api.g_ret_sts_success
               THEN
                  -- debug_insert (3);
                  IF x_msg_count > 1
                  THEN
                     -- debug_insert (4);
                     FOR i IN 1 .. x_msg_count
                     LOOP
                        IF x_message IS NULL
                        THEN
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        ELSE
                           x_msg_data :=
                              SUBSTR
                                 (fnd_msg_pub.get
                                                 (p_encoded      => fnd_api.g_false),
                                  1,
                                  255
                                 );
                           x_message :=
                                 x_message
                              || CHR (10)
                              || 'Create Reservation Error: '
                              || i
                              || '. '
                              || x_msg_data;
                        END IF;
                     END LOOP;
                  ELSIF x_msg_count = 1
                  THEN
                     -- debug_insert (5);
                     IF x_message IS NULL
                     THEN
                        x_message :=
                                   'Create Reservation Error: ' || x_msg_data;
                     ELSE
                        x_message :=
                              x_message
                           || CHR (10)
                           || 'Create Reservation Error: '
                           || x_msg_data;
                     END IF;
                  END IF;
               ELSE
                  UPDATE xxdbl_omshipping_lot_lines
                     SET attribute1 = x_rsv_id
                   WHERE omshipping_lot_id = rec_line.omshipping_lot_id;
               END IF;
            END IF;

            l_record_count := l_record_count + 1;
         END IF;
      /*ELSE
         EXIT;
      END IF;*/
      END LOOP;

      IF x_message IS NULL
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END create_update_reservations_new;

   PROCEDURE transact_move_order (
      p_move_order_line_id   IN       NUMBER,
      p_api                  IN       VARCHAR2,
      p_trx_temp_id          IN       NUMBER,
      p_transaction_date     IN       DATE,
      p_return_status        OUT      VARCHAR2,
      p_return_message       OUT      VARCHAR2
   )
   IS
      a_l_api_version           NUMBER                                 := 1.0;
      a_l_init_msg_list         VARCHAR2 (2)               := fnd_api.g_false;
      --fnd_api.g_true;
      a_l_commit                VARCHAR2 (2)               := fnd_api.g_false;
      --fnd_api.g_true;
      a_x_return_status         VARCHAR2 (2);
      a_x_msg_count             NUMBER                                  := 0;
      a_x_msg_data              VARCHAR2 (1000);
      a_l_move_order_type       NUMBER                                  := 3;
      a_l_transaction_mode      NUMBER                                  := 1;
      -- 1 Online, 2 Concurrent, 3 Background
      a_l_trolin_tbl            inv_move_order_pub.trolin_tbl_type;
      a_l_mold_tbl              inv_mo_line_detail_util.g_mmtt_tbl_type;
      a_x_mmtt_tbl              inv_mo_line_detail_util.g_mmtt_tbl_type;
      a_x_trolin_tbl            inv_move_order_pub.trolin_tbl_type;
      l_trolin_tbl_old          inv_move_order_pub.trolin_tbl_type;
      l_trolin_tbl_new          inv_move_order_pub.trolin_tbl_type;
      a_l_transaction_date      DATE                               := SYSDATE;
      a_l_user_id               NUMBER;
      a_l_resp_id               NUMBER;
      a_l_appl_id               NUMBER;
      v_transaction_date        DATE;
      l_out_index               NUMBER                                  := 0;
      l_delivery_id             NUMBER                                  := 0;
      l_user_id                 NUMBER                  := fnd_global.user_id;
      l_resp_id                 NUMBER                  := fnd_global.resp_id;
      l_resp_appl_id            NUMBER             := fnd_global.resp_appl_id;
      k                         NUMBER                                  := 0;

      --
      CURSOR c_mo_details
      IS
         SELECT mtrh.header_id h_1, mtrh.request_number,
                mtrh.move_order_type, mtrh.organization_id o_1, mtrl.*,
                (SELECT DISTINCT operating_unit
                            FROM org_organization_definitions
                           WHERE organization_id =
                                                  mtrh.organization_id)
                                                                      org_id
           FROM mtl_txn_request_headers mtrh, mtl_txn_request_lines mtrl
          WHERE mtrh.header_id = mtrl.header_id
            AND mtrl.line_id = p_move_order_line_id;

---------------------------------------------------------
      x_return_status           VARCHAR2 (1);
      x_msg_data                VARCHAR2 (1000);
      x_msg_count               NUMBER;
      l_header_id               NUMBER;
      l_move_order_type         NUMBER;
      x_number_of_rows          NUMBER;
      x_qty_detailed            NUMBER;
      l_revision                NUMBER;
      x_locator_id              NUMBER;
      x_transfer_to_location    NUMBER;
      x_lot_number              VARCHAR2 (80);
      x_expiration_date         DATE;
      x_transaction_temp_id     NUMBER;
      l_transaction_mode        NUMBER;
      xm_return_status          VARCHAR2 (1);
      xm_msg_count              NUMBER;
      xm_msg_data               VARCHAR2 (1000);
      l_error_message           VARCHAR2 (3000);
      l_msg_index_out           NUMBER;
      x_transaction_header_id   NUMBER;
      l_ser_number              VARCHAR2 (50);
      x                         NUMBER;
      l_return_status           VARCHAR2 (1)                           := NULL;
      l_transaction_temp_id     NUMBER;
----------------------------------------------------------------
   BEGIN
      --
      fnd_global.apps_initialize (user_id           => l_user_id,
                                  resp_id           => l_resp_id,
                                  resp_appl_id      => l_resp_appl_id
                                 );
      --
      a_l_trolin_tbl.DELETE;
      a_l_mold_tbl.DELETE;
      a_x_mmtt_tbl.DELETE;
      a_x_trolin_tbl.DELETE;
      k := 0;
      a_x_return_status := NULL;

      --
      --
      ---- -- debug_insert ('p_move_order_line_id:       ' || p_move_order_line_id);
      ---- -- debug_insert ('p_trx_temp_id:       ' || p_trx_temp_id);
      FOR i IN c_mo_details
      LOOP
         mo_global.set_policy_context ('S', i.org_id);
         inv_globals.set_org_id (i.organization_id);
         mo_global.init ('INV');
         --
         k := NVL (k, 0) + 1;
         /*a_l_trolin_tbl (k).attribute1 := i.attribute1;
         a_l_trolin_tbl (k).attribute10 := i.attribute10;
         a_l_trolin_tbl (k).attribute11 := i.attribute11;
         a_l_trolin_tbl (k).attribute12 := i.attribute12;
         a_l_trolin_tbl (k).attribute13 := i.attribute13;
         a_l_trolin_tbl (k).attribute14 := i.attribute14;
         a_l_trolin_tbl (k).attribute15 := i.attribute15;
         a_l_trolin_tbl (k).attribute2 := i.attribute2;
         a_l_trolin_tbl (k).attribute3 := i.attribute3;
         a_l_trolin_tbl (k).attribute4 := i.attribute4;
         a_l_trolin_tbl (k).attribute5 := i.attribute5;
         a_l_trolin_tbl (k).attribute6 := i.attribute6;
         a_l_trolin_tbl (k).attribute7 := i.attribute7;
         a_l_trolin_tbl (k).attribute8 := i.attribute8;
         a_l_trolin_tbl (k).attribute9 := i.attribute9;
         a_l_trolin_tbl (k).attribute_category := i.attribute_category;
         a_l_trolin_tbl (k).created_by := i.created_by;
         a_l_trolin_tbl (k).creation_date := i.creation_date;
         a_l_trolin_tbl (k).date_required := i.date_required;
         a_l_trolin_tbl (k).from_locator_id := i.from_locator_id;*/

         /*
         a_l_trolin_tbl (k).from_subinventory_id := i.from_subinventory_id;

         a_l_trolin_tbl (k).inventory_item_id := i.inventory_item_id;
         a_l_trolin_tbl (k).last_updated_by := i.last_updated_by;
         a_l_trolin_tbl (k).last_update_date := i.last_update_date;
         a_l_trolin_tbl (k).last_update_login := i.last_update_login;*/
         a_l_trolin_tbl (k).line_id := i.line_id;                         ---
         a_l_trolin_tbl (k).header_id := i.header_id;                     ---

         /*a_l_trolin_tbl (k).line_number := i.line_number;
         a_l_trolin_tbl (k).line_status := i.line_status;
         a_l_trolin_tbl (k).lot_number := i.lot_number;
         a_l_trolin_tbl (k).organization_id := i.organization_id;
         a_l_trolin_tbl (k).program_application_id :=
                                                     i.program_application_id;
         a_l_trolin_tbl (k).program_id := i.program_id;
         a_l_trolin_tbl (k).program_update_date := i.program_update_date;
         a_l_trolin_tbl (k).project_id := i.project_id;
         a_l_trolin_tbl (k).quantity := i.quantity;
         a_l_trolin_tbl (k).quantity_delivered := i.quantity_delivered;
         a_l_trolin_tbl (k).quantity_detailed := i.quantity_detailed;
         a_l_trolin_tbl (k).reason_id := i.reason_id;
         a_l_trolin_tbl (k).REFERENCE := i.REFERENCE;
         a_l_trolin_tbl (k).reference_id := i.reference_id;
         a_l_trolin_tbl (k).reference_type_code := i.reference_type_code;
         a_l_trolin_tbl (k).request_id := i.request_id;
         a_l_trolin_tbl (k).revision := i.revision;
         --a_l_trolin_tbl (k).serial_number_end := i.serial_number_end;
         --a_l_trolin_tbl (k).serial_number_start := i.serial_number_start;
         a_l_trolin_tbl (k).status_date := i.status_date;
         a_l_trolin_tbl (k).task_id := i.task_id;
         a_l_trolin_tbl (k).to_account_id := i.to_account_id;
         a_l_trolin_tbl (k).to_locator_id := i.to_locator_id;
         a_l_trolin_tbl (k).to_subinventory_code := i.to_subinventory_code;
         a_l_trolin_tbl (k).to_subinventory_id := i.to_subinventory_id;
         a_l_trolin_tbl (k).transaction_header_id := i.transaction_header_id;
         a_l_trolin_tbl (k).transaction_type_id := i.transaction_type_id;
         a_l_trolin_tbl (k).txn_source_id := i.txn_source_id;
         a_l_trolin_tbl (k).txn_source_line_id := i.txn_source_line_id;
         a_l_trolin_tbl (k).txn_source_line_detail_id :=
                                                  i.txn_source_line_detail_id;
         a_l_trolin_tbl (k).transaction_source_type_id :=
                                                 i.transaction_source_type_id;
         a_l_trolin_tbl (k).primary_quantity := i.primary_quantity;
         a_l_trolin_tbl (k).to_organization_id := i.to_organization_id;
         a_l_trolin_tbl (k).pick_strategy_id := i.pick_strategy_id;
         a_l_trolin_tbl (k).put_away_strategy_id := i.put_away_strategy_id;
         a_l_trolin_tbl (k).uom_code := i.uom_code;
         a_l_trolin_tbl (k).unit_number := i.unit_number;
         a_l_trolin_tbl (k).ship_to_location_id := i.ship_to_location_id;
         a_l_trolin_tbl (k).from_cost_group_id := i.from_cost_group_id;
         a_l_trolin_tbl (k).to_cost_group_id := i.to_cost_group_id;
         a_l_trolin_tbl (k).lpn_id := i.lpn_id;
         a_l_trolin_tbl (k).to_lpn_id := i.to_lpn_id;
         a_l_trolin_tbl (k).pick_methodology_id := i.pick_methodology_id;
         a_l_trolin_tbl (k).container_item_id := i.container_item_id;
         a_l_trolin_tbl (k).carton_grouping_id := i.carton_grouping_id;
         a_l_trolin_tbl (k).return_status := fnd_api.g_ret_sts_success;
         a_l_trolin_tbl (k).db_flag := fnd_api.g_true;
         a_l_trolin_tbl (k).operation := inv_globals.g_opr_create;
         a_l_trolin_tbl (k).inspection_status := i.inspection_status;
         a_l_trolin_tbl (k).wms_process_flag := i.wms_process_flag;
         a_l_trolin_tbl (k).pick_slip_number := i.pick_slip_number;
         a_l_trolin_tbl (k).pick_slip_date := i.pick_slip_date;
         a_l_trolin_tbl (k).ship_set_id := i.ship_set_id;
         a_l_trolin_tbl (k).ship_model_id := i.ship_model_id;
         a_l_trolin_tbl (k).model_quantity := i.model_quantity;
         a_l_trolin_tbl (k).required_quantity := i.required_quantity;*/
         SELECT mtl_material_transactions_s.NEXTVAL
           INTO l_header_id
           FROM DUAL;

         --
         SELECT move_order_type
           INTO l_move_order_type
           FROM mtl_txn_request_headers
          WHERE header_id = a_l_trolin_tbl (1).header_id;

         --

         --
         IF (i.quantity_detailed IS NULL) OR (i.quantity_detailed = 0)
         THEN
            --
            -- -- debug_insert ('inv_replenish_detail_pub.line_details_pub');
            inv_replenish_detail_pub.line_details_pub
                           (p_line_id                    => a_l_trolin_tbl (k).line_id,
                            x_number_of_rows             => x_number_of_rows,
                            x_detailed_qty               => x_qty_detailed,
                            x_return_status              => x_return_status,
                            x_msg_count                  => x_msg_count,
                            x_msg_data                   => x_msg_data,
                            x_revision                   => l_revision,
                            x_locator_id                 => x_locator_id,
                            x_transfer_to_location       => x_transfer_to_location,
                            x_lot_number                 => x_lot_number,
                            x_expiration_date            => x_expiration_date,
                            x_transaction_temp_id        => x_transaction_temp_id,
                            p_transaction_header_id      => l_header_id,
                            --p_trx_temp_id,
                            p_transaction_mode           => 2,
                            p_move_order_type            => l_move_order_type,
                            p_serial_flag                => fnd_api.g_false,
                            -- NULL,
                            p_auto_pick_confirm          => FALSE,
                            p_commit                     => FALSE
                           );
         ELSE
            x_return_status := 'S';
         END IF;

         --

         ----------------------------------------------------------------------
----------------------------------------------------------------------

         --
         --a_x_return_status := NULL; --fnd_api.g_ret_sts_success;
         --
         a_x_return_status := NULL;
         a_x_msg_data := NULL;
         a_x_msg_count := NULL;
         a_l_transaction_mode := 1;                                       --2;
         --
         /*SELECT transaction_temp_id
           INTO l_transaction_temp_id
           FROM mtl_material_transactions_temp
          WHERE move_order_line_id = p_move_order_line_id;

         -- -- debug_insert ('l_transaction_temp_id:      ' || l_transaction_temp_id);
         SELECT COUNT (1)
           INTO l_transaction_temp_id
           FROM mtl_transaction_lots_temp
          WHERE transaction_temp_id = l_transaction_temp_id;

         -- -- debug_insert (   'l_transaction_temp_id Count:      '
                      -- || l_transaction_temp_id
                      --);*/
         /*SELECT COUNT (1)
           INTO l_transaction_temp_id
           FROM mtl_available_inventory_temp;

         -- debug_insert ('l_transaction_temp_id:  ' || l_transaction_temp_id);*/
         inv_pick_wave_pick_confirm_pub.pick_confirm
                                  (p_api_version_number      => a_l_api_version,
                                   p_init_msg_list           => fnd_api.g_true,
                                   --a_l_init_msg_list,
                                   p_commit                  => fnd_api.g_false,
                                   --a_l_commit,
                                   x_return_status           => a_x_return_status,
                                   x_msg_count               => a_x_msg_count,
                                   x_msg_data                => a_x_msg_data,
                                   p_move_order_type         => l_move_order_type,
                                   --i.move_order_type,
                                   p_transaction_mode        => a_l_transaction_mode,
                                   p_trolin_tbl              => a_l_trolin_tbl,
                                   p_mold_tbl                => a_l_mold_tbl,
                                   x_mmtt_tbl                => a_x_mmtt_tbl,
                                   x_trolin_tbl              => a_x_trolin_tbl,
                                   p_transaction_date        => p_transaction_date
                                                                           --a_l_transaction_date
                                  -- l_transaction_date
                                  );

         ---- -- debug_insert ('a_x_return_status:       ' || a_x_return_status);
         ---- -- debug_insert ('a_x_msg_count:       ' || a_x_msg_count);
         IF (a_x_return_status <> fnd_api.g_ret_sts_success)
         THEN
            /*UPDATE mtl_transaction_lots_temp
               SET lot_number = lot_number || '****'
             WHERE transaction_temp_id = p_trx_temp_id;

            UPDATE mtl_transaction_lots_temp
               SET lot_number = SUBSTR (lot_number, '****', '')
             WHERE transaction_temp_id = p_trx_temp_id;

            COMMIT;
            inv_pick_wave_pick_confirm_pub.pick_confirm
                                  (p_api_version_number      => a_l_api_version,
                                   p_init_msg_list           => fnd_api.g_true,
                                   --a_l_init_msg_list,
                                   p_commit                  => fnd_api.g_false,
                                   --a_l_commit,
                                   x_return_status           => a_x_return_status,
                                   x_msg_count               => a_x_msg_count,
                                   x_msg_data                => a_x_msg_data,
                                   p_move_order_type         => l_move_order_type,
                                   --i.move_order_type,
                                   p_transaction_mode        => a_l_transaction_mode,
                                   p_trolin_tbl              => a_l_trolin_tbl,
                                   p_mold_tbl                => a_l_mold_tbl,
                                   x_mmtt_tbl                => a_x_mmtt_tbl,
                                   x_trolin_tbl              => a_x_trolin_tbl,
                                   p_transaction_date        => a_l_transaction_date
                                  -- l_transaction_date
                                  );

            IF (a_x_return_status <> fnd_api.g_ret_sts_success)
            THEN*/
            IF a_x_msg_count > 0
            THEN
               --
               FOR i IN 1 .. a_x_msg_count
               LOOP
                  fnd_msg_pub.get (p_msg_index          => i,
                                   p_encoded            => 'F',
                                   p_data               => a_x_msg_data,
                                   p_msg_index_out      => l_out_index
                                  );

                  IF p_return_message IS NULL
                  THEN
                     p_return_message := a_x_msg_data;
                  ELSE
                     p_return_message :=
                                  p_return_message || CHR (10)
                                  || a_x_msg_data;
                  END IF;
               END LOOP;

               p_return_status := 'E';
            ELSE
               p_return_status := 'S';
            END IF;

            --END IF;
            /*DELETE      mtl_transaction_lots_temp
                  WHERE transaction_temp_id = p_trx_temp_id;

            DELETE      mtl_material_transactions_temp
                  WHERE transaction_temp_id = p_trx_temp_id;*/

            --transaction_temp_id=p_trx_temp_id;
            COMMIT;
         --
         END IF;

         --
         IF (a_x_return_status = fnd_api.g_ret_sts_success)
         THEN
            p_return_status := 'S';
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF p_return_message IS NULL
         THEN
            p_return_message :=
                  'Move Order Transaction Block Failed     '
               || SUBSTR (SQLERRM, 1, 100);
         ELSE
            p_return_message :=
                  p_return_message
               || CHR (10)
               || 'Move Order Transaction Block Failed     '
               || SUBSTR (SQLERRM, 1, 100);
         END IF;
   END transact_move_order;

   PROCEDURE ship_confirm (
      p_delivery_id      IN       NUMBER,
      p_return_status    OUT      VARCHAR2,
      p_return_message   OUT      VARCHAR2
   )
   IS
      p_api_version_number        NUMBER                               := 1.0;
      init_msg_list               VARCHAR2 (200);
      x_msg_details               VARCHAR2 (3000);
      x_msg_summary               VARCHAR2 (3000);
      x_return_status             VARCHAR2 (3);
      x_msg_count                 NUMBER;
      x_msg_data                  VARCHAR2 (3000);
      p_validation_level          NUMBER;
      v_errbuf                    VARCHAR2 (2000);
      v_retcode                   VARCHAR2 (20);
      v_released_status           wsh_delivery_details.released_status%TYPE;
      v_inv_interfaced_flag       wsh_delivery_details.inv_interfaced_flag%TYPE;
      v_oe_interfaced_flag        wsh_delivery_details.oe_interfaced_flag%TYPE;
      v_source_code               wsh_delivery_details.source_code%TYPE;
      v_pending_interface_flag    wsh_trip_stops.pending_interface_flag%TYPE;
-- Parameters for WSH_DELIVERIES_PUB
      p_delivery_name             VARCHAR2 (30);
      p_action_code               VARCHAR2 (15);
      p_asg_trip_id               NUMBER;
      p_asg_trip_name             VARCHAR2 (30);
      p_asg_pickup_stop_id        NUMBER;
      p_asg_pickup_loc_id         NUMBER;
      p_asg_pickup_loc_code       VARCHAR2 (30);
      p_asg_pickup_arr_date       DATE;
      p_asg_pickup_dep_date       DATE;
      p_asg_dropoff_stop_id       NUMBER;
      p_asg_dropoff_loc_id        NUMBER;
      p_asg_dropoff_loc_code      VARCHAR2 (30);
      p_asg_dropoff_arr_date      DATE;
      p_asg_dropoff_dep_date      DATE;
      p_sc_action_flag            VARCHAR2 (10);
      p_sc_intransit_flag         VARCHAR2 (10);
      p_sc_close_trip_flag        VARCHAR2 (10);
      p_sc_create_bol_flag        VARCHAR2 (10);
      p_sc_stage_del_flag         VARCHAR2 (10);
      p_sc_trip_ship_method       VARCHAR2 (30);
      p_sc_actual_dep_date        VARCHAR2 (30);
      p_sc_report_set_id          NUMBER;
      p_sc_report_set_name        VARCHAR2 (60);
      p_sc_defer_interface_flag   VARCHAR2 (60);
      p_sc_send_945_flag          VARCHAR2 (60);
      p_sc_rule_id                NUMBER;
      p_sc_rule_name              VARCHAR2 (60);
      p_wv_override_flag          VARCHAR2 (10);
      p_asg_pickup_stop_seq       NUMBER;
      p_asg_dropoff_stop_seq      NUMBER;
      x_trip_id                   VARCHAR2 (30);
      x_trip_name                 VARCHAR2 (30);
      fail_api                    EXCEPTION;
      x_debug_file                VARCHAR2 (100);
      l_ship_method_code          VARCHAR2 (100);
      l_user_id                   NUMBER;
      l_resp_id                   NUMBER;
      l_appl_id                   NUMBER;
      l_msg_data                  VARCHAR2 (1000)                     := NULL;
      l_msg_index_out             NUMBER;
      l_to_stops                  NUMBER;
      l_excise_invoice_no         VARCHAR2 (200)                      := NULL;
      ---
      l_request_id10              NUMBER;
      l_wait                      BOOLEAN                             := TRUE;
      l_phase                     VARCHAR2 (30);
      l_status                    VARCHAR2 (30);
      l_dev_phase                 VARCHAR2 (30);
      l_dev_status                VARCHAR2 (30);
      l_complete                  BOOLEAN;
      l_message                   VARCHAR2 (1000);
      l_wait_time                 NUMBER                                 := 5;
      l_sc_rule_name              VARCHAR2 (1000);

      --

      --
      CURSOR c_ord_details (c_delivery_id NUMBER)
      IS
         SELECT DISTINCT det.org_id, del.delivery_id,
                         det.source_header_number sales_order
                    /*det.source_line_number, det.source_header_id,
                    det.source_line_id, det.source_header_type_name,
                    det.inventory_item_id, det.requested_quantity,
                    (SELECT concatenated_segments
                       FROM mtl_system_items_kfv
                      WHERE inventory_item_id =
                                      det.inventory_item_id
                        AND organization_id = det.organization_id)
                                                           ordered_item,
                    det.organization_id, det.src_requested_quantity,
                    det.shipped_quantity,
                    del.status_code delivery_status_code,
                    det.released_status pick_release_status,
                    det.oe_interfaced_flag, det.inv_interfaced_flag*/
         FROM            wsh_delivery_details det,
                         wsh_delivery_assignments asn,
                         wsh_new_deliveries del
                   WHERE 1 = 1
                     AND det.delivery_detail_id = asn.delivery_detail_id
                     AND asn.delivery_id = del.delivery_id(+)
                     ---AND det.delivery_detail_id = c_delivery_detail_id;
                     AND del.delivery_id = c_delivery_id
                     AND ROWNUM = 1;
   BEGIN
      --debug_insert ('p_delivery_id:         ' || p_delivery_id);
      FOR i IN c_ord_details (p_delivery_id)
      LOOP
         mo_global.set_policy_context ('S', i.org_id);
         mo_global.init ('ONT');

         --debug_insert ('i.org_id:         ' || i.org_id);
         BEGIN
            SELECT NVL (shipping_method_code, 'Road Shipment')
              --'DBL-Rail-Standard')
            INTO   l_ship_method_code
              FROM oe_order_headers_all
             WHERE order_number = i.sales_order AND org_id = i.org_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_ship_method_code := '000001_DBL_T_LTL';
         --l_ship_method_code := '000001_DBLCLFC_T_LTL';
         END;

         --debug_insert ('l_ship_method_code:         ' || l_ship_method_code);
         BEGIN
            SELECT MAX (lines.delivery_date)
              INTO p_sc_actual_dep_date
              FROM xxdbl_omshipping_line lines
             WHERE 1 = 1
               AND lines.delivery_id = p_delivery_id
               AND lines.delivery_id IS NOT NULL;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_sc_actual_dep_date := SYSDATE;
         END;

         -- Added By Manas 10-Dec-2019 Starts
         p_sc_actual_dep_date := SYSDATE;
         -- Added By Manas 10-Dec-2019 Ends

         /*debug_insert ('p_sc_actual_dep_date:         '
                       || p_sc_actual_dep_date
                      );*/
         p_action_code := 'CONFIRM';       -- The action code for ship confirm
         p_sc_action_flag := 'S';                    -- Ship entered quantity.
         --p_sc_intransit_flag := 'Y';
--In transit flag is set to 'Y' closes the pickup stop and sets the delivery in transit.
         p_sc_close_trip_flag := 'Y';     -- Close the trip after ship confirm
         p_sc_trip_ship_method := l_ship_method_code;  -- The ship method code
         p_sc_defer_interface_flag := 'N';
         p_sc_stage_del_flag := 'Y';
         p_sc_create_bol_flag := 'N';
         p_wv_override_flag := 'N';
         p_delivery_name := TO_CHAR (i.delivery_id);

         IF i.org_id = 125
         THEN
            l_sc_rule_name := 'DBL Thread';                       --'Thread';
         ELSIF i.org_id = 126
         THEN
            l_sc_rule_name := 'DBL CERAMIC';
         END IF;

         --debug_insert ('l_sc_rule_name:         ' || l_sc_rule_name);
         --
         wsh_deliveries_pub.delivery_action
                      (p_api_version_number           => 1.0,
                       p_init_msg_list                => init_msg_list,
                       x_return_status                => x_return_status,
                       x_msg_count                    => x_msg_count,
                       x_msg_data                     => x_msg_data,
                       p_action_code                  => p_action_code,
                       p_delivery_id                  => i.delivery_id,
                       p_delivery_name                => p_delivery_name,
                       p_asg_trip_id                  => p_asg_trip_id,
                       p_asg_trip_name                => p_asg_trip_name,
                       p_asg_pickup_stop_id           => p_asg_pickup_stop_id,
                       p_asg_pickup_loc_id            => p_asg_pickup_loc_id,
                       p_asg_pickup_stop_seq          => p_asg_pickup_stop_seq,
                       p_asg_pickup_loc_code          => p_asg_pickup_loc_code,
                       p_asg_pickup_arr_date          => p_asg_pickup_arr_date,
                       p_asg_pickup_dep_date          => p_asg_pickup_dep_date,
                       p_asg_dropoff_stop_id          => p_asg_dropoff_stop_id,
                       p_asg_dropoff_loc_id           => p_asg_dropoff_loc_id,
                       p_asg_dropoff_stop_seq         => p_asg_dropoff_stop_seq,
                       p_asg_dropoff_loc_code         => p_asg_dropoff_loc_code,
                       p_asg_dropoff_arr_date         => p_asg_dropoff_arr_date,
                       p_asg_dropoff_dep_date         => p_asg_dropoff_dep_date,
                       p_sc_action_flag               => p_sc_action_flag,
                       p_sc_intransit_flag            => p_sc_intransit_flag,
                       p_sc_close_trip_flag           => p_sc_close_trip_flag,
                       p_sc_create_bol_flag           => p_sc_create_bol_flag,
                       p_sc_stage_del_flag            => p_sc_stage_del_flag,
                       p_sc_trip_ship_method          => p_sc_trip_ship_method,
                       p_sc_actual_dep_date           => p_sc_actual_dep_date,
                       p_sc_report_set_id             => p_sc_report_set_id,
                       p_sc_report_set_name           => p_sc_report_set_name,
                       p_sc_defer_interface_flag      => p_sc_defer_interface_flag,
                       p_sc_send_945_flag             => p_sc_send_945_flag,
                       p_sc_rule_id                   => p_sc_rule_id,
                       p_sc_rule_name                 => l_sc_rule_name,
                                                              --'DBL CERAMIC',
                       --p_sc_rule_name,
                       p_wv_override_flag             => p_wv_override_flag,
                       x_trip_id                      => x_trip_id,
                       x_trip_name                    => x_trip_name
                      );

         --debug_insert ('x_return_status:         ' || x_return_status);

         --

         --
--         write_log ('x_return_status ' || x_return_status, p_enable);
--         write_log ('x_msg_count ' || x_msg_count, p_enable);
--         write_log ('x_msg_data ' || x_msg_data, p_enable);

         --
         IF x_return_status NOT IN ('S', 'W')
         THEN
            --debug_insert ('x_msg_count:         ' || x_msg_count);

            --
            FOR i IN 1 .. x_msg_count
            LOOP
               oe_msg_pub.get (p_msg_index          => i,
                               p_encoded            => fnd_api.g_false,
                               p_data               => l_msg_data,
                               p_msg_index_out      => l_msg_index_out
                              );

               --debug_insert ('l_msg_data:         ' || l_msg_data);
               IF p_return_message IS NULL
               THEN
                  p_return_message := l_msg_data;
               ELSE
                  p_return_message :=
                                    p_return_message || CHR (10)
                                    || l_msg_data;
               END IF;
            END LOOP;

            p_return_status := 'E';
-----------------------------------------------
--RAISE fail_api;
-----------------------------------------------
         ELSE
            p_return_status := 'S';
         --
         /*SELECT wdd.source_code, wdd.released_status,
                wdd.inv_interfaced_flag, wdd.oe_interfaced_flag,
                wts.pending_interface_flag
           INTO v_source_code, v_released_status,
                v_inv_interfaced_flag, v_oe_interfaced_flag,
                v_pending_interface_flag
           FROM wsh_trips wtr,
                wsh_trip_stops wts,
                wsh_delivery_legs wlg,
                wsh_new_deliveries wnd,
                wsh_delivery_assignments wda,
                wsh_delivery_details wdd
          WHERE wtr.trip_id = wts.trip_id
            AND wts.stop_id = wlg.pick_up_stop_id
            AND wts.pending_interface_flag = 'Y'
            AND wdd.inv_interfaced_flag <> 'Y'
            AND wlg.delivery_id = wnd.delivery_id
            AND wnd.delivery_id = wda.delivery_id
            AND wda.delivery_detail_id = wdd.delivery_detail_id
            AND wnd.delivery_id = p_delivery_name
            AND wdd.source_line_id = i.source_line_id
            AND ROWNUM < 2;

         IF (    v_source_code = 'OE'
             AND v_released_status = 'C'
             AND v_inv_interfaced_flag <> 'Y'
             AND v_oe_interfaced_flag <> 'Y'
             AND v_pending_interface_flag = 'Y'
            )
         THEN
            l_request_id10 := NULL;
            l_wait := TRUE;
            l_phase := NULL;
            l_status := NULL;
            l_dev_phase := NULL;
            l_dev_status := NULL;
            l_complete := NULL;
            l_message := NULL;
            l_wait_time := 5;
         --
         ELSE
            p_return_status := 'E';

            IF p_return_message IS NULL
            THEN
               p_return_message :=
                  'Ship confirm Error ~ The Delivery has not Shipped Properly ';
            ELSE
               p_return_message :=
                     p_return_message
                  || CHR (10)
                  || 'Ship confirm Error ~ The Delivery has not Shipped Properly ';
            END IF;
         END IF;*/
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF p_return_message IS NULL
         THEN
            p_return_message :=
                              'Ship Confirm Block Failed ' || SUBSTR (1, 100);
         ELSE
            p_return_message :=
                  p_return_message
               || CHR (10)
               || 'Ship Confirm Block Failed '
               || SUBSTR (1, 100);
         END IF;
   END ship_confirm;

   PROCEDURE pick_release_pick_rule (
      p_delivery_id      IN       NUMBER,
      p_return_status    OUT      VARCHAR2,
      p_return_message   OUT      VARCHAR2
   )
   IS
      l_wsh_picking_rules   wsh_picking_rules%ROWTYPE;
      -- New
      l_return_status       VARCHAR2 (1);
      l_msg_count           NUMBER (15);
      l_msg_data            VARCHAR2 (2000);
      l_count               NUMBER (15);
      l_msg_data_out        VARCHAR2 (2000);
      l_mesg                VARCHAR2 (2000);
      p_count               NUMBER (15);
      p_new_batch_id        NUMBER;
      l_rule_id             NUMBER;
      l_rule_name           VARCHAR2 (2000);
      l_batch_prefix        VARCHAR2 (2000);
      l_batch_info_rec      wsh_picking_batches_pub.batch_info_rec;
      l_request_id          NUMBER;
      v_context             VARCHAR2 (100);
      l_customer_id         NUMBER;
      l_organization_id     NUMBER;
   BEGIN
      BEGIN
         SELECT customer_id, organization_id
           INTO l_customer_id, l_organization_id
           FROM wsh_new_deliveries
          WHERE delivery_id = p_delivery_id;

         BEGIN
            SELECT *
              INTO l_wsh_picking_rules
              FROM wsh_picking_rules
             WHERE organization_id = l_organization_id;

            l_batch_info_rec.backorders_only_flag :=
                                      l_wsh_picking_rules.backorders_only_flag;
            --'E';
            l_batch_info_rec.existing_rsvs_only_flag :=
                                   l_wsh_picking_rules.existing_rsvs_only_flag;
            --'N';
            l_batch_info_rec.customer_id := l_customer_id;
            l_batch_info_rec.delivery_id := p_delivery_id;
            l_batch_info_rec.from_scheduled_ship_date := NULL;
            l_batch_info_rec.organization_id :=
                                           l_wsh_picking_rules.organization_id;
            --92;
            l_batch_info_rec.include_planned_lines :=
                                     l_wsh_picking_rules.include_planned_lines;
            --'N';
            l_batch_info_rec.autocreate_delivery_flag :=
                                  l_wsh_picking_rules.autocreate_delivery_flag;
            -- 'Y';
            l_batch_info_rec.autodetail_pr_flag :=
                                        l_wsh_picking_rules.autodetail_pr_flag;
            -- 'Y';
            l_batch_info_rec.allocation_method :=
                                         l_wsh_picking_rules.allocation_method;
            --'I';
            l_batch_info_rec.pick_from_locator_id := NULL;
            l_batch_info_rec.auto_pick_confirm_flag :=
                                    l_wsh_picking_rules.auto_pick_confirm_flag;
            --'Y';
            l_batch_info_rec.autopack_flag :=
                                             l_wsh_picking_rules.autopack_flag;
            --'Y';
            l_rule_id := l_wsh_picking_rules.picking_rule_id;
            l_rule_name := l_wsh_picking_rules.NAME;
            l_batch_prefix := NULL;
            wsh_picking_batches_pub.create_batch
                                          (p_api_version        => 1.0,
                                           p_init_msg_list      => fnd_api.g_true,
                                           p_commit             => fnd_api.g_true,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_rule_id            => l_rule_id,
                                           p_rule_name          => l_rule_name,
                                           p_batch_rec          => l_batch_info_rec,
                                           p_batch_prefix       => l_batch_prefix,
                                           x_batch_id           => p_new_batch_id
                                          );

            IF l_return_status = 'S'
            THEN
               p_return_status := 'S';
               -- Release the batch Created Above
               wsh_picking_batches_pub.release_batch
                                         (p_api_version        => 1.0,
                                          p_init_msg_list      => fnd_api.g_true,
                                          p_commit             => fnd_api.g_true,
                                          x_return_status      => l_return_status,
                                          x_msg_count          => l_msg_count,
                                          x_msg_data           => l_msg_data,
                                          p_batch_id           => p_new_batch_id,
                                          p_batch_name         => NULL,
                                          p_log_level          => 1,
                                          p_release_mode       => 'ONLINE',
                                          -- (ONLINE or CONCURRENT)
                                          x_request_id         => l_request_id
                                         );

               IF l_return_status = 'S'
               THEN
                  p_return_status := 'S';

                  UPDATE xxdbl_omshipping_line
                     SET attribute6 = 'PICK_RELEASED'
                   WHERE delivery_id = p_delivery_id;

                  COMMIT;
               ELSE
                  p_return_status := 'E';
                  p_return_message :=
                            'wsh_picking_batches_pub.release_batch Error:   ';

                  IF l_msg_count = 1
                  THEN
                     --DBMS_OUTPUT.put_line ('l_msg_data ' || l_msg_data);
                     p_return_message :=
                                    p_return_message || CHR (10)
                                    || l_msg_data;
                  ELSIF l_msg_count > 1
                  THEN
                     LOOP
                        p_count := p_count + 1;
                        l_msg_data :=
                           fnd_msg_pub.get (fnd_msg_pub.g_next,
                                            fnd_api.g_false
                                           );

                        IF l_msg_data IS NULL
                        THEN
                           EXIT;
                        END IF;

                        p_return_message :=
                              p_return_message
                           || CHR (10)
                           || p_count
                           || '---'
                           || l_msg_data;
                     END LOOP;
                  END IF;
               END IF;
            ELSE
               p_return_status := 'E';
               p_return_message :=
                             'wsh_picking_batches_pub.create_batch Error:   ';

               IF l_msg_count = 1
               THEN
                  p_return_message :=
                                    p_return_message || CHR (10)
                                    || l_msg_data;
               ELSIF l_msg_count > 1
               THEN
                  LOOP
                     p_count := p_count + 1;
                     l_msg_data :=
                        fnd_msg_pub.get (fnd_msg_pub.g_next, fnd_api.g_false);

                     IF l_msg_data IS NULL
                     THEN
                        EXIT;
                     END IF;

                     p_return_message :=
                           p_return_message
                        || CHR (10)
                        || p_count
                        || '---'
                        || l_msg_data;
                  END LOOP;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_return_status := 'E';
               p_return_message := 'Unable to find Picking Rules Information';
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_return_status := 'E';
            p_return_message := 'Unable to find Delivery Information';
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return_status := 'E';
         p_return_message :=
            'Unable to do pick_release_pick_rule '
            || SUBSTR (SQLERRM, 1, 100);
   END pick_release_pick_rule;

   PROCEDURE pick_ship_process (
      p_transaction_hdr_id   IN       NUMBER,
      x_message              OUT      VARCHAR2
   )
   IS
      l_delivery_detail_id            NUMBER                          := NULL;
      l_record_count                  NUMBER                             := 1;
      l_org_id                        NUMBER                             := 0;
      e_so_mult_line                  EXCEPTION;
      e_so_no_data                    EXCEPTION;
      e_so_others                     EXCEPTION;
      e_split_mult_line               EXCEPTION;
      e_split_no_data                 EXCEPTION;
      e_split_others                  EXCEPTION;
      e_split_qty_more                EXCEPTION;
      e_split_error                   EXCEPTION;
      e_auto_del                      EXCEPTION;
      e_pick_batch                    EXCEPTION;
      e_batch_release                 EXCEPTION;
      e_hold_error                    EXCEPTION;
      l_so_parent_line_id             NUMBER                             := 0;
      l_so_header_id                  NUMBER                             := 0;
      l_ordered_quantity              NUMBER                             := 0;
      l_parent_det_id                 NUMBER                             := 0;
      l_new_detail_id                 NUMBER                             := 0;
      l_return_status                 VARCHAR2 (30)                   := NULL;
--      l_ship_qty                 NUMBER                           := p_net_wt;
      p_line_rows                     wsh_util_core.id_tab_type;
      x_del_rows                      wsh_util_core.id_tab_type;
      x_msg_count                     NUMBER                             := 0;
      x_msg_data                      VARCHAR2 (32000)                := NULL;
      x_return_status                 VARCHAR2 (10)                   := NULL;
      x_msg_details                   VARCHAR2 (32000)                := NULL;
      x_msg_summary                   VARCHAR2 (3000)                 := NULL;
      p_delivery_id                   NUMBER                             := 0;
      p_delivery_name                 VARCHAR2 (30)                   := NULL;
      x_trip_id                       VARCHAR2 (30)                   := NULL;
      x_trip_name                     VARCHAR2 (30)                   := NULL;
      x_out_index                     NUMBER                             := 0;
      l_batch_info_rec                wsh_picking_batches_pub.batch_info_rec;
      l_batch_id                      NUMBER                             := 0;
      l_request_id                    NUMBER                             := 0;
      l_organization_id               NUMBER                             := 0;
      l_orig_flag                     NUMBER                             := 0;
      l_ship_confirm_rule             VARCHAR2 (240)
                                                  := 'SCBL Bulk Ship Confirm';
      l_line_tbl                      oe_order_pub.line_tbl_type;
      l_header_rec                    oe_order_pub.header_rec_type;
      l_line_tbl_index                NUMBER                             := 0;
      l_random_number                 NUMBER             := DBMS_RANDOM.VALUE;
      l_action_request_tbl            oe_order_pub.request_tbl_type;
      x_header_val_rec                oe_order_pub.header_val_rec_type;
      x_header_adj_tbl                oe_order_pub.header_adj_tbl_type;
      x_header_adj_val_tbl            oe_order_pub.header_adj_val_tbl_type;
      x_header_price_att_tbl          oe_order_pub.header_price_att_tbl_type;
      x_header_adj_att_tbl            oe_order_pub.header_adj_att_tbl_type;
      x_header_adj_assoc_tbl          oe_order_pub.header_adj_assoc_tbl_type;
      x_header_scredit_tbl            oe_order_pub.header_scredit_tbl_type;
      x_header_scredit_val_tbl        oe_order_pub.header_scredit_val_tbl_type;
      x_line_val_tbl                  oe_order_pub.line_val_tbl_type;
      x_line_adj_tbl                  oe_order_pub.line_adj_tbl_type;
      x_line_adj_val_tbl              oe_order_pub.line_adj_val_tbl_type;
      x_line_price_att_tbl            oe_order_pub.line_price_att_tbl_type;
      x_line_adj_att_tbl              oe_order_pub.line_adj_att_tbl_type;
      x_line_adj_assoc_tbl            oe_order_pub.line_adj_assoc_tbl_type;
      x_line_scredit_tbl              oe_order_pub.line_scredit_tbl_type;
      x_line_scredit_val_tbl          oe_order_pub.line_scredit_val_tbl_type;
      x_lot_serial_tbl                oe_order_pub.lot_serial_tbl_type;
      x_lot_serial_val_tbl            oe_order_pub.lot_serial_val_tbl_type;
      x_action_request_tbl            oe_order_pub.request_tbl_type;
      x_header_rec                    oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      x_line_tbl                      oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
      p_line_tbl                      oe_order_pub.line_tbl_type
                                              := oe_order_pub.g_miss_line_tbl;
      -- added on 16aug PwC
      p_action_request_tbl            oe_order_pub.request_tbl_type;
      -- added on 16aug PwC
      p_header_rec                    oe_order_pub.header_rec_type
                                            := oe_order_pub.g_miss_header_rec;
      -- added on 16aug PwC
      l_so_child_line_id              NUMBER                             := 0;
      l_child_det_id                  NUMBER;
      l_user_id                       NUMBER;
      l_resp_id                       NUMBER;
      l_resp_appl_id                  NUMBER;
      l_appl_short_name               VARCHAR2 (100);
      lv_frt_term_code                VARCHAR2 (100);
      ln_line_id                      NUMBER;
      l_hold_order_flag               VARCHAR2 (10)                   := NULL;
      l_split_return_status           VARCHAR2 (10)                   := NULL;
      x_split_msg_data                VARCHAR2 (32000)                := NULL;
      x_split_msg_count               NUMBER                             := 0;
      l_auto_return_status            VARCHAR2 (10)                   := NULL;
      x_auto_msg_count                NUMBER                             := 0;
      x_auto_msg_data                 VARCHAR2 (32000)                := NULL;
      x_auto_out_index                NUMBER                             := 0;
      l_batch_return_status           VARCHAR2 (10)                   := NULL;
      x_batch_msg_count               NUMBER                             := 0;
      x_batch_msg_data                VARCHAR2 (32000)                := NULL;
      x_batch_out_index               NUMBER                             := 0;
      l_rel_return_status             VARCHAR2 (10)                   := NULL;
      x_rel_msg_count                 NUMBER                             := 0;
      x_rel_msg_data                  VARCHAR2 (32000)                := NULL;
      x_rel_out_index                 NUMBER                             := 0;
      -- Standard Parameters.
      p_api_version                   NUMBER;
      p_init_msg_list                 VARCHAR2 (30);
      p_commit                        VARCHAR2 (30);
      --Parameters for WSH_DELIVERIES_PUB.Delivery_Action.
      p_action_code                   VARCHAR2 (15);
      pn_delivery_id                  NUMBER;
      p_delivery_name1                VARCHAR2 (30);
      p_asg_trip_id                   NUMBER;
      p_asg_trip_name                 VARCHAR2 (30);
      p_asg_pickup_stop_id            NUMBER;
      p_asg_pickup_loc_id             NUMBER;
      p_asg_pickup_loc_code           VARCHAR2 (30);
      p_asg_pickup_arr_date           DATE;
      p_asg_pickup_dep_date           DATE;
      p_asg_dropoff_stop_id           NUMBER;
      p_asg_dropoff_loc_id            NUMBER;
      p_asg_dropoff_loc_code          VARCHAR2 (30);
      p_asg_dropoff_arr_date          DATE;
      p_asg_dropoff_dep_date          DATE;
      p_sc_action_flag                VARCHAR2 (10);
      p_sc_close_trip_flag            VARCHAR2 (10);
      p_sc_create_bol_flag            VARCHAR2 (10);
      p_sc_stage_del_flag             VARCHAR2 (10);
      p_sc_trip_ship_method           VARCHAR2 (30);
      p_sc_actual_dep_date            VARCHAR2 (30);
      p_sc_report_set_id              NUMBER;
      p_sc_report_set_name            VARCHAR2 (60);
      p_wv_override_flag              VARCHAR2 (10);
      -- outparameters
      lx1_return_status               VARCHAR2 (10);
      lx1_msg_count                   NUMBER;
      lx1_msg_data                    VARCHAR2 (2000);
      lx1_msg_details                 VARCHAR2 (3000);
      lx1_msg_summary                 VARCHAR2 (3000);
      -- Handle exceptions
      vapierrorexception              EXCEPTION;
      ln1_user_id                     NUMBER;
      ln1_resp_id                     NUMBER;
      ln1_appl_id                     NUMBER;
      l1_msg                          VARCHAR2 (3000);
      l1_error_flag                   VARCHAR2 (10);
      l_move_order_id                 mtl_txn_request_headers.header_id%TYPE
                                                                      := NULL;
      l_move_order_number             mtl_txn_request_headers.request_number%TYPE;
      l_move_order_line_id            mtl_txn_request_lines.line_id%TYPE
                                                                      := NULL;
      l_move_order_quantity           NUMBER                          := NULL;
      l_inv_period_status             org_acct_periods.open_flag%TYPE := NULL;
      l_acct_period_id                org_acct_periods.acct_period_id%TYPE
                                                                      := NULL;
      l_rowid                         ROWID                           := NULL;
      l_new_transaction_temp_id       NUMBER                          := NULL;
      l_new_transaction_temp_hdr_id   NUMBER                          := NULL;
      l_return_status_move_order      VARCHAR2 (1);
      l_return_message_move_order     VARCHAR2 (4000);
      l_return_status_mv_tran         VARCHAR2 (1);
      l_return_message_mv_tran        VARCHAR2 (4000);
      l_delivery_pending              VARCHAR2 (1)                     := 'N';
      l_pick_release_ret_message      VARCHAR2 (4000);
      l_move_order_status_count       NUMBER                             := 0;
      l_delivery_id                   NUMBER                            := -1;
      l_date_shipped                  DATE                         := SYSDATE;
      l_return_status_sc              VARCHAR2 (1);
      l_return_message_sc             VARCHAR2 (4000);
      l_rsv                           inv_reservation_global.mtl_reservation_rec_type;
      l_dummy_sn                      inv_reservation_global.serial_number_tbl_type;
      x_rsv_id                        NUMBER;
      x_dummy_sn                      inv_reservation_global.serial_number_tbl_type;
      x_qty                           NUMBER;
      lx_status                       VARCHAR2 (1);
      lx_msg_count                    NUMBER;
      lx_msg_data                     VARCHAR2 (240);
      lv_rsv                          inv_reservation_global.mtl_reservation_rec_type;
      lv_dummy_sn                     inv_reservation_global.serial_number_tbl_type;
      l_sales_order_id                NUMBER;
      lc_wsh_exceptions_rec           wsh_exceptions_pub.xc_action_rec_type;
      lx_msg_count2                   NUMBER;
      lx_msg_data2                    VARCHAR2 (2000);
      lx_return_status2               VARCHAR2 (200);
      l_message2                      VARCHAR2 (2000);
      l_msg_index_out2                NUMBER;
      l_delivery_date                 DATE;
      l_status_name                   wsh_new_deliveries_v.status_name%TYPE
                                                                      := NULL;
      l_released_status               wsh_dlvy_deliverables_v.released_status%TYPE
                                                                       := 'O';

      CURSOR exceptions_cur (p_delivery_detail_id IN NUMBER)
      IS
         SELECT *
           FROM apps.wsh_exceptions
          WHERE exception_name = 'WSH_CHANGE_SCHED_DATE'
            AND status = 'OPEN'
            AND delivery_detail_id = p_delivery_detail_id;
   BEGIN
      FOR rec_headers IN
         (SELECT   line.ship_to_warehouse, line.warehouse_id,
                   line.delivery_challan_number, xxth.delivery_mode_code,
                   xxth.vehicle_no, xxth.transporter_id,
                   xxth.transporter_name, xxth.transporter_site_id,
                   xxth.transporter_site_name, xxth.transporter_no,
                   xxth.delivery_person, xxth.driver_name
              FROM xxdbl_transpoter_headers xxth,
                   xxdbl_transpoter_line xxtl,
                   xxdbl_omshipping_line line
             WHERE 1 = 1
               AND xxth.transpoter_header_id = xxtl.transpoter_header_id
               AND xxth.transpoter_header_id = p_transaction_hdr_id
               AND xxtl.delivery_challan_number = line.delivery_challan_number
               AND line.omshipping_line_status NOT IN
                                       ('CANCELLED') --('CLOSED', 'CANCELLED')
          GROUP BY line.ship_to_warehouse,
                   line.warehouse_id,
                   line.delivery_challan_number,
                   xxth.delivery_mode_code,
                   xxth.vehicle_no,
                   xxth.transporter_id,
                   xxth.transporter_name,
                   xxth.transporter_site_id,
                   xxth.transporter_site_name,
                   xxth.transporter_no,
                   xxth.delivery_person,
                   xxth.driver_name)
      LOOP
         FOR rec_lines IN
            (SELECT lines.omshipping_header_id, lines.omshipping_line_id,
                    lines.org_id, lines.customer_number, lines.customer_name,
                    lines.customer_id, lines.order_number, lines.order_id,
                    lines.ship_to_warehouse, lines.warehouse_id,
                    lines.order_line_no, lines.order_line_id,
                    lines.item_code, lines.item_desc, lines.item_id,
                    lines.grade, lines.primary_quantity,
                    lines.secondary_quantity, lines.primary_onhand_quantity,
                    lines.secondary_onhand_quantity,
                    lines.schedule_ship_date, lines.shipment_priority_code,
                    lines.shipment_priority_meaning, lines.picking_qty_crt,
                    lines.picking_qty_sft, lines.omshipping_line_status,
                    lines.delivery_challan_number,
                    lines.transport_challan_number, lines.transport_name,
                    lines.transport_id, lines.delivery_id,
                    lines.delivery_detail_id, lines.delivery_date,
                    lines.attribute1, lines.attribute2, lines.attribute3,
                    lines.attribute4, lines.attribute5, lines.attribute6,
                    lines.attribute7, lines.attribute8, lines.attribute9,
                    lines.attribute10, lines.attribute11, lines.attribute12,
                    lines.attribute13, lines.attribute14, lines.attribute15,
                    lines.last_update_date, lines.last_updated_by,
                    lines.creation_date, lines.created_by,
                    lines.last_update_login
               FROM xxdbl_omshipping_line lines
              WHERE 1 = 1
                AND lines.ship_to_warehouse = rec_headers.ship_to_warehouse
                AND lines.warehouse_id = rec_headers.warehouse_id
                AND lines.delivery_challan_number =
                                           rec_headers.delivery_challan_number
                AND lines.omshipping_line_status NOT IN
                                      ('CANCELLED') -- ('CLOSED', 'CANCELLED')
                                                   
                                                   /*AND NOT EXISTS (
                                                          SELECT 'X'
                                                            FROM wsh_delivery_line_status_v wdlsv
                                                           WHERE wdlsv.source_code = 'OE'
                                                             AND wdlsv.source_line_id = lines.order_line_id)*/
            )
         LOOP
            INSERT INTO xxdbl.xxdbl_mtl_reservations
               SELECT *
                 FROM mtl_reservations
                WHERE demand_source_line_id = rec_lines.order_line_id
                  AND demand_source_type_id = 2
                  AND demand_source_header_id = rec_lines.order_id
                  AND inventory_item_id = rec_lines.item_id
                  AND organization_id = rec_lines.warehouse_id;

            DELETE FROM mtl_reservations
                  WHERE demand_source_line_id = rec_lines.order_line_id
                    AND demand_source_type_id = 2
                    AND demand_source_header_id = rec_lines.order_id
                    AND inventory_item_id = rec_lines.item_id
                    AND organization_id = rec_lines.warehouse_id;

            BEGIN
               /*UPDATE wsh_delivery_details
                  SET date_requested = rec_lines.delivery_date,
                      date_scheduled = rec_lines.delivery_date
                WHERE 1 = 1 AND source_line_id = rec_lines.order_line_id;*/
               SELECT xx.delivery_detail_id, xx.delivery_id,
                      xx.latest_pickup_date,
                      NVL (wdlsv2.released_status, 'O')
                 INTO l_delivery_detail_id, l_delivery_id,
                      l_date_shipped,
                      l_released_status
                 FROM (SELECT   NVL
                                   (MAX (NVL (delivery_detail_id, -1)),
                                    -1
                                   ) delivery_detail_id,
                                NVL (MAX (NVL (delivery_id, -1)),
                                     -1
                                    ) delivery_id,
                                MAX (latest_pickup_date) latest_pickup_date
                           /*date_shipped,*/
                       FROM     wsh_deliverables_v /*wsh_dlvy_deliverables_v*/ wdlsv
                          WHERE 1 = 1
                            AND wdlsv.source_line_id = rec_lines.order_line_id
                       GROUP BY NVL (delivery_id, -1), latest_pickup_date) xx,
                      wsh_deliverables_v wdlsv2
                WHERE 1 = 1
                  AND xx.delivery_detail_id = wdlsv2.delivery_detail_id
                                                                       /*AND (   (xx.delivery_id > 0)
                                                                            OR (NVL (wdlsv2.released_status, 'O') != 'B')
                                                                           )*/
               ;
            EXCEPTION
               WHEN TOO_MANY_ROWS
               THEN
                  BEGIN
                     SELECT xx.delivery_detail_id, xx.delivery_id,
                            xx.latest_pickup_date,
                            NVL (wdlsv2.released_status, 'O')
                       INTO l_delivery_detail_id, l_delivery_id,
                            l_date_shipped,
                            l_released_status
                       FROM (SELECT   NVL
                                         (MAX (NVL (delivery_detail_id, -1)),
                                          -1
                                         ) delivery_detail_id,
                                      NVL
                                         (MAX (NVL (delivery_id, -1)),
                                          -1
                                         ) delivery_id,
                                      MAX
                                         (latest_pickup_date
                                         ) latest_pickup_date
                                 /*date_shipped,*/
                             FROM     wsh_deliverables_v /*wsh_dlvy_deliverables_v*/ wdlsv
                                WHERE 1 = 1
                                  AND wdlsv.source_line_id =
                                                       rec_lines.order_line_id
                             GROUP BY NVL (delivery_id, -1),
                                      latest_pickup_date) xx,
                            wsh_deliverables_v wdlsv2
                      WHERE 1 = 1
                        AND xx.delivery_detail_id = wdlsv2.delivery_detail_id
                        AND (   (xx.delivery_id > 0)
                             OR (NVL (wdlsv2.released_status, 'O') != 'B')
                            );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_delivery_detail_id := -1;
                        l_delivery_id := -1;
                  END;
               WHEN OTHERS
               THEN
                  l_delivery_detail_id := -1;
                  l_delivery_id := -1;
            END;

            /*debug_insert (   'l_delivery_detail_id:         '
                          || l_delivery_detail_id
                         );
            debug_insert ('l_delivery_id:         ' || l_delivery_id);*/
            IF l_delivery_id > 0
            THEN
               IF l_delivery_pending = 'Y'
               THEN
                  l_delivery_pending := 'Y';
               ELSE
                  l_delivery_pending := 'N';
               END IF;
            ELSE
               l_delivery_pending := 'Y';
            END IF;

            --debug_insert ('l_delivery_pending:         ' || l_delivery_pending);
            IF l_delivery_detail_id < 0
            THEN
               IF x_message IS NULL
               THEN
                  x_message :=
                        'Unable to Get Deliver Detail ID for '
                     || rec_lines.order_number
                     || '-'
                     || rec_lines.order_line_no;
               ELSE
                  x_message :=
                        x_message
                     || CHR (10)
                     || 'Unable to Get Deliver Detail ID for '
                     || rec_lines.order_number
                     || '-'
                     || rec_lines.order_line_no;
               END IF;
            ELSE
               /*debug_insert ('l_released_status:         '
                             || l_released_status
                            );*/
               IF l_released_status <> 'C'
               THEN
                  p_line_rows (l_record_count) := l_delivery_detail_id;

                  UPDATE xxdbl_omshipping_line lines
                     SET delivery_detail_id = l_delivery_detail_id
                   WHERE 1 = 1
                     AND lines.omshipping_header_id =
                                                rec_lines.omshipping_header_id
                     AND lines.omshipping_line_id =
                                                  rec_lines.omshipping_line_id;

                  l_record_count := l_record_count + 1;
               ELSE
                  l_delivery_pending := 'N';
               END IF;
            END IF;
         END LOOP;                                            -- End rec_lines

         --debug_insert ('l_delivery_pending2:         ' || l_delivery_pending);
         IF l_delivery_pending = 'N'
         THEN
            l_auto_return_status := 'S';
         /*debug_insert (   'l_auto_return_status:         '
                       || l_auto_return_status
                      );*/
         ELSE
            IF l_delivery_id < 0
            THEN
               /*debug_insert (   'l_auto_return_status1:         '
                             || l_auto_return_status
                            );*/
               wsh_delivery_details_pub.autocreate_deliveries
                                    (p_api_version_number      => 1.0,
                                     p_init_msg_list           => apps.fnd_api.g_true,
                                     p_commit                  => apps.fnd_api.g_false,
                                     x_return_status           => l_auto_return_status,
                                     x_msg_count               => x_auto_msg_count,
                                     x_msg_data                => x_auto_msg_data,
                                     p_line_rows               => p_line_rows,
                                     x_del_rows                => x_del_rows
                                    );
            /*debug_insert (   'l_auto_return_status2:         '
                          || l_auto_return_status
                         );*/
            ELSE
               l_auto_return_status := 'S';
            /*debug_insert (   'l_auto_return_status3:         '
                          || l_auto_return_status
                         );*/
            END IF;
         END IF;

         /*debug_insert (   'l_auto_return_status4:         '
                       || l_auto_return_status
                      );*/
         IF (l_auto_return_status <> 'S')
         THEN
            FOR i IN 1 .. x_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_encoded            => 'F',
                                p_data               => x_auto_msg_data,
                                p_msg_index_out      => x_auto_out_index
                               );
            END LOOP;

            IF x_message IS NULL
            THEN
               x_message :=
                     'Delivery Creation Error '
                  || rec_headers.ship_to_warehouse
                  || '~~~'
                  || x_auto_msg_data;
            ELSE
               x_message :=
                     x_message
                  || CHR (10)
                  || 'Delivery Creation Error '
                  || rec_headers.ship_to_warehouse
                  || '~~~'
                  || x_auto_msg_data;
            END IF;
         ELSE
            --debug_insert ('l_delivery_id2:         ' || l_delivery_id);
            IF l_delivery_id < 0                --IF l_delivery_pending = 'Y'
            THEN
               p_delivery_id := x_del_rows (1);
               p_delivery_name := TO_CHAR (x_del_rows (1));

               BEGIN
                  SELECT MAX (lines.delivery_date)
                    INTO l_delivery_date
                    FROM xxdbl_omshipping_line lines
                   WHERE 1 = 1
                     AND lines.ship_to_warehouse =
                                                 rec_headers.ship_to_warehouse
                     AND lines.warehouse_id = rec_headers.warehouse_id
                     AND lines.delivery_challan_number =
                                           rec_headers.delivery_challan_number
                     AND lines.omshipping_line_status NOT IN ('CANCELLED')
                                                                          --('CLOSED', 'CANCELLED')
                  ;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_delivery_date := SYSDATE;
               END;

               UPDATE wsh_new_deliveries
                  SET attribute_category = 'Transporter Details',
                      attribute1 = rec_headers.transporter_id,
                      attribute7 = rec_headers.transporter_site_id,
                      attribute2 = rec_headers.vehicle_no,
                      attribute3 = rec_headers.delivery_mode_code,
                      attribute4 = rec_headers.driver_name,
                      attribute5 = rec_headers.transporter_no,
                      attribute6 = rec_headers.delivery_person,
                      initial_pickup_date = l_delivery_date
                WHERE delivery_id = x_del_rows (1);

               UPDATE xxdbl_omshipping_line lines
                  SET delivery_id = x_del_rows (1)         /*,
                               delivery_date = NVL (l_date_shipped, SYSDATE)*/
                WHERE 1 = 1
                  AND lines.ship_to_warehouse = rec_headers.ship_to_warehouse
                  AND lines.warehouse_id = rec_headers.warehouse_id
                  AND lines.delivery_challan_number =
                                           rec_headers.delivery_challan_number
                  AND lines.omshipping_line_status NOT IN ('CANCELLED')
                                                                       --('CLOSED', 'CANCELLED')
               ;
            ELSE
               BEGIN
                  SELECT MAX (lines.delivery_date)
                    INTO l_delivery_date
                    FROM xxdbl_omshipping_line lines
                   WHERE 1 = 1
                     AND lines.ship_to_warehouse =
                                                 rec_headers.ship_to_warehouse
                     AND lines.warehouse_id = rec_headers.warehouse_id
                     AND lines.delivery_challan_number =
                                           rec_headers.delivery_challan_number
                     AND lines.omshipping_line_status NOT IN ('CANCELLED')
                                                                          --('CLOSED', 'CANCELLED')
                  ;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_delivery_date := SYSDATE;
               END;

               UPDATE wsh_new_deliveries
                  SET attribute_category = 'Transporter Details',
                      attribute1 = rec_headers.transporter_id,
                      attribute7 = rec_headers.transporter_site_id,
                      attribute2 = rec_headers.vehicle_no,
                      attribute3 = rec_headers.delivery_mode_code,
                      attribute4 = rec_headers.driver_name,
                      attribute5 = rec_headers.transporter_no,
                      attribute6 = rec_headers.delivery_person,
                      initial_pickup_date = l_delivery_date
                WHERE delivery_id = l_delivery_id;

               UPDATE xxdbl_omshipping_line lines
                  SET delivery_id = l_delivery_id         /*,
                               delivery_date = NVL (l_date_shipped, SYSDATE)*/
                WHERE 1 = 1
                  AND lines.ship_to_warehouse = rec_headers.ship_to_warehouse
                  AND lines.warehouse_id = rec_headers.warehouse_id
                  AND lines.delivery_challan_number =
                                           rec_headers.delivery_challan_number
                  AND lines.omshipping_line_status NOT IN ('CANCELLED')
                                                                       --('CLOSED', 'CANCELLED')
               ;

               p_delivery_id := l_delivery_id;

               /*BEGIN
                  SELECT   delivery_id
                      INTO p_delivery_id
                      FROM xxdbl_omshipping_line lines
                     WHERE 1 = 1
                       AND lines.ship_to_warehouse =
                                                 rec_headers.ship_to_warehouse
                       AND lines.warehouse_id = rec_headers.warehouse_id
                       AND lines.delivery_challan_number =
                                           rec_headers.delivery_challan_number
                       AND lines.omshipping_line_status NOT IN ('CANCELLED')
                  GROUP BY delivery_id;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_delivery_id := -1;
               END;*/
               IF p_delivery_id < 0
               THEN
                  IF x_message IS NULL
                  THEN
                     x_message :=
                           'Unable to Get Delivery ID '
                        || rec_headers.ship_to_warehouse
                        || '~~~'
                        || rec_headers.delivery_challan_number;
                  ELSE
                     x_message :=
                           x_message
                        || CHR (10)
                        || 'Unable to Get Delivery ID '
                        || rec_headers.ship_to_warehouse
                        || '~~~'
                        || rec_headers.delivery_challan_number;
                  END IF;
               ELSE
                  p_delivery_name := p_delivery_id;
               END IF;
            END IF;
         END IF;

         p_line_rows.DELETE;
         l_record_count := 1;
      END LOOP;                                             -- End rec_headers

      BEGIN
         mo_global.set_policy_context ('S', fnd_profile.VALUE ('ORG_ID'));
         mo_global.init ('ONT');

         FOR rec_pick IN
            (SELECT *
               FROM (SELECT   line.org_id, line.delivery_id,
                              NVL (line.attribute6, 'NO') pick_release_status,
                              NVL (status_name, 'Open') delivery_status_name
                         FROM xxdbl_transpoter_headers xxth,
                              xxdbl_transpoter_line xxtl,
                              xxdbl_omshipping_line line,
                              wsh_new_deliveries_v wndv
                        WHERE 1 = 1
                          AND xxth.transpoter_header_id =
                                                     xxtl.transpoter_header_id
                          AND xxth.transpoter_header_id = p_transaction_hdr_id
                          AND xxtl.delivery_challan_number =
                                                  line.delivery_challan_number
                          AND line.omshipping_line_status NOT IN
                                                                ('CANCELLED')
                          AND line.delivery_id = wndv.delivery_id(+)
                     --('CLOSED', 'CANCELLED')
                     GROUP BY line.org_id,
                              line.delivery_id,
                              NVL (line.attribute6, 'NO'),
                              NVL (status_name, 'Open'))
              WHERE 1 = 1 AND delivery_status_name != 'Closed')
         LOOP
            -- Releases Lines related to a delivery
            IF rec_pick.delivery_id IS NULL
            THEN
               IF x_message IS NULL
               THEN
                  x_message :=
                        'Delivery Not Created '
                     || rec_pick.delivery_id
                     || '~~~'
                     || x_auto_msg_data;
               ELSE
                  x_message :=
                        x_message
                     || CHR (10)
                     || 'Delivery Not Created '
                     || rec_pick.delivery_id
                     || '~~~'
                     || x_auto_msg_data;
               END IF;
            ELSE
               pn_delivery_id := rec_pick.delivery_id;

               IF rec_pick.pick_release_status = 'NO'
               THEN
                  xxdbl_shiping_tran_crp_pkg.pick_release_pick_rule
                              (p_delivery_id         => pn_delivery_id,
                               p_return_status       => x_return_status,
                               p_return_message      => l_pick_release_ret_message
                              );
               ELSE
                  l_pick_release_ret_message := NULL;
               END IF;

               /*p_action_code := 'PICK-RELEASE';
               --WSH_PICK_LIST.RELEASE_BATCH
               -- delivery ID that action is performed on
               -- Call to WSH_DELIVERIES_PUB.Delivery_Action.
               wsh_deliveries_pub.delivery_action
                           (p_api_version_number        => 1.0,
                            p_init_msg_list             => p_init_msg_list,
                            x_return_status             => lx1_return_status,
                            x_msg_count                 => lx1_msg_count,
                            x_msg_data                  => lx1_msg_data,
                            p_action_code               => p_action_code,
                            p_delivery_id               => pn_delivery_id,
                            p_delivery_name             => pn_delivery_id,
                            p_asg_trip_id               => p_asg_trip_id,
                            p_asg_trip_name             => p_asg_trip_name,
                            p_asg_pickup_stop_id        => p_asg_pickup_stop_id,
                            p_asg_pickup_loc_id         => p_asg_pickup_loc_id,
                            p_asg_pickup_loc_code       => p_asg_pickup_loc_code,
                            p_asg_pickup_arr_date       => p_asg_pickup_arr_date,
                            p_asg_pickup_dep_date       => p_asg_pickup_dep_date,
                            p_asg_dropoff_stop_id       => p_asg_dropoff_stop_id,
                            p_asg_dropoff_loc_id        => p_asg_dropoff_loc_id,
                            p_asg_dropoff_loc_code      => p_asg_dropoff_loc_code,
                            p_asg_dropoff_arr_date      => p_asg_dropoff_arr_date,
                            p_asg_dropoff_dep_date      => p_asg_dropoff_dep_date,
                            p_sc_action_flag            => p_sc_action_flag,
                            p_sc_close_trip_flag        => p_sc_close_trip_flag,
                            p_sc_create_bol_flag        => p_sc_create_bol_flag,
                            p_sc_stage_del_flag         => p_sc_stage_del_flag,
                            p_sc_trip_ship_method       => p_sc_trip_ship_method,
                            p_sc_actual_dep_date        => p_sc_actual_dep_date,
                            p_sc_report_set_id          => p_sc_report_set_id,
                            p_sc_report_set_name        => p_sc_report_set_name,
                            p_wv_override_flag          => p_wv_override_flag,
                            x_trip_id                   => x_trip_id,
                            x_trip_name                 => x_trip_name
                           );*/
               IF l_pick_release_ret_message IS NOT NULL
               THEN
                  /*FOR i IN 1 .. lx1_msg_count
                  LOOP
                     fnd_msg_pub.get (p_msg_index          => i,
                                      p_encoded            => 'F',
                                      p_data               => x_auto_msg_data,
                                      p_msg_index_out      => x_auto_out_index
                                     );
                  END LOOP;*/
                  IF x_message IS NULL
                  THEN
                     x_message :=
                           'Delivery Pick Release Error '
                        || rec_pick.delivery_id
                        || '~~~'
                        || l_pick_release_ret_message;
                  ELSE
                     x_message :=
                           x_message
                        || CHR (10)
                        || 'Delivery Pick Release Error '
                        || rec_pick.delivery_id
                        || '~~~'
                        || l_pick_release_ret_message;
                  END IF;
               ELSE
                  FOR rec_del_lines IN
                     (SELECT lines.*
                        FROM xxdbl_omshipping_line lines,
                             wsh_new_deliveries_v wndv
                       WHERE 1 = 1
                         AND lines.org_id = rec_pick.org_id
                         AND lines.delivery_id = rec_pick.delivery_id
                         AND lines.delivery_id = wndv.delivery_id
                         AND wndv.status_name != 'Closed'
                         AND NVL (lines.attribute5, '2') = '2'
                         AND NVL (lines.attribute7, 'NO') = 'NO'
                         AND lines.omshipping_line_status NOT IN
                                                                ('CANCELLED')
                                                                             --('CLOSED', 'CANCELLED')
                     )
                  LOOP
                     BEGIN
                        SELECT NVL (MAX (move_order_line_id), -1)
                          INTO l_move_order_line_id
                          FROM wsh_delivery_details
                         WHERE delivery_detail_id =
                                              rec_del_lines.delivery_detail_id;

                        IF l_move_order_line_id < 0
                        THEN
                           IF x_message IS NULL
                           THEN
                              x_message :=
                                    'Unable to Get Move Order Line ID '
                                 || rec_del_lines.delivery_id;
                           ELSE
                              x_message :=
                                    x_message
                                 || CHR (10)
                                 || 'Unable to Get Move Order Line ID '
                                 || rec_del_lines.delivery_id;
                           END IF;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           IF x_message IS NULL
                           THEN
                              x_message :=
                                    'Unable to Get More Order Line ID '
                                 || rec_del_lines.delivery_id
                                 || '~~~'
                                 || SUBSTR (SQLERRM, 1, 100);
                           ELSE
                              x_message :=
                                    x_message
                                 || CHR (10)
                                 || 'Unable to Get More Order Line ID '
                                 || rec_del_lines.delivery_id
                                 || '~~~'
                                 || SUBSTR (SQLERRM, 1, 100);
                           END IF;
                     END;

                     IF l_move_order_line_id > 0
                     THEN
                        BEGIN
                           SELECT request_number
                             INTO l_move_order_number
                             FROM mtl_txn_request_headers
                            WHERE header_id =
                                       (SELECT header_id
                                          FROM mtl_txn_request_lines
                                         WHERE line_id = l_move_order_line_id);

                           BEGIN
                              SELECT open_flag, acct_period_id
                                INTO l_inv_period_status, l_acct_period_id
                                FROM org_acct_periods
                               WHERE organization_id =
                                                    rec_del_lines.warehouse_id
                                 AND TRUNC (SYSDATE) BETWEEN period_start_date
                                                         AND NVL
                                                               (schedule_close_date,
                                                                period_close_date
                                                               )
                                 AND period_set_name =
                                        (SELECT period_set_name
                                           FROM gl_sets_of_books
                                          WHERE set_of_books_id =
                                                   (SELECT set_of_books_id
                                                      FROM org_organization_definitions
                                                     WHERE organization_id =
                                                              rec_del_lines.warehouse_id));

                              FOR rec_move_order_line IN
                                 (SELECT mtrh.header_id, mtrh.request_number,
                                         mtrh.move_order_type,
                                         mtrh.organization_id, mtrl.line_id,
                                         mtrl.line_number,
                                         mtrl.inventory_item_id,
                                         mtrl.lot_number, mtrl.quantity,
                                         revision, mtrl.from_locator_id,
                                         (SELECT DISTINCT operating_unit
                                                     FROM org_organization_definitions
                                                    WHERE organization_id =
                                                             mtrh.organization_id)
                                                                       org_id,
                                         mtrl.txn_source_id,
                                         mtrl.txn_source_line_id,
                                         msi.lot_control_code,
                                         msi.serial_number_control_code,
                                         mtrl.pick_slip_number,
                                         mtrl.transaction_source_type_id,
                                         mtrl.transaction_type_id,
                                         mtrl.ROWID r_id,
                                         msi.location_control_code,
                                         msi.restrict_subinventories_code,
                                         msi.restrict_locators_code,
                                         msi.inventory_asset_flag,
                                         msi.allowed_units_lookup_code,
                                         msi.default_grade,
                                         msi.revision_qty_control_code,
                                         msi.shelf_life_code,
                                         msi.shelf_life_days,
                                         mtrl.to_subinventory_code,
                                         msi.description item_description
                                    FROM mtl_txn_request_headers mtrh,
                                         mtl_txn_request_lines mtrl,
                                         mtl_system_items msi
                                   WHERE mtrh.header_id = mtrl.header_id
                                     AND mtrl.inventory_item_id =
                                                         msi.inventory_item_id
                                     AND mtrl.organization_id =
                                                           msi.organization_id
                                     AND mtrh.organization_id =
                                                           msi.organization_id
                                     AND (mtrh.request_number =
                                                           l_move_order_number
                                         )
                                     AND (mtrh.organization_id =
                                                    rec_del_lines.warehouse_id
                                         )
                                     AND (mtrl.line_id = l_move_order_line_id
                                         ))
                              LOOP
                                 DELETE      mtl_transaction_lots_temp
                                       WHERE transaction_temp_id IN (
                                                SELECT transaction_temp_id
                                                  FROM mtl_material_transactions_temp
                                                 WHERE move_order_line_id =
                                                          l_move_order_line_id);

                                 DELETE FROM mtl_material_transactions_temp
                                       WHERE move_order_line_id =
                                                          l_move_order_line_id;

--debug_insert('rec_del_lines.omshipping_header_id:        '||rec_del_lines.omshipping_header_id);
--debug_insert('rec_del_lines.omshipping_line_id:        '||rec_del_lines.omshipping_line_id);
                                 FOR rec_lots_headers IN
                                    (SELECT   lots.subinventory_code,
                                              lots.locator_id,
                                              NVL
                                                 (SUM (NVL (lots.quantity_crt,
                                                            0
                                                           )
                                                      ),
                                                  0
                                                 ) quantity_crt,
                                              NVL
                                                 (SUM (NVL (lots.quantity_sft,
                                                            0
                                                           )
                                                      ),
                                                  0
                                                 ) quantity_sft
                                         FROM xxdbl_omshipping_lot_lines lots
                                        WHERE lots.omshipping_header_id =
                                                 rec_del_lines.omshipping_header_id
                                          AND lots.omshipping_line_id =
                                                 rec_del_lines.omshipping_line_id
                                          AND NVL (lots.quantity_crt, 0) > 0
                                     GROUP BY lots.subinventory_code,
                                              lots.locator_id)
                                 LOOP
                                    -- -- debug_insert (   'MANAS001:         '
                                                 -- || SQL%ROWCOUNT
                                                 --);
                                    IF NVL (rec_lots_headers.quantity_sft, 0) <=
                                                                            0
                                    THEN
                                       rec_lots_headers.quantity_sft := NULL;
                                    END IF;

--debug_insert('rec_lots_headers.quantity_sft:        '||nvl(rec_lots_headers.quantity_sft, -999));
--debug_insert('rec_lots_headers.quantity_crt:        '||nvl(rec_lots_headers.quantity_crt, -888));
                                    FOR rec_lots IN
                                       (SELECT   lots.subinventory_code,
                                                 lots.locator_id,
                                                 lots.lot_number,
                                                 lots.attribute1,
                                                 NVL
                                                    (SUM
                                                        (NVL
                                                            (lots.quantity_crt,
                                                             0
                                                            )
                                                        ),
                                                     0
                                                    ) quantity_crt,
                                                 NVL
                                                    (SUM
                                                        (NVL
                                                            (lots.quantity_sft,
                                                             0
                                                            )
                                                        ),
                                                     0
                                                    ) quantity_sft
                                            FROM xxdbl_omshipping_lot_lines lots
                                           WHERE 1 = 1
                                             --AND lots.lot_number = mln.lot_number
                                             AND lots.omshipping_header_id =
                                                    rec_del_lines.omshipping_header_id
                                             AND lots.omshipping_line_id =
                                                    rec_del_lines.omshipping_line_id
                                             AND lots.subinventory_code =
                                                    rec_lots_headers.subinventory_code
                                             AND NVL (lots.locator_id, -1) =
                                                    NVL
                                                       (rec_lots_headers.locator_id,
                                                        NVL (lots.locator_id,
                                                             -1
                                                            )
                                                       )
                                             AND NVL (lots.quantity_crt, 0) >
                                                                             0
                                        GROUP BY lots.subinventory_code,
                                                 lots.locator_id,
                                                 lots.lot_number,
                                                 lots.attribute1)
                                    LOOP
                                          /*SELECT mtl_material_transactions_s.NEXTVAL
                                       INTO l_new_transaction_temp_id
                                       FROM DUAL;*/
                                       SELECT mtl_material_transactions_s.NEXTVAL
                                         INTO l_new_transaction_temp_hdr_id
                                         FROM DUAL;

                                       IF NVL (rec_lots.quantity_sft, 0) <= 0
                                       THEN
                                          rec_lots.quantity_sft := NULL;
                                       END IF;

--debug_insert('rec_lots.quantity_sft:        '||nvl(rec_lots.quantity_sft, -999));
--debug_insert('rec_lots.quantity_crtt:        '||nvl(rec_lots.quantity_crt, -888));
                                       INSERT INTO mtl_material_transactions_temp
                                                   (transaction_header_id,
                                                    transaction_temp_id,
                                                    last_update_date,
                                                    last_updated_by,
                                                    creation_date,
                                                    created_by,
                                                    last_update_login,
                                                    inventory_item_id,
                                                    organization_id,
                                                    subinventory_code,
                                                    transaction_quantity,
                                                    primary_quantity,
                                                    transaction_uom,
                                                    transaction_type_id,
                                                    transaction_action_id,
                                                    transaction_source_type_id,
                                                    transaction_source_id,
                                                    transaction_date,
                                                    acct_period_id,
                                                    trx_source_line_id,
                                                    transfer_subinventory,
                                                    --transfer_organization,
                                                    demand_source_header_id,
                                                    demand_source_line,
                                                    item_primary_uom_code,
                                                    item_lot_control_code,
                                                    item_serial_control_code,
                                                    posting_flag,
                                                    process_flag,
                                                    pick_rule_id,
                                                    move_order_line_id,
                                                    pick_slip_number,
                                                    transaction_status,
                                                    wms_task_type,
                                                    wms_task_status,
                                                    --move_order_header_id,
                                                    source_line_id,
                                                    transaction_mode,
                                                    locator_id,
                                                    item_location_control_code,
                                                    item_restrict_subinv_code,
                                                    item_restrict_locators_code,
                                                    item_inventory_asset_flag,
                                                    allowed_units_lookup_code,
                                                    transfer_to_location,
                                                    --fulfillment_base,
                                                    item_revision_qty_control_code,
                                                    item_shelf_life_code,
                                                    item_shelf_life_days,
                                                    secondary_transaction_quantity,
                                                    secondary_uom_code,
                                                    item_description,
                                                    reservation_id
                                                   )
                                            VALUES (l_new_transaction_temp_hdr_id,
                                                    -- transaction_header_id
                                                    l_new_transaction_temp_hdr_id,
                                                    --l_new_transaction_temp_id,
                                                      -- transaction_temp_id
                                                    --rec_del_lines.delivery_date,
                                                    SYSDATE,
                                                    -- last_update_date
                                                    fnd_global.user_id,
                                                    -- last_updated_by
                                                    --rec_del_lines.delivery_date,
                                                    SYSDATE,
                                                    -- creation_date
                                                    fnd_global.user_id,
                                                    -- created_by
                                                    fnd_global.login_id,
                                                    -- last_update_login
                                                    rec_move_order_line.inventory_item_id,
                                                    -- inventory_item_id
                                                    rec_del_lines.warehouse_id,
                                                    -- organization_id
                                                    rec_lots_headers.subinventory_code,
                                                    -- subinventory_code
                                                    rec_lots.quantity_crt,
                                                    --rec_lots_headers.quantity_crt,
                                                          -- transaction_quantity
                                                    rec_lots.quantity_crt,
                                                    --rec_lots_headers.quantity_crt,
                                                          -- primary_quantity
                                                    UPPER
                                                       (rec_del_lines.attribute1
                                                       ),
                                                    -- transaction_uom
                                                    rec_move_order_line.transaction_type_id,
                                                    -- transaction_type_id
                                                    28,
                                                    -- transaction_action_id
                                                    rec_move_order_line.transaction_source_type_id,
                                                    -- transaction_source_type_id
                                                    rec_move_order_line.txn_source_id,
                                                    -- transaction_source_id
                                                    --rec_del_lines.delivery_date,
                                                    SYSDATE,
                                                    -- transaction_date
                                                    l_acct_period_id,
                                                    -- acct_period_id
                                                    rec_move_order_line.txn_source_line_id,
                                                    -- trx_source_line_id
                                                    rec_move_order_line.to_subinventory_code,
                                                    --rec_lots_headers.subinventory_code,
                                                            -- transfer_subinventory
                                                    --rec_del_lines.warehouse_id,
                                                    -- transfer_organization
                                                    rec_move_order_line.txn_source_id,
                                                    -- demand_source_header_id
                                                    TO_CHAR
                                                       (rec_move_order_line.txn_source_line_id
                                                       ),
                                                    -- demand_source_line
                                                    UPPER
                                                       (rec_del_lines.attribute1
                                                       ),
                                                    -- item_primary_uom_code
                                                    rec_move_order_line.lot_control_code,
                                                    -- item_lot_control_code
                                                    rec_move_order_line.serial_number_control_code,
                                                    
                                                    -- item_serial_control_code
                                                    'Y',       -- posting_flag
                                                    'Y',       -- process_flag
                                                    NULL,     --l_wms_rule_id,
                                                    --10080,                      -- pick_rule_id
                                                    rec_move_order_line.line_id,
                                                    -- move_order_line_id
                                                    rec_move_order_line.pick_slip_number,
                                                    -- pick_slip_number
                                                    2,   -- transaction_status
                                                    1,        -- wms_task_type
                                                    1,      -- wms_task_status
                                                    --rec_move_order_line.header_id,
                                                    -- move_order_header_id
                                                    l_move_order_line_id,
                                                    --rec_move_order_line.line_id,                              -- source_line_id
                                                    NULL,  -- transaction_mode
                                                    rec_lots_headers.locator_id,
                                                    -- For Nashik 13, -- locator id
                                                    rec_move_order_line.location_control_code,
                                                    rec_move_order_line.restrict_subinventories_code,
                                                    rec_move_order_line.restrict_locators_code,
                                                    rec_move_order_line.inventory_asset_flag,
                                                    rec_move_order_line.allowed_units_lookup_code,
                                                    rec_lots_headers.locator_id,
                                                    -- TRANSFER_TO_LOCATION
                                                    --'P',
                                                    -- FULFILLMENT_BASE
                                                    rec_move_order_line.revision_qty_control_code,
                                                    --ITEM_REVISION_QTY_CONTROL_CODE,
                                                    rec_move_order_line.shelf_life_code,
                                                    -- ITEM_SHELF_LIFE_CODE,
                                                    rec_move_order_line.shelf_life_days,
                                                    -- ITEM_SHELF_LIFE_DAYS
                                                    rec_lots.quantity_sft,
                                                    --rec_lots_headers.quantity_sft,
                                                    UPPER
                                                       (rec_del_lines.attribute2
                                                       ),
                                                    rec_move_order_line.item_description,
                                                    -- ITEM_DESCRIPTION
                                                    rec_lots.attribute1
                                                   -- reservation_id
                                                   );

                                       /*l_rsv.reservation_id :=
                                                          rec_lots.attribute1;
                                       -- debug_insert
                                            (   'l_rsv.reservation_id:      '
                                             || l_rsv.reservation_id
                                            );

                                       INSERT INTO xxdbl.xxdbl_mtl_reservations
                                          SELECT *
                                            FROM mtl_reservations
                                           WHERE reservation_id =
                                                           rec_lots.attribute1;


                                       inv_reservation_pub.delete_reservation
                                            (p_api_version_number      => 1.0,
                                             p_init_msg_lst            => fnd_api.g_true,
                                             x_return_status           => lx_status,
                                             x_msg_count               => lx_msg_count,
                                             x_msg_data                => lx_msg_data,
                                             p_rsv_rec                 => l_rsv,
                                             p_serial_number           => lv_dummy_sn
                                            );

                                       IF lx_status <>
                                                     fnd_api.g_ret_sts_success
                                       THEN
                                          IF lx_msg_count = 1
                                          THEN
                                             IF x_message IS NULL
                                             THEN
                                                x_message :=
                                                      'Delete Reservation Error: '
                                                   || lx_msg_data;
                                             ELSE
                                                x_message :=
                                                      x_message
                                                   || 'Delete Reservation Error: '
                                                   || lx_msg_data;
                                             END IF;
                                          ELSIF lx_msg_count > 1
                                          THEN
                                             FOR i IN 1 .. lx_msg_count
                                             LOOP
                                                IF x_message IS NULL
                                                THEN
                                                   x_message :=
                                                         'Delete Reservation Error: '
                                                      || i
                                                      || '. '
                                                      || SUBSTR
                                                            (fnd_msg_pub.get
                                                                (p_encoded      => fnd_api.g_false
                                                                ),
                                                             1,
                                                             255
                                                            );
                                                ELSE
                                                   x_message :=
                                                         x_message
                                                      || 'Delete Reservation Error: '
                                                      || i
                                                      || '. '
                                                      || SUBSTR
                                                            (fnd_msg_pub.get
                                                                (p_encoded      => fnd_api.g_false
                                                                ),
                                                             1,
                                                             255
                                                            );
                                                END IF;
                                             END LOOP;
                                          END IF;
                                       END IF;*/
                                       INSERT INTO mtl_transaction_lots_temp
                                                   (transaction_temp_id,
                                                    group_header_id,
                                                    last_update_date,
                                                    last_updated_by,
                                                    creation_date,
                                                    created_by,
                                                    last_update_login,
                                                    transaction_quantity,
                                                    primary_quantity,
                                                    lot_number,
                                                    pick_rule_id,
                                                    grade_code,
                                                    secondary_quantity,
                                                    secondary_unit_of_measure
                                                   )
                                            VALUES (l_new_transaction_temp_hdr_id,
                                                    --l_new_transaction_temp_id,
                                                    l_new_transaction_temp_hdr_id,
                                                    --l_new_transaction_temp_hdr_id,
                                                          -- GROUP_HEADER_ID
                                                    --rec_del_lines.delivery_date,
                                                    SYSDATE,
                                                    fnd_global.user_id,
                                                    --rec_del_lines.delivery_date,
                                                    SYSDATE,
                                                    fnd_global.user_id,
                                                    fnd_global.login_id,
                                                    --LAST_UPDATE_LOGIN
                                                    rec_lots.quantity_crt,
                                                    -- transaction_quantity
                                                    rec_lots.quantity_crt,
                                                    -- primary_quantity
                                                    rec_lots.lot_number,
                                                    NULL,
                                                    --l_lot_pick_hdr_rec.picking_rule_id,
                                                    rec_move_order_line.default_grade,
                                                    --rec_lots_headers.quantity_sft, -- Commented By Manas on 24-Feb-2019
                                                    rec_lots.quantity_sft,
                                                    UPPER
                                                       (rec_del_lines.attribute2
                                                       )
                                                   );
                                    -- -- debug_insert (   'MANAS002:         '
                                                  --|| SQL%ROWCOUNT
                                                 --);
                                    END LOOP;                      -- rec_lots
                                 END LOOP;                 -- rec_lots_headers

                                 COMMIT;

                                 BEGIN
                                    SELECT COUNT (1)
                                      INTO l_move_order_status_count
                                      FROM mtl_txn_request_lines_v
                                     WHERE organization_id =
                                                    rec_del_lines.warehouse_id
                                       AND line_status IN (3, 7, 9)
                                       AND line_id = l_move_order_line_id;
                                 EXCEPTION
                                    WHEN OTHERS
                                    THEN
                                       l_move_order_status_count := 0;
                                 END;

                                 /*INSERT INTO mtl_material_transa_temp1
                                    SELECT *
                                      FROM mtl_material_transactions_temp
                                     WHERE transaction_temp_id =
                                                     l_new_transaction_temp_id;

                                 INSERT INTO mtl_transaction_lots_temp1
                                    SELECT *
                                      FROM mtl_transaction_lots_temp
                                     WHERE transaction_temp_id =
                                                     l_new_transaction_temp_id;

                                 COMMIT;*/
                                 IF l_move_order_status_count > 0
                                 THEN
                                    xxdbl_shiping_tran_crp_pkg.transact_move_order
                                       (p_move_order_line_id      => l_move_order_line_id,
                                        p_api                     => 'P',
                                        p_trx_temp_id             => l_new_transaction_temp_id,
                                        p_transaction_date        => SYSDATE,
                                        --rec_del_lines.delivery_date,
                                        p_return_status           => l_return_status_mv_tran,
                                        p_return_message          => l_return_message_mv_tran
                                       );
                                 END IF;

                                 IF l_return_status_mv_tran <> 'S'
                                 THEN
                                    /*IF l_return_message_mv_tran NOT LIKE
                                                                  '%Success%'
                                    THEN*/
                                    IF x_message IS NULL
                                    THEN
                                       x_message :=
                                             'Transact Move Order Error '
                                          || l_return_status_mv_tran
                                          || l_return_message_mv_tran;
                                    ELSE
                                       x_message :=
                                             x_message
                                          || CHR (10)
                                          || 'Transact Move Order Error '
                                          || l_return_status_mv_tran
                                          || l_return_message_mv_tran;
                                    END IF;
                                 --END IF;
                                 ELSE
                                    BEGIN
                                       SELECT COUNT (1)
                                         INTO l_move_order_status_count
                                         FROM mtl_txn_request_lines_v
                                        WHERE organization_id =
                                                    rec_del_lines.warehouse_id
                                          AND line_status IN (3, 7, 9)
                                          AND line_id = l_move_order_line_id;
                                    EXCEPTION
                                       WHEN OTHERS
                                       THEN
                                          l_move_order_status_count := 0;
                                    END;

                                    IF l_move_order_status_count = 0
                                    THEN
                                       UPDATE xxdbl_omshipping_line
                                          SET attribute7 = 'TRAN_MOVE_ORDER'
                                        WHERE omshipping_header_id =
                                                 rec_del_lines.omshipping_header_id
                                          AND omshipping_line_id =
                                                 rec_del_lines.omshipping_line_id;

                                       COMMIT;
                                    ELSE
                                       IF x_message IS NULL
                                       THEN
                                          x_message :=
                                                'Transact Move Order Error '
                                             || l_return_status_mv_tran
                                             || l_return_message_mv_tran;
                                       ELSE
                                          x_message :=
                                                x_message
                                             || CHR (10)
                                             || 'Transact Move Order Error '
                                             || l_return_status_mv_tran
                                             || l_return_message_mv_tran;
                                       END IF;
                                    END IF;
                                 END IF;
                              END LOOP;                 -- rec_move_order_line
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 IF x_message IS NULL
                                 THEN
                                    x_message :=
                                          'Unable to Get Accounting Period Information '
                                       || rec_del_lines.delivery_id
                                       || '~~~'
                                       || SUBSTR (SQLERRM, 1, 100);
                                 ELSE
                                    x_message :=
                                          x_message
                                       || CHR (10)
                                       || 'Unable to Get Accounting Period Information '
                                       || rec_del_lines.delivery_id
                                       || '~~~'
                                       || SUBSTR (SQLERRM, 1, 100);
                                 END IF;
                           END;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              IF x_message IS NULL
                              THEN
                                 x_message :=
                                       'Unable to Get More Order Number '
                                    || rec_del_lines.delivery_id
                                    || '~~~'
                                    || SUBSTR (SQLERRM, 1, 100);
                              ELSE
                                 x_message :=
                                       x_message
                                    || CHR (10)
                                    || 'Unable to Get More Order Number '
                                    || rec_del_lines.delivery_id
                                    || '~~~'
                                    || SUBSTR (SQLERRM, 1, 100);
                              END IF;
                        END;
                     END IF;
                  END LOOP;                                   -- rec_del_lines
               END IF;

               IF x_message IS NULL
               THEN
                  BEGIN
                     FOR rec_delivery_details IN
                        (SELECT delivery_detail_id
                           FROM wsh_dlvy_deliverables_v
                          WHERE delivery_id = rec_pick.delivery_id)
                     LOOP
                        FOR exceptions_rec IN
                           exceptions_cur
                                     (rec_delivery_details.delivery_detail_id)
                        LOOP
                           lc_wsh_exceptions_rec.exception_id :=
                                                  exceptions_rec.exception_id;
                           lc_wsh_exceptions_rec.new_status := 'CLOSED';
                           wsh_exceptions_pub.exception_action
                                   (p_api_version           => 1.0,
                                    p_init_msg_list         => NULL,
                                    p_validation_level      => NULL,
                                    p_commit                => fnd_api.g_true,
                                    x_msg_count             => lx_msg_count2,
                                    x_msg_data              => lx_msg_data2,
                                    x_return_status         => lx_return_status2,
                                    p_exception_rec         => lc_wsh_exceptions_rec,
                                    p_action                => 'CHANGE_STATUS'
                                   );

                           IF lx_return_status2 NOT IN ('S', 'W')
                           THEN
                              FOR k IN 1 .. lx_msg_count2
                              LOOP
                                 fnd_msg_pub.get
                                         (p_msg_index          => k,
                                          p_encoded            => 'F',
                                          p_data               => l_message2,
                                          p_msg_index_out      => l_msg_index_out2
                                         );

                                 IF x_message IS NULL
                                 THEN
                                    x_message :=
                                          'The WSH Exception Status Update Error Message '
                                       || k
                                       || ' is: '
                                       || l_message2;
                                 ELSE
                                    x_message :=
                                          x_message
                                       || CHR (10)
                                       || 'The WSH Exception Status Update Error Message '
                                       || k
                                       || ' is: '
                                       || l_message2;
                                 END IF;
                              END LOOP;        -- exceptions_rec Error Message
                           END IF;
                        END LOOP;                            -- exceptions_rec
                     END LOOP;                         -- rec_delivery_details
                  END;

                  BEGIN
                     SELECT NVL (status_name, 'Open')
                       INTO l_status_name
                       FROM wsh_new_deliveries_v
                      WHERE delivery_id = rec_pick.delivery_id;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_status_name := 'Open';
                  END;

                  IF l_status_name != 'Closed'
                  THEN
                     xxdbl_shiping_tran_crp_pkg.ship_confirm
                                     (p_delivery_id         => rec_pick.delivery_id,
                                      p_return_status       => l_return_status_sc,
                                      p_return_message      => l_return_message_sc
                                     );

                     IF l_return_status_sc <> 'S'
                     THEN
                        IF x_message IS NULL
                        THEN
                           x_message :=
                                 'Ship Confirm Error ' || l_return_message_sc;
                        ELSE
                           x_message :=
                                 x_message
                              || CHR (10)
                              || 'Ship Confirm Error '
                              || l_return_message_sc;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;                                                 -- rec_pick
      END;
   END pick_ship_process;

   FUNCTION get_sales_channel (
      p_header_id        IN   NUMBER,
      p_sold_to_org_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      l_sales_channel_code   oe_order_headers_all.sales_channel_code%TYPE
                                                                      := NULL;
   BEGIN
      -- QP_SOURCING_API_PUB.Get_Sales_Channel(OE_ORDER_PUB.G_LINE.sold_to_org_id)
      BEGIN
         SELECT sales_channel_code
           INTO l_sales_channel_code
           FROM oe_order_headers_all
          WHERE header_id = p_header_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_sales_channel_code := NULL;
      END;

      IF l_sales_channel_code IS NOT NULL
      THEN
         RETURN l_sales_channel_code;
      ELSE
         BEGIN
            SELECT qp_sourcing_api_pub.get_sales_channel (p_sold_to_org_id)
              INTO l_sales_channel_code
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_sales_channel_code := NULL;
         END;

         RETURN l_sales_channel_code;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_sales_channel;

   PROCEDURE is_line_in_bs (
      p_application_id                 IN              NUMBER,
      p_entity_short_name              IN              VARCHAR2,
      p_validation_entity_short_name   IN              VARCHAR2,
      p_validation_tmplt_short_name    IN              VARCHAR2,
      p_record_set_tmplt_short_name    IN              VARCHAR2,
      p_scope                          IN              VARCHAR2,
      p_result                         OUT NOCOPY      NUMBER
   )
   IS
      l_line_id   NUMBER := oe_line_security.g_record.line_id;
      l_count     NUMBER := 0;
   BEGIN
      BEGIN
         SELECT COUNT (1)
           INTO l_count
           FROM xxdbl_bill_stat_headers xbsh, xxdbl_bill_stat_lines xbsl
          WHERE 1 = 1
            AND xbsh.bill_stat_header_id = xbsl.bill_stat_header_id
            AND bill_stat_status != 'CANCELLED'
            AND order_line_id = l_line_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_count := 0;
      END;

      IF l_count > 0
      THEN
         p_result := 1;
      ELSE
         p_result := 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result := 0;
   END is_line_in_bs;

   FUNCTION return_available_quantity (
      p_inevntory_item_id   IN   NUMBER,
      p_ship_from_org_id    IN   NUMBER,
      p_item_code           IN   VARCHAR2,
      p_pri_uom             IN   VARCHAR2,
      p_sec_uom             IN   VARCHAR2,
      p_preferred_grade     IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_qty_pri        NUMBER          := 0;
      l_qty_sec        NUMBER          := 0;
      l_final_return   VARCHAR2 (4000) := NULL;
   BEGIN
      BEGIN
         SELECT NVL (SUM (moq.transaction_quantity), 0),
                NVL (SUM (moq.secondary_transaction_quantity), 0)
           INTO l_qty_pri,
                l_qty_sec
           FROM mtl_onhand_quantities moq, mtl_lot_numbers_all_v mln
          WHERE 1 = 1
            AND moq.organization_id = mln.organization_id
            AND moq.inventory_item_id = mln.inventory_item_id
            AND moq.lot_number = mln.lot_number
            AND mln.grade_code = p_preferred_grade
            AND moq.organization_id = p_ship_from_org_id
            AND moq.inventory_item_id = p_inevntory_item_id
            AND xxdbl_shiping_tran_crp_pkg.available_to_transact
                                                       (moq.organization_id,
                                                        moq.inventory_item_id,
                                                        moq.subinventory_code,
                                                        moq.locator_id,
                                                        moq.lot_number
                                                       ) > 0;
      /*SELECT xxdbl_shiping_tran_crp_pkg.available_to_transact
                                                      (p_ship_from_org_id,
                                                       p_inevntory_item_id,
                                                       NULL,
                                                       NULL,
                                                       NULL
                                                      ),
               xxdbl_shiping_tran_crp_pkg.available_to_transact
                                                      (p_ship_from_org_id,
                                                       p_inevntory_item_id,
                                                       NULL,
                                                       NULL,
                                                       NULL
                                                      )
             * inv_convert.inv_um_convert (p_inevntory_item_id,
                                           NULL,
                                           1,
                                           p_pri_uom,
                                           p_sec_uom,
                                           NULL,
                                           NULL
                                          )
        INTO l_qty_pri,
             l_qty_sec
        FROM DUAL;*/
      EXCEPTION
         WHEN OTHERS
         THEN
            l_qty_pri := 0;
            l_qty_sec := 0;
      END;

      l_final_return :=
            'Item Code '
         || p_item_code
         /*|| CHR (10)
         || 'Primary Available Quantity is: '
         || l_qty_pri*/
         || CHR (10)
         || 'Secondary Available Quantity is: '
         || l_qty_sec;
      RETURN l_final_return;
   END return_available_quantity;

   FUNCTION return_avail_quantity_new (
      p_inevntory_item_id   IN   NUMBER,
      p_ship_from_org_id    IN   NUMBER,
      p_item_code           IN   VARCHAR2,
      p_pri_uom             IN   VARCHAR2,
      p_sec_uom             IN   VARCHAR2,
      p_preferred_grade     IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_qty_pri        NUMBER          := 0;
      l_qty_sec        NUMBER          := 0;
      l_final_return   VARCHAR2 (4000) := NULL;
   BEGIN
      BEGIN
         SELECT NVL (SUM (moq.transaction_quantity), 0),
                NVL (SUM (moq.secondary_transaction_quantity), 0)
           INTO l_qty_pri,
                l_qty_sec
           FROM mtl_onhand_quantities moq, mtl_lot_numbers_all_v mln
          WHERE 1 = 1
            AND moq.organization_id = mln.organization_id
            AND moq.inventory_item_id = mln.inventory_item_id
            AND moq.lot_number = mln.lot_number
            AND mln.grade_code = p_preferred_grade
            AND moq.organization_id = p_ship_from_org_id
            AND moq.inventory_item_id = p_inevntory_item_id
            AND xxdbl_shiping_tran_crp_pkg.available_to_transact
                                                       (moq.organization_id,
                                                        moq.inventory_item_id,
                                                        moq.subinventory_code,
                                                        moq.locator_id,
                                                        moq.lot_number
                                                       ) > 0;
      /*SELECT xxdbl_shiping_tran_crp_pkg.available_to_transact
                                                      (p_ship_from_org_id,
                                                       p_inevntory_item_id,
                                                       NULL,
                                                       NULL,
                                                       NULL
                                                      ),
               xxdbl_shiping_tran_crp_pkg.available_to_transact
                                                      (p_ship_from_org_id,
                                                       p_inevntory_item_id,
                                                       NULL,
                                                       NULL,
                                                       NULL
                                                      )
             * inv_convert.inv_um_convert (p_inevntory_item_id,
                                           NULL,
                                           1,
                                           p_pri_uom,
                                           p_sec_uom,
                                           NULL,
                                           NULL
                                          )
        INTO l_qty_pri,
             l_qty_sec
        FROM DUAL;*/
      EXCEPTION
         WHEN OTHERS
         THEN
            l_qty_pri := 0;
            l_qty_sec := 0;
      END;

      l_final_return := l_qty_sec;
      RETURN l_final_return;
   END return_avail_quantity_new;

   FUNCTION total_order_quantity (p_header_id IN NUMBER, p_org_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_ordered_quantity    NUMBER          := 0;
      l_ordered_quantity2   NUMBER          := 0;
      l_final_return        VARCHAR2 (4000) := NULL;
   BEGIN
      BEGIN
         SELECT NVL (SUM (ordered_quantity), 0),
                NVL (SUM (ordered_quantity2), 0)
           INTO l_ordered_quantity,
                l_ordered_quantity2
           FROM oe_order_lines_all
          WHERE 1 = 1
            AND header_id = p_header_id
            AND org_id = p_org_id
            AND NVL (cancelled_flag, 'N') = 'N';
      EXCEPTION
         WHEN OTHERS
         THEN
            l_ordered_quantity := 0;
            l_ordered_quantity2 := 0;
      END;

      l_final_return :=
            'Order Total SFT '
         || l_ordered_quantity
         || CHR (10)
         || 'Order Total CTN '
         || l_ordered_quantity2;
      RETURN l_final_return;
   END total_order_quantity;

   FUNCTION execute_immediate1 (p_ids IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_count     NUMBER          := 0;
      l_string    VARCHAR2 (4000) := NULL;
      l_ids       VARCHAR2 (4000) := NULL;
      l_ids1      VARCHAR2 (4000) := NULL;
      c_hdr_cur   sys_refcursor;
   BEGIN
      --debug_insert ('p_ids:     ' || p_ids);
      l_string :=
            'SELECT COUNT (distinct omshipping_header_id) FROM XXDBL_OMSHIPPING_HEADERS WHERE omshipping_header_id IN ('
         || p_ids
         || ')';

      EXECUTE IMMEDIATE l_string
                   INTO l_count;

      --debug_insert ('l_count:     ' || l_count);
      IF l_count = 0
      THEN
         RETURN NULL;
      ELSE
         /*l_string :=
               'DELETE      xxdbl_omshipping_headers xxoh WHERE omshipping_header_id IN ('
            || p_ids
            || ') AND 0 = (SELECT COUNT(1) FROM xxdbl_omshipping_line xxol
                         WHERE xxol.omshipping_header_id = xxoh.omshipping_header_id )';

         EXECUTE IMMEDIATE l_string;*/

         --COMMIT;
         l_string :=
               'SELECT DISTINCT omshipping_header_id FROM XXDBL_OMSHIPPING_HEADERS WHERE omshipping_header_id IN ('
            || p_ids
            || ')';

         OPEN c_hdr_cur FOR l_string;

         LOOP
            FETCH c_hdr_cur
             INTO l_ids1;

            --debug_insert ('l_ids1:     ' || l_ids1);
            IF l_ids IS NULL
            THEN
               l_ids := l_ids1;
            ELSE
               IF l_ids NOT LIKE '%' || l_ids1 || '%'
               THEN
                  l_ids := l_ids || ',' || l_ids1;
               END IF;
            END IF;

            EXIT WHEN c_hdr_cur%NOTFOUND;
         END LOOP;

         CLOSE c_hdr_cur;

         RETURN l_ids;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END execute_immediate1;

   FUNCTION get_split_line_exists (
      p_order_header_id   IN   NUMBER,
      p_order_line_id     IN   NUMBER
   )
      RETURN NUMBER
   IS
      l_return               NUMBER := 0;
      l_order_original_qty   NUMBER := 0;
      l_total_bs_qty         NUMBER := 0;
      l_line_number          NUMBER := NULL;
      l_return_order         NUMBER := 0;
   BEGIN
      BEGIN
         SELECT COUNT (1)
           INTO l_return_order
           FROM oe_order_headers_all d,
                oe_transaction_types_all f,
                oe_transaction_types_tl g
          WHERE 1 = 1
            AND d.header_id = p_order_header_id
            AND d.order_type_id = f.transaction_type_id
            AND f.transaction_type_id = g.transaction_type_id
            AND g.NAME LIKE '%Replacement%';
      EXCEPTION
         WHEN OTHERS
         THEN
            l_return_order := 0;
      END;

      IF l_return_order = 0
      THEN
         BEGIN
            SELECT   line_number,
                     NVL (SUM (  NVL (customer_job, 0)
                               * ((1 - NVL (cust_model_serial_number, 0) / 100
                                  )
                                 )
                              ),
                          0
                         )
                INTO l_line_number,
                     l_order_original_qty
                FROM oe_order_lines_all
               WHERE header_id = p_order_header_id
                 AND line_id = p_order_line_id
            GROUP BY line_number;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_order_original_qty := 0;
               l_line_number := NULL;
         END;

         BEGIN
            SELECT NVL (SUM (quantity), 0)
              INTO l_total_bs_qty
              FROM xxdbl_bill_stat_lines xbsl, xxdbl_bill_stat_headers xbsh
             WHERE xbsl.bill_stat_header_id = xbsh.bill_stat_header_id
               AND xbsh.bill_stat_status <> 'CANCELLED'
               AND xbsl.order_id = p_order_header_id
               AND xbsl.order_line_no LIKE l_line_number || '.' || '%'
                                                                      /*AND xbsl.order_line_id IN (
                                                                             SELECT     aa.line_id
                                                                                   FROM oe_order_lines_all aa
                                                                                  WHERE 1 = 1
                                                                                    AND aa.header_id = p_order_header_id
                                                                                    AND NVL (aa.cancelled_flag, 'N') = 'N'
                                                                                    AND LEVEL <> 1
                                                                             CONNECT BY PRIOR line_id = split_from_line_id
                                                                             START WITH aa.line_id = p_order_line_id
                                                                             UNION ALL
                                                                             SELECT     aa.line_id
                                                                                   FROM oe_order_lines_all aa
                                                                                  WHERE 1 = 1
                                                                                    AND aa.header_id = p_order_header_id
                                                                                    AND NVL (aa.cancelled_flag, 'N') = 'N'
                                                                                    AND LEVEL <> 1
                                                                             CONNECT BY PRIOR split_from_line_id = line_id
                                                                             START WITH aa.line_id = p_order_line_id)*/
            ;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_return := 0;
         END;

         IF l_order_original_qty <= l_total_bs_qty
         THEN
            l_return := 1;
         ELSE
            l_return := 0;
         END IF;
      ELSE
         l_return := 0;
      END IF;

      RETURN l_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN l_return;
   END get_split_line_exists;
END xxdbl_shiping_tran_crp_pkg;
/
