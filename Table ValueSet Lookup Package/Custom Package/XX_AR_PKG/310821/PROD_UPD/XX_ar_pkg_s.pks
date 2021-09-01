/* Formatted on 8/30/2021 9:52:05 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE APPS.xx_ar_pkg
AS
   FUNCTION get_party_site_address (p_party_site_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_bank_short_code (p_bank_acct_use_id NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_customer_address (p_customer_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_state_wise_sum_from_acc_id (p_org_id        NUMBER,
                                            p_account_id    NUMBER,
                                            p_state         VARCHAR2,
                                            p_date_from     DATE,
                                            p_date_to       DATE)
      RETURN NUMBER;

   FUNCTION get_customer_name_with_number (p_customer_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_customer_open_balance (p_org_id         NUMBER,
                                       p_customer_id    NUMBER,
                                       p_date           DATE)
      RETURN NUMBER;

   FUNCTION get_shipment_wise_ar (p_org_id         NUMBER,
                                  p_customer_id    NUMBER,
                                  p_shipment_id    NUMBER)
      RETURN NUMBER;

   FUNCTION get_shipment_wise_br (p_org_id         NUMBER,
                                  p_customer_id    NUMBER,
                                  p_shipment_id    NUMBER)
      RETURN NUMBER;

   FUNCTION get_shipment_wise_realization (p_org_id         NUMBER,
                                           p_customer_id    NUMBER,
                                           p_shipment_id    NUMBER)
      RETURN NUMBER;

   FUNCTION get_cci_from_code (p_cc_code VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_trx_number (p_customer_trx_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_challan_no (p_customer_trx_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_customer_refund (p_org_id         NUMBER,
                                 p_customer_id    NUMBER,
                                 p_date_from      DATE,
                                 p_date_to        DATE)
      RETURN NUMBER;

   FUNCTION get_cust_opening_bal (p_org_id         NUMBER,
                                  p_customer_id    NUMBER,
                                  p_date_as_on     DATE)
      RETURN NUMBER;

   FUNCTION get_br_trx_num (p_loan_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_br_trx_date (p_loan_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_br_amount (p_org_id             NUMBER,
                           p_customer_id        NUMBER,
                           p_customer_trx_id    NUMBER,
                           p_status             VARCHAR2,
                           p_date_from          DATE,
                           p_date_to            DATE)
      RETURN NUMBER;

   FUNCTION get_adj_amount (p_org_id             NUMBER,
                            p_customer_id        NUMBER,
                            p_customer_trx_id    NUMBER,
                            p_status             VARCHAR2,
                            p_date_from          DATE,
                            p_date_to            DATE)
      RETURN NUMBER;

   FUNCTION get_receipt_amount (p_org_id             NUMBER,
                                p_customer_id        NUMBER,
                                p_customer_trx_id    NUMBER,
                                p_status             VARCHAR2,
                                p_date_from          DATE,
                                p_date_to            DATE)
      RETURN NUMBER;

   FUNCTION get_cm_amount (p_org_id             NUMBER,
                           p_customer_id        NUMBER,
                           p_customer_trx_id    NUMBER,
                           p_status             VARCHAR2,
                           p_date_from          DATE,
                           p_date_to            DATE)
      RETURN NUMBER;

   FUNCTION get_br_rct_amount (p_org_id             NUMBER,
                               p_customer_id        NUMBER,
                               p_customer_trx_id    NUMBER,
                               p_status             VARCHAR2,
                               p_date_from          DATE,
                               p_date_to            DATE)
      RETURN NUMBER;

   PROCEDURE create_ic_ar_invoice (errbuf             OUT NOCOPY VARCHAR2,
                                   retcode            OUT NOCOPY NUMBER,
                                   --   P_ORG_ID                 IN NUMBER,
                                   p_period_name   IN            VARCHAR2);

   PROCEDURE create_exp_ar_invoice (errbuf             OUT NOCOPY VARCHAR2,
                                    retcode            OUT NOCOPY NUMBER,
                                    p_org_id        IN            NUMBER,
                                    p_period_name   IN            VARCHAR2);

   --Create By Majid 13-Aug-2018
   PROCEDURE create_exp_ar_invoice2 (errbuf             OUT NOCOPY VARCHAR2,
                                     retcode            OUT NOCOPY NUMBER,
                                     p_org_id        IN            NUMBER,
                                     p_period_name   IN            VARCHAR2);

   FUNCTION get_reversal_gl_date (p_cash_receipt_id NUMBER)
      RETURN DATE;


   FUNCTION get_br_open_bal (P_LEDGER_ID      NUMBER,
                             P_ORG_ID         NUMBER,
                             P_CUSTOMER_ID    NUMBER,
                             P_DATE_FROM      DATE,
                             P_DATE_TO        DATE)
      RETURN NUMBER;

   FUNCTION get_ar_open_bal (P_LEDGER_ID      NUMBER,
                             P_ORG_ID         NUMBER,
                             P_CUSTOMER_ID    NUMBER,
                             P_DATE_FROM      DATE,
                             P_DATE_TO        DATE)
      RETURN NUMBER;
END xx_ar_pkg;
/