/****************************************************************
 *								*
 * Copyright (c) 2002-2015 Fidelity National Information 	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#include <string.h>
#include "shrenv.h"
#include "gtm_stdio.h"
#include "gtmxc_types.h"

#ifdef __MVS__
#pragma export(xc_pre_alloc_a)
#endif

/* Note that without preallocation by default GT.M allocates 100 bytes for  char * type */
void	xc_pre_alloc_a (int count, char*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	strcpy(arg_prealloca, "New Message");
	fflush (stdout);

	return;
}
void	xc_new_alloc_32k (int count, xc_char_t*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	memset(arg_prealloca, 'A',32766);
	arg_prealloca[32766] = '\0';
	fflush (stdout);

	return;
}
void	xc_new_alloc_64k (int count, xc_char_t*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	memset(arg_prealloca, 'A',65535);
	arg_prealloca[65535] = '\0';
	fflush (stdout);

	return;
}
void	xc_new_alloc_75k (int count, xc_char_t*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	memset(arg_prealloca, 'A',74999);
	arg_prealloca[74999] = '\0';
	fflush (stdout);

	return;
}

void	xc_new_alloc_1mb (int count, xc_char_t*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	memset(arg_prealloca, 'A',1048575);
	arg_prealloca[1048575] = '\0';
	fflush (stdout);

	return;
}

/* for string star testing */

void	xc_new_alloc_32kstr (int count, xc_string_t*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	memset(arg_prealloca->address, 'A',32766);
	arg_prealloca->length = 32766;
	fflush (stdout);

	return;
}
void	xc_new_alloc_64kstr (int count, xc_string_t*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	memset(arg_prealloca->address, 'A',65535);
	arg_prealloca->length = 65535;
	fflush (stdout);

	return;
}
void	xc_new_alloc_75kstr (int count, xc_string_t*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	memset(arg_prealloca->address, 'A',74999);
	arg_prealloca->length = 74999;
	fflush (stdout);

	return;
}
void	xc_new_alloc_1mbstr (int count, xc_string_t*  arg_prealloca)
{
	FPRINTF(stderr,"sizeof(arg_prealloca) = %d\n", (int) sizeof(arg_prealloca));
	memset(arg_prealloca->address, 'A',1048575);
	arg_prealloca->length = 1048575;
	fflush (stdout);

	return;
}

