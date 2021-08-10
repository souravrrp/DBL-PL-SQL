/* Formatted on 6/4/2020 5:22:29 PM (QP5 v5.287) */
SELECT *
  FROM (SELECT x1.*,
               wdd_dfv.*,
               wnd_dfv.*,
               requested_quantity_value DELIVERY_VALUE
          FROM (SELECT ecc_spec_id,
                       line_number,
                       schedule_ship_date,
                       subinventory,
                       locator,
                       revision,
                       lot_number,
                       request_date,
                       order_number,
                       ordered_date,
                       delivery_detail_id,
                       delivery_id,
                       delivery_name,
                       delivery_name_disp,
                       released_status,
                       released_status_bucket,
                       exceptionid_detail detail_exception_id,
                       NVL (exceptionid_detail, exceptionid_delivery)
                          delivery_exception_id,
                       DECODE (
                          NVL (exceptionid_detail, exceptionid_delivery),
                          NULL, 'No',
                          'Yes')
                          delivery_exception_flag,
                       NVL (NVL (exceptionid_detail, exceptionid_delivery),
                            exceptionid_trip)
                          trip_exception_id,
                       msiv1.concatenated_segments item,
                       msiv1.inventory_item_id,
                       a.organization_id,
                       organization_code,
                       quantity,
                       quantity2,
                       ship_from_country,
                       ship_to_country,
                       ship_from_location,
                       ship_to_location,
                       hp.party_name customer,
                       conv_gross_weight gross_weight,
                       volume detail_volume,
                       a.weight_uom_code,
                       a.volume_uom_code,
                       requested_quantity_value,
                       trip_name,
                       trip_name_disp,
                       flv2.meaning planned_flag,
                       initial_pickup_date,
                       ultimate_dropoff_date,
                       flv3.meaning fob_code,
                       waybill,
                       delivery_gross_weight,
                       delivery_gross_weight_uom,
                       delivery_net_weight,
                       delivery_net_weight_uom,
                       delivery_volume,
                       delivery_volume_uom,
                       confirm_date,
                       flv4.meaning trip_status,
                       vehicle_number,
                       order_type,
                       flv5.meaning delivery_status,
                       released_status_flag,
                       DECODE (released_status_flag,
                               'C', 'Complete',
                               'D', 'Canceled',
                               'Not Complete and Not Cancelled')
                          fulfill_status,
                       flv6.meaning ship_method,
                       flv7.meaning service_level,
                       flv8.meaning mode_of_transport,
                       flv9.meaning freight_terms_code,
                       NVL (hp1.party_name, 'Unassigned') Carrier,
                       hp1.party_name Carrier_disp,
                       trip_id,
                       CASE
                          WHEN    (NVL (hp1.party_name, 'Unassigned') =
                                      'Unassigned')
                               OR (delivery_name = 'Unassigned')
                               OR (trip_name = 'Unassigned')
                               OR (exceptionid_detail IS NOT NULL)
                               OR (hold_flag IS NOT NULL)
                          THEN
                             'ecc_warning'
                          ELSE
                             'ecc_blank'
                       END
                          detail_alert_flag,
                       CASE
                          WHEN    (NVL (hp1.party_name, 'Unassigned') =
                                      'Unassigned')
                               OR (trip_name = 'Unassigned')
                               OR (NVL (exceptionid_detail,
                                        exceptionid_delivery)
                                      IS NOT NULL)
                               OR (hold_flag IS NOT NULL)
                          THEN
                             'ecc_warning'
                          ELSE
                             'ecc_blank'
                       END
                          delivery_alert_flag,
                       CASE
                          WHEN    (NVL (hp1.party_name, 'Unassigned') =
                                      'Unassigned')
                               OR (exceptionid_trip IS NOT NULL)
                               OR (hold_flag IS NOT NULL)
                          THEN
                             'ecc_warning'
                          ELSE
                             'ecc_blank'
                       END
                          trip_alert_flag,
                       inv_ecc_outbound_util_pvt.get_lookup_meaning (
                          DECODE (
                             exceptionid_detail,
                             NULL, DECODE (
                                      exceptionid_delivery,
                                      NULL, DECODE (exceptionid_trip,
                                                    NULL, 'N',
                                                    'Y'),
                                      'Y'),
                             'Y'),
                          'YES_NO',
                          0,
                          a.language)
                          exception_flag,
                       DECODE (hold_flag, 'Y', 'delete_16_full', 'ecc_blank')
                          hold_flag,
                       flv10.meaning otm_planning_status,
                       flv11.meaning shipment_priority_name,
                       shipping_instructions,
                       stop_sequence_number,
                       TRIM (wave_name) wave_name,
                       a.language
                  FROM (SELECT wdd.delivery_detail_id ecc_spec_id,
                               wdd.source_header_number order_number,
                               ooha.ordered_date ordered_date,
                               wdd.source_line_number line_number,
                               NVL (wnd.initial_pickup_date,
                                    wdd.date_scheduled)
                                  schedule_ship_date,
                               wdd.subinventory,
                               mil.concatenated_segments locator,
                               wdd.revision,
                               wdd.lot_number,
                               wdd.date_requested request_date,
                               wdd.delivery_detail_id,
                               wnd.delivery_id delivery_id,
                               NVL (wnd.name, 'Unassigned') delivery_name,
                               wnd.name delivery_name_disp,
                               flv1.meaning released_status,
                               (CASE
                                   WHEN    wdd.replenishment_status IN
                                              ('R', 'C')
                                        OR wdd.released_status = 'S'
                                   THEN
                                      5
                                   WHEN wdd.released_status IN ('R', 'B')
                                   THEN
                                      3
                                   WHEN wdd.released_status = 'Y'
                                   THEN
                                      7
                                   WHEN wdd.released_status = 'C'
                                   THEN
                                      9
                                END)
                                  released_status_bucket,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.delivery_detail_id =
                                              wdd.delivery_detail_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_detail,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.assigned_delivery_id =
                                              wnd.delivery_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_delivery,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.trip_id = wt.trip_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_trip,
                               wdd.organization_id,
                               mp.organization_code organization_code,
                               CASE
                                  WHEN     wdd.requested_quantity < 1
                                       AND wdd.requested_quantity > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                                  ELSE
                                        wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                               END
                                  quantity,
                               CASE
                                  WHEN     wdd.requested_quantity2 < 1
                                       AND wdd.requested_quantity2 > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                                  ELSE
                                        wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                               END
                                  quantity2,
                               wl1.country ship_from_country,
                               wl2.country ship_to_country,
                               wl3.ui_location_code ship_from_location,
                               wl4.ui_location_code ship_to_location,
                               wdd.inventory_item_id,
                               wdd.customer_id,
                               CASE
                                  WHEN wdd.weight_uom_code = muom1.uom_code
                                  THEN
                                     wdd.gross_weight
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.weight_uom_code,
                                        to_uom     => muom1.uom_code,
                                        quantity   => wdd.gross_weight,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  conv_gross_weight,
                               CASE
                                  WHEN wdd.gross_weight > 0
                                  THEN
                                        CASE
                                           WHEN wdd.weight_uom_code =
                                                   muom1.uom_code
                                           THEN
                                              wdd.gross_weight
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.weight_uom_code,
                                                 to_uom     => muom1.uom_code,
                                                 quantity   => wdd.gross_weight,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom1.uom_code
                               END
                                  weight_uom_code,
                               CASE
                                  WHEN wdd.volume_uom_code = muom2.uom_code
                                  THEN
                                     wdd.volume
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.volume_uom_code,
                                        to_uom     => muom2.uom_code,
                                        quantity   => wdd.volume,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  Volume,
                               CASE
                                  WHEN WDD.VOLUME > 0
                                  THEN
                                        CASE
                                           WHEN wdd.volume_uom_code =
                                                   muom2.uom_code
                                           THEN
                                              wdd.volume
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.volume_uom_code,
                                                 to_uom     => muom2.uom_code,
                                                 quantity   => wdd.volume,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom2.uom_code
                               END
                                  volume_uom_code,
                               inv_ecc_outbound_util_pvt.get_converted_amount (
                                  wdd.org_id,
                                  wdd.currency_code,
                                  wdd.date_requested,
                                  NULL,
                                  NULL,
                                    DECODE (
                                       wdd.requested_quantity_uom,
                                       wdd.src_requested_quantity_uom, wdd.requested_quantity,
                                       inv_convert.inv_um_convert (
                                          wdd.inventory_item_id,
                                          5,
                                          wdd.requested_quantity,
                                          wdd.requested_quantity_uom,
                                          wdd.src_requested_quantity_uom,
                                          NULL,
                                          NULL))
                                  * oola.unit_selling_price)
                                  requested_quantity_value,
                               NVL (wt.name, 'Unassigned') trip_name,
                               wt.name trip_name_disp,
                               wnd.planned_flag,
                               wnd.initial_pickup_date,
                               wnd.ultimate_dropoff_date,
                               wnd.fob_code,
                               wnd.waybill,
                               wnd.gross_weight delivery_gross_weight,
                               CASE
                                  WHEN wnd.gross_weight > 0
                                  THEN
                                        wnd.gross_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_gross_weight_uom,
                               wnd.net_weight delivery_net_weight,
                               CASE
                                  WHEN wnd.net_weight > 0
                                  THEN
                                        wnd.net_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_net_weight_uom,
                               wnd.volume delivery_volume,
                               CASE
                                  WHEN wnd.volume > 0
                                  THEN
                                     wnd.volume || ' ' || wnd.volume_uom_code
                               END
                                  delivery_volume_uom,
                               wnd.confirm_date,
                               wt.status_code trip_status,
                               wt.vehicle_number,
                               wdd.source_header_type_name order_type,
                               wnd.status_code delivery_status,
                               wdd.released_status released_status_flag,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.ship_method_code
                                  ELSE
                                     NULL
                               END
                                  ship_method_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.service_level
                                  ELSE
                                     NULL
                               END
                                  service_level,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.mode_of_transport
                                  ELSE
                                     NULL
                               END
                                  mode_of_transport,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.freight_terms_code
                                  ELSE
                                     NULL
                               END
                                  freight_terms_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.carrier_id
                                  ELSE
                                     NULL
                               END
                                  carrier_id,
                               wt.trip_id,
                               inv_ecc_outbound_util_pvt.GET_hold_flag (
                                  oh1.header_id,
                                  oh2.line_id)
                                  hold_flag,
                               DECODE (
                                  wsp.otm_enabled,
                                  'Y', DECODE (
                                          wdd.ignore_for_planning,
                                          'N', DECODE (wt.trip_id,
                                                       NULL, 'N',
                                                       'Y'),
                                          'X'),
                                  'X')
                                  otm_planned_flag,
                               wdd.shipment_priority_code,
                               wdd.shipping_instructions,
                               wts1.stop_sequence_number,
                               whtl.wave_name,
                               flv1.language
                          FROM oe_order_headers_all ooha,
                               oe_order_lines_all oola,
                               wsh_delivery_details wdd,
                               wsh_shipping_parameters wsp,
                               mtl_units_of_measure_tl muom1,
                               mtl_units_of_measure_tl muom2,
                               wsh_delivery_assignments wda,
                               mtl_item_locations_kfv mil,
                               wsh_new_deliveries wnd,
                               wsh_delivery_legs wdl,
                               wsh_trip_stops wts,
                               wsh_trip_stops wts1,
                               wsh_trips wt,
                               fnd_lookup_values flv1,
                               oe_order_holds_all oh1,
                               oe_order_holds_all oh2,
                               wms_wp_wave_headers_tl whtl,
                               wms_wp_wave_lines wl,
                               mtl_parameters mp,
                               wsh_locations wl1,
                               wsh_locations wl2,
                               wsh_locations wl3,
                               wsh_locations wl4
                         WHERE     ooha.header_id = oola.header_id
                               AND wdd.source_header_id = ooha.header_id(+)
                               AND wdd.source_line_id = oola.line_id
                               AND wdd.released_status IN ('B',
                                                           'S',
                                                           'Y',
                                                           'R',
                                                           'C',
                                                           'D')
                               AND wdd.organization_id =
                                      mil.organization_id(+)
                               AND wdd.locator_id =
                                      mil.inventory_location_id(+)
                               AND wdd.organization_id = wsp.organization_id
                               AND wsp.weight_uom_class = muom1.uom_class
                               AND muom1.base_uom_flag = 'Y'
                               AND muom1.language = flv1.language
                               AND wsp.volume_uom_class = muom2.uom_class
                               AND muom2.base_uom_flag = 'Y'
                               AND muom2.language = flv1.language
                               AND wdd.delivery_detail_id =
                                      wda.delivery_detail_id(+)
                               AND wda.delivery_id = wnd.delivery_id(+)
                               AND wnd.delivery_id = wdl.delivery_id(+)
                               AND wdl.pick_up_stop_id = wts.stop_id(+)
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.initial_pickup_location_id =
                                          wts.stop_location_id)
                               AND wts.trip_id = wt.trip_id(+)
                               AND DECODE (
                                      wdd.released_status,
                                      'N', 'N',
                                      DECODE (wdd.replenishment_status,
                                              'R', 'E',
                                              'C', 'F',
                                              wdd.released_status)) =
                                      flv1.lookup_code
                               AND flv1.lookup_type = 'PICK_STATUS'
                               AND ooha.header_id = oh1.header_id(+)
                               AND oh1.line_id(+) IS NULL
                               AND oola.line_id = oh2.line_id(+)
                               AND oh2.line_id(+) IS NOT NULL
                               AND wdd.delivery_detail_id =
                                      wl.delivery_detail_id(+)
                               AND wl.wave_header_id = whtl.wave_header_id(+)
                               AND NVL (whtl.language, flv1.language) =
                                      flv1.language
                               AND wdl.drop_off_stop_id = wts1.stop_id(+)
                               AND mp.organization_id(+) =
                                      wdd.organization_id
                               AND wl1.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl1.location_source_code(+) = 'HR'
                               AND wl2.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND wl2.location_source_code(+) = 'HZ'
                               AND wl3.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl4.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.ultimate_dropoff_location_id =
                                          wts1.stop_location_id)
                               AND oola.last_update_date >
                                      TO_DATE (
                                         TO_CHAR (
                                            TO_TIMESTAMP (
                                               '03-JUN-20 02.56.05.000000 PM'),
                                            'DD-MON-YY HH24.MI.SS'),
                                         'DD-MON-YY HH24.MI.SS')
                        UNION
                        SELECT wdd.delivery_detail_id ecc_spec_id,
                               wdd.source_header_number order_number,
                               ooha.ordered_date ordered_date,
                               wdd.source_line_number line_number,
                               NVL (wnd.initial_pickup_date,
                                    wdd.date_scheduled)
                                  schedule_ship_date,
                               wdd.subinventory,
                               mil.concatenated_segments locator,
                               wdd.revision,
                               wdd.lot_number,
                               wdd.date_requested request_date,
                               wdd.delivery_detail_id,
                               wnd.delivery_id delivery_id,
                               NVL (wnd.name, 'Unassigned') delivery_name,
                               wnd.name delivery_name_disp,
                               flv1.meaning released_status,
                               (CASE
                                   WHEN    wdd.replenishment_status IN
                                              ('R', 'C')
                                        OR wdd.released_status = 'S'
                                   THEN
                                      5
                                   WHEN wdd.released_status IN ('R', 'B')
                                   THEN
                                      3
                                   WHEN wdd.released_status = 'Y'
                                   THEN
                                      7
                                   WHEN wdd.released_status = 'C'
                                   THEN
                                      9
                                END)
                                  released_status_bucket,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.delivery_detail_id =
                                              wdd.delivery_detail_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_detail,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.assigned_delivery_id =
                                              wnd.delivery_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_delivery,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.trip_id = wt.trip_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_trip,
                               wdd.organization_id,
                               mp.organization_code organization_code,
                               CASE
                                  WHEN     wdd.requested_quantity < 1
                                       AND wdd.requested_quantity > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                                  ELSE
                                        wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                               END
                                  quantity,
                               CASE
                                  WHEN     wdd.requested_quantity2 < 1
                                       AND wdd.requested_quantity2 > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                                  ELSE
                                        wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                               END
                                  quantity2,
                               wl1.country ship_from_country,
                               wl2.country ship_to_country,
                               wl3.ui_location_code ship_from_location,
                               wl4.ui_location_code ship_to_location,
                               wdd.inventory_item_id,
                               wdd.customer_id,
                               CASE
                                  WHEN wdd.weight_uom_code = muom1.uom_code
                                  THEN
                                     wdd.gross_weight
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.weight_uom_code,
                                        to_uom     => muom1.uom_code,
                                        quantity   => wdd.gross_weight,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  conv_gross_weight,
                               CASE
                                  WHEN wdd.gross_weight > 0
                                  THEN
                                        CASE
                                           WHEN wdd.weight_uom_code =
                                                   muom1.uom_code
                                           THEN
                                              wdd.gross_weight
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.weight_uom_code,
                                                 to_uom     => muom1.uom_code,
                                                 quantity   => wdd.gross_weight,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom1.uom_code
                               END
                                  weight_uom_code,
                               CASE
                                  WHEN wdd.volume_uom_code = muom2.uom_code
                                  THEN
                                     wdd.volume
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.volume_uom_code,
                                        to_uom     => muom2.uom_code,
                                        quantity   => wdd.volume,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  Volume,
                               CASE
                                  WHEN WDD.VOLUME > 0
                                  THEN
                                        CASE
                                           WHEN wdd.volume_uom_code =
                                                   muom2.uom_code
                                           THEN
                                              wdd.volume
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.volume_uom_code,
                                                 to_uom     => muom2.uom_code,
                                                 quantity   => wdd.volume,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom2.uom_code
                               END
                                  volume_uom_code,
                               inv_ecc_outbound_util_pvt.get_converted_amount (
                                  wdd.org_id,
                                  wdd.currency_code,
                                  wdd.date_requested,
                                  NULL,
                                  NULL,
                                    DECODE (
                                       wdd.requested_quantity_uom,
                                       wdd.src_requested_quantity_uom, wdd.requested_quantity,
                                       inv_convert.inv_um_convert (
                                          wdd.inventory_item_id,
                                          5,
                                          wdd.requested_quantity,
                                          wdd.requested_quantity_uom,
                                          wdd.src_requested_quantity_uom,
                                          NULL,
                                          NULL))
                                  * oola.unit_selling_price)
                                  requested_quantity_value,
                               NVL (wt.name, 'Unassigned') trip_name,
                               wt.name trip_name_disp,
                               wnd.planned_flag,
                               wnd.initial_pickup_date,
                               wnd.ultimate_dropoff_date,
                               wnd.fob_code,
                               wnd.waybill,
                               wnd.gross_weight delivery_gross_weight,
                               CASE
                                  WHEN wnd.gross_weight > 0
                                  THEN
                                        wnd.gross_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_gross_weight_uom,
                               wnd.net_weight delivery_net_weight,
                               CASE
                                  WHEN wnd.net_weight > 0
                                  THEN
                                        wnd.net_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_net_weight_uom,
                               wnd.volume delivery_volume,
                               CASE
                                  WHEN wnd.volume > 0
                                  THEN
                                     wnd.volume || ' ' || wnd.volume_uom_code
                               END
                                  delivery_volume_uom,
                               wnd.confirm_date,
                               wt.status_code trip_status,
                               wt.vehicle_number,
                               wdd.source_header_type_name order_type,
                               wnd.status_code delivery_status,
                               wdd.released_status released_status_flag,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.ship_method_code
                                  ELSE
                                     NULL
                               END
                                  ship_method_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.service_level
                                  ELSE
                                     NULL
                               END
                                  service_level,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.mode_of_transport
                                  ELSE
                                     NULL
                               END
                                  mode_of_transport,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.freight_terms_code
                                  ELSE
                                     NULL
                               END
                                  freight_terms_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.carrier_id
                                  ELSE
                                     NULL
                               END
                                  carrier_id,
                               wt.trip_id,
                               inv_ecc_outbound_util_pvt.GET_hold_flag (
                                  oh1.header_id,
                                  oh2.line_id)
                                  hold_flag,
                               DECODE (
                                  wsp.otm_enabled,
                                  'Y', DECODE (
                                          wdd.ignore_for_planning,
                                          'N', DECODE (wt.trip_id,
                                                       NULL, 'N',
                                                       'Y'),
                                          'X'),
                                  'X')
                                  otm_planned_flag,
                               wdd.shipment_priority_code,
                               wdd.shipping_instructions,
                               wts1.stop_sequence_number,
                               whtl.wave_name,
                               flv1.language
                          FROM oe_order_headers_all ooha,
                               oe_order_lines_all oola,
                               wsh_delivery_details wdd,
                               wsh_shipping_parameters wsp,
                               mtl_units_of_measure_tl muom1,
                               mtl_units_of_measure_tl muom2,
                               wsh_delivery_assignments wda,
                               mtl_item_locations_kfv mil,
                               wsh_new_deliveries wnd,
                               wsh_delivery_legs wdl,
                               wsh_trip_stops wts,
                               wsh_trip_stops wts1,
                               wsh_trips wt,
                               fnd_lookup_values flv1,
                               oe_order_holds_all oh1,
                               oe_order_holds_all oh2,
                               wms_wp_wave_headers_tl whtl,
                               wms_wp_wave_lines wl,
                               mtl_parameters mp,
                               wsh_locations wl1,
                               wsh_locations wl2,
                               wsh_locations wl3,
                               wsh_locations wl4
                         WHERE     ooha.header_id = oola.header_id
                               AND wdd.source_header_id = ooha.header_id(+)
                               AND wdd.source_line_id = oola.line_id
                               AND wdd.released_status IN ('B',
                                                           'S',
                                                           'Y',
                                                           'R',
                                                           'C',
                                                           'D')
                               AND wdd.organization_id =
                                      mil.organization_id(+)
                               AND wdd.locator_id =
                                      mil.inventory_location_id(+)
                               AND wdd.organization_id = wsp.organization_id
                               AND wsp.weight_uom_class = muom1.uom_class
                               AND muom1.base_uom_flag = 'Y'
                               AND muom1.language = flv1.language
                               AND wsp.volume_uom_class = muom2.uom_class
                               AND muom2.base_uom_flag = 'Y'
                               AND muom2.language = flv1.language
                               AND wdd.delivery_detail_id =
                                      wda.delivery_detail_id(+)
                               AND wda.delivery_id = wnd.delivery_id(+)
                               AND wnd.delivery_id = wdl.delivery_id(+)
                               AND wdl.pick_up_stop_id = wts.stop_id(+)
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.initial_pickup_location_id =
                                          wts.stop_location_id)
                               AND wts.trip_id = wt.trip_id(+)
                               AND DECODE (
                                      wdd.released_status,
                                      'N', 'N',
                                      DECODE (wdd.replenishment_status,
                                              'R', 'E',
                                              'C', 'F',
                                              wdd.released_status)) =
                                      flv1.lookup_code
                               AND flv1.lookup_type = 'PICK_STATUS'
                               AND ooha.header_id = oh1.header_id(+)
                               AND oh1.line_id(+) IS NULL
                               AND oola.line_id = oh2.line_id(+)
                               AND oh2.line_id(+) IS NOT NULL
                               AND wdd.delivery_detail_id =
                                      wl.delivery_detail_id(+)
                               AND wl.wave_header_id = whtl.wave_header_id(+)
                               AND NVL (whtl.language, flv1.language) =
                                      flv1.language
                               AND wdl.drop_off_stop_id = wts1.stop_id(+)
                               AND mp.organization_id(+) =
                                      wdd.organization_id
                               AND wl1.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl1.location_source_code(+) = 'HR'
                               AND wl2.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND wl2.location_source_code(+) = 'HZ'
                               AND wl3.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl4.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.ultimate_dropoff_location_id =
                                          wts1.stop_location_id)
                               AND oh1.last_update_date >
                                      TO_DATE (
                                         TO_CHAR (
                                            TO_TIMESTAMP (
                                               '03-JUN-20 02.56.05.000000 PM'),
                                            'DD-MON-YY HH24.MI.SS'),
                                         'DD-MON-YY HH24.MI.SS')
                        UNION
                        SELECT wdd.delivery_detail_id ecc_spec_id,
                               wdd.source_header_number order_number,
                               ooha.ordered_date ordered_date,
                               wdd.source_line_number line_number,
                               NVL (wnd.initial_pickup_date,
                                    wdd.date_scheduled)
                                  schedule_ship_date,
                               wdd.subinventory,
                               mil.concatenated_segments locator,
                               wdd.revision,
                               wdd.lot_number,
                               wdd.date_requested request_date,
                               wdd.delivery_detail_id,
                               wnd.delivery_id delivery_id,
                               NVL (wnd.name, 'Unassigned') delivery_name,
                               wnd.name delivery_name_disp,
                               flv1.meaning released_status,
                               (CASE
                                   WHEN    wdd.replenishment_status IN
                                              ('R', 'C')
                                        OR wdd.released_status = 'S'
                                   THEN
                                      5
                                   WHEN wdd.released_status IN ('R', 'B')
                                   THEN
                                      3
                                   WHEN wdd.released_status = 'Y'
                                   THEN
                                      7
                                   WHEN wdd.released_status = 'C'
                                   THEN
                                      9
                                END)
                                  released_status_bucket,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.delivery_detail_id =
                                              wdd.delivery_detail_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_detail,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.assigned_delivery_id =
                                              wnd.delivery_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_delivery,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.trip_id = wt.trip_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_trip,
                               wdd.organization_id,
                               mp.organization_code organization_code,
                               CASE
                                  WHEN     wdd.requested_quantity < 1
                                       AND wdd.requested_quantity > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                                  ELSE
                                        wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                               END
                                  quantity,
                               CASE
                                  WHEN     wdd.requested_quantity2 < 1
                                       AND wdd.requested_quantity2 > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                                  ELSE
                                        wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                               END
                                  quantity2,
                               wl1.country ship_from_country,
                               wl2.country ship_to_country,
                               wl3.ui_location_code ship_from_location,
                               wl4.ui_location_code ship_to_location,
                               wdd.inventory_item_id,
                               wdd.customer_id,
                               CASE
                                  WHEN wdd.weight_uom_code = muom1.uom_code
                                  THEN
                                     wdd.gross_weight
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.weight_uom_code,
                                        to_uom     => muom1.uom_code,
                                        quantity   => wdd.gross_weight,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  conv_gross_weight,
                               CASE
                                  WHEN wdd.gross_weight > 0
                                  THEN
                                        CASE
                                           WHEN wdd.weight_uom_code =
                                                   muom1.uom_code
                                           THEN
                                              wdd.gross_weight
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.weight_uom_code,
                                                 to_uom     => muom1.uom_code,
                                                 quantity   => wdd.gross_weight,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom1.uom_code
                               END
                                  weight_uom_code,
                               CASE
                                  WHEN wdd.volume_uom_code = muom2.uom_code
                                  THEN
                                     wdd.volume
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.volume_uom_code,
                                        to_uom     => muom2.uom_code,
                                        quantity   => wdd.volume,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  Volume,
                               CASE
                                  WHEN WDD.VOLUME > 0
                                  THEN
                                        CASE
                                           WHEN wdd.volume_uom_code =
                                                   muom2.uom_code
                                           THEN
                                              wdd.volume
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.volume_uom_code,
                                                 to_uom     => muom2.uom_code,
                                                 quantity   => wdd.volume,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom2.uom_code
                               END
                                  volume_uom_code,
                               inv_ecc_outbound_util_pvt.get_converted_amount (
                                  wdd.org_id,
                                  wdd.currency_code,
                                  wdd.date_requested,
                                  NULL,
                                  NULL,
                                    DECODE (
                                       wdd.requested_quantity_uom,
                                       wdd.src_requested_quantity_uom, wdd.requested_quantity,
                                       inv_convert.inv_um_convert (
                                          wdd.inventory_item_id,
                                          5,
                                          wdd.requested_quantity,
                                          wdd.requested_quantity_uom,
                                          wdd.src_requested_quantity_uom,
                                          NULL,
                                          NULL))
                                  * oola.unit_selling_price)
                                  requested_quantity_value,
                               NVL (wt.name, 'Unassigned') trip_name,
                               wt.name trip_name_disp,
                               wnd.planned_flag,
                               wnd.initial_pickup_date,
                               wnd.ultimate_dropoff_date,
                               wnd.fob_code,
                               wnd.waybill,
                               wnd.gross_weight delivery_gross_weight,
                               CASE
                                  WHEN wnd.gross_weight > 0
                                  THEN
                                        wnd.gross_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_gross_weight_uom,
                               wnd.net_weight delivery_net_weight,
                               CASE
                                  WHEN wnd.net_weight > 0
                                  THEN
                                        wnd.net_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_net_weight_uom,
                               wnd.volume delivery_volume,
                               CASE
                                  WHEN wnd.volume > 0
                                  THEN
                                     wnd.volume || ' ' || wnd.volume_uom_code
                               END
                                  delivery_volume_uom,
                               wnd.confirm_date,
                               wt.status_code trip_status,
                               wt.vehicle_number,
                               wdd.source_header_type_name order_type,
                               wnd.status_code delivery_status,
                               wdd.released_status released_status_flag,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.ship_method_code
                                  ELSE
                                     NULL
                               END
                                  ship_method_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.service_level
                                  ELSE
                                     NULL
                               END
                                  service_level,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.mode_of_transport
                                  ELSE
                                     NULL
                               END
                                  mode_of_transport,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.freight_terms_code
                                  ELSE
                                     NULL
                               END
                                  freight_terms_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.carrier_id
                                  ELSE
                                     NULL
                               END
                                  carrier_id,
                               wt.trip_id,
                               inv_ecc_outbound_util_pvt.GET_hold_flag (
                                  oh1.header_id,
                                  oh2.line_id)
                                  hold_flag,
                               DECODE (
                                  wsp.otm_enabled,
                                  'Y', DECODE (
                                          wdd.ignore_for_planning,
                                          'N', DECODE (wt.trip_id,
                                                       NULL, 'N',
                                                       'Y'),
                                          'X'),
                                  'X')
                                  otm_planned_flag,
                               wdd.shipment_priority_code,
                               wdd.shipping_instructions,
                               wts1.stop_sequence_number,
                               whtl.wave_name,
                               flv1.language
                          FROM oe_order_headers_all ooha,
                               oe_order_lines_all oola,
                               wsh_delivery_details wdd,
                               wsh_shipping_parameters wsp,
                               mtl_units_of_measure_tl muom1,
                               mtl_units_of_measure_tl muom2,
                               wsh_delivery_assignments wda,
                               mtl_item_locations_kfv mil,
                               wsh_new_deliveries wnd,
                               wsh_delivery_legs wdl,
                               wsh_trip_stops wts,
                               wsh_trip_stops wts1,
                               wsh_trips wt,
                               fnd_lookup_values flv1,
                               oe_order_holds_all oh1,
                               oe_order_holds_all oh2,
                               wms_wp_wave_headers_tl whtl,
                               wms_wp_wave_lines wl,
                               mtl_parameters mp,
                               wsh_locations wl1,
                               wsh_locations wl2,
                               wsh_locations wl3,
                               wsh_locations wl4
                         WHERE     ooha.header_id = oola.header_id
                               AND wdd.source_header_id = ooha.header_id(+)
                               AND wdd.source_line_id = oola.line_id
                               AND wdd.released_status IN ('B',
                                                           'S',
                                                           'Y',
                                                           'R',
                                                           'C',
                                                           'D')
                               AND wdd.organization_id =
                                      mil.organization_id(+)
                               AND wdd.locator_id =
                                      mil.inventory_location_id(+)
                               AND wdd.organization_id = wsp.organization_id
                               AND wsp.weight_uom_class = muom1.uom_class
                               AND muom1.base_uom_flag = 'Y'
                               AND muom1.language = flv1.language
                               AND wsp.volume_uom_class = muom2.uom_class
                               AND muom2.base_uom_flag = 'Y'
                               AND muom2.language = flv1.language
                               AND wdd.delivery_detail_id =
                                      wda.delivery_detail_id(+)
                               AND wda.delivery_id = wnd.delivery_id(+)
                               AND wnd.delivery_id = wdl.delivery_id(+)
                               AND wdl.pick_up_stop_id = wts.stop_id(+)
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.initial_pickup_location_id =
                                          wts.stop_location_id)
                               AND wts.trip_id = wt.trip_id(+)
                               AND DECODE (
                                      wdd.released_status,
                                      'N', 'N',
                                      DECODE (wdd.replenishment_status,
                                              'R', 'E',
                                              'C', 'F',
                                              wdd.released_status)) =
                                      flv1.lookup_code
                               AND flv1.lookup_type = 'PICK_STATUS'
                               AND ooha.header_id = oh1.header_id(+)
                               AND oh1.line_id(+) IS NULL
                               AND oola.line_id = oh2.line_id(+)
                               AND oh2.line_id(+) IS NOT NULL
                               AND wdd.delivery_detail_id =
                                      wl.delivery_detail_id(+)
                               AND wl.wave_header_id = whtl.wave_header_id(+)
                               AND NVL (whtl.language, flv1.language) =
                                      flv1.language
                               AND wdl.drop_off_stop_id = wts1.stop_id(+)
                               AND mp.organization_id(+) =
                                      wdd.organization_id
                               AND wl1.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl1.location_source_code(+) = 'HR'
                               AND wl2.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND wl2.location_source_code(+) = 'HZ'
                               AND wl3.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl4.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.ultimate_dropoff_location_id =
                                          wts1.stop_location_id)
                               AND oh2.last_update_date >
                                      TO_DATE (
                                         TO_CHAR (
                                            TO_TIMESTAMP (
                                               '03-JUN-20 02.56.05.000000 PM'),
                                            'DD-MON-YY HH24.MI.SS'),
                                         'DD-MON-YY HH24.MI.SS')
                        UNION
                        SELECT wdd.delivery_detail_id ecc_spec_id,
                               wdd.source_header_number order_number,
                               ooha.ordered_date ordered_date,
                               wdd.source_line_number line_number,
                               NVL (wnd.initial_pickup_date,
                                    wdd.date_scheduled)
                                  schedule_ship_date,
                               wdd.subinventory,
                               mil.concatenated_segments locator,
                               wdd.revision,
                               wdd.lot_number,
                               wdd.date_requested request_date,
                               wdd.delivery_detail_id,
                               wnd.delivery_id delivery_id,
                               NVL (wnd.name, 'Unassigned') delivery_name,
                               wnd.name delivery_name_disp,
                               flv1.meaning released_status,
                               (CASE
                                   WHEN    wdd.replenishment_status IN
                                              ('R', 'C')
                                        OR wdd.released_status = 'S'
                                   THEN
                                      5
                                   WHEN wdd.released_status IN ('R', 'B')
                                   THEN
                                      3
                                   WHEN wdd.released_status = 'Y'
                                   THEN
                                      7
                                   WHEN wdd.released_status = 'C'
                                   THEN
                                      9
                                END)
                                  released_status_bucket,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.delivery_detail_id =
                                              wdd.delivery_detail_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_detail,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.assigned_delivery_id =
                                              wnd.delivery_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_delivery,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.trip_id = wt.trip_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_trip,
                               wdd.organization_id,
                               mp.organization_code organization_code,
                               CASE
                                  WHEN     wdd.requested_quantity < 1
                                       AND wdd.requested_quantity > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                                  ELSE
                                        wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                               END
                                  quantity,
                               CASE
                                  WHEN     wdd.requested_quantity2 < 1
                                       AND wdd.requested_quantity2 > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                                  ELSE
                                        wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                               END
                                  quantity2,
                               wl1.country ship_from_country,
                               wl2.country ship_to_country,
                               wl3.ui_location_code ship_from_location,
                               wl4.ui_location_code ship_to_location,
                               wdd.inventory_item_id,
                               wdd.customer_id,
                               CASE
                                  WHEN wdd.weight_uom_code = muom1.uom_code
                                  THEN
                                     wdd.gross_weight
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.weight_uom_code,
                                        to_uom     => muom1.uom_code,
                                        quantity   => wdd.gross_weight,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  conv_gross_weight,
                               CASE
                                  WHEN wdd.gross_weight > 0
                                  THEN
                                        CASE
                                           WHEN wdd.weight_uom_code =
                                                   muom1.uom_code
                                           THEN
                                              wdd.gross_weight
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.weight_uom_code,
                                                 to_uom     => muom1.uom_code,
                                                 quantity   => wdd.gross_weight,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom1.uom_code
                               END
                                  weight_uom_code,
                               CASE
                                  WHEN wdd.volume_uom_code = muom2.uom_code
                                  THEN
                                     wdd.volume
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.volume_uom_code,
                                        to_uom     => muom2.uom_code,
                                        quantity   => wdd.volume,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  Volume,
                               CASE
                                  WHEN WDD.VOLUME > 0
                                  THEN
                                        CASE
                                           WHEN wdd.volume_uom_code =
                                                   muom2.uom_code
                                           THEN
                                              wdd.volume
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.volume_uom_code,
                                                 to_uom     => muom2.uom_code,
                                                 quantity   => wdd.volume,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom2.uom_code
                               END
                                  volume_uom_code,
                               inv_ecc_outbound_util_pvt.get_converted_amount (
                                  wdd.org_id,
                                  wdd.currency_code,
                                  wdd.date_requested,
                                  NULL,
                                  NULL,
                                    DECODE (
                                       wdd.requested_quantity_uom,
                                       wdd.src_requested_quantity_uom, wdd.requested_quantity,
                                       inv_convert.inv_um_convert (
                                          wdd.inventory_item_id,
                                          5,
                                          wdd.requested_quantity,
                                          wdd.requested_quantity_uom,
                                          wdd.src_requested_quantity_uom,
                                          NULL,
                                          NULL))
                                  * oola.unit_selling_price)
                                  requested_quantity_value,
                               NVL (wt.name, 'Unassigned') trip_name,
                               wt.name trip_name_disp,
                               wnd.planned_flag,
                               wnd.initial_pickup_date,
                               wnd.ultimate_dropoff_date,
                               wnd.fob_code,
                               wnd.waybill,
                               wnd.gross_weight delivery_gross_weight,
                               CASE
                                  WHEN wnd.gross_weight > 0
                                  THEN
                                        wnd.gross_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_gross_weight_uom,
                               wnd.net_weight delivery_net_weight,
                               CASE
                                  WHEN wnd.net_weight > 0
                                  THEN
                                        wnd.net_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_net_weight_uom,
                               wnd.volume delivery_volume,
                               CASE
                                  WHEN wnd.volume > 0
                                  THEN
                                     wnd.volume || ' ' || wnd.volume_uom_code
                               END
                                  delivery_volume_uom,
                               wnd.confirm_date,
                               wt.status_code trip_status,
                               wt.vehicle_number,
                               wdd.source_header_type_name order_type,
                               wnd.status_code delivery_status,
                               wdd.released_status released_status_flag,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.ship_method_code
                                  ELSE
                                     NULL
                               END
                                  ship_method_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.service_level
                                  ELSE
                                     NULL
                               END
                                  service_level,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.mode_of_transport
                                  ELSE
                                     NULL
                               END
                                  mode_of_transport,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.freight_terms_code
                                  ELSE
                                     NULL
                               END
                                  freight_terms_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.carrier_id
                                  ELSE
                                     NULL
                               END
                                  carrier_id,
                               wt.trip_id,
                               inv_ecc_outbound_util_pvt.GET_hold_flag (
                                  oh1.header_id,
                                  oh2.line_id)
                                  hold_flag,
                               DECODE (
                                  wsp.otm_enabled,
                                  'Y', DECODE (
                                          wdd.ignore_for_planning,
                                          'N', DECODE (wt.trip_id,
                                                       NULL, 'N',
                                                       'Y'),
                                          'X'),
                                  'X')
                                  otm_planned_flag,
                               wdd.shipment_priority_code,
                               wdd.shipping_instructions,
                               wts1.stop_sequence_number,
                               whtl.wave_name,
                               flv1.language
                          FROM oe_order_headers_all ooha,
                               oe_order_lines_all oola,
                               wsh_delivery_details wdd,
                               wsh_shipping_parameters wsp,
                               mtl_units_of_measure_tl muom1,
                               mtl_units_of_measure_tl muom2,
                               wsh_delivery_assignments wda,
                               mtl_item_locations_kfv mil,
                               wsh_new_deliveries wnd,
                               wsh_delivery_legs wdl,
                               wsh_trip_stops wts,
                               wsh_trip_stops wts1,
                               wsh_trips wt,
                               fnd_lookup_values flv1,
                               oe_order_holds_all oh1,
                               oe_order_holds_all oh2,
                               wms_wp_wave_headers_tl whtl,
                               wms_wp_wave_lines wl,
                               mtl_parameters mp,
                               wsh_locations wl1,
                               wsh_locations wl2,
                               wsh_locations wl3,
                               wsh_locations wl4
                         WHERE     ooha.header_id = oola.header_id
                               AND wdd.source_header_id = ooha.header_id(+)
                               AND wdd.source_line_id = oola.line_id
                               AND wdd.released_status IN ('B',
                                                           'S',
                                                           'Y',
                                                           'R',
                                                           'C',
                                                           'D')
                               AND wdd.organization_id =
                                      mil.organization_id(+)
                               AND wdd.locator_id =
                                      mil.inventory_location_id(+)
                               AND wdd.organization_id = wsp.organization_id
                               AND wsp.weight_uom_class = muom1.uom_class
                               AND muom1.base_uom_flag = 'Y'
                               AND muom1.language = flv1.language
                               AND wsp.volume_uom_class = muom2.uom_class
                               AND muom2.base_uom_flag = 'Y'
                               AND muom2.language = flv1.language
                               AND wdd.delivery_detail_id =
                                      wda.delivery_detail_id(+)
                               AND wda.delivery_id = wnd.delivery_id(+)
                               AND wnd.delivery_id = wdl.delivery_id(+)
                               AND wdl.pick_up_stop_id = wts.stop_id(+)
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.initial_pickup_location_id =
                                          wts.stop_location_id)
                               AND wts.trip_id = wt.trip_id(+)
                               AND DECODE (
                                      wdd.released_status,
                                      'N', 'N',
                                      DECODE (wdd.replenishment_status,
                                              'R', 'E',
                                              'C', 'F',
                                              wdd.released_status)) =
                                      flv1.lookup_code
                               AND flv1.lookup_type = 'PICK_STATUS'
                               AND ooha.header_id = oh1.header_id(+)
                               AND oh1.line_id(+) IS NULL
                               AND oola.line_id = oh2.line_id(+)
                               AND oh2.line_id(+) IS NOT NULL
                               AND wdd.delivery_detail_id =
                                      wl.delivery_detail_id(+)
                               AND wl.wave_header_id = whtl.wave_header_id(+)
                               AND NVL (whtl.language, flv1.language) =
                                      flv1.language
                               AND wdl.drop_off_stop_id = wts1.stop_id(+)
                               AND mp.organization_id(+) =
                                      wdd.organization_id
                               AND wl1.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl1.location_source_code(+) = 'HR'
                               AND wl2.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND wl2.location_source_code(+) = 'HZ'
                               AND wl3.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl4.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.ultimate_dropoff_location_id =
                                          wts1.stop_location_id)
                               AND wdd.last_update_date >
                                      TO_DATE (
                                         TO_CHAR (
                                            TO_TIMESTAMP (
                                               '03-JUN-20 02.56.05.000000 PM'),
                                            'DD-MON-YY HH24.MI.SS'),
                                         'DD-MON-YY HH24.MI.SS')
                        UNION
                        SELECT wdd.delivery_detail_id ecc_spec_id,
                               wdd.source_header_number order_number,
                               ooha.ordered_date ordered_date,
                               wdd.source_line_number line_number,
                               NVL (wnd.initial_pickup_date,
                                    wdd.date_scheduled)
                                  schedule_ship_date,
                               wdd.subinventory,
                               mil.concatenated_segments locator,
                               wdd.revision,
                               wdd.lot_number,
                               wdd.date_requested request_date,
                               wdd.delivery_detail_id,
                               wnd.delivery_id delivery_id,
                               NVL (wnd.name, 'Unassigned') delivery_name,
                               wnd.name delivery_name_disp,
                               flv1.meaning released_status,
                               (CASE
                                   WHEN    wdd.replenishment_status IN
                                              ('R', 'C')
                                        OR wdd.released_status = 'S'
                                   THEN
                                      5
                                   WHEN wdd.released_status IN ('R', 'B')
                                   THEN
                                      3
                                   WHEN wdd.released_status = 'Y'
                                   THEN
                                      7
                                   WHEN wdd.released_status = 'C'
                                   THEN
                                      9
                                END)
                                  released_status_bucket,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.delivery_detail_id =
                                              wdd.delivery_detail_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_detail,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.assigned_delivery_id =
                                              wnd.delivery_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_delivery,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.trip_id = wt.trip_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_trip,
                               wdd.organization_id,
                               mp.organization_code organization_code,
                               CASE
                                  WHEN     wdd.requested_quantity < 1
                                       AND wdd.requested_quantity > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                                  ELSE
                                        wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                               END
                                  quantity,
                               CASE
                                  WHEN     wdd.requested_quantity2 < 1
                                       AND wdd.requested_quantity2 > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                                  ELSE
                                        wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                               END
                                  quantity2,
                               wl1.country ship_from_country,
                               wl2.country ship_to_country,
                               wl3.ui_location_code ship_from_location,
                               wl4.ui_location_code ship_to_location,
                               wdd.inventory_item_id,
                               wdd.customer_id,
                               CASE
                                  WHEN wdd.weight_uom_code = muom1.uom_code
                                  THEN
                                     wdd.gross_weight
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.weight_uom_code,
                                        to_uom     => muom1.uom_code,
                                        quantity   => wdd.gross_weight,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  conv_gross_weight,
                               CASE
                                  WHEN wdd.gross_weight > 0
                                  THEN
                                        CASE
                                           WHEN wdd.weight_uom_code =
                                                   muom1.uom_code
                                           THEN
                                              wdd.gross_weight
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.weight_uom_code,
                                                 to_uom     => muom1.uom_code,
                                                 quantity   => wdd.gross_weight,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom1.uom_code
                               END
                                  weight_uom_code,
                               CASE
                                  WHEN wdd.volume_uom_code = muom2.uom_code
                                  THEN
                                     wdd.volume
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.volume_uom_code,
                                        to_uom     => muom2.uom_code,
                                        quantity   => wdd.volume,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  Volume,
                               CASE
                                  WHEN WDD.VOLUME > 0
                                  THEN
                                        CASE
                                           WHEN wdd.volume_uom_code =
                                                   muom2.uom_code
                                           THEN
                                              wdd.volume
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.volume_uom_code,
                                                 to_uom     => muom2.uom_code,
                                                 quantity   => wdd.volume,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom2.uom_code
                               END
                                  volume_uom_code,
                               inv_ecc_outbound_util_pvt.get_converted_amount (
                                  wdd.org_id,
                                  wdd.currency_code,
                                  wdd.date_requested,
                                  NULL,
                                  NULL,
                                    DECODE (
                                       wdd.requested_quantity_uom,
                                       wdd.src_requested_quantity_uom, wdd.requested_quantity,
                                       inv_convert.inv_um_convert (
                                          wdd.inventory_item_id,
                                          5,
                                          wdd.requested_quantity,
                                          wdd.requested_quantity_uom,
                                          wdd.src_requested_quantity_uom,
                                          NULL,
                                          NULL))
                                  * oola.unit_selling_price)
                                  requested_quantity_value,
                               NVL (wt.name, 'Unassigned') trip_name,
                               wt.name trip_name_disp,
                               wnd.planned_flag,
                               wnd.initial_pickup_date,
                               wnd.ultimate_dropoff_date,
                               wnd.fob_code,
                               wnd.waybill,
                               wnd.gross_weight delivery_gross_weight,
                               CASE
                                  WHEN wnd.gross_weight > 0
                                  THEN
                                        wnd.gross_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_gross_weight_uom,
                               wnd.net_weight delivery_net_weight,
                               CASE
                                  WHEN wnd.net_weight > 0
                                  THEN
                                        wnd.net_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_net_weight_uom,
                               wnd.volume delivery_volume,
                               CASE
                                  WHEN wnd.volume > 0
                                  THEN
                                     wnd.volume || ' ' || wnd.volume_uom_code
                               END
                                  delivery_volume_uom,
                               wnd.confirm_date,
                               wt.status_code trip_status,
                               wt.vehicle_number,
                               wdd.source_header_type_name order_type,
                               wnd.status_code delivery_status,
                               wdd.released_status released_status_flag,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.ship_method_code
                                  ELSE
                                     NULL
                               END
                                  ship_method_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.service_level
                                  ELSE
                                     NULL
                               END
                                  service_level,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.mode_of_transport
                                  ELSE
                                     NULL
                               END
                                  mode_of_transport,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.freight_terms_code
                                  ELSE
                                     NULL
                               END
                                  freight_terms_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.carrier_id
                                  ELSE
                                     NULL
                               END
                                  carrier_id,
                               wt.trip_id,
                               inv_ecc_outbound_util_pvt.GET_hold_flag (
                                  oh1.header_id,
                                  oh2.line_id)
                                  hold_flag,
                               DECODE (
                                  wsp.otm_enabled,
                                  'Y', DECODE (
                                          wdd.ignore_for_planning,
                                          'N', DECODE (wt.trip_id,
                                                       NULL, 'N',
                                                       'Y'),
                                          'X'),
                                  'X')
                                  otm_planned_flag,
                               wdd.shipment_priority_code,
                               wdd.shipping_instructions,
                               wts1.stop_sequence_number,
                               whtl.wave_name,
                               flv1.language
                          FROM oe_order_headers_all ooha,
                               oe_order_lines_all oola,
                               wsh_delivery_details wdd,
                               wsh_shipping_parameters wsp,
                               mtl_units_of_measure_tl muom1,
                               mtl_units_of_measure_tl muom2,
                               wsh_delivery_assignments wda,
                               mtl_item_locations_kfv mil,
                               wsh_new_deliveries wnd,
                               wsh_delivery_legs wdl,
                               wsh_trip_stops wts,
                               wsh_trip_stops wts1,
                               wsh_trips wt,
                               fnd_lookup_values flv1,
                               oe_order_holds_all oh1,
                               oe_order_holds_all oh2,
                               wms_wp_wave_headers_tl whtl,
                               wms_wp_wave_lines wl,
                               mtl_parameters mp,
                               wsh_locations wl1,
                               wsh_locations wl2,
                               wsh_locations wl3,
                               wsh_locations wl4
                         WHERE     ooha.header_id = oola.header_id
                               AND wdd.source_header_id = ooha.header_id(+)
                               AND wdd.source_line_id = oola.line_id
                               AND wdd.released_status IN ('B',
                                                           'S',
                                                           'Y',
                                                           'R',
                                                           'C',
                                                           'D')
                               AND wdd.organization_id =
                                      mil.organization_id(+)
                               AND wdd.locator_id =
                                      mil.inventory_location_id(+)
                               AND wdd.organization_id = wsp.organization_id
                               AND wsp.weight_uom_class = muom1.uom_class
                               AND muom1.base_uom_flag = 'Y'
                               AND muom1.language = flv1.language
                               AND wsp.volume_uom_class = muom2.uom_class
                               AND muom2.base_uom_flag = 'Y'
                               AND muom2.language = flv1.language
                               AND wdd.delivery_detail_id =
                                      wda.delivery_detail_id(+)
                               AND wda.delivery_id = wnd.delivery_id(+)
                               AND wnd.delivery_id = wdl.delivery_id(+)
                               AND wdl.pick_up_stop_id = wts.stop_id(+)
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.initial_pickup_location_id =
                                          wts.stop_location_id)
                               AND wts.trip_id = wt.trip_id(+)
                               AND DECODE (
                                      wdd.released_status,
                                      'N', 'N',
                                      DECODE (wdd.replenishment_status,
                                              'R', 'E',
                                              'C', 'F',
                                              wdd.released_status)) =
                                      flv1.lookup_code
                               AND flv1.lookup_type = 'PICK_STATUS'
                               AND ooha.header_id = oh1.header_id(+)
                               AND oh1.line_id(+) IS NULL
                               AND oola.line_id = oh2.line_id(+)
                               AND oh2.line_id(+) IS NOT NULL
                               AND wdd.delivery_detail_id =
                                      wl.delivery_detail_id(+)
                               AND wl.wave_header_id = whtl.wave_header_id(+)
                               AND NVL (whtl.language, flv1.language) =
                                      flv1.language
                               AND wdl.drop_off_stop_id = wts1.stop_id(+)
                               AND mp.organization_id(+) =
                                      wdd.organization_id
                               AND wl1.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl1.location_source_code(+) = 'HR'
                               AND wl2.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND wl2.location_source_code(+) = 'HZ'
                               AND wl3.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl4.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.ultimate_dropoff_location_id =
                                          wts1.stop_location_id)
                               AND wnd.last_update_date >
                                      TO_DATE (
                                         TO_CHAR (
                                            TO_TIMESTAMP (
                                               '03-JUN-20 02.56.05.000000 PM'),
                                            'DD-MON-YY HH24.MI.SS'),
                                         'DD-MON-YY HH24.MI.SS')
                        UNION
                        SELECT wdd.delivery_detail_id ecc_spec_id,
                               wdd.source_header_number order_number,
                               ooha.ordered_date ordered_date,
                               wdd.source_line_number line_number,
                               NVL (wnd.initial_pickup_date,
                                    wdd.date_scheduled)
                                  schedule_ship_date,
                               wdd.subinventory,
                               mil.concatenated_segments locator,
                               wdd.revision,
                               wdd.lot_number,
                               wdd.date_requested request_date,
                               wdd.delivery_detail_id,
                               wnd.delivery_id delivery_id,
                               NVL (wnd.name, 'Unassigned') delivery_name,
                               wnd.name delivery_name_disp,
                               flv1.meaning released_status,
                               (CASE
                                   WHEN    wdd.replenishment_status IN
                                              ('R', 'C')
                                        OR wdd.released_status = 'S'
                                   THEN
                                      5
                                   WHEN wdd.released_status IN ('R', 'B')
                                   THEN
                                      3
                                   WHEN wdd.released_status = 'Y'
                                   THEN
                                      7
                                   WHEN wdd.released_status = 'C'
                                   THEN
                                      9
                                END)
                                  released_status_bucket,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.delivery_detail_id =
                                              wdd.delivery_detail_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_detail,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.assigned_delivery_id =
                                              wnd.delivery_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_delivery,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.trip_id = wt.trip_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_trip,
                               wdd.organization_id,
                               mp.organization_code organization_code,
                               CASE
                                  WHEN     wdd.requested_quantity < 1
                                       AND wdd.requested_quantity > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                                  ELSE
                                        wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                               END
                                  quantity,
                               CASE
                                  WHEN     wdd.requested_quantity2 < 1
                                       AND wdd.requested_quantity2 > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                                  ELSE
                                        wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                               END
                                  quantity2,
                               wl1.country ship_from_country,
                               wl2.country ship_to_country,
                               wl3.ui_location_code ship_from_location,
                               wl4.ui_location_code ship_to_location,
                               wdd.inventory_item_id,
                               wdd.customer_id,
                               CASE
                                  WHEN wdd.weight_uom_code = muom1.uom_code
                                  THEN
                                     wdd.gross_weight
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.weight_uom_code,
                                        to_uom     => muom1.uom_code,
                                        quantity   => wdd.gross_weight,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  conv_gross_weight,
                               CASE
                                  WHEN wdd.gross_weight > 0
                                  THEN
                                        CASE
                                           WHEN wdd.weight_uom_code =
                                                   muom1.uom_code
                                           THEN
                                              wdd.gross_weight
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.weight_uom_code,
                                                 to_uom     => muom1.uom_code,
                                                 quantity   => wdd.gross_weight,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom1.uom_code
                               END
                                  weight_uom_code,
                               CASE
                                  WHEN wdd.volume_uom_code = muom2.uom_code
                                  THEN
                                     wdd.volume
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.volume_uom_code,
                                        to_uom     => muom2.uom_code,
                                        quantity   => wdd.volume,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  Volume,
                               CASE
                                  WHEN WDD.VOLUME > 0
                                  THEN
                                        CASE
                                           WHEN wdd.volume_uom_code =
                                                   muom2.uom_code
                                           THEN
                                              wdd.volume
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.volume_uom_code,
                                                 to_uom     => muom2.uom_code,
                                                 quantity   => wdd.volume,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom2.uom_code
                               END
                                  volume_uom_code,
                               inv_ecc_outbound_util_pvt.get_converted_amount (
                                  wdd.org_id,
                                  wdd.currency_code,
                                  wdd.date_requested,
                                  NULL,
                                  NULL,
                                    DECODE (
                                       wdd.requested_quantity_uom,
                                       wdd.src_requested_quantity_uom, wdd.requested_quantity,
                                       inv_convert.inv_um_convert (
                                          wdd.inventory_item_id,
                                          5,
                                          wdd.requested_quantity,
                                          wdd.requested_quantity_uom,
                                          wdd.src_requested_quantity_uom,
                                          NULL,
                                          NULL))
                                  * oola.unit_selling_price)
                                  requested_quantity_value,
                               NVL (wt.name, 'Unassigned') trip_name,
                               wt.name trip_name_disp,
                               wnd.planned_flag,
                               wnd.initial_pickup_date,
                               wnd.ultimate_dropoff_date,
                               wnd.fob_code,
                               wnd.waybill,
                               wnd.gross_weight delivery_gross_weight,
                               CASE
                                  WHEN wnd.gross_weight > 0
                                  THEN
                                        wnd.gross_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_gross_weight_uom,
                               wnd.net_weight delivery_net_weight,
                               CASE
                                  WHEN wnd.net_weight > 0
                                  THEN
                                        wnd.net_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_net_weight_uom,
                               wnd.volume delivery_volume,
                               CASE
                                  WHEN wnd.volume > 0
                                  THEN
                                     wnd.volume || ' ' || wnd.volume_uom_code
                               END
                                  delivery_volume_uom,
                               wnd.confirm_date,
                               wt.status_code trip_status,
                               wt.vehicle_number,
                               wdd.source_header_type_name order_type,
                               wnd.status_code delivery_status,
                               wdd.released_status released_status_flag,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.ship_method_code
                                  ELSE
                                     NULL
                               END
                                  ship_method_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.service_level
                                  ELSE
                                     NULL
                               END
                                  service_level,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.mode_of_transport
                                  ELSE
                                     NULL
                               END
                                  mode_of_transport,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.freight_terms_code
                                  ELSE
                                     NULL
                               END
                                  freight_terms_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.carrier_id
                                  ELSE
                                     NULL
                               END
                                  carrier_id,
                               wt.trip_id,
                               inv_ecc_outbound_util_pvt.GET_hold_flag (
                                  oh1.header_id,
                                  oh2.line_id)
                                  hold_flag,
                               DECODE (
                                  wsp.otm_enabled,
                                  'Y', DECODE (
                                          wdd.ignore_for_planning,
                                          'N', DECODE (wt.trip_id,
                                                       NULL, 'N',
                                                       'Y'),
                                          'X'),
                                  'X')
                                  otm_planned_flag,
                               wdd.shipment_priority_code,
                               wdd.shipping_instructions,
                               wts1.stop_sequence_number,
                               whtl.wave_name,
                               flv1.language
                          FROM oe_order_headers_all ooha,
                               oe_order_lines_all oola,
                               wsh_delivery_details wdd,
                               wsh_shipping_parameters wsp,
                               mtl_units_of_measure_tl muom1,
                               mtl_units_of_measure_tl muom2,
                               wsh_delivery_assignments wda,
                               mtl_item_locations_kfv mil,
                               wsh_new_deliveries wnd,
                               wsh_delivery_legs wdl,
                               wsh_trip_stops wts,
                               wsh_trip_stops wts1,
                               wsh_trips wt,
                               fnd_lookup_values flv1,
                               oe_order_holds_all oh1,
                               oe_order_holds_all oh2,
                               wms_wp_wave_headers_tl whtl,
                               wms_wp_wave_lines wl,
                               mtl_parameters mp,
                               wsh_locations wl1,
                               wsh_locations wl2,
                               wsh_locations wl3,
                               wsh_locations wl4
                         WHERE     ooha.header_id = oola.header_id
                               AND wdd.source_header_id = ooha.header_id(+)
                               AND wdd.source_line_id = oola.line_id
                               AND wdd.released_status IN ('B',
                                                           'S',
                                                           'Y',
                                                           'R',
                                                           'C',
                                                           'D')
                               AND wdd.organization_id =
                                      mil.organization_id(+)
                               AND wdd.locator_id =
                                      mil.inventory_location_id(+)
                               AND wdd.organization_id = wsp.organization_id
                               AND wsp.weight_uom_class = muom1.uom_class
                               AND muom1.base_uom_flag = 'Y'
                               AND muom1.language = flv1.language
                               AND wsp.volume_uom_class = muom2.uom_class
                               AND muom2.base_uom_flag = 'Y'
                               AND muom2.language = flv1.language
                               AND wdd.delivery_detail_id =
                                      wda.delivery_detail_id(+)
                               AND wda.delivery_id = wnd.delivery_id(+)
                               AND wnd.delivery_id = wdl.delivery_id(+)
                               AND wdl.pick_up_stop_id = wts.stop_id(+)
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.initial_pickup_location_id =
                                          wts.stop_location_id)
                               AND wts.trip_id = wt.trip_id(+)
                               AND DECODE (
                                      wdd.released_status,
                                      'N', 'N',
                                      DECODE (wdd.replenishment_status,
                                              'R', 'E',
                                              'C', 'F',
                                              wdd.released_status)) =
                                      flv1.lookup_code
                               AND flv1.lookup_type = 'PICK_STATUS'
                               AND ooha.header_id = oh1.header_id(+)
                               AND oh1.line_id(+) IS NULL
                               AND oola.line_id = oh2.line_id(+)
                               AND oh2.line_id(+) IS NOT NULL
                               AND wdd.delivery_detail_id =
                                      wl.delivery_detail_id(+)
                               AND wl.wave_header_id = whtl.wave_header_id(+)
                               AND NVL (whtl.language, flv1.language) =
                                      flv1.language
                               AND wdl.drop_off_stop_id = wts1.stop_id(+)
                               AND mp.organization_id(+) =
                                      wdd.organization_id
                               AND wl1.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl1.location_source_code(+) = 'HR'
                               AND wl2.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND wl2.location_source_code(+) = 'HZ'
                               AND wl3.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl4.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.ultimate_dropoff_location_id =
                                          wts1.stop_location_id)
                               AND wt.last_update_date >
                                      TO_DATE (
                                         TO_CHAR (
                                            TO_TIMESTAMP (
                                               '03-JUN-20 02.56.05.000000 PM'),
                                            'DD-MON-YY HH24.MI.SS'),
                                         'DD-MON-YY HH24.MI.SS')
                        UNION
                        SELECT wdd.delivery_detail_id ecc_spec_id,
                               wdd.source_header_number order_number,
                               ooha.ordered_date ordered_date,
                               wdd.source_line_number line_number,
                               NVL (wnd.initial_pickup_date,
                                    wdd.date_scheduled)
                                  schedule_ship_date,
                               wdd.subinventory,
                               mil.concatenated_segments locator,
                               wdd.revision,
                               wdd.lot_number,
                               wdd.date_requested request_date,
                               wdd.delivery_detail_id,
                               wnd.delivery_id delivery_id,
                               NVL (wnd.name, 'Unassigned') delivery_name,
                               wnd.name delivery_name_disp,
                               flv1.meaning released_status,
                               (CASE
                                   WHEN    wdd.replenishment_status IN
                                              ('R', 'C')
                                        OR wdd.released_status = 'S'
                                   THEN
                                      5
                                   WHEN wdd.released_status IN ('R', 'B')
                                   THEN
                                      3
                                   WHEN wdd.released_status = 'Y'
                                   THEN
                                      7
                                   WHEN wdd.released_status = 'C'
                                   THEN
                                      9
                                END)
                                  released_status_bucket,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.delivery_detail_id =
                                              wdd.delivery_detail_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_detail,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.assigned_delivery_id =
                                              wnd.delivery_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_delivery,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.trip_id = wt.trip_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_trip,
                               wdd.organization_id,
                               mp.organization_code organization_code,
                               CASE
                                  WHEN     wdd.requested_quantity < 1
                                       AND wdd.requested_quantity > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                                  ELSE
                                        wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                               END
                                  quantity,
                               CASE
                                  WHEN     wdd.requested_quantity2 < 1
                                       AND wdd.requested_quantity2 > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                                  ELSE
                                        wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                               END
                                  quantity2,
                               wl1.country ship_from_country,
                               wl2.country ship_to_country,
                               wl3.ui_location_code ship_from_location,
                               wl4.ui_location_code ship_to_location,
                               wdd.inventory_item_id,
                               wdd.customer_id,
                               CASE
                                  WHEN wdd.weight_uom_code = muom1.uom_code
                                  THEN
                                     wdd.gross_weight
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.weight_uom_code,
                                        to_uom     => muom1.uom_code,
                                        quantity   => wdd.gross_weight,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  conv_gross_weight,
                               CASE
                                  WHEN wdd.gross_weight > 0
                                  THEN
                                        CASE
                                           WHEN wdd.weight_uom_code =
                                                   muom1.uom_code
                                           THEN
                                              wdd.gross_weight
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.weight_uom_code,
                                                 to_uom     => muom1.uom_code,
                                                 quantity   => wdd.gross_weight,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom1.uom_code
                               END
                                  weight_uom_code,
                               CASE
                                  WHEN wdd.volume_uom_code = muom2.uom_code
                                  THEN
                                     wdd.volume
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.volume_uom_code,
                                        to_uom     => muom2.uom_code,
                                        quantity   => wdd.volume,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  Volume,
                               CASE
                                  WHEN WDD.VOLUME > 0
                                  THEN
                                        CASE
                                           WHEN wdd.volume_uom_code =
                                                   muom2.uom_code
                                           THEN
                                              wdd.volume
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.volume_uom_code,
                                                 to_uom     => muom2.uom_code,
                                                 quantity   => wdd.volume,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom2.uom_code
                               END
                                  volume_uom_code,
                               inv_ecc_outbound_util_pvt.get_converted_amount (
                                  wdd.org_id,
                                  wdd.currency_code,
                                  wdd.date_requested,
                                  NULL,
                                  NULL,
                                    DECODE (
                                       wdd.requested_quantity_uom,
                                       wdd.src_requested_quantity_uom, wdd.requested_quantity,
                                       inv_convert.inv_um_convert (
                                          wdd.inventory_item_id,
                                          5,
                                          wdd.requested_quantity,
                                          wdd.requested_quantity_uom,
                                          wdd.src_requested_quantity_uom,
                                          NULL,
                                          NULL))
                                  * oola.unit_selling_price)
                                  requested_quantity_value,
                               NVL (wt.name, 'Unassigned') trip_name,
                               wt.name trip_name_disp,
                               wnd.planned_flag,
                               wnd.initial_pickup_date,
                               wnd.ultimate_dropoff_date,
                               wnd.fob_code,
                               wnd.waybill,
                               wnd.gross_weight delivery_gross_weight,
                               CASE
                                  WHEN wnd.gross_weight > 0
                                  THEN
                                        wnd.gross_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_gross_weight_uom,
                               wnd.net_weight delivery_net_weight,
                               CASE
                                  WHEN wnd.net_weight > 0
                                  THEN
                                        wnd.net_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_net_weight_uom,
                               wnd.volume delivery_volume,
                               CASE
                                  WHEN wnd.volume > 0
                                  THEN
                                     wnd.volume || ' ' || wnd.volume_uom_code
                               END
                                  delivery_volume_uom,
                               wnd.confirm_date,
                               wt.status_code trip_status,
                               wt.vehicle_number,
                               wdd.source_header_type_name order_type,
                               wnd.status_code delivery_status,
                               wdd.released_status released_status_flag,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.ship_method_code
                                  ELSE
                                     NULL
                               END
                                  ship_method_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.service_level
                                  ELSE
                                     NULL
                               END
                                  service_level,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.mode_of_transport
                                  ELSE
                                     NULL
                               END
                                  mode_of_transport,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.freight_terms_code
                                  ELSE
                                     NULL
                               END
                                  freight_terms_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.carrier_id
                                  ELSE
                                     NULL
                               END
                                  carrier_id,
                               wt.trip_id,
                               inv_ecc_outbound_util_pvt.GET_hold_flag (
                                  oh1.header_id,
                                  oh2.line_id)
                                  hold_flag,
                               DECODE (
                                  wsp.otm_enabled,
                                  'Y', DECODE (
                                          wdd.ignore_for_planning,
                                          'N', DECODE (wt.trip_id,
                                                       NULL, 'N',
                                                       'Y'),
                                          'X'),
                                  'X')
                                  otm_planned_flag,
                               wdd.shipment_priority_code,
                               wdd.shipping_instructions,
                               wts1.stop_sequence_number,
                               whtl.wave_name,
                               flv1.language
                          FROM oe_order_headers_all ooha,
                               oe_order_lines_all oola,
                               wsh_delivery_details wdd,
                               wsh_shipping_parameters wsp,
                               mtl_units_of_measure_tl muom1,
                               mtl_units_of_measure_tl muom2,
                               wsh_delivery_assignments wda,
                               mtl_item_locations_kfv mil,
                               wsh_new_deliveries wnd,
                               wsh_delivery_legs wdl,
                               wsh_trip_stops wts,
                               wsh_trip_stops wts1,
                               wsh_trips wt,
                               fnd_lookup_values flv1,
                               oe_order_holds_all oh1,
                               oe_order_holds_all oh2,
                               wms_wp_wave_headers_tl whtl,
                               wms_wp_wave_lines wl,
                               mtl_parameters mp,
                               wsh_locations wl1,
                               wsh_locations wl2,
                               wsh_locations wl3,
                               wsh_locations wl4
                         WHERE     ooha.header_id = oola.header_id
                               AND wdd.source_header_id = ooha.header_id(+)
                               AND wdd.source_line_id = oola.line_id
                               AND wdd.released_status IN ('B',
                                                           'S',
                                                           'Y',
                                                           'R',
                                                           'C',
                                                           'D')
                               AND wdd.organization_id =
                                      mil.organization_id(+)
                               AND wdd.locator_id =
                                      mil.inventory_location_id(+)
                               AND wdd.organization_id = wsp.organization_id
                               AND wsp.weight_uom_class = muom1.uom_class
                               AND muom1.base_uom_flag = 'Y'
                               AND muom1.language = flv1.language
                               AND wsp.volume_uom_class = muom2.uom_class
                               AND muom2.base_uom_flag = 'Y'
                               AND muom2.language = flv1.language
                               AND wdd.delivery_detail_id =
                                      wda.delivery_detail_id(+)
                               AND wda.delivery_id = wnd.delivery_id(+)
                               AND wnd.delivery_id = wdl.delivery_id(+)
                               AND wdl.pick_up_stop_id = wts.stop_id(+)
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.initial_pickup_location_id =
                                          wts.stop_location_id)
                               AND wts.trip_id = wt.trip_id(+)
                               AND DECODE (
                                      wdd.released_status,
                                      'N', 'N',
                                      DECODE (wdd.replenishment_status,
                                              'R', 'E',
                                              'C', 'F',
                                              wdd.released_status)) =
                                      flv1.lookup_code
                               AND flv1.lookup_type = 'PICK_STATUS'
                               AND ooha.header_id = oh1.header_id(+)
                               AND oh1.line_id(+) IS NULL
                               AND oola.line_id = oh2.line_id(+)
                               AND oh2.line_id(+) IS NOT NULL
                               AND wdd.delivery_detail_id =
                                      wl.delivery_detail_id(+)
                               AND wl.wave_header_id = whtl.wave_header_id(+)
                               AND NVL (whtl.language, flv1.language) =
                                      flv1.language
                               AND wdl.drop_off_stop_id = wts1.stop_id(+)
                               AND mp.organization_id(+) =
                                      wdd.organization_id
                               AND wl1.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl1.location_source_code(+) = 'HR'
                               AND wl2.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND wl2.location_source_code(+) = 'HZ'
                               AND wl3.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl4.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.ultimate_dropoff_location_id =
                                          wts1.stop_location_id)
                               AND wts1.last_update_date >
                                      TO_DATE (
                                         TO_CHAR (
                                            TO_TIMESTAMP (
                                               '03-JUN-20 02.56.05.000000 PM'),
                                            'DD-MON-YY HH24.MI.SS'),
                                         'DD-MON-YY HH24.MI.SS')
                        UNION
                        SELECT wdd.delivery_detail_id ecc_spec_id,
                               wdd.source_header_number order_number,
                               ooha.ordered_date ordered_date,
                               wdd.source_line_number line_number,
                               NVL (wnd.initial_pickup_date,
                                    wdd.date_scheduled)
                                  schedule_ship_date,
                               wdd.subinventory,
                               mil.concatenated_segments locator,
                               wdd.revision,
                               wdd.lot_number,
                               wdd.date_requested request_date,
                               wdd.delivery_detail_id,
                               wnd.delivery_id delivery_id,
                               NVL (wnd.name, 'Unassigned') delivery_name,
                               wnd.name delivery_name_disp,
                               flv1.meaning released_status,
                               (CASE
                                   WHEN    wdd.replenishment_status IN
                                              ('R', 'C')
                                        OR wdd.released_status = 'S'
                                   THEN
                                      5
                                   WHEN wdd.released_status IN ('R', 'B')
                                   THEN
                                      3
                                   WHEN wdd.released_status = 'Y'
                                   THEN
                                      7
                                   WHEN wdd.released_status = 'C'
                                   THEN
                                      9
                                END)
                                  released_status_bucket,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.delivery_detail_id =
                                              wdd.delivery_detail_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_detail,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.assigned_delivery_id =
                                              wnd.delivery_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_delivery,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.trip_id = wt.trip_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_trip,
                               wdd.organization_id,
                               mp.organization_code organization_code,
                               CASE
                                  WHEN     wdd.requested_quantity < 1
                                       AND wdd.requested_quantity > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                                  ELSE
                                        wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                               END
                                  quantity,
                               CASE
                                  WHEN     wdd.requested_quantity2 < 1
                                       AND wdd.requested_quantity2 > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                                  ELSE
                                        wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                               END
                                  quantity2,
                               wl1.country ship_from_country,
                               wl2.country ship_to_country,
                               wl3.ui_location_code ship_from_location,
                               wl4.ui_location_code ship_to_location,
                               wdd.inventory_item_id,
                               wdd.customer_id,
                               CASE
                                  WHEN wdd.weight_uom_code = muom1.uom_code
                                  THEN
                                     wdd.gross_weight
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.weight_uom_code,
                                        to_uom     => muom1.uom_code,
                                        quantity   => wdd.gross_weight,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  conv_gross_weight,
                               CASE
                                  WHEN wdd.gross_weight > 0
                                  THEN
                                        CASE
                                           WHEN wdd.weight_uom_code =
                                                   muom1.uom_code
                                           THEN
                                              wdd.gross_weight
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.weight_uom_code,
                                                 to_uom     => muom1.uom_code,
                                                 quantity   => wdd.gross_weight,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom1.uom_code
                               END
                                  weight_uom_code,
                               CASE
                                  WHEN wdd.volume_uom_code = muom2.uom_code
                                  THEN
                                     wdd.volume
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.volume_uom_code,
                                        to_uom     => muom2.uom_code,
                                        quantity   => wdd.volume,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  Volume,
                               CASE
                                  WHEN WDD.VOLUME > 0
                                  THEN
                                        CASE
                                           WHEN wdd.volume_uom_code =
                                                   muom2.uom_code
                                           THEN
                                              wdd.volume
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.volume_uom_code,
                                                 to_uom     => muom2.uom_code,
                                                 quantity   => wdd.volume,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom2.uom_code
                               END
                                  volume_uom_code,
                               inv_ecc_outbound_util_pvt.get_converted_amount (
                                  wdd.org_id,
                                  wdd.currency_code,
                                  wdd.date_requested,
                                  NULL,
                                  NULL,
                                    DECODE (
                                       wdd.requested_quantity_uom,
                                       wdd.src_requested_quantity_uom, wdd.requested_quantity,
                                       inv_convert.inv_um_convert (
                                          wdd.inventory_item_id,
                                          5,
                                          wdd.requested_quantity,
                                          wdd.requested_quantity_uom,
                                          wdd.src_requested_quantity_uom,
                                          NULL,
                                          NULL))
                                  * oola.unit_selling_price)
                                  requested_quantity_value,
                               NVL (wt.name, 'Unassigned') trip_name,
                               wt.name trip_name_disp,
                               wnd.planned_flag,
                               wnd.initial_pickup_date,
                               wnd.ultimate_dropoff_date,
                               wnd.fob_code,
                               wnd.waybill,
                               wnd.gross_weight delivery_gross_weight,
                               CASE
                                  WHEN wnd.gross_weight > 0
                                  THEN
                                        wnd.gross_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_gross_weight_uom,
                               wnd.net_weight delivery_net_weight,
                               CASE
                                  WHEN wnd.net_weight > 0
                                  THEN
                                        wnd.net_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_net_weight_uom,
                               wnd.volume delivery_volume,
                               CASE
                                  WHEN wnd.volume > 0
                                  THEN
                                     wnd.volume || ' ' || wnd.volume_uom_code
                               END
                                  delivery_volume_uom,
                               wnd.confirm_date,
                               wt.status_code trip_status,
                               wt.vehicle_number,
                               wdd.source_header_type_name order_type,
                               wnd.status_code delivery_status,
                               wdd.released_status released_status_flag,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.ship_method_code
                                  ELSE
                                     NULL
                               END
                                  ship_method_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.service_level
                                  ELSE
                                     NULL
                               END
                                  service_level,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.mode_of_transport
                                  ELSE
                                     NULL
                               END
                                  mode_of_transport,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.freight_terms_code
                                  ELSE
                                     NULL
                               END
                                  freight_terms_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.carrier_id
                                  ELSE
                                     NULL
                               END
                                  carrier_id,
                               wt.trip_id,
                               inv_ecc_outbound_util_pvt.GET_hold_flag (
                                  oh1.header_id,
                                  oh2.line_id)
                                  hold_flag,
                               DECODE (
                                  wsp.otm_enabled,
                                  'Y', DECODE (
                                          wdd.ignore_for_planning,
                                          'N', DECODE (wt.trip_id,
                                                       NULL, 'N',
                                                       'Y'),
                                          'X'),
                                  'X')
                                  otm_planned_flag,
                               wdd.shipment_priority_code,
                               wdd.shipping_instructions,
                               wts1.stop_sequence_number,
                               whtl.wave_name,
                               flv1.language
                          FROM oe_order_headers_all ooha,
                               oe_order_lines_all oola,
                               wsh_delivery_details wdd,
                               wsh_shipping_parameters wsp,
                               mtl_units_of_measure_tl muom1,
                               mtl_units_of_measure_tl muom2,
                               wsh_delivery_assignments wda,
                               mtl_item_locations_kfv mil,
                               wsh_new_deliveries wnd,
                               wsh_delivery_legs wdl,
                               wsh_trip_stops wts,
                               wsh_trip_stops wts1,
                               wsh_trips wt,
                               fnd_lookup_values flv1,
                               oe_order_holds_all oh1,
                               oe_order_holds_all oh2,
                               wms_wp_wave_headers_tl whtl,
                               wms_wp_wave_lines wl,
                               mtl_parameters mp,
                               wsh_locations wl1,
                               wsh_locations wl2,
                               wsh_locations wl3,
                               wsh_locations wl4
                         WHERE     ooha.header_id = oola.header_id
                               AND wdd.source_header_id = ooha.header_id(+)
                               AND wdd.source_line_id = oola.line_id
                               AND wdd.released_status IN ('B',
                                                           'S',
                                                           'Y',
                                                           'R',
                                                           'C',
                                                           'D')
                               AND wdd.organization_id =
                                      mil.organization_id(+)
                               AND wdd.locator_id =
                                      mil.inventory_location_id(+)
                               AND wdd.organization_id = wsp.organization_id
                               AND wsp.weight_uom_class = muom1.uom_class
                               AND muom1.base_uom_flag = 'Y'
                               AND muom1.language = flv1.language
                               AND wsp.volume_uom_class = muom2.uom_class
                               AND muom2.base_uom_flag = 'Y'
                               AND muom2.language = flv1.language
                               AND wdd.delivery_detail_id =
                                      wda.delivery_detail_id(+)
                               AND wda.delivery_id = wnd.delivery_id(+)
                               AND wnd.delivery_id = wdl.delivery_id(+)
                               AND wdl.pick_up_stop_id = wts.stop_id(+)
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.initial_pickup_location_id =
                                          wts.stop_location_id)
                               AND wts.trip_id = wt.trip_id(+)
                               AND DECODE (
                                      wdd.released_status,
                                      'N', 'N',
                                      DECODE (wdd.replenishment_status,
                                              'R', 'E',
                                              'C', 'F',
                                              wdd.released_status)) =
                                      flv1.lookup_code
                               AND flv1.lookup_type = 'PICK_STATUS'
                               AND ooha.header_id = oh1.header_id(+)
                               AND oh1.line_id(+) IS NULL
                               AND oola.line_id = oh2.line_id(+)
                               AND oh2.line_id(+) IS NOT NULL
                               AND wdd.delivery_detail_id =
                                      wl.delivery_detail_id(+)
                               AND wl.wave_header_id = whtl.wave_header_id(+)
                               AND NVL (whtl.language, flv1.language) =
                                      flv1.language
                               AND wdl.drop_off_stop_id = wts1.stop_id(+)
                               AND mp.organization_id(+) =
                                      wdd.organization_id
                               AND wl1.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl1.location_source_code(+) = 'HR'
                               AND wl2.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND wl2.location_source_code(+) = 'HZ'
                               AND wl3.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl4.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.ultimate_dropoff_location_id =
                                          wts1.stop_location_id)
                               AND wl.last_update_date >
                                      TO_DATE (
                                         TO_CHAR (
                                            TO_TIMESTAMP (
                                               '03-JUN-20 02.56.05.000000 PM'),
                                            'DD-MON-YY HH24.MI.SS'),
                                         'DD-MON-YY HH24.MI.SS')) A,
                       mtl_system_items_b_kfv msiv1,
                       hz_cust_accounts hca,
                       hz_parties hp,
                       fnd_lookup_values flv2,
                       fnd_lookup_values flv3,
                       fnd_lookup_values flv4,
                       fnd_lookup_values flv5,
                       fnd_lookup_values flv6,
                       fnd_lookup_values flv7,
                       fnd_lookup_values flv8,
                       fnd_lookup_values flv9,
                       fnd_lookup_values flv10,
                       fnd_lookup_values flv11,
                       hz_parties hp1
                 WHERE     A.customer_id = hca.cust_account_id
                       AND hca.party_id = hp.party_id
                       AND A.organization_id = msiv1.organization_id
                       AND A.inventory_item_id = msiv1.inventory_item_id
                       AND flv2.lookup_code(+) = A.planned_flag
                       AND flv2.lookup_type(+) = 'DELIVERY_PLANNED_FLAG'
                       AND flv2.view_application_id(+) = 665
                       AND flv2.language(+) = A.language
                       AND flv3.lookup_code(+) = A.fob_code
                       AND flv3.lookup_type(+) = 'FOB'
                       AND flv3.view_application_id(+) = '222'
                       AND flv3.language(+) = A.language
                       AND flv4.lookup_type(+) = 'TRIP_STATUS'
                       AND flv4.lookup_code(+) = A.trip_status
                       AND flv4.language(+) = A.language
                       AND flv5.lookup_type(+) = 'DELIVERY_STATUS'
                       AND flv5.lookup_code(+) = A.delivery_status
                       AND flv5.language(+) = A.language
                       AND flv6.lookup_code(+) = A.ship_method_code
                       AND flv6.lookup_type(+) = 'SHIP_METHOD'
                       AND flv6.view_application_id(+) = 3
                       AND flv6.language(+) = A.language
                       AND flv7.lookup_code(+) = A.service_level
                       AND flv7.lookup_type(+) = 'WSH_SERVICE_LEVELS'
                       AND flv7.view_application_id(+) = 665
                       AND flv7.language(+) = A.language
                       AND flv8.lookup_code(+) = A.mode_of_transport
                       AND flv8.lookup_type(+) = 'WSH_MODE_OF_TRANSPORT'
                       AND flv8.view_application_id(+) = 665
                       AND flv8.language(+) = A.language
                       AND flv9.lookup_code(+) = A.freight_terms_code
                       AND flv9.lookup_type(+) = 'FREIGHT_TERMS'
                       AND flv9.view_application_id(+) = 660
                       AND flv9.language(+) = A.language
                       AND flv10.lookup_code(+) = A.otm_planned_flag
                       AND flv10.lookup_type(+) = 'ECC_OTM_PLANNING_STATUS'
                       AND flv10.view_application_id(+) = 665
                       AND flv10.language(+) = A.language
                       AND flv11.lookup_code(+) = A.shipment_priority_code
                       AND flv11.lookup_type(+) = 'SHIPMENT_PRIORITY'
                       AND flv11.view_application_id(+) = 660
                       AND flv11.language(+) = A.language
                       AND hp1.party_id(+) = A.carrier_id
                UNION
                SELECT ecc_spec_id,
                       line_number,
                       schedule_ship_date,
                       subinventory,
                       locator,
                       revision,
                       lot_number,
                       request_date,
                       order_number,
                       ordered_date,
                       delivery_detail_id,
                       delivery_id,
                       delivery_name,
                       delivery_name_disp,
                       released_status,
                       released_status_bucket,
                       exceptionid_detail detail_exception_id,
                       NVL (exceptionid_detail, exceptionid_delivery)
                          delivery_exception_id,
                       DECODE (
                          NVL (exceptionid_detail, exceptionid_delivery),
                          NULL, 'No',
                          'Yes')
                          delivery_exception_flag,
                       NVL (NVL (exceptionid_detail, exceptionid_delivery),
                            exceptionid_trip)
                          trip_exception_id,
                       item,
                       inventory_item_id,
                       organization_id,
                       organization_code,
                       quantity,
                       quantity2,
                       ship_from_country,
                       ship_to_country,
                       ship_from_location,
                       ship_to_location,
                       customer,
                       conv_gross_weight gross_weight,
                       volume DETAIL_VOLUME,
                       weight_uom_code,
                       volume_uom_code,
                       requested_quantity_value,
                       trip_name,
                       trip_name_disp,
                       flv2.meaning planned_flag,
                       initial_pickup_date,
                       ultimate_dropoff_date,
                       flv3.meaning fob_code,
                       waybill,
                       delivery_gross_weight,
                       delivery_gross_weight_uom,
                       delivery_net_weight,
                       delivery_net_weight_uom,
                       delivery_volume,
                       delivery_volume_uom,
                       confirm_date,
                       flv4.meaning trip_status,
                       vehicle_number,
                       order_type,
                       flv5.meaning delivery_status,
                       released_status_flag,
                       DECODE (released_status_flag,
                               'C', 'Complete',
                               'D', 'Canceled',
                               'Not Complete and Not Cancelled')
                          fulfill_status,
                       flv6.meaning ship_method,
                       flv7.meaning service_level,
                       flv8.meaning mode_of_transport,
                       flv9.meaning freight_terms_code,
                       NVL (hp1.party_name, 'Unassigned') Carrier,
                       hp1.party_name Carrier_disp,
                       trip_id,
                       CASE
                          WHEN    (NVL (hp1.party_name, 'Unassigned') =
                                      'Unassigned')
                               OR (delivery_name = 'Unassigned')
                               OR (trip_name = 'Unassigned')
                               OR (exceptionid_detail IS NOT NULL)
                               OR (hold_flag IS NOT NULL)
                          THEN
                             'ecc_warning'
                          ELSE
                             'ecc_blank'
                       END
                          detail_alert_flag,
                       CASE
                          WHEN    (NVL (hp1.party_name, 'Unassigned') =
                                      'Unassigned')
                               OR (trip_name = 'Unassigned')
                               OR (NVL (exceptionid_detail,
                                        exceptionid_delivery)
                                      IS NOT NULL)
                               OR (hold_flag IS NOT NULL)
                          THEN
                             'ecc_warning'
                          ELSE
                             'ecc_blank'
                       END
                          delivery_alert_flag,
                       CASE
                          WHEN    (NVL (hp1.party_name, 'Unassigned') =
                                      'Unassigned')
                               OR (exceptionid_trip IS NOT NULL)
                               OR (hold_flag IS NOT NULL)
                          THEN
                             'ecc_warning'
                          ELSE
                             'ecc_blank'
                       END
                          trip_alert_flag,
                       inv_ecc_outbound_util_pvt.get_lookup_meaning (
                          DECODE (
                             exceptionid_detail,
                             NULL, DECODE (
                                      exceptionid_delivery,
                                      NULL, DECODE (exceptionid_trip,
                                                    NULL, 'N',
                                                    'Y'),
                                      'Y'),
                             'Y'),
                          'YES_NO',
                          0,
                          b.language)
                          exception_flag,
                       DECODE (hold_flag, 'Y', 'delete_16_full', 'ecc_blank')
                          hold_flag,
                       flv10.meaning otm_planning_status,
                       flv11.meaning shipment_priority_name,
                       shipping_instructions,
                       stop_sequence_number,
                       TRIM (wave_name) wave_name,
                       b.language
                  FROM (SELECT wdd.delivery_detail_id ecc_spec_id,
                               wdd.source_header_number order_number,
                               ooha.ordered_date ordered_date,
                               wdd.source_line_number line_number,
                               NVL (wnd.initial_pickup_date,
                                    wdd.date_scheduled)
                                  schedule_ship_date,
                               wdd.subinventory,
                               mil.concatenated_segments locator,
                               wdd.revision,
                               wdd.lot_number,
                               wdd.date_requested request_date,
                               wdd.delivery_detail_id,
                               wnd.delivery_id delivery_id,
                               NVL (wnd.name, 'Unassigned') delivery_name,
                               wnd.name delivery_name_disp,
                               flv1.meaning released_status,
                               (CASE
                                   WHEN    wdd.replenishment_status IN
                                              ('R', 'C')
                                        OR wdd.released_status = 'S'
                                   THEN
                                      5
                                   WHEN wdd.released_status IN ('R', 'B')
                                   THEN
                                      3
                                   WHEN wdd.released_status = 'Y'
                                   THEN
                                      7
                                   WHEN wdd.released_status = 'C'
                                   THEN
                                      9
                                END)
                                  released_status_bucket,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.delivery_detail_id =
                                              wdd.delivery_detail_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_detail,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.assigned_delivery_id =
                                              wnd.delivery_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_delivery,
                               (SELECT MIN (we.exception_id)
                                  FROM wsh_exceptions_v we
                                 WHERE     we.trip_id = wt.trip_id
                                       AND we.severity = 'ERROR'
                                       AND we.status = 'OPEN')
                                  exceptionid_trip,
                               msiv1.concatenated_segments item,
                               msiv1.inventory_item_id,
                               wdd.organization_id,
                               mp.organization_code organization_code,
                               CASE
                                  WHEN     wdd.requested_quantity < 1
                                       AND wdd.requested_quantity > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                                  ELSE
                                        wdd.requested_quantity
                                     || ' '
                                     || wdd.requested_quantity_uom
                               END
                                  quantity,
                               CASE
                                  WHEN     wdd.requested_quantity2 < 1
                                       AND wdd.requested_quantity2 > 0
                                  THEN
                                        '0'
                                     || wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                                  ELSE
                                        wdd.requested_quantity2
                                     || ' '
                                     || wdd.requested_quantity_uom2
                               END
                                  quantity2,
                               wl1.country ship_from_country,
                               wl2.country ship_to_country,
                               wl3.ui_location_code ship_from_location,
                               wl4.ui_location_code ship_to_location,
                               hp.party_name customer,
                               CASE
                                  WHEN wdd.weight_uom_code = muom1.uom_code
                                  THEN
                                     wdd.gross_weight
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.weight_uom_code,
                                        to_uom     => muom1.uom_code,
                                        quantity   => wdd.gross_weight,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  conv_gross_weight,
                               CASE
                                  WHEN wdd.gross_weight > 0
                                  THEN
                                        CASE
                                           WHEN wdd.weight_uom_code =
                                                   muom1.uom_code
                                           THEN
                                              wdd.gross_weight
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.weight_uom_code,
                                                 to_uom     => muom1.uom_code,
                                                 quantity   => wdd.gross_weight,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom1.uom_code
                               END
                                  weight_uom_code,
                               CASE
                                  WHEN wdd.volume_uom_code = muom2.uom_code
                                  THEN
                                     wdd.volume
                                  ELSE
                                     wsh_wv_utils.convert_uom (
                                        from_uom   => wdd.volume_uom_code,
                                        to_uom     => muom2.uom_code,
                                        quantity   => wdd.volume,
                                        item_id    => wdd.inventory_item_id,
                                        org_id     => wdd.organization_id)
                               END
                                  Volume,
                               CASE
                                  WHEN WDD.VOLUME > 0
                                  THEN
                                        CASE
                                           WHEN wdd.volume_uom_code =
                                                   muom2.uom_code
                                           THEN
                                              wdd.volume
                                           ELSE
                                              wsh_wv_utils.convert_uom (
                                                 from_uom   => wdd.volume_uom_code,
                                                 to_uom     => muom2.uom_code,
                                                 quantity   => wdd.volume,
                                                 item_id    => wdd.inventory_item_id,
                                                 org_id     => wdd.organization_id)
                                        END
                                     || ' '
                                     || muom2.uom_code
                               END
                                  volume_uom_code,
                               inv_ecc_outbound_util_pvt.get_converted_amount (
                                  wdd.org_id,
                                  wdd.currency_code,
                                  wdd.date_requested,
                                  NULL,
                                  NULL,
                                    DECODE (
                                       wdd.requested_quantity_uom,
                                       wdd.src_requested_quantity_uom, wdd.requested_quantity,
                                       inv_convert.inv_um_convert (
                                          wdd.inventory_item_id,
                                          5,
                                          wdd.requested_quantity,
                                          wdd.requested_quantity_uom,
                                          wdd.src_requested_quantity_uom,
                                          NULL,
                                          NULL))
                                  * oola.unit_selling_price)
                                  requested_quantity_value,
                               NVL (wt.name, 'Unassigned') trip_name,
                               wt.name trip_name_disp,
                               wnd.planned_flag,
                               wnd.initial_pickup_date,
                               wnd.ultimate_dropoff_date,
                               wnd.fob_code,
                               wnd.waybill,
                               wnd.gross_weight delivery_gross_weight,
                               CASE
                                  WHEN wnd.gross_weight > 0
                                  THEN
                                        wnd.gross_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_gross_weight_uom,
                               wnd.net_weight delivery_net_weight,
                               CASE
                                  WHEN wnd.net_weight > 0
                                  THEN
                                        wnd.net_weight
                                     || ' '
                                     || wnd.weight_uom_code
                               END
                                  delivery_net_weight_uom,
                               wnd.volume delivery_volume,
                               CASE
                                  WHEN wnd.volume > 0
                                  THEN
                                     wnd.volume || ' ' || wnd.volume_uom_code
                               END
                                  delivery_volume_uom,
                               wnd.confirm_date,
                               wt.status_code trip_status,
                               wt.vehicle_number,
                               wdd.source_header_type_name order_type,
                               wnd.status_code delivery_status,
                               wdd.released_status released_status_flag,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.ship_method_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.ship_method_code
                                  ELSE
                                     NULL
                               END
                                  ship_method_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.service_level
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.service_level
                                  ELSE
                                     NULL
                               END
                                  service_level,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.mode_of_transport
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.mode_of_transport
                                  ELSE
                                     NULL
                               END
                                  mode_of_transport,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.freight_terms_code
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.freight_terms_code
                                  ELSE
                                     NULL
                               END
                                  freight_terms_code,
                               CASE
                                  WHEN wt.trip_id IS NOT NULL
                                  THEN
                                     wt.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NOT NULL
                                  THEN
                                     wnd.carrier_id
                                  WHEN     wt.trip_id IS NULL
                                       AND wnd.delivery_id IS NULL
                                       AND wdd.delivery_detail_id IS NOT NULL
                                  THEN
                                     wdd.carrier_id
                                  ELSE
                                     NULL
                               END
                                  carrier_id,
                               wt.trip_id,
                               inv_ecc_outbound_util_pvt.GET_hold_flag (
                                  oh1.header_id,
                                  oh2.line_id)
                                  hold_flag,
                               DECODE (
                                  wsp.otm_enabled,
                                  'Y', DECODE (
                                          wdd.ignore_for_planning,
                                          'N', DECODE (wt.trip_id,
                                                       NULL, 'N',
                                                       'Y'),
                                          'X'),
                                  'X')
                                  otm_planned_flag,
                               wdd.shipment_priority_code,
                               wdd.shipping_instructions,
                               wts1.stop_sequence_number,
                               whtl.wave_name,
                               flv1.language
                          FROM oe_order_headers_all ooha,
                               oe_order_lines_all oola,
                               wsh_delivery_details wdd,
                               wsh_shipping_parameters wsp,
                               mtl_units_of_measure_tl muom1,
                               mtl_units_of_measure_tl muom2,
                               wsh_delivery_assignments wda,
                               mtl_item_locations_kfv mil,
                               wsh_new_deliveries wnd,
                               wsh_delivery_legs wdl,
                               wsh_trip_stops wts,
                               wsh_trip_stops wts1,
                               wsh_trips wt,
                               fnd_lookup_values flv1,
                               mtl_system_items_b_kfv msiv1,
                               hz_cust_accounts hca,
                               hz_parties hp,
                               oe_order_holds_all oh1,
                               oe_order_holds_all oh2,
                               wms_wp_wave_headers_tl whtl,
                               wms_wp_wave_lines wl,
                               mtl_parameters mp,
                               wsh_locations wl1,
                               wsh_locations wl2,
                               wsh_locations wl3,
                               wsh_locations wl4
                         WHERE     ooha.header_id = oola.header_id
                               AND wdd.source_header_id = ooha.header_id(+)
                               AND wdd.source_line_id = oola.line_id
                               AND wdd.released_status IN ('B',
                                                           'S',
                                                           'Y',
                                                           'R',
                                                           'C',
                                                           'D')
                               AND wdd.organization_id =
                                      mil.organization_id(+)
                               AND wdd.locator_id =
                                      mil.inventory_location_id(+)
                               AND wdd.organization_id = wsp.organization_id
                               AND wsp.weight_uom_class = muom1.uom_class
                               AND muom1.base_uom_flag = 'Y'
                               AND muom1.language = flv1.language
                               AND wsp.volume_uom_class = muom2.uom_class
                               AND muom2.base_uom_flag = 'Y'
                               AND muom2.language = flv1.language
                               AND wdd.delivery_detail_id =
                                      wda.delivery_detail_id(+)
                               AND wda.delivery_id = wnd.delivery_id(+)
                               AND wnd.delivery_id = wdl.delivery_id(+)
                               AND wdl.pick_up_stop_id = wts.stop_id(+)
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.initial_pickup_location_id =
                                          wts.stop_location_id)
                               AND wts.trip_id = wt.trip_id(+)
                               AND DECODE (
                                      wdd.released_status,
                                      'N', 'N',
                                      DECODE (wdd.replenishment_status,
                                              'R', 'E',
                                              'C', 'F',
                                              wdd.released_status)) =
                                      flv1.lookup_code
                               AND wdd.organization_id =
                                      msiv1.organization_id
                               AND wdd.inventory_item_id =
                                      msiv1.inventory_item_id
                               AND wdd.customer_id = hca.cust_account_id
                               AND hca.party_id = hp.party_id
                               AND flv1.lookup_type = 'PICK_STATUS'
                               AND ooha.header_id = oh1.header_id(+)
                               AND oh1.line_id(+) IS NULL
                               AND oola.line_id = oh2.line_id(+)
                               AND oh2.line_id(+) IS NOT NULL
                               AND wdd.delivery_detail_id =
                                      wl.delivery_detail_id(+)
                               AND wl.wave_header_id = whtl.wave_header_id(+)
                               AND NVL (whtl.language, flv1.language) =
                                      flv1.language
                               AND wdl.drop_off_stop_id = wts1.stop_id(+)
                               AND mp.organization_id(+) =
                                      wdd.organization_id
                               AND wl1.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl1.location_source_code(+) = 'HR'
                               AND wl2.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND wl2.location_source_code(+) = 'HZ'
                               AND wl3.wsh_location_id(+) =
                                      wdd.ship_from_location_id
                               AND wl4.wsh_location_id(+) =
                                      wdd.ship_to_location_id
                               AND (   wdl.delivery_id IS NULL
                                    OR wnd.ultimate_dropoff_location_id =
                                          wts1.stop_location_id)
                               AND hp.last_update_date >
                                      TO_DATE (
                                         TO_CHAR (
                                            TO_TIMESTAMP (
                                               '03-JUN-20 02.56.05.000000 PM'),
                                            'DD-MON-YY HH24.MI.SS'),
                                         'DD-MON-YY HH24.MI.SS')) b,
                       fnd_lookup_values flv2,
                       fnd_lookup_values flv3,
                       fnd_lookup_values flv4,
                       fnd_lookup_values flv5,
                       fnd_lookup_values flv6,
                       fnd_lookup_values flv7,
                       fnd_lookup_values flv8,
                       fnd_lookup_values flv9,
                       fnd_lookup_values flv10,
                       fnd_lookup_values flv11,
                       hz_parties hp1
                 WHERE     flv2.lookup_code(+) = B.planned_flag
                       AND flv2.lookup_type(+) = 'DELIVERY_PLANNED_FLAG'
                       AND flv2.view_application_id(+) = 665
                       AND flv2.language(+) = B.language
                       AND flv3.lookup_code(+) = B.fob_code
                       AND flv3.lookup_type(+) = 'FOB'
                       AND flv3.view_application_id(+) = '222'
                       AND flv3.language(+) = B.language
                       AND flv4.lookup_type(+) = 'TRIP_STATUS'
                       AND flv4.lookup_code(+) = B.trip_status
                       AND flv4.language(+) = B.language
                       AND flv5.lookup_type(+) = 'DELIVERY_STATUS'
                       AND flv5.lookup_code(+) = B.delivery_status
                       AND flv5.language(+) = B.language
                       AND flv6.lookup_code(+) = B.ship_method_code
                       AND flv6.lookup_type(+) = 'SHIP_METHOD'
                       AND flv6.view_application_id(+) = 3
                       AND flv6.language(+) = B.language
                       AND flv7.lookup_code(+) = B.service_level
                       AND flv7.lookup_type(+) = 'WSH_SERVICE_LEVELS'
                       AND flv7.view_application_id(+) = 665
                       AND flv7.language(+) = B.language
                       AND flv8.lookup_code(+) = B.mode_of_transport
                       AND flv8.lookup_type(+) = 'WSH_MODE_OF_TRANSPORT'
                       AND flv8.view_application_id(+) = 665
                       AND flv8.language(+) = B.language
                       AND flv9.lookup_code(+) = B.freight_terms_code
                       AND flv9.lookup_type(+) = 'FREIGHT_TERMS'
                       AND flv9.view_application_id(+) = 660
                       AND flv9.language(+) = B.language
                       AND flv10.lookup_code(+) = B.otm_planned_flag
                       AND flv10.lookup_type(+) = 'ECC_OTM_PLANNING_STATUS'
                       AND flv10.view_application_id(+) = 665
                       AND flv10.language(+) = B.language
                       AND flv11.lookup_code(+) = B.shipment_priority_code
                       AND flv11.lookup_type(+) = 'SHIPMENT_PRIORITY'
                       AND flv11.view_application_id(+) = 660
                       AND flv11.language(+) = B.language
                       AND hp1.party_id(+) = B.carrier_id) X1,
               (SELECT 'WSH_WDD_ROW_ID',
                       'WSH_WDD_CONTEXT_VALUE',
                       'WSH_WDD_CONCATENATED_SEGMENTS'
                  FROM DUAL
                 WHERE 1 = 2
                UNION
                SELECT ROWIDTOCHAR (ROW_ID),
                       CONTEXT_VALUE,
                       CONCATENATED_SEGMENTS
                  FROM WSH_DELIVERY_DETAILS_DFV) wdd_dfv,
               wsh_delivery_details wdd_X1,
               (SELECT 'WSH_WND_ROW_ID',
                       'WSH_WND_CONTEXT_VALUE',
                       'WSH_WND_CONCATENATED_SEGMENTS'
                  FROM DUAL
                 WHERE 1 = 2
                UNION
                SELECT ROWIDTOCHAR (ROW_ID),
                       CONTEXT_VALUE,
                       CONCATENATED_SEGMENTS
                  FROM WSH_NEW_DELIVERIES_DFV) wnd_dfv,
               wsh_new_deliveries wnd_X1
         WHERE     wdd_X1.ROWID = wdd_dfv."'WSH_WDD_ROW_ID'"(+)
               AND X1.delivery_detail_id = wdd_X1.delivery_detail_id
               AND wnd_X1.ROWID = wnd_dfv."'WSH_WND_ROW_ID'"(+)
               AND X1.delivery_id = wnd_X1.delivery_id(+)
               AND X1.language IN ('US')
               AND EXISTS
                      (SELECT 1
                         FROM fnd_lookup_values
                        WHERE     lookup_type = 'INV_ECC_ORG_CONTROL'
                              AND lookup_code IN
                                     ('ALL', (x1.organization_code))
                              AND enabled_flag = 'Y'
                              AND language = x1.language
                              AND VIEW_APPLICATION_ID = 3
                              AND SYSDATE BETWEEN start_date_active
                                              AND NVL (end_date_active,
                                                       SYSDATE)))
       PIVOT
          (MAX (RELEASED_STATUS)
          AS RELEASED_STATUS, MAX (PLANNED_FLAG)
          AS PLANNED_FLAG, MAX (FOB_CODE)
          AS FOB_CODE, MAX (SHIP_METHOD)
          AS SHIP_METHOD, MAX (SERVICE_LEVEL)
          AS SERVICE_LEVEL, MAX (MODE_OF_TRANSPORT)
          AS MODE_OF_TRANSPORT, MAX (FREIGHT_TERMS_CODE)
          AS FREIGHT_TERMS_CODE, MAX (DELIVERY_STATUS)
          AS DELIVERY_STATUS, MAX (TRIP_STATUS)
          AS TRIP_STATUS, MAX (EXCEPTION_FLAG)
          AS EXCEPTION_FLAG, MAX (OTM_PLANNING_STATUS)
          AS OTM_PLANNING_STATUS, MAX (SHIPMENT_PRIORITY_NAME)
          AS SHIPMENT_PRIORITY_NAME, MAX (WAVE_NAME)
          AS WAVE_NAME
          FOR LANGUAGE
          IN ('US' "US"))