/* Formatted on 7/19/2020 10:38:56 AM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION XXDBL.XXDBL_FNC_GET_ONHAND_QTY (
   p_inv_item_id   IN NUMBER,
   p_org_id        IN NUMBER,
   p_qty_type      IN VARCHAR2)
   RETURN NUMBER
IS
   x_return_status         VARCHAR2 (50);
   x_msg_count             VARCHAR2 (50);
   x_msg_data              VARCHAR2 (50);
   v_item_id               NUMBER;
   v_organization_id       NUMBER;
   v_qoh                   NUMBER;
   v_rqoh                  NUMBER;
   v_atr                   NUMBER;
   v_att                   NUMBER;
   v_qr                    NUMBER;
   v_qs                    NUMBER;
   v_lot_control_code      BOOLEAN;
   v_serial_control_code   BOOLEAN;
   L_QTY                   NUMBER;
BEGIN
   SELECT inventory_item_id, mp.organization_id
     INTO v_item_id, v_organization_id
     FROM apps.mtl_system_items_b msib, apps.mtl_parameters mp
    WHERE     msib.inventory_item_id = p_inv_item_id
          AND msib.organization_id = mp.organization_id
          AND msib.organization_id = p_org_id;            --organization_code;


   v_qoh := NULL;
   v_rqoh := NULL;
   v_atr := NULL;
   v_lot_control_code := FALSE;
   v_serial_control_code := FALSE;


   apps.fnd_client_info.set_org_context (90);


   apps.inv_quantity_tree_pub.query_quantities (
      p_api_version_number    => 1.0,
      p_init_msg_lst          => 'F',
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      p_organization_id       => v_organization_id,
      p_inventory_item_id     => v_item_id,
      p_tree_mode             => apps.inv_quantity_tree_pub.g_transaction_mode,
      p_is_revision_control   => FALSE,
      p_is_lot_control        => v_lot_control_code,
      p_is_serial_control     => v_serial_control_code,
      p_revision              => NULL,                          -- p_revision,
      p_lot_number            => NULL,                        -- p_lot_number,
      p_lot_expiration_date   => SYSDATE,
      p_subinventory_code     => NULL,                 -- p_subinventory_code,
      p_locator_id            => NULL,                        -- p_locator_id,
      p_onhand_source         => 3,
      x_qoh                   => v_qoh,                    -- Quantity on-hand
      x_rqoh                  => v_rqoh,         --reservable quantity on-hand
      x_qr                    => v_qr,
      x_qs                    => v_qs,
      x_att                   => v_att,               -- available to transact
      x_atr                   => v_atr                 -- available to reserve
                                      );

   IF p_qty_type = 'OHQ'
   THEN                                                          --On Hand qty
      L_QTY := v_qoh;                                      --v_QuantityOnhand;
   ELSE
      IF p_qty_type = 'ATR'
      THEN                                              --Available to Reserve
         L_QTY := v_atr;
      ELSE
         IF p_qty_type = 'ATT'
         THEN                                          --Available to Transact
            L_QTY := v_att;
         END IF;
      END IF;
   END IF;

   RETURN L_QTY;
   --return v_atr;

   DBMS_OUTPUT.put_line ('On-Hand Quantity: ' || v_qoh);
   DBMS_OUTPUT.put_line ('Available to reserve: ' || v_atr);
   DBMS_OUTPUT.put_line ('Quantity Reserved: ' || v_qr);
   DBMS_OUTPUT.put_line ('Quantity Suggested: ' || v_qs);
   DBMS_OUTPUT.put_line ('Available to Transact: ' || v_att);
   DBMS_OUTPUT.put_line ('Available to Reserve: ' || v_atr);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('ERROR: ' || SQLERRM);
END;
/