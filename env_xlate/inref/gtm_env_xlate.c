/****************************************************************
 *								*
 * Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
/* This module is derived from FIS GT.M.
 ****************************************************************/

#include <string.h>
#include "gtm_stdlib.h"
#include "gtm_stdio.h"

#include "gtmxc_types.h"
#include "shrenv.h"

/*void *GTM_MALLOC(size_t);*/
#define ENV_VAR         "GTM_CALLIN_START"
GTM64_ONLY(typedef  long (*int_fptr)();)
NON_GTM64_ONLY(typedef  int (*int_fptr)();)
int_fptr        GTM_MALLOC;
int_fptr        GTM_FREE;
void init_functable()
{

	char 	*pcAddress;
	long  	lAddress;
	void 	**functable;
	void 	(*setup_timer)  ();
	void 	(*cancel_timer) ();

	pcAddress = getenv(ENV_VAR);
	if (pcAddress == NULL)
	{
		FPRINTF(stdout, "\nsca_AlarmSetup: Failed to get environment variable %s.\n", ENV_VAR);
	}
	lAddress = -1;
	lAddress = STRTOUL(pcAddress, NULL, 10);
	if (lAddress == -1)
	{
		FPRINTF(stdout, "\nsca_AlarmSetup: Failed to convert %s to a valid address.", pcAddress);
	}
	functable = (void *)lAddress;
	setup_timer  = (void(*)()) functable[2];
	cancel_timer = (void(*)()) functable[3];
	GTM_MALLOC = (int_fptr) functable[4];
}


static xc_string_t tmp;
static xc_char_t str[100];
static xc_char_t *mumps = "mumps";
int gtm_env_xlate(xc_string_t *ptr1, xc_string_t *ptr2, xc_string_t *ptr_zdir, xc_string_t *ret_ptr)
{

	init_functable();
	/* This is a dummy script that malloc's everytime.
	 * It's whole purpose is to exercise the GT.M code */
	if (ptr2->address)
	{
		if (*ptr2->address == 'X')
		{
			tmp.address = (char *) GTM_MALLOC(36);
			tmp.length = 35;
			strcpy(tmp.address,"This is an error from gtm_env_xlate");
			ret_ptr->length=tmp.length;
			ret_ptr->address=tmp.address;
			return -1;
		}
		else if (*ptr2->address == 'Y')
		{
			ret_ptr->length = 0;
			return 100;
		}
		else if (*ptr2->address == 'Z')
		{
			ret_ptr->length = 33333;
			if (NULL == ptr2->address) return 0;
			if (*ptr2->address == 's')
				return 0;
			else
				return 1;
		}
		else if (*ptr2->address == 'T')
		{
			ret_ptr->address = str;
			memcpy(str, ptr_zdir->address,ptr_zdir->length);
			ret_ptr->length = ptr_zdir->length + 5;
			memcpy(str + ptr_zdir->length, mumps, 5);
			return 0;
		}
	}

	tmp.address = (char *) GTM_MALLOC(ptr2->length);
	tmp.length = ptr2->length;
	memcpy(tmp.address,ptr2->address,tmp.length);
	tmp.length=tmp.length;
	ret_ptr->length=tmp.length;
	ret_ptr->address=tmp.address;
	/*return -1;*/
	/*tmp.length = 0;*/
	return 0;
}
