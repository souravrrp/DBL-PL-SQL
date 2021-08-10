/* Formatted on 9/2/2020 3:37:43 PM (QP5 v5.287) */
DECLARE
   l_open_quantity        NUMBER := 0;
   l_reserved_quantity    NUMBER := 0;
   l_mtl_sales_order_id   NUMBER;
   l_return_status        VARCHAR2 (1);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2 (240);

   l_rsv_rec              inv_reservation_global.mtl_reservation_rec_type;
   l_rsv_tbl              inv_reservation_global.mtl_reservation_tbl_type;
   l_count                NUMBER;
   l_x_error_code         NUMBER;
   l_lock_records         VARCHAR2 (1);
   l_sort_by_req_date     NUMBER;
   l_converted_qty        NUMBER;
   l_inventory_item_id    NUMBER;
   l_order_quantity_uom   VARCHAR2 (30);

   P_HEADER_ID            NUMBER := 6220;
   P_LINE_ID              NUMBER := 4850;
BEGIN
   l_mtl_sales_order_id :=
      OE_HEADER_UTIL.Get_Mtl_Sales_Order_Id (p_header_id => p_header_id);

   l_rsv_rec.demand_source_header_id := l_mtl_sales_order_id;
   l_rsv_rec.demand_source_line_id := p_line_id;
   l_rsv_rec.organization_id := NULL;

   INV_RESERVATION_PUB.QUERY_RESERVATION_OM_HDR_LINE (
      p_api_version_number          => 1.0,
      p_init_msg_lst                => fnd_api.g_true,
      x_return_status               => l_return_status,
      x_msg_count                   => l_msg_count,
      x_msg_data                    => l_msg_data,
      p_query_input                 => l_rsv_rec,
      x_mtl_reservation_tbl         => l_rsv_tbl,
      x_mtl_reservation_tbl_count   => l_count,
      x_error_code                  => l_x_error_code,
      p_lock_records                => l_lock_records,
      p_sort_by_req_date            => l_sort_by_req_date);

   BEGIN
      SELECT order_quantity_uom, inventory_item_id
        INTO l_order_quantity_uom, l_inventory_item_id
        FROM oe_order_lines_all
       WHERE line_id = p_line_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_order_quantity_uom := NULL;
   END;

   FOR I IN 1 .. l_rsv_tbl.COUNT
   LOOP
      l_rsv_rec := l_rsv_tbl (I);

      IF NVL (l_order_quantity_uom, l_rsv_rec.reservation_uom_code) <>
            l_rsv_rec.reservation_uom_code
      THEN
         l_converted_qty :=
            Oe_Order_Misc_Util.convert_uom (l_inventory_item_id,
                                            l_rsv_rec.reservation_uom_code,
                                            l_order_quantity_uom,
                                            l_rsv_rec.reservation_quantity);

         l_reserved_quantity := l_reserved_quantity + l_converted_qty;
      ELSE
         l_reserved_quantity :=
            l_reserved_quantity + l_rsv_rec.reservation_quantity;
      END IF;
   END LOOP;

   DBMS_OUTPUT.PUT_LINE ('RESERVED QUANTITY :' || l_reserved_quantity);
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
END;