No responsibilities are assigned to:

HR: Security Profile
MO: Security Profile
MO: Operating Unit
MO:  Default Operating Unit

In order to assign the proper values for those profiles, please perform the following in a UAT environment and migrate the solution accordingly:

 

1. Check the Value of the Profile Option at the Site Level using the below SQL:

select
user_profile_option_name NAME,
v.profile_option_value VALUE
from
fnd_profile_options p,
fnd_profile_option_values v,
fnd_profile_options_tl n
where
v.level_id= 10001
and p.profile_option_id = v.profile_option_id (+)
and p.profile_option_name = n.profile_option_name
and upper(n.profile_option_name) = upper ('ORG_ID')
order by name, v.level_id;

2. If the result is NULL, update it from backend:

Set the ORG_ID manually at the site level:

DECLARE
stat boolean;
BEGIN
dbms_output.disable;
dbms_output.enable(100000);
stat := FND_PROFILE.SAVE('ORG_ID', '2', 'SITE');
IF stat THEN
dbms_output.put_line( 'Stat = TRUE - profile updated' );
ELSE
dbms_output.put_line( 'Stat = FALSE - profile NOT updated' );
END IF;
commit;
END;
/

 

3. Retest the issue


--------------------------------------------------------------------------------

select Org_id from fa_book_controls where date_ineffective IS NULL;