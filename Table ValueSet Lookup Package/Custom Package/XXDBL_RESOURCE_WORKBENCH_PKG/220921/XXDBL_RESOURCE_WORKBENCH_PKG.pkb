CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_resource_workbench_pkg
AS
/******************************************************************************
   NAME:
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/06/2018  PwC              1. Created this package Body.
******************************************************************************/--
   --
   PROCEDURE insert_row (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_secondary_plan_qty        IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   )
   IS
      l_transaction_id             NUMBER;
      e_rout_err                   EXCEPTION;
      l_recipe_no                  VARCHAR2 (240);
      l_recipe_version             NUMBER;
      l_formula_no                 VARCHAR2 (240);
      l_formula_vers               NUMBER;
      l_routing_no                 VARCHAR2 (240);
      l_routing_vers               NUMBER;
      l_recipe_id                  NUMBER;
      l_recipe_validity_rule_id    NUMBER;
      l_rtn_msg                    VARCHAR2 (4000);
      l_alternate_bom_designator   VARCHAR2 (240);
      l_order_type                 VARCHAR2 (240)  := NULL;
   BEGIN
      IF               --P_REFERENCE_TYPE IN  ('Planned order', 'Work order')
            p_transaction_source = 'MTO'
         OR (    p_transaction_source = 'ASCP'
             AND p_reference_type = 'Planned order'
            )
      THEN
         BEGIN
            SELECT rcp.recipe_id, rul.recipe_validity_rule_id,
                   rcp.recipe_version, rcp.recipe_no
              INTO l_recipe_id, l_recipe_validity_rule_id,
                   l_recipe_version, l_recipe_no
              FROM gmd_recipes rcp, gmd_recipe_validity_rules rul
             WHERE 1 = 1
               AND rcp.recipe_status = '700'
               AND rcp.recipe_id = rul.recipe_id
               AND rcp.recipe_no = p_item_number
               AND ROWNUM = 1;
         /*
         SELECT alternate_bom_designator
           INTO l_alternate_bom_designator
           FROM msc_orders_v
          WHERE transaction_id = p_reference_header_id
            AND alternate_bom_designator IS NOT NULL
            AND ROWNUM = 1;
         --
         SELECT rcp.recipe_id, rul.recipe_validity_rule_id,
                rcp.recipe_version, rcp.recipe_no
           INTO l_recipe_id, l_recipe_validity_rule_id,
                l_recipe_version, l_recipe_no
           FROM gmd_operations_vl op,
                gmd_operation_activities act,
                gmd_operation_resources res,
                fm_rout_hdr rh,
                fm_rout_dtl rl,
                gmd_recipes rcp,
                fm_form_mst frm,
                gmd_recipe_validity_rules rul
          WHERE res.resources = p_vessel_name
            AND res.oprn_line_id = act.oprn_line_id
            AND act.oprn_id = op.oprn_id
            AND op.oprn_id = rl.oprn_id
            AND rl.routing_id = rh.routing_id
            AND rh.routing_status = '700'
            AND rcp.routing_id = rh.routing_id
            AND rcp.formula_id = frm.formula_id
            AND rcp.recipe_status = '700'
            AND rcp.recipe_id = rul.recipe_id
            AND    rcp.recipe_no
                || '/'
                || rcp.recipe_version
                || '/'
                || frm.formula_no
                || '/'
                || frm.formula_vers = l_alternate_bom_designator;
                */
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         --RAISE e_rout_err;
         END;
      END IF;

      --
      IF p_reference_type IN ('Planned order', 'Work order')
      THEN
         IF p_reference_type = 'Work order'
         THEN
            l_order_type := p_transaction_source || ' Batch order';
         ELSE
            l_order_type := p_transaction_source || ' ' || p_reference_type;
         END IF;
      ELSE
         l_order_type := p_reference_type;
      END IF;

      --
      INSERT INTO xxdbl_resource_workbench
                  (resource_workbench_id, organization_id,
                   organization_code, order_header_id, order_number,
                   order_line_id, order_line_no, inventory_item_id,
                   item_number, item_description, article_ticket,
                   product_line, parent_quantity, transaction_quantity,
                   plan_quantity, parent_qty_uom, transaction_qty_uom,
                   reference_type, reference_header_id, reference_line_id,
                   plan_start_date, plan_end_date, vessel_name,
                   recipe_id,
                   recipe_no,
                   recipe_version,
                   recipe_validity_rule_id,
                   special_instruction, status, customer_id,
                   customer_number, customer_name, customer_po_number,
                   batch_no, bacth_id, attribute1, attribute2,
                   attribute3, attribute4, attribute5, attribute6,
                   attribute7, attribute8, attribute9, attribute10,
                   attribute11, attribute12, attribute13,
                   attribute14, attribute15, attribute16,
                   attribute17, attribute18, attribute19,
                   attribute20, last_update_date, last_updated_by,
                   creation_date, created_by, last_update_login,
                   transaction_source, lot_number, secondary_plan_qty,
                   secondary_plan_qty_uom, plan_name, transaction_id,
                   orig_plan_start_date, orig_plan_end_date,
                   parent_quantity_sec, parent_qty_uom_sec
                  )
           VALUES (xxdbl_resource_workbench_s.NEXTVAL,
                                                      -- RESOURCE_WORKBENCH_ID    ,
                                                      p_organization_id,
                   -- ORGANIZATION_ID          ,
                   p_organization_code,          -- ORGANIZATION_CODE        ,
                                       p_order_header_id,
                                                         -- ORDER_HEADER_ID          ,
                                                         p_order_number,
                   -- ORDER_NUMBER             ,
                   p_order_line_id,              -- ORDER_LINE_ID            ,
                                   p_order_line_no,
                                                   -- ORDER_LINE_NO            ,
                                                   p_inventory_item_id,
                   -- INVENTORY_ITEM_ID        ,
                   p_item_number,                -- ITEM_NUMBER              ,
                                 p_item_description,
                                                    -- ITEM_DESCRIPTION         ,
                                                    p_article_ticket,
                   -- ARTICLE_TICKET           ,
                   p_product_line,               -- PRODUCT_LINE             ,
                                  p_parent_quantity,
                                                    -- PARENT_QUANTITY          ,
                                                    p_transaction_quantity,
                   -- TRANSACTION_QUANTITY     ,
                   p_plan_quantity,              -- PLAN_QUANTITY            ,
                                   p_parent_qty_uom,
                                                    -- PARENT_QTY_UOM           ,
                                                    p_transaction_qty_uom,
                   -- TRANSACTION_QTY_UOM      ,
                   l_order_type,                 -- REFERENCE_TYPE           ,
                                p_reference_header_id,
                                                      -- REFERENCE_HEADER_ID      ,
                                                      p_reference_line_id,
                   -- REFERENCE_LINE_ID        ,
                   p_plan_start_date,            -- PLAN_START_DATE          ,
                                     p_plan_end_date,
                                                     -- PLAN_END_DATE            ,
                                                     p_vessel_name,
                   -- VESSEL_NAME              ,
                   NVL (p_recipe_id, l_recipe_id),
                   -- RECIPE_ID                ,
                   NVL (p_recipe_no, l_recipe_no),
                   -- RECIPE_NO                ,
                   NVL (p_recipe_version, l_recipe_version),
                   -- RECIPE_VERSION           ,
                   NVL (p_recipe_validity_rule_id, l_recipe_validity_rule_id),
                   -- RECIPE_VALIDITY_RULE_ID  ,
                   p_special_instruction,        -- SPECIAL_INSTRUCTION      ,
                                         p_status,
                                                  -- STATUS                   ,
                                                  p_customer_id,
                   -- CUSTOMER_ID              ,
                   p_customer_number,            -- CUSTOMER_NUMBER          ,
                                     p_customer_name,
                                                     -- CUSTOMER_NAME            ,
                                                     p_customer_po_number,
                   -- CUSTOMER_PO_NUMBER       ,
                   p_batch_no,                   -- BATCH_NO                 ,
                              p_bacth_id,        -- BACTH_ID                 ,
                                         p_attribute1,
                                                      -- ATTRIBUTE1               ,
                                                      p_attribute2,
                   -- ATTRIBUTE2               ,
                   p_attribute3,                 -- ATTRIBUTE3               ,
                                p_attribute4,    -- ATTRIBUTE4               ,
                                             p_attribute5,
                                                          -- ATTRIBUTE5               ,
                                                          p_attribute6,
                   -- ATTRIBUTE6               ,
                   p_attribute7,                 -- ATTRIBUTE7               ,
                                p_attribute8,    -- ATTRIBUTE8               ,
                                             p_attribute9,
                                                          -- ATTRIBUTE9               ,
                                                          p_attribute10,
                   -- ATTRIBUTE10              ,
                   p_attribute11,                -- ATTRIBUTE11              ,
                                 p_attribute12,  -- ATTRIBUTE12              ,
                                               p_attribute13,
                   -- ATTRIBUTE13              ,
                   p_attribute14,                -- ATTRIBUTE14              ,
                                 p_attribute15,  -- ATTRIBUTE15              ,
                                               p_attribute16,
                   -- ATTRIBUTE16              ,
                   p_attribute17,                -- ATTRIBUTE17              ,
                                 p_attribute18,  -- ATTRIBUTE18              ,
                                               p_attribute19,
                   -- ATTRIBUTE19              ,
                   p_attribute20,                -- ATTRIBUTE20              ,
                                 SYSDATE,        -- LAST_UPDATE_DATE         ,
                                         fnd_global.user_id,
                   -- LAST_UPDATED_BY          ,
                   SYSDATE,                      -- CREATION_DATE            ,
                           fnd_global.user_id,   -- CREATED_BY               ,
                                              fnd_global.login_id,
                   -- LAST_UPDATE_LOGIN
                   p_transaction_source, p_lot_number, p_secondary_plan_qty,
                   p_secondary_plan_qty_uom, p_plan_name, p_transaction_id,
                   p_orig_plan_start_date, p_orig_plan_end_date,
                   p_parent_quantity_sec, p_parent_qty_uom_sec
                  );

      ---- debug_insert ('Manas9:       ' || SQL%ROWCOUNT);
         -- Getting BOM and Resource
      --fnd_file.put_line (fnd_file.LOG,'New Child Order number created: '||l_transaction_id);
      x_rtn_stat := 'S';
      x_rtn_msg := NULL;
   EXCEPTION
      WHEN e_rout_err
      THEN
         l_rtn_msg :=
                'Error to get BOM and Routing for Resource ' || p_vessel_name;
         fnd_file.put_line (fnd_file.LOG, l_rtn_msg);
         x_rtn_stat := 'E';
         x_rtn_msg := l_rtn_msg;
      WHEN OTHERS
      THEN
         l_rtn_msg := 'Unexpected Error to insert data - ' || SQLERRM;
         fnd_file.put_line (fnd_file.LOG, l_rtn_msg);
         x_rtn_stat := 'E';
         x_rtn_msg := l_rtn_msg;
   END insert_row;

   PROCEDURE insert_row_new (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_secondary_plan_qty        IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   )
   IS
      l_transaction_id             NUMBER;
      e_rout_err                   EXCEPTION;
      l_recipe_no                  VARCHAR2 (240);
      l_recipe_version             NUMBER;
      l_formula_no                 VARCHAR2 (240);
      l_formula_vers               NUMBER;
      l_routing_no                 VARCHAR2 (240);
      l_routing_vers               NUMBER;
      l_recipe_id                  NUMBER;
      l_recipe_validity_rule_id    NUMBER;
      l_rtn_msg                    VARCHAR2 (4000);
      l_alternate_bom_designator   VARCHAR2 (240);
      l_order_type                 VARCHAR2 (240)  := NULL;
   BEGIN
      IF               --P_REFERENCE_TYPE IN  ('Planned order', 'Work order')
            p_transaction_source = 'MTO'
         OR (    p_transaction_source = 'ASCP'
             AND p_reference_type = 'Planned order'
            )
      THEN
         BEGIN
            SELECT rcp.recipe_id, rul.recipe_validity_rule_id,
                   rcp.recipe_version, rcp.recipe_no
              INTO l_recipe_id, l_recipe_validity_rule_id,
                   l_recipe_version, l_recipe_no
              FROM gmd_recipes rcp, gmd_recipe_validity_rules rul
             WHERE 1 = 1
               AND rcp.recipe_status = '700'
               AND rcp.recipe_id = rul.recipe_id
               AND rcp.recipe_no = p_item_number
               AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         --RAISE e_rout_err;
         END;
      END IF;

      --
      IF p_reference_type IN ('Planned order', 'Work order')
      THEN
         IF p_reference_type = 'Work order'
         THEN
            l_order_type := p_transaction_source || ' Batch order';
         ELSE
            l_order_type := p_transaction_source || ' ' || p_reference_type;
         END IF;
      ELSE
         l_order_type := p_reference_type;
      END IF;

      --
      INSERT INTO xxdbl_resource_workbench_temp
                  (resource_workbench_id, organization_id,
                   organization_code, order_header_id, order_number,
                   order_line_id, order_line_no, inventory_item_id,
                   item_number, item_description, article_ticket,
                   product_line, parent_quantity, transaction_quantity,
                   plan_quantity, parent_qty_uom, transaction_qty_uom,
                   reference_type, reference_header_id, reference_line_id,
                   plan_start_date, plan_end_date, vessel_name,
                   recipe_id,
                   recipe_no,
                   recipe_version,
                   recipe_validity_rule_id,
                   special_instruction, status, customer_id,
                   customer_number, customer_name, customer_po_number,
                   batch_no, bacth_id, attribute1, attribute2,
                   attribute3, attribute4, attribute5, attribute6,
                   attribute7, attribute8, attribute9, attribute10,
                   attribute11, attribute12, attribute13,
                   attribute14, attribute15, attribute16,
                   attribute17, attribute18, attribute19,
                   attribute20, last_update_date, last_updated_by,
                   creation_date, created_by, last_update_login,
                   transaction_source, lot_number, secondary_plan_qty,
                   secondary_plan_qty_uom, plan_name, transaction_id,
                   orig_plan_start_date, orig_plan_end_date,
                   parent_quantity_sec, parent_qty_uom_sec
                  )
           VALUES (xxdbl_resource_workbench_s.NEXTVAL,
                                                      -- RESOURCE_WORKBENCH_ID    ,
                                                      p_organization_id,
                   -- ORGANIZATION_ID          ,
                   p_organization_code,          -- ORGANIZATION_CODE        ,
                                       p_order_header_id,
                                                         -- ORDER_HEADER_ID          ,
                                                         p_order_number,
                   -- ORDER_NUMBER             ,
                   p_order_line_id,              -- ORDER_LINE_ID            ,
                                   p_order_line_no,
                                                   -- ORDER_LINE_NO            ,
                                                   p_inventory_item_id,
                   -- INVENTORY_ITEM_ID        ,
                   p_item_number,                -- ITEM_NUMBER              ,
                                 p_item_description,
                                                    -- ITEM_DESCRIPTION         ,
                                                    p_article_ticket,
                   -- ARTICLE_TICKET           ,
                   p_product_line,               -- PRODUCT_LINE             ,
                                  p_parent_quantity,
                                                    -- PARENT_QUANTITY          ,
                                                    p_transaction_quantity,
                   -- TRANSACTION_QUANTITY     ,
                   p_plan_quantity,              -- PLAN_QUANTITY            ,
                                   p_parent_qty_uom,
                                                    -- PARENT_QTY_UOM           ,
                                                    p_transaction_qty_uom,
                   -- TRANSACTION_QTY_UOM      ,
                   l_order_type,                 -- REFERENCE_TYPE           ,
                                p_reference_header_id,
                                                      -- REFERENCE_HEADER_ID      ,
                                                      p_reference_line_id,
                   -- REFERENCE_LINE_ID        ,
                   p_plan_start_date,            -- PLAN_START_DATE          ,
                                     p_plan_end_date,
                                                     -- PLAN_END_DATE            ,
                                                     p_vessel_name,
                   -- VESSEL_NAME              ,
                   NVL (p_recipe_id, l_recipe_id),
                   -- RECIPE_ID                ,
                   NVL (p_recipe_no, l_recipe_no),
                   -- RECIPE_NO                ,
                   NVL (p_recipe_version, l_recipe_version),
                   -- RECIPE_VERSION           ,
                   NVL (p_recipe_validity_rule_id, l_recipe_validity_rule_id),
                   -- RECIPE_VALIDITY_RULE_ID  ,
                   p_special_instruction,        -- SPECIAL_INSTRUCTION      ,
                                         p_status,
                                                  -- STATUS                   ,
                                                  p_customer_id,
                   -- CUSTOMER_ID              ,
                   p_customer_number,            -- CUSTOMER_NUMBER          ,
                                     p_customer_name,
                                                     -- CUSTOMER_NAME            ,
                                                     p_customer_po_number,
                   -- CUSTOMER_PO_NUMBER       ,
                   p_batch_no,                   -- BATCH_NO                 ,
                              p_bacth_id,        -- BACTH_ID                 ,
                                         p_attribute1,
                                                      -- ATTRIBUTE1               ,
                                                      p_attribute2,
                   -- ATTRIBUTE2               ,
                   p_attribute3,                 -- ATTRIBUTE3               ,
                                p_attribute4,    -- ATTRIBUTE4               ,
                                             p_attribute5,
                                                          -- ATTRIBUTE5               ,
                                                          p_attribute6,
                   -- ATTRIBUTE6               ,
                   p_attribute7,                 -- ATTRIBUTE7               ,
                                p_attribute8,    -- ATTRIBUTE8               ,
                                             p_attribute9,
                                                          -- ATTRIBUTE9               ,
                                                          p_attribute10,
                   -- ATTRIBUTE10              ,
                   p_attribute11,                -- ATTRIBUTE11              ,
                                 p_attribute12,  -- ATTRIBUTE12              ,
                                               p_attribute13,
                   -- ATTRIBUTE13              ,
                   p_attribute14,                -- ATTRIBUTE14              ,
                                 p_attribute15,  -- ATTRIBUTE15              ,
                                               p_attribute16,
                   -- ATTRIBUTE16              ,
                   p_attribute17,                -- ATTRIBUTE17              ,
                                 p_attribute18,  -- ATTRIBUTE18              ,
                                               p_attribute19,
                   -- ATTRIBUTE19              ,
                   p_attribute20,                -- ATTRIBUTE20              ,
                                 SYSDATE,        -- LAST_UPDATE_DATE         ,
                                         fnd_global.user_id,
                   -- LAST_UPDATED_BY          ,
                   SYSDATE,                      -- CREATION_DATE            ,
                           fnd_global.user_id,   -- CREATED_BY               ,
                                              fnd_global.login_id,
                   -- LAST_UPDATE_LOGIN
                   p_transaction_source, p_lot_number, p_secondary_plan_qty,
                   p_secondary_plan_qty_uom, p_plan_name, p_transaction_id,
                   p_orig_plan_start_date, p_orig_plan_end_date,
                   p_parent_quantity_sec, p_parent_qty_uom_sec
                  );

         -- Getting BOM and Resource
      --fnd_file.put_line (fnd_file.LOG,'New Child Order number created: '||l_transaction_id);
      x_rtn_stat := 'S';
      x_rtn_msg := NULL;
   EXCEPTION
      WHEN e_rout_err
      THEN
         l_rtn_msg :=
                'Error to get BOM and Routing for Resource ' || p_vessel_name;
         fnd_file.put_line (fnd_file.LOG, l_rtn_msg);
         x_rtn_stat := 'E';
         x_rtn_msg := l_rtn_msg;
      WHEN OTHERS
      THEN
         l_rtn_msg := 'Unexpected Error to insert data - ' || SQLERRM;
         fnd_file.put_line (fnd_file.LOG, l_rtn_msg);
         x_rtn_stat := 'E';
         x_rtn_msg := l_rtn_msg;
   END insert_row_new;

   PROCEDURE ascp_main_prc (
      x_errbuff           OUT      VARCHAR2,
      x_retcode           OUT      VARCHAR2,
      p_organization_id   IN       NUMBER,
      --p_order_type        IN       VARCHAR2,
      p_plan_name         IN       VARCHAR2,
      p_transaction_id    IN       NUMBER
   )
   IS
      e_usr_exception       EXCEPTION;
      l_bal_quantity        NUMBER;
      l_order_quantity      NUMBER;
      l_int                 INTEGER;
      l_bal_kg_quantity     NUMBER;
      l_tot_con_quantity    NUMBER;
      l_con_quantity        NUMBER;
      l_pkg_qty             NUMBER;
      l_rtn_stat            VARCHAR2 (100);
      l_ins_row             VARCHAR2 (1);
      l_rtn_msg             VARCHAR2 (4000);
      l_conv_rate           NUMBER;
      l_count               NUMBER;
      l_quantity_sec        NUMBER;
      l_uom_sec             VARCHAR2 (10);
      ln_kg_per_pkg         NUMBER;
      l_conv_factor         NUMBER;
      l_error_message_con   VARCHAR2 (4000);
      l_new_count           NUMBER          := 0;
   BEGIN
      fnd_file.put_line
                       (fnd_file.LOG,
                        'Initiate XXDBL_RESOURCE_WORKBENCH_PKG.ASCP_MAIN_PRC'
                       );
      fnd_file.put_line (fnd_file.LOG,
                         'Parent Order Number: ' || p_transaction_id
                        );
      fnd_file.put_line (fnd_file.LOG,
                         '------------------------------------------------'
                        );

      --
      -- Populate archive table
      BEGIN
         SELECT COUNT (1)
           INTO l_new_count
           FROM (SELECT DISTINCT sup.organization_id, sup.order_number,
                                 sup.item_segments, sup.uom_code,
                                 sup.order_type_text, sup.transaction_id,
                                 CASE
                                    WHEN NVL
                                           (sup.implement_quantity_rate,
                                            0
                                           ) <> 0
                                       THEN sup.implement_quantity_rate
                                    ELSE sup.quantity
                                 END quantity,
                                 msib.inventory_item_id item_id,
                                 msib.description item_desc,
                                 micv.segment1 product_line,
                                 micv.segment2 article_ticket,
                                 msib.attribute4
                                                /*msib.attribute1*/
                                 kg_per_pkg, mp.organization_code orgn_code,
                                 sup.compile_designator plan_name,
                                 sup.new_start_date suggested_st_dt,
                                 sup.new_due_date suggested_ed_dt
                            FROM msc_orders_v@prod_to_ascp /*ebscrp_to_ascpuat*/ sup,
                                 mtl_system_items_kfv msib,
                                 mtl_item_categories_v micv,
                                 fnd_lookup_values_vl lkp,
                                 mtl_parameters mp
                           WHERE sup.transaction_id =
                                    NVL (p_transaction_id, sup.transaction_id)
                             AND sup.organization_id =
                                    NVL (p_organization_id,
                                         sup.organization_id
                                        )
                             AND sup.order_type_text = 'Planned order'
                             AND sup.compile_designator =
                                     NVL (p_plan_name, sup.compile_designator)
                             AND sup.action = 'Release'
                             AND   NVL (sup.implement_quantity_rate, 0)
                                 + NVL (sup.quantity, 0) > 0
                             AND sup.item_segments = msib.segment1
                             AND sup.organization_id = msib.organization_id
                             AND msib.inventory_item_id =
                                                        micv.inventory_item_id
                             AND msib.organization_id = micv.organization_id
                             AND micv.category_set_name = 'DBL_SALES_PLAN_CAT'
                             AND micv.segment1 = 'SEWING THREAD'
                             AND lkp.lookup_type =
                                              'XXDBL_DYEHOUSE_ARTICLE_TKT_LKP'
                             -- Added By Manas on 14-Jan-2020 Starts
                             AND NVL (lkp.tag, 'N') = 'N'
                             -- Added By Manas on 14-Jan-2020 Ends
                             AND lkp.description = micv.segment1
                             AND lkp.meaning = micv.segment2
                             AND sup.organization_id = mp.organization_id);
      EXCEPTION
         WHEN OTHERS
         THEN
            l_new_count := 0;
      END;

      IF l_new_count > 0
      THEN
         ascp_archive_prc;

         --
         -- Cursor on planned orders
         FOR c_order_csr IN
            (SELECT DISTINCT sup.organization_id, sup.order_number,
                             sup.item_segments, sup.uom_code,
                             sup.order_type_text, sup.transaction_id,
                             CASE
                                WHEN NVL
                                       (sup.implement_quantity_rate,
                                        0
                                       ) <> 0
                                   THEN sup.implement_quantity_rate
                                ELSE sup.quantity
                             END quantity,
                             msib.inventory_item_id item_id,
                             msib.description item_desc,
                             micv.segment1 product_line,
                             micv.segment2 article_ticket,
                             msib.attribute4 /*msib.attribute1*/ kg_per_pkg,
                             mp.organization_code orgn_code,
                             sup.compile_designator plan_name,
                             sup.new_start_date suggested_st_dt,
                             sup.new_due_date suggested_ed_dt
                        FROM msc_orders_v@prod_to_ascp /*ebscrp_to_ascpuat*/ sup,
                             mtl_system_items_kfv msib,
                             mtl_item_categories_v micv,
                             fnd_lookup_values_vl lkp,
                             mtl_parameters mp
                       WHERE sup.transaction_id =
                                    NVL (p_transaction_id, sup.transaction_id)
                         AND sup.organization_id =
                                  NVL (p_organization_id, sup.organization_id)
                         /*
                         AND (   (    p_order_type IS NULL
                                  AND sup.order_type_text IN
                                                 ('Planned order', 'Work order')
                                 )
                              OR sup.order_type_text = p_order_type
                             )
                         */
                         AND sup.order_type_text = 'Planned order'
                         AND sup.compile_designator =
                                     NVL (p_plan_name, sup.compile_designator)
                         AND sup.action = 'Release'
                         AND   NVL (sup.implement_quantity_rate, 0)
                             + NVL (sup.quantity, 0) > 0
                         AND sup.item_segments = msib.segment1
                         AND sup.organization_id = msib.organization_id
                         AND msib.inventory_item_id = micv.inventory_item_id
                         AND msib.organization_id = micv.organization_id
                         AND micv.category_set_name = 'DBL_SALES_PLAN_CAT'
                                                                        /*IN (
                               SELECT mdcsfv.category_set_name
                                 FROM mtl_default_category_sets_fk_v mdcsfv
                                WHERE 1 = 1
                                  AND mdcsfv.functional_area_desc = 'Planning')*/
                         --= 'Planning'
                         AND micv.segment1 = 'SEWING THREAD'
                         AND lkp.lookup_type =
                                              'XXDBL_DYEHOUSE_ARTICLE_TKT_LKP'
                         -- Added By Manas on 14-Jan-2020 Starts
                         AND NVL (lkp.tag, 'N') = 'N'
                         -- Added By Manas on 14-Jan-2020 Ends
                         AND lkp.description = micv.segment1
                         AND lkp.meaning = micv.segment2
                         AND sup.organization_id = mp.organization_id)
         LOOP
            fnd_file.put_line
                (fnd_file.LOG,
                    'Start Creation of child order for Parent Order number: '
                 || c_order_csr.transaction_id
                 || ' and Item Number: '
                 || c_order_csr.item_segments
                );

            --
            -- Deriving KG/Pkg
            BEGIN
               SELECT kg_per_pkg
                 INTO ln_kg_per_pkg
                 FROM xxdbl_dyehouse_routing_hdr
                WHERE product_line = c_order_csr.product_line
                  AND article_ticket = c_order_csr.article_ticket;
            EXCEPTION
               WHEN OTHERS
               THEN
                  ln_kg_per_pkg := NULL;
            END;

            --
            BEGIN
               IF c_order_csr.order_type_text = 'Planned order'
               THEN
                  SELECT COUNT (*)
                    INTO l_count
                    FROM xxdbl_dyehouse_routing_hdr hdr,
                         xxdbl_dyehouse_routing_chart dtl
                   WHERE hdr.hdr_id = dtl.hdr_id
                     AND hdr.product_line = c_order_csr.product_line
                     AND hdr.article_ticket = c_order_csr.article_ticket;

                  --AND hdr.kg_per_pkg = TO_NUMBER (c_order_csr.kg_per_pkg);

                  --
                  IF l_count = 0
                  THEN
                     fnd_file.put_line
                           (fnd_file.LOG,
                               'Routing Chart not found for Article Ticket: '
                            || c_order_csr.article_ticket
                            || ' and Kg/Pkg: '
                            || ln_kg_per_pkg
                           );
                     RAISE e_usr_exception;
                  END IF;

                  --
                  IF c_order_csr.uom_code = 'CON'
                  THEN
                     -- Added By Manas on 07-Aug-2019 Starts
                     xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                     IF l_conv_factor < 0
                     THEN
                        fnd_file.put_line (fnd_file.LOG, l_error_message_con);
                        raise_application_error (-20001, l_error_message_con);
                     END IF;

                     l_bal_quantity := l_conv_factor * c_order_csr.quantity;
                     /*l_bal_quantity :=
                     xxdbl_resource_workbench_pkg.mtl_uom_conversion_qty
                                         (p_item_id       => c_order_csr.item_id,
                                          p_from_qty      => c_order_csr.quantity,
                                          p_from_um       => 'CON',
                                          p_to_um         => 'KG'
                                         );*/

                     -- Added By Manas on 07-Aug-2019 Ends
                     --
                     l_pkg_qty := (l_bal_quantity / NVL (ln_kg_per_pkg, 1));

                     SELECT FLOOR (l_bal_quantity / NVL (ln_kg_per_pkg, 1))
                       INTO l_int
                       FROM DUAL;

                     --
                     IF l_pkg_qty > l_int
                     THEN
                        l_pkg_qty := l_int + 1;
                     END IF;

                     --
                     l_bal_kg_quantity := l_pkg_qty * ln_kg_per_pkg;
                     --
                     xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                         (p_organization_id,
                                                          c_order_csr.item_id,
                                                          l_error_message_con,
                                                          l_conv_factor
                                                         );

                     IF l_conv_factor < 0
                     THEN
                        fnd_file.put_line (fnd_file.LOG, l_error_message_con);
                        raise_application_error (-20003, l_error_message_con);
                     ELSE
                        l_conv_rate := l_conv_factor;
                     END IF;

                     /*BEGIN
                        SELECT conversion_rate
                          INTO l_conv_rate
                          FROM mtl_uom_class_conversions
                         WHERE inventory_item_id = c_order_csr.item_id
                           AND from_uom_code = 'NO'
                           AND to_uom_code = 'KG';
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_conv_rate := 1;
                     END;*/

                     --
                     l_tot_con_quantity := l_bal_kg_quantity / l_conv_rate;

                     --
                     -- Added by Manas on 08-Jul-2019 Starts
                     /*SELECT FLOOR (l_tot_con_quantity)
                       INTO l_int
                       FROM DUAL;*/
                     SELECT FLOOR (l_tot_con_quantity)
                       INTO l_int
                       FROM DUAL;

                     -- Added by Manas on 08-Jul-2019 Ends

                     --
                     IF l_tot_con_quantity > l_int
                     THEN
                        l_tot_con_quantity := l_int;
                     END IF;
                  --
                  ELSE
                     --
                     l_bal_kg_quantity := c_order_csr.quantity;
                  END IF;
               ELSE
                  -- for Work Order
                  l_bal_kg_quantity := 0;
               END IF;

               --
               WHILE l_bal_kg_quantity > 0
               LOOP
                  FOR c_vessel_csr IN
                     (SELECT   dtl.*
                          FROM xxdbl_dyehouse_routing_hdr hdr,
                               xxdbl_dyehouse_routing_chart dtl
                         WHERE hdr.hdr_id = dtl.hdr_id
                           AND hdr.product_line = c_order_csr.product_line
                           AND hdr.article_ticket = c_order_csr.article_ticket
                      --  AND hdr.kg_per_pkg = ln_kg_per_pkg
                      --         TO_NUMBER
                      --                (c_order_csr.kg_per_pkg)
                      ORDER BY to_weight DESC)
                  LOOP
                     l_ins_row := 'F';

                     --
                     IF l_bal_kg_quantity >= c_vessel_csr.from_weight
                     THEN
                        IF l_bal_kg_quantity <= c_vessel_csr.to_weight
                        THEN
                           l_order_quantity := l_bal_kg_quantity;

                           --
                           IF c_order_csr.uom_code = 'CON'
                           THEN
                              l_con_quantity :=
                                               l_order_quantity / l_conv_rate;

                              --
                              SELECT FLOOR (l_con_quantity)
                                INTO l_int
                                FROM DUAL;

                              --
                              IF l_con_quantity > l_int
                              THEN
                                 l_con_quantity := l_int;
                              END IF;

                              --
                              l_tot_con_quantity :=
                                           l_tot_con_quantity - l_con_quantity;
                           END IF;

                           --
                           l_bal_kg_quantity := 0;
                           l_ins_row := 'T';
                        ELSE
                           l_order_quantity := c_vessel_csr.to_weight;
                           l_bal_kg_quantity :=
                                         l_bal_kg_quantity - l_order_quantity;

                           --
                           IF c_order_csr.uom_code = 'CON'
                           THEN
                              l_con_quantity :=
                                               l_order_quantity / l_conv_rate;

                              --
                              SELECT FLOOR (l_con_quantity)
                                INTO l_int
                                FROM DUAL;

                              --
                              IF l_con_quantity > l_int
                              THEN
                                 l_con_quantity := l_int;
                              END IF;

                              --
                              l_tot_con_quantity :=
                                           l_tot_con_quantity - l_con_quantity;
                           END IF;

                           --
                           l_ins_row := 'T';
                        END IF;

                        --
                        IF l_ins_row = 'T'
                        THEN
                           IF     c_order_csr.uom_code = 'CON'
                              AND l_bal_kg_quantity <= 0
                              AND l_tot_con_quantity > 0
                           THEN
                              l_con_quantity :=
                                          l_con_quantity + l_tot_con_quantity;
                              l_order_quantity :=
                                                 -- Manas on 22-Aug-2019
                                                 /*mtl_uom_conversion_qty
                                                              (p_item_id       => c_order_csr.item_id,
                                                               p_from_qty      => l_con_quantity,
                                                               p_from_um       => 'CON',
                                                               p_to_um         => 'KG'
                                                              );*/
                                                 l_con_quantity * l_conv_rate;
                           END IF;

                           --
                           l_rtn_stat := 'S';

                           --
                           IF c_order_csr.uom_code = 'CON'
                           THEN
                              -- Added By Manas on 22-Aug-2019
                                 /*SELECT mtl_uom_conversion_qty
                                                (p_item_id       => c_order_csr.item_id,
                                                 p_from_qty      => c_order_csr.quantity,
                                                 p_from_um       => 'CON',
                                                 p_to_um         => 'KG'
                                                )
                                   INTO l_quantity_sec
                                   FROM DUAL;*/
                              l_quantity_sec :=
                                           c_order_csr.quantity * l_conv_rate;
                              l_uom_sec := 'KG';
                              insert_row
                                 (p_organization_id             => c_order_csr.organization_id,
                                  p_organization_code           => c_order_csr.orgn_code,
                                  p_order_number                => c_order_csr.order_number,
                                  p_inventory_item_id           => c_order_csr.item_id,
                                  p_item_number                 => c_order_csr.item_segments,
                                  p_item_description            => c_order_csr.item_desc,
                                  p_article_ticket              => c_order_csr.article_ticket,
                                  p_product_line                => c_order_csr.product_line,
                                  p_parent_quantity             => c_order_csr.quantity,
                                  p_transaction_quantity        => CEIL
                                                                      (l_con_quantity
                                                                      ),
                                  --l_order_quantity,
                                  p_plan_quantity               => CEIL
                                                                      (l_con_quantity
                                                                      ),
                                  --l_order_quantity,
                                  p_parent_qty_uom              => c_order_csr.uom_code,
                                  p_transaction_qty_uom         => 'CON',
                                  --'KG',
                                  p_reference_type              => c_order_csr.order_type_text,
                                  p_reference_header_id         => c_order_csr.transaction_id,
                                  p_plan_start_date             => NVL
                                                                      (c_order_csr.suggested_st_dt,
                                                                       SYSDATE
                                                                      ),
                                  p_plan_end_date               => NVL
                                                                      (c_order_csr.suggested_ed_dt,
                                                                         SYSDATE
                                                                       + 90
                                                                      ),
                                  p_vessel_name                 => c_vessel_csr.resource_name,
                                  p_transaction_source          => 'ASCP',
                                  p_secondary_plan_qty          => l_order_quantity,
                                  p_secondary_plan_qty_uom      => 'KG',
                                  p_plan_name                   => c_order_csr.plan_name,
                                  p_transaction_id              => c_order_csr.transaction_id,
                                  p_orig_plan_start_date        => NVL
                                                                      (c_order_csr.suggested_st_dt,
                                                                       SYSDATE
                                                                      ),
                                  p_orig_plan_end_date          => NVL
                                                                      (c_order_csr.suggested_ed_dt,
                                                                         SYSDATE
                                                                       + 90
                                                                      ),
                                  p_parent_quantity_sec         => l_quantity_sec,
                                  p_parent_qty_uom_sec          => l_uom_sec,
                                  x_rtn_stat                    => l_rtn_stat,
                                  x_rtn_msg                     => l_rtn_msg
                                 );
                           ELSE
                              -- Added By Manas on 22-Aug-2019
                                 /*SELECT mtl_uom_conversion_qty
                                                (p_item_id       => c_order_csr.item_id,
                                                 p_from_qty      => c_order_csr.quantity,
                                                 p_from_um       => 'KG',
                                                 p_to_um         => 'CON'
                                                )
                                   INTO l_quantity_sec
                                   FROM DUAL;*/
                              l_quantity_sec :=
                                           c_order_csr.quantity / l_conv_rate;
                              l_uom_sec := 'CON';
                              insert_row
                                 (p_organization_id           => c_order_csr.organization_id,
                                  p_organization_code         => c_order_csr.orgn_code,
                                  p_order_number              => c_order_csr.order_number,
                                  p_inventory_item_id         => c_order_csr.item_id,
                                  p_item_number               => c_order_csr.item_segments,
                                  p_item_description          => c_order_csr.item_desc,
                                  p_article_ticket            => c_order_csr.article_ticket,
                                  p_product_line              => c_order_csr.product_line,
                                  p_parent_quantity           => c_order_csr.quantity,
                                  p_transaction_quantity      => CEIL
                                                                    (l_order_quantity
                                                                    ),
                                  p_plan_quantity             => CEIL
                                                                    (l_order_quantity
                                                                    ),
                                  p_parent_qty_uom            => c_order_csr.uom_code,
                                  p_transaction_qty_uom       => 'KG',
                                  p_reference_type            => c_order_csr.order_type_text,
                                  p_reference_header_id       => c_order_csr.transaction_id,
                                  p_plan_start_date           => NVL
                                                                    (c_order_csr.suggested_st_dt,
                                                                     SYSDATE
                                                                    ),
                                  p_plan_end_date             => NVL
                                                                    (c_order_csr.suggested_ed_dt,
                                                                       SYSDATE
                                                                     + 90
                                                                    ),
                                  p_vessel_name               => c_vessel_csr.resource_name,
                                  p_transaction_source        => 'ASCP',
                                  p_plan_name                 => c_order_csr.plan_name,
                                  p_transaction_id            => c_order_csr.transaction_id,
                                  p_orig_plan_start_date      => NVL
                                                                    (c_order_csr.suggested_st_dt,
                                                                     SYSDATE
                                                                    ),
                                  p_orig_plan_end_date        => NVL
                                                                    (c_order_csr.suggested_ed_dt,
                                                                       SYSDATE
                                                                     + 90
                                                                    ),
                                  p_parent_quantity_sec       => l_quantity_sec,
                                  p_parent_qty_uom_sec        => l_uom_sec,
                                  x_rtn_stat                  => l_rtn_stat,
                                  x_rtn_msg                   => l_rtn_msg
                                 );
                           END IF;

                           --
                           IF l_rtn_stat <> 'S'
                           THEN
                              RAISE e_usr_exception;
                           END IF;

                           --
                           EXIT;
                        END IF;
                     END IF;
                  END LOOP c_vessel_csr;
               --
               END LOOP;

               --
               IF c_order_csr.order_type_text = 'Work order'
               THEN
                  l_rtn_stat := 'S';

                  IF c_order_csr.uom_code = 'KG'
                  THEN
                     -- Added By Manas 22-Aug-2019
                     xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                     IF l_conv_factor < 0
                     THEN
                        fnd_file.put_line (fnd_file.LOG, l_error_message_con);
                        raise_application_error (-20003, l_error_message_con);
                     ELSE
                        l_conv_rate := l_conv_factor;
                     END IF;

                     l_quantity_sec := c_order_csr.quantity / l_conv_factor;
                     /*SELECT mtl_uom_conversion_qty
                                             (p_item_id       => c_order_csr.item_id,
                                              p_from_qty      => c_order_csr.quantity,
                                              p_from_um       => 'KG',
                                              p_to_um         => 'CON'
                                             )
                       INTO l_quantity_sec
                       FROM DUAL;*/
                     l_uom_sec := 'CON';
                  ELSE
                     -- Added By Manas 22-Aug-2019
                     xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                     IF l_conv_factor < 0
                     THEN
                        fnd_file.put_line (fnd_file.LOG, l_error_message_con);
                        raise_application_error (-20003, l_error_message_con);
                     ELSE
                        l_conv_rate := l_conv_factor;
                     END IF;

                     l_quantity_sec := c_order_csr.quantity * l_conv_factor;
                     /*SELECT mtl_uom_conversion_qty
                                             (p_item_id       => c_order_csr.item_id,
                                              p_from_qty      => c_order_csr.quantity,
                                              p_from_um       => 'CON',
                                              p_to_um         => 'KG'
                                             )
                       INTO l_quantity_sec
                       FROM DUAL;*/
                     l_uom_sec := 'KG';
                  END IF;

                  insert_row
                     (p_organization_id           => c_order_csr.organization_id,
                      p_organization_code         => c_order_csr.orgn_code,
                      p_order_number              => c_order_csr.order_number,
                      p_inventory_item_id         => c_order_csr.item_id,
                      p_item_number               => c_order_csr.item_segments,
                      p_item_description          => c_order_csr.item_desc,
                      p_article_ticket            => c_order_csr.article_ticket,
                      p_product_line              => c_order_csr.product_line,
                      p_parent_quantity           => c_order_csr.quantity,
                      p_transaction_quantity      => CEIL
                                                         (c_order_csr.quantity),
                      p_plan_quantity             => CEIL
                                                         (c_order_csr.quantity),
                      p_parent_qty_uom            => c_order_csr.uom_code,
                      p_transaction_qty_uom       => c_order_csr.uom_code,
                      p_reference_type            => c_order_csr.order_type_text,
                      p_reference_header_id       => c_order_csr.transaction_id,
                      p_plan_start_date           => NVL
                                                        (c_order_csr.suggested_st_dt,
                                                         SYSDATE
                                                        ),
                      p_plan_end_date             => NVL
                                                        (c_order_csr.suggested_ed_dt,
                                                         SYSDATE + 90
                                                        ),
                      p_vessel_name               => NULL,
                      p_transaction_source        => 'ASCP',
                      p_plan_name                 => c_order_csr.plan_name,
                      p_transaction_id            => c_order_csr.transaction_id,
                      p_orig_plan_start_date      => NVL
                                                        (c_order_csr.suggested_st_dt,
                                                         SYSDATE
                                                        ),
                      p_orig_plan_end_date        => NVL
                                                        (c_order_csr.suggested_ed_dt,
                                                         SYSDATE + 90
                                                        ),
                      p_parent_quantity_sec       => l_quantity_sec,
                      p_parent_qty_uom_sec        => l_uom_sec,
                      x_rtn_stat                  => l_rtn_stat,
                      x_rtn_msg                   => l_rtn_msg
                     );

                  IF l_rtn_stat <> 'S'
                  THEN
                     RAISE e_usr_exception;
                  END IF;
               END IF;

               --
               -- Update parent order
               UPDATE msc_supplies@prod_to_ascp          /*ebscrp_to_ascpuat*/
                  SET implemented_quantity = new_order_quantity
                -- ACTION = 'None'
               WHERE  transaction_id = c_order_csr.transaction_id;

               UPDATE msc_supplies@prod_to_ascp          /*ebscrp_to_ascpuat*/
                  SET new_order_quantity = 0
                -- ACTION = 'None'
               WHERE  transaction_id = c_order_csr.transaction_id;

               --
               COMMIT;
            EXCEPTION
               WHEN e_usr_exception
               THEN
                  ROLLBACK;
                  fnd_file.put_line (fnd_file.LOG,
                                     'Deleted all the child plan order'
                                    );
               WHEN OTHERS
               THEN
                  ROLLBACK;
                  fnd_file.put_line
                          (fnd_file.LOG,
                              'Unexpected Error to create child plan order- '
                           || SQLERRM
                          );
            END;
         END LOOP c_order_csr;
      ELSE
         fnd_file.put_line (fnd_file.LOG, 'There is no New Data for Upload ');
      END IF;
   END ascp_main_prc;

   -- Added By Manas on 04-Oct-2018 Starts
   PROCEDURE ascp_inline_prc (
      p_organization_id     IN   NUMBER,
      p_plan_name           IN   VARCHAR2,
      p_transaction_id      IN   NUMBER,
      p_order_number        IN   VARCHAR2,
      p_quantity            IN   NUMBER,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   )
   IS
      e_usr_exception       EXCEPTION;
      l_bal_quantity        NUMBER;
      l_order_quantity      NUMBER;
      l_int                 INTEGER;
      l_bal_kg_quantity     NUMBER;
      l_tot_con_quantity    NUMBER;
      l_con_quantity        NUMBER;
      l_pkg_qty             NUMBER;
      l_rtn_stat            VARCHAR2 (100);
      l_ins_row             VARCHAR2 (1);
      l_rtn_msg             VARCHAR2 (4000);
      l_conv_rate           NUMBER;
      l_count               NUMBER;
      l_delete_count        NUMBER          := 0;
      l_quantity_sec        NUMBER;
      l_uom_sec             VARCHAR2 (10);
      ln_kg_per_pkg         NUMBER;
      l_conv_factor         NUMBER;
      l_error_message_con   VARCHAR2 (4000);
   BEGIN
      fnd_file.put_line
                       (fnd_file.LOG,
                        'Initiate XXDBL_RESOURCE_WORKBENCH_PKG.ASCP_MAIN_PRC'
                       );
      fnd_file.put_line (fnd_file.LOG,
                         'Parent Order Number: ' || p_transaction_id
                        );
      fnd_file.put_line (fnd_file.LOG,
                         '------------------------------------------------'
                        );

      -- Cursor on planned orders
      FOR c_order_csr IN
         (SELECT DISTINCT sup.organization_id, sup.order_number,
                          sup.item_number item_segments,
                          sup.parent_qty_uom uom_code,
                          sup.reference_type order_type_text,
                          NULL transaction_id, p_quantity quantity,
                          msib.inventory_item_id item_id,
                          msib.description item_desc,
                          micv.segment1 product_line,
                          micv.segment2 article_ticket,
                          msib.attribute4 /*msib.attribute1*/ kg_per_pkg,
                          mp.organization_code orgn_code, NULL plan_name,
                          sup.parent_quantity, sup.parent_quantity_sec,
                          sup.parent_qty_uom_sec, sup.orig_plan_start_date,
                          sup.orig_plan_end_date
                     FROM xxdbl_rw_headers sup,
                          mtl_system_items_kfv msib,
                          mtl_item_categories_v micv,
                          fnd_lookup_values_vl lkp,
                          mtl_parameters mp
                    WHERE 1 = 1
                      AND sup.organization_id =
                                  NVL (p_organization_id, sup.organization_id)
                      AND sup.order_number =
                                        NVL (p_order_number, sup.order_number)
                      AND sup.item_number = msib.segment1
                      AND sup.organization_id = msib.organization_id
                      AND msib.inventory_item_id = micv.inventory_item_id
                      AND msib.organization_id = micv.organization_id
                      AND micv.category_set_name = 'DBL_SALES_PLAN_CAT' /*IN (
                            SELECT mdcsfv.category_set_name
                              FROM mtl_default_category_sets_fk_v mdcsfv
                             WHERE 1 = 1
                               AND mdcsfv.functional_area_desc = 'Planning')*/
                      --= 'Planning'
                      AND micv.segment1 = 'SEWING THREAD'
                      AND lkp.lookup_type = 'XXDBL_DYEHOUSE_ARTICLE_TKT_LKP'
                      AND lkp.description = micv.segment1
                      AND lkp.meaning = micv.segment2
                      AND sup.organization_id = mp.organization_id
                      AND msib.inventory_item_id =
                             NVL (p_inventory_item_id, msib.inventory_item_id))
      LOOP
         ---- debug_insert ('l_delete_count');
         IF l_delete_count = 0
         THEN
            --
            -- Populate archive table
            ascp_inline_archive_prc (p_plan_name,
                                     p_transaction_id,
                                     p_order_number,
                                     p_inventory_item_id
                                    );
            --
            l_delete_count := 1;
         END IF;

         fnd_file.put_line
                 (fnd_file.LOG,
                     'Start Creation of child order for Parent Order number: '
                  || c_order_csr.transaction_id
                 );

         BEGIN
            SELECT kg_per_pkg
              INTO ln_kg_per_pkg
              FROM xxdbl_dyehouse_routing_hdr
             WHERE product_line = c_order_csr.product_line
               AND article_ticket = c_order_csr.article_ticket;
         EXCEPTION
            WHEN OTHERS
            THEN
               ln_kg_per_pkg := NULL;
         END;

         --
         BEGIN
            IF c_order_csr.order_type_text LIKE '%Planned order%'
            THEN
               ---- debug_insert ('Planned order');
               SELECT COUNT (*)
                 INTO l_count
                 FROM xxdbl_dyehouse_routing_hdr hdr,
                      xxdbl_dyehouse_routing_chart dtl
                WHERE hdr.hdr_id = dtl.hdr_id
                  AND hdr.product_line = c_order_csr.product_line
                  AND hdr.article_ticket = c_order_csr.article_ticket;

               --  AND hdr.kg_per_pkg = TO_NUMBER (c_order_csr.kg_per_pkg);

               --
               IF l_count = 0
               THEN
                  ---- debug_insert ('l_count = 0');
                  fnd_file.put_line
                          (fnd_file.LOG,
                           'Routing Chart not found fot this Order Number!!!'
                          );
                  RAISE e_usr_exception;
               END IF;

               --
               IF c_order_csr.uom_code = 'CON'
               THEN
                  ---- debug_insert ('c_order_csr.uom_code = CON');
                  -- Added By Manas on 07-Aug-2019 Starts
                  xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                  IF l_conv_factor < 0
                  THEN
                     fnd_file.put_line (fnd_file.LOG, l_error_message_con);
                     raise_application_error (-20002, l_error_message_con);
                  END IF;

                  l_bal_quantity := l_conv_factor * c_order_csr.quantity;
                  /*l_bal_quantity :=
                  xxdbl_resource_workbench_pkg.mtl_uom_conversion_qty
                                      (p_item_id       => c_order_csr.item_id,
                                       p_from_qty      => c_order_csr.quantity,
                                       p_from_um       => 'CON',
                                       p_to_um         => 'KG'
                                      );*/

                  -- Added By Manas on 07-Aug-2019 Ends
                  --
                  l_pkg_qty := (l_bal_quantity / NVL (ln_kg_per_pkg, 1));

                  SELECT FLOOR (l_bal_quantity / NVL (ln_kg_per_pkg, 1))
                    INTO l_int
                    FROM DUAL;

                  --
                  IF l_pkg_qty > l_int
                  THEN
                     l_pkg_qty := l_int + 1;
                  END IF;

                  --
                  l_bal_kg_quantity := l_pkg_qty * ln_kg_per_pkg;
                  --
                  xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                         (p_organization_id,
                                                          c_order_csr.item_id,
                                                          l_error_message_con,
                                                          l_conv_factor
                                                         );

                  IF l_conv_factor < 0
                  THEN
                     fnd_file.put_line (fnd_file.LOG, l_error_message_con);
                     raise_application_error (-20004, l_error_message_con);
                  ELSE
                     l_conv_rate := l_conv_factor;
                  END IF;

                  /*BEGIN
                     SELECT conversion_rate
                       INTO l_conv_rate
                       FROM mtl_uom_class_conversions
                      WHERE inventory_item_id = c_order_csr.item_id
                        AND from_uom_code = 'NO'
                        AND to_uom_code = 'KG';
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_conv_rate := 1;
                  END;*/

                  --
                  l_tot_con_quantity := l_bal_kg_quantity / l_conv_rate;

                  --
                  SELECT FLOOR (l_tot_con_quantity)
                    INTO l_int
                    FROM DUAL;

                  --
                  IF l_tot_con_quantity > l_int
                  THEN
                     l_tot_con_quantity := l_int;
                  END IF;
               --
               ELSE
                  --
                  l_bal_kg_quantity := c_order_csr.quantity;
               END IF;
            ELSE
               ---- debug_insert ('c_order_csr.uom_code = KG');
               -- for Work Order
               l_bal_kg_quantity := 0;
            END IF;

            ---- debug_insert ('l_bal_kg_quantity:    ' || l_bal_kg_quantity);

            --
            WHILE l_bal_kg_quantity > 0
            LOOP
               FOR c_vessel_csr IN (SELECT   dtl.*
                                        FROM xxdbl_dyehouse_routing_hdr hdr,
                                             xxdbl_dyehouse_routing_chart dtl
                                       WHERE hdr.hdr_id = dtl.hdr_id
                                         AND hdr.product_line =
                                                      c_order_csr.product_line
                                         AND hdr.article_ticket =
                                                    c_order_csr.article_ticket
                                    --AND hdr.kg_per_pkg =
                                    --       TO_NUMBER
                                    --              (c_order_csr.kg_per_pkg)
                                    ORDER BY to_weight DESC)
               LOOP
                  l_ins_row := 'F';

                  --
                  IF l_bal_kg_quantity >= c_vessel_csr.from_weight
                  THEN
                     IF l_bal_kg_quantity <= c_vessel_csr.to_weight
                     THEN
                        l_order_quantity := l_bal_kg_quantity;

                        --
                        IF c_order_csr.uom_code = 'CON'
                        THEN
                           l_con_quantity := l_order_quantity / l_conv_rate;

                           --
                           SELECT FLOOR (l_con_quantity)
                             INTO l_int
                             FROM DUAL;

                           --
                           IF l_con_quantity > l_int
                           THEN
                              l_con_quantity := l_int;
                           END IF;

                           --
                           l_tot_con_quantity :=
                                           l_tot_con_quantity - l_con_quantity;
                        END IF;

                        --
                        l_bal_kg_quantity := 0;
                        l_ins_row := 'T';
                     ELSE
                        l_order_quantity := c_vessel_csr.to_weight;
                        l_bal_kg_quantity :=
                                         l_bal_kg_quantity - l_order_quantity;

                        --
                        IF c_order_csr.uom_code = 'CON'
                        THEN
                           l_con_quantity := l_order_quantity / l_conv_rate;

                           --
                           SELECT FLOOR (l_con_quantity)
                             INTO l_int
                             FROM DUAL;

                           --
                           IF l_con_quantity > l_int
                           THEN
                              l_con_quantity := l_int;
                           END IF;

                           --
                           l_tot_con_quantity :=
                                           l_tot_con_quantity - l_con_quantity;
                        END IF;

                        --
                        l_ins_row := 'T';
                     END IF;

                     --
                     IF l_ins_row = 'T'
                     THEN
                        IF     c_order_csr.uom_code = 'CON'
                           AND l_bal_kg_quantity <= 0
                           AND l_tot_con_quantity > 0
                        THEN
                           l_con_quantity :=
                                          l_con_quantity + l_tot_con_quantity;
                           l_order_quantity :=
                                               -- Manas on 22-Aug-2019
                                                             /*mtl_uom_conversion_qty
                                                                          (p_item_id       => c_order_csr.item_id,
                                                                           p_from_qty      => l_con_quantity,
                                                                           p_from_um       => 'CON',
                                                                           p_to_um         => 'KG'
                                                                          );*/
                                               l_con_quantity * l_conv_rate;
                        END IF;

                        --
                        l_rtn_stat := 'S';

                        --
                        IF c_order_csr.uom_code = 'CON'
                        THEN
                           -- Added By Manas on 22-Aug-2019
                           /*SELECT mtl_uom_conversion_qty
                                          (p_item_id       => c_order_csr.item_id,
                                           p_from_qty      => c_order_csr.quantity,
                                           p_from_um       => 'CON',
                                           p_to_um         => 'KG'
                                          )
                             INTO l_quantity_sec
                             FROM DUAL;*/
                           l_quantity_sec :=
                                           c_order_csr.quantity * l_conv_rate;
                           l_uom_sec := 'KG';
                           ---- debug_insert (   'insert_row_con:    '|| l_con_quantity);
                           insert_row
                              (p_organization_id             => c_order_csr.organization_id,
                               p_organization_code           => c_order_csr.orgn_code,
                               p_order_number                => c_order_csr.order_number,
                               p_inventory_item_id           => c_order_csr.item_id,
                               p_item_number                 => c_order_csr.item_segments,
                               p_item_description            => c_order_csr.item_desc,
                               p_article_ticket              => c_order_csr.article_ticket,
                               p_product_line                => c_order_csr.product_line,
                               p_parent_quantity             => c_order_csr.parent_quantity,
                               p_transaction_quantity        => l_con_quantity,
                               --l_order_quantity,
                               p_plan_quantity               => l_con_quantity,
                               --l_order_quantity,
                               p_parent_qty_uom              => c_order_csr.uom_code,
                               p_transaction_qty_uom         => 'CON', --'KG',
                               p_reference_type              => c_order_csr.order_type_text,
                               p_reference_header_id         => c_order_csr.transaction_id,
                               p_plan_start_date             => SYSDATE,
                               p_plan_end_date               => SYSDATE + 90,
                               p_vessel_name                 => c_vessel_csr.resource_name,
                               p_transaction_source          => 'ASCP',
                               p_secondary_plan_qty          => l_order_quantity,
                               p_secondary_plan_qty_uom      => 'KG',
                               p_plan_name                   => c_order_csr.plan_name,
                               p_transaction_id              => c_order_csr.transaction_id,
                               p_parent_quantity_sec         => c_order_csr.parent_quantity_sec,
                               p_parent_qty_uom_sec          => c_order_csr.parent_qty_uom_sec,
                               p_orig_plan_start_date        => c_order_csr.orig_plan_start_date,
                               p_orig_plan_end_date          => c_order_csr.orig_plan_end_date,
                               x_rtn_stat                    => l_rtn_stat,
                               x_rtn_msg                     => l_rtn_msg
                              );
                        ELSE
                           -- Added By Manas on 22-Aug-2019
                           /*SELECT mtl_uom_conversion_qty
                                          (p_item_id       => c_order_csr.item_id,
                                           p_from_qty      => c_order_csr.quantity,
                                           p_from_um       => 'KG',
                                           p_to_um         => 'CON'
                                          )
                             INTO l_quantity_sec
                             FROM DUAL;*/
                           l_quantity_sec :=
                                           c_order_csr.quantity / l_conv_rate;
                           l_uom_sec := 'CON';
                           ---- debug_insert (   'insert_row_kg:    '|| l_order_quantity);
                           insert_row
                              (p_organization_id           => c_order_csr.organization_id,
                               p_organization_code         => c_order_csr.orgn_code,
                               p_order_number              => c_order_csr.order_number,
                               p_inventory_item_id         => c_order_csr.item_id,
                               p_item_number               => c_order_csr.item_segments,
                               p_item_description          => c_order_csr.item_desc,
                               p_article_ticket            => c_order_csr.article_ticket,
                               p_product_line              => c_order_csr.product_line,
                               p_parent_quantity           => c_order_csr.parent_quantity,
                               p_transaction_quantity      => l_order_quantity,
                               p_plan_quantity             => l_order_quantity,
                               p_parent_qty_uom            => c_order_csr.uom_code,
                               p_transaction_qty_uom       => 'KG',
                               p_reference_type            => c_order_csr.order_type_text,
                               p_reference_header_id       => c_order_csr.transaction_id,
                               p_plan_start_date           => SYSDATE,
                               p_plan_end_date             => SYSDATE + 90,
                               p_vessel_name               => c_vessel_csr.resource_name,
                               p_transaction_source        => 'ASCP',
                               p_plan_name                 => c_order_csr.plan_name,
                               p_transaction_id            => c_order_csr.transaction_id,
                               p_parent_quantity_sec       => c_order_csr.parent_quantity_sec,
                               p_parent_qty_uom_sec        => c_order_csr.parent_qty_uom_sec,
                               p_orig_plan_start_date      => c_order_csr.orig_plan_start_date,
                               p_orig_plan_end_date        => c_order_csr.orig_plan_end_date,
                               x_rtn_stat                  => l_rtn_stat,
                               x_rtn_msg                   => l_rtn_msg
                              );
                        END IF;

                        --
                        IF l_rtn_stat <> 'S'
                        THEN
                           RAISE e_usr_exception;
                        END IF;

                        --
                        EXIT;
                     END IF;
                  END IF;
               END LOOP c_vessel_csr;
            --
            END LOOP;

            --
            IF c_order_csr.order_type_text LIKE '%Work order%'
            THEN
               ---- debug_insert ('Work order');
               l_rtn_stat := 'S';

               IF c_order_csr.uom_code = 'KG'
               THEN
                  -- Added By Manas 22-Aug-2019
                  xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                  IF l_conv_factor < 0
                  THEN
                     fnd_file.put_line (fnd_file.LOG, l_error_message_con);
                     raise_application_error (-20003, l_error_message_con);
                  ELSE
                     l_conv_rate := l_conv_factor;
                  END IF;

                  l_quantity_sec := c_order_csr.quantity / l_conv_factor;
                  /*SELECT mtl_uom_conversion_qty
                                          (p_item_id       => c_order_csr.item_id,
                                           p_from_qty      => c_order_csr.quantity,
                                           p_from_um       => 'KG',
                                           p_to_um         => 'CON'
                                          )
                    INTO l_quantity_sec
                    FROM DUAL;*/
                  l_uom_sec := 'CON';
               ELSE
                  -- Added By Manas 22-Aug-2019
                  xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                  IF l_conv_factor < 0
                  THEN
                     fnd_file.put_line (fnd_file.LOG, l_error_message_con);
                     raise_application_error (-20003, l_error_message_con);
                  ELSE
                     l_conv_rate := l_conv_factor;
                  END IF;

                  l_quantity_sec := c_order_csr.quantity * l_conv_factor;
                  /*SELECT mtl_uom_conversion_qty
                                          (p_item_id       => c_order_csr.item_id,
                                           p_from_qty      => c_order_csr.quantity,
                                           p_from_um       => 'CON',
                                           p_to_um         => 'KG'
                                          )
                    INTO l_quantity_sec
                    FROM DUAL;*/
                  l_uom_sec := 'KG';
               END IF;

               ---- debug_insert (   'insert_row_work_order:    '|| c_order_csr.quantity);
               insert_row
                  (p_organization_id           => c_order_csr.organization_id,
                   p_organization_code         => c_order_csr.orgn_code,
                   p_order_number              => c_order_csr.order_number,
                   p_inventory_item_id         => c_order_csr.item_id,
                   p_item_number               => c_order_csr.item_segments,
                   p_item_description          => c_order_csr.item_desc,
                   p_article_ticket            => c_order_csr.article_ticket,
                   p_product_line              => c_order_csr.product_line,
                   p_parent_quantity           => c_order_csr.parent_quantity,
                   p_transaction_quantity      => c_order_csr.quantity,
                   p_plan_quantity             => c_order_csr.quantity,
                   p_parent_qty_uom            => c_order_csr.uom_code,
                   p_transaction_qty_uom       => c_order_csr.uom_code,
                   p_reference_type            => c_order_csr.order_type_text,
                   p_reference_header_id       => c_order_csr.transaction_id,
                   p_plan_start_date           => SYSDATE,
                   p_plan_end_date             => SYSDATE + 90,
                   p_vessel_name               => NULL,
                   p_transaction_source        => 'ASCP',
                   p_plan_name                 => c_order_csr.plan_name,
                   p_transaction_id            => c_order_csr.transaction_id,
                   p_parent_quantity_sec       => c_order_csr.parent_quantity_sec,
                   p_parent_qty_uom_sec        => c_order_csr.parent_qty_uom_sec,
                   p_orig_plan_start_date      => c_order_csr.orig_plan_start_date,
                   p_orig_plan_end_date        => c_order_csr.orig_plan_end_date,
                   x_rtn_stat                  => l_rtn_stat,
                   x_rtn_msg                   => l_rtn_msg
                  );

               IF l_rtn_stat <> 'S'
               THEN
                  RAISE e_usr_exception;
               END IF;
            END IF;
         EXCEPTION
            WHEN e_usr_exception
            THEN
               ROLLBACK;
               fnd_file.put_line (fnd_file.LOG,
                                  'Deleted all the child plan order'
                                 );
            WHEN OTHERS
            THEN
               ROLLBACK;
               fnd_file.put_line
                          (fnd_file.LOG,
                              'Unexpected Error to create child plan order- '
                           || SQLERRM
                          );
         END;
      END LOOP c_order_csr;

      COMMIT;
   END ascp_inline_prc;

   PROCEDURE ascp_inline_prc_wo (
      p_organization_id     IN   NUMBER,
      p_plan_name           IN   VARCHAR2,
      p_transaction_id      IN   NUMBER,
      p_quantity            IN   NUMBER,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   )
   IS
      e_usr_exception               EXCEPTION;
      l_bal_quantity                NUMBER;
      l_order_quantity              NUMBER;
      l_int                         INTEGER;
      l_bal_kg_quantity             NUMBER;
      l_tot_con_quantity            NUMBER;
      l_con_quantity                NUMBER;
      l_pkg_qty                     NUMBER;
      l_rtn_stat                    VARCHAR2 (100);
      l_ins_row                     VARCHAR2 (1);
      l_rtn_msg                     VARCHAR2 (4000);
      l_conv_rate                   NUMBER;
      l_count                       NUMBER;
      l_delete_count                NUMBER          := 0;
      l_quantity_sec                NUMBER;
      l_uom_sec                     VARCHAR2 (10);
      l_order_number                VARCHAR2 (100)  := NULL;
      l_sum_plan_quantity           NUMBER;
      l_max_resource_workbench_id   NUMBER;
      l_balance_quantity            NUMBER;
      l_related_quantity_factor     NUMBER          := 1;
      l_null                        VARCHAR2 (4000) := NULL;
      l_attribute10                 NUMBER          := NULL;
      l_attribute11                 NUMBER          := NULL;
      c_main_rec_count              NUMBER          := 0;
      ln_kg_per_pkg                 NUMBER;
      l_conv_factor                 NUMBER;
      l_error_message_con           VARCHAR2 (4000);
   BEGIN
      fnd_file.put_line
                       (fnd_file.LOG,
                        'Initiate XXDBL_RESOURCE_WORKBENCH_PKG.ASCP_MAIN_PRC'
                       );
      fnd_file.put_line (fnd_file.LOG,
                         'Parent Order Number: ' || p_transaction_id
                        );
      fnd_file.put_line (fnd_file.LOG,
                         '------------------------------------------------'
                        );
      c_main_rec_count := 0;

      FOR c_main_rec IN
         (SELECT   transaction_source, inventory_item_id, item_number,
                   item_description, organization_id, organization_code,
                   lot_number, customer_po_number, customer_number,
                   customer_name, customer_id, order_number, order_line_no,
                   order_header_id, order_line_id, attribute1, attribute12,
                   parent_quantity, parent_qty_uom, parent_quantity_sec,
                   parent_qty_uom_sec,
                   SUM (plan_quantity)
                                      --SUM (transaction_quantity)
                   transaction_quantity_pri,
                   SUM (NVL (secondary_plan_qty, plan_quantity)
                       )
                        --SUM (parent_quantity_sec)
                   transaction_quantity_sec,
                   MIN (plan_start_date) plan_start_date_min,
                   MIN (plan_end_date) plan_end_date_min
              --order_number
          FROM     xxdbl_resource_workbench
             WHERE 1 = 1
               AND status IN ('NEW', 'ERROR', 'MERGE_NEW')
               AND organization_id = p_organization_id
               AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
          GROUP BY transaction_source,
                   inventory_item_id,
                   item_number,
                   item_description,
                   organization_id,
                   organization_code,
                   lot_number,
                   customer_po_number,
                   customer_number,
                   customer_name,
                   customer_id,
                   order_number,
                   order_line_no,
                   order_header_id,
                   order_line_id,
                   attribute1,
                   attribute12,
                   parent_quantity,
                   parent_qty_uom,
                   parent_quantity_sec,
                   parent_qty_uom_sec                           --order_number
            HAVING SUM (plan_quantity) > 0
               AND SUM (NVL (secondary_plan_qty, plan_quantity)) > 0
          ORDER BY transaction_source,
                   inventory_item_id,
                   item_number,
                   item_description,
                   organization_id,
                   organization_code,
                   lot_number,
                   customer_po_number,
                   customer_number,
                   customer_name,
                   customer_id,
                   order_number,
                   order_line_no,
                   order_header_id,
                   order_line_id,
                   attribute1,
                   attribute12,
                   parent_quantity,
                   parent_qty_uom,
                   parent_quantity_sec,
                   parent_qty_uom_sec                           --order_number
                                     )
      LOOP
         IF c_main_rec.order_number IS NULL
         THEN
            c_main_rec_count := c_main_rec_count + 1;
            l_order_number :=
                     TO_CHAR (SYSDATE, 'DDMMYYYYHH24MISS')
                     || c_main_rec_count;
         ELSE
            l_order_number := c_main_rec.order_number;
         END IF;

         l_delete_count := 0;

         /*debug_insert ('l_order_number:         ' || l_order_number);
         debug_insert ('c_main_rec.lot_number:      ' || c_main_rec.lot_number);
         debug_insert (   'c_main_rec.item_number:      '
                       || c_main_rec.item_number
                      );*/

         -- Cursor on planned orders
         FOR c_order_csr IN
            (SELECT DISTINCT sup.organization_id, l_order_number order_number,
                             sup.item_number item_segments,
                             sup.parent_qty_uom uom_code,
                             sup.reference_type order_type_text,
                             NULL transaction_id,
                             xxdbl_resource_workbench_pkg.get_remainning_quantity_wo
                                     (c_main_rec.transaction_source,
                                      c_main_rec.lot_number,
                                      c_main_rec.customer_po_number,
                                      c_main_rec.customer_number,
                                      c_main_rec.customer_name,
                                      c_main_rec.customer_id,
                                      c_main_rec.order_number,
                                      c_main_rec.order_line_no,
                                      c_main_rec.order_header_id,
                                      c_main_rec.order_line_id,
                                      c_main_rec.inventory_item_id
                                     ) quantity,
                             DECODE
                                (c_main_rec.transaction_source,
                                 'MTO', xxdbl_resource_workbench_pkg.get_remain_quantity_wo_mto
                                               (c_main_rec.transaction_source,
                                                c_main_rec.lot_number,
                                                c_main_rec.customer_po_number,
                                                c_main_rec.customer_number,
                                                c_main_rec.customer_name,
                                                c_main_rec.customer_id,
                                                c_main_rec.order_number,
                                                c_main_rec.order_line_no,
                                                c_main_rec.order_header_id,
                                                c_main_rec.order_line_id,
                                                c_main_rec.inventory_item_id
                                               ),
                                 'ASCP', xxdbl_resource_workbench_pkg.get_remain_quantity_wo_ascp
                                               (c_main_rec.transaction_source,
                                                c_main_rec.inventory_item_id
                                               ),
                                 xxdbl_resource_workbench_pkg.get_remain_quantity_wo_mto
                                               (c_main_rec.transaction_source,
                                                c_main_rec.lot_number,
                                                c_main_rec.customer_po_number,
                                                c_main_rec.customer_number,
                                                c_main_rec.customer_name,
                                                c_main_rec.customer_id,
                                                c_main_rec.order_number,
                                                c_main_rec.order_line_no,
                                                c_main_rec.order_header_id,
                                                c_main_rec.order_line_id,
                                                c_main_rec.inventory_item_id
                                               )
                                ) related_quantity,
                             msib.inventory_item_id item_id,
                             msib.description item_desc,
                             micv.segment1 product_line,
                             micv.segment2 article_ticket,
                             msib.attribute4 /*msib.attribute1*/ kg_per_pkg,
                             mp.organization_code orgn_code, NULL plan_name,
                             c_main_rec.transaction_quantity_pri
                                                              parent_quantity,
                             c_main_rec.transaction_quantity_sec
                                                          parent_quantity_sec,
                             sup.parent_qty_uom_sec,
                             SYSDATE orig_plan_start_date,
                             SYSDATE orig_plan_end_date
                        FROM (SELECT   sup1.organization_id,
                                       sup1.inventory_item_id,
                                       sup1.item_number, sup1.parent_qty_uom,
                                       sup1.reference_type,
                                       NVL
                                          (sup1.parent_qty_uom_sec,
                                           'KG'
                                          ) parent_qty_uom_sec,
                                       lot_number
                                  FROM xxdbl_rw_headers sup1
                              GROUP BY sup1.organization_id,
                                       sup1.inventory_item_id,
                                       sup1.item_number,
                                       sup1.parent_qty_uom,
                                       sup1.reference_type,
                                       NVL (sup1.parent_qty_uom_sec, 'KG'),
                                       lot_number) sup,
                             mtl_system_items_kfv msib,
                             mtl_item_categories_v micv,
                             --fnd_lookup_values_vl lkp,
                             mtl_parameters mp
                       WHERE 1 = 1
                         AND sup.organization_id =
                                  NVL (p_organization_id, sup.organization_id)
                         AND sup.inventory_item_id =
                                                  c_main_rec.inventory_item_id
                         AND sup.item_number = msib.segment1
                         AND sup.organization_id = msib.organization_id
                         AND msib.inventory_item_id = micv.inventory_item_id
                         AND msib.organization_id = micv.organization_id
                         AND micv.category_set_name = 'DBL_SALES_PLAN_CAT'
                                                                       /*IN (
                             SELECT mdcsfv.category_set_name
                               FROM mtl_default_category_sets_fk_v mdcsfv
                              WHERE 1 = 1
                                AND mdcsfv.functional_area_desc =
                                                                 'Planning')*/
                         --= 'Planning'
                         AND micv.segment1 IN
                                ('SEWING THREAD', 'YARN', 'FIBER',
                                 'DYED YARN', 'DYED FIBER')
                         /*AND lkp.lookup_type =
                                           'XXDBL_DYEHOUSE_ARTICLE_TKT_LKP'
                         AND lkp.description = micv.segment1
                         AND lkp.meaning = micv.segment2*/
                         AND sup.organization_id = mp.organization_id
                         AND ROWNUM = 1)
         LOOP
            IF c_order_csr.related_quantity IS NULL
            THEN
               l_related_quantity_factor := 1;
            ELSIF c_order_csr.related_quantity = 0
            THEN
               l_related_quantity_factor := 1;
            ELSE
               SELECT DECODE (c_order_csr.quantity,
                              0, 1,
                                c_order_csr.related_quantity
                              / c_order_csr.quantity
                             )
                 INTO l_related_quantity_factor
                 FROM DUAL;
            END IF;

            --debug_insert ('l_delete_count');
            IF l_delete_count = 0
            THEN
               --
               -- Populate archive table
               xxdbl_resource_workbench_pkg.ascp_inline_archive_prc_wo
                      (p_plan_name               => p_plan_name,
                       p_transaction_id          => p_transaction_id,
                       p_transaction_source      => c_main_rec.transaction_source,
                       p_inventory_item_id       => c_main_rec.inventory_item_id,
                       p_item_number             => c_main_rec.item_number,
                       p_item_description        => c_main_rec.item_description,
                       p_organization_id         => p_organization_id,
                       p_organization_code       => c_main_rec.organization_code,
                       p_lot_number              => c_main_rec.lot_number,
                       p_customer_po_number      => c_main_rec.customer_po_number,
                       p_customer_number         => c_main_rec.customer_number,
                       p_customer_name           => c_main_rec.customer_name,
                       p_customer_id             => c_main_rec.customer_id,
                       p_order_number            => c_main_rec.order_number,
                       p_order_line_no           => c_main_rec.order_line_no,
                       p_order_header_id         => c_main_rec.order_header_id,
                       p_order_line_id           => c_main_rec.order_line_id
                      );
               --
               l_delete_count := 1;
            END IF;

            fnd_file.put_line
                 (fnd_file.LOG,
                     'Start Creation of child order for Parent Order number: '
                  || c_order_csr.transaction_id
                 );

            BEGIN
               IF c_order_csr.order_type_text LIKE '%Planned order%'
               THEN
                  --debug_insert ('Planned order');
                  SELECT COUNT (*)
                    INTO l_count
                    FROM xxdbl_dyehouse_routing_hdr hdr,
                         xxdbl_dyehouse_routing_chart dtl
                   WHERE hdr.hdr_id = dtl.hdr_id
                     AND hdr.product_line = c_order_csr.product_line
                     AND hdr.article_ticket = c_order_csr.article_ticket;

                  -- AND hdr.kg_per_pkg = TO_NUMBER (c_order_csr.kg_per_pkg);
                  BEGIN
                     SELECT kg_per_pkg
                       INTO ln_kg_per_pkg
                       FROM xxdbl_dyehouse_routing_hdr
                      WHERE product_line = c_order_csr.product_line
                        AND article_ticket = c_order_csr.article_ticket;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ln_kg_per_pkg := NULL;
                  END;

                  --
                  IF l_count = 0
                  THEN
                     --debug_insert ('l_count = 0');
                     fnd_file.put_line
                          (fnd_file.LOG,
                           'Routing Chart not found fot this Order Number!!!'
                          );
                     RAISE e_usr_exception;
                  END IF;
               --
               ELSE
                  --debug_insert ('c_order_csr.uom_code = KG');
                  -- for Work Order
                  l_bal_kg_quantity := 0;
               END IF;

               --debug_insert ('l_bal_kg_quantity:    ' || l_bal_kg_quantity);
               --debug_insert (   'c_order_csr.quantity:        '
               --              || c_order_csr.quantity
               --             );
               --
               l_bal_kg_quantity := c_order_csr.quantity;

               IF c_main_rec.transaction_source = 'ASCP'
               THEN
                  BEGIN
                     xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                     IF l_conv_factor < 0
                     THEN
                        fnd_file.put_line (fnd_file.LOG, l_error_message_con);
                        raise_application_error (-20005, l_error_message_con);
                     ELSE
                        l_conv_rate := l_conv_factor;
                     END IF;
                  /*SELECT conversion_rate
                    INTO l_conv_rate
                    FROM mtl_uom_class_conversions
                   WHERE inventory_item_id = c_order_csr.item_id
                     AND from_uom_code = 'NO'
                     AND to_uom_code = 'KG';*/
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_conv_rate := 1;
                  END;
               ELSE
                  l_conv_rate := 1;
               END IF;

               --
               l_tot_con_quantity := c_order_csr.parent_quantity_sec;

               --debug_insert (   'c_order_csr.parent_quantity_sec:        '
               --              || c_order_csr.parent_quantity_sec
               --             );
               WHILE l_bal_kg_quantity > 0
               LOOP
                  FOR c_vessel_csr IN
                     (SELECT   dtl.*
                          FROM xxdbl_dyehouse_routing_hdr hdr,
                               xxdbl_dyehouse_routing_chart dtl
                         WHERE hdr.hdr_id = dtl.hdr_id
                           AND hdr.product_line = c_order_csr.product_line
                           AND hdr.article_ticket = c_order_csr.article_ticket
                      --  AND hdr.kg_per_pkg =
                      --                   TO_NUMBER (c_order_csr.kg_per_pkg)
                      ORDER BY to_weight DESC)
                  LOOP
                     l_ins_row := 'F';

                     --
                     IF l_bal_kg_quantity >= c_vessel_csr.from_weight
                     THEN
                        IF l_bal_kg_quantity <= c_vessel_csr.to_weight
                        THEN
                           l_order_quantity := l_bal_kg_quantity;

                           --
                           IF c_order_csr.uom_code = 'CON'
                           THEN
                              l_con_quantity :=
                                               l_order_quantity / l_conv_rate;

                              --
                              SELECT FLOOR (l_con_quantity)
                                INTO l_int
                                FROM DUAL;

                              --
                              IF l_con_quantity > l_int
                              THEN
                                 l_con_quantity := l_int;
                              END IF;

                              --
                              l_tot_con_quantity :=
                                           l_tot_con_quantity - l_con_quantity;
                           END IF;

                           --
                           l_bal_kg_quantity := 0;
                           l_ins_row := 'T';
                        ELSE
                           l_order_quantity := c_vessel_csr.to_weight;
                           l_bal_kg_quantity :=
                                         l_bal_kg_quantity - l_order_quantity;

                           --
                           IF c_order_csr.uom_code = 'CON'
                           THEN
                              l_con_quantity :=
                                               l_order_quantity / l_conv_rate;

                              --
                              SELECT FLOOR (l_con_quantity)
                                INTO l_int
                                FROM DUAL;

                              --
                              IF l_con_quantity > l_int
                              THEN
                                 l_con_quantity := l_int;
                              END IF;

                              --
                              l_tot_con_quantity :=
                                           l_tot_con_quantity - l_con_quantity;
                           END IF;

                           --
                           l_ins_row := 'T';
                        END IF;

                        --
                        IF l_ins_row = 'T'
                        THEN
                           IF     c_order_csr.uom_code = 'CON'
                              AND l_bal_kg_quantity <= 0
                              AND l_tot_con_quantity > 0
                           THEN
                              l_con_quantity :=
                                          l_con_quantity + l_tot_con_quantity;
                              -- Added By Manas 22-Aug-2019
                              xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                              IF l_conv_factor < 0
                              THEN
                                 fnd_file.put_line (fnd_file.LOG,
                                                    l_error_message_con
                                                   );
                                 raise_application_error (-20003,
                                                          l_error_message_con
                                                         );
                              ELSE
                                 l_conv_rate := l_conv_factor;
                              END IF;

                              l_order_quantity :=
                                                l_con_quantity * l_conv_factor;
                           /*l_order_quantity :=
                              mtl_uom_conversion_qty
                                        (p_item_id       => c_order_csr.item_id,
                                         p_from_qty      => l_con_quantity,
                                         p_from_um       => 'CON',
                                         p_to_um         => 'KG'
                                        );*/
                           END IF;

                           --
                           l_rtn_stat := 'S';

                           --
                           IF c_order_csr.uom_code = 'CON'
                           THEN
                              -- Added By Manas 22-Aug-2019
                              xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                              IF l_conv_factor < 0
                              THEN
                                 fnd_file.put_line (fnd_file.LOG,
                                                    l_error_message_con
                                                   );
                                 raise_application_error (-20003,
                                                          l_error_message_con
                                                         );
                              ELSE
                                 l_conv_rate := l_conv_factor;
                              END IF;

                              l_quantity_sec :=
                                          c_order_csr.quantity * l_conv_factor;
                              /*SELECT mtl_uom_conversion_qty
                                          (p_item_id       => c_order_csr.item_id,
                                           p_from_qty      => c_order_csr.quantity,
                                           p_from_um       => 'CON',
                                           p_to_um         => 'KG'
                                          )
                                INTO l_quantity_sec
                                FROM DUAL;*/
                              l_uom_sec := 'KG';

                              --debug_insert (   'insert_row_con:    '
                              --              || l_con_quantity
                              --             );
                              IF (   (l_con_quantity < 0)
                                  OR (l_order_quantity < 0)
                                 )
                              THEN
                                 raise_application_error
                                                      (-20001,
                                                       'Quantity is negative'
                                                      );
                              END IF;

                              insert_row
                                 (p_organization_id             => c_order_csr.organization_id,
                                  p_organization_code           => c_order_csr.orgn_code,
                                  p_order_number                => c_order_csr.order_number,
                                  p_inventory_item_id           => c_order_csr.item_id,
                                  p_item_number                 => c_order_csr.item_segments,
                                  p_item_description            => c_order_csr.item_desc,
                                  p_article_ticket              => c_order_csr.article_ticket,
                                  p_product_line                => c_order_csr.product_line,
                                  p_parent_quantity             => c_main_rec.parent_quantity,
                                  --c_order_csr.parent_quantity,
                                  p_transaction_quantity        => l_con_quantity,
                                  --l_order_quantity,
                                  p_plan_quantity               => l_con_quantity,
                                  --l_order_quantity,
                                  p_parent_qty_uom              => c_main_rec.parent_qty_uom,
                                  --c_order_csr.uom_code,
                                  p_transaction_qty_uom         => 'CON',
                                  --'KG',
                                  p_reference_type              => c_order_csr.order_type_text,
                                  p_reference_header_id         => c_order_csr.transaction_id,
                                  p_plan_start_date             => c_main_rec.plan_start_date_min,
                                  --SYSDATE,
                                  p_plan_end_date               => c_main_rec.plan_end_date_min,
                                  --SYSDATE + 90,
                                  p_vessel_name                 => c_vessel_csr.resource_name,
                                  p_transaction_source          => c_main_rec.transaction_source,
                                  p_secondary_plan_qty          => l_order_quantity,
                                  p_secondary_plan_qty_uom      => 'KG',
                                  p_plan_name                   => c_order_csr.plan_name,
                                  p_transaction_id              => c_order_csr.transaction_id,
                                  p_parent_quantity_sec         => c_main_rec.parent_quantity_sec,
                                  --c_order_csr.parent_quantity_sec,
                                  p_parent_qty_uom_sec          => c_main_rec.parent_qty_uom_sec,
                                  --c_order_csr.parent_qty_uom_sec,
                                  p_orig_plan_start_date        => c_main_rec.plan_start_date_min,
                                  --c_order_csr.orig_plan_start_date,
                                  p_orig_plan_end_date          => c_main_rec.plan_end_date_min,
                                  --c_order_csr.orig_plan_end_date,
                                  p_lot_number                  => c_main_rec.lot_number,
                                  p_customer_po_number          => c_main_rec.customer_po_number,
                                  x_rtn_stat                    => l_rtn_stat,
                                  x_rtn_msg                     => l_rtn_msg
                                 );
                           ELSE
                              IF c_main_rec.transaction_source = 'ASCP'
                              THEN
                                 -- Added By Manas 22-Aug-2019
                                 xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                                 IF l_conv_factor < 0
                                 THEN
                                    fnd_file.put_line (fnd_file.LOG,
                                                       l_error_message_con
                                                      );
                                    raise_application_error
                                                          (-20003,
                                                           l_error_message_con
                                                          );
                                 ELSE
                                    l_conv_rate := l_conv_factor;
                                 END IF;

                                 l_quantity_sec :=
                                            c_order_csr.quantity / l_conv_rate;
                              /*SELECT mtl_uom_conversion_qty
                                        (p_item_id       => c_order_csr.item_id,
                                         p_from_qty      => c_order_csr.quantity,
                                         p_from_um       => 'KG',
                                         p_to_um         => 'CON'
                                        )
                                INTO l_quantity_sec
                                FROM DUAL;*/
                              ELSE
                                 l_quantity_sec := c_order_csr.quantity;
                              END IF;

                              IF c_main_rec.transaction_source = 'ASCP'
                              THEN
                                 l_uom_sec := 'CON';
                              ELSE
                                 l_uom_sec := 'KG';
                              END IF;

                              --debug_insert (   'insert_row_kg:    '
                              --              || l_order_quantity
                              --             );
                              IF c_main_rec.transaction_source = 'ASCP'
                              THEN
                                 IF (   (l_con_quantity < 0)
                                     OR (l_order_quantity < 0)
                                    )
                                 THEN
                                    raise_application_error
                                                     (-20001,
                                                      'Quantity is negative2'
                                                     );
                                 END IF;

                                 insert_row
                                    (p_organization_id           => c_order_csr.organization_id,
                                     p_organization_code         => c_order_csr.orgn_code,
                                     p_order_number              => c_order_csr.order_number,
                                     p_inventory_item_id         => c_order_csr.item_id,
                                     p_item_number               => c_order_csr.item_segments,
                                     p_item_description          => c_order_csr.item_desc,
                                     p_article_ticket            => c_order_csr.article_ticket,
                                     p_product_line              => c_order_csr.product_line,
                                     p_parent_quantity           => c_order_csr.parent_quantity,
                                     p_transaction_quantity      => l_order_quantity,
                                     p_plan_quantity             => l_order_quantity,
                                     p_parent_qty_uom            => c_order_csr.uom_code,
                                     p_transaction_qty_uom       => 'KG',
                                     p_reference_type            => c_order_csr.order_type_text,
                                     p_reference_header_id       => c_order_csr.transaction_id,
                                     p_plan_start_date           => c_main_rec.plan_start_date_min,
                                     --SYSDATE,
                                     p_plan_end_date             => c_main_rec.plan_end_date_min,
                                     --  SYSDATE + 90,
                                     p_vessel_name               => c_vessel_csr.resource_name,
                                     p_transaction_source        => c_main_rec.transaction_source,
                                     --'ASCP',
                                     p_plan_name                 => c_order_csr.plan_name,
                                     p_transaction_id            => c_order_csr.transaction_id,
                                     p_parent_quantity_sec       => c_order_csr.parent_quantity_sec,
                                     p_parent_qty_uom_sec        => c_order_csr.parent_qty_uom_sec,
                                     p_orig_plan_start_date      => c_main_rec.plan_start_date_min,
                                     --c_order_csr.orig_plan_start_date,
                                     p_orig_plan_end_date        => c_main_rec.plan_end_date_min,
                                     --c_order_csr.orig_plan_end_date,
                                     p_lot_number                => c_main_rec.lot_number,
                                     p_customer_po_number        => c_main_rec.customer_po_number,
                                     x_rtn_stat                  => l_rtn_stat,
                                     x_rtn_msg                   => l_rtn_msg
                                    );
                              ELSE
                                 l_attribute10 :=
                                    ROUND (  l_order_quantity
                                           * l_related_quantity_factor,
                                           3
                                          );

                                 SELECT DECODE (l_order_quantity,
                                                0, 1 - (l_attribute10),
                                                  1
                                                - (  l_attribute10
                                                   / l_order_quantity
                                                  )
                                               )
                                   INTO l_attribute11
                                   FROM DUAL;

                                 IF (   (l_con_quantity < 0)
                                     OR (l_order_quantity < 0)
                                    )
                                 THEN
                                    raise_application_error
                                                     (-20001,
                                                      'Quantity is negative3'
                                                     );
                                 END IF;

                                 insert_row
                                    (p_organization_id              => c_order_csr.organization_id,
                                     p_organization_code            => c_order_csr.orgn_code,
                                     p_order_header_id              => c_main_rec.order_header_id,
                                     p_order_number                 => c_main_rec.order_number,
                                     p_order_line_id                => c_main_rec.order_line_id,
                                     p_order_line_no                => c_main_rec.order_line_no,
                                     p_inventory_item_id            => c_order_csr.item_id,
                                     p_item_number                  => c_order_csr.item_segments,
                                     p_item_description             => c_order_csr.item_desc,
                                     p_article_ticket               => c_order_csr.article_ticket,
                                     p_product_line                 => c_order_csr.product_line,
                                     p_parent_quantity              => NULL,
                                     --c_order_csr.parent_quantity,
                                     p_transaction_quantity         => l_order_quantity,
                                     p_plan_quantity                => l_order_quantity,
                                     p_parent_qty_uom               => NULL,
                                     --c_order_csr.uom_code,
                                     p_transaction_qty_uom          => 'KG',
                                     p_reference_type               => c_order_csr.order_type_text,
                                     p_reference_header_id          => c_order_csr.transaction_id,
                                     p_reference_line_id            => l_null,
                                     p_plan_start_date              => c_main_rec.plan_start_date_min,
                                     -- SYSDATE,
                                     p_plan_end_date                => c_main_rec.plan_end_date_min,
                                     --SYSDATE + 90,
                                     p_vessel_name                  => c_vessel_csr.resource_name,
                                     p_recipe_id                    => l_null,
                                     p_recipe_no                    => l_null,
                                     p_recipe_version               => l_null,
                                     p_recipe_validity_rule_id      => l_null,
                                     p_special_instruction          => l_null,
                                     p_status                       => 'NEW',
                                     p_customer_id                  => c_main_rec.customer_id,
                                     p_customer_number              => c_main_rec.customer_number,
                                     p_customer_name                => c_main_rec.customer_name,
                                     p_customer_po_number           => c_main_rec.customer_po_number,
                                     p_batch_no                     => l_null,
                                     p_bacth_id                     => l_null,
                                     p_attribute1                   => c_main_rec.attribute1,
                                     p_attribute2                   => l_null,
                                     p_attribute3                   => l_null,
                                     p_attribute4                   => l_null,
                                     p_attribute5                   => l_null,
                                     p_attribute6                   => l_null,
                                     p_attribute7                   => l_null,
                                     p_attribute8                   => l_null,
                                     p_attribute9                   => l_null,
                                     p_attribute10                  => l_attribute10,
                                     p_attribute11                  => l_attribute11,
                                     p_attribute12                  => c_main_rec.attribute12,
                                     p_attribute13                  => l_null,
                                     p_attribute14                  => l_null,
                                     p_attribute15                  => l_null,
                                     p_attribute16                  => l_null,
                                     p_attribute17                  => l_null,
                                     p_attribute18                  => l_null,
                                     p_attribute19                  => l_null,
                                     p_attribute20                  => l_null,
                                     p_transaction_source           => c_main_rec.transaction_source,
                                     p_lot_number                   => c_main_rec.lot_number,
                                     p_secondary_plan_qty           => NULL,
                                     --l_order_quantity,
                                     p_secondary_plan_qty_uom       => NULL,
                                                                       --'KG',
                                     --'ASCP',
                                     p_plan_name                    => c_order_csr.plan_name,
                                     p_transaction_id               => c_order_csr.transaction_id,
                                     p_orig_plan_start_date         => c_main_rec.plan_start_date_min,
                                     -- c_order_csr.orig_plan_start_date,
                                     p_orig_plan_end_date           => c_main_rec.plan_end_date_min,
                                     -- c_order_csr.orig_plan_end_date,
                                     p_parent_quantity_sec          => NULL,
                                     --c_order_csr.parent_quantity_sec,
                                     p_parent_qty_uom_sec           => NULL,
                                     --c_order_csr.parent_qty_uom_sec,
                                     x_rtn_stat                     => l_rtn_stat,
                                     x_rtn_msg                      => l_rtn_msg
                                    );
                              END IF;
                           END IF;

                           --
                           IF l_rtn_stat <> 'S'
                           THEN
                              RAISE e_usr_exception;
                           END IF;

                           --
                           EXIT;
                        END IF;
                     END IF;
                  END LOOP c_vessel_csr;
               --
               END LOOP;

               --
               IF c_order_csr.order_type_text LIKE '%Work order%'
               THEN
                  ---- debug_insert ('Work order');
                  l_rtn_stat := 'S';

                  IF c_order_csr.uom_code = 'KG'
                  THEN
                     IF c_main_rec.transaction_source = 'ASCP'
                     THEN
                        -- Added By Manas 22-Aug-2019
                        xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                        IF l_conv_factor < 0
                        THEN
                           fnd_file.put_line (fnd_file.LOG,
                                              l_error_message_con
                                             );
                           raise_application_error (-20003,
                                                    l_error_message_con
                                                   );
                        ELSE
                           l_conv_rate := l_conv_factor;
                        END IF;

                        l_quantity_sec := c_order_csr.quantity / l_conv_factor;
                        /*SELECT mtl_uom_conversion_qty
                                          (p_item_id       => c_order_csr.item_id,
                                           p_from_qty      => c_order_csr.quantity,
                                           p_from_um       => 'KG',
                                           p_to_um         => 'CON'
                                          )
                          INTO l_quantity_sec
                          FROM DUAL;*/
                        l_uom_sec := 'CON';
                     ELSE
                        l_quantity_sec := c_order_csr.quantity;
                        l_uom_sec := 'KG';
                     END IF;
                  ELSE
                     IF c_main_rec.transaction_source = 'ASCP'
                     THEN
                        -- Added By Manas 22-Aug-2019
                        xxdbl_resource_workbench_pkg.parent_child_form_qty
                                                        (p_organization_id,
                                                         c_order_csr.item_id,
                                                         l_error_message_con,
                                                         l_conv_factor
                                                        );

                        IF l_conv_factor < 0
                        THEN
                           fnd_file.put_line (fnd_file.LOG,
                                              l_error_message_con
                                             );
                           raise_application_error (-20003,
                                                    l_error_message_con
                                                   );
                        ELSE
                           l_conv_rate := l_conv_factor;
                        END IF;

                        l_quantity_sec := c_order_csr.quantity * l_conv_factor;
                        /*SELECT mtl_uom_conversion_qty
                                          (p_item_id       => c_order_csr.item_id,
                                           p_from_qty      => c_order_csr.quantity,
                                           p_from_um       => 'CON',
                                           p_to_um         => 'KG'
                                          )
                          INTO l_quantity_sec
                          FROM DUAL;*/
                        l_uom_sec := 'KG';
                     ELSE
                        l_quantity_sec := c_order_csr.quantity;
                        l_uom_sec := 'KG';
                     END IF;
                  END IF;

                  ---- debug_insert (   'insert_row_work_order:    '|| c_order_csr.quantity);
                  IF c_main_rec.transaction_source = 'ASCP'
                  THEN
                     IF ((l_con_quantity < 0) OR (l_order_quantity < 0))
                     THEN
                        raise_application_error (-20001,
                                                 'Quantity is negative4'
                                                );
                     END IF;

                     insert_row
                        (p_organization_id           => c_order_csr.organization_id,
                         p_organization_code         => c_order_csr.orgn_code,
                         p_order_number              => c_order_csr.order_number,
                         p_inventory_item_id         => c_order_csr.item_id,
                         p_item_number               => c_order_csr.item_segments,
                         p_item_description          => c_order_csr.item_desc,
                         p_article_ticket            => c_order_csr.article_ticket,
                         p_product_line              => c_order_csr.product_line,
                         p_parent_quantity           => c_order_csr.parent_quantity,
                         p_transaction_quantity      => c_order_csr.quantity,
                         p_plan_quantity             => c_order_csr.quantity,
                         p_parent_qty_uom            => c_order_csr.uom_code,
                         p_transaction_qty_uom       => c_order_csr.uom_code,
                         p_reference_type            => c_order_csr.order_type_text,
                         p_reference_header_id       => c_order_csr.transaction_id,
                         p_plan_start_date           => c_main_rec.plan_start_date_min,
                         -- SYSDATE,
                         p_plan_end_date             => c_main_rec.plan_end_date_min,
                         -- SYSDATE + 90,
                         p_vessel_name               => NULL,
                         p_transaction_source        => c_main_rec.transaction_source,
                         --'ASCP',
                         p_plan_name                 => c_order_csr.plan_name,
                         p_transaction_id            => c_order_csr.transaction_id,
                         p_parent_quantity_sec       => c_order_csr.parent_quantity_sec,
                         p_parent_qty_uom_sec        => c_order_csr.parent_qty_uom_sec,
                         p_orig_plan_start_date      => c_main_rec.plan_start_date_min,
                         --c_order_csr.orig_plan_start_date,
                         p_orig_plan_end_date        => c_main_rec.plan_end_date_min,
                         --c_order_csr.orig_plan_end_date,
                         p_lot_number                => c_main_rec.lot_number,
                         p_customer_po_number        => c_main_rec.customer_po_number,
                         x_rtn_stat                  => l_rtn_stat,
                         x_rtn_msg                   => l_rtn_msg
                        );
                  ELSE
                     l_attribute10 :=
                        ROUND (l_order_quantity * l_related_quantity_factor,
                               3
                              );

                     SELECT DECODE (l_order_quantity,
                                    0, 1 - (l_attribute10),
                                    1 - (l_attribute10 / l_order_quantity)
                                   )
                       INTO l_attribute11
                       FROM DUAL;

                     IF ((l_con_quantity < 0) OR (l_order_quantity < 0))
                     THEN
                        raise_application_error (-20001,
                                                 'Quantity is negative5'
                                                );
                     END IF;

                     insert_row
                        (p_organization_id              => c_order_csr.organization_id,
                         p_organization_code            => c_order_csr.orgn_code,
                         p_order_header_id              => c_main_rec.order_header_id,
                         p_order_number                 => c_main_rec.order_number,
                         p_order_line_id                => c_main_rec.order_line_id,
                         p_order_line_no                => c_main_rec.order_line_no,
                         p_inventory_item_id            => c_order_csr.item_id,
                         p_item_number                  => c_order_csr.item_segments,
                         p_item_description             => c_order_csr.item_desc,
                         p_article_ticket               => c_order_csr.article_ticket,
                         p_product_line                 => c_order_csr.product_line,
                         p_parent_quantity              => NULL,
                         --c_order_csr.parent_quantity,
                         p_transaction_quantity         => c_order_csr.quantity,
                         p_plan_quantity                => c_order_csr.quantity,
                         p_parent_qty_uom               => NULL,
                         --c_order_csr.uom_code,
                         p_transaction_qty_uom          => c_order_csr.uom_code,
                         p_reference_type               => c_order_csr.order_type_text,
                         p_reference_header_id          => c_order_csr.transaction_id,
                         p_reference_line_id            => l_null,
                         p_plan_start_date              => c_main_rec.plan_start_date_min,
                         -- SYSDATE,
                         p_plan_end_date                => c_main_rec.plan_end_date_min,
                         -- SYSDATE + 90,
                         p_vessel_name                  => l_null,
                         p_recipe_id                    => l_null,
                         p_recipe_no                    => l_null,
                         p_recipe_version               => l_null,
                         p_recipe_validity_rule_id      => l_null,
                         p_special_instruction          => l_null,
                         p_status                       => 'NEW',
                         p_customer_id                  => c_main_rec.customer_id,
                         p_customer_number              => c_main_rec.customer_number,
                         p_customer_name                => c_main_rec.customer_name,
                         p_customer_po_number           => c_main_rec.customer_po_number,
                         p_batch_no                     => l_null,
                         p_bacth_id                     => l_null,
                         p_attribute1                   => c_main_rec.attribute1,
                         p_attribute2                   => l_null,
                         p_attribute3                   => l_null,
                         p_attribute4                   => l_null,
                         p_attribute5                   => l_null,
                         p_attribute6                   => l_null,
                         p_attribute7                   => l_null,
                         p_attribute8                   => l_null,
                         p_attribute9                   => l_null,
                         p_attribute10                  => l_attribute10,
                         p_attribute11                  => l_attribute11,
                         p_attribute12                  => c_main_rec.attribute12,
                         p_attribute13                  => l_null,
                         p_attribute14                  => l_null,
                         p_attribute15                  => l_null,
                         p_attribute16                  => l_null,
                         p_attribute17                  => l_null,
                         p_attribute18                  => l_null,
                         p_attribute19                  => l_null,
                         p_attribute20                  => l_null,
                         p_transaction_source           => c_main_rec.transaction_source,
                         p_lot_number                   => c_main_rec.lot_number,
                         p_secondary_plan_qty           => NULL,
                         --l_order_quantity,
                         p_secondary_plan_qty_uom       => NULL,       --'KG',
                         --'ASCP',
                         p_plan_name                    => c_order_csr.plan_name,
                         p_transaction_id               => c_order_csr.transaction_id,
                         p_orig_plan_start_date         => c_main_rec.plan_start_date_min,
                         -- c_order_csr.orig_plan_start_date,
                         p_orig_plan_end_date           => c_main_rec.plan_end_date_min,
                         -- c_order_csr.orig_plan_end_date,
                         p_parent_quantity_sec          => NULL,
                         --c_order_csr.parent_quantity_sec,
                         p_parent_qty_uom_sec           => NULL,
                         --c_order_csr.parent_qty_uom_sec,
                         x_rtn_stat                     => l_rtn_stat,
                         x_rtn_msg                      => l_rtn_msg
                        );
                  END IF;

                  IF l_rtn_stat <> 'S'
                  THEN
                     RAISE e_usr_exception;
                  END IF;
               END IF;
            EXCEPTION
               WHEN e_usr_exception
               THEN
                  ROLLBACK;
                  fnd_file.put_line (fnd_file.LOG,
                                     'Deleted all the child plan order'
                                    );
               WHEN OTHERS
               THEN
                  ROLLBACK;
                  fnd_file.put_line
                          (fnd_file.LOG,
                              'Unexpected Error to create child plan order- '
                           || SQLERRM
                          );
            END;
         END LOOP c_order_csr;

         BEGIN
            IF c_main_rec.transaction_source = 'MTO'
            THEN
               SELECT SUM (plan_quantity), MAX (resource_workbench_id)
                 INTO l_sum_plan_quantity, l_max_resource_workbench_id
                 FROM xxdbl_resource_workbench
                WHERE 1 = 1
                  --AND order_number = l_order_number
                  AND transaction_source = c_main_rec.transaction_source
                  AND NVL (lot_number, '##') =
                           NVL (c_main_rec.lot_number, NVL (lot_number, '##'))
                  AND NVL (customer_po_number, '##') =
                         NVL (c_main_rec.customer_po_number,
                              NVL (customer_po_number, '##')
                             )
                  AND NVL (customer_number, '##') =
                         NVL (c_main_rec.customer_number,
                              NVL (customer_number, '##')
                             )
                  AND NVL (customer_name, '##') =
                         NVL (c_main_rec.customer_name,
                              NVL (customer_name, '##')
                             )
                  AND NVL (customer_id, -1) =
                            NVL (c_main_rec.customer_id, NVL (customer_id, -1))
                  AND NVL (order_number, -1) =
                          NVL (c_main_rec.order_number, NVL (order_number, -1))
                  AND NVL (order_line_no, '##') =
                         NVL (c_main_rec.order_line_no,
                              NVL (order_line_no, '##')
                             )
                  AND NVL (order_header_id, -1) =
                         NVL (c_main_rec.order_header_id,
                              NVL (order_header_id, -1)
                             )
                  AND NVL (order_line_id, -1) =
                         NVL (c_main_rec.order_line_id,
                              NVL (order_line_id, -1))
                  AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
                  AND status IN ('NEW', 'ERROR', 'MERGED', 'MERGE_NEW');
            --debug_insert (   'l_sum_plan_quantity:        '
            --              || l_sum_plan_quantity
            --             );
            --debug_insert (   'l_max_resource_workbench_id:        '
            --              || l_max_resource_workbench_id
            --             );
            ELSE
               SELECT SUM (plan_quantity), MAX (resource_workbench_id)
                 INTO l_sum_plan_quantity, l_max_resource_workbench_id
                 FROM xxdbl_resource_workbench
                WHERE order_number = l_order_number
                  AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
                  AND transaction_source = c_main_rec.transaction_source
                  AND status IN ('NEW', 'ERROR', 'MERGED', 'MERGE_NEW');
            --debug_insert (   'l_sum_plan_quantity2:        '
            --              || l_sum_plan_quantity
            --             );
            --debug_insert (   'l_max_resource_workbench_id2:        '
            --              || l_max_resource_workbench_id
            --             );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_sum_plan_quantity := 0;
               l_max_resource_workbench_id := -1;
         END;

         IF l_sum_plan_quantity <> c_main_rec.transaction_quantity_pri
         THEN
            --debug_insert
            --   ('Inside l_sum_plan_quantity <> c_main_rec.transaction_quantity_pri'
            --   );
            l_balance_quantity :=
                    c_main_rec.transaction_quantity_pri - l_sum_plan_quantity;

            IF l_balance_quantity < -2
            THEN
               l_balance_quantity := 0;

               DELETE      xxdbl_resource_workbench
                     WHERE resource_workbench_id =
                                                  l_max_resource_workbench_id;
            ELSE
               UPDATE xxdbl_resource_workbench
                  SET plan_quantity = plan_quantity + l_balance_quantity
                WHERE resource_workbench_id = l_max_resource_workbench_id;
            END IF;
         --debug_insert ('l_balance_quantity:          '
         --              || l_balance_quantity
         --             );
         END IF;

         COMMIT;
      END LOOP c_main_rec;
   END ascp_inline_prc_wo;

-- Added By Manas on 04-Oct-2018 Ends
   --
   --

   --
   FUNCTION mtl_uom_conversion_qty (
      p_item_id    IN   NUMBER,
      p_from_qty   IN   NUMBER,
      p_from_um    IN   VARCHAR2,
      p_to_um      IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      l_from_uom_class       VARCHAR2 (100);
      l_from_base_uom_code   VARCHAR2 (100);
      l_to_uom_class         VARCHAR2 (100);
      l_to_base_uom_code     VARCHAR2 (100);
      l_to_conv_rate         NUMBER;
      l_conversion_rate      NUMBER;
      l_to_qty               NUMBER;
      l_inter_conv_rate      NUMBER;
   BEGIN
      -- Base Class and Base UOM of from UM
      SELECT v1.uom_class, v2.uom_code
        INTO l_from_uom_class, l_from_base_uom_code
        FROM mtl_units_of_measure_vl v1, mtl_units_of_measure_vl v2
       WHERE v1.uom_code = p_from_um
         AND v1.disable_date IS NULL
         AND v2.uom_class = v1.uom_class
         AND v2.base_uom_flag = 'Y'
         AND v2.disable_date IS NULL;

      --
      -- IntraClass Conversion Rate for from
      BEGIN
         SELECT conversion_rate
           INTO l_conversion_rate
           FROM mtl_uom_conversions
          WHERE inventory_item_id = 0
            AND uom_class = l_from_uom_class
            AND uom_code = p_from_um;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_conversion_rate := 1;
      END;

      --
      l_to_qty := p_from_qty * l_conversion_rate;

      --
      -- Base Class and Base UOM of To UM
      SELECT v1.uom_class, v2.uom_code
        INTO l_to_uom_class, l_to_base_uom_code
        FROM mtl_units_of_measure_vl v1, mtl_units_of_measure_vl v2
       WHERE v1.uom_code = p_to_um
         AND v1.disable_date IS NULL
         AND v2.uom_class = v1.uom_class
         AND v2.base_uom_flag = 'Y'
         AND v2.disable_date IS NULL;

      --
      -- IntraClass Conversion Rate for To UM
      BEGIN
         SELECT conversion_rate
           INTO l_to_conv_rate
           FROM mtl_uom_conversions
          WHERE inventory_item_id = 0
            AND uom_class = l_to_uom_class
            AND uom_code = p_to_um;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_conversion_rate := 1;
      END;

      --
      -- InterClass Conversion Rate
      --
      BEGIN
         SELECT conversion_rate
           INTO l_inter_conv_rate
           FROM mtl_uom_class_conversions
          WHERE inventory_item_id = p_item_id
            AND from_uom_code = l_from_base_uom_code
            AND to_uom_code = l_to_base_uom_code
            AND disable_date IS NULL;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_inter_conv_rate := 1;
      END;

      --
      --
      IF NVL (l_inter_conv_rate, 0) = 0
      THEN
         l_inter_conv_rate := 1;
      END IF;

      --
      IF NVL (l_to_conv_rate, 0) = 0
      THEN
         l_to_conv_rate := 1;
      END IF;

      --
      l_to_qty := l_to_qty / l_inter_conv_rate;
      l_to_qty := l_to_qty / l_to_conv_rate;
      --
      RETURN (ROUND (l_to_qty, 3));
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (p_from_qty);
   END mtl_uom_conversion_qty;

   --
   PROCEDURE mto_main_prc (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_factor                    IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   )
   IS
      e_usr_exception        EXCEPTION;
      l_bal_quantity         NUMBER;
      l_order_quantity       NUMBER;
      l_product_line         VARCHAR2 (240);
      l_article_ticket       VARCHAR2 (240);
      l_kg_per_pkg           NUMBER;
      l_ins_row              VARCHAR2 (1);
      l_rtn_stat             VARCHAR2 (100);
      l_rtn_msg              VARCHAR2 (4000);
      l_count                NUMBER;
      l_secondary_plan_qty   NUMBER          := 0;
   BEGIN
      ---- debug_insert ('Manas-1:       ');
      fnd_file.put_line (fnd_file.LOG,
                         'Initiate XXDBL_RESOURCE_WORKBENCH_PKG.MTO_MAIN_PRC'
                        );
      --fnd_file.put_line (fnd_file.LOG,'Parent Order Number: '||p_transaction_id);
      fnd_file.put_line (fnd_file.LOG,
                         '------------------------------------------------'
                        );

      --
      ---- debug_insert ('Manas0:       ');
      BEGIN
         SELECT micv.segment1 product_line, micv.segment2 article_ticket,
                msib.attribute4 /*msib.attribute1*/ kg_per_pkg
           INTO l_product_line, l_article_ticket,
                l_kg_per_pkg
           FROM mtl_system_items_kfv msib, mtl_item_categories_v micv
          WHERE msib.inventory_item_id = p_inventory_item_id
            AND msib.organization_id = p_organization_id
            AND msib.inventory_item_id = micv.inventory_item_id
            AND msib.organization_id = micv.organization_id
            AND micv.category_set_name = 'DBL_SALES_PLAN_CAT'                                         /*IN (
                                                              SELECT mdcsfv.category_set_name
                                                                FROM mtl_default_category_sets_fk_v mdcsfv
                                                               WHERE 1 = 1
                                                                     AND mdcsfv.functional_area_desc = 'Planning')*/;
      --= 'Planning';
      EXCEPTION
         WHEN OTHERS
         THEN
            l_rtn_msg := 'Error to get Planning catg details - ' || SQLERRM;
            RAISE e_usr_exception;
      END;

      ---- debug_insert ('Manas1:       ');

      --
      SELECT COUNT (*)
        INTO l_count
        FROM xxdbl_dyehouse_routing_hdr hdr, xxdbl_dyehouse_routing_chart dtl
       WHERE hdr.hdr_id = dtl.hdr_id
         AND hdr.product_line = l_product_line
         AND hdr.article_ticket = l_article_ticket;

      -- AND hdr.kg_per_pkg = l_kg_per_pkg;

      --
      IF l_count = 0
      THEN
         l_rtn_msg := 'Routing Chart not found fot this Order Number!!!';
         RAISE e_usr_exception;
      END IF;

      ---- debug_insert ('Manas2:       ');
      --
      l_bal_quantity := p_parent_quantity;

      --
      WHILE l_bal_quantity > 0
      LOOP
         FOR c_vessel_csr IN (SELECT   dtl.*
                                  FROM xxdbl_dyehouse_routing_hdr hdr,
                                       xxdbl_dyehouse_routing_chart dtl
                                 WHERE hdr.hdr_id = dtl.hdr_id
                                   AND hdr.product_line = l_product_line
                                   AND hdr.article_ticket = l_article_ticket
                              --  AND hdr.kg_per_pkg = l_kg_per_pkg
                              ORDER BY to_weight DESC)
         LOOP
            ---- debug_insert ('Manas3:       ');
            l_ins_row := 'F';

            IF l_bal_quantity >= c_vessel_csr.from_weight
            THEN
               IF l_bal_quantity <= c_vessel_csr.to_weight
               THEN
                  l_order_quantity := l_bal_quantity;
                  --
                  l_ins_row := 'T';
                  l_bal_quantity := 0;
               --
               ELSE
                  l_order_quantity := c_vessel_csr.to_weight;
                  --
                  l_ins_row := 'T';
                  l_bal_quantity := l_bal_quantity - l_order_quantity;
               --
               END IF;

               --
               IF l_ins_row = 'T'
               THEN
                  l_rtn_stat := 'S';
                  l_rtn_msg := NULL;
                  ---- debug_insert ('MANAS00001      ' || p_factor);
                  ---- debug_insert ('MANAS00002      ' || p_attribute11 );
                  l_secondary_plan_qty := l_order_quantity;
                  ---- debug_insert ('Manas4:       ');
                  insert_row
                     (p_organization_id              => p_organization_id,
                      p_organization_code            => p_organization_code,
                      p_order_header_id              => p_order_header_id,
                      p_order_number                 => p_order_number,
                      p_order_line_id                => p_order_line_id,
                      p_order_line_no                => p_order_line_no,
                      p_inventory_item_id            => p_inventory_item_id,
                      p_item_number                  => p_item_number,
                      p_item_description             => p_item_description,
                      p_article_ticket               => l_article_ticket,
                      p_product_line                 => l_product_line,
                      p_parent_quantity              => p_parent_quantity,
                      p_transaction_quantity         => l_secondary_plan_qty,
                      --l_order_quantity,
                      p_plan_quantity                => l_secondary_plan_qty,
                      --l_order_quantity,
                      p_parent_qty_uom               => p_parent_qty_uom,
                      p_transaction_qty_uom          => p_parent_qty_uom,
                      p_reference_type               => p_reference_type,
                      p_reference_header_id          => p_reference_header_id,
                      p_reference_line_id            => p_reference_line_id,
                      p_plan_start_date              => p_plan_start_date,
                      p_plan_end_date                => p_plan_end_date,
                      p_vessel_name                  => c_vessel_csr.resource_name,
                      p_recipe_id                    => p_recipe_id,
                      p_recipe_no                    => p_recipe_no,
                      p_recipe_version               => p_recipe_version,
                      p_recipe_validity_rule_id      => p_recipe_validity_rule_id,
                      p_special_instruction          => p_special_instruction,
                      p_status                       => p_status,
                      p_customer_id                  => p_customer_id,
                      p_customer_number              => p_customer_number,
                      p_customer_name                => p_customer_name,
                      p_customer_po_number           => p_customer_po_number,
                      p_batch_no                     => p_batch_no,
                      p_bacth_id                     => p_bacth_id,
                      p_attribute1                   => p_attribute1,
                      p_attribute2                   => p_attribute2,
                      p_attribute3                   => p_attribute3,
                      p_attribute4                   => p_attribute4,
                      p_attribute5                   => p_attribute5,
                      p_attribute6                   => p_attribute6,
                      p_attribute7                   => p_attribute7,
                      p_attribute8                   => p_attribute8,
                      p_attribute9                   => p_attribute9,
                      p_attribute10                  =>   l_secondary_plan_qty
                                                        * (1 - p_attribute11
                                                          )                          /*ROUND
                                                            ((  p_attribute10
                                                              / p_parent_quantity
                                                             ),
                                                             4
                                                            )*/                                                                                                                  /*(  (  l_secondary_plan_qty
                                                                  / p_parent_quantity
                                                                 )
                                                               * p_attribute10
                                                              )*/,
                      --p_attribute10,
                      p_attribute11                  => p_attribute11,
                      p_attribute12                  => p_attribute12,
                      p_attribute13                  => p_attribute13,
                      p_attribute14                  => p_attribute14,
                      p_attribute15                  => p_attribute15,
                      p_attribute16                  => p_attribute16,
                      p_attribute17                  => p_attribute17,
                      p_attribute18                  => p_attribute18,
                      p_attribute19                  => p_attribute19,
                      p_attribute20                  => p_attribute20,
                      p_transaction_source           => NVL
                                                           (p_transaction_source,
                                                            'MTO'
                                                           ),
                      p_lot_number                   => p_lot_number,
                      p_secondary_plan_qty           => ROUND
                                                           (  l_order_quantity
                                                            * p_factor,
                                                            2
                                                           ),
                      p_secondary_plan_qty_uom       => p_secondary_plan_qty_uom,
                      p_plan_name                    => p_plan_name,
                      p_transaction_id               => p_transaction_id,
                      p_orig_plan_start_date         => p_orig_plan_start_date,
                      p_orig_plan_end_date           => p_orig_plan_end_date,
                      p_parent_quantity_sec          => p_parent_quantity_sec,
                      p_parent_qty_uom_sec           => p_parent_qty_uom_sec,
                      x_rtn_stat                     => l_rtn_stat,
                      x_rtn_msg                      => l_rtn_msg
                     );

                  ---- debug_insert ('Manas5:       ');
                  IF l_rtn_stat <> 'S'
                  THEN
                     RAISE e_usr_exception;
                  END IF;

                  --
                  EXIT;
               END IF;
            END IF;
         END LOOP c_vessel_csr;
      END LOOP;

      --COMMIT;
      x_rtn_stat := 'S';
      x_rtn_msg := 'Records have been created successfully!';
   ---- debug_insert ('Manas6:       ');
   EXCEPTION
      WHEN e_usr_exception
      THEN
         ---- debug_insert ('Manas7:       ');
         --ROLLBACK;
         x_rtn_stat := 'E';
         x_rtn_msg := l_rtn_msg;
      WHEN OTHERS
      THEN
         ---- debug_insert ('Manas8:       ');
         --ROLLBACK;
         x_rtn_stat := 'E';
         x_rtn_msg :=
               'Unexpected Error to create resource work bench - ' || SQLERRM;
   END mto_main_prc;

   PROCEDURE mto_merge_main_prc (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_factor                    IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   )
   IS
      e_usr_exception        EXCEPTION;
      l_bal_quantity         NUMBER;
      l_order_quantity       NUMBER;
      l_product_line         VARCHAR2 (240);
      l_article_ticket       VARCHAR2 (240);
      l_kg_per_pkg           NUMBER;
      l_ins_row              VARCHAR2 (1);
      l_rtn_stat             VARCHAR2 (100);
      l_rtn_msg              VARCHAR2 (4000);
      l_count                NUMBER;
      l_secondary_plan_qty   NUMBER          := 0;
   BEGIN
      ---- debug_insert ('Manas-1:       ');
      fnd_file.put_line (fnd_file.LOG,
                         'Initiate XXDBL_RESOURCE_WORKBENCH_PKG.MTO_MAIN_PRC'
                        );
      --fnd_file.put_line (fnd_file.LOG,'Parent Order Number: '||p_transaction_id);
      fnd_file.put_line (fnd_file.LOG,
                         '------------------------------------------------'
                        );

      --
      ---- debug_insert ('Manas0:       ');
      BEGIN
         SELECT micv.segment1 product_line, micv.segment2 article_ticket,
                msib.attribute4 /*msib.attribute1*/ kg_per_pkg
           INTO l_product_line, l_article_ticket,
                l_kg_per_pkg
           FROM mtl_system_items_kfv msib, mtl_item_categories_v micv
          WHERE msib.inventory_item_id = p_inventory_item_id
            AND msib.organization_id = p_organization_id
            AND msib.inventory_item_id = micv.inventory_item_id
            AND msib.organization_id = micv.organization_id
            AND micv.category_set_name = 'DBL_SALES_PLAN_CAT'                                         /*IN (
                                                              SELECT mdcsfv.category_set_name
                                                                FROM mtl_default_category_sets_fk_v mdcsfv
                                                               WHERE 1 = 1
                                                                     AND mdcsfv.functional_area_desc = 'Planning')*/;
      --= 'Planning';
      EXCEPTION
         WHEN OTHERS
         THEN
            l_rtn_msg := 'Error to get Planning catg details - ' || SQLERRM;
            RAISE e_usr_exception;
      END;

      ---- debug_insert ('Manas1:       ');

      --
      SELECT COUNT (*)
        INTO l_count
        FROM xxdbl_dyehouse_routing_hdr hdr, xxdbl_dyehouse_routing_chart dtl
       WHERE hdr.hdr_id = dtl.hdr_id
         AND hdr.product_line = l_product_line
         AND hdr.article_ticket = l_article_ticket;

      -- AND hdr.kg_per_pkg = l_kg_per_pkg;

      --
      IF l_count = 0
      THEN
         l_rtn_msg := 'Routing Chart not found fot this Order Number!!!';
         RAISE e_usr_exception;
      END IF;

      ---- debug_insert ('Manas2:       ');
      --
      l_bal_quantity := p_parent_quantity;

      --
      WHILE l_bal_quantity > 0
      LOOP
         FOR c_vessel_csr IN (SELECT   dtl.*
                                  FROM xxdbl_dyehouse_routing_hdr hdr,
                                       xxdbl_dyehouse_routing_chart dtl
                                 WHERE hdr.hdr_id = dtl.hdr_id
                                   AND hdr.product_line = l_product_line
                                   AND hdr.article_ticket = l_article_ticket
                              -- AND hdr.kg_per_pkg = l_kg_per_pkg
                              ORDER BY to_weight DESC)
         LOOP
            /*debug_insert (   'c_vessel_csr.from_weight:       '
                          || c_vessel_csr.from_weight
                         );
            debug_insert (   'c_vessel_csr.to_weight:       '
                          || c_vessel_csr.to_weight
                         );
            debug_insert (   '(l_bal_quantity * p_factor):       '
                          || (l_bal_quantity * p_factor)
                         );*/
            l_ins_row := 'F';

            IF (l_bal_quantity * p_factor) >= c_vessel_csr.from_weight
            THEN
               /*debug_insert
                  ('(l_bal_quantity * p_factor) >= c_vessel_csr.from_weight       '
                  );*/
               IF (l_bal_quantity * p_factor) <= c_vessel_csr.to_weight
               THEN
                  /*debug_insert
                     ('(l_bal_quantity * p_factor) <= c_vessel_csr.to_weight');*/
                  l_order_quantity := l_bal_quantity;
                  /*debug_insert (   'l_order_quantity1:          '
                                || l_order_quantity
                               );*/
                  --
                  l_ins_row := 'T';
                  l_bal_quantity := 0;
               --
               ELSE
                  l_order_quantity :=
                                  FLOOR (c_vessel_csr.to_weight / (p_factor));
                  /*debug_insert (   'l_order_quantity2:          '
                                || l_order_quantity
                               );*/
                  --
                  l_ins_row := 'T';
                  l_bal_quantity := l_bal_quantity - l_order_quantity;
                  --debug_insert ('l_bal_quantity1:          ' || l_bal_quantity);
               --
               END IF;

               --
               IF l_ins_row = 'T'
               THEN
                  l_rtn_stat := 'S';
                  l_rtn_msg := NULL;
                  --debug_insert ('MANAS00001      ' || p_factor);
                  --debug_insert ('l_order_quantity3:       '
                  --              || l_order_quantity
                  --             );
                  l_secondary_plan_qty := l_order_quantity;
                  --debug_insert (   'l_secondary_plan_qty:       '
                  --              || l_secondary_plan_qty
                  --             );
                  insert_row
                     (p_organization_id              => p_organization_id,
                      p_organization_code            => p_organization_code,
                      p_order_header_id              => p_order_header_id,
                      p_order_number                 => p_order_number,
                      p_order_line_id                => p_order_line_id,
                      p_order_line_no                => p_order_line_no,
                      p_inventory_item_id            => p_inventory_item_id,
                      p_item_number                  => p_item_number,
                      p_item_description             => p_item_description,
                      p_article_ticket               => l_article_ticket,
                      p_product_line                 => l_product_line,
                      p_parent_quantity              => p_parent_quantity,
                      p_transaction_quantity         => l_secondary_plan_qty,
                      --l_order_quantity,
                      p_plan_quantity                => l_secondary_plan_qty,
                      --l_order_quantity,
                      p_parent_qty_uom               => p_parent_qty_uom,
                      p_transaction_qty_uom          => p_parent_qty_uom,
                      p_reference_type               => p_reference_type,
                      p_reference_header_id          => p_reference_header_id,
                      p_reference_line_id            => p_reference_line_id,
                      p_plan_start_date              => p_plan_start_date,
                      p_plan_end_date                => p_plan_end_date,
                      p_vessel_name                  => c_vessel_csr.resource_name,
                      p_recipe_id                    => p_recipe_id,
                      p_recipe_no                    => p_recipe_no,
                      p_recipe_version               => p_recipe_version,
                      p_recipe_validity_rule_id      => p_recipe_validity_rule_id,
                      p_special_instruction          => p_special_instruction,
                      p_status                       => p_status,
                      p_customer_id                  => p_customer_id,
                      p_customer_number              => p_customer_number,
                      p_customer_name                => p_customer_name,
                      p_customer_po_number           => p_customer_po_number,
                      p_batch_no                     => p_batch_no,
                      p_bacth_id                     => p_bacth_id,
                      p_attribute1                   => p_attribute1,
                      p_attribute2                   => p_attribute2,
                      p_attribute3                   => p_attribute3,
                      p_attribute4                   => p_attribute4,
                      p_attribute5                   => p_attribute5,
                      p_attribute6                   => p_attribute6,
                      p_attribute7                   => p_attribute7,
                      p_attribute8                   => p_attribute8,
                      p_attribute9                   => p_attribute9,
                      p_attribute10                  =>   l_secondary_plan_qty
                                                        * (1 - p_attribute11
                                                          )                          /*ROUND
                                                            ((  p_attribute10
                                                              / p_parent_quantity
                                                             ),
                                                             4
                                                            )*/                                                                                                                  /*(  (  l_secondary_plan_qty
                                                                  / p_parent_quantity
                                                                 )
                                                               * p_attribute10
                                                              )*/,
                      --p_attribute10,
                      p_attribute11                  => p_attribute11,
                      p_attribute12                  => p_attribute12,
                      p_attribute13                  => p_attribute13,
                      p_attribute14                  => p_attribute14,
                      p_attribute15                  => p_attribute15,
                      p_attribute16                  => p_attribute16,
                      p_attribute17                  => p_attribute17,
                      p_attribute18                  => p_attribute18,
                      p_attribute19                  => p_attribute19,
                      p_attribute20                  => p_attribute20,
                      p_transaction_source           => NVL
                                                           (p_transaction_source,
                                                            'MTO'
                                                           ),
                      p_lot_number                   => p_lot_number,
                      p_secondary_plan_qty           => ROUND
                                                           (  l_order_quantity
                                                            * p_factor,
                                                            2
                                                           ),
                      p_secondary_plan_qty_uom       => p_secondary_plan_qty_uom,
                      p_plan_name                    => p_plan_name,
                      p_transaction_id               => p_transaction_id,
                      p_orig_plan_start_date         => p_orig_plan_start_date,
                      p_orig_plan_end_date           => p_orig_plan_end_date,
                      p_parent_quantity_sec          => p_parent_quantity_sec,
                      p_parent_qty_uom_sec           => p_parent_qty_uom_sec,
                      x_rtn_stat                     => l_rtn_stat,
                      x_rtn_msg                      => l_rtn_msg
                     );

                  ---- debug_insert ('Manas5:       ');
                  IF l_rtn_stat <> 'S'
                  THEN
                     RAISE e_usr_exception;
                  END IF;

                  --
                  EXIT;
               END IF;
            END IF;
         END LOOP c_vessel_csr;
      END LOOP;

      --COMMIT;
      x_rtn_stat := 'S';
      x_rtn_msg := 'Records have been created successfully!';
   ---- debug_insert ('Manas6:       ');
   EXCEPTION
      WHEN e_usr_exception
      THEN
         ---- debug_insert ('Manas7:       ');
         --ROLLBACK;
         x_rtn_stat := 'E';
         x_rtn_msg := l_rtn_msg;
      WHEN OTHERS
      THEN
         ---- debug_insert ('Manas8:       ');
         --ROLLBACK;
         x_rtn_stat := 'E';
         x_rtn_msg :=
               'Unexpected Error to create resource work bench - ' || SQLERRM;
   END mto_merge_main_prc;

   PROCEDURE mto_main_prc_new (
      p_organization_id           IN       NUMBER DEFAULT NULL,
      p_organization_code         IN       VARCHAR2 DEFAULT NULL,
      p_order_header_id           IN       NUMBER DEFAULT NULL,
      p_order_number              IN       NUMBER DEFAULT NULL,
      p_order_line_id             IN       NUMBER DEFAULT NULL,
      p_order_line_no             IN       VARCHAR2 DEFAULT NULL,
      p_inventory_item_id         IN       NUMBER DEFAULT NULL,
      p_item_number               IN       VARCHAR2 DEFAULT NULL,
      p_item_description          IN       VARCHAR2 DEFAULT NULL,
      p_article_ticket            IN       VARCHAR2 DEFAULT NULL,
      p_product_line              IN       VARCHAR2 DEFAULT NULL,
      p_parent_quantity           IN       NUMBER DEFAULT NULL,
      p_transaction_quantity      IN       NUMBER DEFAULT NULL,
      p_plan_quantity             IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom            IN       VARCHAR2 DEFAULT NULL,
      p_transaction_qty_uom       IN       VARCHAR2 DEFAULT NULL,
      p_reference_type            IN       VARCHAR2 DEFAULT NULL,
      p_reference_header_id       IN       NUMBER DEFAULT NULL,
      p_reference_line_id         IN       NUMBER DEFAULT NULL,
      p_plan_start_date           IN       DATE DEFAULT NULL,
      p_plan_end_date             IN       DATE DEFAULT NULL,
      p_vessel_name               IN       VARCHAR2 DEFAULT NULL,
      p_recipe_id                 IN       NUMBER DEFAULT NULL,
      p_recipe_no                 IN       VARCHAR2 DEFAULT NULL,
      p_recipe_version            IN       VARCHAR2 DEFAULT NULL,
      p_recipe_validity_rule_id   IN       NUMBER DEFAULT NULL,
      p_special_instruction       IN       VARCHAR2 DEFAULT NULL,
      p_status                    IN       VARCHAR2 DEFAULT 'NEW',
      p_customer_id               IN       NUMBER DEFAULT NULL,
      p_customer_number           IN       VARCHAR2 DEFAULT NULL,
      p_customer_name             IN       VARCHAR2 DEFAULT NULL,
      p_customer_po_number        IN       VARCHAR2 DEFAULT NULL,
      p_batch_no                  IN       NUMBER DEFAULT NULL,
      p_bacth_id                  IN       NUMBER DEFAULT NULL,
      p_attribute1                IN       VARCHAR2 DEFAULT NULL,
      p_attribute2                IN       VARCHAR2 DEFAULT NULL,
      p_attribute3                IN       VARCHAR2 DEFAULT NULL,
      p_attribute4                IN       VARCHAR2 DEFAULT NULL,
      p_attribute5                IN       VARCHAR2 DEFAULT NULL,
      p_attribute6                IN       VARCHAR2 DEFAULT NULL,
      p_attribute7                IN       VARCHAR2 DEFAULT NULL,
      p_attribute8                IN       VARCHAR2 DEFAULT NULL,
      p_attribute9                IN       VARCHAR2 DEFAULT NULL,
      p_attribute10               IN       VARCHAR2 DEFAULT NULL,
      p_attribute11               IN       VARCHAR2 DEFAULT NULL,
      p_attribute12               IN       VARCHAR2 DEFAULT NULL,
      p_attribute13               IN       VARCHAR2 DEFAULT NULL,
      p_attribute14               IN       VARCHAR2 DEFAULT NULL,
      p_attribute15               IN       VARCHAR2 DEFAULT NULL,
      p_attribute16               IN       VARCHAR2 DEFAULT NULL,
      p_attribute17               IN       VARCHAR2 DEFAULT NULL,
      p_attribute18               IN       VARCHAR2 DEFAULT NULL,
      p_attribute19               IN       VARCHAR2 DEFAULT NULL,
      p_attribute20               IN       VARCHAR2 DEFAULT NULL,
      p_lot_number                IN       VARCHAR2 DEFAULT NULL,
      p_transaction_source        IN       VARCHAR2 DEFAULT NULL,
      p_factor                    IN       NUMBER DEFAULT NULL,
      p_secondary_plan_qty_uom    IN       VARCHAR2 DEFAULT NULL,
      p_plan_name                 IN       VARCHAR2 DEFAULT NULL,
      p_transaction_id            IN       NUMBER DEFAULT NULL,
      p_orig_plan_start_date      IN       DATE DEFAULT NULL,
      p_orig_plan_end_date        IN       DATE DEFAULT NULL,
      p_parent_quantity_sec       IN       NUMBER DEFAULT NULL,
      p_parent_qty_uom_sec        IN       VARCHAR2 DEFAULT NULL,
      x_rtn_stat                  OUT      VARCHAR2,
      x_rtn_msg                   OUT      VARCHAR2
   )
   IS
      e_usr_exception    EXCEPTION;
      l_bal_quantity     NUMBER;
      l_order_quantity   NUMBER;
      l_product_line     VARCHAR2 (240);
      l_article_ticket   VARCHAR2 (240);
      l_kg_per_pkg       NUMBER;
      l_ins_row          VARCHAR2 (1);
      l_rtn_stat         VARCHAR2 (100);
      l_rtn_msg          VARCHAR2 (4000);
      l_count            NUMBER;
      l_rec_count        NUMBER          := 0;
   BEGIN
      fnd_file.put_line (fnd_file.LOG,
                         'Initiate XXDBL_RESOURCE_WORKBENCH_PKG.MTO_MAIN_PRC'
                        );
      --fnd_file.put_line (fnd_file.LOG,'Parent Order Number: '||p_transaction_id);
      fnd_file.put_line (fnd_file.LOG,
                         '------------------------------------------------'
                        );

      --
      BEGIN
         SELECT micv.segment1 product_line, micv.segment2 article_ticket,
                msib.attribute4 /*msib.attribute1*/ kg_per_pkg
           INTO l_product_line, l_article_ticket,
                l_kg_per_pkg
           FROM mtl_system_items_kfv msib, mtl_item_categories_v micv
          WHERE msib.inventory_item_id = p_inventory_item_id
            AND msib.organization_id = p_organization_id
            AND msib.inventory_item_id = micv.inventory_item_id
            AND msib.organization_id = micv.organization_id
            AND micv.category_set_name = 'DBL_SALES_PLAN_CAT'                                         /*IN (
                                                              SELECT mdcsfv.category_set_name
                                                                FROM mtl_default_category_sets_fk_v mdcsfv
                                                               WHERE 1 = 1
                                                                     AND mdcsfv.functional_area_desc = 'Planning')*/;
      --= 'Planning';
      EXCEPTION
         WHEN OTHERS
         THEN
            l_rtn_msg := 'Error to get Planning catg details - ' || SQLERRM;
            RAISE e_usr_exception;
      END;

      BEGIN
         SELECT kg_per_pkg
           INTO l_kg_per_pkg
           FROM xxdbl_dyehouse_routing_hdr
          WHERE product_line = l_product_line
            AND article_ticket = l_article_ticket;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_kg_per_pkg := NULL;
      END;

      --
      SELECT COUNT (*)
        INTO l_count
        FROM xxdbl_dyehouse_routing_hdr hdr, xxdbl_dyehouse_routing_chart dtl
       WHERE hdr.hdr_id = dtl.hdr_id
         AND hdr.product_line = l_product_line
         AND hdr.article_ticket = l_article_ticket;

      -- AND hdr.kg_per_pkg = l_kg_per_pkg;

      --
      IF l_count = 0
      THEN
         l_rtn_msg := 'Routing Chart not found fot this Order Number!!!';
         RAISE e_usr_exception;
      END IF;

      --
      l_bal_quantity := p_parent_quantity;

      --
      FOR c_vessel_csr IN (SELECT   dtl.*
                               FROM xxdbl_dyehouse_routing_hdr hdr,
                                    xxdbl_dyehouse_routing_chart dtl
                              WHERE hdr.hdr_id = dtl.hdr_id
                                AND hdr.product_line = l_product_line
                                AND hdr.article_ticket = l_article_ticket
                                -- AND hdr.kg_per_pkg = l_kg_per_pkg
                                AND p_parent_quantity BETWEEN from_weight
                                                          AND to_weight
                           ORDER BY to_weight DESC)
      LOOP
         l_ins_row := 'F';
         --
         l_rtn_stat := 'S';
         l_rtn_msg := NULL;
         l_rec_count := l_rec_count + 1;

         IF l_rec_count = 1
         THEN
            insert_row_new
                     (p_organization_id              => p_organization_id,
                      p_organization_code            => p_organization_code,
                      p_order_header_id              => p_order_header_id,
                      p_order_number                 => p_order_number,
                      p_order_line_id                => p_order_line_id,
                      p_order_line_no                => p_order_line_no,
                      p_inventory_item_id            => p_inventory_item_id,
                      p_item_number                  => p_item_number,
                      p_item_description             => p_item_description,
                      p_article_ticket               => l_article_ticket,
                      p_product_line                 => l_product_line,
                      p_parent_quantity              => p_parent_quantity,
                      p_transaction_quantity         => p_parent_quantity,
                      p_plan_quantity                => p_parent_quantity,
                      p_parent_qty_uom               => p_parent_qty_uom,
                      p_transaction_qty_uom          => p_parent_qty_uom,
                      p_reference_type               => p_reference_type,
                      p_reference_header_id          => p_reference_header_id,
                      p_reference_line_id            => p_reference_line_id,
                      p_plan_start_date              => p_plan_start_date,
                      p_plan_end_date                => p_plan_end_date,
                      p_vessel_name                  => c_vessel_csr.resource_name,
                      p_recipe_id                    => p_recipe_id,
                      p_recipe_no                    => p_recipe_no,
                      p_recipe_version               => p_recipe_version,
                      p_recipe_validity_rule_id      => p_recipe_validity_rule_id,
                      p_special_instruction          => p_special_instruction,
                      p_status                       => p_status,
                      p_customer_id                  => p_customer_id,
                      p_customer_number              => p_customer_number,
                      p_customer_name                => p_customer_name,
                      p_customer_po_number           => p_customer_po_number,
                      p_batch_no                     => p_batch_no,
                      p_bacth_id                     => p_bacth_id,
                      p_attribute1                   => p_attribute1,
                      p_attribute2                   => p_attribute2,
                      p_attribute3                   => p_attribute3,
                      p_attribute4                   => p_attribute4,
                      p_attribute5                   => p_attribute5,
                      p_attribute6                   => p_attribute6,
                      p_attribute7                   => p_attribute7,
                      p_attribute8                   => p_attribute8,
                      p_attribute9                   => p_attribute9,
                      p_attribute10                  => p_attribute10,
                      p_attribute11                  => p_attribute11,
                      p_attribute12                  => p_attribute12,
                      p_attribute13                  => p_attribute13,
                      p_attribute14                  => p_attribute14,
                      p_attribute15                  => p_attribute15,
                      p_attribute16                  => p_attribute16,
                      p_attribute17                  => p_attribute17,
                      p_attribute18                  => p_attribute18,
                      p_attribute19                  => p_attribute19,
                      p_attribute20                  => p_attribute20,
                      p_transaction_source           => NVL
                                                           (p_transaction_source,
                                                            'MTO'
                                                           ),
                      p_lot_number                   => p_lot_number,
                      p_secondary_plan_qty           => ROUND
                                                           (  p_parent_quantity
                                                            * p_factor,
                                                            2
                                                           ),
                      p_secondary_plan_qty_uom       => p_secondary_plan_qty_uom,
                      p_plan_name                    => p_plan_name,
                      p_transaction_id               => p_transaction_id,
                      p_orig_plan_start_date         => p_orig_plan_start_date,
                      p_orig_plan_end_date           => p_orig_plan_end_date,
                      p_parent_quantity_sec          => p_parent_quantity_sec,
                      p_parent_qty_uom_sec           => p_parent_qty_uom_sec,
                      x_rtn_stat                     => l_rtn_stat,
                      x_rtn_msg                      => l_rtn_msg
                     );

            IF l_rtn_stat <> 'S'
            THEN
               RAISE e_usr_exception;
            END IF;
         END IF;
      END LOOP c_vessel_csr;

      IF l_rec_count < 1
      THEN
         FOR c_vessel_csr IN
            (SELECT   dtl.*
                 FROM xxdbl_dyehouse_routing_hdr hdr,
                      xxdbl_dyehouse_routing_chart dtl
                WHERE 1 = 1
                  AND hdr.hdr_id = dtl.hdr_id
                  AND hdr.product_line = l_product_line
                  AND hdr.article_ticket = l_article_ticket
                  --  AND hdr.kg_per_pkg = l_kg_per_pkg
                  AND to_weight = (SELECT MAX (to_weight)
                                     FROM xxdbl_dyehouse_routing_chart dtl1
                                    WHERE 1 = 1 AND dtl1.hdr_id = hdr.hdr_id)
             ORDER BY to_weight DESC)
         LOOP
            l_ins_row := 'F';
            --
            l_rtn_stat := 'S';
            l_rtn_msg := NULL;
            l_rec_count := l_rec_count + 1;

            IF l_rec_count = 1
            THEN
               insert_row_new
                     (p_organization_id              => p_organization_id,
                      p_organization_code            => p_organization_code,
                      p_order_header_id              => p_order_header_id,
                      p_order_number                 => p_order_number,
                      p_order_line_id                => p_order_line_id,
                      p_order_line_no                => p_order_line_no,
                      p_inventory_item_id            => p_inventory_item_id,
                      p_item_number                  => p_item_number,
                      p_item_description             => p_item_description,
                      p_article_ticket               => l_article_ticket,
                      p_product_line                 => l_product_line,
                      p_parent_quantity              => p_parent_quantity,
                      p_transaction_quantity         => p_parent_quantity,
                      p_plan_quantity                => p_parent_quantity,
                      p_parent_qty_uom               => p_parent_qty_uom,
                      p_transaction_qty_uom          => p_parent_qty_uom,
                      p_reference_type               => p_reference_type,
                      p_reference_header_id          => p_reference_header_id,
                      p_reference_line_id            => p_reference_line_id,
                      p_plan_start_date              => p_plan_start_date,
                      p_plan_end_date                => p_plan_end_date,
                      p_vessel_name                  => c_vessel_csr.resource_name,
                      p_recipe_id                    => p_recipe_id,
                      p_recipe_no                    => p_recipe_no,
                      p_recipe_version               => p_recipe_version,
                      p_recipe_validity_rule_id      => p_recipe_validity_rule_id,
                      p_special_instruction          => p_special_instruction,
                      p_status                       => p_status,
                      p_customer_id                  => p_customer_id,
                      p_customer_number              => p_customer_number,
                      p_customer_name                => p_customer_name,
                      p_customer_po_number           => p_customer_po_number,
                      p_batch_no                     => p_batch_no,
                      p_bacth_id                     => p_bacth_id,
                      p_attribute1                   => p_attribute1,
                      p_attribute2                   => p_attribute2,
                      p_attribute3                   => p_attribute3,
                      p_attribute4                   => p_attribute4,
                      p_attribute5                   => p_attribute5,
                      p_attribute6                   => p_attribute6,
                      p_attribute7                   => p_attribute7,
                      p_attribute8                   => p_attribute8,
                      p_attribute9                   => p_attribute9,
                      p_attribute10                  => p_attribute10,
                      p_attribute11                  => p_attribute11,
                      p_attribute12                  => p_attribute12,
                      p_attribute13                  => p_attribute13,
                      p_attribute14                  => p_attribute14,
                      p_attribute15                  => p_attribute15,
                      p_attribute16                  => p_attribute16,
                      p_attribute17                  => p_attribute17,
                      p_attribute18                  => p_attribute18,
                      p_attribute19                  => p_attribute19,
                      p_attribute20                  => p_attribute20,
                      p_transaction_source           => NVL
                                                           (p_transaction_source,
                                                            'MTO'
                                                           ),
                      p_lot_number                   => p_lot_number,
                      p_secondary_plan_qty           => ROUND
                                                           (  p_parent_quantity
                                                            * p_factor,
                                                            2
                                                           ),
                      p_secondary_plan_qty_uom       => p_secondary_plan_qty_uom,
                      p_plan_name                    => p_plan_name,
                      p_transaction_id               => p_transaction_id,
                      p_orig_plan_start_date         => p_orig_plan_start_date,
                      p_orig_plan_end_date           => p_orig_plan_end_date,
                      p_parent_quantity_sec          => p_parent_quantity_sec,
                      p_parent_qty_uom_sec           => p_parent_qty_uom_sec,
                      x_rtn_stat                     => l_rtn_stat,
                      x_rtn_msg                      => l_rtn_msg
                     );

               IF l_rtn_stat <> 'S'
               THEN
                  RAISE e_usr_exception;
               END IF;
            END IF;
         END LOOP c_vessel_csr;
      END IF;

      --COMMIT;
      x_rtn_stat := 'S';
      x_rtn_msg := 'Records have been created successfully!';
   EXCEPTION
      WHEN e_usr_exception
      THEN
         --ROLLBACK;
         x_rtn_stat := 'E';
         x_rtn_msg := l_rtn_msg;
      WHEN OTHERS
      THEN
         --ROLLBACK;
         x_rtn_stat := 'E';
         x_rtn_msg :=
               'Unexpected Error to create resource work bench - ' || SQLERRM;
   END mto_main_prc_new;

--
   PROCEDURE ascp_archive_prc
   IS
   BEGIN
      INSERT INTO xxdbl_resource_workbench1
                  (resource_workbench_id, organization_id, organization_code,
                   order_header_id, order_number, order_line_id,
                   order_line_no, inventory_item_id, item_number,
                   item_description, article_ticket, product_line,
                   parent_quantity, transaction_quantity, plan_quantity,
                   parent_qty_uom, transaction_qty_uom, reference_type,
                   reference_header_id, reference_line_id, plan_start_date,
                   plan_end_date, vessel_name, recipe_id, recipe_no,
                   recipe_version, recipe_validity_rule_id,
                   special_instruction, status, customer_id, customer_number,
                   customer_name, customer_po_number, batch_no, bacth_id,
                   attribute1, attribute2, attribute3, attribute4,
                   attribute5, attribute6, attribute7, attribute8,
                   attribute9, attribute10, attribute11, attribute12,
                   attribute13, attribute14, attribute15, attribute16,
                   attribute17, attribute18, attribute19, attribute20,
                   last_update_date, last_updated_by, creation_date,
                   created_by, last_update_login, transaction_source,
                   lot_number, secondary_plan_qty, secondary_plan_qty_uom,
                   plan_name, transaction_id, orig_plan_start_date,
                   orig_plan_end_date)
         (SELECT resource_workbench_id, organization_id, organization_code,
                 order_header_id, order_number, order_line_id, order_line_no,
                 inventory_item_id, item_number, item_description,
                 article_ticket, product_line, parent_quantity,
                 transaction_quantity, plan_quantity, parent_qty_uom,
                 transaction_qty_uom, reference_type, reference_header_id,
                 reference_line_id, plan_start_date, plan_end_date,
                 vessel_name, recipe_id, recipe_no, recipe_version,
                 recipe_validity_rule_id, special_instruction, status,
                 customer_id, customer_number, customer_name,
                 customer_po_number, batch_no, bacth_id, attribute1,
                 attribute2, attribute3, attribute4, attribute5, attribute6,
                 attribute7, attribute8, attribute9, attribute10,
                 attribute11, attribute12, attribute13, attribute14,
                 attribute15, attribute16, attribute17, attribute18,
                 attribute19, attribute20, last_update_date, last_updated_by,
                 creation_date, created_by, last_update_login,
                 transaction_source, lot_number, secondary_plan_qty,
                 secondary_plan_qty_uom, plan_name, transaction_id,
                 orig_plan_start_date, orig_plan_end_date
            FROM xxdbl_resource_workbench
           WHERE 1 = 1 AND /*status <> 'NEW' AND */ transaction_source =
                                                                       'ASCP');

      --
      DELETE FROM xxdbl_resource_workbench
            WHERE transaction_source = 'ASCP';

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         fnd_file.put_line (fnd_file.LOG,
                               'Unexpected Error to populate archive - '
                            || SQLERRM
                           );
   END ascp_archive_prc;

   -- Added By Manas on 04-Oct-2018 Starts
   PROCEDURE ascp_inline_archive_prc (
      p_plan_name           IN   VARCHAR2,
      p_transaction_id      IN   NUMBER,
      p_order_number        IN   VARCHAR2,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   )
   IS
   BEGIN
      INSERT INTO xxdbl_resource_workbench1
                  (resource_workbench_id, organization_id, organization_code,
                   order_header_id, order_number, order_line_id,
                   order_line_no, inventory_item_id, item_number,
                   item_description, article_ticket, product_line,
                   parent_quantity, transaction_quantity, plan_quantity,
                   parent_qty_uom, transaction_qty_uom, reference_type,
                   reference_header_id, reference_line_id, plan_start_date,
                   plan_end_date, vessel_name, recipe_id, recipe_no,
                   recipe_version, recipe_validity_rule_id,
                   special_instruction, status, customer_id, customer_number,
                   customer_name, customer_po_number, batch_no, bacth_id,
                   attribute1, attribute2, attribute3, attribute4,
                   attribute5, attribute6, attribute7, attribute8,
                   attribute9, attribute10, attribute11, attribute12,
                   attribute13, attribute14, attribute15, attribute16,
                   attribute17, attribute18, attribute19, attribute20,
                   last_update_date, last_updated_by, creation_date,
                   created_by, last_update_login, transaction_source,
                   lot_number, secondary_plan_qty, secondary_plan_qty_uom,
                   plan_name, transaction_id, orig_plan_start_date,
                   orig_plan_end_date)
         (SELECT resource_workbench_id, organization_id, organization_code,
                 order_header_id, order_number, order_line_id, order_line_no,
                 inventory_item_id, item_number, item_description,
                 article_ticket, product_line, parent_quantity,
                 transaction_quantity, plan_quantity, parent_qty_uom,
                 transaction_qty_uom, reference_type, reference_header_id,
                 reference_line_id, plan_start_date, plan_end_date,
                 vessel_name, recipe_id, recipe_no, recipe_version,
                 recipe_validity_rule_id, special_instruction, status,
                 customer_id, customer_number, customer_name,
                 customer_po_number, batch_no, bacth_id, attribute1,
                 attribute2, attribute3, attribute4, attribute5, attribute6,
                 attribute7, attribute8, attribute9, attribute10,
                 attribute11, attribute12, attribute13, attribute14,
                 attribute15, attribute16, attribute17, attribute18,
                 attribute19, attribute20, last_update_date, last_updated_by,
                 creation_date, created_by, last_update_login,
                 transaction_source, lot_number, secondary_plan_qty,
                 secondary_plan_qty_uom, plan_name, transaction_id,
                 orig_plan_start_date, orig_plan_end_date
            FROM xxdbl_resource_workbench
           WHERE 1 = 1
             AND transaction_source = 'ASCP'
             AND NVL (plan_name, '##') =
                                      NVL (p_plan_name, NVL (plan_name, '##'))
             AND NVL (transaction_id, -1) =
                               NVL (p_transaction_id, NVL (transaction_id, -1))
             AND NVL (order_number, -1) =
                                   NVL (p_order_number, NVL (order_number, -1))
             AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
             AND status IN ('NEW', 'ERROR', 'MERGED', 'MERGE_NEW'));

      --
      DELETE FROM xxdbl_resource_workbench
            WHERE 1 = 1
              AND transaction_source = 'ASCP'
              AND NVL (plan_name, '##') =
                                      NVL (p_plan_name, NVL (plan_name, '##'))
              AND NVL (transaction_id, -1) =
                               NVL (p_transaction_id, NVL (transaction_id, -1))
              AND NVL (order_number, -1) =
                                   NVL (p_order_number, NVL (order_number, -1))
              AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
              AND status IN ('NEW', 'ERROR', 'MERGED', 'MERGE_NEW');

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         fnd_file.put_line (fnd_file.LOG,
                               'Unexpected Error to populate archive - '
                            || SQLERRM
                           );
   END ascp_inline_archive_prc;

   PROCEDURE ascp_inline_archive_prc_wo (
      p_plan_name            IN   VARCHAR2,
      p_transaction_id       IN   NUMBER,
      p_transaction_source        VARCHAR2 DEFAULT 'ASCP',
      p_inventory_item_id    IN   NUMBER,
      p_item_number          IN   VARCHAR2,
      p_item_description     IN   VARCHAR2,
      p_organization_id      IN   NUMBER,
      p_organization_code    IN   VARCHAR2,
      p_lot_number           IN   VARCHAR2,
      p_customer_po_number   IN   VARCHAR2,
      p_customer_number      IN   VARCHAR2,
      p_customer_name        IN   VARCHAR2,
      p_customer_id          IN   NUMBER,
      p_order_number         IN   NUMBER,
      p_order_line_no        IN   VARCHAR2,
      p_order_header_id      IN   NUMBER,
      p_order_line_id        IN   NUMBER
   )
   IS
   BEGIN
      INSERT INTO xxdbl_resource_workbench1
                  (resource_workbench_id, organization_id, organization_code,
                   order_header_id, order_number, order_line_id,
                   order_line_no, inventory_item_id, item_number,
                   item_description, article_ticket, product_line,
                   parent_quantity, transaction_quantity, plan_quantity,
                   parent_qty_uom, transaction_qty_uom, reference_type,
                   reference_header_id, reference_line_id, plan_start_date,
                   plan_end_date, vessel_name, recipe_id, recipe_no,
                   recipe_version, recipe_validity_rule_id,
                   special_instruction, status, customer_id, customer_number,
                   customer_name, customer_po_number, batch_no, bacth_id,
                   attribute1, attribute2, attribute3, attribute4,
                   attribute5, attribute6, attribute7, attribute8,
                   attribute9, attribute10, attribute11, attribute12,
                   attribute13, attribute14, attribute15, attribute16,
                   attribute17, attribute18, attribute19, attribute20,
                   last_update_date, last_updated_by, creation_date,
                   created_by, last_update_login, transaction_source,
                   lot_number, secondary_plan_qty, secondary_plan_qty_uom,
                   plan_name, transaction_id, orig_plan_start_date,
                   orig_plan_end_date)
         (SELECT resource_workbench_id, organization_id, organization_code,
                 order_header_id, order_number, order_line_id, order_line_no,
                 inventory_item_id, item_number, item_description,
                 article_ticket, product_line, parent_quantity,
                 transaction_quantity, plan_quantity, parent_qty_uom,
                 transaction_qty_uom, reference_type, reference_header_id,
                 reference_line_id, plan_start_date, plan_end_date,
                 vessel_name, recipe_id, recipe_no, recipe_version,
                 recipe_validity_rule_id, special_instruction, status,
                 customer_id, customer_number, customer_name,
                 customer_po_number, batch_no, bacth_id, attribute1,
                 attribute2, attribute3, attribute4, attribute5, attribute6,
                 attribute7, attribute8, attribute9, attribute10,
                 attribute11, attribute12, attribute13, attribute14,
                 attribute15, attribute16, attribute17, attribute18,
                 attribute19, attribute20, last_update_date, last_updated_by,
                 creation_date, created_by, last_update_login,
                 transaction_source, lot_number, secondary_plan_qty,
                 secondary_plan_qty_uom, plan_name, transaction_id,
                 orig_plan_start_date, orig_plan_end_date
            FROM xxdbl_resource_workbench
           WHERE 1 = 1
             AND transaction_source = p_transaction_source            --'ASCP'
             AND NVL (plan_name, '##') =
                                      NVL (p_plan_name, NVL (plan_name, '##'))
             AND NVL (transaction_id, -1) =
                               NVL (p_transaction_id, NVL (transaction_id, -1))
             AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
             AND NVL (item_number, '##') =
                                  NVL (p_item_number, NVL (item_number, '##'))
             AND NVL (item_description, '##') =
                        NVL (p_item_description, NVL (item_description, '##'))
             AND NVL (organization_id, -1) =
                             NVL (p_organization_id, NVL (organization_id, -1))
             AND NVL (organization_code, '##') =
                      NVL (p_organization_code, NVL (organization_code, '##'))
             AND NVL (lot_number, '##') =
                                    NVL (p_lot_number, NVL (lot_number, '##'))
             AND NVL (customer_po_number, '##') =
                    NVL (p_customer_po_number, NVL (customer_po_number, '##'))
             AND NVL (customer_number, '##') =
                          NVL (p_customer_number, NVL (customer_number, '##'))
             AND NVL (customer_name, '##') =
                              NVL (p_customer_name, NVL (customer_name, '##'))
             AND NVL (customer_id, -1) =
                                     NVL (p_customer_id, NVL (customer_id, -1))
             AND NVL (order_number, -1) =
                                   NVL (p_order_number, NVL (order_number, -1))
             AND NVL (order_line_no, '##') =
                              NVL (p_order_line_no, NVL (order_line_no, '##'))
             AND NVL (order_header_id, -1) =
                             NVL (p_order_header_id, NVL (order_header_id, -1))
             AND NVL (order_line_id, -1) =
                                 NVL (p_order_line_id, NVL (order_line_id, -1))
             AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
             AND status IN ('NEW', 'ERROR', 'MERGED', 'MERGE_NEW'));

      --
      DELETE FROM xxdbl_resource_workbench
            WHERE 1 = 1
              AND transaction_source = p_transaction_source           --'ASCP'
              AND NVL (plan_name, '##') =
                                      NVL (p_plan_name, NVL (plan_name, '##'))
              AND NVL (transaction_id, -1) =
                               NVL (p_transaction_id, NVL (transaction_id, -1))
              AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
              AND NVL (item_number, '##') =
                                  NVL (p_item_number, NVL (item_number, '##'))
              AND NVL (item_description, '##') =
                        NVL (p_item_description, NVL (item_description, '##'))
              AND NVL (organization_id, -1) =
                             NVL (p_organization_id, NVL (organization_id, -1))
              AND NVL (organization_code, '##') =
                      NVL (p_organization_code, NVL (organization_code, '##'))
              AND NVL (lot_number, '##') =
                                    NVL (p_lot_number, NVL (lot_number, '##'))
              -- Manas 28-May-2019 it was commented Starts
              AND NVL (customer_po_number, '##') =
                     NVL (p_customer_po_number,
                          NVL (customer_po_number, '##'))
              AND NVL (customer_number, '##') =
                          NVL (p_customer_number, NVL (customer_number, '##'))
              AND NVL (customer_name, '##') =
                              NVL (p_customer_name, NVL (customer_name, '##'))
              AND NVL (customer_id, -1) =
                                     NVL (p_customer_id, NVL (customer_id, -1))
              AND NVL (order_number, -1) =
                                   NVL (p_order_number, NVL (order_number, -1))
              AND NVL (order_line_no, '##') =
                              NVL (p_order_line_no, NVL (order_line_no, '##'))
              AND NVL (order_header_id, -1) =
                             NVL (p_order_header_id, NVL (order_header_id, -1))
              AND NVL (order_line_id, -1) =
                                 NVL (p_order_line_id, NVL (order_line_id, -1))
              AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
              -- Manas 28-May-2019 it was commented Ends
              AND status IN ('NEW', 'ERROR', 'MERGED', 'MERGE_NEW');

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         fnd_file.put_line (fnd_file.LOG,
                               'Unexpected Error to populate archive - '
                            || SQLERRM
                           );
   END ascp_inline_archive_prc_wo;

   FUNCTION get_remainning_quantity (
      p_order_number        IN   NUMBER,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_total_quantity        NUMBER := 0;
      l_remainning_quantity   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT SUM (NVL (transaction_quantity, 0))
           INTO l_total_quantity
           FROM xxdbl_resource_workbench
          WHERE 1 = 1
            AND order_number = p_order_number
            AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
            AND status IN ('NEW', 'ERROR', 'MERGE_NEW');
      EXCEPTION
         WHEN OTHERS
         THEN
            l_total_quantity := 0;
      END;

      l_remainning_quantity := NVL (l_total_quantity, 0);

      IF l_remainning_quantity < 0
      THEN
         RETURN 0;
      ELSE
         RETURN l_remainning_quantity;
      END IF;
   END get_remainning_quantity;

   FUNCTION get_remainning_quantity_wo (
      p_transaction_source   IN   VARCHAR2 DEFAULT 'ASCP',
      p_lot_number           IN   VARCHAR2 DEFAULT NULL,
      p_customer_po_number   IN   VARCHAR2 DEFAULT NULL,
      p_customer_number      IN   VARCHAR2 DEFAULT NULL,
      p_customer_name        IN   VARCHAR2 DEFAULT NULL,
      p_customer_id          IN   NUMBER DEFAULT NULL,
      p_order_number         IN   NUMBER DEFAULT NULL,
      p_order_line_no        IN   VARCHAR2 DEFAULT NULL,
      p_order_header_id      IN   NUMBER DEFAULT NULL,
      p_order_line_id        IN   NUMBER DEFAULT NULL,
      p_inventory_item_id    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_total_quantity        NUMBER := 0;
      l_remainning_quantity   NUMBER := 0;
   BEGIN
      IF p_transaction_source != 'ASCP'
      THEN
         BEGIN
            SELECT SUM (NVL (plan_quantity, 0))
              --SUM (NVL (secondary_plan_qty, 0))
            INTO   l_total_quantity
              FROM xxdbl_resource_workbench
             WHERE 1 = 1
               --AND order_number = p_order_number
               AND status IN ('NEW', 'ERROR', 'MERGE_NEW')
               AND transaction_source = p_transaction_source
               AND NVL (lot_number, '##') =
                                    NVL (p_lot_number, NVL (lot_number, '##'))
               AND NVL (customer_po_number, '##') =
                      NVL (p_customer_po_number,
                           NVL (customer_po_number, '##')
                          )
               AND NVL (customer_number, '##') =
                          NVL (p_customer_number, NVL (customer_number, '##'))
               AND NVL (customer_name, '##') =
                              NVL (p_customer_name, NVL (customer_name, '##'))
               AND NVL (customer_id, -1) =
                                     NVL (p_customer_id, NVL (customer_id, -1))
               AND NVL (order_number, -1) =
                                   NVL (p_order_number, NVL (order_number, -1))
               AND NVL (order_line_no, '##') =
                              NVL (p_order_line_no, NVL (order_line_no, '##'))
               AND NVL (order_header_id, -1) =
                             NVL (p_order_header_id, NVL (order_header_id, -1))
               AND NVL (order_line_id, -1) =
                                 NVL (p_order_line_id, NVL (order_line_id, -1))
               AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1));
         EXCEPTION
            WHEN OTHERS
            THEN
               l_total_quantity := 0;
         END;
      ELSE
         BEGIN
            SELECT SUM (NVL (secondary_plan_qty, NVL (plan_quantity, 0)))
              INTO l_total_quantity
              FROM xxdbl_resource_workbench
             WHERE 1 = 1
               --AND order_number = p_order_number
               AND status IN ('NEW', 'ERROR', 'MERGE_NEW')
               AND transaction_source = p_transaction_source
               AND NVL (lot_number, '##') =
                                    NVL (p_lot_number, NVL (lot_number, '##'))
               AND NVL (customer_po_number, '##') =
                      NVL (p_customer_po_number,
                           NVL (customer_po_number, '##')
                          )
               AND NVL (customer_number, '##') =
                          NVL (p_customer_number, NVL (customer_number, '##'))
               AND NVL (customer_name, '##') =
                              NVL (p_customer_name, NVL (customer_name, '##'))
               AND NVL (customer_id, -1) =
                                     NVL (p_customer_id, NVL (customer_id, -1))
               AND NVL (order_number, -1) =
                                   NVL (p_order_number, NVL (order_number, -1))
               AND NVL (order_line_no, '##') =
                              NVL (p_order_line_no, NVL (order_line_no, '##'))
               AND NVL (order_header_id, -1) =
                             NVL (p_order_header_id, NVL (order_header_id, -1))
               AND NVL (order_line_id, -1) =
                                 NVL (p_order_line_id, NVL (order_line_id, -1))
               AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1));
         EXCEPTION
            WHEN OTHERS
            THEN
               l_total_quantity := 0;
         END;
      END IF;

      l_remainning_quantity := NVL (l_total_quantity, 0);

      IF l_remainning_quantity < 0
      THEN
         RETURN 0;
      ELSE
         RETURN l_remainning_quantity;
      END IF;
   END get_remainning_quantity_wo;

   FUNCTION get_remain_quantity_wo_ascp (
      p_transaction_source        VARCHAR2 DEFAULT 'ASCP',
      p_inventory_item_id    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_total_quantity        NUMBER := 0;
      l_remainning_quantity   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT SUM (NVL (secondary_plan_qty, NVL (plan_quantity, 0)))
           INTO l_total_quantity
           FROM xxdbl_resource_workbench
          WHERE 1 = 1
            --AND order_number = p_order_number
            AND status IN ('NEW', 'ERROR', 'MERGE_NEW')
            AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
            AND transaction_source = p_transaction_source;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_total_quantity := 0;
      END;

      l_remainning_quantity := NVL (l_total_quantity, 0);

      IF l_remainning_quantity < 0
      THEN
         RETURN 0;
      ELSE
         RETURN l_remainning_quantity;
      END IF;
   END get_remain_quantity_wo_ascp;

   FUNCTION get_remain_quantity_wo_mto (
      p_transaction_source   IN   VARCHAR2 DEFAULT 'MTO',
      p_lot_number           IN   VARCHAR2 DEFAULT NULL,
      p_customer_po_number   IN   VARCHAR2 DEFAULT NULL,
      p_customer_number      IN   VARCHAR2 DEFAULT NULL,
      p_customer_name        IN   VARCHAR2 DEFAULT NULL,
      p_customer_id          IN   NUMBER DEFAULT NULL,
      p_order_number         IN   NUMBER DEFAULT NULL,
      p_order_line_no        IN   VARCHAR2 DEFAULT NULL,
      p_order_header_id      IN   NUMBER DEFAULT NULL,
      p_order_line_id        IN   NUMBER DEFAULT NULL,
      p_inventory_item_id    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_total_quantity        NUMBER := 0;
      l_remainning_quantity   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT SUM (NVL (attribute10, 0))
           INTO l_total_quantity
           FROM xxdbl_resource_workbench
          WHERE 1 = 1
            --AND order_number = p_order_number
            AND status IN ('NEW', 'ERROR', 'MERGE_NEW')
            AND transaction_source = p_transaction_source
            AND NVL (lot_number, '##') =
                                    NVL (p_lot_number, NVL (lot_number, '##'))
            AND NVL (customer_po_number, '##') =
                    NVL (p_customer_po_number, NVL (customer_po_number, '##'))
            AND NVL (customer_number, '##') =
                          NVL (p_customer_number, NVL (customer_number, '##'))
            AND NVL (customer_name, '##') =
                              NVL (p_customer_name, NVL (customer_name, '##'))
            AND NVL (customer_id, -1) =
                                     NVL (p_customer_id, NVL (customer_id, -1))
            AND NVL (order_number, -1) =
                                   NVL (p_order_number, NVL (order_number, -1))
            AND NVL (order_line_no, '##') =
                              NVL (p_order_line_no, NVL (order_line_no, '##'))
            AND NVL (order_header_id, -1) =
                             NVL (p_order_header_id, NVL (order_header_id, -1))
            AND NVL (order_line_id, -1) =
                                 NVL (p_order_line_id, NVL (order_line_id, -1))
            AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1));
      EXCEPTION
         WHEN OTHERS
         THEN
            l_total_quantity := 0;
      END;

      l_remainning_quantity := NVL (l_total_quantity, 0);

      IF l_remainning_quantity < 0
      THEN
         RETURN 0;
      ELSE
         RETURN l_remainning_quantity;
      END IF;
   END get_remain_quantity_wo_mto;

   FUNCTION get_remainning_quantity_sec (
      p_order_number        IN   NUMBER,
      p_inventory_item_id   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_total_quantity        NUMBER := 0;
      l_remainning_quantity   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT SUM (NVL (secondary_plan_qty, NVL (plan_quantity, 0)))
           INTO l_total_quantity
           FROM xxdbl_resource_workbench
          WHERE 1 = 1
            AND order_number = p_order_number
            AND NVL (inventory_item_id, -1) =
                         NVL (p_inventory_item_id, NVL (inventory_item_id, -1))
            AND status IN ('NEW', 'ERROR', 'MERGE_NEW');
      EXCEPTION
         WHEN OTHERS
         THEN
            l_total_quantity := 0;
      END;

      l_remainning_quantity := NVL (l_total_quantity, 0);

      IF l_remainning_quantity < 0
      THEN
         RETURN 0;
      ELSE
         RETURN l_remainning_quantity;
      END IF;
   END get_remainning_quantity_sec;

   FUNCTION get_remainning_uom_sec (p_uom_code IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      IF p_uom_code = 'KG'
      THEN
         RETURN 'CON';
      ELSIF p_uom_code = 'CON'
      THEN
         RETURN 'KG';
      ELSE
         RETURN 'NA';
      END IF;
   END get_remainning_uom_sec;

   FUNCTION execute_immediate1 (p_ids IN VARCHAR2)
      RETURN DATE
   IS
      l_plan_start_date   DATE;
      l_string            VARCHAR2 (4000) := NULL;
   BEGIN
      l_string :=
            'SELECT MIN (plan_start_date) FROM xxdbl_resource_workbench WHERE resource_workbench_id IN ('
         || p_ids
         || ')';

      /*EXECUTE IMMEDIATE    'SELECT MIN (plan_start_date) FROM xxdbl_resource_workbench WHERE resource_workbench_id IN ('
                        || ':p_ids'
                        || ')'
                   INTO l_plan_start_date
                  USING p_ids;*/
      EXECUTE IMMEDIATE l_string
                   INTO l_plan_start_date;

      RETURN l_plan_start_date;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END execute_immediate1;

   FUNCTION execute_immediate2 (p_ids IN VARCHAR2)
      RETURN DATE
   IS
      l_plan_end_date   DATE;
      l_string          VARCHAR2 (4000) := NULL;
   BEGIN
      l_string :=
            'SELECT MAX (plan_end_date) FROM xxdbl_resource_workbench WHERE resource_workbench_id IN ('
         || p_ids
         || ')';

      EXECUTE IMMEDIATE l_string
                   INTO l_plan_end_date;

      RETURN l_plan_end_date;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END execute_immediate2;

   PROCEDURE execute_immediate3 (p_ids IN VARCHAR2)
   IS
      l_plan_quantity           NUMBER;
      l_plan_quantity_new       NUMBER;
      l_string                  VARCHAR2 (4000) := NULL;
      l_delta                   NUMBER          := 0;
      l_resource_workbench_id   NUMBER;
   BEGIN
      -- debug_insert ('p_ids:       '||p_ids);
      l_string :=
            'SELECT SUM (PLAN_QUANTITY) FROM xxdbl_resource_workbench WHERE resource_workbench_id IN ('
         || p_ids
         || ')';

      EXECUTE IMMEDIATE l_string
                   INTO l_plan_quantity;

      -- debug_insert ('l_plan_quantity:       '||l_plan_quantity);
      l_string :=
            'SELECT SUM (plan_quantity) FROM xxdbl_resource_workbench WHERE attribute7 ='''
         || p_ids
         || '''';

      EXECUTE IMMEDIATE l_string
                   INTO l_plan_quantity_new;

      -- debug_insert ('l_plan_quantity_new:       '||l_plan_quantity_new);
      l_delta := NVL (l_plan_quantity, 0) - NVL (l_plan_quantity_new, 0);
      l_string :=
            'SELECT MAX (resource_workbench_id) FROM xxdbl_resource_workbench WHERE attribute7 ='''
         || p_ids
         || '''';

      EXECUTE IMMEDIATE l_string
                   INTO l_resource_workbench_id;

      UPDATE xxdbl_resource_workbench
         SET plan_quantity = NVL (plan_quantity, 0) + l_delta
       WHERE resource_workbench_id = l_resource_workbench_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END execute_immediate3;

   FUNCTION get_yarn_process_loss (p_article_ticket_mumber IN VARCHAR2)
      RETURN NUMBER
   IS
      l_yarn_process_loss   NUMBER := 0;
   BEGIN
      /*SELECT fltv.description                                  -- fltv.meaning
        INTO l_yarn_process_loss
        FROM fnd_lookup_values fltv
       WHERE 1 = 1
         AND fltv.lookup_type = 'YARN_PROCESS_LOSS'
         AND fltv.lookup_code LIKE '%' || p_article_ticket_mumber || '%'
         AND ROWNUM = 1;*/
      SELECT NVL (ffvl.attribute1, 0)
        INTO l_yarn_process_loss
        FROM fnd_flex_vset_v ffv, fnd_flex_values_vl ffvl
       WHERE 1 = 1
         AND ffv.flex_value_set_id = ffvl.flex_value_set_id
         AND ffv.parent_value_set_name = 'DBL_ARTICLE_TICKET'
         AND ffvl.flex_value = p_article_ticket_mumber
         AND ROWNUM = 1;

      RETURN l_yarn_process_loss;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END get_yarn_process_loss;

-- Added By Manas on 04-Oct-2018 Ends
   PROCEDURE parent_child_form_qty (
      p_org_id      IN       NUMBER,
      p_item_id     IN       NUMBER,
      x_error_msg   OUT      VARCHAR2,
      x_factor      OUT      NUMBER
   )
   IS
      v_parent_prod_qty    NUMBER;
      v_parent_ingr_qty    NUMBER;
      v_child_prod_qty     NUMBER;
      v_child_gt_qty       NUMBER;
      v_parent_item_code   VARCHAR2 (400);
      v_item_type          VARCHAR2 (400);
      v_recipe_no          VARCHAR2 (400);
      v_formula_id         NUMBER;
      v_child_formula_no   VARCHAR2 (400);
      v_child_formula_id   NUMBER;
      check_point          NUMBER;
      kg_per_cone          NUMBER;
      l_error_code         VARCHAR2 (4000) := NULL;
      l_error_message      VARCHAR2 (4000) := NULL;
   BEGIN
      -- find parent product code. If return -999991 then item code does not exist
      BEGIN
         SELECT segment1
           INTO v_parent_item_code
           FROM mtl_system_items_b msib
          WHERE msib.organization_id = p_org_id
            AND msib.inventory_item_id = p_item_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_code := SQLCODE;
            l_error_message := SUBSTR (SQLERRM, 1, 150);
            x_error_msg :=
                  'item code does not exist:   '
               || l_error_code
               || ':     '
               || l_error_message;
            x_factor := -1;
      END;

      /*
      -- check it is sewing thread. If return -999992 then item type null
      BEGIN
         SELECT item_type
           INTO v_item_type
           FROM mtl_system_items_b
          WHERE inventory_item_id = p_item_id AND organization_id = p_org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            check_point := -999992;
            RETURN check_point;
      END;

      -- if return -999993 then item is not sewing thread
      IF v_item_type <> 'SEWING THREAD'
      THEN
         check_point := -999993;
         RETURN check_point;
      END IF;*/

      -- check if recipe exist. If return -999994 then recipe does not exists
      -- assumption - recipe_no is always an item_code or segment1
      BEGIN
         SELECT gr.recipe_no, gr.formula_id
           INTO v_recipe_no, v_formula_id
           FROM gmd_recipes gr
          WHERE gr.recipe_no = v_parent_item_code
            AND gr.owner_organization_id = p_org_id
            AND gr.recipe_status = 700
            AND gr.recipe_version =
                   (SELECT MAX (gr1.recipe_version)
                      FROM gmd_recipes gr1
                     WHERE gr1.recipe_no = v_parent_item_code
                       AND gr1.owner_organization_id = p_org_id
                       AND gr1.recipe_status = 700);
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_code := SQLCODE;
            l_error_message := SUBSTR (SQLERRM, 1, 150);

            IF x_error_msg IS NULL
            THEN
               x_error_msg :=
                     'recipe does not exists:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            ELSE
               x_error_msg :=
                     x_error_msg
                  || CHR (10)
                  || 'recipe does not exists:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            END IF;

            x_factor := -1;
      END;

      /*
      -- if return -999995 then formula does not exists
      BEGIN
         SELECT formula_id
           INTO v_formula_id
           FROM gmd_recipes
          WHERE recipe_no = v_recipe_no;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            check_point := -999995;
            RETURN check_point;
      END;
      */

      -- if return -999996 then product of formula has some problem
      BEGIN
         SELECT dtl.qty
           INTO v_parent_prod_qty
           FROM fm_form_mst mst, fm_matl_dtl dtl
          WHERE mst.formula_id = dtl.formula_id
            AND dtl.line_type = 1
            AND mst.formula_id = v_formula_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_code := SQLCODE;
            l_error_message := SUBSTR (SQLERRM, 1, 150);

            IF x_error_msg IS NULL
            THEN
               x_error_msg :=
                     'product of formula has some problem:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            ELSE
               x_error_msg :=
                     x_error_msg
                  || CHR (10)
                  || 'product of formula has some problem:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            END IF;
      END;

      -- if return -999997 then ingredient of parent formula has problem
      BEGIN
         SELECT dtl.qty
           INTO v_parent_ingr_qty
           FROM fm_form_mst mst, fm_matl_dtl dtl, mtl_system_items_b msib
          WHERE mst.formula_id = dtl.formula_id
            AND dtl.line_type = -1
            AND dtl.inventory_item_id = msib.inventory_item_id
            AND msib.segment1 NOT LIKE '%P'
            AND mst.formula_id = v_formula_id
            AND msib.organization_id = p_org_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_code := SQLCODE;
            l_error_message := SUBSTR (SQLERRM, 1, 150);

            IF x_error_msg IS NULL
            THEN
               x_error_msg :=
                     'ingredient of parent formula has problem:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            ELSE
               x_error_msg :=
                     x_error_msg
                  || CHR (10)
                  || 'ingredient of parent formula has problem:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            END IF;

            x_factor := -1;
      END;

      -- if return -999998 then child formula has error
      BEGIN
         SELECT msib.segment1
           INTO v_child_formula_no
           FROM fm_form_mst mst, fm_matl_dtl dtl, mtl_system_items_b msib
          WHERE mst.formula_id = dtl.formula_id
            AND dtl.line_type = -1
            AND dtl.inventory_item_id = msib.inventory_item_id
            AND msib.segment1 NOT LIKE '%P'
            AND mst.formula_id = v_formula_id
            AND msib.organization_id = p_org_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_code := SQLCODE;
            l_error_message := SUBSTR (SQLERRM, 1, 150);

            IF x_error_msg IS NULL
            THEN
               x_error_msg :=
                     'child formula has error:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            ELSE
               x_error_msg :=
                     x_error_msg
                  || CHR (10)
                  || 'child formula has error:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            END IF;

            x_factor := -1;
      END;

      -- if return -999999 then child formula product has problem
      BEGIN
         SELECT dtl.qty
           INTO v_child_prod_qty
           FROM fm_form_mst mst, fm_matl_dtl dtl
          WHERE mst.formula_id = dtl.formula_id
            AND dtl.line_type = 1
            AND mst.formula_no = v_child_formula_no;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_code := SQLCODE;
            l_error_message := SUBSTR (SQLERRM, 1, 150);

            IF x_error_msg IS NULL
            THEN
               x_error_msg :=
                     'child formula product has problem:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            ELSE
               x_error_msg :=
                     x_error_msg
                  || CHR (10)
                  || 'child formula product has problem:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            END IF;

            x_factor := -1;
      END;

      -- if return -9999910 then GT qty has problem
      BEGIN
         SELECT dtl.qty
           INTO v_child_gt_qty
           FROM fm_form_mst mst, fm_matl_dtl dtl, mtl_system_items_b msib
          WHERE mst.formula_id = dtl.formula_id
            AND dtl.line_type = -1
            AND dtl.inventory_item_id = msib.inventory_item_id
            AND msib.segment1 LIKE 'GT%'
            AND mst.formula_no = v_child_formula_no
            AND msib.organization_id = p_org_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error_code := SQLCODE;
            l_error_message := SUBSTR (SQLERRM, 1, 150);

            IF x_error_msg IS NULL
            THEN
               x_error_msg :=
                     'GT qty has problem:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            ELSE
               x_error_msg :=
                     x_error_msg
                  || CHR (10)
                  || 'GT qty has problem:   '
                  || l_error_code
                  || ':     '
                  || l_error_message;
            END IF;

            x_factor := -1;
      END;

      IF x_factor IS NULL
      THEN
         kg_per_cone :=
              v_child_gt_qty
            * (v_parent_ingr_qty / v_child_prod_qty)
            / v_parent_prod_qty;
         --RETURN (kg_per_cone);
         x_factor := kg_per_cone;
      ELSE
         x_factor := -1;
      END IF;
-- if return -9999911 then error is further analysis required
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error_code := SQLCODE;
         l_error_message := SUBSTR (SQLERRM, 1, 150);

         IF x_error_msg IS NULL
         THEN
            x_error_msg :=
                  'Others:   ' || l_error_code || ':     ' || l_error_message;
         ELSE
            x_error_msg :=
                  x_error_msg
               || CHR (10)
               || 'Others:   '
               || l_error_code
               || ':     '
               || l_error_message;
         END IF;

         x_factor := -1;
   END parent_child_form_qty;
END xxdbl_resource_workbench_pkg;
/