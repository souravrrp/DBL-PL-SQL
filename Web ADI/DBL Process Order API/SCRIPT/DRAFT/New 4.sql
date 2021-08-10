/* Formatted on 5/20/2021 5:32:03 PM (QP5 v5.287) */
SET SERVEROUTPUT ON;

DECLARE
   l_api_version_number           NUMBER := 1;
   l_return_status                VARCHAR2 (2000);
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2 (2000);
   l_debug_level                  NUMBER := 1;       -- OM DEBUG LEVEL (MAX 5)

   -- IN Variables --
   l_header_rec                   oe_order_pub.header_rec_type;
   l_line_tbl                     oe_order_pub.line_tbl_type;
   l_action_request_tbl           oe_order_pub.Request_Tbl_Type;

   -- OUT Variables --
   l_header_rec_out               oe_order_pub.header_rec_type;
   l_header_val_rec_out           oe_order_pub.header_val_rec_type;
   l_header_adj_tbl_out           oe_order_pub.header_adj_tbl_type;
   l_header_adj_val_tbl_out       oe_order_pub.header_adj_val_tbl_type;
   l_header_price_att_tbl_out     oe_order_pub.header_price_att_tbl_type;
   l_header_adj_att_tbl_out       oe_order_pub.header_adj_att_tbl_type;
   l_header_adj_assoc_tbl_out     oe_order_pub.header_adj_assoc_tbl_type;
   l_header_scredit_tbl_out       oe_order_pub.header_scredit_tbl_type;
   l_header_scredit_val_tbl_out   oe_order_pub.header_scredit_val_tbl_type;
   l_line_tbl_out                 oe_order_pub.line_tbl_type;
   l_line_val_tbl_out             oe_order_pub.line_val_tbl_type;
   l_line_adj_tbl_out             oe_order_pub.line_adj_tbl_type;
   l_line_adj_val_tbl_out         oe_order_pub.line_adj_val_tbl_type;
   l_line_price_att_tbl_out       oe_order_pub.line_price_att_tbl_type;
   l_line_adj_att_tbl_out         oe_order_pub.line_adj_att_tbl_type;
   l_line_adj_assoc_tbl_out       oe_order_pub.line_adj_assoc_tbl_type;
   l_line_scredit_tbl_out         oe_order_pub.line_scredit_tbl_type;
   l_line_scredit_val_tbl_out     oe_order_pub.line_scredit_val_tbl_type;
   l_lot_serial_tbl_out           oe_order_pub.lot_serial_tbl_type;
   l_lot_serial_val_tbl_out       oe_order_pub.lot_serial_val_tbl_type;
   l_action_request_tbl_out       oe_order_pub.request_tbl_type;
   l_msg_index                    NUMBER;
   l_data                         VARCHAR2 (2000);
   l_loop_count                   NUMBER;
   l_debug_file                   VARCHAR2 (200);

   b_return_status                VARCHAR2 (200);
   b_msg_count                    NUMBER;
   b_msg_data                     VARCHAR2 (2000);
BEGIN
   IF (l_debug_level > 0)
   THEN
      l_debug_file := OE_DEBUG_PUB.Set_Debug_Mode ('FILE');
      oe_debug_pub.initialize;
      oe_debug_pub.setdebuglevel (l_debug_level);
      Oe_Msg_Pub.initialize;
   END IF;

   mo_global.init ('ONT');
   mo_global.set_policy_context ('S', 204);
   fnd_global.apps_initialize (user_id        => 1318,
                               resp_id        => 21623,
                               resp_appl_id   => 660);

   l_header_rec := oe_order_pub.G_MISS_HEADER_REC;
   l_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
   l_header_rec.order_type_id := 1430;
   l_header_rec.sold_to_org_id := 1005;
   l_header_rec.ship_to_org_id := 1024;
   l_header_rec.invoice_to_org_id := 1023;
   l_header_rec.sold_from_org_id := 204;
   l_header_rec.salesrep_id := -3;
   l_header_rec.price_list_id := 1000;               --p_price_list_id;--1000;
   l_header_rec.pricing_date := SYSDATE;
   l_header_rec.transactional_curr_code := 'USD';       --p_curr_code;--'USD';
   l_header_rec.flow_status_code := 'ENTERED';         --p_flow_status_code;--
   l_header_rec.cust_po_number := 'TestEnter';    -- p_po_num;--'06112009-08';
   l_header_rec.order_source_id := 0;                --p_order_source_id;--0 ;
   -- To BOOK the Sales Order
   l_action_request_tbl (1) := oe_order_pub.G_MISS_REQUEST_REC;
   l_action_request_tbl (1).request_type := oe_globals.g_book_order;
   l_action_request_tbl (1).entity_code := oe_globals.g_entity_header;

   l_line_tbl (1) := oe_order_pub.G_MISS_LINE_REC;
   l_line_tbl (1).operation := OE_GLOBALS.G_OPR_CREATE;
   l_line_tbl (1).inventory_item_id := 162744;
   l_line_tbl (1).ordered_quantity := 5;
   l_line_tbl (1).ship_to_org_id := 1024;
   l_line_tbl (1).tax_code := 'Location';

   DBMS_OUTPUT.put_line ('Calling API');
   oe_order_pub.Process_Order (
      p_api_version_number       => l_api_version_number,
      p_header_rec               => l_header_rec,
      p_line_tbl                 => l_line_tbl,
      p_action_request_tbl       => l_action_request_tbl,
      --OUT variables
      x_header_rec               => l_header_rec_out,
      x_header_val_rec           => l_header_val_rec_out,
      x_header_adj_tbl           => l_header_adj_tbl_out,
      x_header_adj_val_tbl       => l_header_adj_val_tbl_out,
      x_header_price_att_tbl     => l_header_price_att_tbl_out,
      x_header_adj_att_tbl       => l_header_adj_att_tbl_out,
      x_header_adj_assoc_tbl     => l_header_adj_assoc_tbl_out,
      x_header_scredit_tbl       => l_header_scredit_tbl_out,
      x_header_scredit_val_tbl   => l_header_scredit_val_tbl_out,
      x_line_tbl                 => l_line_tbl_out,
      x_line_val_tbl             => l_line_val_tbl_out,
      x_line_adj_tbl             => l_line_adj_tbl_out,
      x_line_adj_val_tbl         => l_line_adj_val_tbl_out,
      x_line_price_att_tbl       => l_line_price_att_tbl_out,
      x_line_adj_att_tbl         => l_line_adj_att_tbl_out,
      x_line_adj_assoc_tbl       => l_line_adj_assoc_tbl_out,
      x_line_scredit_tbl         => l_line_scredit_tbl_out,
      x_line_scredit_val_tbl     => l_line_scredit_val_tbl_out,
      x_lot_serial_tbl           => l_lot_serial_tbl_out,
      x_lot_serial_val_tbl       => l_lot_serial_val_tbl_out,
      x_action_request_tbl       => l_action_request_tbl_out,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data);

   IF l_return_status = FND_API.G_RET_STS_SUCCESS
   THEN
      DBMS_OUTPUT.put_line ('API Return status is success ');
      COMMIT;
   ELSE
      DBMS_OUTPUT.put_line ('Return status failure ');

      IF (l_debug_level > 0)
      THEN
         DBMS_OUTPUT.put_line ('failure');
      END IF;

      ROLLBACK;
   END IF;

   -- Display Return Status
   IF (l_debug_level > 0)
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'process ORDER ret status IS: ' || l_return_status);
      DBMS_OUTPUT.PUT_LINE ('process ORDER msg data IS: ' || l_msg_data);
      DBMS_OUTPUT.PUT_LINE (
            'header.order_number IS: '
         || TO_CHAR (l_header_rec_out.order_number));
      DBMS_OUTPUT.PUT_LINE (
         'header.header_id IS: ' || l_header_rec_out.header_id);
      DBMS_OUTPUT.PUT_LINE (
         'header.order_source_id IS: ' || l_header_rec_out.order_source_id);
      DBMS_OUTPUT.PUT_LINE (
         'header.flow_status_code IS: ' || l_header_rec_out.flow_status_code);
   END IF;

   --Display ERROR Messages
   IF (l_debug_level > 0)
   THEN
      FOR i IN 1 .. l_msg_count
      LOOP
         l_data := oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
         DBMS_OUTPUT.put_line (i || ') ' || l_data);
      END LOOP;
   END IF;

   IF (l_debug_level > 0)
   THEN
      OE_DEBUG_PUB.DEBUG_OFF;
   END IF;
END;