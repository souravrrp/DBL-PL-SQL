/* Formatted on 6/24/2021 2:49:51 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_cust_creation_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 10-MAR-2021
   -- LAST UPDATE DATE :10-MAR-2021
   -- PURPOSE : CUSTOMER CREATION WEB ADI
   FUNCTION create_cust_profile_amnt (p_cust_id NUMBER)
      RETURN NUMBER
   IS
      CURSOR c
      IS
         SELECT *
           FROM xxdbl.xxdbl_cust_creation_tbl a
          WHERE a.cust_id = p_cust_id;                -- AND a.status IS NULL;

      p_cpamt_rec                  HZ_CUSTOMER_PROFILE_V2PUB.cust_profile_amt_rec_type;

      x_return_status              VARCHAR2 (2000);
      x_msg_count                  NUMBER;
      x_msg_data                   VARCHAR2 (2000);
      x_cust_acct_profile_amt_id   NUMBER;
      l_return_val                 NUMBER;
      l_profile_id                 NUMBER;
   BEGIN
      FOR r IN c
      LOOP
         MO_GLOBAL.INIT ('AR');
         MO_GLOBAL.SET_POLICY_CONTEXT ('S', r.operating_unit);
         FND_GLOBAL.APPS_INITIALIZE (p_user_id,
                                     p_responsibility_id,
                                     p_respappl_id,
                                     0);

         SELECT MAX (cust_account_profile_id)
           INTO l_profile_id
           FROM hz_customer_profiles
          WHERE cust_account_id = r.cust_account_id AND ROWNUM = 1;

         p_cpamt_rec.cust_account_profile_id := l_profile_id;
         p_cpamt_rec.currency_code :=
            CASE WHEN r.operating_unit = 126 THEN 'BDT' ELSE 'USD' END; --'BDT';  --<< Currency Code
         --p_cpamt_rec.created_by_module := 'TCAAPI';
         p_cpamt_rec.created_by_module := 'HZ_CPUI';
         p_cpamt_rec.overall_credit_limit := r.credit_limit;        --1000000;
         p_cpamt_rec.cust_account_id := r.cust_account_id;
         -- if you want to create the amounts at site level use this line
         p_cpamt_rec.site_use_id := r.bill_site_use_id;


         HZ_CUSTOMER_PROFILE_V2PUB.create_cust_profile_amt (
            'T',
            'T',
            p_cpamt_rec,
            x_cust_acct_profile_amt_id,
            x_return_status,
            x_msg_count,
            x_msg_data);
         COMMIT;

         UPDATE xxdbl.xxdbl_cust_creation_tbl
            SET cust_acct_profile_amt_id = x_cust_acct_profile_amt_id,
                cust_account_profile_id = l_profile_id
          WHERE cust_id = r.cust_id;

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

      RETURN x_cust_acct_profile_amt_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION create_site_contact (p_cust_id NUMBER)
      RETURN NUMBER
   IS
      CURSOR c
      IS
         SELECT *
           FROM xxdbl.xxdbl_cust_creation_tbl a
          WHERE a.cust_id = p_cust_id AND a.status IS NULL;

      p_contact_point_rec   hz_contact_point_v2pub.contact_point_rec_type;
      p_phone_rec           hz_contact_point_v2pub.phone_rec_type;
      p_edi_rec_type        hz_contact_point_v2pub.edi_rec_type;
      p_email_rec_type      hz_contact_point_v2pub.email_rec_type;
      p_telex_rec_type      hz_contact_point_v2pub.telex_rec_type;
      p_web_rec_type        hz_contact_point_v2pub.web_rec_type;

      x_contact_point_id    NUMBER;
      x_return_status       VARCHAR2 (2000);
      x_msg_count           NUMBER;
      x_msg_data            VARCHAR2 (2000);
      l_return_val          NUMBER;
   BEGIN
      FOR r IN c
      LOOP
         mo_global.init ('AR');
         MO_GLOBAL.SET_POLICY_CONTEXT ('S', r.operating_unit);
         FND_GLOBAL.APPS_INITIALIZE (p_user_id,
                                     p_responsibility_id,
                                     p_respappl_id,
                                     0);
         p_contact_point_rec.contact_point_type := 'PHONE';
         p_contact_point_rec.owner_table_name := 'HZ_PARTY_SITES';
         p_contact_point_rec.owner_table_id := r.party_site_id;
         p_contact_point_rec.created_by_module := 'HZ_CPUI';
         p_phone_rec.phone_number := SUBSTR (r.contact_number, -11, 11);
         p_phone_rec.phone_line_type := 'GEN';

         hz_contact_point_v2pub.create_contact_point ('T',
                                                      p_contact_point_rec,
                                                      p_edi_rec_type,
                                                      p_email_rec_type,
                                                      p_phone_rec,
                                                      p_telex_rec_type,
                                                      p_web_rec_type,
                                                      x_contact_point_id,
                                                      x_return_status,
                                                      x_msg_count,
                                                      x_msg_data);
         COMMIT;

         DBMS_OUTPUT.put_line ('***************************');
         DBMS_OUTPUT.put_line ('Output information ....');
         DBMS_OUTPUT.put_line ('x_contact_point_id: ' || x_contact_point_id);
         DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);
         DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);
         DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);
         DBMS_OUTPUT.put_line ('***************************');
      END LOOP;

      RETURN x_contact_point_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION create_ship_to_site (p_cust_id               NUMBER,
                                 lp_cust_acct_site_id    NUMBER,
                                 lp_site_use_id          NUMBER)
      RETURN NUMBER
   IS
      CURSOR c
      IS
         SELECT *
           FROM xxdbl.xxdbl_cust_creation_tbl a
          WHERE a.cust_id = p_cust_id AND a.status IS NULL;

      p_cust_site_use_rec         hz_cust_account_site_v2pub.cust_site_use_rec_type;
      p_customer_profile_rec      hz_customer_profile_v2pub.customer_profile_rec_type;
      x_site_use_id               NUMBER;
      x_return_status             VARCHAR2 (2000);
      x_msg_count                 NUMBER;
      x_msg_data                  VARCHAR2 (2000);
      l_location_rec_type         hz_location_v2pub.location_rec_type;
      l_party_site_rec_type       hz_party_site_v2pub.party_site_rec_type;
      l_cust_acct_site_rec_type   hz_cust_account_site_v2pub.cust_acct_site_rec_type;
      l_cust_site_use_rec_type    hz_cust_account_site_v2pub.cust_site_use_rec_type;
      ln_location_id              NUMBER;
      gc_api_return_status        VARCHAR2 (100);
      gn_msg_count                NUMBER;
      gc_msg_data                 VARCHAR2 (4000);
      ln_site_use_id              NUMBER;
      ln_party_site_id            NUMBER;
      lc_party_site_number        VARCHAR (100);
      l_unit_name                 VARCHAR2 (100);
      lc_add_val_status           VARCHAR2 (4000);
      lc_addr_warn_msg            VARCHAR2 (4000);
      l_return_val                NUMBER;
   BEGIN
      FOR r IN c
      LOOP
         MO_GLOBAL.INIT ('AR');
         MO_GLOBAL.SET_POLICY_CONTEXT ('S', r.operating_unit);
         FND_GLOBAL.APPS_INITIALIZE (p_user_id,
                                     p_responsibility_id,
                                     p_respappl_id,
                                     0);

         -- CREATE CUSTOMER PARTY SITE
         COMMIT;

         l_cust_site_use_rec_type.LOCATION := r.location_id; --SUBSTR (r.address1, 1, 40);   --varchar2(40)
         l_cust_site_use_rec_type.created_by_module := 'HZ_CPUI';
         l_cust_site_use_rec_type.status := 'A';
         l_cust_site_use_rec_type.org_id := r.operating_unit;
         l_cust_site_use_rec_type.cust_acct_site_id := r.cust_acct_site_id;
         l_cust_site_use_rec_type.site_use_code := 'SHIP_TO';
         l_cust_site_use_rec_type.primary_salesrep_id := r.salesperson;
         l_cust_site_use_rec_type.territory_id := r.territory;
         l_cust_site_use_rec_type.demand_class_code := r.demand_class;
         l_cust_site_use_rec_type.bill_to_site_use_id := r.bill_site_use_id; --For Bill_To
         hz_cust_account_site_v2pub.create_cust_site_use (
            p_init_msg_list          => fnd_api.g_false,
            p_cust_site_use_rec      => l_cust_site_use_rec_type,
            p_customer_profile_rec   => NULL,
            p_create_profile         => fnd_api.g_true,
            p_create_profile_amt     => fnd_api.g_true,
            x_site_use_id            => ln_site_use_id,
            x_return_status          => gc_api_return_status,
            x_msg_count              => gn_msg_count,
            x_msg_data               => gc_msg_data);
         COMMIT;

         UPDATE xxdbl.xxdbl_cust_creation_tbl
            SET ship_site_use_id = ln_site_use_id
          WHERE cust_id = r.cust_id;

         COMMIT;
         DBMS_OUTPUT.put_line (
            'gc_api_return_status' || gc_api_return_status);
         DBMS_OUTPUT.put_line ('ln_site_use_id' || ln_site_use_id);



         FOR i IN 1 .. gn_msg_count
         LOOP
            x_msg_data := fnd_msg_pub.get (p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.put_line (i || ') ' || x_msg_data);
         END LOOP;

         COMMIT;
      END LOOP;

      RETURN ln_site_use_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION create_customer_site (p_cust_id NUMBER)
      RETURN NUMBER
   IS
      CURSOR c
      IS
         SELECT *
           FROM xxdbl.xxdbl_cust_creation_tbl a
          WHERE a.cust_id = p_cust_id AND a.status IS NULL;

      p_cust_site_use_rec         hz_cust_account_site_v2pub.cust_site_use_rec_type;
      p_customer_profile_rec      hz_customer_profile_v2pub.customer_profile_rec_type;
      p_create_profile_amt        HZ_CUSTOMER_PROFILE_V2PUB.cust_profile_amt_rec_type;
      x_site_use_id               NUMBER;
      x_return_status             VARCHAR2 (2000);
      x_msg_count                 NUMBER;
      x_msg_data                  VARCHAR2 (2000);
      l_customer_profile_rec      hz_customer_profile_v2pub.customer_profile_rec_type;
      l_create_profile_amt        HZ_CUSTOMER_PROFILE_V2PUB.cust_profile_amt_rec_type;
      l_location_rec_type         hz_location_v2pub.location_rec_type;
      l_party_site_rec_type       hz_party_site_v2pub.party_site_rec_type;
      l_cust_acct_site_rec_type   hz_cust_account_site_v2pub.cust_acct_site_rec_type;
      l_cust_site_use_rec_type    hz_cust_account_site_v2pub.cust_site_use_rec_type;
      ln_location_id              NUMBER;
      gc_api_return_status        VARCHAR2 (100);
      gn_msg_count                NUMBER;
      gc_msg_data                 VARCHAR2 (4000);
      ln_party_site_id            NUMBER;
      lc_party_site_number        VARCHAR (100);
      ln_cust_acct_site_id        NUMBER;
      ln_site_use_id              NUMBER;
      l_unit_name                 VARCHAR2 (100);
      lc_add_val_status           VARCHAR2 (4000);
      lc_addr_warn_msg            VARCHAR2 (4000);
      p_contact_point_rec         HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
      p_phone_rec                 HZ_CONTACT_POINT_V2PUB.phone_rec_type;
      p_edi_rec_type              HZ_CONTACT_POINT_V2PUB.edi_rec_type;
      p_email_rec_type            HZ_CONTACT_POINT_V2PUB.email_rec_type;
      p_telex_rec_type            HZ_CONTACT_POINT_V2PUB.telex_rec_type;
      p_web_rec_type              HZ_CONTACT_POINT_V2PUB.web_rec_type;

      x_contact_point_id          NUMBER;
      --x_return_status             VARCHAR2 (2000);
      --x_msg_count                 NUMBER;
      --x_msg_data                  VARCHAR2 (2000);
      l_return_val                NUMBER;
   BEGIN
      FOR r IN c
      LOOP
         MO_GLOBAL.INIT ('AR');
         MO_GLOBAL.SET_POLICY_CONTEXT ('S', r.operating_unit);
         FND_GLOBAL.APPS_INITIALIZE (p_user_id,
                                     p_responsibility_id,
                                     p_respappl_id,
                                     0);
         --CREATE CUSTOMER LOCATION
         l_location_rec_type.country := 'BD';
         l_location_rec_type.address1 := r.site_address1;
         l_location_rec_type.address2 := r.site_address2;
         l_location_rec_type.address3 := r.site_address3;
         --l_location_rec_type.address4 := r.site_address4;
         --l_location_rec_type.city := r.city;
         l_location_rec_type.postal_code := r.site_postal_code;
         --l_location_rec_type.state := r.state;
         --l_location_rec_type.county := r.country_name;
         l_location_rec_type.created_by_module := 'HZ_CPUI';
         l_location_rec_type.orig_system_reference := NULL;
         hz_location_v2pub.create_location (
            p_init_msg_list     => fnd_api.g_false,
            p_location_rec      => l_location_rec_type,
            p_do_addr_val       => NULL,
            x_location_id       => ln_location_id,
            x_addr_val_status   => lc_add_val_status,
            x_addr_warn_msg     => lc_addr_warn_msg,
            x_return_status     => gc_api_return_status,
            x_msg_count         => gn_msg_count,
            x_msg_data          => gc_msg_data);
         COMMIT;

         UPDATE xxdbl.xxdbl_cust_creation_tbl
            SET location_id = ln_location_id
          WHERE cust_id = r.cust_id;

         COMMIT;
         DBMS_OUTPUT.put_line ('ln_location_id-' || ln_location_id);


         -- CREATE CUSTOMER PARTY SITE
         l_party_site_rec_type.identifying_address_flag := 'Y';
         l_party_site_rec_type.created_by_module := 'HZ_CPUI';
         l_party_site_rec_type.party_id := r.party_id;
         l_party_site_rec_type.location_id := ln_location_id;
         l_party_site_rec_type.status := 'A';
         hz_party_site_v2pub.create_party_site (
            p_init_msg_list       => fnd_api.g_false,
            p_party_site_rec      => l_party_site_rec_type,
            x_party_site_id       => ln_party_site_id,
            x_party_site_number   => lc_party_site_number,
            x_return_status       => gc_api_return_status,
            x_msg_count           => gn_msg_count,
            x_msg_data            => gc_msg_data);
         COMMIT;

         UPDATE xxdbl.xxdbl_cust_creation_tbl
            SET party_site_id = ln_party_site_id
          WHERE cust_id = r.cust_id;

         COMMIT;
         DBMS_OUTPUT.put_line (
            'gc_api_return_status' || gc_api_return_status);
         COMMIT;

         l_return_val := create_site_contact (r.cust_id);
         COMMIT;
         -- CREATE CUSTOMER ACCT SITE
         DBMS_OUTPUT.put_line ('ln_party_site_id' || ln_party_site_id);
         l_cust_acct_site_rec_type.cust_account_id := r.cust_account_id;
         l_cust_acct_site_rec_type.party_site_id := ln_party_site_id;
         l_cust_acct_site_rec_type.created_by_module := 'HZ_CPUI';
         l_cust_acct_site_rec_type.orig_system_reference := NULL;
         --cv_address_data.site_orig_system_reference;
         l_cust_acct_site_rec_type.status := 'A';
         l_cust_acct_site_rec_type.org_id := r.operating_unit;
         l_cust_acct_site_rec_type.customer_category_code :=
            r.customer_category;
         hz_cust_account_site_v2pub.create_cust_acct_site (
            p_init_msg_list        => fnd_api.g_false,
            p_cust_acct_site_rec   => l_cust_acct_site_rec_type,
            x_cust_acct_site_id    => ln_cust_acct_site_id,
            x_return_status        => gc_api_return_status,
            x_msg_count            => gn_msg_count,
            x_msg_data             => gc_msg_data);
         COMMIT;

         UPDATE xxdbl.xxdbl_cust_creation_tbl
            SET cust_acct_site_id = ln_cust_acct_site_id
          WHERE cust_id = r.cust_id;

         COMMIT;
         DBMS_OUTPUT.put_line (
            'gc_api_return_status' || gc_api_return_status);
         l_cust_site_use_rec_type.LOCATION := r.location_id; --SUBSTR (r.address1, 1, 40);   --varchar2(40)
         l_cust_site_use_rec_type.created_by_module := 'HZ_CPUI';
         l_cust_site_use_rec_type.status := 'A';
         l_cust_site_use_rec_type.org_id := r.operating_unit;
         l_cust_site_use_rec_type.cust_acct_site_id := ln_cust_acct_site_id;
         l_cust_site_use_rec_type.site_use_code := 'BILL_TO';
         l_cust_site_use_rec_type.payment_term_id := r.payment_term;
         l_customer_profile_rec.credit_checking := 'Y';
         --l_create_profile_amt.currency_code := CASE WHEN r.operating_unit = 126 THEN 'BDT' ELSE 'USD' END;
         l_cust_site_use_rec_type.gl_id_rec := r.gl_id_rec;
         hz_cust_account_site_v2pub.create_cust_site_use (
            p_init_msg_list          => fnd_api.g_false,
            p_cust_site_use_rec      => l_cust_site_use_rec_type,
            p_customer_profile_rec   => l_customer_profile_rec,
            p_create_profile         => fnd_api.g_true,
            p_create_profile_amt     => fnd_api.g_true, --fnd_api.g_true, --l_create_profile_amt,
            x_site_use_id            => ln_site_use_id,
            x_return_status          => gc_api_return_status,
            x_msg_count              => gn_msg_count,
            x_msg_data               => gc_msg_data);
         COMMIT;

         UPDATE xxdbl.xxdbl_cust_creation_tbl
            SET bill_site_use_id = ln_site_use_id
          WHERE cust_id = r.cust_id;

         COMMIT;
         DBMS_OUTPUT.put_line (
            'gc_api_return_status' || gc_api_return_status);
         DBMS_OUTPUT.put_line ('ln_site_use_id' || ln_site_use_id);

         l_return_val :=
            create_ship_to_site (r.cust_id,
                                 ln_cust_acct_site_id,
                                 ln_site_use_id);
         COMMIT;

         FOR i IN 1 .. gn_msg_count
         LOOP
            x_msg_data := fnd_msg_pub.get (p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.put_line (i || ') ' || x_msg_data);
         END LOOP;

         COMMIT;
      END LOOP;

      RETURN p_cust_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;


   FUNCTION customer_creation_proc
      RETURN NUMBER
   IS
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
      l_create_profile_amt     HZ_CUSTOMER_PROFILE_V2PUB.cust_profile_amt_rec_type;
      x_cust_account_id        NUMBER;
      x_account_number         VARCHAR2 (2000);
      x_party_id               NUMBER;
      x_party_number           VARCHAR2 (2000);
      x_profile_id             NUMBER;
      x_return_status          VARCHAR2 (2000);
      x_msg_count              NUMBER;
      x_msg_data               VARCHAR2 (2000);
      l_profile_id             NUMBER;
      l_return_val             NUMBER;
   BEGIN
      FOR i IN c1
      LOOP
         BEGIN
            MO_GLOBAL.INIT ('AR');
            MO_GLOBAL.SET_POLICY_CONTEXT ('S', i.operating_unit);
            FND_GLOBAL.APPS_INITIALIZE (p_user_id,
                                        p_responsibility_id,
                                        p_respappl_id,
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
            --p_customer_profile_rec.standard_terms := i.payment_term;
            l_create_profile_amt.currency_code :=
               CASE WHEN i.operating_unit = 126 THEN 'BDT' ELSE 'USD' END;
            --p_customer_profile_rec.credit_checking := 'Y';


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
            COMMIT;

            UPDATE xxdbl.xxdbl_cust_creation_tbl
               SET party_id = x_party_id,
                   --cust_account_profile_id = x_profile_id,
                   cust_account_id = x_cust_account_id,
                   customer_number = x_account_number
             WHERE status IS NULL AND cust_id = i.cust_id;

            COMMIT;


            IF x_return_status = fnd_api.g_ret_sts_success
            THEN
               l_return_val := create_customer_site (i.cust_id);
               COMMIT;

               IF l_return_val IS NOT NULL
               THEN
                  l_return_val := create_cust_profile_amnt (i.cust_id);
                  COMMIT;

                  UPDATE xxdbl.xxdbl_cust_creation_tbl
                     SET status = 'Y'
                   WHERE status IS NULL AND cust_id = i.cust_id;

                  COMMIT;
               END IF;

               DBMS_OUTPUT.PUT_LINE (
                  'Creation of Party and customer account is Successful ');
               DBMS_OUTPUT.PUT_LINE ('Output information ....');
               DBMS_OUTPUT.PUT_LINE (
                  'x_cust_account_id  : ' || x_cust_account_id);
               DBMS_OUTPUT.PUT_LINE (
                  'x_account_number   : ' || x_account_number);
               DBMS_OUTPUT.PUT_LINE ('x_party_id         : ' || x_party_id);
               DBMS_OUTPUT.PUT_LINE (
                  'x_party_number     : ' || x_party_number);
               DBMS_OUTPUT.PUT_LINE ('x_profile_id       : ' || x_profile_id);
            ELSE
               DBMS_OUTPUT.put_line (
                     'Creation of Party and customer account failed:'
                  || x_msg_data);
               ROLLBACK;

               FOR i IN 1 .. x_msg_count
               LOOP
                  x_msg_data :=
                     oe_msg_pub.get (p_msg_index => i, p_encoded => 'F');
                  DBMS_OUTPUT.put_line (i || ') ' || x_msg_data);
               END LOOP;
            END IF;

            DBMS_OUTPUT.PUT_LINE ('Completion of API');
         END;
      END LOOP;

      COMMIT;
      RETURN 0;
   END;



   PROCEDURE upload_data_from_stg_tbl (ERRBUF    OUT VARCHAR2,
                                       RETCODE   OUT VARCHAR2)
   IS
      L_Retcode     NUMBER;
      CONC_STATUS   BOOLEAN;
      l_error       VARCHAR2 (100);
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Parameter received');


      L_Retcode := customer_creation_proc;

      IF L_Retcode = 0
      THEN
         RETCODE := 'Success';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL', 'Completed');
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
      ELSIF L_Retcode = 1
      THEN
         RETCODE := 'Warning';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('WARNING', 'Warning');
      ELSIF L_Retcode = 2
      THEN
         RETCODE := 'Error';
         CONC_STATUS :=
            FND_CONCURRENT.SET_COMPLETION_STATUS ('ERROR', 'Error');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error := 'error while executing the procedure ' || SQLERRM;
         errbuf := l_error;
         RETCODE := 1;
         fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
   END upload_data_from_stg_tbl;

   PROCEDURE import_data_from_web_adi (P_UNIT_NAME             VARCHAR2,
                                       P_CUSTOMER_NO           VARCHAR2,
                                       P_CUSTOMER_NAME         VARCHAR2,
                                       P_CUSTOMER_TYPE         VARCHAR2,
                                       P_CUSTOMER_CATEGORY     VARCHAR2,
                                       P_BIN_NUMBER            VARCHAR2,
                                       P_TIN_NUMBER            VARCHAR2,
                                       P_IRC_NUMBER            VARCHAR2,
                                       P_ERC_NUMBER            VARCHAR2,
                                       P_ADDRESS1              VARCHAR2,
                                       P_ADDRESS2              VARCHAR2,
                                       P_ADDRESS3              VARCHAR2,
                                       P_ADDRESS4              VARCHAR2,
                                       P_EMAIL_ADDRESS         VARCHAR2,
                                       P_GL_ACCOUNT            VARCHAR2,
                                       P_CREDIT_LIMIT          NUMBER,
                                       P_PAYMENT_TERM          VARCHAR2,
                                       P_POSTAL_CODE           VARCHAR2,
                                       P_CUST_SITE_CATEGORY    VARCHAR2,
                                       P_SITE_ADDRESS1         VARCHAR2,
                                       P_SITE_ADDRESS2         VARCHAR2,
                                       P_SITE_ADDRESS3         VARCHAR2,
                                       P_CONTACT_PERSON        VARCHAR2,
                                       P_CONTACT_NUMBER        VARCHAR2,
                                       P_COUNTRY               VARCHAR2,
                                       P_AREA                  VARCHAR2,
                                       P_ZONE                  VARCHAR2,
                                       P_DIVISION              VARCHAR2,
                                       P_SALESPERSON           VARCHAR2,
                                       P_SITE_POSTAL_CODE      VARCHAR2,
                                       P_DEMAND_CLASS          VARCHAR2)
   IS
      ---------------------Parameter-------------------

      l_operating_unit       NUMBER;
      p_attribute_category   VARCHAR2 (30 BYTE) := 'Additional Information';
      l_unit_name            VARCHAR2 (240 BYTE);
      l_customer_number      VARCHAR2 (240 BYTE);
      l_customer_category    VARCHAR2 (30 BYTE);
      l_salesperson          NUMBER;
      l_buyer                VARCHAR2 (30 BYTE);
      l_territory            NUMBER;
      l_demand_class         VARCHAR2 (30 BYTE);
      l_payment_term         VARCHAR2 (15 BYTE);
      l_gl_id_rec            NUMBER;
      --------------------------------------------

      l_error_message        VARCHAR2 (3000);
      l_error_code           VARCHAR2 (3000);
      ---------------------------------------------
      l_customer_id          NUMBER;
      l_customer_site_id     NUMBER;
      l_location_id          NUMBER;
      l_object_version_no    NUMBER;

      l_salesperson_name     VARCHAR2 (240);
      l_salesperson_id       VARCHAR2 (60);
      l_salesperson_conact   VARCHAR2 (60);
      l_bill_site_id         NUMBER;
      l_bill_site_use_id     NUMBER;
      l_cust_site_category   VARCHAR2 (30 BYTE);

      l_existing_loc         NUMBER;
      l_existing_address     VARCHAR2 (20);


      --------------------------------------------

      ERRBUF                 VARCHAR2 (1000);
      RETCODE                VARCHAR2 (1000);
      L_Retcode              NUMBER;
      CONC_STATUS            BOOLEAN;
      l_error                VARCHAR2 (100);
   ---------------------------------------------
   BEGIN
      --------------------------------------CUSTOMER CREATION-------------------
      --------------------------------------------------
      ----------Validate Oraganization------------------
      --------------------------------------------------
      BEGIN
         SELECT hou.organization_id, hou.name
           INTO l_operating_unit, l_unit_name
           FROM hr_organization_units hou
          WHERE hou.name = p_unit_name;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Unit Name.';
            l_error_code := 'E';
      END;


      --------------------------------------------------
      ----------Validate Territory-----------------
      --------------------------------------------------
      BEGIN
         SELECT territory_id
           INTO l_territory
           FROM ra_territories rt
          WHERE     segment1 = p_country
                AND segment2 = p_area
                AND segment3 = p_zone
                AND segment4 = p_division;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Territory combination.';
            l_error_code := 'E';
      END;


      --------------------------------------------------
      ----------Validate Demand Class-------------------
      --------------------------------------------------
      IF p_demand_class IS NOT NULL
      THEN
         BEGIN
            SELECT lookup_code
              INTO l_demand_class
              FROM fnd_lookup_values_vl flv
             WHERE     1 = 1
                   AND flv.lookup_type = 'DEMAND_CLASS'
                   AND enabled_flag = 'Y'
                   AND lookup_code = p_demand_class;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'Please enter correct Demand Class.';
               l_error_code := 'E';
         END;
      ELSE
         SELECT NULL
           INTO l_demand_class
           FROM DUAL;
      END IF;



      --------------------------------------------------
      ----------Validate Demand Class-------------------
      --------------------------------------------------
      BEGIN
         SELECT NVL (papf.employee_number, papf.npw_number),
                (   papf.first_name
                 || ' '
                 || papf.middle_names
                 || ' '
                 || papf.last_name),
                SUBSTR (pp.phone_number, -11, 11),
                sal.salesrep_id
           INTO l_salesperson_id,
                l_salesperson_name,
                l_salesperson_conact,
                l_salesperson
           FROM jtf_rs_salesreps sal,
                hr.per_all_people_f papf,
                jtf_rs_defresources_v rsv,
                per_phones pp
          WHERE     1 = 1
                AND sal.person_id = papf.person_id
                AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                                        AND TRUNC (papf.effective_end_date)
                AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
                AND NVL (papf.employee_number, papf.npw_number) =
                       P_SALESPERSON
                AND sal.org_id = l_operating_unit
                AND sal.resource_id = rsv.resource_id
                AND rsv.source_id = pp.parent_id(+)
                AND pp.phone_type(+) = 'W1';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Employee for Sales Person.';
            l_error_code := 'E';
      END;


      --------------------------------------------------
      ----------Validate Payment Terms-------------------
      --------------------------------------------------
      BEGIN
         SELECT rt.term_id
           INTO l_payment_term
           FROM ra_terms rt
          WHERE rt.name = P_PAYMENT_TERM;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Payment Terms.';
            l_error_code := 'E';
      END;

      --------------------------------------------------
      ----------Validate GL Code-------------------
      --------------------------------------------------
      BEGIN
         SELECT code_combination_id
           INTO l_gl_id_rec
           FROM apps.gl_code_combinations_kfv gcc
          WHERE gcc.concatenated_segments = p_gl_account;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct GL Code.';
            l_error_code := 'E';
      END;


      --------------------------------------------------
      ----------Validate Customer Category-------------------
      --------------------------------------------------
      BEGIN
         SELECT LOOKUP_CODE
           INTO l_customer_category
           FROM FND_LOOKUP_VALUES_VL FLV
          WHERE     FLV.LOOKUP_TYPE = 'CUSTOMER_CATEGORY'
                AND ENABLED_FLAG = 'Y'
                AND FLV.LOOKUP_CODE = UPPER (p_customer_category);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Customer category.';
            l_error_code := 'E';
      END;

      /*
      --------------------------------------------------
      ----------Validate SALES CHANNEL-------------------
      --------------------------------------------------
      BEGIN
         SELECT LOOKUP_CODE
           INTO l_buyer
           FROM FND_LOOKUP_VALUES_VL FLV
          WHERE     FLV.LOOKUP_TYPE = 'SALES_CHANNEL'
                AND ENABLED_FLAG = 'Y'
                AND FLV.LOOKUP_CODE = UPPER ('MWW');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
               l_error_message || ',' || 'Please enter correct Buyer.';
            l_error_code := 'E';
      END;
      */
      --------------------------------------------------
      ----------Validate Customer Category-------------------
      --------------------------------------------------
      BEGIN
         SELECT LOOKUP_CODE
           INTO l_customer_category
           FROM FND_LOOKUP_VALUES_VL FLV
          WHERE     FLV.LOOKUP_TYPE = 'CUSTOMER_CATEGORY'
                AND ENABLED_FLAG = 'Y'
                AND FLV.LOOKUP_CODE = UPPER (p_cust_site_category);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_error_message :=
                  l_error_message
               || ','
               || 'Please enter correct Customer category.';
            l_error_code := 'E';
      END;

      --check existing customer validation for new site creation

      IF p_customer_no IS NOT NULL
      THEN
         --------------------------------------------------
         ----------Validate Existing Customer-----------------
         --------------------------------------------------

         BEGIN
            SELECT hou.organization_id,
                   hou.name,
                   ca.cust_account_id,
                   casa.cust_acct_site_id,
                   csua.site_use_id
              INTO l_operating_unit,
                   l_unit_name,
                   l_customer_id,
                   l_bill_site_id,
                   l_bill_site_use_id
              FROM apps.hz_cust_accounts ca,
                   apps.hz_cust_site_uses_all csua,
                   apps.hz_cust_acct_sites_all casa,
                   apps.hr_operating_units hou,
                   apps.hz_parties hp,
                   apps.hz_party_sites hps,
                   apps.hz_locations loc
             WHERE     1 = 1
                   AND csua.cust_acct_site_id = casa.cust_acct_site_id
                   AND ca.cust_account_id = casa.cust_account_id
                   AND hou.organization_id = casa.org_id
                   AND CA.STATUS = 'A'
                   AND CSUA.STATUS = 'A'
                   AND hp.party_id = ca.party_id
                   AND hps.party_id = hp.party_id
                   AND hps.location_id = loc.location_id
                   AND HP.STATUS = 'A'
                   AND HPS.STATUS = 'A'
                   AND HPS.IDENTIFYING_ADDRESS_FLAG = 'Y'
                   AND SITE_USE_CODE = 'BILL_TO'
                   AND hou.name = p_unit_name
                   AND ca.account_number = p_customer_no;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'This Customer-'
                  || p_customer_no
                  || ' does not exist in System. At first, please create a customer.';
               l_error_code := 'E';
         END;

         --------------------------------------------------------
         ----------Validate Existing Retailer Name / Address1----
         --------------------------------------------------------
         BEGIN
            BEGIN
               SELECT NVL (COUNT (*), 0)
                 INTO l_existing_loc
                 FROM apps.hz_cust_accounts ca,
                      apps.hz_cust_site_uses_all csua,
                      apps.hz_cust_acct_sites_all casa,
                      apps.hr_operating_units hou,
                      apps.hz_parties hp,
                      apps.hz_party_sites hps,
                      apps.hz_locations loc
                WHERE     1 = 1
                      AND csua.cust_acct_site_id = casa.cust_acct_site_id
                      AND ca.cust_account_id = casa.cust_account_id
                      AND hou.organization_id = casa.org_id
                      AND CA.STATUS = 'A'
                      AND CSUA.STATUS = 'A'
                      AND hp.party_id = ca.party_id
                      AND hps.party_id = hp.party_id
                      AND hps.location_id = loc.location_id
                      AND HP.STATUS = 'A'
                      AND HPS.STATUS = 'A'
                      AND HPS.IDENTIFYING_ADDRESS_FLAG = 'Y'
                      AND SITE_USE_CODE IN ('BILL_TO', 'SHIP_TO')
                      AND hou.name = p_unit_name
                      AND ca.account_number = p_customer_no
                      AND UPPER (loc.address1) = UPPER (p_site_address1);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  l_existing_loc := '0';
            END;

            IF (l_existing_loc <> 0)
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'Retailer Name / Address1  is exists for : '
                  || l_existing_address
                  || '.';
               l_error_code := 'E';
            END IF;
         END;


         --------------------------------------------------
         ----------Validate Sales Person-------------------
         --------------------------------------------------

         /*
         BEGIN
            SELECT NVL (papf.employee_number, papf.npw_number),
                   (   papf.first_name
                    || ' '
                    || papf.middle_names
                    || ' '
                    || papf.last_name),
                   SUBSTR (pp.phone_number, -11, 11),
                   sal.salesrep_id
              INTO l_salesperson_id,
                   l_salesperson_name,
                   l_salesperson_conact,
                   l_salesperson
              FROM jtf_rs_salesreps sal,
                   hr.per_all_people_f papf,
                   jtf_rs_defresources_v rsv,
                   per_phones pp
             WHERE     1 = 1
                   AND sal.person_id = papf.person_id
                   AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                  papf.effective_start_date)
                                           AND TRUNC (
                                                  papf.effective_end_date)
                   AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
                   AND NVL (papf.employee_number, papf.npw_number) =
                          p_salesperson_id
                   AND sal.org_id = l_operating_unit
                   AND sal.resource_id = rsv.resource_id
                   AND rsv.source_id = pp.parent_id(+)
                   AND pp.phone_type(+) = 'W1';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'Please enter correct Employee for Sales Person.';
               l_error_code := 'E';
         END;
         */



         /*
         --------------------------------------------------
         ----------Validate Territory-----------------
         --------------------------------------------------
         BEGIN
            SELECT territory_id
              INTO l_territory
              FROM ra_territories rt
             WHERE     segment1 = p_country
                   AND segment2 = p_area
                   AND segment3 = p_zone
                   AND segment4 = p_division;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'Please enter correct Territory combination.';
               l_error_code := 'E';
         END;
         */


         --------------------------------------------------
         ----------Validate Demand Class-------------------
         --------------------------------------------------
         /*
         IF p_demand_class IS NOT NULL
         THEN
            BEGIN
               SELECT lookup_code
                 INTO l_demand_class
                 FROM fnd_lookup_values_vl flv
                WHERE     1 = 1
                      AND flv.lookup_type = 'DEMAND_CLASS'
                      AND enabled_flag = 'Y'
                      AND lookup_code = p_demand_class;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  l_error_message :=
                        l_error_message
                     || ','
                     || 'Please enter correct Demand Class.';
                  l_error_code := 'E';
            END;
         ELSE
            SELECT NULL
              INTO l_demand_class
              FROM DUAL;
         END IF;
         */

         --------------------------------------------------
         ----------Validate Customer Category-------------------
         --------------------------------------------------
         BEGIN
            SELECT LOOKUP_CODE
              INTO l_cust_site_category
              FROM FND_LOOKUP_VALUES_VL FLV
             WHERE     FLV.LOOKUP_TYPE = 'CUSTOMER_CATEGORY'
                   AND ENABLED_FLAG = 'Y'
                   AND FLV.LOOKUP_CODE = UPPER (p_cust_site_category);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_error_message :=
                     l_error_message
                  || ','
                  || 'Please enter correct Customer category.';
               l_error_code := 'E';
         END;
      END IF;


      --------------------------------------------------------------------------------------------------------------
      --------Condition to show error if any of the above validation picks up a data entry error--------------------
      --------Condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------



      IF l_error_code = 'E'
      THEN
         raise_application_error (-20101, l_error_message);
      ELSIF NVL (l_error_code, 'A') <> 'E'
      THEN
         INSERT INTO xxdbl.xxdbl_cust_creation_tbl (cust_id,
                                                    creation_date,
                                                    created_by,
                                                    login_id,
                                                    unit_name,
                                                    operating_unit,
                                                    customer_name,
                                                    customer_type,
                                                    customer_category,
                                                    attribute_category,
                                                    attribute1,
                                                    attribute2,
                                                    attribute3,
                                                    attribute4,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    postal_code,
                                                    payment_term,
                                                    demand_class,
                                                    territory,
                                                    salesperson,
                                                    buyer,
                                                    gl_id_rec,
                                                    credit_limit,
                                                    email_address,
                                                    customer_number,
                                                    bill_site_id,
                                                    bill_site_use_id,
                                                    new_location_id,
                                                    site_address1,
                                                    site_address2,
                                                    site_address3,
                                                    contact_person,
                                                    contact_number,
                                                    salesperson_name,
                                                    salesperson_id,
                                                    salesperson_conact,
                                                    site_postal_code,
                                                    customer_site_category)
                 VALUES (
                           TRIM (
                              LPAD (xxdbl_customer_creation_s.NEXTVAL,
                                    7,
                                    '0')),
                           SYSDATE,
                           p_user_id,
                           p_login_id,
                           l_unit_name,
                           l_operating_unit,
                           p_customer_name,
                           NVL (p_customer_type, 'R'),
                           l_customer_category,
                           p_attribute_category,
                           P_BIN_NUMBER,
                           P_TIN_NUMBER,
                           P_IRC_NUMBER,
                           P_ERC_NUMBER,
                           p_address1,
                           p_address2,
                           p_address3,
                           p_address4,
                           p_postal_code,
                           l_payment_term,
                           l_demand_class,
                           l_territory,
                           l_salesperson,
                           l_buyer,
                           l_gl_id_rec,
                           p_credit_limit,
                           p_email_address,
                           ---------------
                           p_customer_no,
                           l_bill_site_id,
                           l_bill_site_use_id,
                           NVL (l_location_id, 0),
                           p_site_address1,
                              p_contact_person
                           || DECODE (p_site_address2, NULL, '', ',')
                           || p_site_address2,
                           p_site_address3,
                           p_contact_person,
                           p_contact_number,
                           l_salesperson_name,
                           l_salesperson_id,
                           l_salesperson_conact,
                           p_site_postal_code,
                           l_cust_site_category);

         COMMIT;
      END IF;
   END import_data_from_web_adi;
END xxdbl_cust_creation_pkg;
/