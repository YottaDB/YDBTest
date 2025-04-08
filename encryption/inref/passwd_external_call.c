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
#define MAX	64

char	env_str[MAX];
int setCorrectPasswd()
{
	char	*ptr;
	ptr = (char *)getenv(GTM_PASSWD_MASKED);
	snprintf(env_str, MAX, "%s=%s", GTM_PASSWD, ptr);
	return putenv(env_str);
}

int setWrongPasswd()
{
	char 	*ptr;
	ptr = (char *)getenv(GTM_WRONG_PASSWD_MASKED);
	snprintf(env_str, MAX, "%s=%s", GTM_PASSWD, ptr);
	return putenv(env_str);
}

int setNullPasswd()
{
	snprintf(env_str, MAX, "%s=%s", GTM_PASSWD, "");
	return putenv(env_str);
}
