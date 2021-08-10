/* Formatted on 6/21/2020 1:59:07 PM (QP5 v5.287) */
  SELECT *
    FROM (SELECT po.segment1 AS po_number,
                 po.revision_num AS revision,
                 po.currency_code AS currency,
                 hr1.location_code AS ship_to_location,
                 po.ship_via_lookup_code AS ship_via,
                 po.fob_lookup_code AS fob,
                 hr2.location_code AS bill_to_location,
                 terms.NAME AS payment_terms,
                 po.freight_terms_lookup_code AS feight,
                 he.full_name AS buyer,
                 po.po_header_id AS po_header_id,
                 po.ship_to_location_id AS ship_to_location_id,
                 po.bill_to_location_id AS bill_to_location_id,
                 po.agent_id AS agent_id,
                 TO_NUMBER (NULL) AS po_release_id,
                 po.type_lookup_code,
                 NVL (global_agreement_flag, 'N'),
                 po.org_id
            FROM po_headers_archive_all po,
                 ap_terms_val_v terms,
                 hr_locations_all_tl hr1,
                 hr_locations_all_tl hr2,
                 per_all_people_f he
           WHERE     po.terms_id = terms.term_id(+)
                 AND po.ship_to_location_id = hr1.location_id(+)
                 AND po.bill_to_location_id = hr2.location_id(+)
                 AND he.person_id(+) = po.agent_id
                 AND TRUNC (SYSDATE) BETWEEN he.effective_start_date(+)
                                         AND he.effective_end_date(+)
                 AND latest_external_flag = 'Y'
                 AND hr1.LANGUAGE(+) = USERENV ('LANG')
                 AND hr2.LANGUAGE(+) = USERENV ('LANG')
          UNION ALL
          SELECT po.segment1 || '-' || por.release_num AS po_number,
                 por.revision_num,
                 po.currency_code AS currency,
                 hr1.location_code AS ship_to_location,
                 po.ship_via_lookup_code AS ship_via,
                 po.fob_lookup_code AS fob,
                 hr2.location_code AS bill_to_location,
                 terms.NAME AS payment_terms,
                 po.freight_terms_lookup_code AS feight,
                 he.full_name AS buyer,
                 po.po_header_id AS po_header_id,
                 po.ship_to_location_id AS ship_to_location_id,
                 po.bill_to_location_id AS bill_to_location_id,
                 po.agent_id AS agent_id,
                 por.po_release_id AS po_release_id,
                 po.type_lookup_code,
                 NVL (global_agreement_flag, 'N'),
                 por.org_id
            FROM po_headers_archive_all po,
                 po_releases_archive_all por,
                 ap_terms_val_v terms,
                 hr_locations_all_tl hr1,
                 hr_locations_all_tl hr2,
                 per_all_people_f he
           WHERE     po.po_header_id = por.po_header_id
                 AND po.terms_id = terms.term_id(+)
                 AND po.ship_to_location_id = hr1.location_id(+)
                 AND po.bill_to_location_id = hr2.location_id(+)
                 AND he.person_id(+) = po.agent_id
                 AND TRUNC (SYSDATE) BETWEEN he.effective_start_date(+)
                                         AND he.effective_end_date(+)
                 AND por.latest_external_flag = 'Y'
                 AND po.latest_external_flag = 'Y'
                 AND hr1.LANGUAGE(+) = USERENV ('LANG')
                 AND hr2.LANGUAGE(+) = USERENV ('LANG')) qrslt
   WHERE 1 = 1 --AND po_header_id = :1 
   AND po_number='10323009890'
   --AND po_release_id IS NULL
ORDER BY revision DESC


Select *
from po_headers_Archive_all
where po_header_id='51186'
--AND REVISION_NUM='16'

Check for the revision number in
po_headers_all,
po_headers_archive_all,
po_lines_archive_all,
po_line_locations_archive_all
and po_distributions_archive_all.


SELECT PHA.SEGMENT1 PO_NUM,
         PHA.REVISION_NUM,
         PLA.LINE_NUM PO_LINE_NUM,
         PLLA.SHIPMENT_NUM,
         PLA.ITEM_DESCRIPTION,
         PLA.UNIT_MEAS_LOOKUP_CODE,
         PLA.LIST_PRICE_PER_UNIT,
         PLA.CANCEL_FLAG,
         PLA.CANCEL_DATE,
         PLA.QUANTITY PO_LINE_QUANTITY,
         PHA.AUTHORIZATION_STATUS HEADER_APPROVAL_STATUS,
         PHA.APPROVED_FLAG HEADER_APPROVED_FLAG,
         PHA.APPROVED_DATE HEADER_APPROVED_DATE,
         PHA.CLOSED_CODE HEADER_CLOSURE_STATUS,
         PLA.CLOSED_CODE LINE_CLOSURE_STATUS,
         PLLA.CLOSED_CODE SHIPMENT_CLORSURE_STATUS,
         PLLA.APPROVED_FLAG SHIPMENT_APPROVED_FLAG,
         PLLA.APPROVED_DATE SHIPMENT_APPROVED_DATE,
         PHA.CANCEL_FLAG PO_CANCEL_FLAG,
         PLA.CANCEL_FLAG LINE_CANCEL_FLAG,
         PLLA.CANCEL_FLAG SHIPMENT_CANCEL_FLAG,
         PHA.ORG_ID,
         PV.VENDOR_NAME,
         APSS.VENDOR_SITE_CODE,
         PLA.*
    FROM PO.PO_LINE_LOCATIONS_ARCHIVE_ALL PLLA,
         PO.PO_LINES_ARCHIVE_ALL PLA,
         --PO.PO_LINES_ARCHIVE_ALL PLA2,
         PO.PO_HEADERS_ARCHIVE_ALL PHA,
         APPS.PO_VENDORS PV,
         APPS.AP_SUPPLIER_SITES_ALL APSS
   WHERE     1 = 1
         AND PLA.PO_LINE_ID = PLLA.PO_LINE_ID
         --AND PLA.PO_LINE_ID = PLA2.PO_LINE_ID
         --AND PLA.LINE_NUM = PLA2.LINE_NUM
         --AND PLA.REVISION_NUM != PLA2.REVISION_NUM
         --AND PLA.QUANTITY != PLA2.QUANTITY
         AND PLA.CANCEL_FLAG = 'N'
         AND EXISTS
                (SELECT 1
                   FROM PO.PO_LINES_ARCHIVE_ALL PLA2
                  WHERE     PLA.PO_LINE_ID = PLA2.PO_LINE_ID
                        AND PLA.LINE_NUM = PLA2.LINE_NUM
                        AND PLA.REVISION_NUM > PLA2.REVISION_NUM)
         AND PHA.VENDOR_ID = PV.VENDOR_ID
         AND PHA.VENDOR_SITE_ID = APSS.VENDOR_SITE_ID
         AND PLA.PO_HEADER_ID = PLLA.PO_HEADER_ID
         AND PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
         AND pha.VENDOR_ID = '2550'
         AND PHA.VENDOR_SITE_ID = '9873'
         AND PHA.SEGMENT1 IN ('10323009890')
         AND PHA.REVISION_NUM = PLA.REVISION_NUM
         AND PLA.REVISION_NUM = PLLA.REVISION_NUM
         AND PHA.REVISION_NUM = PLLA.REVISION_NUM
ORDER BY PHA.SEGMENT1, PLA.LINE_NUM, PLLA.SHIPMENT_NUM;