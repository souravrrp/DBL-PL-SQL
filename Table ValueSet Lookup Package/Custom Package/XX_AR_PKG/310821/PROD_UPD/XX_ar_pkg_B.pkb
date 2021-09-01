/* Formatted on 8/31/2021 10:39:15 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xx_ar_pkg
AS
   FUNCTION get_party_site_address (p_party_site_id NUMBER)
      RETURN VARCHAR2
   AS
      v_address   VARCHAR2 (500);
   BEGIN
      SELECT hz_format_pub.format_address (arhzpartysiteseo.location_id,
                                           NULL,
                                           NULL,
                                           ' ')
        INTO v_address
        FROM hz_party_sites arhzpartysiteseo, hz_locations arhzlocationseo
       WHERE     arhzpartysiteseo.party_site_id = p_party_site_id
             AND arhzpartysiteseo.location_id = arhzlocationseo.location_id;

      RETURN (v_address);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'No Address Found';
   END;

   FUNCTION get_bank_short_code (p_bank_acct_use_id NUMBER)
      RETURN VARCHAR2
   IS
      v_short_code   VARCHAR2 (100);
   BEGIN
      SELECT short_bank_name
        INTO v_short_code
        FROM ce_bank_acct_uses_all au,
             ce_bank_accounts ba,
             ce_bank_branches_v bb
       WHERE     au.bank_account_id = ba.bank_account_id
             AND ba.bank_id = bb.bank_party_id
             AND ba.bank_branch_id = bb.branch_party_id
             AND bank_acct_use_id = p_bank_acct_use_id;

      RETURN (v_short_code);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 'No Bank';
   END get_bank_short_code;

   FUNCTION get_customer_address (p_customer_id IN NUMBER)
      RETURN VARCHAR2
   AS
      v_result   VARCHAR2 (512);
   BEGIN
      SELECT party.address1 || ', ' || party.address2
        INTO v_result
        FROM hz_parties party, hz_cust_accounts cust_acct
       WHERE     party.party_id = cust_acct.party_id
             AND cust_account_id = p_customer_id;

      RETURN v_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'Not a Valid Customer';
   END get_customer_address;

   FUNCTION get_state_wise_sum_from_acc_id (p_org_id        NUMBER,
                                            p_account_id    NUMBER,
                                            p_state         VARCHAR2,
                                            p_date_from     DATE,
                                            p_date_to       DATE)
      RETURN NUMBER
   AS
      v_result   NUMBER;

      CURSOR p_cursor
      IS
         SELECT SUM (NVL (amount, 0))
           FROM xx_ar_cash_receipts_v
          WHERE     org_id = p_org_id
                AND remit_bank_account_id = p_account_id
                AND state = p_state
                ----  AND NVL (TYPE, 'AKG') = 'MISC'
                AND gl_date BETWEEN p_date_from AND p_date_to;
   BEGIN
      OPEN p_cursor;

      FETCH p_cursor INTO v_result;

      CLOSE p_cursor;

      RETURN NVL (v_result, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_state_wise_sum_from_acc_id;

   FUNCTION get_customer_name_with_number (p_customer_id IN NUMBER)
      RETURN VARCHAR2
   IS
      v_result   VARCHAR2 (360);

      CURSOR p_cursor
      IS
         SELECT cust.account_number || ' - ' || party.party_name
           FROM hz_cust_accounts cust, hz_parties party
          WHERE     cust.party_id = party.party_id
                AND cust.cust_account_id = p_customer_id;
   BEGIN
      OPEN p_cursor;

      FETCH p_cursor INTO v_result;

      CLOSE p_cursor;

      RETURN (v_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'Not a Valid Customer';
   END get_customer_name_with_number;

   FUNCTION get_customer_open_balance (p_org_id         NUMBER,
                                       p_customer_id    NUMBER,
                                       p_date           DATE)
      RETURN NUMBER
   IS
      v_result   NUMBER;

      CURSOR p_cursor
      IS
         SELECT NVL (SUM (NVL (total, 0)), 0)
           FROM xx_ar_customer_ledger_v ps
          WHERE     ps.org_id = p_org_id
                AND ps.customer_id = p_customer_id
                AND gl_date < p_date;
   BEGIN
      OPEN p_cursor;

      FETCH p_cursor INTO v_result;

      CLOSE p_cursor;

      RETURN (v_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_customer_open_balance;

   FUNCTION get_shipment_wise_ar (p_org_id         NUMBER,
                                  p_customer_id    NUMBER,
                                  p_shipment_id    NUMBER)
      RETURN NUMBER
   AS
      v_result   NUMBER;

      CURSOR p_cursor
      IS
         SELECT NVL (SUM (NVL (ctl.extended_amount, 0)), 0)
           FROM ra_customer_trx_lines_all ctl, ra_customer_trx_all ct
          WHERE     ctl.customer_trx_id = ct.customer_trx_id
                AND ctl.line_type = 'LINE'
                AND NOT EXISTS
                       (SELECT *
                          FROM xx_ar_br_assignments_v aba
                         WHERE aba.br_ref_customer_trx_id =
                                  ctl.customer_trx_id)
                AND ct.attribute1 = p_shipment_id
                AND ct.org_id = p_org_id
                AND ct.bill_to_customer_id = p_customer_id;
   BEGIN
      OPEN p_cursor;

      FETCH p_cursor INTO v_result;

      CLOSE p_cursor;

      RETURN NVL (v_result, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_shipment_wise_ar;

   FUNCTION get_shipment_wise_br (p_org_id         NUMBER,
                                  p_customer_id    NUMBER,
                                  p_shipment_id    NUMBER)
      RETURN NUMBER
   AS
      v_result   NUMBER;

      CURSOR p_cursor
      IS
         SELECT NVL (SUM (NVL (ctl.extended_amount, 0)), 0)
           FROM xx_ar_br_assignments_v aba,
                ra_customer_trx_lines_all ctl,
                ra_customer_trx_all ct
          WHERE     aba.br_ref_customer_trx_id = ctl.customer_trx_id
                AND ctl.customer_trx_id = ct.customer_trx_id
                AND ctl.line_type = 'LINE'
                AND EXISTS
                       (SELECT *
                          FROM ar_transaction_history_all tha
                         WHERE     tha.customer_trx_id = aba.customer_trx_id
                               AND current_record_flag = 'Y'
                               AND status = 'PENDING_REMITTANCE')
                AND ct.attribute1 = p_shipment_id
                AND ct.org_id = p_org_id
                AND ct.bill_to_customer_id = p_customer_id;
   BEGIN
      OPEN p_cursor;

      FETCH p_cursor INTO v_result;

      CLOSE p_cursor;

      RETURN NVL (v_result, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_shipment_wise_br;

   FUNCTION get_shipment_wise_realization (p_org_id         NUMBER,
                                           p_customer_id    NUMBER,
                                           p_shipment_id    NUMBER)
      RETURN NUMBER
   AS
      v_result   NUMBER;

      CURSOR p_cursor
      IS
         SELECT NVL (SUM (NVL (ctl.extended_amount, 0)), 0)
           FROM xx_ar_receivable_appl_v ara,
                xx_ar_br_assignments_v aba,
                ra_customer_trx_lines_all ctl,
                ra_customer_trx_all ct
          WHERE     aba.customer_trx_id = ara.customer_trx_id
                AND aba.br_ref_customer_trx_id = ctl.customer_trx_id
                AND ctl.customer_trx_id = ct.customer_trx_id
                AND ctl.line_type = 'LINE'
                AND ct.attribute1 = p_shipment_id
                AND ct.bill_to_customer_id = p_customer_id
                AND ct.org_id = p_org_id;
   BEGIN
      OPEN p_cursor;

      FETCH p_cursor INTO v_result;

      CLOSE p_cursor;

      RETURN NVL (v_result, 0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_shipment_wise_realization;

   FUNCTION get_cci_from_code (p_cc_code VARCHAR2)
      RETURN NUMBER
   IS
      v_cci   NUMBER;
   BEGIN
      SELECT code_combination_id
        INTO v_cci
        FROM gl_code_combinations_kfv
       WHERE concatenated_segments = p_cc_code;

      RETURN (v_cci);
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_trx_number (p_customer_trx_id IN NUMBER)
      RETURN VARCHAR2
   AS
      v_ar_invoice_no   VARCHAR2 (4000);
   BEGIN
      SELECT RTRIM (
                XMLAGG (XMLELEMENT (s, cta.trx_number || ',')).EXTRACT (
                   '//text()'),
                ',')
        INTO v_ar_invoice_no
        FROM ra_customer_trx_all ctb,
             ra_customer_trx_lines_all ctl,
             ra_customer_trx_all cta
       WHERE     ctb.customer_trx_id = ctl.customer_trx_id
             AND ctl.br_ref_customer_trx_id = cta.customer_trx_id
             AND ctb.customer_trx_id = p_customer_trx_id;

      RETURN v_ar_invoice_no;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;

   FUNCTION get_challan_no (p_customer_trx_id IN NUMBER)
      RETURN VARCHAR2
   AS
      ar_challan_no   VARCHAR2 (4000);
   BEGIN
      SELECT /*rtrim (
                         xmlagg (
                            XMLElement (s, decode (cta.attribute_category,
                         'Export', cta.attribute3,
                         cta.attribute10) || ',')).getClobVal(),
                         ',')*/
            MAX (
                DECODE (cta.attribute_category,
                        'Export', cta.attribute3,
                        cta.attribute10))
        INTO ar_challan_no
        FROM ra_customer_trx_all ctb,
             ra_customer_trx_lines_all ctl,
             ra_customer_trx_all cta
       WHERE     ctb.customer_trx_id = ctl.customer_trx_id
             AND ctl.br_ref_customer_trx_id = cta.customer_trx_id
             AND ctb.customer_trx_id = p_customer_trx_id;

      RETURN ar_challan_no;
   END;

   FUNCTION get_customer_refund (p_org_id         NUMBER,
                                 p_customer_id    NUMBER,
                                 p_date_from      DATE,
                                 p_date_to        DATE)
      RETURN NUMBER
   IS
      v_result   NUMBER;

      CURSOR p_cursor
      IS
         SELECT NVL (SUM (NVL (pay.base_amount, pay.amount)), 0)
           FROM hz_cust_accounts cust,
                hz_parties party,
                ap_checks_all pay,
                (SELECT clr.check_id, clr.accounting_date
                   FROM ap_payment_history_all clr
                  WHERE     NOT EXISTS
                               (SELECT 1
                                  FROM ap_payment_history_all rev
                                 WHERE clr.payment_history_id =
                                          rev.rev_pmt_hist_id)
                        AND clr.transaction_type = 'PAYMENT CLEARING') cler
          WHERE     cust.party_id = party.party_id
                AND party.party_id = pay.party_id
                AND pay.status_lookup_code IS NOT NULL
                AND cler.check_id(+) = pay.check_id
                AND NVL (pay.status_lookup_code, 'X') <> 'VOIDED'
                AND pay.org_id = p_org_id
                AND cust.cust_account_id = p_customer_id
                AND TRUNC (NVL (accounting_date, pay.check_date)) BETWEEN p_date_from
                                                                      AND p_date_to;
   BEGIN
      OPEN p_cursor;

      FETCH p_cursor INTO v_result;

      CLOSE p_cursor;

      RETURN (v_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END get_customer_refund;

   FUNCTION get_cust_opening_bal (p_org_id         NUMBER,
                                  p_customer_id    NUMBER,
                                  p_date_as_on     DATE)
      RETURN NUMBER
   AS
      v_balance   NUMBER;
      v_refund    NUMBER;

      CURSOR p_cursor
      IS
         SELECT NVL (
                   SUM (
                        NVL (ps.amount_due_original, 0)
                      * NVL (ps.exchange_rate, 1)),
                   0)
           --  -NVL(AMOUNT_ADJUSTED,0)
           FROM ar_payment_schedules_all ps
          WHERE     ps.customer_id = p_customer_id
                AND ps.org_id = p_org_id
                AND ps.CLASS <> 'BR'
                AND ps.gl_date < p_date_as_on
                AND NOT EXISTS
                       (SELECT 1
                          FROM ar_cash_receipts_all cr
                         WHERE     ps.cash_receipt_id = cr.cash_receipt_id
                               AND ps.org_id = cr.org_id
                               AND NVL (cr.status, 'AKG') IN
                                      ('CCRR',
                                       'CC_CHARGEBACK_REV',
                                       'NSF',
                                       'REV',
                                       'STOP'));
   BEGIN
      v_refund :=
         get_customer_refund (p_org_id,
                              p_customer_id,
                              TO_DATE ('01-JAN-2013', 'DD-MON-YYYY'),
                              p_date_as_on - 1);

      OPEN p_cursor;

      FETCH p_cursor INTO v_balance;

      CLOSE p_cursor;

      ---- <''05-MAY-2011'=-500686990 AND <'30-MAR-2011'=-500678990
      RETURN (v_balance + v_refund);
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_br_trx_num (p_loan_id IN NUMBER)
      RETURN VARCHAR2
   AS
      v_result   VARCHAR2 (4000);

      CURSOR p_cursor
      IS
         SELECT RTRIM (
                   XMLAGG (XMLELEMENT (s, trx_number || ',')).EXTRACT (
                      '//text()'),
                   ',')
           FROM xx_ar_br_bill_discount_map_all
          WHERE loan_id = p_loan_id;
   BEGIN
      OPEN p_cursor;

      FETCH p_cursor INTO v_result;

      CLOSE p_cursor;

      RETURN (v_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END get_br_trx_num;

   FUNCTION get_br_trx_date (p_loan_id IN NUMBER)
      RETURN VARCHAR2
   AS
      v_result   VARCHAR2 (4000);

      CURSOR p_cursor
      IS
         SELECT RTRIM (
                   XMLAGG (XMLELEMENT (s, trx_date || ',')).EXTRACT (
                      '//text()'),
                   ',')
           FROM xx_ar_br_bill_discount_map_all
          WHERE loan_id = p_loan_id;
   BEGIN
      OPEN p_cursor;

      FETCH p_cursor INTO v_result;

      CLOSE p_cursor;

      RETURN (v_result);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END get_br_trx_date;

   FUNCTION get_br_amount (p_org_id             NUMBER,
                           p_customer_id        NUMBER,
                           p_customer_trx_id    NUMBER,
                           p_status             VARCHAR2,
                           p_date_from          DATE,
                           p_date_to            DATE)
      RETURN NUMBER
   AS
      v_output   NUMBER;
   BEGIN
      SELECT CASE
                WHEN p_status = 'ENTERED' THEN SUM (amount)
                WHEN p_status = 'ACCTD' THEN SUM (acctd_amount)
                ELSE 0
             END
        INTO v_output
        FROM ar_adjustments_all adj, ra_customer_trx_all ct
       WHERE     adj.customer_trx_id = ct.customer_trx_id
             AND UPPER (adj.adjustment_type) = 'X'
             AND adj.status = 'A'
             AND adj.org_id = p_org_id
             AND ct.bill_to_customer_id = p_customer_id
             AND adj.customer_trx_id = p_customer_trx_id
             AND TRUNC (adj.gl_date) BETWEEN p_date_from AND p_date_to;

      RETURN v_output;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_adj_amount (p_org_id             NUMBER,
                            p_customer_id        NUMBER,
                            p_customer_trx_id    NUMBER,
                            p_status             VARCHAR2,
                            p_date_from          DATE,
                            p_date_to            DATE)
      RETURN NUMBER
   AS
      v_output   NUMBER;
   BEGIN
      SELECT CASE
                WHEN p_status = 'ENTERED' THEN SUM (amount)
                WHEN p_status = 'ACCTD' THEN SUM (acctd_amount)
                ELSE 0
             END
        INTO v_output
        FROM ar_adjustments_all adj, ra_customer_trx_all ct
       WHERE     adj.customer_trx_id = ct.customer_trx_id
             AND UPPER (adj.adjustment_type) = 'M'
             AND adj.status = 'A'
             AND adj.org_id = p_org_id
             AND ct.bill_to_customer_id = p_customer_id
             AND adj.customer_trx_id = p_customer_trx_id
             AND TRUNC (adj.gl_date) BETWEEN p_date_from AND p_date_to;

      RETURN v_output;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_receipt_amount (p_org_id             NUMBER,
                                p_customer_id        NUMBER,
                                p_customer_trx_id    NUMBER,
                                p_status             VARCHAR2,
                                p_date_from          DATE,
                                p_date_to            DATE)
      RETURN NUMBER
   AS
      v_output   NUMBER;
   BEGIN
      SELECT CASE
                WHEN p_status = 'ENTERED' THEN SUM (amount_applied)
                WHEN p_status = 'ACCTD' THEN SUM (acctd_amount_applied_to)
                ELSE 0
             END
        INTO v_output
        FROM ar_receivable_applications_all ps, ra_customer_trx_all ct
       WHERE     ps.applied_customer_trx_id = ct.customer_trx_id
             AND display = 'Y'
             AND application_type <> 'CM'
             AND ps.org_id = p_org_id
             AND ct.bill_to_customer_id = p_customer_id
             AND ps.applied_customer_trx_id = p_customer_trx_id
             AND TRUNC (gl_date) BETWEEN p_date_from AND p_date_to;

      RETURN v_output;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_cm_amount (p_org_id             NUMBER,
                           p_customer_id        NUMBER,
                           p_customer_trx_id    NUMBER,
                           p_status             VARCHAR2,
                           p_date_from          DATE,
                           p_date_to            DATE)
      RETURN NUMBER
   AS
      v_output   NUMBER;
   BEGIN
      SELECT CASE
                WHEN p_status = 'ENTERED' THEN SUM (distcm.amount)
                WHEN p_status = 'ACCTD' THEN SUM (distcm.acctd_amount)
                ELSE 0
             END
        INTO v_output
        FROM ra_customer_trx_all ctcm, ra_cust_trx_line_gl_dist_all distcm
       WHERE     ctcm.customer_trx_id = distcm.customer_trx_id
             AND distcm.account_class = 'REC'
             AND ctcm.org_id = p_org_id
             AND ctcm.bill_to_customer_id = p_customer_id
             AND ctcm.previous_customer_trx_id = p_customer_trx_id
             AND TRUNC (distcm.gl_date) BETWEEN p_date_from AND p_date_to;

      RETURN v_output;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_br_rct_amount (p_org_id             NUMBER,
                               p_customer_id        NUMBER,
                               p_customer_trx_id    NUMBER,
                               p_status             VARCHAR2,
                               p_date_from          DATE,
                               p_date_to            DATE)
      RETURN NUMBER
   AS
      v_output   NUMBER;
   BEGIN
      SELECT CASE
                WHEN p_status = 'ENTERED' THEN SUM (amount_applied)
                WHEN p_status = 'ACCTD' THEN SUM (acctd_amount_applied_to)
                ELSE 0
             END
        INTO v_output
        FROM ar_receivable_applications_all ps, ra_customer_trx_all ct
       WHERE     ps.applied_customer_trx_id = ct.customer_trx_id
             AND display = 'Y'
             AND application_type <> 'CM'
             AND ps.org_id = p_org_id
             AND ct.drawee_id = p_customer_id
             AND ps.applied_customer_trx_id = p_customer_trx_id
             AND TRUNC (gl_date) BETWEEN p_date_from AND p_date_to;

      RETURN v_output;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE create_ic_ar_invoice (errbuf             OUT NOCOPY VARCHAR2,
                                   retcode            OUT NOCOPY NUMBER,
                                   --    P_ORG_ID                 IN NUMBER,
                                   p_period_name   IN            VARCHAR2)
   AS
      p_org_id                 NUMBER := 110;

      --Matin Spinning Mills Ltd.

      -- Master Cursor
      CURSOR mcur
      IS
           SELECT DISTINCT bh.org_id,
                           bh.bill_header_id invoice_id,
                           bh.bill_number,
                           TRUNC (bh.bill_date) trx_date,
                           TRUNC (bh.bill_date) gl_date,
                           bh.bill_currency invoice_currency_code,
                           NVL (bh.exchance_rate, 1) exchance_rate,
                           'Bill Invoice' attribute_category,
                           bh.bill_header_id attribute6,
                           bh.bill_header_id attribute10,
                           'Sales of Yarn' comments,
                           bh.customer_id,
                           bh.customer_type,
                           bh.bill_category
             FROM xx_ar_bills_headers_all bh,
                  xx_ar_bills_lines_all bl,
                  xx_ar_bills_line_details_all bld
            WHERE     bh.bill_header_id = bl.bill_header_id
                  AND bl.bill_line_id = bld.bill_line_id
                  AND bh.bill_status = 'CONFIRMED'
                  AND bh.org_id = p_org_id
                  AND NVL (bh.process_status, 'U') = 'U'
                  --       AND BH.BILL_NUMBER IN ('MSML/1805')
                  AND TRUNC (bh.bill_date) >= '01-JAN-2015'
                  AND TO_CHAR (bh.bill_date, 'MON-YY') = p_period_name
                  AND NOT EXISTS
                         (SELECT 1
                            FROM ra_customer_trx_all ra
                           WHERE     ra.attribute6 =
                                        TO_CHAR (bh.bill_header_id)
                                 AND ra.org_id = bh.org_id)
         ORDER BY invoice_id;

      CURSOR cur (
         p_header_id    NUMBER)
      IS
           SELECT bh.org_id,
                  bh.bill_header_id invoice_id,
                  bl.bill_line_id line_id,
                  bld.bill_line_detail_id,
                  TRUNC (bh.bill_date) trx_date,
                  TRUNC (bh.bill_date) gl_date,
                  bh.bill_currency invoice_currency_code,
                  NVL (bh.exchance_rate, 1) exchance_rate,
                  'Bill Invoice' attribute_category,
                  bh.bill_header_id attribute6,
                  bh.bill_header_id attribute10,
                  'Sales of Yarn' comments,
                  bh.customer_id,
                  bld.item_description,
                  bld.uom uom_code,
                  bld.finishing_weight quantity,
                  bld.unit_selling_price,
                  bld.total_price,
                  bl.challan_number,
                  bl.challan_date,
                  bld.pi_number,
                  bld.order_number,
                  bh.bill_category
             FROM xx_ar_bills_headers_all bh,
                  xx_ar_bills_lines_all bl,
                  xx_ar_bills_line_details_all bld
            WHERE     bh.bill_header_id = bl.bill_header_id
                  AND bl.bill_line_id = bld.bill_line_id
                  AND bh.bill_status = 'CONFIRMED'
                  AND bh.bill_header_id = p_header_id
                  AND bh.org_id = p_org_id
                  AND NVL (bh.process_status, 'U') = 'U'
                  AND TRUNC (bh.bill_date) >= '01-JAN-2015'
                  AND TO_CHAR (bh.bill_date, 'MON-YY') = p_period_name
                  AND NOT EXISTS
                         (SELECT 1
                            FROM ra_customer_trx_all ra
                           WHERE     ra.attribute6 =
                                        TO_CHAR (bh.bill_header_id)
                                 AND ra.org_id = bh.org_id)
         ORDER BY trx_date,
                  invoice_id,
                  line_id,
                  bill_line_detail_id;

      l_return_status          VARCHAR2 (1);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
      l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
      l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
      l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
      l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
      v_batch_source_id        NUMBER;
      l_cust_trx_id            NUMBER;
      p_msg_count              NUMBER;
      p_msg_data               VARCHAR2 (2000);
      l_cnt                    NUMBER := 0;
      v_record_count           NUMBER := 1;
      v_cust_trx_type_id       NUMBER;
      v_error_msg              VARCHAR2 (4000);
      i                        NUMBER := 0;
      l_msml_ou                VARCHAR2 (240) := 'MSML';
      l_ctt_lookup             VARCHAR2 (100) := 'DBL_BILL_CATEGORY';
   --'DBL_BILL_ENTRY_TO_TRX_TYPES';
   BEGIN
      xx_com_pkg.writelog (
            CHR (10)
         || '+----------------------------Information Log---------------------------------+'
         || CHR (10));

      BEGIN
         SELECT organization_id
           INTO p_org_id
           FROM hr_all_organization_units org
          WHERE NAME = l_msml_ou;
      EXCEPTION
         WHEN OTHERS
         THEN
            xx_com_pkg.writelog ('Unable to find OU ' || l_msml_ou);
            raise_application_error (-20001,
                                     'Unable to find OU ' || l_msml_ou);
      END;

      --         v_error_msg := 'Ord ID ' ||P_org_id|| ' Date From ' ||V_DATE_FROM||'   Date To :'||V_DATE_TO;
      --         XX_COM_PKG.WRITELOG (CHR (10)||v_error_msg||CHR (10));

      --      fnd_global.apps_initialize (FND_PROFILE.VALUE('USER_ID'), FND_PROFILE.VALUE('RESP_ID'), 222, 0);
      mo_global.set_policy_context ('S', p_org_id);

      --          v_error_msg := 'Ord ID ' ||P_org_id|| ' User ID ' ||FND_PROFILE.VALUE('USER_ID')||'   RESP_ID :'||FND_PROFILE.VALUE('RESP_ID');
      --             XX_COM_PKG.WRITELOG (CHR (10)||v_error_msg||CHR (10));
      BEGIN
         SELECT batch_source_id
           INTO v_batch_source_id
           FROM ra_batch_sources_all
          WHERE     UPPER (NAME) = UPPER ('DBL Export Sales')
                AND org_id = p_org_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            xx_com_pkg.writelog (
               'Unable to find batch_source_id for DBL Export Sales');
            raise_application_error (
               -20002,
               'Unable to find batch_source_id for DBL Export Sales');
      END;

      FOR mrec IN mcur
      LOOP
         l_return_status := NULL;
         l_cust_trx_id := NULL;
         i := 0;
         l_batch_source_rec.batch_source_id := v_batch_source_id;
         l_trx_header_tbl (1).trx_header_id := mrec.invoice_id;
         l_trx_header_tbl (1).interface_header_attribute1 := mrec.bill_number;
         l_trx_header_tbl (1).trx_date := mrec.trx_date;
         l_trx_header_tbl (1).gl_date := mrec.gl_date;
         l_trx_header_tbl (1).trx_currency := mrec.invoice_currency_code;
         l_trx_header_tbl (1).exchange_rate_type :=
            CASE
               WHEN mrec.invoice_currency_code = 'BDT' THEN NULL
               ELSE 'User'
            END;
         l_trx_header_tbl (1).exchange_date :=
            CASE
               WHEN mrec.invoice_currency_code = 'BDT' THEN NULL
               ELSE mrec.trx_date
            END;
         l_trx_header_tbl (1).exchange_rate :=
            CASE
               WHEN mrec.invoice_currency_code = 'BDT' THEN NULL
               ELSE mrec.exchance_rate
            END;

         --ADDED BY SMNAYEEM
         /*l_trx_header_tbl (1).cust_trx_type_id :=case when (mrec.customer_type='Internal'
         AND MREC.BILL_CATEGORY='Yarn Export Melange') then 3264
          when (mrec.customer_type<>'Internal'
         AND MREC.BILL_CATEGORY='Yarn Export Melange') then 3265
           when (mrec.customer_type='Internal'
         AND MREC.BILL_CATEGORY='Yarn Export Synthatic') then 3266
           when (mrec.customer_type<>'Internal'
         AND MREC.BILL_CATEGORY='Yarn Export Synthatic') then 3267
           when (mrec.customer_type='Internal'
         AND MREC.BILL_CATEGORY not in ('Yarn Export Synthatic','Yarn Export Melange')) then 1238
         else 1237 end ; */
         -- Org ID - 94, Type Name - Yarn Sales Int. INV  1237 -- org id =94  Type Name : Yarn Sales INV
         --ADDED BY SMNAYEEM
         BEGIN
            SELECT ctt.cust_trx_type_id
              INTO l_trx_header_tbl (1).cust_trx_type_id
              FROM fnd_lookup_values_vl lv,
                   ra_cust_trx_types_all ctt,
                   hr_operating_units ou
             WHERE     lv.lookup_type = l_ctt_lookup
                   AND lv.meaning = mrec.bill_category
                   AND lv.description = ctt.NAME
                   AND lv.tag = ou.NAME
                   AND ctt.org_id = ou.organization_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               xx_com_pkg.writelog (
                  SUBSTRB (
                        'Unable to find Trx Type for  '
                     || l_msml_ou
                     || ' and category '
                     || mrec.bill_category
                     || ' - '
                     || SQLERRM,
                     1,
                     255));
               raise_application_error (
                  -20003,
                  SUBSTRB (
                        'Unable to find Trx Type for  '
                     || l_msml_ou
                     || ' and category '
                     || mrec.bill_category
                     || ' - '
                     || SQLERRM,
                     1,
                     255));
         END;

         xx_com_pkg.writelog (
               'derived cust_trx_type_id = '
            || l_trx_header_tbl (1).cust_trx_type_id);
         --  l_trx_header_tbl (1).cust_trx_type_id :=case when mrec.customer_type='Internal' then  1238 else 1237 end ;
         l_trx_header_tbl (1).bill_to_customer_id := mrec.customer_id;
         l_trx_header_tbl (1).term_id := 5;                        --IMMEDIATE
         l_trx_header_tbl (1).finance_charges := 'N';
         l_trx_header_tbl (1).status_trx := 'OP';
         l_trx_header_tbl (1).printing_option := 'PRI';
         l_trx_header_tbl (1).comments := mrec.comments;
         l_trx_header_tbl (1).attribute_category := mrec.attribute_category;
         l_trx_header_tbl (1).attribute6 := mrec.attribute6;
         l_trx_header_tbl (1).attribute10 := mrec.attribute10;
         l_trx_header_tbl (1).org_id := mrec.org_id;

         FOR rec IN cur (mrec.invoice_id)
         LOOP
            i := i + 1;
            -- Lines (Main Product)
            l_trx_lines_tbl (i).trx_header_id := rec.invoice_id;
            l_trx_lines_tbl (i).trx_line_id := rec.bill_line_detail_id;
            l_trx_lines_tbl (i).line_number := i;
            l_trx_lines_tbl (i).description := rec.item_description;
            l_trx_lines_tbl (i).uom_code := rec.uom_code;
            l_trx_lines_tbl (i).quantity_invoiced := rec.quantity;
            l_trx_lines_tbl (i).unit_selling_price := rec.unit_selling_price;
            l_trx_lines_tbl (i).line_type := 'LINE';
            l_trx_lines_tbl (i).interface_line_context := 'DBL_IC_INVOICE';
            l_trx_lines_tbl (i).interface_line_attribute1 :=
               rec.challan_number;
            l_trx_lines_tbl (i).interface_line_attribute2 := rec.challan_date;
            l_trx_lines_tbl (i).interface_line_attribute3 := rec.pi_number;
            l_trx_lines_tbl (i).interface_line_attribute4 := rec.order_number;
            l_trx_lines_tbl (i).interface_line_attribute5 :=
               rec.bill_line_detail_id;
         END LOOP;

         ar_invoice_api_pub.create_single_invoice (
            p_api_version            => 1.0,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data,
            x_customer_trx_id        => l_cust_trx_id,
            p_commit                 => fnd_api.g_true,
            p_batch_source_rec       => l_batch_source_rec,
            p_trx_header_tbl         => l_trx_header_tbl,
            p_trx_lines_tbl          => l_trx_lines_tbl,
            p_trx_dist_tbl           => l_trx_dist_tbl,
            p_trx_salescredits_tbl   => l_trx_salescredits_tbl);
         v_record_count := NVL (v_record_count, 0) + 1;
         xx_com_pkg.writelog ('Msg ' || SUBSTR (p_msg_data, 1, 225));
         xx_com_pkg.writelog ('Status ' || l_return_status);
         xx_com_pkg.writelog ('Cust Trx Id ' || l_cust_trx_id);
         xx_com_pkg.writelog ('ORGANIZATION Id ' || p_org_id);
         xx_com_pkg.writelog ('Record Successes ' || v_record_count);
         v_error_msg :=
               'Message '
            || SUBSTR (l_msg_data, 1, 225)
            || '   Status '
            || l_return_status
            || '   Cust Trx Id  '
            || l_cust_trx_id;
         xx_com_pkg.writelog (CHR (10) || v_error_msg);

         IF l_return_status = 'S' AND l_cust_trx_id IS NOT NULL
         THEN
            UPDATE xx_ar_bills_headers_all
               SET process_status = 'P'
             WHERE bill_header_id = mrec.invoice_id;

            COMMIT;
         END IF;

         IF    l_return_status = fnd_api.g_ret_sts_error
            OR l_return_status = fnd_api.g_ret_sts_unexp_error
         THEN
            xx_com_pkg.writelog ('unexpected errors found!');
         ELSE
            SELECT COUNT (*) INTO l_cnt FROM ar_trx_errors_gt;

            IF l_cnt = 0
            THEN
               xx_com_pkg.writelog ('Customer Trx id ' || l_cust_trx_id);
            ELSE
               xx_com_pkg.writelog (
                     'Transaction not Created, Please check ar_trx_errors_gt table '
                  || mrec.customer_id);
            END IF;
         END IF;
      END LOOP;
   END;

   PROCEDURE create_exp_ar_invoice (errbuf             OUT NOCOPY VARCHAR2,
                                    retcode            OUT NOCOPY NUMBER,
                                    p_org_id        IN            NUMBER,
                                    p_period_name   IN            VARCHAR2)
   AS
      -- Master Cursor
      CURSOR mcur
      IS
           SELECT sm.org_id,
                  sm.shipment_id invoice_id,
                  sm.shipment_number bill_number,
                  shipment_date trx_date,
                  shipment_date gl_date,
                  'USD' invoice_currency_code,
                  conversion_rate exchance_rate,
                  'Export' attribute_category,
                  sm.shipment_id attribute1,
                  sc.comm_invoice_no attribute3,
                  (TO_CHAR (comm_invoice_date, 'YYYY/MM/DD') || ' 00:00:00')
                     attribute5,
                  sm.customer_id,
                  sm.shipment_number comments
             FROM xx_explc_shipment_mst sm,
                  xx_explc_shipment_comm sc     -- , XX_EXPLC_SHIPMENT_DTL SD,
                                           ,
                  (SELECT conversion_rate, conversion_date
                     FROM gl_daily_rates_v
                    WHERE     user_conversion_type = 'Corporate'
                          AND from_currency = 'USD'
                          AND to_currency = 'BDT') conv
            WHERE     sm.shipment_id = sc.shipment_id
                  --AND SC.COMM_INVOICE_ID=SD.COMM_INVOICE_ID
                  --AND SC.SHIPMENT_ID=SD.SHIPMENT_ID
                  AND sm.shipment_date = conv.conversion_date
                  AND shipment_date IS NOT NULL
                  AND comm_invoice_no IS NOT NULL
                  --AND product_qty>0
                  AND sm.org_id = p_org_id
                  AND sm.ar_invoice_id IS NULL
                  AND TRUNC (sm.shipment_date) >= '01-JAN-2015'
                  AND TO_CHAR (sm.shipment_date, 'MON-YY') = p_period_name
                  --  AND sm.shipment_number IN ('SH/FFL/2014/31/000996')
                  AND NOT EXISTS
                         (SELECT 1
                            FROM ra_customer_trx_all ra
                           WHERE     ra.attribute1 = TO_CHAR (sm.shipment_id)
                                 AND ra.org_id = sm.org_id)
         ORDER BY invoice_id;

      CURSOR cur (
         p_shipment_id    NUMBER)
      IS
           /*
           SELECT   sm.org_id, sm.shipment_id invoice_id, NULL line_id,
                    shipment_date trx_date, shipment_date gl_date,
                    'USD' invoice_currency_code, conversion_rate exchange_rate,
                    --'Export' ATTRIBUTE_CATEGORY,SM.SHIPMENT_ID ATTRIBUTE1,SC.COMM_INVOICE_NO ATTRIBUTE3,COMM_INVOICE_DATE ATTRIBUTE5,
                    'Export of Garments Shipment No ' || sm.shipment_number comments,
                    sm.customer_id, 'Export of Garments' item_description,
                    MAX (product_uom) uom_code, SUM (NVL (quantity, 0)) quantity,
                      --sum(nvl(unit_price,0)) unit_selling_price,
                      (  SUM (NVL (item_value, 0))
                       + SUM (NVL (sc.addition_amt, 0))
                       - SUM (NVL (sc.discount_amt, 0))
                      )
                    / SUM (NVL (quantity, 0)) unit_selling_price,
                      --nvl(product_qty,0)*nvl(unit_price,0)total_price,
                      SUM (NVL (item_value, 0))
                    + SUM (NVL (sc.addition_amt, 0))
                    - SUM (NVL (sc.discount_amt, 0)) total_price
               ----,sm.auto_order_no order_number
           FROM     xx_explc_shipment_mst sm,
                    xx_explc_shipment_comm sc,
                    (SELECT   shipment_id, comm_invoice_id, MAX (product_uom)
                                                                             product_uom,
                              SUM (NVL (product_qty, 0)) quantity,
                              SUM (  (NVL (product_qty, 0) * NVL (unit_price, 0))
                                   + NVL (add_amount, 0)
                                   - NVL (discount_amt, 0)
                                  ) item_value
                         FROM xx_explc_shipment_dtl
                     GROUP BY shipment_id, comm_invoice_id) sd,
                    (SELECT conversion_rate, conversion_date
                       FROM gl_daily_rates_v
                      WHERE user_conversion_type = 'Corporate'
                        AND from_currency = 'USD'
                        AND to_currency = 'BDT') conv
              WHERE sm.shipment_id = sc.shipment_id
                AND sc.comm_invoice_id = sd.comm_invoice_id
                AND sc.shipment_id = sd.shipment_id
                AND sm.shipment_date = conv.conversion_date
                AND shipment_date IS NOT NULL
                AND comm_invoice_no IS NOT NULL
                AND quantity > 0
                AND sm.org_id = p_org_id
                AND sm.shipment_id = p_shipment_id
                AND sm.ar_invoice_id IS NULL
                AND TRUNC (sm.shipment_date) >= '01-JAN-2015'
                AND TO_CHAR (sm.shipment_date, 'MON-YY') = p_period_name
                AND NOT EXISTS (
                       SELECT 1
                         FROM ra_customer_trx_all ra
                        WHERE ra.attribute1 = TO_CHAR (sm.shipment_id)
                          AND ra.org_id = sm.org_id)
           GROUP BY sm.org_id,
                    sm.shipment_id,
                    shipment_date,
                    conversion_rate,
                    'Export of Garments Shipment No ' || sm.shipment_number,
                    sm.customer_id
           ORDER BY invoice_id; */
           SELECT sm.org_id,
                  sm.shipment_id invoice_id,
                  NULL line_id,
                  shipment_date trx_date,
                  shipment_date gl_date,
                  'USD' invoice_currency_code,
                  conversion_rate exchange_rate,
                  --'Export' attribute_category,sm.shipment_id attribute1,
                  -- sc.comm_invoice_no attribute3,comm_invoice_date attribute5,
                  'Export of Garments Shipment No ' || sm.shipment_number
                     comments,
                  sm.customer_id,
                  'Export of Garments' item_description,
                  (product_uom) uom_code,
                  (NVL (quantity, 0)) quantity,
                    --sum(nvl(unit_price,0)) unit_selling_price,
                    (  (NVL (item_value, 0))
                     + (NVL (sc.addition_amt, 0))
                     - (NVL (sc.discount_amt, 0)))
                  / (NVL (quantity, 0))
                     unit_selling_price,
                    --nvl(product_qty,0)*nvl(unit_price,0)total_price,
                    (NVL (item_value, 0))
                  + (NVL (sc.addition_amt, 0))
                  - (NVL (sc.discount_amt, 0))
                     total_price
             ----,sm.auto_order_no order_number
             FROM xx_explc_shipment_mst sm,
                  xx_explc_shipment_comm sc,
                  (SELECT shipment_id,
                          comm_invoice_id,
                          (product_uom) product_uom,
                          (NVL (product_qty, 0)) quantity,
                          (  (NVL (product_qty, 0) * NVL (unit_price, 0))
                           + NVL (add_amount, 0)
                           - NVL (discount_amt, 0))
                             item_value
                     FROM xx_explc_shipment_dtl) sd,
                  (SELECT conversion_rate, conversion_date
                     FROM gl_daily_rates_v
                    WHERE     user_conversion_type = 'Corporate'
                          AND from_currency = 'USD'
                          AND to_currency = 'BDT') conv
            WHERE     sm.shipment_id = sc.shipment_id
                  AND sc.comm_invoice_id = sd.comm_invoice_id
                  AND sc.shipment_id = sd.shipment_id
                  AND sm.shipment_date = conv.conversion_date
                  AND shipment_date IS NOT NULL
                  AND comm_invoice_no IS NOT NULL
                  AND quantity > 0
                  AND sm.org_id = p_org_id
                  AND sm.shipment_id = p_shipment_id
                  AND sm.ar_invoice_id IS NULL
                  AND TRUNC (sm.shipment_date) >= '01-JAN-2015'
                  AND TO_CHAR (sm.shipment_date, 'MON-YY') = p_period_name
                  AND NOT EXISTS
                         (SELECT 1
                            FROM ra_customer_trx_all ra
                           WHERE     ra.attribute1 = TO_CHAR (sm.shipment_id)
                                 AND ra.org_id = sm.org_id)
         ORDER BY invoice_id;

      l_return_status          VARCHAR2 (1);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
      l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
      l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
      l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
      l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
      v_batch_source_id        NUMBER;
      l_cust_trx_id            NUMBER;
      p_msg_count              NUMBER;
      p_msg_data               VARCHAR2 (2000);
      l_cnt                    NUMBER := 0;
      v_record_count           NUMBER := 1;
      v_cust_trx_type_id       NUMBER;
      v_error_msg              VARCHAR2 (4000);
      i                        NUMBER := 0;
      v_batch_source           VARCHAR2 (500) := 'DBL Export Sales';
      v_cust_trx_type          VARCHAR2 (500) := 'Garments Export INV';
      v_rec_ccid               NUMBER;
      v_rev_ccid               NUMBER;
   BEGIN
      xx_com_pkg.writelog (
            CHR (10)
         || '+----------------------------Information Log---------------------------------+'
         || CHR (10));
      --v_error_msg := 'Ord ID ' ||P_org_id|| ' Date From ' ||V_DATE_FROM||'   Date To :'||V_DATE_TO;
      --XX_COM_PKG.WRITELOG (CHR (10)||v_error_msg||CHR (10));

      --fnd_global.apps_initialize (FND_PROFILE.VALUE('USER_ID'), FND_PROFILE.VALUE('RESP_ID'), 222, 0);
      mo_global.set_policy_context ('S', p_org_id);

      --v_error_msg := 'Ord ID ' ||P_org_id|| ' User ID ' ||FND_PROFILE.VALUE('USER_ID')||'   RESP_ID :'||FND_PROFILE.VALUE('RESP_ID');
      --xx_com_pkg.writelog (CHR (10)||v_error_msg||CHR (10));

      /*        begin
                select BATCH_SOURCE_ID
                INTO  v_batch_source_id
                from RA_BATCH_SOURCES_ALL
                WHERE UPPER (NAME) = UPPER ('Intercompany Sales');

        exception
                when others then
                null;
        end;*/



      --SAWKAT
      --v_batch_source_id:= 3002;   ---1;
      BEGIN
         SELECT batch_source_id
           INTO v_batch_source_id
           FROM ar.ra_batch_sources_all rbs
          WHERE rbs.NAME = v_batch_source AND org_id = p_org_id;

         xx_com_pkg.writelog (
               'v_batch_source_id = '
            || v_batch_source_id
            || ', v_batch_source = '
            || v_batch_source);
      EXCEPTION
         WHEN OTHERS
         THEN
            xx_com_pkg.writelog (
               'Unable to derive batch source ' || v_batch_source);
            RAISE;
      END;

      BEGIN
         SELECT cust_trx_type_id, gl_id_rec, gl_id_rev
           INTO v_cust_trx_type_id, v_rec_ccid, v_rev_ccid
           FROM ra_cust_trx_types_all
          WHERE NAME = v_cust_trx_type                 --'Garments Export INV'
                                      AND org_id = p_org_id;

         xx_com_pkg.writelog (
            'Derived v_cust_trx_type_id = ' || v_cust_trx_type_id);
         xx_com_pkg.writelog ('Derived v_rec_ccid = ' || v_rec_ccid);
         xx_com_pkg.writelog ('Derived v_rev_ccid = ' || v_rev_ccid);
      EXCEPTION
         WHEN OTHERS
         THEN
            xx_com_pkg.writelog (
               'Unable to derive trx type ' || v_cust_trx_type);
            RAISE;
      END;

      FOR mrec IN mcur
      LOOP
         l_return_status := NULL;
         l_cust_trx_id := NULL;
         i := 0;
         xx_com_pkg.writelog (
            'Inside loop 1 setting mo_global for  ' || mrec.org_id);
         mo_global.set_policy_context ('S', mrec.org_id);
         xx_com_pkg.writelog ('bill_number = ' || mrec.bill_number);
         l_batch_source_rec.batch_source_id := v_batch_source_id;
         l_trx_header_tbl (1).trx_header_id := mrec.invoice_id;
         l_trx_header_tbl (1).interface_header_context := 'DBL_BILL_NUMBER';
         l_trx_header_tbl (1).interface_header_attribute1 := mrec.bill_number;
         l_trx_header_tbl (1).trx_date := mrec.trx_date;
         l_trx_header_tbl (1).gl_date := mrec.gl_date;
         l_trx_header_tbl (1).trx_currency := mrec.invoice_currency_code;
         l_trx_header_tbl (1).exchange_rate_type := 'User';
         l_trx_header_tbl (1).exchange_date := mrec.trx_date;
         l_trx_header_tbl (1).exchange_rate := mrec.exchance_rate;
         l_trx_header_tbl (1).cust_trx_type_id := v_cust_trx_type_id;
         l_trx_header_tbl (1).bill_to_customer_id := mrec.customer_id;
         l_trx_header_tbl (1).term_id := 5;                        --IMMEDIATE
         l_trx_header_tbl (1).finance_charges := 'N';
         l_trx_header_tbl (1).status_trx := 'OP';
         l_trx_header_tbl (1).printing_option := 'PRI';
         l_trx_header_tbl (1).comments := mrec.comments;
         l_trx_header_tbl (1).attribute_category := mrec.attribute_category;
         l_trx_header_tbl (1).attribute1 := mrec.bill_number;
         --mrec.attribute1;
         l_trx_header_tbl (1).attribute3 := mrec.attribute3;
         l_trx_header_tbl (1).attribute5 := mrec.attribute5;
         l_trx_header_tbl (1).org_id := mrec.org_id;
         xx_com_pkg.writelog ('Populate Rec info');

         SELECT ra_cust_trx_line_gl_dist_s.NEXTVAL
           INTO l_trx_dist_tbl (1).trx_dist_id
           FROM DUAL;

         l_trx_dist_tbl (1).trx_header_id :=
            l_trx_header_tbl (1).trx_header_id;
         l_trx_dist_tbl (1).trx_line_id := NULL;
         l_trx_dist_tbl (1).account_class := 'REC';
         l_trx_dist_tbl (1).PERCENT := 100;
         l_trx_dist_tbl (1).code_combination_id := v_rec_ccid;

         FOR rec IN cur (mrec.invoice_id)
         LOOP
            i := i + 1;
            -- Lines (Main Product)
            xx_com_pkg.writelog (
                  'Inside loop 2 line  '
               || i
               || ', qty = '
               || rec.quantity
               || ', price = '
               || rec.unit_selling_price
               || ', item desc = '
               || rec.item_description);
            l_trx_lines_tbl (i).trx_header_id := rec.invoice_id;

            --l_trx_lines_tbl (i).trx_line_id :=  i;--rec.bill_line_detail_id;
            SELECT ra_customer_trx_lines_s.NEXTVAL
              INTO l_trx_lines_tbl (i).trx_line_id
              FROM DUAL;

            l_trx_lines_tbl (i).line_number := i;
            l_trx_lines_tbl (i).description := rec.item_description;
            l_trx_lines_tbl (i).uom_code := rec.uom_code;
            l_trx_lines_tbl (i).quantity_invoiced := rec.quantity;
            l_trx_lines_tbl (i).unit_selling_price := rec.unit_selling_price;
            l_trx_lines_tbl (i).line_type := 'LINE';
            -- l_trx_lines_tbl (i).interface_line_context := 'DBL_IC_INVOICE';
            -- l_trx_lines_tbl (i).interface_line_attribute1 := rec.challan_number;
            -- l_trx_lines_tbl (i).interface_line_attribute2 := rec.challan_date;
            -- l_trx_lines_tbl (i).interface_line_attribute3 := rec.pi_number;
            -- l_trx_lines_tbl (i).interface_line_attribute4 := rec.order_number;
            --l_trx_lines_tbl (i).interface_line_attribute5 := rec.bill_line_detail_id;
            xx_com_pkg.writelog ('Populate Rev info for line ' || i);

            SELECT ra_cust_trx_line_gl_dist_s.NEXTVAL
              INTO l_trx_dist_tbl (i + 1).trx_dist_id
              FROM DUAL;

            l_trx_dist_tbl (i + 1).trx_header_id :=
               l_trx_header_tbl (1).trx_header_id;
            l_trx_dist_tbl (i + 1).trx_line_id :=
               l_trx_lines_tbl (i).trx_line_id;
            l_trx_dist_tbl (i + 1).account_class := 'REV';
            l_trx_dist_tbl (i + 1).amount :=
               ROUND (rec.quantity * rec.unit_selling_price, 2);
            l_trx_dist_tbl (i + 1).code_combination_id := v_rev_ccid;
         END LOOP;

         ar_invoice_api_pub.create_single_invoice (
            p_api_version            => 1.0,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data,
            x_customer_trx_id        => l_cust_trx_id,
            p_commit                 => fnd_api.g_true,
            p_batch_source_rec       => l_batch_source_rec,
            p_trx_header_tbl         => l_trx_header_tbl,
            p_trx_lines_tbl          => l_trx_lines_tbl,
            p_trx_dist_tbl           => l_trx_dist_tbl,
            p_trx_salescredits_tbl   => l_trx_salescredits_tbl);
         v_record_count := NVL (v_record_count, 0) + 1;
         xx_com_pkg.writelog ('Msg ' || SUBSTR (p_msg_data, 1, 225));
         xx_com_pkg.writelog ('Status ' || l_return_status);
         xx_com_pkg.writelog ('Cust Trx Id ' || l_cust_trx_id);
         xx_com_pkg.writelog ('organization Id ' || mrec.org_id);
         xx_com_pkg.writelog ('Record Successes ' || v_record_count);
         v_error_msg :=
               'Message '
            || SUBSTR (l_msg_data, 1, 225)
            || '   Status '
            || l_return_status
            || '   Cust Trx Id  '
            || l_cust_trx_id;
         xx_com_pkg.writelog (v_error_msg);

         SELECT COUNT (1) INTO l_cnt FROM ar_trx_errors_gt;

         IF l_return_status = 'S' AND l_cust_trx_id IS NOT NULL AND l_cnt = 0
         THEN
            xx_com_pkg.writelog ('Customer Trx id ' || l_cust_trx_id);

            UPDATE xx_explc_shipment_mst
               SET ar_invoice_id = l_cust_trx_id
             WHERE shipment_id = mrec.invoice_id;

            UPDATE xx_explc_shipment_comm
               SET ar_invoice_id = l_cust_trx_id
             WHERE shipment_id = mrec.invoice_id;

            COMMIT;
         END IF;

         IF    l_return_status = fnd_api.g_ret_sts_error
            OR l_return_status = fnd_api.g_ret_sts_unexp_error
         THEN
            xx_com_pkg.writelog ('unexpected errors found!');
         END IF;

         IF l_cnt > 0
         THEN
            xx_com_pkg.writelog (
                  'Transaction not Created, Please check ar_trx_errors_gt table '
               || mrec.customer_id);

            FOR x IN (SELECT *
                        FROM ar_trx_errors_gt)
            LOOP
               xx_com_pkg.writelog (
                  x.error_message || ' ~ ' || x.invalid_value);
            END LOOP;
         END IF;

         l_trx_header_tbl.DELETE;
         l_trx_lines_tbl.DELETE;
         l_trx_dist_tbl.DELETE;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_com_pkg.writelog (
            'Unexpected error: ' || SUBSTRB (SQLERRM, 1, 200));
   END create_exp_ar_invoice;

   --Created By Majid 13-Aug-2018
   PROCEDURE create_exp_ar_invoice2 (errbuf             OUT NOCOPY VARCHAR2,
                                     retcode            OUT NOCOPY NUMBER,
                                     p_org_id        IN            NUMBER,
                                     p_period_name   IN            VARCHAR2)
   AS
      -- Master Cursor
      CURSOR mcur
      IS
           SELECT sm.org_id,
                  sm.shipment_id invoice_id,
                  sm.shipment_number bill_number,
                  shipment_date trx_date,
                  shipment_date gl_date,
                  'USD' invoice_currency_code,
                  conversion_rate exchance_rate,
                  'Export' attribute_category,
                  sm.shipment_id attribute1,
                  sc.comm_invoice_no attribute3,
                  (TO_CHAR (comm_invoice_date, 'YYYY/MM/DD') || ' 00:00:00')
                     attribute5,
                  sm.customer_id,
                  sm.shipment_number comments,
                  CUST_TRX_TYPE_ID,
                  rec_ccid,
                  rev_ccid
             FROM xx_explc_shipment_mst sm,
                  xx_explc_shipment_comm sc,
                  (SELECT conversion_rate, conversion_date
                     FROM gl_daily_rates_v
                    WHERE     user_conversion_type = 'Corporate'
                          AND from_currency = 'USD'
                          AND to_currency = 'BDT') conv
            WHERE     sm.shipment_id = sc.shipment_id
                  AND sm.shipment_date = conv.conversion_date
                  AND shipment_date IS NOT NULL
                  AND comm_invoice_no IS NOT NULL
                  AND sm.org_id = p_org_id
                  AND sm.ar_invoice_id IS NULL
                  AND TRUNC (sm.shipment_date) >= '01-JAN-2015'
                  AND TO_CHAR (sm.shipment_date, 'MON-YY') = p_period_name
                  AND NOT EXISTS
                         (SELECT 1
                            FROM ra_customer_trx_all ra
                           WHERE     ra.attribute1 = TO_CHAR (sm.shipment_id)
                                 AND ra.org_id = sm.org_id)
         ORDER BY invoice_id;

      CURSOR cur (
         p_shipment_id    NUMBER)
      IS
           SELECT sm.org_id,
                  sm.shipment_id invoice_id,
                  NULL line_id,
                  shipment_date trx_date,
                  shipment_date gl_date,
                  'USD' invoice_currency_code,
                  conversion_rate exchange_rate,
                  'Export of Garments Shipment No ' || sm.shipment_number
                     comments,
                  sm.customer_id,
                  NVL (INVOICE_DESCRIPTION, 'Export of Garments')
                     item_description,
                  (product_uom) uom_code,
                  (NVL (quantity, 0)) quantity,
                    (  (NVL (item_value, 0))
                     + (NVL (sc.addition_amt, 0))
                     - (NVL (sc.discount_amt, 0)))
                  / (NVL (quantity, 0))
                     unit_selling_price,
                    (NVL (item_value, 0))
                  + (NVL (sc.addition_amt, 0))
                  - (NVL (sc.discount_amt, 0))
                     total_price
             FROM xx_explc_shipment_mst sm,
                  xx_explc_shipment_comm sc,
                  (SELECT shipment_id,
                          comm_invoice_id,
                          (product_uom) product_uom,
                          (NVL (product_qty, 0)) quantity,
                          (  (NVL (product_qty, 0) * NVL (unit_price, 0))
                           + NVL (add_amount, 0)
                           - NVL (discount_amt, 0))
                             item_value
                     FROM xx_explc_shipment_dtl) sd,
                  (SELECT conversion_rate, conversion_date
                     FROM gl_daily_rates_v
                    WHERE     user_conversion_type = 'Corporate'
                          AND from_currency = 'USD'
                          AND to_currency = 'BDT') conv
            WHERE     sm.shipment_id = sc.shipment_id
                  AND sc.comm_invoice_id = sd.comm_invoice_id
                  AND sc.shipment_id = sd.shipment_id
                  AND sm.shipment_date = conv.conversion_date
                  AND shipment_date IS NOT NULL
                  AND comm_invoice_no IS NOT NULL
                  AND quantity > 0
                  AND sm.org_id = p_org_id
                  AND sm.shipment_id = p_shipment_id
                  AND sm.ar_invoice_id IS NULL
                  AND TRUNC (sm.shipment_date) >= '01-JAN-2015'
                  AND TO_CHAR (sm.shipment_date, 'MON-YY') = p_period_name
                  AND NOT EXISTS
                         (SELECT 1
                            FROM ra_customer_trx_all ra
                           WHERE     ra.attribute1 = TO_CHAR (sm.shipment_id)
                                 AND ra.org_id = sm.org_id)
         ORDER BY invoice_id;

      l_return_status          VARCHAR2 (1);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      l_batch_source_rec       ar_invoice_api_pub.batch_source_rec_type;
      l_trx_header_tbl         ar_invoice_api_pub.trx_header_tbl_type;
      l_trx_lines_tbl          ar_invoice_api_pub.trx_line_tbl_type;
      l_trx_dist_tbl           ar_invoice_api_pub.trx_dist_tbl_type;
      l_trx_salescredits_tbl   ar_invoice_api_pub.trx_salescredits_tbl_type;
      v_batch_source_id        NUMBER;
      l_cust_trx_id            NUMBER;
      p_msg_count              NUMBER;
      p_msg_data               VARCHAR2 (2000);
      l_cnt                    NUMBER := 0;
      v_record_count           NUMBER := 1;
      v_cust_trx_type_id       NUMBER;
      v_error_msg              VARCHAR2 (4000);
      i                        NUMBER := 0;
      v_batch_source           VARCHAR2 (500) := 'DBL Export Sales';
   --  v_cust_trx_type          VARCHAR2 (500) := 'Garments Export INV';
   --  v_rec_ccid               NUMBER;
   -- v_rev_ccid               NUMBER;
   BEGIN
      xx_com_pkg.writelog (
            CHR (10)
         || '+----------------------------Information Log---------------------------------+'
         || CHR (10));
      --v_error_msg := 'Ord ID ' ||P_org_id|| ' Date From ' ||V_DATE_FROM||'   Date To :'||V_DATE_TO;
      --XX_COM_PKG.WRITELOG (CHR (10)||v_error_msg||CHR (10));

      --fnd_global.apps_initialize (FND_PROFILE.VALUE('USER_ID'), FND_PROFILE.VALUE('RESP_ID'), 222, 0);
      mo_global.set_policy_context ('S', p_org_id);

      --v_error_msg := 'Ord ID ' ||P_org_id|| ' User ID ' ||FND_PROFILE.VALUE('USER_ID')||'   RESP_ID :'||FND_PROFILE.VALUE('RESP_ID');
      --xx_com_pkg.writelog (CHR (10)||v_error_msg||CHR (10));

      /*        begin
                select BATCH_SOURCE_ID
                INTO  v_batch_source_id
                from RA_BATCH_SOURCES_ALL
                WHERE UPPER (NAME) = UPPER ('Intercompany Sales');

        exception
                when others then
                null;
        end;*/



      --SAWKAT
      --v_batch_source_id:= 3002;   ---1;
      BEGIN
         SELECT batch_source_id
           INTO v_batch_source_id
           FROM ar.ra_batch_sources_all rbs
          WHERE rbs.NAME = v_batch_source AND org_id = p_org_id;

         xx_com_pkg.writelog (
               'v_batch_source_id = '
            || v_batch_source_id
            || ', v_batch_source = '
            || v_batch_source);
      EXCEPTION
         WHEN OTHERS
         THEN
            xx_com_pkg.writelog (
               'Unable to derive batch source ' || v_batch_source);
            RAISE;
      END;

      /*
         BEGIN
            SELECT cust_trx_type_id, gl_id_rec, gl_id_rev
              INTO v_cust_trx_type_id, v_rec_ccid, v_rev_ccid
              FROM ra_cust_trx_types_all
             WHERE NAME = v_cust_trx_type                    --'Garments Export INV'
                                         AND org_id = p_org_id;

            xx_com_pkg.writelog (
               'Derived v_cust_trx_type_id = ' || v_cust_trx_type_id);
            xx_com_pkg.writelog ('Derived v_rec_ccid = ' || v_rec_ccid);
            xx_com_pkg.writelog ('Derived v_rev_ccid = ' || v_rev_ccid);
         EXCEPTION
            WHEN OTHERS
            THEN
               xx_com_pkg.writelog (
                  'Unable to derive trx type ' || v_cust_trx_type);
               RAISE;
         END;
         */



      FOR mrec IN mcur
      LOOP
         l_return_status := NULL;
         l_cust_trx_id := NULL;
         i := 0;
         xx_com_pkg.writelog (
            'Inside loop 1 setting mo_global for  ' || mrec.org_id);
         mo_global.set_policy_context ('S', mrec.org_id);
         xx_com_pkg.writelog ('bill_number = ' || mrec.bill_number);
         l_batch_source_rec.batch_source_id := v_batch_source_id;
         l_trx_header_tbl (1).trx_header_id := mrec.invoice_id;
         l_trx_header_tbl (1).interface_header_context := 'DBL_BILL_NUMBER';
         l_trx_header_tbl (1).interface_header_attribute1 := mrec.bill_number;
         l_trx_header_tbl (1).trx_date := mrec.trx_date;
         l_trx_header_tbl (1).gl_date := mrec.gl_date;
         l_trx_header_tbl (1).trx_currency := mrec.invoice_currency_code;
         l_trx_header_tbl (1).exchange_rate_type := 'User';
         l_trx_header_tbl (1).exchange_date := mrec.trx_date;
         l_trx_header_tbl (1).exchange_rate := mrec.exchance_rate;
         l_trx_header_tbl (1).cust_trx_type_id := mrec.cust_trx_type_id;
         l_trx_header_tbl (1).bill_to_customer_id := mrec.customer_id;
         l_trx_header_tbl (1).term_id := 5;                        --IMMEDIATE
         l_trx_header_tbl (1).finance_charges := 'N';
         l_trx_header_tbl (1).status_trx := 'OP';
         l_trx_header_tbl (1).printing_option := 'PRI';
         l_trx_header_tbl (1).comments := mrec.comments;
         l_trx_header_tbl (1).attribute_category := mrec.attribute_category;
         l_trx_header_tbl (1).attribute1 := mrec.bill_number;
         --mrec.attribute1;
         l_trx_header_tbl (1).attribute3 := mrec.attribute3;
         l_trx_header_tbl (1).attribute5 := mrec.attribute5;
         l_trx_header_tbl (1).org_id := mrec.org_id;
         xx_com_pkg.writelog ('Populate Rec info');

         SELECT ra_cust_trx_line_gl_dist_s.NEXTVAL
           INTO l_trx_dist_tbl (1).trx_dist_id
           FROM DUAL;

         l_trx_dist_tbl (1).trx_header_id :=
            l_trx_header_tbl (1).trx_header_id;
         l_trx_dist_tbl (1).trx_line_id := NULL;
         l_trx_dist_tbl (1).account_class := 'REC';
         l_trx_dist_tbl (1).PERCENT := 100;
         l_trx_dist_tbl (1).code_combination_id := mrec.rec_ccid;

         FOR rec IN cur (mrec.invoice_id)
         LOOP
            i := i + 1;
            -- Lines (Main Product)
            xx_com_pkg.writelog (
                  'Inside loop 2 line  '
               || i
               || ', qty = '
               || rec.quantity
               || ', price = '
               || rec.unit_selling_price
               || ', item desc = '
               || rec.item_description);
            l_trx_lines_tbl (i).trx_header_id := rec.invoice_id;

            --l_trx_lines_tbl (i).trx_line_id :=  i;--rec.bill_line_detail_id;
            SELECT ra_customer_trx_lines_s.NEXTVAL
              INTO l_trx_lines_tbl (i).trx_line_id
              FROM DUAL;

            l_trx_lines_tbl (i).line_number := i;
            l_trx_lines_tbl (i).description := rec.item_description;
            l_trx_lines_tbl (i).uom_code := rec.uom_code;
            l_trx_lines_tbl (i).quantity_invoiced := rec.quantity;
            l_trx_lines_tbl (i).unit_selling_price := rec.unit_selling_price;
            l_trx_lines_tbl (i).line_type := 'LINE';
            -- l_trx_lines_tbl (i).interface_line_context := 'DBL_IC_INVOICE';
            -- l_trx_lines_tbl (i).interface_line_attribute1 := rec.challan_number;
            -- l_trx_lines_tbl (i).interface_line_attribute2 := rec.challan_date;
            -- l_trx_lines_tbl (i).interface_line_attribute3 := rec.pi_number;
            -- l_trx_lines_tbl (i).interface_line_attribute4 := rec.order_number;
            --l_trx_lines_tbl (i).interface_line_attribute5 := rec.bill_line_detail_id;
            xx_com_pkg.writelog ('Populate Rev info for line ' || i);

            SELECT ra_cust_trx_line_gl_dist_s.NEXTVAL
              INTO l_trx_dist_tbl (i + 1).trx_dist_id
              FROM DUAL;

            l_trx_dist_tbl (i + 1).trx_header_id :=
               l_trx_header_tbl (1).trx_header_id;
            l_trx_dist_tbl (i + 1).trx_line_id :=
               l_trx_lines_tbl (i).trx_line_id;
            l_trx_dist_tbl (i + 1).account_class := 'REV';
            l_trx_dist_tbl (i + 1).amount :=
               ROUND (rec.quantity * rec.unit_selling_price, 2);
            l_trx_dist_tbl (i + 1).code_combination_id := mrec.rev_ccid;
         END LOOP;

         ar_invoice_api_pub.create_single_invoice (
            p_api_version            => 1.0,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data,
            x_customer_trx_id        => l_cust_trx_id,
            p_commit                 => fnd_api.g_true,
            p_batch_source_rec       => l_batch_source_rec,
            p_trx_header_tbl         => l_trx_header_tbl,
            p_trx_lines_tbl          => l_trx_lines_tbl,
            p_trx_dist_tbl           => l_trx_dist_tbl,
            p_trx_salescredits_tbl   => l_trx_salescredits_tbl);
         v_record_count := NVL (v_record_count, 0) + 1;
         xx_com_pkg.writelog ('Msg ' || SUBSTR (p_msg_data, 1, 225));
         xx_com_pkg.writelog ('Status ' || l_return_status);
         xx_com_pkg.writelog ('Cust Trx Id ' || l_cust_trx_id);
         xx_com_pkg.writelog ('organization Id ' || mrec.org_id);
         xx_com_pkg.writelog ('Record Successes ' || v_record_count);
         v_error_msg :=
               'Message '
            || SUBSTR (l_msg_data, 1, 225)
            || '   Status '
            || l_return_status
            || '   Cust Trx Id  '
            || l_cust_trx_id;
         xx_com_pkg.writelog (v_error_msg);

         SELECT COUNT (1) INTO l_cnt FROM ar_trx_errors_gt;

         IF l_return_status = 'S' AND l_cust_trx_id IS NOT NULL AND l_cnt = 0
         THEN
            xx_com_pkg.writelog ('Customer Trx id ' || l_cust_trx_id);

            UPDATE xx_explc_shipment_mst
               SET ar_invoice_id = l_cust_trx_id
             WHERE shipment_id = mrec.invoice_id;

            UPDATE xx_explc_shipment_comm
               SET ar_invoice_id = l_cust_trx_id
             WHERE shipment_id = mrec.invoice_id;

            COMMIT;
         END IF;

         IF    l_return_status = fnd_api.g_ret_sts_error
            OR l_return_status = fnd_api.g_ret_sts_unexp_error
         THEN
            xx_com_pkg.writelog ('unexpected errors found!');
         END IF;

         IF l_cnt > 0
         THEN
            xx_com_pkg.writelog (
                  'Transaction not Created, Please check ar_trx_errors_gt table '
               || mrec.customer_id);

            FOR x IN (SELECT *
                        FROM ar_trx_errors_gt)
            LOOP
               xx_com_pkg.writelog (
                  x.error_message || ' ~ ' || x.invalid_value);
            END LOOP;
         END IF;

         l_trx_header_tbl.DELETE;
         l_trx_lines_tbl.DELETE;
         l_trx_dist_tbl.DELETE;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         xx_com_pkg.writelog (
            'Unexpected error: ' || SUBSTRB (SQLERRM, 1, 200));
   END create_exp_ar_invoice2;

   FUNCTION get_reversal_gl_date (p_cash_receipt_id NUMBER)
      RETURN DATE
   IS
      v_open_gl_date   DATE;
      v_gl_date        DATE;
   BEGIN
      SELECT MAX (gl_date)
        INTO v_gl_date
        FROM ar_cash_receipt_history_all
       WHERE cash_receipt_id = p_cash_receipt_id;

      SELECT v_gl_date
        INTO v_open_gl_date
        FROM gl_period_statuses
       WHERE     set_of_books_id =
                    (SELECT set_of_books_id
                       FROM ar_cash_receipts_all
                      WHERE cash_receipt_id = p_cash_receipt_id)
             AND application_id = 222
             AND closing_status = 'O'
             AND v_gl_date BETWEEN start_date AND end_date;

      RETURN v_open_gl_date;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         SELECT MIN (start_date)
           INTO v_open_gl_date
           FROM gl_period_statuses
          WHERE     set_of_books_id =
                       (SELECT set_of_books_id
                          FROM ar_cash_receipts_all
                         WHERE cash_receipt_id = p_cash_receipt_id)
                AND application_id = 222
                AND closing_status = 'O'
                AND start_date > v_gl_date;

         RETURN v_open_gl_date;
   END get_reversal_gl_date;

   FUNCTION get_br_open_bal (P_LEDGER_ID      NUMBER,
                             P_ORG_ID         NUMBER,
                             P_CUSTOMER_ID    NUMBER,
                             P_DATE_FROM      DATE,
                             P_DATE_TO        DATE)
      RETURN NUMBER
   IS
      V_OPENING_AMOUNT   NUMBER;

      CURSOR P_OPENING_AMOUNT
      IS
         SELECT SUM (BAL_ACCTD_TOTAL) OPENING_AMOUNT
           FROM (WITH BR_INVOICE
                      AS (SELECT DISTINCT
                                 CT.ORG_ID,
                                 RCTT.SET_OF_BOOKS_ID,
                                 CUST.CUSTOMER_TYPE,
                                 CUST.CUSTOMER_CATEGORY_CODE,
                                 CUST.CUSTOMER_ID,
                                 CUST.CUSTOMER_NUMBER,
                                 CUST.CUSTOMER_NAME,
                                    CUST.ADDRESS1
                                 || ', '
                                 || CUST.ADDRESS2
                                 || ', '
                                 || CUST.CITY
                                    ADDRESS,
                                 CASE
                                    WHEN CT.CREATED_FROM = 'OPEN BR'
                                    THEN
                                       TO_CHAR (CT.TRX_NUMBER)
                                    ELSE
                                       TO_CHAR (CT.DOC_SEQUENCE_VALUE)
                                 END
                                    TRX_NUMBER,
                                 CASE
                                    WHEN CT.CREATED_FROM = 'OPEN BR'
                                    THEN
                                       CT.ATTRIBUTE4
                                    ELSE
                                       CT.CUSTOMER_REFERENCE
                                 END
                                    BANk_REF,
                                 CBR.LC_NUMBER,
                                 CT.TRX_DATE,
                                 HISTGL.GL_DATE,
                                 HISTGL.MATURITY_DATE,
                                 CT.BR_AMOUNT AMOUNT,
                                 CT.BR_AMOUNT * NVL (CT.EXCHANGE_RATE, 1)
                                    ACCTD_AMOUNT,
                                 CT.INVOICE_CURRENCY_CODE,
                                 CT.CUSTOMER_TRX_ID
                            FROM RA_CUSTOMER_TRX_ALL CT,
                                 RA_CUST_TRX_TYPES_ALL RCTT,
                                 XX_AR_CUSTOMER_SITE_V CUST,
                                 AR_TRANSACTION_HISTORY_ALL HIST,
                                 AR_TRANSACTION_HISTORY_ALL HISTGL,
                                 XXDBL_BILL_REC_HEADER CBR
                           WHERE     CUST.ORG_ID = CT.ORG_ID
                                 AND CUST.CUSTOMER_ID = CT.DRAWEE_ID
                                 AND CT.CUSTOMER_REFERENCE =
                                        CBR.BR_BANK_REFERENCE(+)
                                 AND CT.ATTRIBUTE4 = CBR.BR_BANK_REFERENCE(+)
                                 AND CT.CUST_TRX_TYPE_ID =
                                        RCTT.CUST_TRX_TYPE_ID
                                 AND CUST.SITE_USE_CODE = 'BILL_TO'
                                 AND CUST.PRIMARY_FLAG = 'Y'
                                 AND CT.CUSTOMER_TRX_ID =
                                        HIST.CUSTOMER_TRX_ID
                                 AND HIST.CURRENT_RECORD_FLAG = 'Y'
                                 AND CT.CUSTOMER_TRX_ID =
                                        HISTGL.CUSTOMER_TRX_ID
                                 AND HISTGL.CURRENT_ACCOUNTED_FLAG = 'Y'
                                 AND HIST.STATUS NOT IN
                                        ('INCOMPLETE', 'CANCELLED')
                                 --AND CT.TRX_NUMBER='521006184'
                                 AND TRUNC (HISTGL.GL_DATE) <= P_DATE_TO),
                      RECEIPT
                      AS (  SELECT APPLIED_CUSTOMER_TRX_ID,
                                   ORG_ID,
                                   SUM (AMOUNT_APPLIED) RECEIPT_ENT_AMOUNT,
                                   SUM (ACCTD_AMOUNT_APPLIED_TO)
                                      RECEIPT_ACCTD_AMOUNT
                              FROM APPS.AR_RECEIVABLE_APPLICATIONS_ALL
                             WHERE     DISPLAY = 'Y'
                                   AND APPLICATION_TYPE <> 'CM'
                                   AND TRUNC (GL_DATE) < P_DATE_FROM
                          GROUP BY APPLIED_CUSTOMER_TRX_ID, ORG_ID)
                   SELECT CUSTOMER_NUMBER,
                          CUSTOMER_NAME,
                          ADDRESS,
                          NVL (SUM (AMOUNT), 0) AMOUNT,
                          NVL (SUM (ACCTD_AMOUNT), 0) ACCTD_AMOUNT,
                          NVL (SUM (NVL (ACCTD_AMOUNT_APPLIED, 0)), 0)
                             ACCTD_AMOUNT_APPLIED,
                          NVL (
                             SUM (ACCTD_AMOUNT - NVL (ACCTD_AMOUNT_APPLIED, 0)),
                             0)
                             BAL_ACCTD_TOTAL
                     FROM (SELECT CUSTOMER_NUMBER,
                                  CUSTOMER_NAME,
                                  ADDRESS,
                                  NVL (AMOUNT, 0) - NVL (RECEIPT_ENT_AMOUNT, 0)
                                     AMOUNT,
                                    NVL (ACCTD_AMOUNT, 0)
                                  - NVL (RECEIPT_ACCTD_AMOUNT, 0)
                                     ACCTD_AMOUNT,
                                  APPS.XX_AR_PKG.GET_BR_RCT_AMOUNT (
                                     BR.ORG_ID,
                                     BR.CUSTOMER_ID,
                                     BR.CUSTOMER_TRX_ID,
                                     'ACCTD',
                                     P_DATE_FROM,
                                     P_DATE_TO)
                                     ACCTD_AMOUNT_APPLIED
                             FROM BR_INVOICE BR, RECEIPT RCT
                            WHERE     BR.CUSTOMER_TRX_ID =
                                         RCT.APPLIED_CUSTOMER_TRX_ID(+)
                                  AND (P_ORG_ID IS NULL OR BR.ORG_ID = P_ORG_ID)
                                  AND BR.ORG_ID = RCT.ORG_ID(+)
                                  AND BR.SET_OF_BOOKS_ID = P_LEDGER_ID
                                  AND (   P_CUSTOMER_ID IS NULL
                                       OR BR.CUSTOMER_ID = P_CUSTOMER_ID)
                                  AND TRUNC (BR.GL_DATE) < P_DATE_FROM)
                 GROUP BY CUSTOMER_NUMBER, CUSTOMER_NAME, ADDRESS);
   BEGIN
      OPEN P_OPENING_AMOUNT;

      FETCH P_OPENING_AMOUNT INTO V_OPENING_AMOUNT;

      CLOSE P_OPENING_AMOUNT;

      RETURN (V_OPENING_AMOUNT);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END GET_BR_OPEN_BAL;

   FUNCTION get_ar_open_bal (P_LEDGER_ID      NUMBER,
                             P_ORG_ID         NUMBER,
                             P_CUSTOMER_ID    NUMBER,
                             P_DATE_FROM      DATE,
                             P_DATE_TO        DATE)
      RETURN NUMBER
   IS
      V_OPENING_AMOUNT   NUMBER;

      CURSOR P_OPENING_AMOUNT
      IS
         SELECT SUM (BAL_ACCTD_TOTAL) OPENING_AMOUNT
           FROM (WITH AR_INVOICE
                      AS (SELECT DISTINCT
                                 CT.ORG_ID,
                                 CT.LEGAL_ENTITY_ID,
                                 RCTT.SET_OF_BOOKS_ID,
                                 CUST_SITE.CUSTOMER_TYPE,
                                 CUST_SITE.CUSTOMER_CATEGORY_CODE,
                                 CT.BILL_TO_CUSTOMER_ID CUSTOMER_ID,
                                 CUST_SITE.CUSTOMER_NUMBER,
                                 CUST_SITE.CUSTOMER_NAME,
                                    CUST_SITE.ADDRESS1
                                 || ', '
                                 || CUST_SITE.ADDRESS2
                                 || ', '
                                 || CUST_SITE.CITY
                                    ADDRESS,
                                 CT.CUSTOMER_TRX_ID,
                                 CT.TRX_NUMBER,
                                 CT.TRX_DATE,
                                 DIST.GL_DATE,
                                 DISTCM.GL_DATE CM_GL_DATE,
                                 CT.ATTRIBUTE7 MAJOR_TYPE,
                                 DECODE (CT.ATTRIBUTE_CATEGORY,
                                         'Export', SHIPMENT_NUMBER,
                                         'Bill Invoice', BILL.BILL_NUMBER,
                                         ct.ATTRIBUTE9)
                                    Bill_number,
                                 DECODE (CT.ATTRIBUTE_CATEGORY,
                                         'Export', CT.ATTRIBUTE3,
                                         CT.ATTRIBUTE10)
                                    challan_number,
                                 CASE
                                    WHEN CT.ATTRIBUTE_CATEGORY = 'Export'
                                    THEN
                                       'Export of Garments'
                                    WHEN CT.TRX_DATE = '31-DEC-2012'
                                    THEN
                                       'Opening Balance'
                                    ELSE
                                       CT.ATTRIBUTE8
                                 END
                                    Sub_type,
                                 (SELECT DISTINCT
                                            B.CUSTOMER_NAME
                                         || ' - '
                                         || B.CUSTOMER_NUMBER
                                    FROM XX_AR_CUSTOMER_SITE_V B
                                   WHERE CT.ATTRIBUTE11 = B.CUSTOMER_ID)
                                    BUYER,
                                 CT.INVOICE_CURRENCY_CODE,
                                 DECODE (CT.INVOICE_CURRENCY_CODE,
                                         'BDT', DIST.AMOUNT * 0,
                                         'USD', DIST.AMOUNT * 1)
                                    ENT_AMOUNT,
                                 DIST.ACCTD_AMOUNT,
                                 DISTCM.AMOUNT CM_ENT_AMOUNT,
                                 DISTCM.ACCTD_AMOUNT CM_ACCTD_AMOUNT,
                                 CT.PRIMARY_SALESREP_ID,
                                 QUANTITY_INVOICED,
                                 RCTT.ATTRIBUTE1 SUB_UNIT
                            FROM RA_CUSTOMER_TRX_ALL CT,
                                 RA_CUST_TRX_LINE_GL_DIST_ALL DIST,
                                 XX_AR_CUSTOMER_SITE_V CUST_SITE,
                                 RA_CUSTOMER_TRX_ALL CTCM,
                                 RA_CUST_TRX_LINE_GL_DIST_ALL DISTCM,
                                 RA_CUST_TRX_TYPES_ALL RCTT,
                                 XX_EXPLC_SHIPMENT_MST SHIP,
                                 XX_AR_BILLS_HEADERS_ALL BILL,
                                 FND_LOOKUP_VALUES_VL LOOKUP,
                                 RA_CUSTOMER_TRX_ALL CTCM2,
                                 RA_CUST_TRX_LINE_GL_DIST_ALL DISTCM2,
                                 (  SELECT CUSTOMER_TRX_ID,
                                           SUM (QUANTITY_INVOICED)
                                              QUANTITY_INVOICED
                                      FROM RA_CUSTOMER_TRX_LINES_ALL
                                  GROUP BY CUSTOMER_TRX_ID) CTL
                           WHERE     DIST.ACCOUNT_CLASS = 'REC'
                                 AND DISTCM.ACCOUNT_CLASS(+) = 'REC'
                                 AND DISTCM2.ACCOUNT_CLASS(+) = 'REC'
                                 AND CT.cust_trx_type_id NOT IN (1789)
                                 AND RCTT.TYPE NOT IN ('DM')
                                 AND CT.SOLD_TO_CUSTOMER_ID IS NOT NULL
                                 AND UPPER (RCTT.TYPE) = LOOKUP.LOOKUP_CODE
                                 AND CT.CUSTOMER_TRX_ID =
                                        DIST.CUSTOMER_TRX_ID
                                 AND CT.CUSTOMER_TRX_ID = CTL.CUSTOMER_TRX_ID
                                 AND CT.CUST_TRX_TYPE_ID =
                                        RCTT.CUST_TRX_TYPE_ID
                                 AND CT.CUSTOMER_TRX_ID =
                                        CTCM.PREVIOUS_CUSTOMER_TRX_ID(+)
                                 AND CTCM.CUSTOMER_TRX_ID =
                                        DISTCM.CUSTOMER_TRX_ID(+)
                                 AND CT.CUSTOMER_TRX_ID =
                                        CTCM2.PREVIOUS_CUSTOMER_TRX_ID(+)
                                 AND CTCM.CUSTOMER_TRX_ID =
                                        DISTCM2.CUSTOMER_TRX_ID(+)
                                 AND CUST_SITE.CUSTOMER_ID =
                                        CT.BILL_TO_CUSTOMER_ID
                                 AND CUST_SITE.ORG_ID = CT.ORG_ID
                                 AND CUST_SITE.SITE_USE_CODE = 'BILL_TO'
                                 AND CUST_SITE.PRIMARY_FLAG = 'Y'
                                 AND CT.ATTRIBUTE1 = SHIP.SHIPMENT_NUMBER(+)
                                 AND CT.ATTRIBUTE6 = BILL.BILL_HEADER_ID(+)
                                 AND (  NVL (DIST.ACCTD_AMOUNT, 0)
                                      + NVL (DISTCM2.ACCTD_AMOUNT, 0)) <> 0
                                 AND CT.COMPLETE_FLAG = 'Y'
                                 AND CTCM.COMPLETE_FLAG(+) = 'Y'
                                 AND CTCM2.COMPLETE_FLAG(+) = 'Y'
                                 AND RCTT.NAME NOT IN
                                        ('Access. Sale CM',
                                         'Allover Printing CM',
                                         'Buying Comm. CM',
                                         'Cartoon Sales CM',
                                         'CCTV Income CM',
                                         'DHL Local Sales CM',
                                         'Diesel Income CM',
                                         'Dredging Income CM',
                                         'Dye & Finish Inc CM',
                                         'Dyeing Income CM',
                                         'Embroidery CM',
                                         'Embroidery Income CM',
                                         'Enecon Income CM',
                                         'Export Lingerie CM',
                                         'Fabrics Export CM',
                                         'Fabrics Export CM.',
                                         'Fibre Dyeing CM',
                                         'Finishing Income CM',
                                         'Fire S.S Income CM',
                                         'Garments Export CM',
                                         'Garments Export CM.',
                                         'Gmts. Printing CM',
                                         'InkCups Income CM',
                                         'Insurance Claim CM',
                                         'Insurance Claim CM.',
                                         'Int Incoming RSP C',
                                         'Int Incoming VSP C',
                                         'Int Incoming-FC CM',
                                         'Knitting Income CM',
                                         'Knitting Income CM.',
                                         'Life Stye CM',
                                         'Lift Income CM',
                                         'Local Sales FG CM',
                                         'Open Invoice CM',
                                         'Others Income CM',
                                         'Out Going Call CM',
                                         'Out Going RSP CM',
                                         'Raw Cotton Sales CM',
                                         'Realization Adj.',
                                         'Rental Income CM',
                                         'Rental Income CM.',
                                         'Return Credit Memo',
                                         'Sales of Ticket CM',
                                         'Scraps Sales CM',
                                         'Scraps Sales CM.',
                                         'Screen Print CM.',
                                         'Sewing Thread CM',
                                         'Sponsor Income CM',
                                         'Sub-Contract CM',
                                         'Sub-Contract CM.',
                                         'Textiles Testing CM',
                                         'Tiles Export CM',
                                         'Tiles Sale -Dealer',
                                         'Trading Income CM',
                                         'Twisting Income CM',
                                         'Visa Processing CM',
                                         'Washing Income CM',
                                         'Washing Income- CM',
                                         'Yarn Dyeing CM',
                                         'Yarn Sales CM',
                                         'Yarn Sales CM-(Mel)',
                                         'Yarn Sales CM-(Syn)')
                                 AND LOOKUP.LOOKUP_TYPE =
                                        'DBL_AR_INVOICE_DETAIL'
                                 AND LOOKUP.enabled_flag = 'Y'
                                 AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                                LOOKUP.START_DATE_ACTIVE)
                                                         AND TRUNC (
                                                                NVL (
                                                                   LOOKUP.END_DATE_ACTIVE,
                                                                   SYSDATE))
                                 AND TRUNC (DIST.GL_DATE) <= P_DATE_TO
                                 AND TRUNC (DISTCM.GL_DATE(+)) < P_DATE_FROM
                                 AND TRUNC (DISTCM2.GL_DATE(+)) BETWEEN P_DATE_FROM
                                                                    AND P_DATE_TO),
                      BR_INVOICE
                      AS (  SELECT CUSTOMER_TRX_ID,
                                   SUM (AMOUNT) BR_ENT_AMOUNT,
                                   SUM (ACCTD_AMOUNT) BR_ACCTD_AMOUNT
                              FROM AR_ADJUSTMENTS_ALL
                             WHERE     UPPER (ADJUSTMENT_TYPE) = 'X'
                                   AND STATUS = 'A'
                                   AND TRUNC (GL_DATE) < P_DATE_FROM
                          GROUP BY CUSTOMER_TRX_ID),
                      ADJUSTMENT
                      AS (  SELECT CUSTOMER_TRX_ID,
                                   SUM (AMOUNT) ADJUST_ENT_AMOUNT,
                                   SUM (ACCTD_AMOUNT) ADJUST_ACCTD_AMOUNT
                              FROM AR_ADJUSTMENTS_ALL
                             WHERE     UPPER (ADJUSTMENT_TYPE) = 'M'
                                   AND STATUS = 'A'
                                   AND TRUNC (GL_DATE) < P_DATE_FROM
                          GROUP BY CUSTOMER_TRX_ID),
                      Receipt
                      AS (  SELECT APPLIED_CUSTOMER_TRX_ID,
                                   SUM (AMOUNT_APPLIED) RECEIPT_ENT_AMOUNT,
                                   SUM (ACCTD_AMOUNT_APPLIED_TO)
                                      RECEIPT_ACCTD_AMOUNT
                              FROM APPS.AR_RECEIVABLE_APPLICATIONS_ALL
                             WHERE     DISPLAY = 'Y'
                                   AND APPLICATION_TYPE <> 'CM'
                                   AND TRUNC (GL_DATE) < P_DATE_FROM
                          GROUP BY APPLIED_CUSTOMER_TRX_ID)
                   SELECT CUSTOMER_NUMBER,
                          CUSTOMER_NAME,
                          ADDRESS,
                          SUM (ACCTD_AMOUNT) ACCTD_AMOUNT,
                          NVL (
                             SUM (
                                ABS (
                                     NVL (CM_ACCTD_AMOUNT_OA, 0)
                                   + LEAST (NVL (ADJUST_ACCTD_AMOUNT_OA, 0), 0))),
                             0)
                             CM_ACCTD_AMOUNT,
                          NVL (
                             SUM (
                                NVL (
                                   (  ABS (NVL (BR_ACCTD_AMOUNT_OA, 0))
                                    + NVL (RECEIPT_ACCTD_AMOUNT_OA, 0)),
                                   0)),
                             0)
                             BR_ACCTD_AMOUNT,
                          NVL (
                             SUM (
                                NVL (GREATEST (ADJUST_ACCTD_AMOUNT_OA, 0), 0)),
                             0)
                             ADJUST_ACCTD_AMOUNT,
                          SUM (
                             (  ACCTD_AMOUNT
                              + NVL (CM_ACCTD_AMOUNT_OA, 0)
                              + NVL (BR_ACCTD_AMOUNT_OA, 0)
                              + NVL (ADJUST_ACCTD_AMOUNT_OA, 0)
                              - NVL (RECEIPT_ACCTD_AMOUNT_OA, 0)))
                             BAL_ACCTD_TOTAL
                     FROM (SELECT AR.CUSTOMER_NUMBER,
                                  AR.CUSTOMER_NAME,
                                  AR.ADDRESS,
                                  NVL (
                                     NVL (
                                          (  NVL (AR.ACCTD_AMOUNT, 0)
                                           + NVL (AR.CM_ACCTD_AMOUNT, 0)
                                           + NVL (ADJ.ADJUST_ACCTD_AMOUNT, 0)
                                           + NVL (BR.BR_ACCTD_AMOUNT, 0))
                                        - NVL (RCT.RECEIPT_ACCTD_AMOUNT, 0) ---,1)
                                                                           ,
                                        0),
                                     0)
                                     ACCTD_AMOUNT,
                                  APPS.XX_AR_PKG.GET_BR_AMOUNT (
                                     AR.ORG_ID,
                                     AR.CUSTOMER_ID,
                                     AR.CUSTOMER_TRX_ID,
                                     'ACCTD',
                                     P_DATE_FROM,
                                     P_DATE_TO)
                                     BR_ACCTD_AMOUNT_OA,
                                  APPS.XX_AR_PKG.GET_ADJ_AMOUNT (
                                     AR.ORG_ID,
                                     AR.CUSTOMER_ID,
                                     AR.CUSTOMER_TRX_ID,
                                     'ACCTD',
                                     P_DATE_FROM,
                                     P_DATE_TO)
                                     ADJUST_ACCTD_AMOUNT_OA,
                                  APPS.XX_AR_PKG.GET_RECEIPT_AMOUNT (
                                     AR.ORG_ID,
                                     AR.CUSTOMER_ID,
                                     AR.CUSTOMER_TRX_ID,
                                     'ACCTD',
                                     P_DATE_FROM,
                                     P_DATE_TO)
                                     RECEIPT_ACCTD_AMOUNT_OA,
                                  APPS.XX_AR_PKG.GET_CM_AMOUNT (
                                     AR.ORG_ID,
                                     AR.CUSTOMER_ID,
                                     AR.CUSTOMER_TRX_ID,
                                     'ACCTD',
                                     P_DATE_FROM,
                                     P_DATE_TO)
                                     CM_ACCTD_AMOUNT_OA
                             FROM AR_INVOICE AR,
                                  BR_INVOICE BR,
                                  ADJUSTMENT ADJ,
                                  Receipt RCT
                            WHERE     AR.CUSTOMER_TRX_ID =
                                         BR.CUSTOMER_TRX_ID(+)
                                  AND AR.CUSTOMER_TRX_ID =
                                         ADJ.CUSTOMER_TRX_ID(+)
                                  AND AR.CUSTOMER_TRX_ID =
                                         RCT.APPLIED_CUSTOMER_TRX_ID(+)
                                  AND AR.SET_OF_BOOKS_ID = P_LEDGER_ID
                                  AND (P_ORG_ID IS NULL OR AR.ORG_ID = P_ORG_ID)
                                  AND (   P_CUSTOMER_ID IS NULL
                                       OR AR.CUSTOMER_ID = P_CUSTOMER_ID)
                                  AND TRUNC (AR.GL_DATE) < P_DATE_FROM)
                 GROUP BY CUSTOMER_NUMBER, CUSTOMER_NAME, ADDRESS);
   BEGIN
      OPEN P_OPENING_AMOUNT;

      FETCH P_OPENING_AMOUNT INTO V_OPENING_AMOUNT;

      CLOSE P_OPENING_AMOUNT;

      RETURN (V_OPENING_AMOUNT);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END GET_AR_OPEN_BAL;
END xx_ar_pkg;
/