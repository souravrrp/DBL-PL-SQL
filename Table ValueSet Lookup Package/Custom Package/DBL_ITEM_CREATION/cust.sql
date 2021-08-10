select
*
from
xxdbl_item_conv_stg


XXDBL_ITEM_CREATION_PKG.CALL_ITEM_API

xxdbl_item_conv_prc_thread

select
*
from
mtl_system_items_interface


DELETE xxdbl.xxdbl_thread_formula_upd_stg
 WHERE ERROR_MSG IS NOT NULL;

COMMIT;


select
*
from xxdbl.xxdbl_thread_formula_upd_stg
 WHERE ERROR_MSG IS NOT NULL;