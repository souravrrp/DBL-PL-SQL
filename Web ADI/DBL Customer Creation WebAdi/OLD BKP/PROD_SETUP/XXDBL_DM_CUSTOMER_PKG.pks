CREATE OR REPLACE PACKAGE APPS.xxdbl_dm_customer_pkg
IS
   PROCEDURE create_customer_site_uses (
      p_cust_acct_site_id           NUMBER,
      p_site_use                    VARCHAR2,
      p_site_name                   VARCHAR2,
      p_payment_term_id             NUMBER,
      p_tax_code                    VARCHAR2,
      p_gl_account_id               NUMBER,
      p_org_id                      NUMBER,
      p_salesrep_id                 NUMBER,
      p_territory_id                NUMBER,
      p_bill_to_site_use_id         NUMBER,
      p_oe_type                     VARCHAR2,
      p_price_list                  VARCHAR2,
      p_frt_term                    VARCHAR2,
      x_site_use_id           OUT   NUMBER,
      x_error_message         OUT   VARCHAR2
   );

   PROCEDURE create_customer_site (
      p_cust_account_id                NUMBER,
      p_party_site_id                  NUMBER,
      l_org_id                         NUMBER,
      p_territory                      VARCHAR2,
      p_customer_category_code         VARCHAR2,                       -- New
      x_cust_acct_site_id        OUT   NUMBER,
      x_error_message            OUT   VARCHAR2
   );

   PROCEDURE insert_data (
      x_errbuff        OUT NOCOPY   VARCHAR2,
      x_retcode        OUT NOCOPY   NUMBER,
      p_organization                VARCHAR2
   );

   PROCEDURE insert_customer_profile (
      p_organization    VARCHAR2,
      p_customer_name   VARCHAR2
   );

   PROCEDURE insert_contact (p_organization VARCHAR2, p_customer_name VARCHAR2);

   FUNCTION order_type_fn (p_oe_type VARCHAR2, p_org_id NUMBER)
      RETURN NUMBER;

   FUNCTION cust_code_derive_fn (p_cust_type VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION price_list_fn (p_price_list VARCHAR2)
      RETURN NUMBER;
END;
/