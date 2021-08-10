/* Formatted on 1/24/2021 11:22:49 AM (QP5 v5.287) */
select qsl.list_header_id, qsl.name, qsl.description
  from qp_secu_list_headers_vl qsl
 where     1 = 1
       and exists
              (select 1
                 from apps.ra_customer_trx_all rcta,
                      apps.ra_customer_trx_lines_all rctla
                where     1 = 1
                      and rcta.customer_trx_id = rctla.customer_trx_id
                      and upper (regexp_substr (rctla.description,
                                                '[^.]+',
                                                1,
                                                1)) like
                             upper ('%' || qsl.name || '%')
                      and (   :p_ord_line_id is null
                           or (rctla.interface_line_attribute6 =
                                  :p_ord_line_id)));



select distinct decode (upper (regexp_substr (rctla.description,
                                     '[^.]+',
                                     1,
                                     1)),
               'CERAMIC DISCOUNT - SQFT WISE', 'LD',
               'SO HEADER ADHOC DISCOUNT', 'HD',
               'CSSM 2', 'CSSM',
               'Others')
          discount_type
  from apps.ra_customer_trx_lines_all rctla
 where 1 = 1 and upper (rctla.description) like upper ('%' || :p_trx_ln_desc || '%');

select xxdbl.xxdbl_get_mod_type_trx_ln ( :p_trx_ln_desc) line_type from dual;

select apps.xxdbl_get_mod_type_trx_ln ( :p_trx_ln_desc) line_type from dual;

grant select on xxdbl.xxdbl_get_mod_type_trx_ln to apps;


  select *
    from ra_customer_trx_lines_all
   where     line_type in ('LINE', 'CB', 'CHARGES')
         and -1 = -1
         and (customer_trx_id = 866084)
         and customer_trx_line_id = :p_trx_line_id
         and upper (description) like '%DIS%'
order by line_number