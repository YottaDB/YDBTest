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

int gtm_ac_version ()
{
	return VERSION;
}

int gtm_ac_verify (unsigned char type, unsigned char ver)
{
    	return !(ver == VERSION);
}

