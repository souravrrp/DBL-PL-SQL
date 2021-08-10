CREATE OR REPLACE PACKAGE APPS.xxdbl_thd_exp_allocation_pkg
AS
   PROCEDURE main (
      x_retcode           OUT NOCOPY      NUMBER,
      x_errbuf            OUT NOCOPY      VARCHAR2,
      p_year              IN              VARCHAR2,
      p_period            IN              VARCHAR2,
      p_organization_id      IN              VARCHAR2,
      p_allocation_code   IN              VARCHAR2
   );
END xxdbl_thd_exp_allocation_pkg;
/