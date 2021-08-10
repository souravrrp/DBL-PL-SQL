/* Formatted on 4/10/2021 3:13:20 PM (QP5 v5.287) */
DECLARE
   CURSOR c1
   IS
      SELECT *
        FROM xxdbl.xxdbl_cust_creation_tbl
       WHERE status IS NULL;


   -------------------
   p_cust_account_rec       HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
   p_organization_rec       HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
   p_customer_profile_rec   HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
   p_create_profile_amt     HZ_CUSTOMER_PROFILE_V2PUB.cust_profile_amt_rec_type;
   x_cust_account_id        NUMBER;
   x_account_number         VARCHAR2 (2000);
   x_party_id               NUMBER;
   x_party_number           VARCHAR2 (2000);
   x_profile_id             NUMBER;
   x_return_status          VARCHAR2 (2000);
   x_msg_count              NUMBER;
   x_msg_data               VARCHAR2 (2000);
   l_return_val             NUMBER;
BEGIN
   FOR i IN c1
   LOOP
      BEGIN
         MO_GLOBAL.INIT ('AR');
         MO_GLOBAL.SET_POLICY_CONTEXT ('S', i.operating_unit);
         FND_GLOBAL.APPS_INITIALIZE (5958,
                                     20678,
                                     222,
                                     0);

         p_cust_account_rec.account_name := i.customer_name;
         p_cust_account_rec.created_by_module := 'HZ_CPUI';
         p_cust_account_rec.customer_type := i.customer_type;
         p_organization_rec.organization_name := i.customer_name;
         p_organization_rec.created_by_module := 'HZ_CPUI';
         p_cust_account_rec.attribute_category := i.attribute_category;
         p_cust_account_rec.attribute1 := i.attribute1;
         p_cust_account_rec.attribute2 := i.attribute2;
         p_cust_account_rec.attribute3 := i.attribute3;
         p_cust_account_rec.attribute4 := i.attribute4;
         p_cust_account_rec.sales_channel_code := i.buyer; --demand_class_code
         p_customer_profile_rec.standard_terms := i.payment_term;
         p_create_profile_amt.currency_code :=
            CASE WHEN i.operating_unit = 126 THEN 'BDT' ELSE 'USD' END;
         p_customer_profile_rec.credit_checking := 'Y';


         DBMS_OUTPUT.PUT_LINE (
            'Calling the API hz_cust_account_v2pub.create_cust_account');

         HZ_CUST_ACCOUNT_V2PUB.CREATE_CUST_ACCOUNT (
            p_init_msg_list          => FND_API.G_TRUE,
            p_cust_account_rec       => p_cust_account_rec,
            p_organization_rec       => p_organization_rec,
            p_customer_profile_rec   => p_customer_profile_rec,
            p_create_profile_amt     => FND_API.G_FALSE, --p_create_profile_amt,
            x_cust_account_id        => x_cust_account_id,
            x_account_number         => x_account_number,
            x_party_id               => x_party_id,
            x_party_number           => x_party_number,
            x_profile_id             => x_profile_id,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);

         IF x_return_status = fnd_api.g_ret_sts_success
         THEN
            --l_return_val := create_customer_site (i.cust_id, x_cust_account_id);

            UPDATE xxdbl.xxdbl_cust_creation_tbl
               SET status = 'Y'
             WHERE status IS NULL AND cust_id = i.cust_id;

            COMMIT;

            DBMS_OUTPUT.PUT_LINE (
               'Creation of Party and customer account is Successful ');
            DBMS_OUTPUT.PUT_LINE ('Output information ....');
            DBMS_OUTPUT.PUT_LINE (
               'x_cust_account_id  : ' || x_cust_account_id);
            DBMS_OUTPUT.PUT_LINE (
               'x_account_number   : ' || x_account_number);
            DBMS_OUTPUT.PUT_LINE ('x_party_id         : ' || x_party_id);
            DBMS_OUTPUT.PUT_LINE ('x_party_number     : ' || x_party_number);
            DBMS_OUTPUT.PUT_LINE ('x_profile_id       : ' || x_profile_id);
         ELSE
            DBMS_OUTPUT.put_line (
               'Creation of Party and customer account failed:' || x_msg_data);
            ROLLBACK;

            FOR i IN 1 .. x_msg_count
            LOOP
               x_msg_data := oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
               DBMS_OUTPUT.put_line (i || ') ' || x_msg_data);
            END LOOP;
         END IF;

         DBMS_OUTPUT.PUT_LINE ('Completion of API');
      END;
   END LOOP;

   COMMIT;
END;