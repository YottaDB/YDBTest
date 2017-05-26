/****************************************************************
*								*
*	Copyright 2014 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
/*
 * col_reverse.c	Alternative collation sequence library.
 * 			This library simulates the buffer overflow while perfomring inverse collation transformation.
 */
#include "gtm_descript.h"
#include <sys/types.h>
#include <assert.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define MYAPP_SUBC2LONG 		12345678
#define COLLATION_TABLE_SIZE		256
#define COLLATION_ROUTINE_VERSION	1
#define SUCCESS     			0

static struct sigaction old_act;

static unsigned char xtransform[COLLATION_TABLE_SIZE] =
{
255, 254, 253, 252, 251, 250, 249, 248, 247, 246, 245, 244, 243, 242, 241, 240,
239, 238, 237, 236, 235, 234, 233, 232, 231, 230, 229, 228, 227, 226, 225, 224,
223, 222, 221, 220, 219, 218, 217, 216, 215, 214, 213, 212, 211, 210, 209, 208,
207, 206, 205, 204, 203, 202, 201, 200, 199, 198, 197, 196, 195, 194, 193, 192,
191, 190, 189, 188, 187, 186, 185, 184, 183, 182, 181, 180, 179, 178, 177, 176,
175, 174, 173, 172, 171, 170, 169, 168, 167, 166, 165, 164, 163, 162, 161, 160,
159, 158, 157, 156, 155, 154, 153, 152, 151, 150, 149, 148, 147, 146, 145, 144,
143, 142, 141, 140, 139, 138, 137, 136, 135, 134, 133, 132, 131, 130, 129, 128,
127, 126, 125, 124, 123, 122, 121, 120, 119, 118, 117, 116, 115, 114, 113, 112,
111, 110, 109, 108, 107, 106, 105, 104, 103, 102, 101, 100,  99,  98,  97,  96,
 95,  94,  93,  92,  91,  90,  89,  88,  87,  86,  85,  84,  83,  82,  81,  80,
 79,  78,  77,  76,  75,  74,  73,  72,  71,  70,  69,  68,  67,  66,  65,  64,
 63,  62,  61,  60,  59,  58,  57,  56,  55,  54,  53,  52,  51,  50,  49,  48,
 47,  46,  45,  44,  43,  42,  41,  40,  39,  38,  37,  36,  35,  34,  33,  32,
 31,  30,  29,  28,  27,  26,  25,  24,  23,  22,  21,  20,  19,  18,  17,  16,
 15,  14,  13,  12,  11,  10,   9,   8,   7,   6,   5,   4,   3,   2,   1,   0
};

void accvio_handler(int sig)
{
	assert(SIGSEGV == sig);
	printf("\nCOL-E-OVERFLOW, Buffer overflow occurred in shared library\n");
	fflush(stdout);
	sigaction(SIGSEGV, &old_act, NULL);
	exit(1);	/* to avoid GT.M from dumping core. */
}

long gtm_ac_xform(gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	int 		n;
	unsigned char	*cp, *cpout;

	n = src->len;
	if (n > dst->len)
		return MYAPP_SUBC2LONG;

	cp  = (unsigned char *)src->val;
	cpout = (unsigned char *)dst->val;

	while (n-- > 0)
		*cpout++ = xtransform[*cp++];
	*dstlen = src->len;
	return SUCCESS;
}

long gtm_ac_xback(gtm_descriptor *src, int level, gtm_descriptor *dst, int *dstlen)
{
	int			n, pagesize;
	unsigned char  		*cp, *cpout;
	struct sigaction	act;

	pagesize = getpagesize();
	assert(0 != pagesize);
	n = src->len;
	if (n > dst->len)
		return MYAPP_SUBC2LONG;

	cp = (unsigned char *)src->val;
	cpout = (unsigned char *)dst->val;
	/* Setup a SIGSEGV handler to catch the potential buffer overflow that follows. */
	sigemptyset(&act.sa_mask);
	act.sa_flags = 0;
	act.sa_handler = accvio_handler;
	sigaction(SIGSEGV, &act, &old_act);
	/* Do regular backward conversion. */
	while (n-- > 0)
		*cpout++ = xtransform[*cp];

	/* Overflow one pagesize. */
	memset(cpout, 0, pagesize);
	assert(0); /* shouldn't reach here. */
	*dstlen = src->len + (pagesize);
	return SUCCESS;
}

int gtm_ac_version()
{
	return COLLATION_ROUTINE_VERSION;
}

int gtm_ac_verify(unsigned char type, unsigned char ver)
{
	return SUCCESS;
}
