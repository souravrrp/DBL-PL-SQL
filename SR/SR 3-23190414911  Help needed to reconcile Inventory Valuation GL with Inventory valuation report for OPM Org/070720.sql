/* Formatted on 7/8/2020 11:03:28 AM (QP5 v5.287) */
--1)

SELECT *
  FROM xla_accounting_errors
 WHERE event_id IN (4940534, 4940535);

--2)

  SELECT xle.code_combination_id,
         xle.accounting_class_code,
         xe.event_status_code,
         xe.process_status_code,
         xlh.gl_transfer_status_code,
         xlh.accounting_entry_status_code,
         SUM (xle.entered_dr),
         SUM (xle.entered_cr),
         SUM (xle.accounted_dr),
         SUM (xle.accounted_cr)
    FROM xla_ae_lines xle,
         xla_ae_headers xlh,
         gmf_xla_extract_headers eh,
         xla_events xe
   WHERE     xle.ae_header_id = xlh.ae_header_id
         AND xlh.event_id = eh.event_id
         AND xe.event_id = eh.event_id
         AND xe.event_id = xlh.event_id
         AND xle.application_id = 555
         AND xle.accounting_class_code IN
                ('INVENTORY_VALUATION', 'PURCHASE_PRICE_VARIANCE')
         AND eh.transaction_date >=
                TO_DATE ('01/12/19 00:00:00', 'dd/mm/yy hh24:mi:ss') -- Change to first date of the current period
         AND eh.transaction_date <=
                TO_DATE ('31/12/19 23:59:59', 'dd/mm/yy hh24:mi:ss') -- Change to last date of the current period
         AND eh.legal_entity_id = :ente_legal_entity_id
         AND eh.ledger_id = :Enter_ledger_id
         AND eh.organization_id = :enter_organization_id
GROUP BY xle.code_combination_id,
         xle.accounting_class_code,
         xe.event_status_code,
         xe.process_status_code,
         xlh.gl_transfer_status_code,
         xlh.accounting_entry_status_code;

--3)

  SELECT xle.code_combination_id,
         xle.accounting_class_code,
         xe.event_status_code,
         xe.process_status_code,
         xlh.gl_transfer_status_code,
         xlh.accounting_entry_status_code,
         SUM (xle.entered_dr),
         SUM (xle.entered_cr),
         SUM (xle.accounted_dr),
         SUM (xle.accounted_cr)
    FROM xla_ae_lines xle,
         xla_ae_headers xlh,
         gmf_xla_extract_headers eh,
         xla_events xe
   WHERE     xle.ae_header_id = xlh.ae_header_id
         AND xlh.event_id = eh.event_id
         AND xe.event_id = eh.event_id
         AND xe.event_id = xlh.event_id
         AND xle.application_id = 555
         --AND xle.code_combination_id IN (< ENTER all code_combination_ids from above query>)
         AND eh.transaction_date >=
                TO_DATE ('01/12/19 00:00:00', 'dd/mm/yy hh24:mi:ss') -- Change to first date of the current period
         AND eh.transaction_date <=
                TO_DATE ('31/12/19 23:59:59', 'dd/mm/yy hh24:mi:ss') -- Change to last date of the current period
         AND eh.legal_entity_id = :ente_legal_entity_id
         AND eh.ledger_id = :Enter_ledger_id
         AND eh.organization_id = :enter_organization_id
GROUP BY xle.code_combination_id,
         xle.accounting_class_code,
         xe.event_status_code,
         xe.process_status_code,
         xlh.gl_transfer_status_code,
         xlh.accounting_entry_status_code;