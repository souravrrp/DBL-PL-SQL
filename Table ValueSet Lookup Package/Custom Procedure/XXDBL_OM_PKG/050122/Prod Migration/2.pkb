CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_om_pkg
AS
   FUNCTION default_item_grade (p_inventory_item_id   IN NUMBER,
                                p_organization_id     IN NUMBER)
      RETURN VARCHAR2
   IS
      l_grade   VARCHAR2 (10);
   BEGIN
      FOR r
         IN (SELECT a.default_grade grade
               FROM mtl_system_items_b a              --, oe_order_lines_all b
              WHERE     1 = 1  --and a.inventory_item_id = b.inventory_item_id
                    --AND a.organization_id = b.ship_from_org_id
                    AND a.inventory_item_id = p_inventory_item_id
                    AND a.organization_id = p_organization_id
                    AND a.lot_control_code = 2)
      LOOP
         l_grade := r.grade;
      END LOOP;

      RETURN l_grade;
   END default_item_grade;

   FUNCTION order_type_pl_match (p_order_type_id   IN NUMBER,
                                 p_org_id          IN NUMBER,
                                 p_pl_id           IN NUMBER)
      RETURN VARCHAR2
   IS
      l_match   VARCHAR2 (10) := 'N';
      l_pl_id   NUMBER;
      l_count   NUMBER := 0;
   BEGIN
      SELECT COUNT (1)
        INTO l_count
        FROM oe_transaction_types_all a
       WHERE     transaction_type_code = 'ORDER'
             AND a.transaction_type_id = p_order_type_id
             --PRICE_LIST_ID
             AND a.org_id = p_org_id
             AND a.price_list_id = p_pl_id
             AND NVL (a.attribute1, 'NO') = 'YES';

      IF l_count <> 0
      THEN
         l_match := 'Y';
      END IF;

      RETURN l_match;
   END order_type_pl_match;

   FUNCTION GET_PARTY_SITE_ADDRESS (P_SITE_USE_ID NUMBER)
      RETURN VARCHAR2
   AS
      V_ADDRESS   VARCHAR2 (500);
   BEGIN
      SELECT ADDRESS1 || '.' || ADDRESS2 --HZ_FORMAT_PUB.FORMAT_ADDRESS (HL.LOCATION_ID,NULL,NULL,' ')
        INTO V_ADDRESS
        FROM APPS.HZ_CUST_SITE_USES_ALL HCSUA,
             APPS.HZ_CUST_ACCT_SITES_ALL HCASA,
             HZ_PARTY_SITES HPS,
             HZ_LOCATIONS HL
       WHERE     HCSUA.CUST_ACCT_SITE_ID = HCASA.CUST_ACCT_SITE_ID
             AND HCASA.PARTY_SITE_ID = HPS.PARTY_SITE_ID
             AND SITE_USE_ID = P_SITE_USE_ID                          --330024
             AND HPS.LOCATION_ID = HL.LOCATION_ID;

      RETURN (V_ADDRESS);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'No Address Found';
   END;

   FUNCTION GET_OM_PHONE_NUMBER (P_ID VARCHAR2, P_NAME VARCHAR2)
      RETURN VARCHAR2
   AS
      V_PHONE_NUMBER   VARCHAR2 (100);
   BEGIN
      IF P_NAME = 'ACCOUNT'
      THEN
         SELECT MAX (PHONE_NUMBER) BILL_PHONE_NUMBER
           INTO V_PHONE_NUMBER
           FROM AR.HZ_CONTACT_POINTS HCP,
                HZ_PARTY_SITES HPS,
                HZ_CUST_ACCT_SITES_ALL HCASA
          WHERE                                 --contact_point_type = 'PHONE'
               HCP  .STATUS = 'A'
                AND OWNER_TABLE_NAME = 'HZ_PARTY_SITES'
                AND HCP.OWNER_TABLE_ID = HPS.PARTY_SITE_ID
                AND HPS.PARTY_SITE_ID = HCASA.PARTY_SITE_ID
                AND CUST_ACCOUNT_ID = P_ID                              --2622
                AND BILL_TO_FLAG = 'P';
      -- GROUP BY CUST_ACCOUNT_ID;
      ELSIF P_NAME = 'SITE'
      THEN
         SELECT MAX (PHONE_NUMBER) SHIP_PHONE_NUMBER
           INTO V_PHONE_NUMBER
           FROM AR.HZ_CONTACT_POINTS HCP,
                HZ_PARTY_SITES HPS,
                HZ_CUST_ACCT_SITES_ALL HCASA
          WHERE                                 --contact_point_type = 'PHONE'
               HCP  .STATUS = 'A'
                AND OWNER_TABLE_NAME = 'HZ_PARTY_SITES'
                AND HCP.OWNER_TABLE_ID = HPS.PARTY_SITE_ID
                AND HPS.PARTY_SITE_ID = HCASA.PARTY_SITE_ID
                AND HPS.PARTY_SITE_ID = P_ID;                           --2622
      ELSIF P_NAME = 'SR'
      THEN
         SELECT MAX (PP.PHONE_NUMBER) SR_PHONE
           INTO V_PHONE_NUMBER
           FROM APPS.PER_ALL_ASSIGNMENTS_F PAF1, PER_PHONES PP
          WHERE     PAF1.PRIMARY_FLAG = 'Y'
                AND SYSDATE BETWEEN PAF1.EFFECTIVE_START_DATE
                                AND PAF1.EFFECTIVE_END_DATE
                --   AND paf1.person_id = :person_id
                AND PAF1.PERSON_ID = PP.PARENT_ID
                AND PAF1.PERSON_ID = P_ID;
      ELSIF P_NAME = 'SRS'
      THEN
         SELECT MAX (PP.PHONE_NUMBER) SRS_PHONE
           INTO V_PHONE_NUMBER
           FROM APPS.PER_ALL_ASSIGNMENTS_F PAF1, PER_PHONES PP
          WHERE     PAF1.PRIMARY_FLAG = 'Y'
                AND SYSDATE BETWEEN PAF1.EFFECTIVE_START_DATE
                                AND PAF1.EFFECTIVE_END_DATE
                -- AND paf1.person_id = :person_id --489
                AND PAF1.SUPERVISOR_ID = PP.PARENT_ID
                AND PAF1.PERSON_ID = P_ID;
      END IF;

      RETURN V_PHONE_NUMBER;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'No Phone Found';
   END;
END xxdbl_om_pkg;
/