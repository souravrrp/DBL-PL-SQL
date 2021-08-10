/* Formatted on 11/24/2020 12:49:12 PM (QP5 v5.354) */
select *
  from xxdbl_mov_ord_appr_hist x
 where x.mo_header_id = :l_mo_header_id;


select *
  from apps.xxdbl_mov_ord_appr_hist_v x
 where x.mo_header_id = :l_mo_header_id;