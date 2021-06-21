/****************************************************************
*								*
* Copyright 2013 Fidelity Information Services, Inc		*
*								*
* Copyright (c) 2020-2021 YottaDB LLC and/or its subsidiaries.	*
* All rights reserved.						*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
/*
 * chinese.c	Alternative collation sequence for Chinese
 *              This alternative collation sequence
 *		simply transfers UTF-8 encoded string into GB18030
 *
 * 		Study has showed that the iconv implementation does
 * 		the conversion good enough for Chinese characters and
 *		most of the other characters. However, it is not perfect.
 *		Tests have revealed that it is not able to transfer utf-8
 *		encoded strings to GB18030 and right back to utf-8 without
 *		losing any information in the following code point ranges
 *			0xD800 -- 0xDFFF ==> High Surrogates
 *					 ==> High Private Use Surrogates
 *					 ==> Low Surrogates
 *			0x16E5B -- 0x10FFFF (not sure what is there...)
 *
 *		In any case, it is recommended that any production implementation
 *		of alternative collation sequence that uses the iconv
 *		utility should verify the conversion first. And use it
 *		for code points that make the round trip only.
 *		    -- Xianguan Li @ 2006/06/26
 *
 * -- If the src string is not UTF-8 encoded, return the original src string
 *	Another way to handle this is to return BADCHAR which will be introduced
 *	in the new gtm_descript.h. However, this implementation chose to
 *	return the original string for backward compatibility considerations.
 * 	(Another reason is that at the time of this writing, the gtm_descript.h
 *	does not exist yet.)
 *
 * -- If there is need to allocate more memory than what is already allocated,
 *   	then, a complete solution will need to be worked out. The memory
 *	dynamically allocated will need to be freed accordingly when time is
 * 	right. In case of globals, if the string after the transformation is longer
 *	than 255, then, an error code of ERR_SUB2LONG should be returned.
 *
 * Note this routine contains some changes for Chinese UTF8 under Alpine even though it
 * does not (yet) work under Alpine. But these are the changes that are needed to make
 * it work once that support is added (heard it was in an upstream repo) ##ALPINE_TODO##
 */

#include <errno.h>
#include <iconv.h>

#include "gtm_descript.h"
#include "gtm_stdio.h"
#include "gtm_stdlib.h"
#include "gtm_string.h"

#define SUCCESS			0
#define FAILURE			1
#define VERSION			3

#define HAVE_NEW_ICONV defined(__linux__) || defined(__hpux) || defined(__MVS__) || defined(_AIX) ||				\
			(defined(__sun) && !defined(__SunOS_5_9) && !defined(__SunOS_5_10))

extern int errno;

long gtm_ac_xform ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
#if HAVE_NEW_ICONV
	char		*inbuf;
#else
	const char	*inbuf;
#endif
	char		*outbuf;
	size_t		inbytesleft;
	size_t		outbytesleft;
	char		*conv_from_chset, *conv_to_chset;
#	ifdef __linux__
	char		*distro;
#	endif

	conv_from_chset = "GB18030";
	conv_to_chset = "UTF-8";	/* Default convert-to character set */
	inbytesleft = src->len;
	outbytesleft = dst->len;
#if HAVE_NEW_ICONV
	inbuf = (char *)src->val;
#else
	inbuf = (const char *)src->val;
#endif
	outbuf = (char *)dst->val;

#ifdef DEBUG
	fprintf(stderr, "\ngt_ac_xform :: length of src and dst :: 0x%X  0x%X\n",
		src->len, dst->len);
#endif

#	ifdef __linux__
	/* Alpine linux with musl uses a different set of conversion names - specifically names should be in lower case
	 * and "UTF-8" should be "utf8".
	 */
	distro = getenv("gtm_test_linux_distrib");
	if (distro && (0 == strncmp("alpine", distro, sizeof("alpine"))))	/* Note max compare includes null terminator */
	{
		conv_from_chset = "gb18030";
		conv_to_chset = "utf8";
	}
#	endif

	iconv_t cd = iconv_open(conv_from_chset, conv_to_chset);
	if (cd == (iconv_t)(-1)) {
		fprintf(stderr, "\ngt_ac_xform :: error number from iconv_open :: %d\n",
				errno);
		return errno;
	}

	size_t conved = iconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
	if (conved == (size_t)(-1)) {
		fprintf(stderr, "\nerror number from iconv :: %d\n", errno);
		iconv_close(cd);
		return errno;
	}

	*outbuf = '\0';
	*dstlen = dst->len - (int)outbytesleft;

#ifdef DEBUG
	fprintf(stderr, "\ngt_ac_xform :: number of bytes converted :: %d\n", conved);
	fprintf(stderr, "\ngt_ac_xform :: inbytesleft :: %d\n", inbytesleft);
	fprintf(stderr, "\ngt_ac_xform :: outbytesleft :: %d\n", outbytesleft);
	fprintf(stderr, "\ngt_ac_xform :: outbuf points to :: %d\n", outbuf);
	fprintf(stderr, "\ngt_ac_xform :: inbuf points to :: %d\n", inbuf);
	fprintf(stderr, "\ngt_ac_xform :: original inbuf points to :: %d\n", src->val);
	fprintf(stderr, "\ngt_ac_xform :: original outbuf points to :: %d\n", dst->val);
	fprintf(stderr, "\ngt_ac_xform :: inbuf string :: %s\n", src->val);
	fprintf(stderr, "\ngt_ac_xform :: outbuf string :: %s\n", dst->val);
	fprintf(stderr, "\ngt_ac_xform :: input :: ");
	char *curr;
	curr = src->val;
	while (curr < inbuf) {
		fprintf(stderr, "0x%x ", 0xFF & *curr);
		curr++;
	}
	fprintf(stderr, "\n");
	fprintf(stderr, "\ngt_ac_xform :: output :: ");
	curr = dst->val;
	while (curr < outbuf) {
		fprintf(stderr, "0x%x ", 0xFF & *curr);
		curr++;
	}
	fprintf(stderr, "\n");
#endif

	iconv_close(cd);

	return SUCCESS;
}

long gtm_ac_xback ( gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
#if HAVE_NEW_ICONV
	char		*inbuf;
#else
	const char	*inbuf;
#endif
	char		*outbuf;
	size_t		inbytesleft;
	size_t		outbytesleft;

	inbytesleft = src->len;
	outbytesleft = dst->len;
#if HAVE_NEW_ICONV
	inbuf = (char *)src->val;
#else
	inbuf = (const char *)src->val;
#endif
	outbuf = (char *)dst->val;

#ifdef DEBUG
	fprintf(stderr, "\ngt_ac_xback :: length of src and dst :: 0x%X  0x%X\n",
		src->len, dst->len);
#endif

#if defined (__hpux)
	iconv_t cd = iconv_open("UTF-8", "gb18030");
#elif defined(__MVS__)
	iconv_t cd = iconv_open("UTF-8", "IBM-1386");
#else
	iconv_t cd = iconv_open("UTF-8", "GB18030");
#endif

	if (cd == (iconv_t)(-1)) {
		fprintf(stderr, "\ngt_ac_xback :: error number from iconv_open :: %d\n",
				errno);
		return errno;
	}

	size_t conved = iconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
	if (conved == (size_t)(-1)) {
		fprintf(stderr, "\nerror number from iconv :: %d\n", errno);
		iconv_close(cd);
		return errno;
	}

	*outbuf = '\0';
	*dstlen = dst->len - (int)outbytesleft;

#ifdef DEBUG
	fprintf(stderr, "\ngt_ac_xback :: number of bytes converted :: %d\n", conved);
	fprintf(stderr, "\ngt_ac_xback :: inbytesleft :: %d\n", inbytesleft);
	fprintf(stderr, "\ngt_ac_xback :: outbytesleft :: %d\n", outbytesleft);
	fprintf(stderr, "\ngt_ac_xback :: outbuf points to :: %d\n", outbuf);
	fprintf(stderr, "\ngt_ac_xback :: inbuf points to :: %d\n", inbuf);
	fprintf(stderr, "\ngt_ac_xback :: original inbuf points to :: %d\n", src->val);
	fprintf(stderr, "\ngt_ac_xback :: original outbuf points to :: %d\n", dst->val);
	fprintf(stderr, "\ngt_ac_xback :: inbuf string :: %s\n", src->val);
	fprintf(stderr, "\ngt_ac_xback :: outbuf string :: %s\n", dst->val);
	fprintf(stderr, "\ngt_ac_xback :: input :: ");
	char *curr;
	curr = src->val;
	while (curr < inbuf) {
		fprintf(stderr, "0x%x ", 0xFF & *curr);
		curr++;
	}
	fprintf(stderr, "\n");
	fprintf(stderr, "\ngt_ac_xback :: output :: ");
	curr = dst->val;
	while (curr < outbuf) {
		fprintf(stderr, "0x%x ", 0xFF & *curr);
		curr++;
	}
	fprintf(stderr, "\n");
#endif

	iconv_close(cd);

	return SUCCESS;
}

long gtm_ac_xutil (gtm32_descriptor *in, int level, gtm32_descriptor *out, int *outlen, int op, int honor_numeric)
{
		/* The $ZATRANSFORM options this function implements only work in M mode but this collation only
		 * works in UTF-8 mode so just return an empty string for this. This function returns 0 as returning
		 * -1 results in a ZATRANSCOL error. */
		*outlen = 0;
		return 0;
}

int gtm_ac_version ()
{
	return VERSION;
}

int gtm_ac_verify (unsigned char type, unsigned char ver)
{
    	return !(ver == VERSION);
}

