REM $Id: drop_ar_tca_analyzer.sql, 200.19 2021/04/29 17:14:26 vcrisost Exp $
REM +===========================================================================+
REM |                 Copyright (c) 2001 Oracle Corporation                     |
REM |                    Redwood Shores, California, USA                        |
REM |                         All rights reserved.                              |
REM +===========================================================================+
REM |                                                                           |
REM | FILENAME                                                                  |
REM |    drop_ar_tca_analyzer.sql                                               |
REM |                                                                           |
REM | DESCRIPTION                                                               |
REM |    If needed, SQL to drop package used for Trading Community Architecture |
REM |                                                                           |
REM |                                                                           |
REM | IMPORTANT NOTE:  Make sure to disable concurrent request if analyzer has  |
REM | been setup to run as concurrent program.                                  |
REM |                                                                           |
REM +===========================================================================+

DROP PACKAGE ar_tca_analyzer_pkg;