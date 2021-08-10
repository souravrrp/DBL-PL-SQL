/* Formatted on 5/16/2021 3:35:33 PM (QP5 v5.287) */
DECLARE
   p_customer_profile_rec_type   HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
   p_cust_account_profile_id     NUMBER;
   p_object_version_number       NUMBER;
   x_return_status               VARCHAR2 (2000);
   x_msg_count                   NUMBER;
   x_msg_data                    VARCHAR2 (2000);
   l_user_id                     NUMBER;
   l_resp_id                     NUMBER;
   l_respid_id                   NUMBER;
   in_out_version_no             NUMBER;
   in_out_version_no_hcpa        NUMBER;
   v_customer_profile_amt        HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE;
   v_cust_act_prof_amt_id        NUMBER;
   v_cust_account_profile_id     NUMBER;
   v_return_status               VARCHAR2 (2000);
   v_msg_count                   NUMBER;
   v_msg_data                    VARCHAR2 (2000);
   p_create_profile_amt          VARCHAR2 (2000);
   v_msg_dummy                   VARCHAR2 (5000);
   t_output                      VARCHAR2 (5000);
   mTrx                          NUMBER;
   mOverall                      NUMBER;
BEGIN
   FOR i
      IN (SELECT hcp.CUST_ACCOUNT_PROFILE_ID profile_id,
                 hca.cust_account_id,
                 hcp.site_use_id,
                 account_number,
                 hcas.ORG_ID org_id,
                 CUST_ACCT_PROFILE_AMT_ID
            FROM hz_cust_accounts hca,
                 hz_parties hp,
                 hz_party_sites hps,
                 hz_cust_acct_sites_all hcas,
                 hz_cust_site_uses_all hcua,
                 Hz_Customer_Profiles hcp,
                 HZ_CUST_PROFILE_AMTS hcpa
           WHERE     hca.party_id = hp.party_id
                 AND hps.party_id = hp.party_id
                 AND hcas.CUST_ACCOUNT_ID = hca.CUST_ACCOUNT_ID
                 AND hcas.PARTY_SITE_ID = hps.PARTY_SITE_ID
                 AND hcua.CUST_ACCT_SITE_ID = hcas.CUST_ACCT_SITE_ID
                 AND hcp.cust_account_id = hca.cust_account_id
                 AND hcp.site_use_id = hcua.site_use_id
                 AND HCP.CUST_ACCOUNT_PROFILE_ID =
                        HCPA.CUST_ACCOUNT_PROFILE_ID
                 AND account_number IN (SELECT DISTINCT CUSTOMER_NUMBER
                                          FROM ncc_po_credit)
                 AND hcua.SITE_USE_CODE = 'BILL_TO'
                 AND hcas.ORG_ID IN (612,
                                     613,
                                     614,
                                     615,
                                     616,
                                     617))
   LOOP
      p_customer_profile_rec_type.cust_account_profile_id := i.profile_id;
      DBMS_OUTPUT.put_line ('profile_id = ' || i.profile_id);
      MO_GLOBAL.INIT ('AR');
      mo_global.set_policy_context ('S', '612');
      l_user_id := 1295;
      l_resp_id := 52514;
      l_respid_id := 222;
      fnd_global.apps_initialize (l_user_id, l_resp_id, l_respid_id);

      SELECT CREDIT_LIMIT_AMOUNT, CREDIT_LIMIT_AMOUNT
        INTO mTrx, mOverall
        FROM ncc_po_credit
       WHERE CUSTOMER_NUMBER = i.account_number AND ORG_ID = i.org_id;

      DBMS_OUTPUT.put_line ('Credit Limit = ' || mTrx || ' ' || mOverall);
      DBMS_OUTPUT.put_line (
         'CUST_ACCT_PROFILE_AMT_ID = ' || i.CUST_ACCT_PROFILE_AMT_ID);
      v_customer_profile_amt.cust_account_profile_id := i.profile_id;
      v_customer_profile_amt.cust_acct_profile_amt_id :=
         i.CUST_ACCT_PROFILE_AMT_ID;
      v_customer_profile_amt.cust_account_id := i.cust_account_id;
      v_customer_profile_amt.SITE_USE_id := i.site_use_id;
      v_customer_profile_amt.currency_code := 'BHD';
      v_customer_profile_amt.trx_credit_limit := mTrx;
      v_customer_profile_amt.overall_credit_limit := mOverall;

      -- v_customer_profile_amt.created_by_module := 'HZ_CPUI';   -- commented by Rushi
      SELECT HCPA.object_version_number
        INTO in_out_version_no_hcpa
        FROM hz_customer_profiles hcp, HZ_CUST_PROFILE_AMTS HCPA
       WHERE     hcp.cust_account_profile_id = i.profile_id
             AND HCP.CUST_ACCOUNT_PROFILE_ID = HCPA.CUST_ACCOUNT_PROFILE_ID;

      DBMS_OUTPUT.put_line (
         'Profile amt version = ' || in_out_version_no_hcpa);
      p_object_version_number := in_out_version_no_hcpa;
      hz_customer_profile_v2pub.update_cust_profile_amt (
         p_init_msg_list           => 'T',
         p_cust_profile_amt_rec    => v_customer_profile_amt,
         p_object_version_number   => p_object_version_number,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data);
      DBMS_OUTPUT.put_line (
         'x_return_status = ' || SUBSTR (x_return_status, 1, 255));
      DBMS_OUTPUT.put_line (
         'Object Version Number = ' || TO_CHAR (p_object_version_number));
      DBMS_OUTPUT.put_line (
         'Credit Rating = ' || p_customer_profile_rec_type.credit_rating);
      DBMS_OUTPUT.put_line ('x_msg_count = ' || TO_CHAR (x_msg_count));
      DBMS_OUTPUT.put_line ('x_msg_data = ' || SUBSTR (x_msg_data, 1, 255));

      IF x_msg_count > 1
      THEN
         FOR I IN 1 .. x_msg_count
         LOOP
            DBMS_OUTPUT.put_line (
                  I
               || '.'
               || SUBSTR (FND_MSG_PUB.Get (p_encoded => FND_API.G_FALSE),
                          1,
                          255));
         END LOOP;
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE ('Error: ' || SQLERRM);
END;