CREATE OR REPLACE PACKAGE APPS.XXDBL_ECC_ITEM_ALLOC AUTHID CURRENT_USER AS
/* $Header: INVEONHS.pls 120.0.12020000.2 2019/05/07 06:39:57 ppulloor noship $ */

/* +======================================================================+ */
/* |    Copyright (c) 2016, 2019 Oracle and/or its affiliates.            | */
/* |                      All rights reserved.                            | */
/* |                      Version 1.0.0                                   | */
/* +======================================================================+ */
/*                                                                          */
/* +======================================================================+ */
/*  FILENAME: INVEONHS.pls                                */
/*  DESCRIPTION:                                                            */
/*    Package for EBS Data Load in ECC Aging                                */
/*                                                                          */
/*  Version History                                                         */
/*                                                                          */
/*  1.0   ppulloor Created                                                  */
/*                                                                          */
/* +======================================================================+ */


G_INV_ECC_INS_OP CONSTANT VARCHAR2(30) := 'INSERT';
G_INV_ECC_UPD_OP CONSTANT VARCHAR2(30) := 'UPDATE';
G_INV_ECC_DEL_OP CONSTANT VARCHAR2(30) := 'DELETE';
G_INV_ECC_UPS_OP CONSTANT VARCHAR2(30) := 'UPSERT';

G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR       CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

PROCEDURE debug_print(p_message IN VARCHAR2,
                      p_level IN NUMBER := 9);


PROCEDURE GET_ECC_DATA_LOAD_INFO(
	p_dataset_key                    IN VARCHAR2,
	p_load_type                      IN VARCHAR2,
	p_ds_last_success_run            IN TIMESTAMP,
   p_languages                      IN VARCHAR2,
   P_ADDL_PARAMS                    IN  ECC_SEC_FIELD_VALUES DEFAULT NULL,
	x_ecc_ds_meta_rec                OUT NOCOPY  ecc_ds_meta_rec,
	x_return_status                  OUT NOCOPY VARCHAR2);

end;
/


