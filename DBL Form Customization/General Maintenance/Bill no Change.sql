
	DECLARE
		v_do_seq NUMBER;
		v_short_code VARCHAR2(100);
		v_bill_number varchar2(100);
		v_org					number;

Begin
	  fnd_standard.set_who;
	  :XX_VMS_BILL_MST.VMS_BILL_ID := XX_COM_PKG.GET_SEQUENCE_VALUE('XX_VMS_BILL_MST', 'VMS_BILL_ID');

		   SELECT MAX(XX_COM_PKG.GET_SEQUENCE_VALUE('XX_VMS_BILL_MST', 'VMS_BILL_ID'))+1
	     INTO v_do_seq
	     FROM DUAL;
	   SELECT :xx_vms_bill_mst.purch_ou||'/'||v_short_code||'BILL'
	          || DECODE (v_short_code, NULL, NULL, '/')
	          || v_do_seq
	     INTO v_bill_number
	     FROM DUAL;
	 :XX_VMS_BILL_MST.BLL_NO := v_bill_number;
	 
	 :XX_VMS_BILL_MST.INVOICE_AMOUNT:=:ITEM299;


 Select organization_id into v_org  from hr_operating_units
 where name=:xx_vms_bill_mst.purch_ou;
 
 :xx_vms_bill_mst.org_id:=v_org;
 
 Set_Item_Property ('XX_VMS_BILL_MST.INVOICE', ENABLED, property_true);
	End;