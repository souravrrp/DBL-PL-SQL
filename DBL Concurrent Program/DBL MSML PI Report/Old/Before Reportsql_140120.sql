function BeforeReport return boolean is
 v_po_number		varchar2(20);
 v_operating		varchar2(300);
 v_max					number;
 v_org					number;
 v_year                 number;
begin
	
select 
	 count(* ) 
	into 
	 v_po_number  
	from xx_dbl_po_recv_adjust where po_no=:p_po_number ;

select to_number(extract (year from sysdate)) into v_year from dual;

 if :p_status='Final' then	 
	
	if v_po_number=0 then
		 select 
		  max(nvl(fucn1,0 ))+1
		 into
		  v_max
		 from xx_dbl_po_recv_adjust
		 where FUCDN1=v_year; 
		 
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
		  v_year);
		 
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
		    v_year);	 
		end if;
		
	end if;
	else 
		null;
	end if;
	
	
  commit;
 return (TRUE);
end;