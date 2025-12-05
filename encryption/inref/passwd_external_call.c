/****************************************************************
 *								*
 * Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 * Portions Copyright (c) Fidelity National			*
 * Information Services, Inc. and/or its subsidiaries.		*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdlib.h>
#include <stdio.h>

#define GTM_PASSWD "gtm_passwd"
#define GTM_PASSWD_MASKED "gtm_passwd_masked"
#define GTM_WRONG_PASSWD_MASKED "gtm_wrong_passwd_masked"

int setCorrectPasswd()
{
	return setenv(GTM_PASSWD, (char *)getenv(GTM_PASSWD_MASKED), 1);
}

int setWrongPasswd()
{
	return setenv(GTM_PASSWD, (char *)getenv(GTM_WRONG_PASSWD_MASKED), 1);
}

int setNullPasswd()
{
	return setenv(GTM_PASSWD, "", 1);
}
