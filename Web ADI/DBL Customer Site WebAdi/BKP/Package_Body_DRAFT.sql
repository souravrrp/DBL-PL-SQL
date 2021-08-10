/* Formatted on 5/30/2021 3:37:57 PM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_cust_site_webadi_pkg
IS
   -- CREATED BY : SOURAV PAUL
   -- CREATION DATE : 10-MAR-2021
   -- LAST UPDATE DATE :10-MAR-2021
   -- PURPOSE : CUSTOMER UPDATE WEB ADI

   FUNCTION create_customer_site_contact (p_cust_id         NUMBER,
                                          p_part_site_id    NUMBER)
      RETURN NUMBER
   IS
      CURSOR c
      IS
         SELECT *
           FROM xxdbl.xxdbl_cust_site_stg_tbl a
          WHERE a.cust_site_id = p_cust_id;

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
   BEGIN
      FOR r IN c
      LOOP
         mo_global.init ('AR');
         MO_GLOBAL.SET_POLICY_CONTEXT ('S', r.operating_unit);
         FND_GLOBAL.APPS_INITIALIZE (p_user_id,
                                     p_responsibility_id,
                                     p_respappl_id,
                                     0);
         --mo_global.set_policy_context ('S', 126);
         --fnd_global.apps_initialize (5958, 20678, 222,0);
         p_contact_point_rec.contact_point_type := 'PHONE';
         p_contact_point_rec.owner_table_name := 'HZ_PARTY_SITES';
         p_contact_point_rec.owner_table_id := p_part_site_id;
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

      RETURN p_cust_id;
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
           FROM xxdbl.xxdbl_cust_site_stg_tbl a
          WHERE a.cust_site_id = p_cust_id AND a.status IS NULL;

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
      l_return_val                NUMBER;
      ln_req_id                   NUMBER;
      lv_req_phase                VARCHAR2 (240);
      lv_req_status               VARCHAR2 (240);
      lv_req_dev_phase            VARCHAR2 (240);
      lv_req_dev_status           VARCHAR2 (240);
      lv_req_message              VARCHAR2 (240);
      lv_req_return_status        BOOLEAN;
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
         l_location_rec_type.address1 := r.address1;
         l_location_rec_type.address2 := r.address2;
         l_location_rec_type.address3 := r.address3;
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
         l_cust_acct_site_rec_type.customer_category_code := 'RETAILER';
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

         l_cust_site_use_rec_type.LOCATION := ln_location_id; --SUBSTR (r.address1, 1, 40);
         l_cust_site_use_rec_type.created_by_module := 'HZ_CPUI';
         l_cust_site_use_rec_type.status := 'A';
         l_cust_site_use_rec_type.org_id := r.operating_unit;
         l_cust_site_use_rec_type.cust_acct_site_id := ln_cust_acct_site_id;
         l_cust_site_use_rec_type.site_use_code := 'SHIP_TO';
         l_cust_site_use_rec_type.primary_salesrep_id := r.salesperson;
         l_cust_site_use_rec_type.territory_id := r.territory;
         l_cust_site_use_rec_type.demand_class_code :=
            CASE
               WHEN r.operating_unit = 125 THEN r.demand_class
               ELSE NULL
            END;
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
         DBMS_OUTPUT.put_line (
            'gc_api_return_status' || gc_api_return_status);
         DBMS_OUTPUT.put_line ('ln_site_use_id' || ln_site_use_id);

         FOR i IN 1 .. gn_msg_count
         LOOP
            x_msg_data := fnd_msg_pub.get (p_msg_index => i, p_encoded => 'F');
            DBMS_OUTPUT.put_line (i || ') ' || x_msg_data);
         END LOOP;

         BEGIN
            SELECT fcrs.request_id
              INTO ln_req_id
              FROM fnd_conc_req_summary_v fcrs, apps.fnd_user fu
             WHERE     fcrs.requestor = fu.user_name
                   AND fu.user_id = p_user_id
                   AND fcrs.program_short_name = 'ARHDQMSS'
                   AND fcrs.phase_code IN ('P', 'R');

            IF ln_req_id > 0
            THEN
               LOOP
                  lv_req_return_status :=
                     fnd_concurrent.wait_for_request (ln_req_id,
                                                      60,
                                                      0,
                                                      lv_req_phase,
                                                      lv_req_status,
                                                      lv_req_dev_phase,
                                                      lv_req_dev_status,
                                                      lv_req_message);
                  EXIT WHEN    UPPER (lv_req_phase) = 'COMPLETED'
                            OR UPPER (lv_req_status) IN
                                  ('CANCELLED', 'ERROR', 'TERMINATED');
               END LOOP;

               DBMS_OUTPUT.PUT_LINE ('Request Phase  : ' || lv_req_dev_phase);
               DBMS_OUTPUT.PUT_LINE (
                  'Request Status : ' || lv_req_dev_status);
               DBMS_OUTPUT.PUT_LINE ('Request id     : ' || ln_req_id);
               Fnd_File.PUT_LINE (
                  Fnd_File.LOG,
                     'The Customer Site Program Completion Phase: '
                  || lv_req_dev_phase);
               Fnd_File.PUT_LINE (
                  Fnd_File.LOG,
                     'The Customer Site Program Completion Status: '
                  || lv_req_dev_status);

               CASE
                  WHEN     UPPER (lv_req_phase) = 'COMPLETED'
                       AND UPPER (lv_req_status) = 'ERROR'
                  THEN
                     fnd_file.put_line (
                        fnd_file.LOG,
                        'The Customer Site prog completed in error. See log for request id');
                     fnd_file.put_line (fnd_file.LOG, SQLERRM);
                  WHEN    (    UPPER (lv_req_phase) = 'COMPLETED'
                           AND UPPER (lv_req_status) = 'NORMAL')
                       OR (    UPPER (lv_req_phase) = 'COMPLETED'
                           AND UPPER (lv_req_status) = 'WARNING')
                  THEN
                     BEGIN
                        l_return_val :=
                           create_customer_site_contact (p_cust_id,
                                                         ln_party_site_id);
                        Fnd_File.PUT_LINE (
                           Fnd_File.LOG,
                              'The contact successfully Assigned to the respected Customer site for request id: '
                           || ln_req_id);
                     END;

                     Fnd_File.PUT_LINE (
                        Fnd_File.LOG,
                           'The Customer Site successfully completed for request id: '
                        || ln_req_id);
                  ELSE
                     Fnd_File.PUT_LINE (
                        Fnd_File.LOG,
                        'The Customer Site request failed.Review log for Oracle request id ');
                     Fnd_File.PUT_LINE (Fnd_File.LOG, SQLERRM);
               END CASE;
            END IF;
         END;

         COMMIT;

         UPDATE xxdbl.xxdbl_cust_site_stg_tbl
            SET status = 'Y'
          WHERE status IS NULL AND cust_site_id = p_cust_id;

         COMMIT;
      END LOOP;

      RETURN p_cust_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   PROCEDURE import_data_from_web_adi (p_unit_name         VARCHAR2,
                                       p_customer_no       VARCHAR2,
                                       p_address1          VARCHAR2,
                                       p_address2          VARCHAR2,
                                       p_address3          VARCHAR2,
                                       p_contact_person    VARCHAR2,
                                       p_contact_number    VARCHAR2,
                                       p_country           VARCHAR2,
                                       p_area              VARCHAR2,
                                       p_zone              VARCHAR2,
                                       p_division          VARCHAR2,
                                       p_salesperson_id    VARCHAR2,
                                       p_postal_code       VARCHAR2,
                                       p_demand_class      VARCHAR2)
   IS
      ---------------------Parameter-------------------

      l_operating_unit       NUMBER;
      l_unit_name            VARCHAR2 (240 BYTE);
      l_customer_id          NUMBER;
      l_customer_site_id     NUMBER;
      l_location_id          NUMBER;
      l_object_version_no    NUMBER;

      l_salesperson_name     VARCHAR2 (240);
      l_salesperson_id       VARCHAR2 (60);
      l_salesperson_conact   VARCHAR2 (60);
      l_salesperson          NUMBER;
      l_territory            NUMBER;
      l_demand_class         VARCHAR2 (30 BYTE);
      l_bill_site_id         NUMBER;
      l_bill_site_use_id     NUMBER;

      l_existing_loc         NUMBER;
      l_existing_address     VARCHAR2 (20);
      --------------------------------------------

      l_error_message        VARCHAR2 (3000);
      l_error_code           VARCHAR2 (3000);


      --------------------------------------------

      ERRBUF                 VARCHAR2 (1000);
      RETCODE                VARCHAR2 (1000);
      L_Retcode              NUMBER;
      CONC_STATUS            BOOLEAN;
      l_error                VARCHAR2 (100);
   ---------------------------------------------
   BEGIN
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
              FROM apps.hz_locations loc
             WHERE UPPER (loc.address1) = UPPER (p_address1);
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
      BEGIN
         /*
         SELECT sal.salesrep_id
           INTO l_salesperson
           FROM jtf_rs_salesreps sal, hr.per_all_people_f papf
          WHERE     1 = 1
                AND sal.person_id = papf.person_id
                AND TRUNC (SYSDATE) BETWEEN TRUNC (papf.effective_start_date)
                                        AND TRUNC (papf.effective_end_date)
                AND NVL (papf.current_emp_or_apl_flag, 'Y') = 'Y'
                AND NVL (papf.employee_number, papf.npw_number) =
                       P_SALESPERSON_ID
                AND sal.org_id = l_operating_unit;
                */
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
               l_error_message || ',' || 'Please enter correct Demand Class.';
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
         INSERT INTO xxdbl.xxdbl_cust_site_stg_tbl (cust_site_id,
                                                    creation_date,
                                                    created_by,
                                                    unit_name,
                                                    operating_unit,
                                                    customer_id,
                                                    customer_number,
                                                    bill_site_id,
                                                    bill_site_use_id,
                                                    new_location_id,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    contact_person,
                                                    contact_number,
                                                    country,
                                                    area,
                                                    zone,
                                                    division,
                                                    salesperson_name,
                                                    salesperson_id,
                                                    salesperson_conact,
                                                    postal_code,
                                                    salesperson,
                                                    demand_class,
                                                    territory)
              VALUES (TRIM (LPAD (xxdbl.xxdbl_cust_site_s.NEXTVAL, 7, '0')),
                      SYSDATE,
                      p_user_id,
                      l_unit_name,
                      l_operating_unit,
                      l_customer_id,
                      p_customer_no,
                      l_bill_site_id,
                      l_bill_site_use_id,
                      NVL (l_location_id, 0),
                      p_address1,
                      p_contact_person || ',' || p_address2,
                      p_address3,
                      p_contact_person,
                      p_contact_number,
                      p_country,
                      p_area,
                      p_zone,
                      p_division,
                      l_salesperson_name,
                      l_salesperson_id,
                      l_salesperson_conact,
                      p_postal_code,
                      l_salesperson,
                      l_demand_class,
                      l_territory);

         COMMIT;

         BEGIN
            fnd_file.put_line (fnd_file.LOG, 'Parameter received');


            L_Retcode :=
               create_customer_site (
                  TRIM (LPAD (xxdbl_cust_site_s.CURRVAL, 7, '0')));


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
END xxdbl_cust_site_webadi_pkg;
/