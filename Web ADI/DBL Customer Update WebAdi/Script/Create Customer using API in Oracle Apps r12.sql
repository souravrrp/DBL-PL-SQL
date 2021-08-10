DECLARE
 p_cust_account_rec     HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
 p_organization_rec     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
 p_customer_profile_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
 x_cust_account_id      NUMBER;
 x_account_number       VARCHAR2(2000);
 x_party_id             NUMBER;
 x_party_number         VARCHAR2(2000);
 x_profile_id           NUMBER;
 x_return_status        VARCHAR2(2000);
 x_msg_count            NUMBER;
 x_msg_data             VARCHAR2(2000);

BEGIN
 p_cust_account_rec.account_name      := 'API_ACC';
 p_cust_account_rec.created_by_module := 'BO_API';
 p_organization_rec.organization_name := 'API Party';
 p_organization_rec.created_by_module := 'BO_API';

 DBMS_OUTPUT.PUT_LINE('Calling the API hz_cust_account_v2pub.create_cust_account');

 HZ_CUST_ACCOUNT_V2PUB.CREATE_CUST_ACCOUNT
             (
              p_init_msg_list       => FND_API.G_TRUE,
              p_cust_account_rec    =>p_cust_account_rec,
              p_organization_rec    =>p_organization_rec,
              p_customer_profile_rec=>p_customer_profile_rec,
              p_create_profile_amt  =>FND_API.G_FALSE,
              x_cust_account_id     =>x_cust_account_id,
              x_account_number      =>x_account_number,
              x_party_id            =>x_party_id,
              x_party_number        =>x_party_number,
              x_profile_id          =>x_profile_id,
              x_return_status       =>x_return_status,
              x_msg_count           =>x_msg_count,
              x_msg_data            =>x_msg_data
                    );

IF x_return_status = fnd_api.g_ret_sts_success THEN
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Creation of Party and customer account is Successful ');
    DBMS_OUTPUT.PUT_LINE('Output information ....');
    DBMS_OUTPUT.PUT_LINE('x_cust_account_id  : '||x_cust_account_id);
    DBMS_OUTPUT.PUT_LINE('x_account_number   : '||x_account_number);
    DBMS_OUTPUT.PUT_LINE('x_party_id         : '||x_party_id);
    DBMS_OUTPUT.PUT_LINE('x_party_number     : '||x_party_number);
    DBMS_OUTPUT.PUT_LINE('x_profile_id       : '||x_profile_id);   
ELSE
    DBMS_OUTPUT.put_line ('Creation of Party and customer account failed:'||x_msg_data);
    ROLLBACK;
    FOR i IN 1 .. x_msg_count
    LOOP
      x_msg_data := oe_msg_pub.get( p_msg_index => i, p_encoded => 'F');
      dbms_output.put_line( i|| ') '|| x_msg_data);
    END LOOP;
END IF;
DBMS_OUTPUT.PUT_LINE('Completion of API');
END;
/



--------------------------------------------------------------------------------


DECLARE
    l_cust_account_rec       hz_cust_account_v2pub.cust_account_rec_type;
    l_org_rec                hz_party_v2pub.organization_rec_type;
    l_customer_profile_rec   hz_customer_profile_v2pub.customer_profile_rec_type;
    l_account_name           hz_cust_accounts.account_name%TYPE;

    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2 (4000);
    l_err_msg                VARCHAR2 (4000);
    l_return_status          VARCHAR2 (1);
    l_cust_account_id        NUMBER;
    l_account_number         hz_cust_accounts.account_number%TYPE;
    l_party_id               hz_cust_accounts.party_id%TYPE;
    l_party_number           hz_parties.party_id%TYPE;
    l_cust_acct_profile_id   hz_customer_profiles.cust_account_profile_id%TYPE;
BEGIN
    l_cust_account_rec.account_name := 'Test Customer 98765432';
    l_cust_account_rec.account_number := '98765432';
    l_cust_account_rec.customer_type := 'R';
    l_cust_account_rec.attribute1 := SYSDATE;
    l_cust_account_rec.created_by_module := 'HZ_CPUI';
    l_org_rec.organization_name := 'Test Customer 98765432';

    hz_cust_account_v2pub.create_cust_account (
        p_init_msg_list          => fnd_api.g_true,
        p_cust_account_rec       => l_cust_account_rec,
        p_organization_rec       => l_org_rec,
        p_customer_profile_rec   => l_customer_profile_rec,
        p_create_profile_amt     => fnd_api.g_true,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        x_cust_account_id        => l_cust_account_id,
        x_account_number         => l_account_number,
        x_party_id               => l_party_id,
        x_party_number           => l_party_number,
        x_profile_id             => l_cust_acct_profile_id);

    DBMS_OUTPUT.put_line ('API Return status is: ' || l_return_status);
    
    IF l_return_status <> 'S'
    THEN 
        DBMS_OUTPUT.put_line ('Error message is: ' || SUBSTR (l_msg_data, 200));
    END IF; 
    
    IF l_return_status = 'S'
    THEN
        BEGIN
            SELECT account_name
              INTO l_account_name
              FROM hz_cust_accounts
             WHERE account_number = '98769876';

            DBMS_OUTPUT.put_line (
                   'Customer Account created with Account number: '
                || l_account_number
                || ' and Cust Account ID: '
                || l_cust_account_id
                || ' and Account Name: '
                || l_account_name);
        EXCEPTION
            WHEN OTHERS
            THEN
                DBMS_OUTPUT.put_line (
                    'Error during deriving Account Name: ' || SQLERRM);
        END;
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN
        DBMS_OUTPUT.put_line ('Error during creating account: ' || SQLERRM);
END;



