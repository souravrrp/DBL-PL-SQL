/* Formatted on 3/29/2021 5:35:51 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_cust_upd_webadi_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 10-MAR-2021
   -- LAST UPDATE DATE :10-MAR-2021
   -- PURPOSE : CUSTOMER UPDATE WEB ADI
   FUNCTION create_customer_site (p_cust_id NUMBER)
      RETURN NUMBER
   IS
      CURSOR c
      IS
         SELECT *
           FROM xxdbl.xxdbl_cust_update_stg_tbl a
          WHERE a.cust_upd_id = p_cust_id AND a.status IS NULL;

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
         FND_GLOBAL.APPS_INITIALIZE (p_user_id,
                                     p_responsibility_id,
                                     p_respappl_id,
                                     0);
         --CREATE CUSTOMER LOCATION
         l_location_rec_type.country := 'BD';
         l_location_rec_type.address1 := r.new_address;
         --l_location_rec_type.address2 := r.address2;
         --l_location_rec_type.address3 := r.address3;
         --l_location_rec_type.address4 := r.address4;
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
                   AND b.cust_account_id = r.customer_id;
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
         DBMS_OUTPUT.put_line (
            'gc_api_return_status' || gc_api_return_status);
         COMMIT;
         -- CREATE CUSTOMER ACCT SITE
         DBMS_OUTPUT.put_line ('ln_party_site_id' || ln_party_site_id);
         l_cust_acct_site_rec_type.cust_account_id := r.customer_id;
         l_cust_acct_site_rec_type.party_site_id := ln_party_site_id;
         l_cust_acct_site_rec_type.created_by_module := 'HZ_CPUI';
         l_cust_acct_site_rec_type.orig_system_reference := NULL;
         --cv_address_data.site_orig_system_reference;
         l_cust_acct_site_rec_type.status := 'A';
         l_cust_acct_site_rec_type.org_id := r.operating_unit;
         hz_cust_account_site_v2pub.create_cust_acct_site (
            p_init_msg_list        => fnd_api.g_false,
            p_cust_acct_site_rec   => l_cust_acct_site_rec_type,
            x_cust_acct_site_id    => ln_cust_acct_site_id,
            x_return_status        => gc_api_return_status,
            x_msg_count            => gn_msg_count,
            x_msg_data             => gc_msg_data);
         COMMIT;
         DBMS_OUTPUT.put_line (
            'gc_api_return_status' || gc_api_return_status);

         l_cust_site_use_rec_type.LOCATION := SUBSTR (r.new_address, 1, 40);
         l_cust_site_use_rec_type.created_by_module := 'HZ_CPUI';
         l_cust_site_use_rec_type.status := 'A';
         l_cust_site_use_rec_type.org_id := r.operating_unit;
         --l_cust_site_use_rec_type.primary_salesrep_id := r.sales_rep_id;
         l_cust_site_use_rec_type.cust_acct_site_id := ln_cust_acct_site_id;
         l_cust_site_use_rec_type.site_use_code := 'SHIP_TO';
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
         DBMS_OUTPUT.put_line (
            'gc_api_return_status' || gc_api_return_status);
         DBMS_OUTPUT.put_line ('ln_site_use_id' || ln_site_use_id);

         FOR i IN 1 .. gn_msg_count
         LOOP
            x_msg_data := fnd_msg_pub.get (p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.put_line (i || ') ' || x_msg_data);
         END LOOP;

         COMMIT;

         UPDATE xxdbl.xxdbl_cust_update_stg_tbl
            SET status = 'Y'
          WHERE status IS NULL AND cust_upd_id = p_cust_id;

         COMMIT;
      END LOOP;

      RETURN p_cust_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;


   FUNCTION update_customer_site (p_cust_upd_id NUMBER)
      RETURN NUMBER
   IS
      CURSOR c
      IS
         SELECT *
           FROM xxdbl.xxdbl_cust_update_stg_tbl a
          WHERE a.cust_upd_id = p_cust_upd_id AND a.status IS NULL;

      p_location_rec    HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
      x_return_status   VARCHAR2 (2000);
      x_msg_count       NUMBER;
      x_msg_data        VARCHAR2 (2000);
      x_ver_number      NUMBER;
   BEGIN
      FOR r IN c
      LOOP
         p_location_rec.location_id := r.location_id;
         p_location_rec.address1 := r.new_address;
         x_ver_number := r.location_version;

         hz_location_v2pub.update_location ('T',
                                            p_location_rec,
                                            x_ver_number,
                                            x_return_status,
                                            x_msg_count,
                                            x_msg_data);

         DBMS_OUTPUT.put_line ('***************************');
         DBMS_OUTPUT.put_line ('Output information ....');
         DBMS_OUTPUT.put_line ('x_p_version: ' || x_ver_number);
         DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);
         DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);
         DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);
         DBMS_OUTPUT.put_line ('***************************');
         COMMIT;

         UPDATE xxdbl.xxdbl_cust_update_stg_tbl
            SET status = 'Y'
          WHERE status IS NULL AND cust_upd_id = p_cust_upd_id;

         COMMIT;
      END LOOP;


      RETURN p_cust_upd_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;



   PROCEDURE import_data_from_web_adi (p_unit_name           VARCHAR2,
                                       p_customer_no         VARCHAR2,
                                       p_existing_address    VARCHAR2,
                                       p_new_address         VARCHAR2,
                                       p_postal_code         VARCHAR2)
   IS
      ---------------------Parameter-------------------

      l_operating_unit      NUMBER;
      l_unit_name           VARCHAR2 (240 BYTE);
      l_customer_id         NUMBER;
      l_customer_site_id    NUMBER;
      l_location_id         NUMBER;
      l_object_version_no   NUMBER;
      --------------------------------------------

      l_error_message       VARCHAR2 (3000);
      l_error_code          VARCHAR2 (3000);


      --------------------------------------------

      ERRBUF                VARCHAR2 (1000);
      RETCODE               VARCHAR2 (1000);
      L_Retcode             NUMBER;
      CONC_STATUS           BOOLEAN;
      l_error               VARCHAR2 (100);
   ---------------------------------------------
   BEGIN
      --------------------------------------------------
      ----------Validate Existing Customer-----------------
      --------------------------------------------------

      BEGIN
         IF p_existing_address IS NOT NULL
         THEN
            SELECT hou.organization_id,
                   hou.name,
                   ca.cust_account_id,
                   casa.cust_acct_site_id,
                   loc.location_id,
                   loc.object_version_number
              INTO l_operating_unit,
                   l_unit_name,
                   l_customer_id,
                   l_customer_site_id,
                   l_location_id,
                   l_object_version_no
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
                   AND SITE_USE_CODE = 'SHIP_TO'
                   AND hou.name = p_unit_name
                   AND ca.account_number = p_customer_no
                   AND UPPER (loc.address1) = UPPER (p_existing_address);
         ELSE
            BEGIN
               SELECT hou.organization_id, hou.name
                 INTO l_operating_unit, l_unit_name
                 FROM hr_organization_units hou
                WHERE hou.name = p_unit_name;
            END;

            BEGIN
               SELECT hca.cust_account_id
                 INTO l_customer_id
                 FROM hz_cust_accounts hca
                WHERE hca.account_number = p_customer_no AND hca.status = 'A';
            END;
         END IF;
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



      --------------------------------------------------------------------------------------------------------------
      --------Condition to show error if any of the above validation picks up a data entry error--------------------
      --------Condition to insert data into custom staging table if the data passes all above validations-----------
      --------------------------------------------------------------------------------------------------------------



      IF l_error_code = 'E'
      THEN
         raise_application_error (-20101, l_error_message);
      ELSIF NVL (l_error_code, 'A') <> 'E'
      THEN
         INSERT INTO xxdbl.xxdbl_cust_update_stg_tbl (cust_upd_id,
                                                      creation_date,
                                                      created_by,
                                                      unit_name,
                                                      operating_unit,
                                                      customer_id,
                                                      customer_number,
                                                      cust_site_id,
                                                      location_id,
                                                      location_address,
                                                      location_version,
                                                      new_location_id,
                                                      new_address,
                                                      postal_code)
                 VALUES (
                           TRIM (
                              LPAD (xxdbl.xxdbl_cust_update_s.NEXTVAL,
                                    7,
                                    '0')),
                           SYSDATE,
                           p_user_id,
                           l_unit_name,
                           l_operating_unit,
                           l_customer_id,
                           p_customer_no,
                           NVL (l_customer_site_id, 0),
                           NVL (l_location_id, 0),
                           p_existing_address,
                           NVL (l_object_version_no, 0),
                           NVL (l_location_id, 0),
                           p_new_address,
                           p_postal_code);

         COMMIT;

         BEGIN
            fnd_file.put_line (fnd_file.LOG, 'Parameter received');

            IF p_existing_address IS NULL
            THEN
               L_Retcode :=
                  create_customer_site (
                     TRIM (LPAD (xxdbl_cust_update_s.CURRVAL, 7, '0')));
            ELSE
               L_Retcode :=
                  update_customer_site (
                     TRIM (LPAD (xxdbl_cust_update_s.CURRVAL, 7, '0')));
            END IF;

            IF L_Retcode = 0
            THEN
               RETCODE := 'Success';
               CONC_STATUS :=
                  FND_CONCURRENT.SET_COMPLETION_STATUS ('NORMAL',
                                                        'Completed');
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
         END;
      END IF;
   END import_data_from_web_adi;
END xxdbl_cust_upd_webadi_pkg;
/