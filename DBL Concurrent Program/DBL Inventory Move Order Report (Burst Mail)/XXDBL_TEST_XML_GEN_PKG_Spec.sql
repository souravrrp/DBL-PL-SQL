/* Formatted on 3/22/2021 9:36:53 AM (QP5 v5.287) */
CREATE OR REPLACE PACKAGE XXDBL_TEST_XML_GEN_PKG
IS
   p_responsibility_id   NUMBER := apps.fnd_global.resp_id;
   p_respappl_id         NUMBER := apps.fnd_global.resp_appl_id;
   p_user_id             NUMBER := apps.fnd_global.user_id;
   p_org_id              NUMBER := apps.fnd_global.org_id;

   PROCEDURE P_RUN (p_errbuff             OUT VARCHAR2,
                    p_ret_code            OUT VARCHAR2,
                    p_person_id        IN     VARCHAR2,
                    p_effective_date   IN     VARCHAR2);
END XXDBL_TEST_XML_GEN_PKG;
/