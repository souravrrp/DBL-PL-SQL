/* Formatted on 3/11/2021 9:48:00 AM (QP5 v5.287) */
SELECT DISTINCT
       a.party_number,
       ps.party_site_number,
       a.party_id,
       'CUST-' || a.party_id || '-' || ass.org_id AS customer_ref,
       'ADD-' || ps.party_site_id || '-' || ass.org_id AS address_ref,
       ps.party_site_id,
       ass.address_line1,
       ass.city,
       ass.state,
       ass.zip,
       ass.country,
       a.orig_system_reference AS party_ref,
       a.party_name AS customer_name,
       ass.org_id
  FROM ap_suppliers ap,
       ap_supplier_sites_all ass,
       hz_parties a,
       hz_party_sites ps
 WHERE     ap.vendor_id = ass.vendor_id
       AND a.party_id = ap.party_id
       AND ps.party_id = ap.party_id
       AND ass.party_site_id = ps.party_site_id
       AND a.party_name = ap.vendor_name
       --AND a.party_id = 12465 -- Please pass your Party_id or Comment this line
       AND NOT EXISTS
              (SELECT 1
                 FROM hz_cust_accounts a
                WHERE a.party_id = a.party_id);


       -----------------Here we will be USING APIs:
--HZ_CUST_ACCOUNT_V2PUB.create_cust_account TO CREATE Customer ACCOUNT
--HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_siteto CREATE ACCOUNT Site
--HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use TO CREATE Site Uses BILL TO

SELECT USER_ID,
       RESPONSIBILITY_ID,
       RESPONSIBILITY_APPLICATION_ID,
       SECURITY_GROUP_ID
  FROM FND_USER_RESP_GROUPS
 WHERE     USER_ID = (SELECT USER_ID
                        FROM FND_USER
                       WHERE USER_NAME = '&user_name')
       AND RESPONSIBILITY_ID = (SELECT RESPONSIBILITY_ID
                                  FROM FND_RESPONSIBILITY_VL
                                 WHERE RESPONSIBILITY_NAME = '&Resp_name');
                                 
                                 
                                 
--------------------------------------------------------------------------------
--Sample code:
DECLARE
 l_num_user_id       NUMBER;
 l_num_appl_id       NUMBER;
 l_num_resp_id       NUMBER;
 cust_account_rec_type   hz_cust_account_v2pub.cust_account_rec_type;
 l_num_obj_ver_num     NUMBER;
 l_chr_return_status    VARCHAR2 (2000);
 l_num_msg_count      NUMBER;
 l_chr_msg_data       VARCHAR2 (500);
 l_num_profile_id      NUMBER;
 l_organization_rec     hz_party_v2pub.organization_rec_type;
 l_customer_profile_rec   hz_customer_profile_v2pub.customer_profile_rec_type;
 l_num_cust_id       NUMBER;
 l_chr_acct_num       VARCHAR2 (500);
 l_num_party_id       NUMBER;
 l_chr_party_number     VARCHAR2 (500);
 l_cust_acct_site_use_rec  hz_cust_account_site_v2pub.cust_site_use_rec_type;
 l_cust_acct_site_rec    hz_cust_account_site_v2pub.cust_acct_site_rec_type;
 l_chr_sit_return_status  VARCHAR2 (500);
 l_num_sit_msg_count    NUMBER;
 l_chr_sit_msg_data     VARCHAR2 (500);
 l_chr_situ_return_status  VARCHAR2 (500);
 l_num_situ_msg_count    NUMBER;
 l_chr_situ_msg_data    VARCHAR2 (500);
 l_num_site_use_id     NUMBER;
 CURSOR update_base_tables_cur
 IS
   SELECT DISTINCT a.party_number, ps.party_site_number, a.party_id,
           'CUST-' ||a.party_id||'-'||ass.org_id AS customer_ref,
           'ADD-'||ps.party_site_id||'-'||ass.org_id AS address_ref,
           ps.party_site_id,
           ass.address_line1,
           ass.city, ass.state, ass.zip, ass.country,
           'N' primary_site_use_flag,
           a.orig_system_reference AS party_ref,
           a.party_name AS customer_name, ass.org_id
        FROM apps.ap_suppliers ap,
           apps.ap_supplier_sites_all ass,
           apps.hz_parties a,
           apps.hz_party_sites ps
        WHERE ap.vendor_id = ass.vendor_id
         AND a.party_id = ap.party_id
         AND ps.party_id = ap.party_id
         AND ass.party_site_id = ps.party_site_id
         AND a.party_name = ap.vendor_name
         and a.party_id = 12465 -- modify this part/query
         --and ass.org_id = 204
         and NOT Exists (select 1 from hz_cust_accounts a
         where a.party_id = a.party_id);
BEGIN
FND_GLOBAL.APPS_INITIALIZE( &user_id, &responsibility_id, 222); -- input from 1st sql
dbms_output.put_line('***************************');
 FOR update_base_tables_rec IN update_base_tables_cur
 LOOP
   NULL;
   cust_account_rec_type.cust_account_id := fnd_api.g_miss_num;
   cust_account_rec_type.account_name := update_base_tables_rec.customer_name;
   l_organization_rec.party_rec.party_id := update_base_tables_rec.party_id;
   l_organization_rec.party_rec.party_number := update_base_tables_rec.party_number;
   l_organization_rec.organization_name := update_base_tables_rec.customer_name;
   cust_account_rec_type.orig_system_reference := update_base_tables_rec.customer_ref;
   l_customer_profile_rec.party_id := update_base_tables_rec.party_id;
   l_customer_profile_rec.profile_class_id := 0 ; -- use DEFAULT profile with id=0
   l_customer_profile_rec.created_by_module := 'HZ_CPUI';
   cust_account_rec_type.created_by_module := 'HZ_CPUI';
   hz_cust_account_v2pub.create_cust_account
             (p_init_msg_list       => fnd_api.g_false,
              p_cust_account_rec     => cust_account_rec_type,
              p_organization_rec     => l_organization_rec,
              p_customer_profile_rec   => l_customer_profile_rec,
              p_create_profile_amt    => fnd_api.g_true,
              x_cust_account_id      => l_num_cust_id,
              x_account_number      => l_chr_acct_num,
              x_party_id         => l_num_party_id,
              x_party_number       => l_chr_party_number,
              x_profile_id        => l_num_profile_id,
              x_return_status       => l_chr_return_status,
              x_msg_count         => l_num_msg_count,
              x_msg_data         => l_chr_msg_data
             );
dbms_output.put_line('x_return_status: '||l_chr_return_status);
dbms_output.put_line('x_cust_account_id: '||l_num_cust_id);
dbms_output.put_line('x_account_number: '||l_chr_acct_num);
dbms_output.put_line('x_party_id: '||l_num_party_id);
   IF l_chr_return_status != 'S'
   THEN
    --Display all the error messages
    FOR j IN 1 .. fnd_msg_pub.count_msg
    LOOP
      DBMS_OUTPUT.put_line (j);
      l_chr_msg_data :=
            fnd_msg_pub.get (p_msg_index   => j,
                     p_encoded    => 'F');
      DBMS_OUTPUT.put_line ('Message(' || j || '):= ' || l_chr_msg_data);
    END LOOP;
   END IF;
   BEGIN
    SELECT cust_account_id
     INTO l_cust_acct_site_rec.cust_account_id
     FROM hz_cust_accounts
     WHERE orig_system_reference = update_base_tables_rec.customer_ref;
   EXCEPTION
    WHEN OTHERS
    THEN
      l_cust_acct_site_rec.cust_account_id := fnd_api.g_miss_num;
   END;
   l_cust_acct_site_rec.party_site_id := update_base_tables_rec.party_site_id;
   l_cust_acct_site_rec.created_by_module := 'HZ_CPUI';
   l_cust_acct_site_rec.orig_system_reference := update_base_tables_rec.address_ref;
   l_cust_acct_site_rec.status := 'A';
   l_cust_acct_site_rec.org_id := update_base_tables_rec.org_id;
   mo_global.init ('ONT');
   mo_global.set_policy_context (p_access_mode   => 'S',
                  p_org_id      => update_base_tables_rec.org_id
                 );
   hz_cust_account_site_v2pub.create_cust_acct_site
                (p_init_msg_list      => 'T',
                p_cust_acct_site_rec   => l_cust_acct_site_rec,
                x_cust_acct_site_id    => l_num_obj_ver_num,
                x_return_status      => l_chr_sit_return_status,
                x_msg_count        => l_num_sit_msg_count,
                x_msg_data        => l_chr_sit_msg_data
                );
dbms_output.put_line('x_cust_acct_site_id: '||l_num_obj_ver_num);
dbms_output.put_line('x_return_status: '||l_chr_sit_return_status);
   IF l_chr_sit_return_status != 'S'
   THEN
    --Display all the error messages
    FOR j IN 1 .. fnd_msg_pub.count_msg
    LOOP
      DBMS_OUTPUT.put_line (j);
      l_chr_sit_msg_data :=
            fnd_msg_pub.get (p_msg_index   => j,
                     p_encoded    => 'F');
      DBMS_OUTPUT.put_line (  'Site Message('
                 || j
                 || '):= '
                 || l_chr_sit_msg_data
                );
    END LOOP;
   END IF;
   BEGIN
    SELECT cust_acct_site_id
     INTO l_cust_acct_site_use_rec.cust_acct_site_id
     FROM hz_cust_acct_sites_all
     WHERE orig_system_reference = update_base_tables_rec.address_ref;
   EXCEPTION
    WHEN OTHERS
    THEN
      l_cust_acct_site_use_rec.cust_acct_site_id := fnd_api.g_miss_num;
   END;
   l_cust_acct_site_use_rec.org_id := update_base_tables_rec.org_id;
   l_cust_acct_site_use_rec.site_use_code := 'BILL_TO';
   l_cust_acct_site_use_rec.status := 'A';
   l_cust_acct_site_use_rec.primary_flag := 'Y';
   l_cust_acct_site_use_rec.orig_system_reference :=
                      update_base_tables_rec.address_ref;
   l_cust_acct_site_use_rec.created_by_module := 'HZ_CPUI';
   mo_global.set_policy_context (p_access_mode   => 'S',
                  p_org_id      => update_base_tables_rec.org_id
                 );
   hz_cust_account_site_v2pub.create_cust_site_use
              (p_init_msg_list       => 'T',
              p_cust_site_use_rec     => l_cust_acct_site_use_rec,
              p_customer_profile_rec   => l_customer_profile_rec,
              p_create_profile      => fnd_api.g_true,
              p_create_profile_amt    => fnd_api.g_true,
              x_site_use_id        => l_num_site_use_id,
              x_return_status       => l_chr_situ_return_status,
              x_msg_count         => l_num_situ_msg_count,
              x_msg_data         => l_chr_situ_msg_data
              );
dbms_output.put_line('x_site_use_id: '||l_num_site_use_id);
dbms_output.put_line('x_return_status: '||l_chr_situ_return_status);
   IF l_chr_situ_return_status != 'S'
   THEN
    --Display all the error messages
    FOR j IN 1 .. fnd_msg_pub.count_msg
    LOOP
      DBMS_OUTPUT.put_line (j);
      l_chr_situ_msg_data :=
            fnd_msg_pub.get (p_msg_index   => j,
                     p_encoded    => 'F');
      DBMS_OUTPUT.put_line (  'Site Use Message('
                 || j
                 || '):= '
                 || l_chr_situ_msg_data
                );
    END LOOP;
   END IF;
 END LOOP;
END;
/
--COMMIT once the code finishes successfully.
commit;

--------------------------------------------------------------------------------
select cust_account_id, party_id, account_number,
account_name, orig_system_reference
from hz_cust_accounts
where party_id = 12465;

select  cust_acct_site_id, cust_account_id,party_site_id,org_id
from HZ_CUST_ACCT_SITES_ALL
where CUST_ACCOUNT_ID=207822;