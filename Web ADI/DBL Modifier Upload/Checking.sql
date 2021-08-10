/* Formatted on 1/14/2021 10:47:18 AM (QP5 v5.287) */
xxdbl_modifier_upload_pkg.load_modifier_adi_prc

select description, attribute2, list_type_code
  --INTO l_description, l_attribute2, l_list_type_code
  from qp_list_headers qlh
 where name = 'CSSM 2.5';

select lookup_type,
       lookup_code,
       meaning,
       description,
       start_date_active,
       end_date_active
  --,FLV.*
  from fnd_lookup_values_vl flv
  where 1=1
  and lookup_type='LIST_TYPE_CODE';
  
  select lookup_type,
       lookup_code,
       meaning,
       description,
       start_date_active,
       end_date_active
  --,FLV.*
  from fnd_lookup_values_vl flv
  where 1=1
  and lookup_type='LIST_LINE_TYPE_CODE';
  
  select 
       meaning
       --into l_meaning
  from fnd_lookup_values_vl flv
  where 1=1
  and lookup_type='LIST_LINE_TYPE_CODE'
  and lookup_code=decode(:l_list_type_code,'DLT','DIS','SLT','SUR');
  
  
  
  select
  *
  from
  xxdbl_modifier_stg