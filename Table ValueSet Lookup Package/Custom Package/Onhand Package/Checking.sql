
select APPS.XXDBL_CUSTOM_PKG.xx_onhand_qty (4575, 195,'OHQ') onhand
from dual


BEGIN
    EXECUTE inv_quantity_tree_pub.query_quantities(p_api_version_number    => 1.0,p_inventory_item_id     =>'288589',p_organization_id       =>150);
    
    END;

    
    
    inv_quantity_tree_pub.query_quantities (
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
         p_revision              => NULL,                       -- p_revision,
         p_lot_number            => NULL,                     -- p_lot_number,
         p_lot_expiration_date   => SYSDATE,
         p_subinventory_code     => NULL,              -- p_subinventory_code,
         p_locator_id            => NULL,                     -- p_locator_id,
         p_onhand_source         => 3,
         x_qoh                   => v_qoh,                 -- Quantity on-hand
         x_rqoh                  => v_rqoh,      --reservable quantity on-hand
         x_qr                    => v_qr,
         x_qs                    => v_qs,
         x_att                   => v_att,            -- available to transact
         x_atr                   => v_atr              -- available to reserve
                                         );