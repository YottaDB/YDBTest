/****************************************************************
 *								*
 * Copyright 2014 Fidelity Information Services, Inc		*
 *								*
 * Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "gtm_common_defs.h"
#include "gtm_unistd.h"
#include "gtm_string.h"
#include "gtm_stdio.h"
#include "gtm_stdlib.h"
#include "gtm_fcntl.h"
#include "gtm_time.h"
#include <sys/resource.h>
#include "mdef.h"
#include "cli.h"
#include "gtm_threadgbl_init.h"
#include "gtm_malloc.h"
#include "gtmio.h"
#include "gtmimagename.h"
#include "mmrhash.h"
#include "md5hash.h"

void do_test_perf(void);
void do_test_stable(void);
void do_test_equiv(int urfd, int size, int zfd, int align);
int null_printf(const char *format, ...);

#define DEBUG_PRINTF		null_printf
#define REAL_PRINTF		printf

/* Sanity tests for hash functions */

int main(int argc, char *argv[])
{
	int urfd, zfd, i, j;
	DCL_THREADGBL_ACCESS;

	GTM_THREADGBL_INIT;

	/* In case we end up in util_out_send_oper(), pretend to be lke. */
	image_type = LKE_IMAGE;

	urfd = OPEN("/dev/urandom", O_RDONLY);
	if (-1 == urfd)
	{
		perror("open");
		exit(1);
	}
	zfd = OPEN("/dev/zero", O_RDONLY);
	if (-1 == zfd)
	{
		perror("open");
		exit(1);
	}

	DEBUG_PRINTF("ZERO DATA\n=========\n");

	for (i = 1; i <= 128; i++)
		for (j = 0; j < 8; j++)
			do_test_equiv(urfd, i, zfd, j);

	DEBUG_PRINTF("\nRANDOM DATA\n===========\n");

	for (i = 1; i <= 128; i++)
		for (j = 0; j < 8; j++)
			do_test_equiv(urfd, i, 0, j);

	DEBUG_PRINTF("\nRANDOM DATA, RANDOM SIZE\n========================\n");

	for (i = 0; i < 1024; i++)
		do_test_equiv(urfd, 0, 0, -1);

	do_test_stable();

#if 0
	do_test_perf();
#endif

	return 0;
}

/* Test that the hash functions get the same results on the same data with different alignments,
 * and ensure that different versions of the same hash function get the same results.
 *
 * urfd:	open file descriptor for /dev/urandom
 * size:	size of data to test, or 0 for random size
 * zfd:		open file descriptor for /dev/zero for all-zero data, or 0 for random data
 * align:	byte count for alignment adjustment, or -1 for random alignment
 */

void do_test_equiv(int urfd, int size, int zfd, int align)
{
	int			status, i;
	char			*buf, *unaligned_buf;
	unsigned short		data_size;
	unsigned char		align_offset, inc_size;
	uint4			hashval_32, ua_hashval_32;
	uint4			hashval_128[4];
	cvs_MD5_CTX		md5_context;
	unsigned char		md5_digest[MD5_DIGEST_LENGTH], ua_md5_digest[MD5_DIGEST_LENGTH], inc_md5_digest[MD5_DIGEST_LENGTH];
	gtm_uint8		hashval_128_64[2];
	gtm_uint16		phashval_128, ua_phashval_128, inc_phashval_128;
	hash128_state_t		phash_state_128;

	if (size > 0)
		data_size = size;
	else
	{	/* Get random size (0-64K) */
		DOREADRC(urfd, &data_size, SIZEOF(data_size), status);
		assertpro(0 == status);
	}
	buf = (char *) malloc(data_size);
	if (data_size > 0)
	{	/* Get data - zero if zfd set, random otherwise */
		DOREADRC((zfd ? zfd : urfd), buf, data_size, status);
		assertpro(0 == status);
	}
	DEBUG_PRINTF("Data Size: %d\n", data_size);
	if (align < 0)
	{	/* Get random alignment (0-15) */
		DOREADRC(urfd, &align_offset, SIZEOF(align_offset), status);
		assertpro(0 == status);
		align_offset &= 0xf;
	}
	else
		align_offset = align;
	DEBUG_PRINTF("Align Offset: %d\n", align_offset);
	/* Make re-aligned copy of the data */
	unaligned_buf = (char *) malloc(data_size + align_offset);
	memcpy(unaligned_buf + align_offset, buf, data_size);
	/* Test 32-bit hashes */
	MurmurHash3_x86_32(buf, data_size, 0, &hashval_32);
	DEBUG_PRINTF("MurmurHash3_x86_32: %08X\n", hashval_32);
	MurmurHash3_x86_32(unaligned_buf + align_offset, data_size, 0, &ua_hashval_32);
	DEBUG_PRINTF("MurmurHash3_x86_32(unaligned): %08X\n", ua_hashval_32);
	assertpro(hashval_32 == ua_hashval_32);

	/* Test 128-bit hashes */
	MurmurHash3_x86_128(buf, data_size, 0, &hashval_128);
	DEBUG_PRINTF("MurmurHash3_x86_128: %08X%08X%08X%08X\n", hashval_128[0], hashval_128[1], hashval_128[2], hashval_128[3]);
	MurmurHash3_x64_128(buf, data_size, 0, &hashval_128_64);
	DEBUG_PRINTF("%-30s %016lX%016lX\n", "MurmurHash3_x64_128:", hashval_128_64[0], hashval_128_64[1]);
	ydb_mmrhash_128(buf, data_size, 0, &phashval_128);
	DEBUG_PRINTF("%-30s %016lX%016lX\n", "ydb_mmrhash_128:", phashval_128.one, phashval_128.two);
	assertpro((hashval_128_64[0] == phashval_128.one) && (hashval_128_64[1] == phashval_128.two));
	ydb_mmrhash_128(unaligned_buf + align_offset, data_size, 0, &ua_phashval_128);
	DEBUG_PRINTF("%-30s %016lX%016lX\n", "ydb_mmrhash_128(unaligned):", ua_phashval_128.one, ua_phashval_128.two);
	assertpro((hashval_128_64[0] == ua_phashval_128.one) && (hashval_128_64[1] == ua_phashval_128.two));

	/* Test 128-bit incremental hashing */
	HASH128_STATE_INIT(phash_state_128, 0);
	for (i = 0; i < data_size; i += inc_size)
	{
		DEBUG_PRINTF("%d>", i);
		DOREADRC(urfd, &inc_size, SIZEOF(inc_size), status);
		assertpro(0 == status);
		if (inc_size + i > data_size)
			inc_size = data_size - i;
		ydb_mmrhash_128_ingest(&phash_state_128, unaligned_buf + align_offset + i, inc_size);
	}
	DEBUG_PRINTF("%d\n", data_size);
	ydb_mmrhash_128_result(&phash_state_128, data_size, &inc_phashval_128);
	DEBUG_PRINTF("%-30s %016lX%016lX\n", "ydb_mmrhash_128(incremental):", inc_phashval_128.one, inc_phashval_128.two);
	assertpro((hashval_128_64[0] == inc_phashval_128.one) && (hashval_128_64[1] == inc_phashval_128.two));

	/* Test md5 */
	cvs_MD5Init(&md5_context);
	cvs_MD5Update(&md5_context, (unsigned char const *) buf, data_size);
	cvs_MD5Final(md5_digest, &md5_context);
	DEBUG_PRINTF("%-30s ", "cvs_MD5:");
	for (i = 0; i < MD5_DIGEST_LENGTH; i++)
		DEBUG_PRINTF("%02X", (unsigned int) md5_digest[i]);
	DEBUG_PRINTF("\n");

	cvs_MD5Init(&md5_context);
	cvs_MD5Update(&md5_context, (unsigned char const *) unaligned_buf + align_offset, data_size);
	cvs_MD5Final(ua_md5_digest, &md5_context);
	DEBUG_PRINTF("%-30s ", "cvs_MD5(unaligned):");
	for (i = 0; i < MD5_DIGEST_LENGTH; i++)
		DEBUG_PRINTF("%02X", (unsigned int) ua_md5_digest[i]);
	DEBUG_PRINTF("\n");
	assertpro(0 == memcmp(md5_digest, ua_md5_digest, MD5_DIGEST_LENGTH));

	cvs_MD5Init(&md5_context);
	for (i = 0; i < data_size; i += inc_size)
	{
		DEBUG_PRINTF("%d>", i);
		DOREADRC(urfd, &inc_size, SIZEOF(inc_size), status);
		assertpro(0 == status);
		if (inc_size + i > data_size)
			inc_size = data_size - i;
		cvs_MD5Update(&md5_context, (unsigned char const *) unaligned_buf + align_offset + i, inc_size);
	}
	DEBUG_PRINTF("%d\n", data_size);
	cvs_MD5Final(inc_md5_digest, &md5_context);
	DEBUG_PRINTF("%-30s ", "cvs_MD5(incremental):");
	for (i = 0; i < MD5_DIGEST_LENGTH; i++)
		DEBUG_PRINTF("%02X", (unsigned int) inc_md5_digest[i]);
	DEBUG_PRINTF("\n");
	assertpro(0 == memcmp(md5_digest, inc_md5_digest, MD5_DIGEST_LENGTH));

	free(buf);
	free(unaligned_buf);
}

#define ITERATIONS		32768
#define LOW_SIZE		1024
#define HIGH_SIZE		16384
#define SIZE_MULTIPLIER		4
#define	MAX_INCREMENTS		256

#define TIMEVAL_DIFF_MS(AFTER, BEFORE) (((AFTER).tv_sec - (BEFORE).tv_sec) * 1000.0 + ((AFTER).tv_usec - (BEFORE).tv_usec) / 1000.0)

void do_test_perf(void)
{
	int			i, j, data_size, align_offset, inc_size, inc_num;
	unsigned char		*buf, *unaligned_buf;
	unsigned char		increments[MAX_INCREMENTS];
	struct rusage		before, after;
	time_t			now;
	pid_t			mypid;
	uint4			hashval_32;
	uint4			hashval_128[4];
	cvs_MD5_CTX		md5_context;
	unsigned char		md5_digest[MD5_DIGEST_LENGTH], inc_md5_digest[MD5_DIGEST_LENGTH];
	gtm_uint8		hashval_128_64[2];
	gtm_uint16		phashval_128;
	hash128_state_t		phash_state_128;

	buf = (unsigned char *) malloc(HIGH_SIZE);
	unaligned_buf = (unsigned char *) malloc(HIGH_SIZE + 16);

	now = time(0);
	mypid = getpid();
	HASH128_STATE_INIT(phash_state_128, 0);
	ydb_mmrhash_128_ingest(&phash_state_128, &now, SIZEOF(now));
	ydb_mmrhash_128_ingest(&phash_state_128, &mypid, SIZEOF(mypid));
	ydb_mmrhash_128_result(&phash_state_128, SIZEOF(now) + SIZEOF(mypid), &phashval_128);
	srandom((unsigned int)phashval_128.one);

	for (i = 0; i < MAX_INCREMENTS; i++)
		increments[i] = (unsigned char) random();

	for (i = 0; i < HIGH_SIZE; i++)
		buf[i] = (unsigned char) random();

	REAL_PRINTF("Iterations: %d\n", ITERATIONS);
	for (data_size = LOW_SIZE; data_size <= HIGH_SIZE; data_size *= SIZE_MULTIPLIER)
	{
		REAL_PRINTF("Data Size: %d\n", data_size);
		for (align_offset = 0; align_offset < 16; align_offset++)
		{
			REAL_PRINTF("Align Offset: %d\n", align_offset);
			memcpy(unaligned_buf + align_offset, buf, data_size);

			/* Reference 32-bit hash */
			getrusage(RUSAGE_SELF, &before);
			for (i = 0; i < ITERATIONS; i++)
				MurmurHash3_x86_32(unaligned_buf + align_offset, data_size, 0, &hashval_32);
			getrusage(RUSAGE_SELF, &after);
			REAL_PRINTF("%-30s %.3f kbytes/ms\n", "MurmurHash3_x86_32:",
					(double)data_size * ITERATIONS / 1024 / TIMEVAL_DIFF_MS(after.ru_utime, before.ru_utime));

			/* Reference 128-bit hash - 32-bit chunks */
			getrusage(RUSAGE_SELF, &before);
			for (i = 0; i < ITERATIONS; i++)
				MurmurHash3_x86_128(unaligned_buf + align_offset, data_size, 0, &hashval_128);
			getrusage(RUSAGE_SELF, &after);
			REAL_PRINTF("%-30s %.3f kbytes/ms\n", "MurmurHash3_x86_128:",
					(double)data_size * ITERATIONS / 1024 / TIMEVAL_DIFF_MS(after.ru_utime, before.ru_utime));

			/* Reference 128-bit hash - 64-bit chunks */
			getrusage(RUSAGE_SELF, &before);
			for (i = 0; i < ITERATIONS; i++)
				MurmurHash3_x64_128(unaligned_buf + align_offset, data_size, 0, &hashval_128_64);
			getrusage(RUSAGE_SELF, &after);
			REAL_PRINTF("%-30s %.3f kbytes/ms\n", "MurmurHash3_x64_128:",
					(double)data_size * ITERATIONS / 1024 / TIMEVAL_DIFF_MS(after.ru_utime, before.ru_utime));

			/* Progressive 128-bit hash */
			getrusage(RUSAGE_SELF, &before);
			for (i = 0; i < ITERATIONS; i++)
				ydb_mmrhash_128(unaligned_buf + align_offset, data_size, 0, &phashval_128);
			getrusage(RUSAGE_SELF, &after);
			REAL_PRINTF("%-30s %.3f kbytes/ms\n", "ydb_mmrhash_128:",
					(double)data_size * ITERATIONS / 1024 / TIMEVAL_DIFF_MS(after.ru_utime, before.ru_utime));

			assertpro((hashval_128_64[0] == phashval_128.one) && (hashval_128_64[1] == phashval_128.two));

			/* Progressive 128-bit hash - incremental */
			getrusage(RUSAGE_SELF, &before);
			for (j = 0; j < ITERATIONS; j++)
			{
				HASH128_STATE_INIT(phash_state_128, 0);
				for (i = 0, inc_num = 0; i < data_size; inc_num++, i += inc_size)
				{
					inc_size = increments[inc_num % MAX_INCREMENTS];
					if (inc_size + i > data_size)
						inc_size = data_size - i;
					ydb_mmrhash_128_ingest(&phash_state_128, unaligned_buf + align_offset + i, inc_size);
				}
				ydb_mmrhash_128_result(&phash_state_128, data_size, &phashval_128);
			}
			getrusage(RUSAGE_SELF, &after);
			REAL_PRINTF("%-30s %.3f kbytes/ms\n", "ydb_mmrhash_128 (incremental):",
					(double)data_size * ITERATIONS / 1024 / TIMEVAL_DIFF_MS(after.ru_utime, before.ru_utime));
			assertpro((hashval_128_64[0] == phashval_128.one) && (hashval_128_64[1] == phashval_128.two));

			/* md5 */
			getrusage(RUSAGE_SELF, &before);
			for (i = 0; i < ITERATIONS; i++)
			{
				cvs_MD5Init(&md5_context);
				cvs_MD5Update(&md5_context, (unsigned char const *) unaligned_buf + align_offset, data_size);
				cvs_MD5Final(md5_digest, &md5_context);
			}
			getrusage(RUSAGE_SELF, &after);
			REAL_PRINTF("%-30s %.3f kbytes/ms\n", "cvs_MD5:",
					(double)data_size * ITERATIONS / 1024 / TIMEVAL_DIFF_MS(after.ru_utime, before.ru_utime));

			/* md5 - incremental */
			getrusage(RUSAGE_SELF, &before);
			for (j = 0; j < ITERATIONS; j++)
			{
				cvs_MD5Init(&md5_context);
				for (i = 0; i < data_size; inc_num++, i += inc_size)
				{
					inc_size = increments[inc_num % MAX_INCREMENTS];
					if (inc_size + i > data_size)
						inc_size = data_size - i;
					cvs_MD5Update(&md5_context,
							(unsigned char const *) unaligned_buf + align_offset + i, inc_size);
				}
				cvs_MD5Final(inc_md5_digest, &md5_context);
			}
			getrusage(RUSAGE_SELF, &after);
			REAL_PRINTF("%-30s %.3f kbytes/ms\n", "cvs_MD5 (incremental):",
					(double)data_size * ITERATIONS / 1024 / TIMEVAL_DIFF_MS(after.ru_utime, before.ru_utime));
			assertpro(0 == memcmp(md5_digest, inc_md5_digest, MD5_DIGEST_LENGTH));

			fflush(stdout);
		}
	}

	free(buf);
	free(unaligned_buf);
}

void do_test_stable(void)
{
	unsigned char		hello_str[] = "Hello, World!";
	gtm_uint16		hello_hash_expected = { 0xD6E476E733054E07LLU, 0x30934B73EE0B074DLLU };
	unsigned char		alpha_str[] = "The quick brown fox jumped over the lazy dog.";
	gtm_uint16		alpha_hash_expected = { 0x373706FAB0BA6087LLU, 0xDD19BEC56A029B1FLLU };
	unsigned char		time_str[] = "Now is the time for all good men to come to the aid of their country.";
	gtm_uint16		time_hash_expected = { 0xAFDE4FFBBC680965LLU, 0xE60BD830BE06B182LLU };
	gtm_uint8		hashval_128_64[2];
	gtm_uint16		phashval_128;
	hash128_state_t		phash_state_128;

	DEBUG_PRINTF("Hello\n=====\n");
	ydb_mmrhash_128(hello_str, SIZEOF(hello_str), 0, &phashval_128);
	DEBUG_PRINTF("%-30s %016lX%016lX\n", "ydb_mmrhash_128:", phashval_128.one, phashval_128.two);
	assertpro((phashval_128.one == hello_hash_expected.one) && (phashval_128.two == hello_hash_expected.two));

	DEBUG_PRINTF("\nAlpha\n=====\n");
	ydb_mmrhash_128(alpha_str, SIZEOF(alpha_str), 0, &phashval_128);
	DEBUG_PRINTF("%-30s %016lX%016lX\n", "ydb_mmrhash_128:", phashval_128.one, phashval_128.two);
	assertpro((phashval_128.one == alpha_hash_expected.one) && (phashval_128.two == alpha_hash_expected.two));

	DEBUG_PRINTF("\nTime\n====\n");
	ydb_mmrhash_128(time_str, SIZEOF(time_str), 0, &phashval_128);
	DEBUG_PRINTF("%-30s %016lX%016lX\n", "ydb_mmrhash_128:", phashval_128.one, phashval_128.two);
	assertpro((phashval_128.one == time_hash_expected.one) && (phashval_128.two == time_hash_expected.two));
}

int null_printf(const char *format, ...)
{
	return 0;
}
