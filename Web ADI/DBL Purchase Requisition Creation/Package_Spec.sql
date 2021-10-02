/* Formatted on 9/29/2021 6:08:44 PM (QP5 v5.365) */
CREATE OR REPLACE PACKAGE APPS.xxdbl_pr_creation_pkg
IS
    p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
    p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
    p_user_id             NUMBER := apps.fnd_global.user_id;
    p_org_id              NUMBER := apps.fnd_global.org_id;
    p_login_id            NUMBER := apps.fnd_global.login_id;

    PROCEDURE cust_upload_data_to_staging (p_organization_code   VARCHAR2,
                                           p_line_type           VARCHAR2,
                                           p_item_code           VARCHAR2,
                                           p_item_category       VARCHAR2,
                                           p_quantity            NUMBER,
                                           p_unit_price          NUMBER,
                                           p_specification       VARCHAR2);

    PROCEDURE create_pr_from_interface (ERRBUF    OUT VARCHAR2,
                                        RETCODE   OUT VARCHAR2);
END xxdbl_pr_creation_pkg;
/