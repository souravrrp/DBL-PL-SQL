SELECT *
             FROM inl_allocations ia
             where 1=1
             and ship_header_id='3961'
             and ASSOCIATION_ID is not null
             and ADJUSTMENT_NUM=7
             ;
             
             select
             *
             from
             INL_CHARGE_ALLOCATIONS_V
             where 1=1
             and ship_header_id='3961'
             ;
             
             select
             *
             from
             INL_PO_CHARGE_ALLOCATIONS_V
             where 1=1
--             and ship_header_id='3961'

select
*
from
inl_ship_lines_all
where 1=1
and ship_line_id='33283'
             
             