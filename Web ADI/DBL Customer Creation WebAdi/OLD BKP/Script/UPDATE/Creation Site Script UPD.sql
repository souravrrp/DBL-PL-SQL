/* Formatted on 4/10/2021 3:46:53 PM (QP5 v5.287) */
DECLARE
   p_cust_id                   NUMBER := '1000042';
   p_cust_account_id           NUMBER := '232438';
   L_Retcode                   NUMBER;
   CONC_STATUS                 BOOLEAN;
   l_error                     VARCHAR2 (100);

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
   ln_party_site_id            NUMBER;
   lc_party_site_number        VARCHAR (100);
   ln_cust_acct_site_id        NUMBER;
   ln_site_use_id              NUMBER;
   l_unit_name                 VARCHAR2 (100);
   lc_add_val_status           VARCHAR2 (4000);
   lc_addr_warn_msg            VARCHAR2 (4000);
BEGIN
   FOR r IN c
   LOOP
      MO_GLOBAL.INIT ('AR');
      MO_GLOBAL.SET_POLICY_CONTEXT ('S', r.operating_unit);
      FND_GLOBAL.APPS_INITIALIZE (5958,
                                  20678,
                                  222,
                                  0);
      --CREATE CUSTOMER LOCATION
      l_location_rec_type.country := 'BD';
      l_location_rec_type.address1 := r.address1;
      l_location_rec_type.address2 := r.address2;
      l_location_rec_type.address3 := r.address3;
      l_location_rec_type.address4 := r.address4;
      --l_location_rec_type.city := r.city;
      l_location_rec_type.postal_code := r.postal_code;
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
      -- CREATE CUSTOMER PARTY SITE
      COMMIT;
      DBMS_OUTPUT.put_line ('ln_location_id-' || ln_location_id);

      BEGIN
         SELECT a.party_id
           INTO l_party_site_rec_type.party_id
           FROM hz_parties a, hz_cust_accounts b
          WHERE     a.party_id = b.party_id
                AND b.cust_account_id = p_cust_account_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_party_site_rec_type.party_id := NULL;
      END;

      l_party_site_rec_type.identifying_address_flag := 'Y';
      l_party_site_rec_type.created_by_module := 'HZ_CPUI';

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
      DBMS_OUTPUT.put_line ('gc_api_return_status' || gc_api_return_status);
      COMMIT;
      -- CREATE CUSTOMER ACCT SITE
      DBMS_OUTPUT.put_line ('ln_party_site_id' || ln_party_site_id);
      l_cust_acct_site_rec_type.cust_account_id := p_cust_account_id;
      l_cust_acct_site_rec_type.party_site_id := ln_party_site_id;
      l_cust_acct_site_rec_type.created_by_module := 'HZ_CPUI';
      l_cust_acct_site_rec_type.orig_system_reference := NULL;
      --cv_address_data.site_orig_system_reference;
      l_cust_acct_site_rec_type.status := 'A';
      l_cust_acct_site_rec_type.org_id := r.operating_unit;
      l_cust_acct_site_rec_type.customer_category_code := r.customer_category;
      hz_cust_account_site_v2pub.create_cust_acct_site (
         p_init_msg_list        => fnd_api.g_false,
         p_cust_acct_site_rec   => l_cust_acct_site_rec_type,
         x_cust_acct_site_id    => ln_cust_acct_site_id,
         x_return_status        => gc_api_return_status,
         x_msg_count            => gn_msg_count,
         x_msg_data             => gc_msg_data);
      COMMIT;
      DBMS_OUTPUT.put_line ('gc_api_return_status' || gc_api_return_status);
      l_cust_site_use_rec_type.LOCATION := r.address2; --SUBSTR (r.address1, 1, 40);   --varchar2(40)
      l_cust_site_use_rec_type.created_by_module := 'HZ_CPUI';
      l_cust_site_use_rec_type.status := 'A';
      l_cust_site_use_rec_type.org_id := r.operating_unit;
      --l_cust_site_use_rec_type.primary_salesrep_id := r.sales_rep_id;
      l_cust_site_use_rec_type.cust_acct_site_id := ln_cust_acct_site_id;
      l_cust_site_use_rec_type.gl_id_rec := 264532;
      l_cust_site_use_rec_type.site_use_code := 'BILL_TO';
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
      DBMS_OUTPUT.put_line ('gc_api_return_status' || gc_api_return_status);
      DBMS_OUTPUT.put_line ('ln_site_use_id' || ln_site_use_id);


      l_cust_site_use_rec_type.LOCATION := r.address2; --SUBSTR (r.address1, 1, 40);   --varchar2(40)
      l_cust_site_use_rec_type.created_by_module := 'HZ_CPUI';
      l_cust_site_use_rec_type.status := 'A';
      l_cust_site_use_rec_type.org_id := r.operating_unit;
      l_cust_site_use_rec_type.cust_acct_site_id := ln_cust_acct_site_id;
      l_cust_site_use_rec_type.site_use_code := 'SHIP_TO';
      l_cust_site_use_rec_type.primary_salesrep_id := r.salesperson;
      l_cust_site_use_rec_type.territory_id := r.territory;
      l_cust_site_use_rec_type.demand_class_code := r.demand_class;
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
      DBMS_OUTPUT.put_line ('gc_api_return_status' || gc_api_return_status);
      DBMS_OUTPUT.put_line ('ln_site_use_id' || ln_site_use_id);

      FOR i IN 1 .. gn_msg_count
      LOOP
         x_msg_data := fnd_msg_pub.get (p_msg_index => i, p_encoded => 'F');
         DBMS_OUTPUT.put_line (i || ') ' || x_msg_data);
      END LOOP;

      COMMIT;
   END LOOP;
--RETURN p_cust_id;
--EXCEPTION
--   WHEN OTHERS
--   THEN
--      l_error := 'error while executing the procedure ' || SQLERRM;
--      fnd_file.put_line (fnd_file.LOG, 'Status :' || L_Retcode);
END;