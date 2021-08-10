/* Formatted on 5/18/2021 5:34:09 PM (QP5 v5.287) */
DECLARE
   l_session_id               NUMBER;
   l_count                    NUMBER;
   l_msg_count                NUMBER := 0;
   l_return_status            VARCHAR2 (1);
   l_msg_data                 VARCHAR2 (20000);
   x_msg_data                 VARCHAR2 (20000);
   x_msg_details              VARCHAR2 (20000);
   x_msg_count                VARCHAR2 (20000);
   msg_text                   VARCHAR2 (20000) DEFAULT NULL;

   l_header_rec               oe_order_pub.header_rec_type;
   l_header_val_rec           oe_order_pub.header_val_rec_type;
   l_header_adj_tbl           oe_order_pub.header_adj_tbl_type;
   l_header_adj_val_tbl       oe_order_pub.header_adj_val_tbl_type;
   l_header_price_att_tbl     oe_order_pub.header_price_att_tbl_type;
   l_header_adj_att_tbl       oe_order_pub.header_adj_att_tbl_type;
   l_header_adj_assoc_tbl     oe_order_pub.header_adj_assoc_tbl_type;
   l_header_scredit_tbl       oe_order_pub.header_scredit_tbl_type;
   l_header_scredit_val_tbl   oe_order_pub.header_scredit_val_tbl_type;
   l_header_payment_tbl       oe_order_pub.header_payment_tbl_type;
   l_line_tbl                 oe_order_pub.line_tbl_type;
   l_line_val_tbl             oe_order_pub.line_val_tbl_type;
   l_line_adj_tbl             oe_order_pub.line_adj_tbl_type;
   l_line_adj_val_tbl         oe_order_pub.line_adj_val_tbl_type;
   l_line_price_att_tbl       oe_order_pub.line_price_att_tbl_type;
   l_line_adj_att_tbl         oe_order_pub.line_adj_att_tbl_type;
   l_line_adj_assoc_tbl       oe_order_pub.line_adj_assoc_tbl_type;
   l_line_scredit_tbl         oe_order_pub.line_scredit_tbl_type;
   l_line_scredit_val_tbl     oe_order_pub.line_scredit_val_tbl_type;
   l_lot_serial_tbl           oe_order_pub.lot_serial_tbl_type;
   l_lot_serial_val_tbl       oe_order_pub.lot_serial_val_tbl_type;
   l_action_request_tbl       oe_order_pub.request_tbl_type;
   o_header_rec               oe_order_pub.header_rec_type;
   o_header_val_rec           oe_order_pub.header_val_rec_type;
   o_header_adj_tbl           oe_order_pub.header_adj_tbl_type;
   o_header_adj_val_tbl       oe_order_pub.header_adj_val_tbl_type;
   o_header_price_att_tbl     oe_order_pub.header_price_att_tbl_type;
   o_header_adj_att_tbl       oe_order_pub.header_adj_att_tbl_type;
   o_header_adj_assoc_tbl     oe_order_pub.header_adj_assoc_tbl_type;
   o_header_scredit_tbl       oe_order_pub.header_scredit_tbl_type;
   o_header_scredit_val_tbl   oe_order_pub.header_scredit_val_tbl_type;
   o_header_payment_tbl       oe_order_pub.header_payment_tbl_type;
   o_header_payment_val_tbl   oe_order_pub.header_payment_val_tbl_type;
   o_line_tbl                 oe_order_pub.line_tbl_type;
   o_line_val_tbl             oe_order_pub.line_val_tbl_type;
   o_line_adj_tbl             oe_order_pub.line_adj_tbl_type;
   o_line_adj_val_tbl         oe_order_pub.line_adj_val_tbl_type;
   o_line_price_att_tbl       oe_order_pub.line_price_att_tbl_type;
   o_line_adj_att_tbl         oe_order_pub.line_adj_att_tbl_type;
   o_line_adj_assoc_tbl       oe_order_pub.line_adj_assoc_tbl_type;
   o_line_scredit_tbl         oe_order_pub.line_scredit_tbl_type;
   o_line_scredit_val_tbl     oe_order_pub.line_scredit_val_tbl_type;
   o_lot_serial_tbl           oe_order_pub.lot_serial_tbl_type;
   o_lot_serial_val_tbl       oe_order_pub.lot_serial_val_tbl_type;
   o_action_request_tbl       oe_order_pub.request_tbl_type;
   o_line_payment_tbl         oe_order_pub.line_payment_tbl_type;
   o_line_payment_val_tbl     oe_order_pub.line_payment_val_tbl_type;
   l_header_cust_info_tbl     oe_order_pub.customer_info_table_type;
   -- degug_file_name
   dbg_file                   VARCHAR2 (10240);
   l_inventory_item_id        NUMBER := 149;
   l_ship_from_org_id         NUMBER := 204;
   l_file_val                 VARCHAR2 (1000);
   l_count                    NUMBER := 0;
   err_msg                    VARCHAR2 (240);
   l_result                   VARCHAR2 (30);
   l_line_tbl_index           NUMBER;
BEGIN
   oe_debug_pub.debug_on;
   oe_debug_pub.initialize;
   l_file_val := OE_DEBUG_PUB.Set_Debug_Mode ('FILE');
   oe_Debug_pub.setdebuglevel (5); -- Use 5 for the most debugging output, I warn you its a lot of data
   DBMS_OUTPUT.put_line (' Inside the script');
   DBMS_OUTPUT.put_line ('file path is:' || l_file_val);

   fnd_global.apps_initialize (1318, 21623, 660); -- pass in user_id,responsibility_id, and application_id
   mo_global.init ('ONT');
   mo_global.set_policy_context ('S', 204); -- this may not be needed since passing org_id to the API
   -- Sample code to add customer
   l_header_cust_info_tbl (1) := oe_order_pub.g_miss_customer_info_rec ();
   l_header_cust_info_tbl (1).customer_info_ref := 'NEW_XX-REF-1';
   l_header_cust_info_tbl (1).customer_info_type_code := 'CUSTOMER';
   l_header_cust_info_tbl (1).customer_type := 'ORGANIZATION';
   l_header_cust_info_tbl (1).organization_name := 'NEW_XX-TEST-PO-CUST-15102';
   --l_header_cust_info_tbl(1).customer_number := 4445912; --Pass if automatic customer numbering is OFF
   l_header_cust_info_tbl (2) := oe_order_pub.g_miss_customer_info_rec ();
   l_header_cust_info_tbl (2).customer_info_type_code := 'ADDRESS';
   l_header_cust_info_tbl (2).customer_info_ref := 'NEW_XX-REF-2';
   l_header_cust_info_tbl (2).parent_customer_info_ref := 'NEW_XX-REF-1';
   l_header_cust_info_tbl (2).country := 'US';
   l_header_cust_info_tbl (2).city := 'Chattanooga';
   l_header_cust_info_tbl (2).state := 'TN';
   l_header_cust_info_tbl (2).postal_code := 37401;
   l_header_cust_info_tbl (2).county := 'Hamilton';
   l_header_cust_info_tbl (2).address1 := '611 - A  oracle parkway';
   l_header_cust_info_tbl (2).address2 := NULL;
   l_header_cust_info_tbl (2).address3 := NULL;
   l_header_cust_info_tbl (2).address4 := NULL;
   l_header_cust_info_tbl (2).location_number := 'LOC-0001';
   l_header_cust_info_tbl (2).site_number := 'SITE-0001';
   l_header_cust_info_tbl (3) := oe_order_pub.g_miss_customer_info_rec ();
   l_header_cust_info_tbl (3).customer_info_type_code := 'CONTACT';
   l_header_cust_info_tbl (3).customer_info_ref := 'NEW_XX-REF-3';
   l_header_cust_info_tbl (3).parent_customer_info_ref := 'NEW_XX-REF-1';
   l_header_cust_info_tbl (3).person_first_name := 'hello';
   l_header_cust_info_tbl (3).person_last_name := 'world';
   l_header_cust_info_tbl (3).email_address := 'hello@world123.com';
   oe_msg_pub.initialize;
   --==================================================================================================
   --
   --==================================================================================================
   l_header_rec := oe_order_pub.g_miss_header_rec;
   l_header_rec.operation := oe_globals.g_opr_create;
   l_header_rec.org_id := 204;
   l_header_rec.cust_po_number := NULL;
   --l_header_rec.sold_to_org_id := 1005;
   --l_header_rec.ship_to_org_id := 1024;
   --l_header_rec.invoice_to_org_id := 1023;
   l_header_rec.order_type_id := 1437;
   l_header_rec.freight_terms_code := NULL;
   l_header_rec.shipping_method_code := 'DHL';
   l_header_rec.price_list_id := 1000;
   l_header_rec.sold_to_customer_ref := 'NEW_XX-REF-1';
   l_header_rec.ship_to_address_ref := 'NEW_XX-REF-2';
   l_header_rec.invoice_to_address_ref := 'NEW_XX-REF-2';
   l_header_rec.deliver_to_address_ref := 'NEW_XX-REF-2';
   l_header_rec.sold_to_address_ref := 'NEW_XX-REF-2';
   l_header_rec.sold_to_contact_ref := 'NEW_XX-REF-3';
   l_header_rec.ship_to_contact_ref := 'NEW_XX-REF-3';
   l_header_rec.invoice_to_contact_ref := 'NEW_XX-REF-3';

   --==================================================================================================

   -- l_action_request_tbl(1).request_type := oe_globals.g_book_order;
   -- l_action_request_tbl(1).entity_code := oe_globals.g_entity_header;
   l_line_tbl_index := 1;
   l_line_tbl (l_line_tbl_index) := oe_order_pub.g_miss_line_rec;
   l_line_tbl (l_line_tbl_index).operation := oe_globals.g_opr_create;

   l_line_tbl (l_line_tbl_index).inventory_item_id := 2155;
   l_line_tbl (l_line_tbl_index).ordered_quantity := 10;
   l_line_tbl (l_line_tbl_index).ship_from_org_id := 207;

   l_line_tbl (l_line_tbl_index).payment_term_id := 4;
   l_line_tbl (l_line_tbl_index).line_type_id := 1427;
   l_line_tbl (l_line_tbl_index).price_list_id := 1000;
   l_line_tbl (l_line_tbl_index).calculate_price_flag := 'N';
   l_line_tbl (l_line_tbl_index).unit_list_price := 10;
   l_line_tbl (l_line_tbl_index).unit_selling_price := 10;

   --==================================================================================================
   -- Process Order API
   --==================================================================================================
   oe_order_pub.process_order (
      p_api_version_number         => 1.0,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data,
      p_header_rec                 => l_header_rec,
      p_line_tbl                   => l_line_tbl,
      p_header_payment_tbl         => l_header_payment_tbl,
      p_action_request_tbl         => l_action_request_tbl,
      p_header_customer_info_tbl   => l_header_cust_info_tbl,
      x_header_rec                 => o_header_rec,
      x_header_val_rec             => o_header_val_rec,
      x_header_adj_tbl             => o_header_adj_tbl,
      x_header_adj_val_tbl         => o_header_adj_val_tbl,
      x_header_price_att_tbl       => o_header_price_att_tbl,
      x_header_adj_att_tbl         => o_header_adj_att_tbl,
      x_header_adj_assoc_tbl       => o_header_adj_assoc_tbl,
      x_header_scredit_tbl         => o_header_scredit_tbl,
      x_header_scredit_val_tbl     => o_header_scredit_val_tbl,
      x_header_payment_tbl         => o_header_payment_tbl,
      x_header_payment_val_tbl     => o_header_payment_val_tbl,
      x_line_tbl                   => o_line_tbl,
      x_line_val_tbl               => o_line_val_tbl,
      x_line_adj_tbl               => o_line_adj_tbl,
      x_line_adj_val_tbl           => o_line_adj_val_tbl,
      x_line_price_att_tbl         => o_line_price_att_tbl,
      x_line_adj_att_tbl           => o_line_adj_att_tbl,
      x_line_adj_assoc_tbl         => o_line_adj_assoc_tbl,
      x_line_scredit_tbl           => o_line_scredit_tbl,
      x_line_scredit_val_tbl       => o_line_scredit_val_tbl,
      x_lot_serial_tbl             => o_lot_serial_tbl,
      x_lot_serial_val_tbl         => o_lot_serial_val_tbl,
      x_action_request_tbl         => o_action_request_tbl,
      x_line_payment_tbl           => o_line_payment_tbl,
      x_line_payment_val_tbl       => o_line_payment_val_tbl);

   IF l_msg_count > 0
   THEN
      FOR i IN 1 .. l_msg_count
      LOOP
         l_msg_data := oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
         DBMS_OUTPUT.put_line ('MESSAGE : ' || SUBSTRB (l_msg_data, 1, 200));
      END LOOP;
   END IF;

   IF l_return_status = fnd_api.g_ret_sts_success
   THEN
      DBMS_OUTPUT.put_line ('ORDER_NUMBER   : ' || o_header_rec.order_number);


      COMMIT;
   ELSE
      DBMS_OUTPUT.put_line ('FAILURE');
      DBMS_OUTPUT.put_line ('RETURN STATUS = ' || l_return_status);
      DBMS_OUTPUT.put_line ('***** ROLLBACK *****');
      ROLLBACK;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM);
END;
/