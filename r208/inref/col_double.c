/****************************************************************
 *								*
 * Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* A test collation in which each byte of a string is stored twice, so the key form of a string subscript is twice as
 * long as with the standard collation (see r208/u_inref/trigger_subs_too_long-ydb1356.csh). Strings collate in the same
 * order as with the standard collation.
 */
#include <stdlib.h>
#include <string.h>
#include "gtm_descript.h"
#define SUBC2LONG 12345678
long gtm_ac_xform(gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	int		n;
	unsigned char	*cp, *cpout;

	n = src->len;
	if ((2 * n) > dst->len)
		return SUBC2LONG;
	cp = (unsigned char *)src->val;
	cpout = (unsigned char *)dst->val;
	while (n-- > 0)
	{
		*cpout++ = *cp;
		*cpout++ = *cp++;
	}
	*dstlen = 2 * src->len;
	return 0;
}
long gtm_ac_xback(gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	int		n;
	unsigned char	*cp, *cpout;

	n = src->len / 2;
	if (n > dst->len)
		return SUBC2LONG;
	cp = (unsigned char *)src->val;
	cpout = (unsigned char *)dst->val;
	while (n-- > 0)
	{
		*cpout++ = *cp;
		cp += 2;
	}
	*dstlen = src->len / 2;
	return 0;
}
int gtm_ac_version(void)
{
	return 1;
}
int gtm_ac_verify(unsigned char type, unsigned char ver)
{
	return !(ver == type);
}
