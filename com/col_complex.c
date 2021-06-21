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
/*
 * errorhandlingtestc	Alternative collation sequence for error testing purposes only.
 *                      Logic implemented in this module include:
 *			1. switch 'a' and 'b' -- to verify that this alternative sequence
 *						 is being used.
 *			2. return BADCHAR when the subscript is "please return BADCHAR";
 *			3. return ERR_SUB2LONG when the subscript is "please return SUB2LONG"
 */

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include "gtm_descript.h"

#define SUCCESS			0
#define FAILURE			1
#define VERSION			3

/* the follow macro will be defined in gtm_descriptor.h when the unicode project is implemented, this is just
   to get the testing going temporarily. Xianguan Li @ 2006/06/26 */
#define ERR_BADCHAR		0x87658765
#define ERR_SUB2LONG		150375154


extern int errno;

long gtm_ac_xform ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	char *inbuf, *outbuf, ch;
	int srclen, maxdstlen, cmp_result, ii;

	srclen = src->len;
	maxdstlen = dst->len;
	inbuf = (char *)src->val;
	outbuf = (char *)dst->val;

	cmp_result = strncmp(inbuf, "please return BADCHAR", 21);
	if (cmp_result == 0) {
		return ERR_BADCHAR;
	}

	cmp_result = strncmp(inbuf, "please return SUB2LONG", 22);
	if (cmp_result == 0) {
		return ERR_SUB2LONG;
	}

	for (ii = 0; ii < srclen; ii++) {
		ch = *(inbuf + ii);
		if (ch == 'a') {
			ch = 'b';
		}
		else if (ch == 'b') {
			ch = 'a';
		}
		*(outbuf + ii) = ch;
	}

	*dstlen = srclen;

	return SUCCESS;
}

long gtm_ac_xback ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	char *inbuf, *outbuf, ch;
	int srclen, maxdstlen, cmp_result, ii;

	srclen = src->len;
	maxdstlen = dst->len;
	inbuf = (char *)src->val;
	outbuf = (char *)dst->val;

	for (ii = 0; ii < srclen; ii++) {
		ch = *(inbuf + ii);
		if (ch == 'a') {
			ch = 'b';
		}
		else if (ch == 'b') {
			ch = 'a';
		}
		*(outbuf + ii) = ch;
	}

	*dstlen = srclen;

	return SUCCESS;
}

/* This function returns the next or previous collated character respectively for a $ZATRANSFORM command where the
 * third argument to $ZATRANSFORM is 2 or -2. Parameters are:
 * The parameter in - Supplies the input string, the first character of which is considered
 * The parameter level - Currently unused and should not be examined or changed
 * The parameter out - Supplies the one (1) character result string produced by applying the collation operation if a result was possible
 * The parameter outlen - Supplies to the caller the length of the returned string, which will be 0 or 1.
 * The parameter op - Specifies the collation operation returned:
 *   0 - collation value of the given character
 *   1 - character collating before the given character if it exists
 *   2 - character collating after the given character if it exists
 * The parameter honor_numeric - Boolean specifying:
 *   TRUE  - standard GT.M collation of digits before any other character
 *   FALSE - digits should be treated the same as all other characters
 * The gtm_ac_xutil function returns 0 on success and -1 on failure.
 */
long gtm_ac_xutil (gtm32_descriptor *in, int level, gtm32_descriptor *out, int *outlen, int op, int honor_numeric)
{
	/* Get the input character (a gtm32_descriptor's val is a void *) */
	unsigned char charindx;
	charindx = *(unsigned char *)in->val;
	switch (op)
	{
		/* As this collation swaps 'a' and 'b' and otherwise just returns the input unless it is "please return BADCHAR"
		 * or "please return ERR_SUB2LONG", this gtm_ac_xutil function is different from the others. There are 3 cases
		 * here. If it is case 0, we just send the first character of input unless it is 'a' or 'b' in which case we swap
		 * it with the appropriate character. If it is case 1 (equivalent to -2 as 3rd argument), we either return the
		 * character that collates before the input (charindx - 1 except that 'b' is before 'a') or an empty string if no
		 * such collation exists. If case 2, we either return the character that collates after the input (charindx + 1
		 * except that 'a' is after 'b') or an empty string if no such collation exists.
		 */
		case 0:
			memcpy(out->val, &charindx, 1);
			*outlen = 1;
			return 0;
		case 1:
			if (1 <= charindx)
			{
				switch (charindx)
				{
					case 'a':
						charindx++; /* set charindx equal to 'b' */
						break;
					case 'b':
					case 'c':
						/* As 'b' and 'a' are swapped in this collation, 'b' collates to the character
						 * before 'a' in standard ASCII and 'c' collates to 'a'. So both collate to the
						 * character that is 2 characters prior to the input in standard ASCII.
						 */
						charindx = charindx - 2;
						break;
					default:
						charindx--; /* previous character */
						break;
				}
				memcpy(out->val, &charindx, 1);
				*outlen = 1;
			} else
				*outlen = 0;
			return 0;
		case 2:
			if (254 >= charindx)
			{
				switch (charindx)
				{
					case 'a' - 1:
					case 'a':
						/* The character before 'a' in standard ASCII collates to 'b' and 'a' collates
						 * to 'c'.
						 */
						charindx = charindx + 2;
						break;
					case 'b':
						charindx--; /* set to 'a' */
						break;
					default:
						charindx++; /* next character */
						break;
				}
				memcpy(out->val, &charindx, 1);
				*outlen = 1;
			} else
				*outlen = 0;
			return 0;
		default:
			return -1;
	}
}

int gtm_ac_version ()
{
	return VERSION;
}

int gtm_ac_verify (unsigned char type, unsigned char ver)
{
    	return !(ver == VERSION);
}

