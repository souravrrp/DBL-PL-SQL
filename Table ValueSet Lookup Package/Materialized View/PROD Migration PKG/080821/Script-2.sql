EXEC ad_zd_mview.upgrade('APPS','XXDBL_GL_DTL_STAT_SUM_MV');

CREATE OR REPLACE SYNONYM APPSRO.XXDBL_GL_DTL_STAT_SUM_MV FOR APPS.XXDBL_GL_DTL_STAT_SUM_MV;


grant select on APPS.XXDBL_GL_DTL_STAT_SUM_MV to appsro;