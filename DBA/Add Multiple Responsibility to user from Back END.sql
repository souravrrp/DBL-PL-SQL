 declare  
   v_user_name varchar2(30) :='103908';   -- User Name  
   --v_password  varchar2(30) :='johnytips';  -- Password  
   -- List of responsibilities to be added automatically  
   cursor cur_get_responsibilities  
   is  
     select resp.responsibility_key  
           ,resp.responsibility_name  
           ,app.application_short_name        
     from  fnd_responsibility_vl resp  
          ,fnd_application       app  
     where resp.application_id = app.application_id   
     and   resp.responsibility_name in ( 'HTL-DYEING : CM - User'  
                                        ,'JKL-KNIT : AR - User') ;  
 begin  
--   fnd_user_pkg.createuser (  
--           x_user_name             => upper(v_user_name)  
--          ,x_owner                 => null  
--          ,x_unencrypted_password  => v_password  
--          ,x_session_number        => userenv('sessionid')  
--          ,x_start_date            => sysdate  
--          ,x_end_date              => null );  
--   dbms_output.put_line ('User '||v_user_name||' created !!!!!');  
   for c_get_resp in cur_get_responsibilities   
   loop  
     fnd_user_pkg.addresp ( 
                username        => v_user_name  
               ,resp_app        => c_get_resp.application_short_name  
               ,resp_key        => c_get_resp.responsibility_key  
               ,security_group  => 'STANDARD'  
               ,description     => null  
               ,start_date      => sysdate  
               ,end_date        => null);  
     dbms_output.put_line('Responsibility '||c_get_resp.responsibility_name||' added !!!!!!');    
   end loop;  
   commit;  
 exception  
   when others then  
   dbms_output.put_line ('Exception : '||SUBSTR(SQLERRM, 1, 500));  
   rollback;  
 end; 
 
 ----------------
 /*
 BEGIN
fnd_user_pkg.addresp ('&Enter_User_Name','SYSADMIN','SYSTEM_ADMINISTRATOR','STANDARD','Add Responsibility to USER using pl/sql',SYSDATE,SYSDATE + 100);
commit;
dbms_output.put_line('Responsibility Added Successfully');
exception
        WHEN others THEN
                dbms_output.put_line(' Responsibility is not added due to ' || SQLCODE || substr(SQLERRM, 1, 100));
                ROLLBACK;
END;

*/