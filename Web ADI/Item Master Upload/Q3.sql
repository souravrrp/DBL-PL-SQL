CREATE OR REPLACE PACKAGE body APPS.cust_webadi_item_upload_pkg
IS   
 PROCEDURE initialize_segment_len
 AS
    BEGIN
             BEGIN
             
                  select  ffv.maximum_size
                    into  l_segment1_len       
                    from  fnd_id_flex_segments_vl fifs, 
                          fnd_flex_value_sets ffv
                   where 1=1
                     and fifs.flex_value_set_id = ffv.flex_value_set_id
                     and fifs.id_flex_code = 'MSTK'
                     and fifs.enabled_flag = 'Y'
                     and fifs.application_column_name = 'SEGMENT1';
                     
               EXCEPTION
                    WHEN no_data_found 
                    THEN
                         l_segment1_len := 0;
             END;
             
             BEGIN            
                     
                   select ffv.maximum_size
                    into  l_segment2_len       
                    from  fnd_id_flex_segments_vl fifs, 
                          fnd_flex_value_sets ffv
                   where 1=1
                     and fifs.flex_value_set_id = ffv.flex_value_set_id
                     and fifs.id_flex_code = 'MSTK'
                     and fifs.enabled_flag = 'Y'
                     and fifs.application_column_name = 'SEGMENT2';

               EXCEPTION
                    WHEN no_data_found 
                    THEN
                         l_segment2_len := 0;
             END;                  
                   
             BEGIN  
                   select ffv.maximum_size
                    into  l_segment3_len       
                    from  fnd_id_flex_segments_vl fifs, 
                          fnd_flex_value_sets ffv
                   where 1=1
                     and fifs.flex_value_set_id = ffv.flex_value_set_id
                     and fifs.id_flex_code = 'MSTK'
                     and fifs.enabled_flag = 'Y'
                     and fifs.application_column_name = 'SEGMENT3';
               
               EXCEPTION
                    WHEN no_data_found 
                    THEN
                         l_segment3_len := 0;
             END;
                 
             BEGIN    
                   select  ffv.maximum_size
                    into  l_segment4_len       
                    from  fnd_id_flex_segments_vl fifs, 
                          fnd_flex_value_sets ffv
                   where 1=1
                     and fifs.flex_value_set_id = ffv.flex_value_set_id
                     and fifs.id_flex_code = 'MSTK'
                     and fifs.enabled_flag = 'Y'
                     and fifs.application_column_name = 'SEGMENT4'; 
             
               EXCEPTION
                    WHEN no_data_found 
                    THEN
                         l_segment4_len := 0;
             END;
                     
             BEGIN
             
                  select  ffv.maximum_size
                    into  l_segment5_len       
                    from  fnd_id_flex_segments_vl fifs, 
                          fnd_flex_value_sets ffv
                   where 1=1
                     and fifs.flex_value_set_id = ffv.flex_value_set_id
                     and fifs.id_flex_code = 'MSTK'
                     and fifs.enabled_flag = 'Y'
                     and fifs.application_column_name = 'SEGMENT5';
                     
               EXCEPTION
                    WHEN no_data_found 
                    THEN
                         l_segment5_len := 0;
             END;
             
             BEGIN            
                     
                   select ffv.maximum_size
                    into  l_segment6_len       
                    from  fnd_id_flex_segments_vl fifs, 
                          fnd_flex_value_sets ffv
                   where 1=1
                     and fifs.flex_value_set_id = ffv.flex_value_set_id
                     and fifs.id_flex_code = 'MSTK'
                     and fifs.enabled_flag = 'Y'
                     and fifs.application_column_name = 'SEGMENT6';

               EXCEPTION
                    WHEN no_data_found 
                    THEN
                         l_segment6_len := 0;
             END;                  
                   
             BEGIN  
                   select ffv.maximum_size
                    into  l_segment7_len       
                    from  fnd_id_flex_segments_vl fifs, 
                          fnd_flex_value_sets ffv
                   where 1=1
                     and fifs.flex_value_set_id = ffv.flex_value_set_id
                     and fifs.id_flex_code = 'MSTK'
                     and fifs.enabled_flag = 'Y'
                     and fifs.application_column_name = 'SEGMENT7';
               
               EXCEPTION
                    WHEN no_data_found 
                    THEN
                         l_segment7_len := 0;
             END;
                 
             BEGIN    
                   select ffv.maximum_size
                    into  l_segment8_len       
                    from  fnd_id_flex_segments_vl fifs, 
                          fnd_flex_value_sets ffv
                   where 1=1
                     and fifs.flex_value_set_id = ffv.flex_value_set_id
                     and fifs.id_flex_code = 'MSTK'
                     and fifs.enabled_flag = 'Y'
                     and fifs.application_column_name = 'SEGMENT8'; 
             
               EXCEPTION
                    WHEN no_data_found 
                    THEN
                         l_segment8_len := 0;
             END;
    END;       

PROCEDURE cust_import_data_to_interface
IS
CURSOR int_trans
IS 
select  
    segment1,
    segment2,
    segment3,
    segment4,
    segment5,
    segment6,
    segment7,
    segment8,
    organization_id,
    description,
    inventory_item_status_code,
    template_id,
    primary_uom_code,
    tracking_quantity_ind,
    ont_pricing_qty_source,
    secondary_uom_code,
    secondary_default_ind,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    purchasing_item_flag,
    shippable_item_flag,
    customer_order_flag,
    internal_order_flag,
    service_item_flag,
    inventory_item_flag,
    inventory_asset_flag,
    purchasing_enabled_flag,
    customer_order_enabled_flag,
    internal_order_enabled_flag,
    so_transactions_flag,
    mtl_transactions_enabled_flag,
    stock_enabled_flag,
    bom_enabled_flag,
    build_in_wip_flag,
    returnable_flag,
    taxable_flag,
    allow_item_desc_update_flag,
    inspection_required_flag,
    receipt_required_flag,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date,
    process_flag,
    transaction_type,
    set_process_id,
    summary_flag,
    enabled_flag
from  cust_webadi_item_upload;

    BEGIN

     FOR r_int_trans in int_trans
        LOOP

        INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
        (
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            organization_id,
            description,
            inventory_item_status_code,
            template_id,
            primary_uom_code,
            tracking_quantity_ind,
            ont_pricing_qty_source,
            secondary_uom_code,
            secondary_default_ind,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            purchasing_item_flag,
            shippable_item_flag,
            customer_order_flag,
            internal_order_flag,
            service_item_flag,
            inventory_item_flag,
            inventory_asset_flag,
            purchasing_enabled_flag,
            customer_order_enabled_flag,
            internal_order_enabled_flag,
            so_transactions_flag,
            mtl_transactions_enabled_flag,
            stock_enabled_flag,
            bom_enabled_flag,
            build_in_wip_flag,
            returnable_flag,
            taxable_flag,
            allow_item_desc_update_flag,
            inspection_required_flag,
            receipt_required_flag,
            last_update_date,
            last_updated_by,
            last_update_login,
            created_by,
            creation_date,
            process_flag,
            transaction_type,
            set_process_id,
            summary_flag,
            enabled_flag
        )
        VALUES
        (
            r_int_trans.segment1,
            r_int_trans.segment2,
            r_int_trans.segment3,
            r_int_trans.segment4,
            r_int_trans.segment5,
            r_int_trans.segment6,
            r_int_trans.segment7,
            r_int_trans.segment8,
            r_int_trans.organization_id,
            r_int_trans.description,
            r_int_trans.inventory_item_status_code,
            r_int_trans.template_id,
            r_int_trans.primary_uom_code,
            r_int_trans.tracking_quantity_ind,
            r_int_trans.ont_pricing_qty_source,
            r_int_trans.secondary_uom_code,
            r_int_trans.secondary_default_ind,
            r_int_trans.attribute_category,
            r_int_trans.attribute1,
            r_int_trans.attribute2,
            r_int_trans.attribute3,
            r_int_trans.attribute4,
            r_int_trans.attribute5,
            r_int_trans.attribute6,
            r_int_trans.attribute7,
            r_int_trans.attribute8,
            r_int_trans.attribute9,
            r_int_trans.attribute10,
            r_int_trans.attribute11,
            r_int_trans.attribute12,
            r_int_trans.attribute13,
            r_int_trans.attribute14,
            r_int_trans.attribute15,
            r_int_trans.purchasing_item_flag,
            r_int_trans.shippable_item_flag,
            r_int_trans.customer_order_flag,
            r_int_trans.internal_order_flag,
            r_int_trans.service_item_flag,
            r_int_trans.inventory_item_flag,
            r_int_trans.inventory_asset_flag,
            r_int_trans.purchasing_enabled_flag,
            r_int_trans.customer_order_enabled_flag,
            r_int_trans.internal_order_enabled_flag,
            r_int_trans.so_transactions_flag,
            r_int_trans.mtl_transactions_enabled_flag,
            r_int_trans.stock_enabled_flag,
            r_int_trans.bom_enabled_flag,
            r_int_trans.build_in_wip_flag,
            r_int_trans.returnable_flag,
            r_int_trans.taxable_flag,
            r_int_trans.allow_item_desc_update_flag,
            r_int_trans.inspection_required_flag,
            r_int_trans.receipt_required_flag,
            r_int_trans.last_update_date,
            r_int_trans.last_updated_by,
            r_int_trans.last_update_login,
            r_int_trans.created_by,
            r_int_trans.creation_date,
            r_int_trans.process_flag,
            r_int_trans.transaction_type,
            r_int_trans.set_process_id,
            r_int_trans.summary_flag,
            r_int_trans.enabled_flag
           );

            /*
             update mtl_system_items_interface msii
                set msii.SEGMENT1 = LPAD(SEGMENT1,l_segment1_len,0),
                    msii.SEGMENT2 = LPAD(SEGMENT2,l_segment2_len,0),
                    msii.SEGMENT3 = LPAD(SEGMENT3,l_segment3_len,0),
                    msii.SEGMENT4 = LPAD(SEGMENT4,l_segment4_len,0),
                    msii.SEGMENT5 = LPAD(SEGMENT5,l_segment5_len,0),
                    msii.SEGMENT6 = LPAD(SEGMENT6,l_segment6_len,0),
                    msii.SEGMENT7 = LPAD(SEGMENT7,l_segment7_len,0),
                    msii.SEGMENT8 = LPAD(SEGMENT8,l_segment8_len,0)
                    ;
            */
            
            /*
             delete 
               from  cust_webadi_item_upload cwi
              where 1=1 
                and NVL(cwi.SEGMENT1,1) = NVL(r_int_trans.SEGMENT1,1)
                and NVL(cwi.SEGMENT2,1) = NVL(r_int_trans.SEGMENT2,1)
                and NVL(cwi.SEGMENT3,1) = NVL(r_int_trans.SEGMENT3,1)
                and NVL(cwi.SEGMENT4,1) = NVL(r_int_trans.SEGMENT4,1)
                and NVL(cwi.SEGMENT5,1) = NVL(r_int_trans.SEGMENT5,1)
                and NVL(cwi.SEGMENT6,1) = NVL(r_int_trans.SEGMENT6,1)
                and NVL(cwi.SEGMENT7,1) = NVL(r_int_trans.SEGMENT7,1)
                and NVL(cwi.SEGMENT8,1) = NVL(r_int_trans.SEGMENT8,1);
              
              */   
        
        
        END LOOP;
        
       COMMIT; 

    
 
    END cust_import_data_to_interface;

PROCEDURE cust_upload_data_to_staging
(     
      p_segment1                      VARCHAR2,
      p_segment2                      VARCHAR2,
      p_segment3                      VARCHAR2,
      p_segment4                      VARCHAR2,
      p_segment5                      VARCHAR2,
      p_segment6                      VARCHAR2,
      p_segment7                      VARCHAR2,
      p_segment8                      VARCHAR2,
      p_organization_name             VARCHAR2,
      p_description                   VARCHAR2,
      p_inventory_item_status_code    VARCHAR2,
      p_template_name                 VARCHAR2,
      p_primary_uom_code              VARCHAR2,
      p_tracking_quantity_ind         VARCHAR2,
      p_ont_pricing_qty_source        VARCHAR2,
      p_secondary_uom_code            VARCHAR2,
      p_secondary_default_ind         VARCHAR2,
      p_attribute_category            VARCHAR2,
      p_attribute1                    VARCHAR2,
      p_attribute2                    VARCHAR2,
      p_attribute3                    VARCHAR2,
      p_attribute4                    VARCHAR2,
      p_attribute5                    VARCHAR2,
      p_attribute6                    VARCHAR2,
      p_attribute7                    VARCHAR2,
      p_attribute8                    VARCHAR2,
      p_attribute9                    VARCHAR2,
      p_attribute10                   VARCHAR2,
      p_attribute11                   VARCHAR2,
      p_attribute12                   VARCHAR2,
      p_attribute13                   VARCHAR2,
      p_attribute14                   VARCHAR2,
      p_attribute15                   VARCHAR2,
      p_purchasing_item_flag          VARCHAR2,
      p_shippable_item_flag           VARCHAR2,
      p_customer_order_flag           VARCHAR2,
      p_internal_order_flag           VARCHAR2,
      p_service_item_flag             VARCHAR2,
      p_inventory_item_flag           VARCHAR2,
      p_inventory_asset_flag          VARCHAR2,
      p_purchasing_enabled_flag       VARCHAR2,
      p_customer_order_enabled_flag   VARCHAR2,
      p_internal_order_enabled_flag   VARCHAR2,
      p_so_transactions_flag          VARCHAR2,
      p_mtl_transactions_enab_flag    VARCHAR2,
      p_stock_enabled_flag            VARCHAR2,
      p_bom_enabled_flag              VARCHAR2,
      p_build_in_wip_flag             VARCHAR2,
      p_returnable_flag               VARCHAR2,
      p_taxable_flag                  VARCHAR2,
      p_allow_item_desc_update_flag   VARCHAR2,
      p_inspection_required_flag      VARCHAR2,
      p_receipt_required_flag         VARCHAR2
)
IS

l_error_message VARCHAR2(3000);
l_error_code VARCHAR2(3000);
l_organization_id NUMBER;
l_template_id  NUMBER;
l_uom_validity VARCHAR2(250);
l_flag_validation VARCHAR2(250);
l_item_desc_len number;

  

  BEGIN
     
  
     ----------------------------------------
     -----Load Segment Sizes from setup------
     ----------------------------------------
     BEGIN
     
     initialize_segment_len;
     
     END;
  
     ----------------------------------------
     ----------Select Org ID-----------------
     ----------------------------------------
      BEGIN
       select
        ood.organization_id
         into l_organization_id
        from
        org_organization_definitions ood
        where ood.organization_code= p_organization_name;
        
        /*
        select hou.ORGANIZATION_ID ,hou.NAME
         into l_organization_id
         from hr_organization_units hou 
        where hou.NAME = p_organization_name;
        */

        EXCEPTION
             WHEN no_data_found 
             THEN
                 l_error_message :=l_error_message
                                   ||','||
                                   'Please enter correct organization';
                 l_error_code    := 'E';                  

     END;

    ----------------------------------------
    ----------Select Template ID------------
    ----------------------------------------

     IF
        p_template_name is not null
       
      THEN      
             
              BEGIN
               select mit.TEMPLATE_ID
                 into l_template_id
                 from MTL_ITEM_TEMPLATES mit 
                where mit.TEMPLATE_NAME = p_template_name
                ;

                EXCEPTION
                     WHEN no_data_found 
                     THEN
                         l_error_message :=l_error_message
                                           ||','||
                                           'Please enter correct template';
                         l_error_code    := 'E';

             END;
      
     END IF;       
     
     
     ----------------------------------------
     ------Validate Primary UOM Code---------
     ----------------------------------------
      BEGIN
       select 'Valid'
         into l_uom_validity
         from MTL_UNITS_OF_MEASURE_VL uom 
        where uom.UOM_CODE = p_primary_uom_code
        ;

        EXCEPTION
             WHEN no_data_found 
             THEN
                 l_error_message :=l_error_message
                                   ||','||
                                   'Please enter the correct Primary/Secondary UOM Code';
                 l_error_code    := 'E';

     END;
    
    ----------------------------------------
    ------Validate Secondary UOM Code-------
    ----------------------------------------
        
     IF p_secondary_uom_code is not null
     
       THEN
             
              BEGIN
               select 'Valid'
                 into l_uom_validity
                 from MTL_UNITS_OF_MEASURE_VL uom 
                where uom.UOM_CODE = p_secondary_uom_code
                ;

                EXCEPTION
                     WHEN no_data_found 
                     THEN
                         l_error_message :=l_error_message
                                           ||','||
                                           'Please enter the correct Primary/Secondary UOM Code';
                         l_error_code    := 'E';

             END;
     
     END IF;
     
     ----------------------------------------
     ---------Validate Flags entered---------
     ----------------------------------------
     
     BEGIN
     
         select TRIM(TRANSLATE(
                NVL(p_purchasing_item_flag,'Y')||
                NVL(p_shippable_item_flag,'Y')||
                NVL(p_customer_order_flag,'Y')||
                NVL(p_internal_order_flag,'Y')||
                NVL(p_service_item_flag,'Y')||
                NVL(p_inventory_item_flag,'Y')||
                NVL(p_inventory_asset_flag,'Y')||
                NVL(p_purchasing_enabled_flag,'Y')||
                NVL(p_customer_order_enabled_flag,'Y')||
                NVL(p_internal_order_enabled_flag,'Y')||
                NVL(p_so_transactions_flag,'Y')||
                NVL(p_mtl_transactions_enab_flag,'Y')||
                NVL(p_stock_enabled_flag,'Y')||
                NVL(p_bom_enabled_flag,'Y')||
                NVL(p_build_in_wip_flag,'Y')||
                NVL(p_returnable_flag,'Y')||
                NVL(p_taxable_flag,'Y')||
                NVL(p_allow_item_desc_update_flag,'Y')||
                NVL(p_inspection_required_flag,'N')||
                NVL(p_receipt_required_flag,'Y')
                ,'YN',' '))
           into l_flag_validation
           from dual;
          
         IF 
           l_flag_validation is not null
              THEN
                         l_error_message :=l_error_message
                                           ||','||
                                           'Please enter your relevant flags as either Y or N';
                         l_error_code    := 'E';
         END IF;     
     END;
     
     ----------------------------------------
     -----Validate Description entered-------
     ----------------------------------------
     
     BEGIN
     
     select LENGTH(TRIM(p_description))
     INTO l_item_desc_len
     from dual;
     
       IF
           l_item_desc_len > 240           
                     THEN
                         l_error_message :=l_error_message
                                           ||','||
                                           'Please ensure the description length is lesser than 240 characters';
                         l_error_code    := 'E';
       END IF;                         
     
     END;
     
     
     ----------------------------------------
     --------Validate Item Segments----------
     ----------------------------------------
      BEGIN 
     
      
             IF
               
               l_segment1_len > 0 AND LENGTH(P_SEGMENT1) > l_segment1_len
               OR
               l_segment2_len > 0 AND LENGTH(P_SEGMENT2) > l_segment2_len
               OR
               l_segment3_len > 0 AND LENGTH(P_SEGMENT3) > l_segment3_len
               OR
               l_segment4_len > 0 AND LENGTH(P_SEGMENT4) > l_segment4_len
               OR
               l_segment5_len > 0 AND LENGTH(P_SEGMENT5) > l_segment5_len
               OR
               l_segment6_len > 0 AND LENGTH(P_SEGMENT6) > l_segment6_len
               OR
               l_segment7_len > 0 AND LENGTH(P_SEGMENT7) > l_segment7_len
               OR
               l_segment8_len > 0 AND LENGTH(P_SEGMENT8) > l_segment8_len       
               THEN
                         l_error_message :=l_error_message
                                           ||','||
                                           'Please ensure that all Item SEGMENT lengths are as per setup.';
                         l_error_code    := 'E';       
               
               
             END IF;
      
        
      END;     


     --------------------------------------------------------------------------------------------------------------
     --------Condition to show error if any of the above validation picks up a data entry error--------------------
     --------Condition to insert data into custom staging table if the data passes all above validations-----------
     --------------------------------------------------------------------------------------------------------------
       
     
          IF l_error_code = 'E'
           
           THEN raise_application_error(-20101,l_error_message);
           
          ELSIF  NVL(l_error_code,'A') <> 'E'
          
           THEN
             
            INSERT INTO apps.cust_webadi_item_upload
            (
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            organization_id,
            description,
            inventory_item_status_code,
            template_id,
            primary_uom_code,
            tracking_quantity_ind,
            ont_pricing_qty_source,
            secondary_uom_code,
            secondary_default_ind,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            purchasing_item_flag,
            shippable_item_flag,
            customer_order_flag,
            internal_order_flag,
            service_item_flag,
            inventory_item_flag,
            inventory_asset_flag,
            purchasing_enabled_flag,
            customer_order_enabled_flag,
            internal_order_enabled_flag,
            so_transactions_flag,
            mtl_transactions_enabled_flag,
            stock_enabled_flag,
            bom_enabled_flag,
            build_in_wip_flag,
            returnable_flag,
            taxable_flag,
            allow_item_desc_update_flag,
            inspection_required_flag,
            receipt_required_flag,
            last_update_date,
            last_updated_by,
            last_update_login,
            created_by,
            creation_date,
            process_flag,
            transaction_type,
            set_process_id,
            summary_flag,
            enabled_flag,
            interface_status
            )
            VALUES
            (
            TRIM(p_segment1),
            TRIM(p_segment2),
            TRIM(p_segment3),
            TRIM(p_segment4),
            TRIM(p_segment5),
            TRIM(p_segment6),
            TRIM(p_segment7),
            TRIM(p_segment8),
            l_organization_id,
            TRIM(p_description),
            TRIM(p_inventory_item_status_code),
            l_template_id,
            TRIM(p_primary_uom_code),
            TRIM(p_tracking_quantity_ind),
            TRIM(p_ont_pricing_qty_source),
            TRIM(p_secondary_uom_code),
            TRIM(p_secondary_default_ind),
            TRIM(p_attribute_category),
            TRIM(p_attribute1),
            TRIM(p_attribute2),
            TRIM(p_attribute3),
            TRIM(p_attribute4),
            TRIM(p_attribute5),
            TRIM(p_attribute6),
            TRIM(p_attribute7),
            TRIM(p_attribute8),
            TRIM(p_attribute9),
            TRIM(p_attribute10),
            TRIM(p_attribute11),
            TRIM(p_attribute12),
            TRIM(p_attribute13),
            TRIM(p_attribute14),
            TRIM(p_attribute15),
            p_purchasing_item_flag,
            p_shippable_item_flag,
            p_customer_order_flag,
            p_internal_order_flag,
            p_service_item_flag,
            p_inventory_item_flag,
            p_inventory_asset_flag,
            p_purchasing_enabled_flag,
            p_customer_order_enabled_flag,
            p_internal_order_enabled_flag,
            p_so_transactions_flag,
            p_mtl_transactions_enab_flag,
            p_stock_enabled_flag,
            p_bom_enabled_flag,
            p_build_in_wip_flag,
            p_returnable_flag,
            p_taxable_flag,
            p_allow_item_desc_update_flag,
            p_inspection_required_flag,
            p_receipt_required_flag,
            sysdate,
            1113,
            0,
            1113,
            sysdate,
            1,
            'CREATE',
            1,
            'N',
            'Y',
            'NO'
            );
            
            ----------------------------------------------------------------------------------------------------
            -----------Insert data into MTL_SYSTEM_ITEMS_INTERFACE after loading into staging table-------------
            ----------------------------------------------------------------------------------------------------
            
            BEGIN
            
            cust_import_data_to_interface;
            
            END;
           
          END IF; 

  END cust_upload_data_to_staging;


END cust_webadi_item_upload_PKG;
/
