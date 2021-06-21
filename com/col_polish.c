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
 * collation.c	Alternative collation sequence
 *
 */
#include <stdio.h>
#include <string.h>
#include "gtm_descript.h"

#define COLLATION_TABLE_SIZE		256
#define MYAPPS_SUBSC2LONG		12345678 /* Wow I mean Wow */
#define SUCCESS     0
#define FAILURE     1				/* Yeah Right!!! But I have seen crazier things in this code. */
#define VERSION	    3

 static unsigned char	xform_table[COLLATION_TABLE_SIZE] =
{
 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
 51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
 61, 62, 63, 64, 70, 78, 82, 90, 97, 104,
 106, 108, 112, 116, 118, 122, 128, 131, 139, 146,
 148, 152, 158, 166, 174, 180, 182, 184, 187, 191,
 197, 198, 199, 200, 201, 202, 65, 77, 79, 87,
 93, 103, 105, 107, 109, 115, 117, 119, 127, 129,
 135, 145, 147, 149, 155, 163, 169, 179, 181, 183,
 185, 189, 203, 204, 205, 206, 220, 221, 222, 223,
 224, 225, 226, 227, 228, 229, 230, 231, 232, 233,
 234, 235, 236, 237, 238, 239, 240, 241, 242, 243,
 244, 245, 246, 247, 248, 249, 250, 251, 252, 253,
 76, 207, 126, 208, 123, 162, 209, 210, 159, 160,
 167, 194, 211, 192, 196, 212, 75, 213, 125, 214,
 120, 161, 215, 216, 156, 157, 164, 193, 217, 190,
 195, 153, 71, 72, 73, 74, 124, 86, 83, 84,
 98, 102, 99, 100, 113, 114, 91, 92, 134, 132,
 144, 140, 141, 142, 218, 154, 175, 176, 177, 178,
 188, 168, 254, 150, 66, 67, 68, 69, 121, 85,
 80, 81, 94, 101, 95, 96, 110, 111, 88, 89,
 133, 130, 143, 136, 137, 138, 219, 151, 170, 171,
 172, 173, 186, 165, 255
};

static unsigned char	inverse_table[COLLATION_TABLE_SIZE] =
{
 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
 51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
 61, 62, 63, 64, 97, 225, 226, 227, 228, 65,
 193, 194, 195, 196, 177, 161, 98, 66, 99, 231,
 232, 67, 199, 200, 230, 198, 100, 239, 240, 68,
 207, 208, 101, 233, 235, 236, 69, 201, 203, 204,
 234, 202, 102, 70, 103, 71, 104, 72, 105, 237,
 238, 73, 205, 206, 106, 74, 107, 75, 108, 181,
 229, 76, 165, 197, 179, 163, 109, 77, 110, 242,
 78, 210, 241, 209, 111, 244, 245, 246, 79, 212,
 213, 214, 243, 211, 112, 80, 113, 81, 114, 224,
 248, 82, 192, 216, 115, 185, 186, 83, 169, 170,
 182, 166, 116, 187, 254, 84, 171, 222, 117, 249,
 250, 251, 252, 85, 217, 218, 219, 220, 118, 86,
 119, 87, 120, 88, 121, 253, 89, 221, 122, 190,
 90, 174, 188, 172, 191, 175, 91, 92, 93, 94,
 95, 96, 123, 124, 125, 126, 162, 164, 167, 168,
 173, 176, 178, 180, 183, 184, 189, 215, 247, 127,
 128, 129, 130, 131, 132, 133, 134, 135, 136, 137,
 138, 139, 140, 141, 142, 143, 144, 145, 146, 147,
 148, 149, 150, 151, 152, 153, 154, 155, 156, 157,
 158, 159, 160, 223, 255
};

long gtm_ac_xform ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	int n;
	unsigned char  *cp, *cpout;
#ifdef DEBUG
	char 	input[256], output[256];
#endif
	n = src->len;
	if ( n > dst->len)
		return MYAPPS_SUBSC2LONG;

	cp  = (unsigned char *)src->val;
#ifdef DEBUG
	memcpy(input, cp, src->len);
	input[src->len] = '\0';
#endif
	cpout = (unsigned char *)dst->val;

	while ( n-- > 0 )
	   *cpout++ = xform_table[*cp++];

        *cpout = '\0';

	*dstlen = src->len;
#ifdef DEBUG
	memcpy(output, dst->val, dst->len);
	output[dst->len] = '\0';

	fprintf(stderr, "\nInput = \n");
	for (n = 0; n < *dstlen; n++ ) fprintf(stderr," %d ",(int )input[n]);
	fprintf(stderr, "\nOutput = \n");
	for (n = 0; n < *dstlen; n++ ) fprintf(stderr," %d ",(int )output[n]);
#endif

	return SUCCESS;
}

long gtm_ac_xback ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	int	n;
	unsigned char  *cp, *cpout;
#ifdef DEBUG
	char 	input[256], output[256];
#endif

	n = src->len;
	if ( n > dst->len)
		return MYAPPS_SUBSC2LONG;

	cp  = (unsigned char *)src->val;
	cpout = (unsigned char *)dst->val;

	while ( n-- > 0 )
	   *cpout++ = inverse_table[*cp++];

        *cpout = '\0';

	*dstlen = src->len;
#ifdef DEBUG
	memcpy(input, src->val, src->len);
	input[src->len] = '\0';
	memcpy(output, dst->val, dst->len);
	output[dst->len] = '\0';
	fprintf(stderr, "Input = %s, Output = %s\n",input, output);
#endif

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
	return VERSION;
}

int gtm_ac_verify (unsigned char type, unsigned char ver)
{
    	return !(ver == VERSION);
}
