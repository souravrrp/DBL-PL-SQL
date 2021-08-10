/* Formatted on 2/25/2020 11:04:34 AM (QP5 v5.287) */
  SELECT hu.legal_entity_name unit_name,
         pha.segment1 "PO Number",
         pla.line_num,
         pha.po_header_id,
         pha.org_id,
         pha.authorization_status,
         pha.creation_date,
         pha.approved_date,
         pha.currency_code,
         sup.vendor_name,
         sups.vendor_site_code,
         pll.ship_to_organization_id,
         DECODE (pha.attribute_category,
                 'STANDARD', pha.attribute13,
                 pha.attribute13)
            buyer_id,
         SYSDATE,
            loc.address_line_1
         || ' '
         || loc.address_line_2
         || ' '
         || loc.address_line_3
         || ' '
         || loc.region_1
         || ' '
         || loc.region_2
         || ' '
         || loc.region_3
         || ' '
         || loc.town_or_city
         || ' '
         || 'Bangladesh'
            location,
         msi.segment1 "Item Code",
         SUBSTR (msi.description, 6, 500) || ' ' || pla.note_to_vendor
            description,
         SUBSTR (msi.description, 1, 4) "Yarn Count",
         SUBSTR (TO_CHAR (SYSDATE, 'DD-MON-YYYY'), 8, 11) "Year",
            'MSML'
         || '/'
         || hu.unit_name
         || '/'
         || SUBSTR (TO_CHAR (SYSDATE, 'DD-MON-YYYY'), 8, 11)
         || '/'
         || NVL (pi.fucn1, 0)
            "PI Number",
         pla.unit_meas_lookup_code uom,
         pll.quantity,
         pla.unit_price,
         pll.quantity * pla.unit_price total_amount,
         -- :bank
         CASE :bank
            WHEN 'HSBC Limited'
            THEN
               'HSBC Bank Limited, Global Trade and Receivable Finance Transaction Services, Level-12, Shanta Western Tower, 186 Bir Uttam Mir Shawkat Ali Road, Tejgoan, I/A, Dhaka-1208.'
            WHEN 'The City Bank Limited'
            THEN
               'The City Bank Limited , Trade Service Division, Al Amin Center,7th Floor, 25/1 Dilkusha C/A, Dhaka-100'
            WHEN 'BRACK Bank Limited'
            THEN
               'BRACK Bank Ltd., Anik Tower,220/B,Tejgoan Link Road, Gulshan-01, Dhaka-1208'
            ELSE
               NULL
         END
            Bank_address,
         CASE :bank
            WHEN 'HSBC Limited' THEN 'HSBCBDDH'
            WHEN 'The City Bank Limited' THEN 'CIBLBDDHXX'
            WHEN 'BRACK Bank Limited' THEN 'BRAKBDDHXX'
            ELSE 'No Swift Code Selected'
         END
            Swift,
         :Tenor_number || ' ' || 'Days' Tenor,
         :at_shight shight,
         :p_revised Revised_name,
         :p_max_number MAX
    FROM apps.po_headers_all pha,
         apps.ap_suppliers sup,
         apps.ap_supplier_sites_all sups,
         apps.po_lines_all pla,
         apps.po_line_locations_all pll,
         apps.mtl_system_items_b msi,
         apps.hr_organization_units hou,
         apps.xxdbl_company_le_mapping_v hu,
         apps.hr_locations_all_v loc,
         apps.xx_dbl_po_recv_adjust pi
   WHERE     pha.po_header_id = pla.po_header_id
         AND pha.org_id = hu.org_id
         AND pha.org_id = pla.org_id
         AND pha.vendor_id = sup.vendor_id
         AND sup.vendor_id = sups.vendor_id
         AND pha.vendor_site_id = sups.vendor_site_id(+)
         AND pha.po_header_id = pll.po_header_id
         AND pla.po_line_id = pll.po_line_id
         AND pla.item_id = msi.inventory_item_id(+)
         AND pll.ship_to_organization_id = msi.organization_id(+)
         AND pll.ship_to_organization_id = hou.organization_id(+)
         AND hou.location_id = loc.location_id(+)
         AND pha.segment1 = pi.po_no(+)
         AND NVL (pll.cancel_flag, 'N') = 'N'
         AND pll.cancel_date IS NULL
         -- and pha.org_id=:p_org
         AND pha.segment1 = :p_po_number
ORDER BY pla.line_num