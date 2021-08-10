/* Formatted on 6/23/2020 1:19:59 PM (QP5 v5.287) */
CREATE OR REPLACE PROCEDURE XX_ARINVOICE_INTERFACE (errbuf     OUT VARCHAR2,
                                                    rectcode   OUT VARCHAR2)
AS
   l_org_id               hr_operating_units.organization_id%TYPE;

   l_sob_id               hr_operating_units.set_of_books_id%TYPE;

   l_cust_trx_type_id     ra_cust_trx_types_all.cust_trx_type_id%TYPE;

   l_gl_id_rev            ra_cust_trx_types_all.gl_id_rev%TYPE;

   l_cust_trx_type_name   ra_cust_trx_types_all.name%TYPE;

   l_currency_code        fnd_currencies.currency_code%TYPE;

   l_term_id              ra_terms_tl.term_id%TYPE;

   l_term_name            ra_terms_tl.name%TYPE;

   l_address_id           hz_cust_acct_sites_all.cust_acct_site_id%TYPE;

   l_customer_id          hz_cust_accounts.cust_account_id%TYPE;

   l_verify_flag          CHAR (1);

   l_error_message        VARCHAR2 (2500);
   
BEGIN
   BEGIN
      SELECT organization_id, SET_OF_BOOKS_ID
        INTO l_org_id, l_sob_id
        FROM hr_operating_units
       WHERE name = 'Operating Unit';
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Operating Unit...';
   END;

   BEGIN
      SELECT cust_trx_type_id, name, gl_id_rev
        INTO l_cust_trx_type_id, l_cust_trx_type_name, l_gl_id_rev
        FROM ra_cust_trx_types_all
       WHERE     set_of_books_id = l_sob_id
             AND org_id = l_org_id
             AND name = 'xxx-Spares-Inv';
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Invoice Type...';
   END;



   BEGIN
      SELECT currency_code
        INTO l_currency_code
        FROM fnd_currencies
       WHERE currency_code = 'USD';
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Currency Code...';
   END;



   BEGIN
      SELECT term_id, name
        INTO l_term_id, l_term_name
        FROM ra_terms_tl
       WHERE UPPER (name) = UPPER ('30 Days');
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Terms Name...';
   END;



   BEGIN
      SELECT DISTINCT HCAS.cust_acct_site_id, HCA.cust_account_id
        INTO l_address_id, l_customer_id
        FROM hz_parties HP,
             hz_party_sites HPS,
             hz_cust_accounts HCA,
             hz_cust_acct_sites_all HCAS,
             hz_cust_site_uses_all HCSU
       WHERE     HCA.party_id = HP.party_id
             AND HP.party_id = HPS.party_id
             AND HCA.cust_account_id = HCAS.cust_account_id
             AND HCAS.cust_acct_site_id = HCSU.cust_acct_site_id
             AND HCSU.site_use_code = 'BILL_TO'
             AND HCSU.primary_flag = 'Y'
             AND UPPER (LTRIM (RTRIM (HP.party_name))) =
                    UPPER (LTRIM (RTRIM ('Customer Name')))
             AND HCAs.org_id = l_org_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_verify_flag := 'N';

         l_error_message := 'Invalide Customer Name...';
   END;



   INSERT INTO ra_interface_lines_all (INTERFACE_LINE_ID,
                                       BATCH_SOURCE_NAME,
                                       LINE_TYPE,
                                       CUST_TRX_TYPE_ID,
                                       cust_trx_type_name,
                                       TRX_DATE,
                                       GL_DATE,
                                       CURRENCY_CODE,
                                       term_id,
                                       term_name,
                                       orig_system_bill_customer_id,
                                       orig_system_bill_address_id,
                                       orig_system_sold_customer_id,
                                       QUANTITY,
                                       AMOUNT,
                                       DESCRIPTION,
                                       conversion_type,
                                       conversion_rate,
                                       INTERFACE_LINE_CONTEXT,
                                       INTERFACE_LINE_ATTRIBUTE1,
                                       org_id)
        VALUES (RA_CUSTOMER_TRX_LINES_S.NEXTVAL,
                'Invoice Migration',
                'LINE',
                l_cust_trx_type_id,
                l_cust_trx_type_name,
                SYSDATE,
                SYSDATE,
                l_currency_code,
                l_term_id,
                l_term_name,
                l_customer_id,
                l_address_id,
                l_customer_id,
                1,
                --40000

                1000,
                'AR Invoice 001',
                'User',
                1,
                'Invoice Conversions',
                '1001',
                l_org_id);



   INSERT INTO ra_interface_distributions_all (INTERFACE_LINE_ID,
                                               account_class,
                                               amount,
                                               code_combination_id,
                                               percent,
                                               interface_line_context,
                                               interface_line_attribute1,
                                               org_id)
        VALUES (RA_CUSTOMER_TRX_LINES_S.CURRVAL,
                'REV',
                1000,
                l_gl_id_rev,
                100,
                'Invoice Conversions',
                '1001',
                l_org_id);



   COMMIT;
END XX_ARINVOICE_INTERFACE;
/