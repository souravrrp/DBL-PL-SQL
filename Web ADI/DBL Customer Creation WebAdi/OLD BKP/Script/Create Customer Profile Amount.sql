/* Formatted on 5/30/2021 10:05:22 AM (QP5 v5.287) */
DECLARE
   CURSOR c
   IS
      SELECT *
        FROM xxdbl.xxdbl_cust_creation_tbl a
       WHERE a.cust_id = 1000081;

   p_cpamt_rec                  HZ_CUSTOMER_PROFILE_V2PUB.cust_profile_amt_rec_type;

   x_return_status              VARCHAR2 (2000);
   x_msg_count                  NUMBER;
   x_msg_data                   VARCHAR2 (2000);
   x_cust_acct_profile_amt_id   NUMBER;
   l_profile_id                 NUMBER;
   lp_site_use_id               NUMBER := 283791;
BEGIN
   FOR r IN c
   LOOP
      MO_GLOBAL.INIT ('AR');
      MO_GLOBAL.SET_POLICY_CONTEXT ('S', r.operating_unit);
      FND_GLOBAL.APPS_INITIALIZE (5958,
                                  20678,
                                  222,
                                  0);

      SELECT cust_account_profile_id
        INTO l_profile_id
        FROM hz_customer_profiles
       WHERE cust_account_id = r.cust_account_id AND ROWNUM = 1;

      p_cpamt_rec.cust_account_profile_id := l_profile_id;
      p_cpamt_rec.currency_code :=
         CASE WHEN r.operating_unit = 126 THEN 'BDT' ELSE 'USD' END; --'BDT';  --<< Currency Code
      --p_cpamt_rec.created_by_module := 'TCAAPI';
      p_cpamt_rec.created_by_module := 'HZ_CPUI';
      p_cpamt_rec.overall_credit_limit := 1000000;
      p_cpamt_rec.cust_account_id := r.cust_account_id;
      -- if you want to create the amounts at site level use this line
      p_cpamt_rec.site_use_id := lp_site_use_id;


      HZ_CUSTOMER_PROFILE_V2PUB.create_cust_profile_amt (
         'T',
         'T',
         p_cpamt_rec,
         x_cust_acct_profile_amt_id,
         x_return_status,
         x_msg_count,
         x_msg_data);
      COMMIT;

      DBMS_OUTPUT.put_line ('***************************');
      DBMS_OUTPUT.put_line ('Output information ....');
      DBMS_OUTPUT.put_line (
         'x_cust_acct_profile_amt_id: ' || x_cust_acct_profile_amt_id);
      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);
      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);
      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);
      DBMS_OUTPUT.put_line ('***************************');

      IF x_msg_count > 1
      THEN
         FOR I IN 1 .. x_msg_count
         LOOP
            DBMS_OUTPUT.put_line (
                  I
               || '. '
               || SUBSTR (FND_MSG_PUB.Get (p_encoded => FND_API.G_FALSE),
                          1,
                          255));
         END LOOP;
      END IF;
   END LOOP;
END;