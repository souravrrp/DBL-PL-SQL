/* Formatted on 5/22/2021 11:55:36 AM (QP5 v5.287) */
DECLARE
   l_count                        NUMBER;

   l_api_version_number           NUMBER := 1;

   l_return_status                VARCHAR2 (2000);

   l_msg_count                    NUMBER;

   l_msg_data                     VARCHAR2 (2000);

   l_msg_index                    NUMBER;

   API_ERROR                      EXCEPTION;

   X_DEBUG_FILE                   VARCHAR2 (100);



   p_init_msg_list                VARCHAR2 (10) := FND_API.G_FALSE;

   p_return_values                VARCHAR2 (10) := FND_API.G_FALSE;

   p_action_commit                VARCHAR2 (10) := FND_API.G_FALSE;

   l_header_rec                   OE_ORDER_PUB.Header_Rec_Type;

   l_line_tbl                     OE_ORDER_PUB.Line_Tbl_Type;

   l_action_request_tbl           OE_ORDER_PUB.Request_Tbl_Type;

   l_header_adj_tbl               OE_ORDER_PUB.Header_Adj_Tbl_Type;

   l_line_adj_tbl                 OE_ORDER_PUB.line_adj_tbl_Type;

   l_header_scr_tbl               OE_ORDER_PUB.Header_Scredit_Tbl_Type;

   l_line_scredit_tbl             OE_ORDER_PUB.Line_Scredit_Tbl_Type;

   l_request_rec                  OE_ORDER_PUB.Request_Rec_Type;



   /***OUT VARIABLES FOR PROCESS_ORDER API***************************/

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
BEGIN
   DBMS_OUTPUT.ENABLE (1000000);

   MO_GLOBAL.INIT ('ONT');

   MO_GLOBAL.SET_POLICY_CONTEXT ('S', 126);            ----–>Vision Operations

   FND_GLOBAL.APPS_INITIALIZE (5958, 53292, 660);        --(1318, 21623, 660);
   ----–>User,Resp,Appl

   OE_MSG_PUB.INITIALIZE;

   OE_DEBUG_PUB.INITIALIZE;

   X_DEBUG_FILE := OE_DEBUG_PUB.SET_DEBUG_MODE ('FILE');

   OE_DEBUG_PUB.SETDEBUGLEVEL (5);

   DBMS_OUTPUT.put_line ('

                           ===============================');

   DBMS_OUTPUT.put_line ('Start Order Creation Process');

   DBMS_OUTPUT.put_line ('
                      ===============================');



   ----–> Header Records

   L_HEADER_REC := OE_ORDER_PUB.G_MISS_HEADER_REC;

   L_HEADER_REC.operation := OE_GLOBALS.G_OPR_CREATE;

   L_HEADER_REC.freight_carrier_code := 'COMPANY'; --–h1.frieght_code;– 'DHL';
   
   L_HEADER_REC.freight_terms_code := 'COMPANY'; --–h1.frieght_code;– 'DHL';

   L_HEADER_REC.pricing_date := SYSDATE;

   L_HEADER_REC.sold_to_org_id := 2660;
   --–1006;
   ----–>Computer Service and Rentals(1006)

   L_HEADER_REC.price_list_id := 54178;
   ----–>Corporate

   L_HEADER_REC.ordered_date := SYSDATE;

   L_HEADER_REC.sold_from_org_id := 126;

   L_HEADER_REC.order_type_id := 1002;

   L_HEADER_REC.salesrep_id := 100002052;

   L_HEADER_REC.order_source_id := 0;
   ----–>Corporate

   --–> Line Records

   L_LINE_TBL (1) := OE_ORDER_PUB.G_MISS_LINE_REC;

   L_LINE_TBL (1).OPERATION := OE_GLOBALS.G_OPR_CREATE;

   l_line_tbl (1).header_id := l_header_rec_out.header_id;


   l_line_tbl (1).price_list_id := 54178;                        --–>Corporate

   l_line_tbl (1).inventory_item_id := 188961;                     --–>AS54888

   l_line_tbl (1).ordered_quantity := 5;
   --–3;

   l_line_tbl (1).ship_to_org_id := 93198;
   --–1026;                                                               --–>

   l_line_tbl (1).line_type_id := 1001;
   --h1.line_type_id;
   -- 1421;

   l_line_tbl (1).ship_from_org_id := 152;
   --–207;
   --–8583;
   --–9324;
   --–h1.ship_from_org_id;
   --– 207;

   l_line_tbl (1).salesrep_id := 100002052;

   --l_line_tbl (1).shipping_method_code := 'DHL';
   --–h1.shiping_code;
   --– 'DHL';

   l_line_tbl (1).freight_terms_code := 'COMPANY'; --–h1.frieght_code;– 'DHL';
   --l_line_tbl (1).freight_carrier_code := 'COMPANY'; --–h1.frieght_code;– 'DHL';
   --l_line_tbl(1).tax_code := 'Location';



   --–>INITIALIZE ACTION REQUEST RECORD

   l_action_request_tbl (1) := OE_ORDER_PUB.G_MISS_REQUEST_REC;

   l_action_request_tbl (1).request_type := oe_globals.g_book_order;

   l_action_request_tbl (1).entity_code := oe_globals.g_entity_header;



   --–> Calling the API

   OE_ORDER_PUB.PROCESS_ORDER (
      p_api_version_number       => 1.0,
      p_init_msg_list            => fnd_api.g_false,
      p_return_values            => fnd_api.g_false,
      p_action_commit            => fnd_api.g_false,
      x_return_status            => l_return_status,
      x_msg_count                => l_msg_count,
      x_msg_data                 => l_msg_data,
      p_header_rec               => l_header_rec,
      p_line_tbl                 => l_line_tbl,
      p_action_request_tbl       => l_action_request_tbl,
      --— OUT PARAMETERS

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
      x_action_request_tbl       => l_action_request_tbl_out);
   COMMIT;



   IF l_return_status = FND_API.G_RET_STS_SUCCESS
   THEN
      DBMS_OUTPUT.put_line (
            'Oracle Order is Created, Order Header ID : '
         || l_header_rec_out.header_id
         --|| 'Oracle Order is Created, Order Line ID : ' || l_line_tbl_out.line_id
         || ', Order Number Is : '
         || l_header_rec_out.order_number);

      DBMS_OUTPUT.put_line (
            '
                      Sales Order is Created And Order Number Is : '
         || l_header_rec_out.order_number);

      --DBMS_OUTPUT.put_line ('the order is' || v_order);

      DBMS_OUTPUT.put_line ('============================');

      DBMS_OUTPUT.put_line ('
                       Order Creation is Comleted');

      DBMS_OUTPUT.put_line ('============================');
   ELSE
      DBMS_OUTPUT.put_line ('

                      Order Creation Status Failure');

      RAISE API_ERROR;

      ROLLBACK;
   END IF;
--–> ——————————————————

--–> HANDLE EXCEPTIONS

EXCEPTION
   WHEN API_ERROR
   THEN
      FOR i IN 1 .. l_msg_count
      LOOP
         OE_MSG_PUB.GET (p_msg_index       => i,
                         p_encoded         => Fnd_Api.G_FALSE,
                         p_data            => l_msg_data,
                         p_msg_index_out   => l_msg_index);

         DBMS_OUTPUT.put_line ('message is: ' || l_msg_data);

         DBMS_OUTPUT.put_line ('message index is: ' || l_msg_index);
      END LOOP;
   WHEN OTHERS
   THEN
      FOR i IN 1 .. l_msg_count
      LOOP
         OE_MSG_PUB.GET (p_msg_index       => i,
                         p_encoded         => Fnd_Api.G_FALSE,
                         p_data            => l_msg_data,
                         p_msg_index_out   => l_msg_index);

         DBMS_OUTPUT.put_line ('message is: ' || l_msg_data);

         DBMS_OUTPUT.put_line ('message index is: ' || l_msg_index);
      END LOOP;
END;