IF :ORGNAME IS NULL THEN :ORGID:=NULL; END IF;
IF :ctrl.VREG IS NULL THEN :IOU_NUMBER:=NULL; END IF;
--IF :ORGNAME IS NULL THEN :ORGID:=NULL; END IF;

declare
	v_where varchar2(2000);
	v_activities varchar2(2000);
	v_org varchar2(1000);
	v_type varchar2(1000);
	v_IOU_NUMBER varchar2(1000);
	v_exp varchar2(2000);
	v_act varchar2(2000);
	--	abc varchar2(2000);
		v_act_where varchar2(2000);
		v_exp_a varchar2(2000);
	v_act_a varchar2(2000); 
	
	 
begin
if :ctrl.orgid is null then v_org:='1=1'; else v_org:=	'org_id='||:ctrl.orgid; end if;
if :ctrl.IOU_NUMBER is null then v_IOU_NUMBER:='1=1'; else v_IOU_NUMBER:=	'VMST_ID='||:ctrl.IOU_NUMBER; end if;
if :ctrl.vtype is null then v_type:='1=1'; else v_type:=	'type='||:ctrl.vtype; end if;	 	
if :ctrl.IOU_DATE is null then v_exp:='1=1'; v_exp_a:='1=1'; else v_exp:=' VMST_ID in (select  VMST_ID from XXVEH_ACTIVITIES 
where to_char((Trunc(DOC_DATE)),''MM/RRRR'')=to_char(:ctrl.IOU_DATE,''MM/RRRR''))'; 
v_exp_a:='to_char((Trunc(DOC_DATE)),''MM/RRRR'')=to_char(:ctrl.IOU_DATE,''MM/RRRR'')'; end if;
if :ctrl.ACTYPE is null then v_act:='1=1'; v_act_a:='1=1'; else v_act:=' VMST_ID in (select  VMST_ID from XXVEH_ACTIVITIES 
	where Upper(ACTIVITIES_TYPE)=upper('''||:ctrl.ACTYPE||'''))';
	v_act_a:='Upper(ACTIVITIES_TYPE)=upper('''||:ctrl.ACTYPE||''')';  end if;
	                                                                                  
v_where:='(USER_NAME is null or upper(USER_NAME) like ''%'||:ctrl.user||'%'') and '|| v_org|| ' and '||v_IOU_NUMBER||' and '||v_type||' and '||v_exp||' and '||v_act;


go_block('XX_VMS');
set_block_property('XX_VMS',default_where,v_where);
execute_query;

if :ctrl.IOU_DATE is not null  then
go_block('XXVEH_ACTIVITIES');
set_block_property('XXVEH_ACTIVITIES',default_where,v_exp_a||' and '||v_act_a);
execute_query;
end if;

end;

