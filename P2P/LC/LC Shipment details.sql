SELECT m.org_id,
          m.shipment_id,
          m.shipment_number,
          m.shipment_id_phy shipment_number_doc,
          l.contract_lc_no lc_number,
          NVL (order_no, style_no) order_number,
          style_no style_number,
          product_size,
          d.product_qty,
          product_uom,
          product_color,
          o.auto_order_no order_id,
          product_no item_number,
          product_name item_description,
          com_invoice_no,
          m.customer_id,
          m.bl_no,
          m.shipment_date
          --,m.*
          --,com.*
          --,d.*
          --,o.*
          ,l.*
     FROM xx_explc_shipment_mst m,
          xx_explc_shipment_comm com,
          xx_explc_shipment_dtl d,
          xx_explc_order_info o,
          xx_explc_master_info l,
          (SELECT meaning product_name, lookup_code
             FROM fnd_lookup_values_vl
            WHERE lookup_type = 'FINISHED_GARMENTS') p
    WHERE     m.shipment_id = com.shipment_id
          AND com.comm_invoice_id = d.comm_invoice_id
          AND d.auto_order_no = o.auto_order_no(+)
          AND m.explc_master_id = l.explc_master_id
          AND d.product_no = p.lookup_code(+);