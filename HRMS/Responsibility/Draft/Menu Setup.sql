select
*
from
fnd_menus_vl fmv
where 1=1
AND fmv.type='STANDARD' 
and (   :p_user_menu_name is null
            or upper (fmv.user_menu_name) like upper ('%' || :p_user_menu_name || '%'))
AND (   :p_menu_name IS NULL      OR (fmv.menu_name = :p_menu_name))
--and (   :p_menu_name is null or upper (fmv.menu_name) like upper ('%' || :p_menu_name || '%'))