/****************************************************************
 *								*
 * Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	*
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

#include "shrenv.h"
#include "gtm_stdio.h"
#include "gtm_stdlib.h"
#include "gtm_string.h"
#include "gtmxc_types.h"
#include <string.h>
#include <locale.h>

void
xc_wcslen( int count,
		xc_char_t **in_data,
                xc_string_t *out_data)
{
	int len,n;
	wchar_t *wp;
	char *c;

	setlocale(LC_ALL, "");
	c = *in_data;
	n = (strlen(*in_data) + 1) * sizeof(wchar_t);
	wp = (wchar_t *)malloc(n);
	len = mbstowcs(wp, *in_data, n);
	len = wcslen(wp);
        (void)SPRINTF(out_data->address,"%d",len);
	fflush(stdout);
        out_data->length = strlen(out_data->address);
}

void xc_wcscat	(int count,
		 xc_char_t **in_data1,
		 xc_char_t **in_data2,
		 xc_char_t **out_data)
{
	wchar_t *w1, *w2;
	int n1,n2,len;
	setlocale(LC_ALL, "");

	n1 = (strlen(*in_data1) + 1) * sizeof(wchar_t);
	w1 = (wchar_t *)malloc(n1);
	len = mbstowcs(w1,*in_data1,n1);
	n2 = (strlen(*in_data2) + 1) * sizeof(wchar_t);
	w2 = (wchar_t *)malloc(n2+n1);
	len = mbstowcs(w2,*in_data2,n2);
	wcscat(w2,w1);
        (void)SPRINTF(*out_data,"%ls",w2);
	fflush(stdout);
}

void xc_wcscpy	(int count,
		 xc_char_t **in_data,
		 xc_char_t **out_data)
{
	wchar_t *w1,*w2;
	int n,len;
	setlocale(LC_ALL, "");

	n = (strlen(*in_data) + 1) * sizeof(wchar_t);
	w1 = (wchar_t *)malloc(n);
	w2 = (wchar_t *)malloc(n);
	len = mbstowcs(w1,*in_data,n);

	wcscpy(w2,w1);
	(void)SPRINTF(*out_data,"%ls",w2);
	fflush(stdout);
}
