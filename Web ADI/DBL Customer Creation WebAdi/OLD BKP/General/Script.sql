/* Formatted on 5/10/2021 11:52:22 AM (QP5 v5.287) */
DECLARE
   --Create a party and an account
   --Setup the Org_id
   --EXEC dbms_application_info.set_client_info('204');

   --Show the output variables

   --SET serveroutput ON

   --DECLARE

   p_cust_account_rec       HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;

   p_organization_rec       HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;

   p_customer_profile_rec   HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;

   x_cust_account_id        NUMBER;
   x_account_number         VARCHAR2 (2000);

   x_party_id               NUMBER;
   x_party_number           VARCHAR2 (2000);

   x_profile_id             NUMBER;
   x_return_status          VARCHAR2 (2000);

   x_msg_count              NUMBER;
   x_msg_data               VARCHAR2 (2000);
   ------------------------------------------
   p_location_rec           HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

   x_location_id            NUMBER;

   --x_return_status          VARCHAR2 (2000);
   --x_msg_count NUMBER;

   --x_msg_data VARCHAR2(2000);
   ----------------------------------------------------
   p_party_site_rec         HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;

   x_party_site_id          NUMBER;

   x_party_site_number      VARCHAR2 (2000);

   --x_return_status          VARCHAR2 (2000);

   --x_msg_count              NUMBER;

   --x_msg_data               VARCHAR2 (2000);
   -----------------------------------------------------------------------------
   p_cust_acct_site_rec     hz_cust_account_site_v2pub.cust_acct_site_rec_type;

   --x_return_status VARCHAR2(2000);

   --x_msg_count NUMBER;

   --x_msg_data VARCHAR2(2000);


   x_cust_acct_site_id      NUMBER;
   -----------------------------------------------------------------------------
   p_cust_site_use_rec      HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;

   --p_customer_profile_rec   HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;

   x_site_use_id            NUMBER;
--x_return_status          VARCHAR2 (2000);

--x_msg_count              NUMBER;

--x_msg_data               VARCHAR2 (2000);
-----------------------------------------------------------------------------
--p_location_rec           HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

--x_location_id            NUMBER;

--x_return_status          VARCHAR2 (2000);

--x_msg_count              NUMBER;

--x_msg_data               VARCHAR2 (2000);
-----------------------------------------------------------------------------
--p_party_site_rec         HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;

--x_party_site_id          NUMBER;

--x_party_site_number      VARCHAR2 (2000);
--x_return_status          VARCHAR2 (2000);

--x_msg_count              NUMBER;

--x_msg_data               VARCHAR2 (2000);
-----------------------------------------------------------------------------
--p_cust_acct_site_rec     hz_cust_account_site_v2pub.cust_acct_site_rec_type;

--x_return_status          VARCHAR2 (2000);
--x_msg_count              NUMBER;

--x_msg_data               VARCHAR2 (2000);

--x_cust_acct_site_id      NUMBER;
-----------------------------------------------------------------------------
--p_cust_site_use_rec      HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;

--p_customer_profile_rec   HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;

--x_site_use_id            NUMBER;
--x_return_status          VARCHAR2 (2000);

--x_msg_count              NUMBER;

--x_msg_data               VARCHAR2 (2000);
BEGIN
   BEGIN
      p_cust_account_rec.account_name := 'ACC01_01_03';

      p_cust_account_rec.created_by_module := 'TCAPI_EXAMPLE';

      -- p_cust_account_rec.orig_system_reference := '001_001'; -- is not mandatory

      p_organization_rec.organization_name := 'CUSTAPI3';

      p_organization_rec.created_by_module := 'TCAPI_EXAMPLE';

      hz_cust_account_v2pub.create_cust_account ('T',
                                                 p_cust_account_rec,
                                                 p_organization_rec,
                                                 p_customer_profile_rec,
                                                 'F',
                                                 x_cust_account_id,
                                                 x_account_number,
                                                 x_party_id,
                                                 x_party_number,
                                                 x_profile_id,
                                                 x_return_status,
                                                 x_msg_count,
                                                 x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');

      DBMS_OUTPUT.put_line ('Output information ....');

      DBMS_OUTPUT.put_line ('x_cust_account_id: ' || x_cust_account_id);

      DBMS_OUTPUT.put_line ('x_account_number: ' || x_account_number);

      DBMS_OUTPUT.put_line ('x_party_id: ' || x_party_id);

      DBMS_OUTPUT.put_line ('x_party_number: ' || x_party_number);

      DBMS_OUTPUT.put_line ('x_profile_id: ' || x_profile_id);

      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);

      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');
   END;

   /* BEGIN address */


   --CREATE a physical location

   --DECLARE



   BEGIN
      p_location_rec.country := 'US';

      p_location_rec.address1 := 'Address3a';

      p_location_rec.city := 'San Mateo';
      p_location_rec.postal_code := '94401';

      p_location_rec.state := 'CA';
      p_location_rec.created_by_module := 'TCAPI_EXAMPLE';

      hz_location_v2pub.create_location ('T',
                                         p_location_rec,
                                         x_location_id,
                                         x_return_status,
                                         x_msg_count,
                                         x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');

      DBMS_OUTPUT.put_line ('Output information ....');

      DBMS_OUTPUT.put_line ('x_location_id: ' || x_location_id);

      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);

      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');
   END;


   --CREATE a party site using party_id from step 2 and location_id from step

   --DECLARE



   BEGIN
      p_party_site_rec.party_id := x_party_id;                           --XX;

      --<<value for party_id from step 2>
      p_party_site_rec.location_id := x_location_id;                     --XX;

      --<<value for location_id from step 3>
      p_party_site_rec.identifying_address_flag := 'Y';

      p_party_site_rec.created_by_module := 'TCAPI_EXAMPLE';

      hz_party_site_v2pub.create_party_site ('T',
                                             p_party_site_rec,
                                             x_party_site_id,
                                             x_party_site_number,
                                             x_return_status,
                                             x_msg_count,
                                             x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');

      DBMS_OUTPUT.put_line ('Output information ....');

      DBMS_OUTPUT.put_line ('x_party_site_id: ' || x_party_site_id);

      DBMS_OUTPUT.put_line ('x_party_site_number: ' || x_party_site_number);

      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);

      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');
   END;


   --CREATE an account site using cust_account_id from step 2 and party_site_id from step 4.

   --DECLARE



   BEGIN
      p_cust_acct_site_rec.cust_account_id := x_cust_account_id;         --XX;

      --<<value for cust_account_id you get from step 2>
      p_cust_acct_site_rec.party_site_id := x_party_site_id;             --XX;

      --<<value for party_site_id from step 4>
      p_cust_acct_site_rec.language := 'US';

      p_cust_acct_site_rec.created_by_module := 'TCAPI_EXAMPLE';

      hz_cust_account_site_v2pub.create_cust_acct_site ('T',
                                                        p_cust_acct_site_rec,
                                                        x_cust_acct_site_id,
                                                        x_return_status,
                                                        x_msg_count,
                                                        x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');

      DBMS_OUTPUT.put_line ('Output information ....');

      DBMS_OUTPUT.put_line ('x_cust_acct_site_id: ' || x_cust_acct_site_id);

      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);

      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);
      DBMS_OUTPUT.put_line ('***************************');
   END;                                ------------------------------------ --


   --CREATE an account site use using cust_acct_site_id from step 5 and site_use_code='BILL_TO'

   --DECLARE



   BEGIN
      p_cust_site_use_rec.cust_acct_site_id := x_cust_acct_site_id;      --XX;

      --<<value for cust_acct_site_id from step 5>
      p_cust_site_use_rec.site_use_code := 'BILL_TO';

      p_cust_site_use_rec.created_by_module := 'TCAPI_EXAMPLE';

      hz_cust_account_site_v2pub.create_cust_site_use (
         'T',
         p_cust_site_use_rec,
         p_customer_profile_rec,
         '',
         '',
         x_site_use_id,
         x_return_status,
         x_msg_count,
         x_msg_data);
      DBMS_OUTPUT.put_line ('***************************');

      DBMS_OUTPUT.put_line ('Output information ....');

      DBMS_OUTPUT.put_line ('x_site_use_id: ' || x_site_use_id);

      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);

      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('***************************');
   END;

   /* END address */


   --COMMIT the changes

   COMMIT;

   --CREATE a physical location

   --DECLARE



   BEGIN
      p_location_rec.country := 'US';

      p_location_rec.address1 := 'Address3b';

      p_location_rec.city := 'San Mateo';

      p_location_rec.postal_code := '94401';

      p_location_rec.state := 'CA';

      p_location_rec.created_by_module := 'TCAPI_EXAMPLE';

      hz_location_v2pub.create_location ('T',
                                         p_location_rec,
                                         x_location_id,
                                         x_return_status,
                                         x_msg_count,
                                         x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');

      DBMS_OUTPUT.put_line ('Output information ....');

      DBMS_OUTPUT.put_line ('x_location_id: ' || x_location_id);

      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);

      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');
   END;


   --CREATE a party site using party_idfrom step 2 and location_id from step 7

   --DECLARE



   BEGIN
      p_party_site_rec.party_id := x_party_id;                           --XX;

      --<<value for party_id from step 2>
      p_party_site_rec.location_id := x_location_id;                     --XX;

      --<<value for location_id from step 7>
      p_party_site_rec.identifying_address_flag := 'Y';

      p_party_site_rec.created_by_module := 'TCAPI_EXAMPLE';

      hz_party_site_v2pub.create_party_site ('T',
                                             p_party_site_rec,
                                             x_party_site_id,
                                             x_party_site_number,
                                             x_return_status,
                                             x_msg_count,
                                             x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');

      DBMS_OUTPUT.put_line ('Output information ....');

      DBMS_OUTPUT.put_line ('x_party_site_id: ' || x_party_site_id);

      DBMS_OUTPUT.put_line ('x_party_site_number: ' || x_party_site_number);
      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);

      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');
   END;


   --CREATE an account site using cust_account_id from step 2 and party_site_id from step 8.

   --DECLARE



   BEGIN
      p_cust_acct_site_rec.cust_account_id := x_cust_account_id;         --XX;

      --<<value for cust_account_id you get from step 2>
      p_cust_acct_site_rec.party_site_id := x_party_site_id;             --XX;

      --<<value for party_site_id from step 8>
      p_cust_acct_site_rec.language := 'US';

      p_cust_acct_site_rec.created_by_module := 'TCAPI_EXAMPLE';

      hz_cust_account_site_v2pub.create_cust_acct_site ('T',
                                                        p_cust_acct_site_rec,
                                                        x_cust_acct_site_id,
                                                        x_return_status,
                                                        x_msg_count,
                                                        x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');

      DBMS_OUTPUT.put_line ('Output information ....');

      DBMS_OUTPUT.put_line ('x_cust_acct_site_id: ' || x_cust_acct_site_id);

      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);

      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_data);

      DBMS_OUTPUT.put_line ('***************************');
   END;


   --CREATE an account site use using cust_acct_site_id from step 9 and site_use_code='SHIP_TO'

   --DECLARE



   BEGIN
      p_cust_site_use_rec.cust_acct_site_id := x_cust_acct_site_id;      --XX;

      --<<value for cust_acct_site_id from step 9>
      p_cust_site_use_rec.site_use_code := 'SHIP_TO';

      p_cust_site_use_rec.created_by_module := 'TCAPI_EXAMPLE';

      hz_cust_account_site_v2pub.create_cust_site_use (
         'T',
         p_cust_site_use_rec,
         p_customer_profile_rec,
         '',
         '',
         x_site_use_id,
         x_return_status,
         x_msg_count,
         x_msg_data);
      DBMS_OUTPUT.put_line ('***************************');

      DBMS_OUTPUT.put_line ('Output information ....');

      DBMS_OUTPUT.put_line ('x_site_use_id: ' || x_site_use_id);

      DBMS_OUTPUT.put_line ('x_return_status: ' || x_return_status);

      DBMS_OUTPUT.put_line ('x_msg_count: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('x_msg_data: ' || x_msg_count);

      DBMS_OUTPUT.put_line ('***************************');
   END;


   --COMMIT the changes

   COMMIT;
END;