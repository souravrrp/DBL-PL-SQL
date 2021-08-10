select PROJECT_ID,PROJECT_NAME
from ALL_PROJECT_INFO_MASTER
where PROJECT_NAME is not null

--------------------------------**********--------------------------------------
select PROJECT_ID,PROJECT_NAME,APIM.*
from ALL_PROJECT_INFO_MASTER APIM
where PROJECT_NAME is not null