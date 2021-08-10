CREATE OR REPLACE PACKAGE APPS.xxdbl_modifier_upload_pkg
AS
   PROCEDURE load_modifier_adi_prc (
      p_MODIFIER_NAME             IN VARCHAR2 DEFAULT NULL,
      p_LINE_LEVEL                IN VARCHAR2 DEFAULT NULL,
      p_MODIFIER_TYPE             IN VARCHAR2 DEFAULT NULL,
      p_effective_date_from       IN DATE DEFAULT NULL,
      p_effective_date_to         IN DATE DEFAULT NULL,
      P_PRICING_PHASE             IN VARCHAR2 DEFAULT NULL,
      P_PRICING_PHASE_ID          IN NUMBER DEFAULT NULL,
      p_ln_product_context        IN VARCHAR2 DEFAULT NULL,
      p_trns_product_context      IN VARCHAR2 DEFAULT NULL,
      p_PRODUCT_ATTRIBUTE         IN VARCHAR2 DEFAULT NULL,
      P_LN_PRODUCT_VALUE          IN VARCHAR2 DEFAULT NULL,
      p_VOLUME_TYPE               IN VARCHAR2 DEFAULT NULL,
      p_uom                       IN VARCHAR2 DEFAULT NULL,
      p_ln_uom_code               IN VARCHAR2 DEFAULT NULL,
      p_BREAK_TYPE                IN VARCHAR2 DEFAULT NULL,
      p_LN_PRODUCT_ATTRIBUTE      IN VARCHAR2 DEFAULT NULL,
      p_OPERATOR                  IN VARCHAR2 DEFAULT NULL,
      P_VALUE_FROM                IN NUMBER DEFAULT NULL,
      P_VALUE_TO                  IN NUMBER DEFAULT NULL,
      P_APPLICATION_METHOD        IN VARCHAR2 DEFAULT NULL,
      P_VALUE                     IN NUMBER DEFAULT NULL,
      P_PRICING_ATTRIBUTE         IN VARCHAR2 DEFAULT NULL,
      P_ITEM_ID                   IN NUMBER DEFAULT NULL,
      p_application_operator      IN VARCHAR2 DEFAULT NULL,
      p_ln_value                  IN NUMBER DEFAULT NULL,
      p_grade_pricing_attribute   IN VARCHAR2 DEFAULT NULL,
      p_grade_operator            IN VARCHAR2 DEFAULT NULL,
      p_grade_lookup_code         IN VARCHAR2 DEFAULT NULL,
      p_grade_name                IN VARCHAR2 DEFAULT NULL);

   PROCEDURE VALIDATE_PL (x_retcode        OUT NUMBER,
                          x_errbuff        OUT VARCHAR2,
                          p_listname    IN     VARCHAR2,
                          p_record_id   IN     NUMBER);

   PROCEDURE main (ERRBUF           OUT VARCHAR2,
                   RETCODE          OUT VARCHAR2,
                   P_MODE        IN     VARCHAR2,
                   P_LIST_NAME   IN     VARCHAR2,
                   P_RECORD_ID   IN     NUMBER);

   PROCEDURE INSERT_END_DATE (x_retcode        OUT NUMBER,
                              x_errbuff        OUT VARCHAR2,
                              p_listname    IN     VARCHAR2,
                              p_record_id   IN     NUMBER);


   PROCEDURE INSERT_PL (x_retcode        OUT NUMBER,
                        x_errbuff        OUT VARCHAR2,
                        p_listname    IN     VARCHAR2,
                        p_record_id   IN     NUMBER);
END xxdbl_modifier_upload_pkg;
/