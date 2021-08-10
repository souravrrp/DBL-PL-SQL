CREATE OR REPLACE PACKAGE APPS.XXDBL_ITEM_UPLOAD_WEBADI_PKG
IS
    vl_set_process_id   NUMBER := TO_NUMBER (TO_CHAR (SYSDATE, 'ddmmyyyy'));

    PROCEDURE cust_import_data_to_interface;

    PROCEDURE cust_upload_data_to_staging (p_item_type      VARCHAR2,
                                           p_item_count     VARCHAR2,
                                           p_product_type   VARCHAR2,
                                           p_item_content   VARCHAR2,
                                           p_item_style     VARCHAR2,
                                           p_item_process   VARCHAR2,
                                           p_description    VARCHAR2);

    PROCEDURE assign_item_org_and_category (errbuf    OUT VARCHAR2,
                                            retcode   OUT VARCHAR2);

    PROCEDURE assign_item_into_org (l_item_code         VARCHAR2,
                                    l_organization_id   NUMBER);

    PROCEDURE assign_item_category (vl_item_code         VARCHAR2,
                                    vl_organization_id   NUMBER,
                                    vlu_category_id      NUMBER);

    PROCEDURE create_lcm_item_category (Lcm_ITEM_CODE         VARCHAR2,
                                        Lcm_organization_id   NUMBER);


    PROCEDURE item_assign_uom_conv (um_item_code IN VARCHAR2);

    PROCEDURE item_assign_template (tm_item_code       IN VARCHAR2,
                                    tm_org_id          IN NUMBER,
                                    tm_template_name   IN VARCHAR2);

    PROCEDURE item_catalog_update (ct_item_code VARCHAR2);
END XXDBL_ITEM_UPLOAD_WEBADI_PKG;
/
