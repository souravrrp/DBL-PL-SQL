select
*
from
fnd_territories_vl;

select
TERRITORY_ID l_TERRITORY, rt.*
from
ra_territories rt
where segment1||'.'||segment2||'.'||segment3||'.'||segment4='Bangladesh.Area-1.Zone-A.N/A'