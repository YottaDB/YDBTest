/*
 * col_unicode_numeric.c
 * 	This collation library is meant to reverse the collation order for
 * 	Hindi numbers.  It does so by swapping the last byte of the 3-byte
 * 	Hindi encoded character.  This is not safe to use outside reverse
 * 	collation of Hindi numbers.
 */

#include "gtm_stdio.h"
#include "gtm_stdlib.h"
#include "gtm_string.h"
#include "gtm_descript.h"

#define SUCCESS			0
#define FAILURE			1
#define VERSION			3
#define MYAPPS_SUBSC2LONG	12345678 /* Wow I mean Wow */

#ifdef DEBUG
#define DEBUG_ONLY(x)	x
#else
#define DEBUG_ONLY(x)
#endif

long hindinumreverse (const char *parent, gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen);

long gtm_ac_xform ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	return hindinumreverse("gtm_ac_xback", src, level, dst, dstlen);
}

long gtm_ac_xback ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	return hindinumreverse("gtm_ac_xback", src, level, dst, dstlen);
}

int gtm_ac_version ()
{
	return VERSION;
}

int gtm_ac_verify (unsigned char type, unsigned char ver)
{
    	return !(ver == VERSION);
}

long hindinumreverse (const char *parent, gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	int		num, srclength, i;
	char		*outbuf, *conv, *srcbuf;

	/* reject calls that pass in NULLs or zero length strings */
	if (dst == NULL) {
		return MYAPPS_SUBSC2LONG;
	}
	memset((void *)dst->val, 0, dst->len);
	if ( src == NULL || src->len == 0) {
		dst->len=0;
		*dstlen=0;
		return SUCCESS;
	}

	if (src->len > dst->len)
		return MYAPPS_SUBSC2LONG;

	/* setup pointers and sanitize PADded mval input string */
	outbuf = dst->val;
	srclength = (int)src->len;
	srcbuf = (char *)malloc(srclength+1);
	memset((void *)srcbuf, 0, srclength+1);
	strncpy(srcbuf, (const char *)src->val, srclength);

	DEBUG_ONLY(fprintf(stderr, "%s :: srcbuf string  :: %s(%d)\n", parent, srcbuf, srclength);)

	*dstlen=srclength;
	strncpy(outbuf, srcbuf, srclength);
	dst->len=srclength;
	for (i=0; i < srclength; i+=3) {
		DEBUG_ONLY(fprintf(stderr, "%s :: outbuf string  :: $zchar(%d,%d,%d)\n",
					parent, (int)(unsigned char)outbuf[i],
					(int)(unsigned char)outbuf[i+1],(int)(unsigned char)outbuf[i+2]);)

		/* ignore any non-hindi byte sequence. this is by no means a complete method*/
		if (224 != (int)(unsigned char)outbuf[i] || 165 != (int)(unsigned char)outbuf[i+1]) continue;
		outbuf[i+2]=(char)(341-((int)(unsigned char)outbuf[i+2]));

		DEBUG_ONLY(fprintf(stderr, "%s :: outbuf string  :: $zchar(%d,%d,%d)\n",
					parent, (int)(unsigned char)outbuf[i],
					(int)(unsigned char)outbuf[i+1],(int)(unsigned char)outbuf[i+2]);)
	}

	DEBUG_ONLY(fprintf(stderr, "%s :: outbuf string :: %s(%d)\n\n", parent, outbuf, (int)dst->len);)

	free(srcbuf);
	return SUCCESS;
}

