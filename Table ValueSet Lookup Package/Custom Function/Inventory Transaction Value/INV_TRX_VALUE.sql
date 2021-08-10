/* Formatted on 10/8/2020 3:40:14 PM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION APPS.XXDBL_INV_TRX_VAL (P_item_id   IN NUMBER,
                                                   p_org_id       NUMBER,
                                                   p_t_type       VARCHAR2,
                                                   p_trx_id       VARCHAR2,
                                                   p_date_fr      DATE,
                                                   p_date_to      DATE)
   RETURN NUMBER
AS
   --Related to Function: APPS.XX_INV_TRAN_VAL
   --Added p_trx_id in terms of transaction_type_id
   inv_values   NUMBER (38);
BEGIN
   IF p_t_type IN ('O', 'C')
   THEN
      SELECT NVL (SUM (base_transaction_value), 0)
        INTO INV_Values
        FROM cst_inv_distribution_v
       WHERE     transaction_id IN
                    (SELECT transaction_id
                       FROM mtl_material_transactions
                      WHERE     TRUNC (transaction_date) BETWEEN p_date_fr
                                                             AND p_date_to
                            AND inventory_item_id = P_item_id
                            AND transaction_type_id = p_trx_id
                            AND organization_id = p_org_id)
             AND line_type_name = 'Inv valuation';
   END IF;


   IF p_t_type = 'R'
   THEN
      SELECT NVL (SUM (base_transaction_value), 0)
        INTO INV_Values
        FROM cst_inv_distribution_v
       WHERE     transaction_id IN
                    (SELECT transaction_id
                       FROM mtl_material_transactions
                      WHERE     TRUNC (transaction_date) BETWEEN p_date_fr
                                                             AND p_date_to
                            AND inventory_item_id = P_item_id
                            AND transaction_type_id = p_trx_id
                            AND organization_id = p_org_id
                            AND SIGN (PRIMARY_QUANTITY) = 1)
             AND line_type_name = 'Inv valuation';
   END IF;

   IF p_t_type = 'I'
   THEN
      SELECT NVL (SUM (base_transaction_value), 0)
        INTO INV_Values
        FROM cst_inv_distribution_v
       WHERE     transaction_id IN
                    (SELECT transaction_id
                       FROM mtl_material_transactions
                      WHERE     TRUNC (transaction_date) BETWEEN p_date_fr
                                                             AND p_date_to
                            AND inventory_item_id = P_item_id
                            AND organization_id = p_org_id
                            AND transaction_type_id = p_trx_id
                            AND SIGN (PRIMARY_QUANTITY) = -1)
             AND line_type_name = 'Inv valuation';
   END IF;

   RETURN INV_Values;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 0;
END;
/