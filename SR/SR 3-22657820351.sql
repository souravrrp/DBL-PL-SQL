select * from cm_cmpt_dtl
where inventory_item_id in (4524,
189473,
36170,
85500,
4671,
4623,
4544,
4569,
4789,
4995,
4739,
4972,
4580,
5186,
189594,
189592,
4653,
4886,
4020,
307201,
4629,
83428)
and organization_id = 152
and period_id = 1250;

select * from cm_cmpt_dtl
where inventory_item_id= 4653
and organization_id = 152
and period_id = &&prior_Period_id;

select * from mtl_material_transactions
where inventory_item_id= 4653
and organization_id = 152;