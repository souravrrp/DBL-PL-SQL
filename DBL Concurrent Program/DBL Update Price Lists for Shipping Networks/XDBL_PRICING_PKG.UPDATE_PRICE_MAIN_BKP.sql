--XXDBL_PRICING_PKG.UPDATE_PRICE_MAIN
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_pricing_pkg
AS
   g_request_id     NUMBER;
   g_resp_id        NUMBER;
   g_resp_appl_id   NUMBER;
   g_user_id        NUMBER;
   g_login_id       NUMBER;

   PROCEDURE writelog (p_text IN VARCHAR2)
   IS
   BEGIN
      apps.fnd_file.put_line (apps.fnd_file.LOG, SUBSTRB (p_text, 1, 255));
   END writelog;

   PROCEDURE log_errors (p_request_id          IN NUMBER,
                         p_resp_id             IN NUMBER,
                         p_resp_appl_id        IN NUMBER,
                         p_org_id              IN NUMBER,
                         p_price_list_id       IN NUMBER,
                         p_price_list_name     IN VARCHAR2,
                         p_item_id             IN NUMBER,
                         p_organization_id     IN NUMBER,
                         p_error_type          IN VARCHAR2,
                         p_error_message       IN VARCHAR2,
                         p_creation_date       IN DATE,
                         p_created_by          IN NUMBER,
                         p_last_update_date    IN DATE,
                         p_last_updated_by     IN NUMBER,
                         p_last_update_login   IN NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO xxdbl_price_list_update_errors (request_id,
                                                  resp_id,
                                                  resp_appl_id,
                                                  org_id,
                                                  price_list_id,
                                                  price_list_name,
                                                  item_id,
                                                  organization_id,
                                                  ERROR_TYPE,
                                                  error_message,
                                                  creation_date,
                                                  created_by,
                                                  last_update_date,
                                                  last_updated_by,
                                                  last_update_login)
          VALUES (p_request_id,
                  p_resp_id,
                  p_resp_appl_id,
                  p_org_id,
                  p_price_list_id,
                  p_price_list_name,
                  p_item_id,
                  p_organization_id,
                  p_error_type,
                  p_error_message,
                  p_creation_date,
                  p_created_by,
                  p_last_update_date,
                  p_last_updated_by,
                  p_last_update_login);

      COMMIT;
   END log_errors;

   PROCEDURE update_price_main (p_errbuff              OUT VARCHAR2,
                                p_retcode              OUT VARCHAR2,
                                p_po_approve_date   IN     VARCHAR2)
   IS
      --- DBL Update Price Lists for Shipping Networks --
      -- XXDBL_UPDATE_PROCE_LISTS ---
      CURSOR cur_po_items (
         cp_approve_date IN DATE)
      IS
           SELECT x.org_id,
                  x.segment1,
                  x.item_id,
                  x.unit_price * x.rate unit_price,
                  x.uom_code,
                  x.unit_meas_lookup_code,
                  x.ship_to_organization_id,
                  si.segment1 item
             FROM (  SELECT ph.org_id,
                            ph.segment1,
                            pl.item_id,
                            ph.currency_code,
                            NVL (ph.rate, 1) rate,
                            pl.unit_price,
                            uom.uom_code,
                            pl.unit_meas_lookup_code,
                            ll.ship_to_organization_id,
                            RANK ()
                               OVER (
                                  PARTITION BY pl.item_id,
                                               ll.ship_to_organization_id
                                  ORDER BY ph.approved_date DESC)
                               rnk
                       FROM po_headers_all ph,
                            po_lines_all pl,
                            po_line_locations_all ll,
                            mtl_units_of_measure uom
                      WHERE 1 = 1
                            AND TRUNC (ph.approved_date) =
                                  TRUNC (cp_approve_date)
                            AND pl.unit_meas_lookup_code = uom.unit_of_measure(+)
                            AND NVL (ph.cancel_flag, 'N') = 'N'
                            AND ph.authorization_status = 'APPROVED'
                            AND ph.po_header_id = pl.po_header_id
                            AND NVL (pl.cancel_flag, 'N') = 'N'
                            AND pl.po_line_id = ll.po_line_id
                            AND NVL (ll.cancel_flag, 'N') = 'N'
                   ORDER BY pl.item_id,
                            ll.ship_to_organization_id,
                            ph.approved_date) x,
                  mtl_system_items si
            WHERE     x.rnk = 1
                  AND x.item_id = si.inventory_item_id
                  AND x.ship_to_organization_id = si.organization_id
         ORDER BY x.org_id;

      CURSOR cur_ship_net (
         cp_inv_org_id IN NUMBER)
      IS
           SELECT DISTINCT snv.pricelist_id, qlh.NAME pricelist_name
             FROM mtl_shipping_network_view snv, qp_list_headers qlh
            WHERE snv.from_organization_id = cp_inv_org_id
                  AND snv.pricelist_id = qlh.list_header_id
         ORDER BY qlh.NAME;

      gpr_return_status             VARCHAR2 (1) := NULL;
      gpr_msg_count                 NUMBER := 0;
      gpr_msg_data                  VARCHAR2 (2000);
      gpr_price_list_rec            qp_price_list_pub.price_list_rec_type;
      gpr_price_list_val_rec        qp_price_list_pub.price_list_val_rec_type;
      gpr_price_list_line_tbl       qp_price_list_pub.price_list_line_tbl_type;
      gpr_price_list_line_val_tbl   qp_price_list_pub.price_list_line_val_tbl_type;
      gpr_qualifiers_tbl            qp_qualifier_rules_pub.qualifiers_tbl_type;
      gpr_qualifiers_val_tbl        qp_qualifier_rules_pub.qualifiers_val_tbl_type;
      gpr_pricing_attr_tbl          qp_price_list_pub.pricing_attr_tbl_type;
      gpr_pricing_attr_val_tbl      qp_price_list_pub.pricing_attr_val_tbl_type;
      ppr_price_list_rec            qp_price_list_pub.price_list_rec_type;
      ppr_price_list_val_rec        qp_price_list_pub.price_list_val_rec_type;
      ppr_price_list_line_tbl       qp_price_list_pub.price_list_line_tbl_type;
      ppr_price_list_line_val_tbl   qp_price_list_pub.price_list_line_val_tbl_type;
      ppr_qualifiers_tbl            qp_qualifier_rules_pub.qualifiers_tbl_type;
      ppr_qualifiers_val_tbl        qp_qualifier_rules_pub.qualifiers_val_tbl_type;
      ppr_pricing_attr_tbl          qp_price_list_pub.pricing_attr_tbl_type;
      ppr_pricing_attr_val_tbl      qp_price_list_pub.pricing_attr_val_tbl_type;
      k                             NUMBER := 1;
      j                             NUMBER := 1;
      l_count                       NUMBER := 0;
      l_count_s                     NUMBER := 0;
      l_count_e                     NUMBER := 0;
      --
      l_approve_date                DATE;
      l_message                     VARCHAR2 (4000);
   BEGIN
      p_retcode := '0';
      p_errbuff := '';
      g_request_id := fnd_global.conc_request_id;
      g_resp_id := fnd_global.resp_id;
      g_resp_appl_id := fnd_global.resp_appl_id;
      g_user_id := fnd_global.user_id;
      g_login_id := fnd_global.login_id;
      writelog ('Input p_po_approve_date : ' || p_po_approve_date);
      l_approve_date := fnd_date.canonical_to_date (p_po_approve_date);
      writelog('Converted l_approve_date : '
               || TO_CHAR (l_approve_date, 'DD-MON-RRRR'));

      FOR r1 IN cur_po_items (l_approve_date)
      LOOP
         writelog ('ORG ID: ' || r1.org_id);
         mo_global.init ('PO');
         mo_global.set_policy_context ('S', r1.org_id);

         FOR r2 IN cur_ship_net (r1.ship_to_organization_id)
         LOOP
            SELECT COUNT (1)
              INTO l_count
              FROM qp_list_lines_v l
             WHERE     l.list_header_id = r2.pricelist_id
                   AND l.product_attribute_context = 'ITEM'
                   AND l.product_attr_value = TO_CHAR (r1.item_id)
                   AND l.arithmetic_operator = 'UNIT_PRICE';

            writelog(   'Price list line for price list '
                     || r2.pricelist_name
                     || '; pricelist id '
                     || r2.pricelist_id
                     || '; item  '
                     || r1.item
                     || '; item id '
                     || r1.item_id
                     || ', inv org id '
                     || r1.ship_to_organization_id
                     || ', new unit price '
                     || r1.unit_price
                     || ', check count '
                     || l_count);

            --writelog ('Debug 100');
            IF 1 = 1
            THEN
               /*l_count > 0
               THEN
                  writelog (   'Updating Price list line for price list '
                            || r2.pricelist_name
                            || '; item id '
                            || r1.item_id
                            || ', inv org id '
                            || r1.ship_to_organization_id
                            || ', new unit price '
                            || r1.unit_price
                           );

                  UPDATE qp_list_lines l
                     SET l.operand = r1.unit_price
                   WHERE l.list_header_id = r2.pricelist_id
                     AND l.inventory_item_id = r1.item_id
                     AND l.organization_id = r1.ship_to_organization_id
                     AND l.arithmetic_operator = 'UNIT_PRICE'
                     AND l.operand != r1.unit_price;

                  j := SQL%ROWCOUNT;
                  writelog (j || ' rows updated');
                  l_count_s := NVL (l_count_s, 0) + 1;
               ELSE
               */
               gpr_price_list_rec.list_header_id := r2.pricelist_id;
               gpr_price_list_rec.NAME := r2.pricelist_name;
               --gpr_price_list_rec.list_type_code := 'PRL';
               --gpr_price_list_rec.description := 'TEST PRICE LIST';
               gpr_price_list_rec.operation := qp_globals.g_opr_update;
               -- create the price list line rec ---
               k := 1;
               gpr_price_list_line_tbl (k).list_header_id := r2.pricelist_id;
               -- Enter the list_header_id from qp_list_headers
               gpr_price_list_line_tbl (k).list_line_id := fnd_api.g_miss_num;
               gpr_price_list_line_tbl (k).list_line_type_code := 'PLL';
               gpr_price_list_line_tbl (k).operation :=
                  qp_globals.g_opr_create;

               --writelog ('Debug 110');
               IF l_count > 0
               THEN
                  FOR i
                     IN (SELECT l.list_line_id, l.product_uom_code
                           FROM qp_list_lines_v l
                          WHERE l.list_header_id = r2.pricelist_id
                                AND l.product_attribute_context = 'ITEM'
                                AND l.product_attr_value =
                                      TO_CHAR (r1.item_id)
                                AND l.arithmetic_operator = 'UNIT_PRICE')
                  LOOP
                     gpr_price_list_line_tbl (k).list_line_id :=
                        i.list_line_id;
                     writelog (
                        'UPDATE MODE: list_line_id = ' || i.list_line_id);
                  END LOOP;

                  gpr_price_list_line_tbl (k).operation :=
                     qp_globals.g_opr_update;
               END IF;

               gpr_price_list_line_tbl (k).operand := r1.unit_price;
               --Enter the Unit Price
               gpr_price_list_line_tbl (k).arithmetic_operator := 'UNIT_PRICE';
               --gpr_price_list_line_tbl (k).inventory_item_id := r1.item_id;
               --gpr_price_list_line_tbl (k).organization_id := r1.ship_to_organization_id;
               --- Pricing Attributes ---
               --writelog ('Debug 120');
               j := 1;
               gpr_pricing_attr_tbl (j).pricing_attribute_id :=
                  fnd_api.g_miss_num;
               gpr_pricing_attr_tbl (j).list_line_id := fnd_api.g_miss_num;
               gpr_pricing_attr_tbl (j).product_attribute_context := 'ITEM';
               gpr_pricing_attr_tbl (j).product_attribute :=
                  'PRICING_ATTRIBUTE1';
               gpr_pricing_attr_tbl (j).product_attr_value :=
                  TO_CHAR (r1.item_id);
               gpr_pricing_attr_tbl (j).product_uom_code := r1.uom_code;
               gpr_pricing_attr_tbl (j).excluder_flag := 'N';
               gpr_pricing_attr_tbl (j).attribute_grouping_no := 1;
               gpr_pricing_attr_tbl (j).price_list_line_index := 1;

               --writelog ('Debug 130');
               IF l_count > 0
               THEN
                  FOR n
                     IN (SELECT *
                           FROM qp_pricing_attributes qppr
                          WHERE gpr_price_list_line_tbl (k).list_line_id =
                                   qppr.list_line_id)
                  LOOP
                     gpr_pricing_attr_tbl (j).pricing_attribute_id :=
                        n.pricing_attribute_id;
                     gpr_pricing_attr_tbl (j).list_line_id := n.list_line_id;
                     gpr_pricing_attr_tbl (j).product_attribute_context :=
                        n.product_attribute_context;
                     gpr_pricing_attr_tbl (j).product_attribute :=
                        n.product_attribute;
                     gpr_pricing_attr_tbl (j).product_attr_value :=
                        n.product_attr_value;
                     gpr_pricing_attr_tbl (j).product_uom_code :=
                        n.product_uom_code;
                     gpr_pricing_attr_tbl (j).excluder_flag := n.excluder_flag;
                     writelog('UPDATE MODE: pricing_attribute_id = '
                              || n.pricing_attribute_id);
                     EXIT;
                  END LOOP;
               END IF;

               --writelog ('Debug 140');
               gpr_pricing_attr_tbl (j).operation :=
                  gpr_price_list_line_tbl (k).operation;
               writelog(   'Calling qp_price_list_pub API for price list '
                        || r2.pricelist_name
                        || '; item id '
                        || r1.item_id
                        || ', inv org id '
                        || r1.ship_to_organization_id
                        || ', new unit price '
                        || r1.unit_price);
               qp_price_list_pub.process_price_list (
                  p_api_version_number        => 1,
                  p_init_msg_list             => fnd_api.g_true,
                  p_return_values             => fnd_api.g_true,
                  p_commit                    => fnd_api.g_false,
                  x_return_status             => gpr_return_status,
                  x_msg_count                 => gpr_msg_count,
                  x_msg_data                  => gpr_msg_data,
                  p_price_list_rec            => gpr_price_list_rec,
                  p_price_list_line_tbl       => gpr_price_list_line_tbl,
                  p_pricing_attr_tbl          => gpr_pricing_attr_tbl,
                  x_price_list_rec            => ppr_price_list_rec,
                  x_price_list_val_rec        => ppr_price_list_val_rec,
                  x_price_list_line_tbl       => ppr_price_list_line_tbl,
                  x_price_list_line_val_tbl   => ppr_price_list_line_val_tbl,
                  x_qualifiers_tbl            => ppr_qualifiers_tbl,
                  x_qualifiers_val_tbl        => ppr_qualifiers_val_tbl,
                  x_pricing_attr_tbl          => ppr_pricing_attr_tbl,
                  x_pricing_attr_val_tbl      => ppr_pricing_attr_val_tbl);
               writelog(   'API result gpr_return_status = '
                        || gpr_return_status
                        || '; gpr_msg_count = '
                        || gpr_msg_count/*|| ', gpr_msg_data = '
                                        || SUBSTRB (gpr_msg_data, 1, 50)*/
               );

               IF NVL (gpr_return_status, 'E') != 'S'
               THEN
                  l_count_e := NVL (l_count_e, 0) + 1;
                  writelog ('API Errors: ');
                  l_message :=
                     SUBSTRB (
                           'API Errors: gpr_return_status = '
                        || gpr_return_status
                        || '; gpr_msg_count = '
                        || gpr_msg_count
                        || '; gpr_msg_data = '
                        || gpr_msg_data,
                        1,
                        4000);

                  IF NVL (gpr_msg_count, 0) > 0
                  THEN
                     FOR k IN 1 .. gpr_msg_count
                     LOOP
                        gpr_msg_data :=
                           oe_msg_pub.get (p_msg_index => k, p_encoded => 'F');
                        writelog (k || ') ' || gpr_msg_data);
                        l_message :=
                           SUBSTRB (l_message || '| ' || gpr_msg_data,
                                    1,
                                    4000);
                     END LOOP;
                  END IF;

                  oe_msg_pub.delete_msg;
                  log_errors (
                     p_request_id          => g_request_id,
                     p_resp_id             => g_resp_id,
                     p_resp_appl_id        => g_resp_appl_id,
                     p_org_id              => r1.org_id,
                     p_price_list_id       => r2.pricelist_id,
                     p_price_list_name     => r2.pricelist_name,
                     p_item_id             => r1.item_id,
                     p_organization_id     => r1.ship_to_organization_id,
                     p_error_type          => 'API',
                     p_error_message       => l_message,
                     p_creation_date       => SYSDATE,
                     p_created_by          => g_user_id,
                     p_last_update_date    => SYSDATE,
                     p_last_updated_by     => g_user_id,
                     p_last_update_login   => g_login_id);
               ELSE
                  writelog('Price List updated successfully , added lines '
                           || ppr_price_list_line_tbl.COUNT);
                  l_count_s := NVL (l_count_s, 0) + 1;
               END IF;
            END IF;
         END LOOP cur_ship_net;
      END LOOP cur_po_items;

      writelog ('No of errorrs: ' || l_count_e);
      writelog ('No of success: ' || l_count_s);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_retcode := '2';
         p_errbuff := 'ERROR: unknown error ' || SQLERRM;
         writelog (p_errbuff);
   END update_price_main;
END xxdbl_pricing_pkg;
/
