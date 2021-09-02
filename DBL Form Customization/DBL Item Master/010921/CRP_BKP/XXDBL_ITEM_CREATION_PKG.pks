CREATE OR REPLACE PACKAGE APPS.xxdbl_item_creation_pkg AUTHID CURRENT_USER
AS
   g_exception             EXCEPTION;
   g_sep                   VARCHAR2 (1)   := '.';
   g_success      CONSTANT VARCHAR2 (10)  := 'SUCCESS';
   g_master_org   CONSTANT VARCHAR2 (3)   := 'IMO';
   g_sysadmin     CONSTANT VARCHAR2 (30)  := 'SYSADMIN';
   g_gl_resp      CONSTANT VARCHAR2 (100) := 'GENERAL_LEDGER_SUPER_USER';
   g_orig_user_id          NUMBER;
   g_orig_resp_id          NUMBER;
   g_orig_appl_id          NUMBER;
   g_gl_resp_id            NUMBER;
   g_gl_appl_id            NUMBER;
   g_sys_user_id           NUMBER;

   FUNCTION get_elem_srl_num (
      p_catalog_group   IN   VARCHAR2,
      p_element         IN   VARCHAR2,
      p_length          IN   NUMBER
   )
      RETURN VARCHAR2;

   FUNCTION get_item_uom_conv (
      p_item_code            IN   VARCHAR2,
      p_primary_uom_code     IN   VARCHAR2,
      p_secondary_uom_code   IN   VARCHAR2
   )
      RETURN NUMBER;

   PROCEDURE gen_expense_ccid (
      p_organization_id       IN       NUMBER DEFAULT NULL,
      p_expense_acc_code      IN       VARCHAR2 DEFAULT NULL,
      p_expense_subacc_code   IN       VARCHAR2 DEFAULT NULL,
      p_product_line          IN       VARCHAR2 DEFAULT NULL,
      x_expense_ccid          OUT      NUMBER,
      x_message               OUT      VARCHAR2
   );

   FUNCTION submit_item_prog (p_batch_id IN NUMBER)
      RETURN NUMBER;

   PROCEDURE call_item_api (
      p_errbuff    OUT      VARCHAR2,
      p_retcode    OUT      VARCHAR2,
      p_batch_id   IN       NUMBER
   );

   PROCEDURE copy_items_from_batch (
      p_batch_id        IN       NUMBER,
      x_new_batch_id    OUT      NUMBER,
      x_return_status   OUT      VARCHAR2,
      x_message         OUT      VARCHAR2
   );
END xxdbl_item_creation_pkg;
/