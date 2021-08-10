CREATE OR REPLACE PACKAGE XXDBL.XXCPM_WORK_MAT_REQE_PKG
AS          
   PROCEDURE insert_row (p_row_id    IN OUT NOCOPY VARCHAR2
                                       ,p_nature_of_job_id    number
                                        ,p_work_description_id    number
                                        ,p_sub_work_description_id    number
                                      --  ,p_organization_id    number
                                        ,p_inventory_item_id    number
                                        ,p_mtl_specification    varchar2
                                        ,p_unit_of_measure    varchar2
                                        ,p_mtl_origin_lookup_code    varchar2
                                        ,p_mtl_brand_lookup_code    varchar2
                                        ,p_required_quantity    number
                                        ,p_mixing_ratio    number
                                        ,p_ratio_basis    varchar2
                                        ,p_creation_date    date
                                        ,p_created_by    number
                                        ,p_last_update_date    date
                                        ,p_last_updated_by    number
                                        ,p_last_update_login    number
                                        );

   PROCEDURE update_row (p_row_id     VARCHAR2
                                        ,p_nature_of_job_id    number
                                        ,p_work_description_id    number
                                        ,p_sub_work_description_id    number
                                     --   ,p_organization_id    number
                                        ,p_inventory_item_id    number
                                        ,p_mtl_specification    varchar2
                                        ,p_unit_of_measure    varchar2
                                        ,p_mtl_origin_lookup_code    varchar2
                                         ,p_mtl_brand_lookup_code    varchar2
                                        ,p_required_quantity    number
                                        ,p_mixing_ratio    number
                                        ,p_ratio_basis    varchar2
                                        ,p_last_update_date    date
                                        ,p_last_updated_by    number
                                        ,p_last_update_login    number
                                        );
                         
   PROCEDURE delete_row(p_row_id    VARCHAR2
                                     ,p_nature_of_job_id    number
                                    ,p_work_description_id    number
                                    ,p_sub_work_description_id    number
                                  --  ,p_organization_id    number
                                    ,p_inventory_item_id    number
                                        );
                         
END     XXCPM_WORK_MAT_REQE_PKG;
/

------------------------------------------------------------------------------------


CREATE OR REPLACE PACKAGE BODY XXDBL.XXCPM_WORK_MAT_REQE_PKG
AS        
   PROCEDURE insert_row (p_row_id    IN OUT NOCOPY VARCHAR2
                                       ,p_nature_of_job_id    number
                                        ,p_work_description_id    number
                                        ,p_sub_work_description_id    number
                                        --,p_organization_id    number
                                        ,p_inventory_item_id    number
                                        ,p_mtl_specification    varchar2
                                        ,p_unit_of_measure    varchar2
                                        ,p_mtl_origin_lookup_code    varchar2
                                        ,p_mtl_brand_lookup_code    varchar2
                                        ,p_required_quantity    number
                                        ,p_mixing_ratio    number
                                        ,p_ratio_basis    varchar2
                                        ,p_creation_date    date
                                        ,p_created_by    number
                                        ,p_last_update_date    date
                                        ,p_last_updated_by    number
                                        ,p_last_update_login    number) IS
  
    BEGIN

            INSERT  INTO WORK_MATERIAL_REQE(
                 nature_of_job_id
                ,work_description_id
                ,sub_work_description_id
               -- ,organization_id
                ,inventory_item_id
                ,mtl_specification
                ,unit_of_measure
                ,mtl_origin_lookup_code
                ,mtl_brand_lookup_code
                ,required_quantity
                ,mixing_ratio
                ,ratio_basis
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,last_update_login
                )
                VALUES(
                p_nature_of_job_id
                ,p_work_description_id
                ,p_sub_work_description_id
              --  ,p_organization_id
                ,p_inventory_item_id
                ,p_mtl_specification
                ,p_unit_of_measure
                ,p_mtl_origin_lookup_code
                ,p_mtl_brand_lookup_code
                ,p_required_quantity
                ,p_mixing_ratio
                ,p_ratio_basis
                ,p_creation_date
                ,p_created_by
                ,p_last_update_date
                ,p_last_updated_by
                ,p_last_update_login)

                RETURNING rowid
                INTO p_row_id;     
    END insert_row;                         

      PROCEDURE update_row (
                         p_row_id                   VARCHAR2,
                        p_nature_of_job_id    number
                        ,p_work_description_id    number
                        ,p_sub_work_description_id    number
                       -- ,p_organization_id    number
                        ,p_inventory_item_id    number
                        ,p_mtl_specification    varchar2
                        ,p_unit_of_measure    varchar2
                        ,p_mtl_origin_lookup_code    varchar2
                         ,p_mtl_brand_lookup_code    varchar2
                        ,p_required_quantity    number
                        ,p_mixing_ratio    number
                        ,p_ratio_basis    varchar2
                        ,p_last_update_date    date
                        ,p_last_updated_by    number
                        ,p_last_update_login    number) IS
    BEGIN
    
 --   RAISE_APPLICATION_ERROR (-20000,         p_nature_of_job_id||'  '||p_work_description_id||'  '||p_sub_work_description_id||'   '||p_organization_id||'   '||p_inventory_item_id);
    
            UPDATE WORK_MATERIAL_REQE
            SET   nature_of_job_id    =    p_nature_of_job_id
                    ,work_description_id    =    p_work_description_id
                    ,sub_work_description_id    =    p_sub_work_description_id
                    --,organization_id    =    p_organization_id
                    ,inventory_item_id    =    p_inventory_item_id
                    ,mtl_specification    =    p_mtl_specification
                    ,unit_of_measure    =    p_unit_of_measure
                    ,mtl_origin_lookup_code    =    p_mtl_origin_lookup_code
                    ,mtl_brand_lookup_code    =    p_mtl_brand_lookup_code
                    ,required_quantity    =    p_required_quantity
                    ,mixing_ratio    =    p_mixing_ratio
                    ,ratio_basis    =    p_ratio_basis
                    ,last_update_date    =    p_last_update_date
                    ,last_updated_by    =    p_last_updated_by
                    ,last_update_login    =    p_last_update_login
            WHERE nature_of_job_id =  p_nature_of_job_id
            AND     work_description_id = p_work_description_id
            AND     sub_work_description_id = p_sub_work_description_id
           -- AND     organization_id = p_organization_id
            AND     inventory_item_id = p_inventory_item_id;        
    END update_row;                         

   PROCEDURE delete_row(p_row_id    VARCHAR2,
                                     p_nature_of_job_id    number
                                    ,p_work_description_id    number
                                    ,p_sub_work_description_id    number
                                  --  ,p_organization_id    number
                                    ,p_inventory_item_id    number) IS
    
    BEGIN
            delete WORK_MATERIAL_REQE
            WHERE nature_of_job_id =  p_nature_of_job_id
            AND     work_description_id = p_work_description_id
            AND     sub_work_description_id = p_sub_work_description_id
            --AND     organization_id = p_organization_id
            AND     inventory_item_id = p_inventory_item_id;      

            IF (SQL%NOTFOUND) THEN
                RAISE NO_DATA_FOUND;
            END IF;
              
    END delete_row;               
        
END XXCPM_WORK_MAT_REQE_PKG;
/
