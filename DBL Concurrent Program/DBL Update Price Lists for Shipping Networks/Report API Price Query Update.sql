SELECT x.org_id,
                  x.segment1,
                  x.item_id,
                  NVL((x.unit_price * x.rate ),XXDBL.xxdbl_fnc_get_item_cost (x.ship_to_organization_id,x.item_id,TO_CHAR(X.approved_date,'MON-YY')))unit_price,
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