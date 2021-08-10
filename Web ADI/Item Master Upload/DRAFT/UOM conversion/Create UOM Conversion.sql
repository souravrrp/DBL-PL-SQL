CREATE OR REPLACE PACKAGE BODY APPS.xxdbl_thd_uom_conv_upload
AS
   PROCEDURE writelog (p_text VARCHAR2)
   IS
   BEGIN
      fnd_file.put_line (fnd_file.LOG, p_text);
   END writelog;

   PROCEDURE main (
      x_retcode             OUT NOCOPY      NUMBER,
      x_errbuf              OUT NOCOPY      VARCHAR2,
      p_set_proc_id         IN              VARCHAR2,
      p_organization_code   IN              VARCHAR2
   )
   IS
      l_set_proc_id         VARCHAR2 (240);
      l_size                VARCHAR2 (240);
      l_conv_factor         VARCHAR2 (240);
      l_inventory_item_id   NUMBER;
      lx_return_status      VARCHAR2 (2000) := NULL;

      CURSOR item_thread_stg (
         p_set_proc_id         VARCHAR2,
         p_organization_code   NUMBER
      )
      IS
         (SELECT msib.inventory_item_id, stg.item_conversion_factor
            FROM xxdbl_item_conv_stg stg,
                 mtl_system_items_b msib,
                 mtl_parameters mp
           WHERE stg.set_proc_id = NVL (:p_set_proc_id, stg.set_proc_id)
             AND mp.organization_id =
                                 NVL (:p_organization_code, mp.organization_id)
             AND stg.organization_code = mp.organization_code
             AND stg.item_code = msib.segment1
             AND msib.organization_id = mp.organization_id
             AND NOT EXISTS (
                         SELECT conv.inventory_item_id
                           FROM mtl_uom_class_conversions conv
                          WHERE msib.inventory_item_id =
                                                        conv.inventory_item_id));
   BEGIN
      writelog (p_set_proc_id || ' ' || p_organization_code);
      mo_global.init ('INV');
      inv_globals.set_org_id (138);

      FOR c1 IN item_thread_stg (p_set_proc_id, p_organization_code)
      LOOP
         IF c1.item_conversion_factor = 0
         THEN
            writelog
               (   'Item_conversion_factor is 0 for l_inventory_item_id:        '
                || c1.inventory_item_id
               );
            CONTINUE;
         END IF;

         IF c1.item_conversion_factor IS NULL
         THEN
            writelog
               (   'Item_conversion_factor is null for l_inventory_item_id:        '
                || c1.inventory_item_id
               );
            CONTINUE;
         END IF;

         fnd_global.apps_initialize (1130, 20634, 401);
         l_inventory_item_id := c1.inventory_item_id;
         l_conv_factor := 1 / c1.item_conversion_factor;
         inv_convert.create_uom_conversion
                                          (p_from_uom_code      => 'NO',
                                           -- Source is the Base UOM of Primary UOM's class
                                           p_to_uom_code        => 'KG',
                                           -- Destination UOM
                                           p_item_id            => l_inventory_item_id,
                                           p_uom_rate           => l_conv_factor,
                                           x_return_status      => lx_return_status
                                          );
         writelog ('l_inventory_item_id:        ' || l_inventory_item_id);

         IF lx_return_status = 'S'
         THEN
            writelog ('UOM Conversion created successfully.');
            COMMIT;
         ELSE
            ROLLBACK;
            writelog ('UOM Conversion not created.');
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         writelog ('Program in Exception - ' || SQLERRM);
   END main;
END xxdbl_thd_uom_conv_upload;
/