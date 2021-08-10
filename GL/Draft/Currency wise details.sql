/* Formatted on 11/9/2020 1:18:30 PM (QP5 v5.287) */
SELECT msi.segment1 item,
       sob.currency_code warehouse_currency,
       cst_cost_api.get_item_cost (1,
                                   moq.inventory_item_id,
                                   moq.organization_id,
                                   NULL,
                                   NULL)
          cost,
       gl_currency_api.get_rate (sob.currency_code,
                                 'EUR',
                                 SYSDATE,
                                 'Corporate')
          conversion_rate,
         cst_cost_api.get_item_cost (1,
                                     moq.inventory_item_id,
                                     moq.organization_id,
                                     NULL,
                                     NULL)
       * gl_currency_api.get_rate (sob.currency_code,
                                   'EUR',
                                   SYSDATE,
                                   'Corporate')
          cost_in_eur
  FROM gl_sets_of_books sob,
       mtl_organizations mo,
       mtl_onhand_quantities moq,
       mtl_system_items_b msi
 WHERE     mo.set_of_books_name = sob.name
       AND moq.organization_id = mo.organization_id
       AND moq.organization_id = msi.organization_id
       AND moq.inventory_item_id = msi.inventory_item_id
       --AND mo.organization_code = '101';