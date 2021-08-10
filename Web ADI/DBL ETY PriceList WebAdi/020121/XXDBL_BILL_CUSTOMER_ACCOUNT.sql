/* Formatted on 1/2/2021 3:05:59 PM (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW APPS.XXDBL_BILL_CUSTOMER_ACCOUNT
(
   CUST_ACCOUNT_ID,
   ACCOUNT_NAME,
   ACCOUNT_NUMBER,
   ORG_ID,
   CUST_ACCT_SITE_ID,
   SITE_USE_CODE,
   SITE_USE_ID,
   PARTY_ID
)
   BEQUEATH DEFINER
AS
   SELECT c.cust_account_id,
          c.account_name,
          c.account_number,
          a.org_id,
          a.cust_acct_site_id,
          b.site_use_code,
          b.site_use_id,
          c.party_id
     FROM hz_cust_acct_sites_all a,
          hz_cust_site_uses_all b,
          hz_cust_accounts c
    WHERE     c.cust_account_id = a.cust_account_id
          AND a.cust_acct_site_id = b.cust_acct_site_id
          --   AND a.cust_account_id = 2064
          AND a.org_id = 125
          AND A.STATUS = 'A'                               -- ADDED BY MONOJIT
          AND b.status = 'A'                   -- ADDED BY SOURAV ON 02-DEC-21
          AND b.site_use_code = 'BILL_TO';