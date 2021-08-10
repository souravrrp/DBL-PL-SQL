function BeforeReport return boolean is
 v_po_number		varchar2(20);
 v_operating		varchar2(300);
 v_max					number;
 v_org					number;
begin
	
select 
	 count(* ) 
	into 
	 v_po_number  
	from xx_dbl_po_recv_adjust where po_no=:p_po_number ;

 if :p_status='Final' then	 
	
	if v_po_number=0 then
		 select 
		  max(nvl(fucn1,0 ))+1
		 into
		  v_max
		 from xx_dbl_po_recv_adjust
		 where FUCDN1=2019; 
		 
		 insert into xx_dbl_po_recv_adjust 
		 (item_code,
		  po_no,
		  fucn1,
		  transaction_date,
		  FUCDN1)
		 values 
		 ('NA',
		  :p_po_number,
		  v_max,
		  sysdate,
		  2019);
		 
		 commit;
	else
		if :p_max_number is not null then
		    select
		     max(nvl(fucn1,365 ))+1
		    into
		     v_max
		    from xx_dbl_po_recv_adjust; 
		 
			insert into xx_dbl_po_recv_adjust 
		  (item_code,
		   po_no,
		   fucn1,
		   transaction_date,
		   FUCDN1)
		 values 
		  ('NA',
		   'Outside PI',
		    v_max,
		    sysdate,
		    2019);	 
		end if;
		
	end if;
	else 
		null;
	end if;
	
	
  commit;
 return (TRUE);
end;