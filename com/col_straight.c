/****************************************************************
*								*
*	Copyright 2003, 2014 Fidelity Information Services, Inc	*
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
/*
 * col_straight.c	Alternative collation sequence
 * actually, it is rather simple, it collates everyting the same
 * i.e. 1-255 -> 1-255
 *
 */

#include <stdlib.h>
#include <string.h>
#include "gtm_descript.h"

#define MYAPP_SUBC2LONG 12345678
#define MYAPP_WRONGVERSION 20406080
#define COLLATION_TABLE_SIZE		256
#define COLLATION_ROUTINE_VERSION	1
#define SUCCESS     0
#define FAILURE     1

 static unsigned char	xform_table[COLLATION_TABLE_SIZE] =
{
  0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,
 16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,
 32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
 48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
 64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,
 96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255
};

static unsigned char	inverse_table[COLLATION_TABLE_SIZE] =
{
  0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,
 16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,
 32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
 48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
 64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,
 96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255
};

long gtm_ac_xform ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	int n;
	unsigned char  *cp, *cpout;


	n = src->len;
	if ( n > dst->len)
		return MYAPP_SUBC2LONG;

	cp  = (unsigned char *)src->val;
	cpout = (unsigned char *)dst->val;

	while ( n-- > 0 )
	   *cpout++ = xform_table[*cp++];

	*dstlen = src->len;

	return 0;
}

long gtm_ac_xback ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	int	n;
	unsigned char  *cp, *cpout;


	n = src->len;
	if ( n > dst->len)
	  return MYAPP_SUBC2LONG;

	cp  = (unsigned char *)src->val;
	cpout = (unsigned char *)dst->val;

	while ( n-- > 0 )
	   *cpout++ = inverse_table[*cp++];

	*dstlen = src->len;

	return 0;
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
		/* There are 3 cases here. If it is case 0, we just send the input to the collation table unmodified to be
		 * collated to the appropriate character. If it is case 1 (equivalent to -2 as 3rd argument), we either return
		 * the collation of charindx - 1 or an empty string if no such collation exists. If case 2, we either return the
		 * collation of charindx + 1 or an empty string if no such collation exists.
		 */
		case 0:
			memcpy(out->val, &xform_table[charindx], 1);
			*outlen = 1;
			return 0;
		case 1:
			if (1 <= charindx)
			{
				memcpy(out->val, &xform_table[charindx] - 1, 1);
				*outlen = 1;
			} else
				*outlen = 0;
			return 0;
		case 2:
			if (254 >= charindx)
			{
				memcpy(out->val, &xform_table[charindx + 1], 1);
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
	char *ver_ptr;
	int version;
	version = 0;
	if (NULL != (ver_ptr = (char *)getenv("gtm_test_col_return_version")))
		version = atoi(ver_ptr);
	return version;
}

int gtm_ac_verify (unsigned char type, unsigned char ver)
{
	return !(ver == gtm_ac_version());
}

int main ( )
{
}
