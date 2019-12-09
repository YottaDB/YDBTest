/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.      *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "libyottadb.h"
#include "mmrhash.h"

/* This program calls ydb_mmrhash_128 on several strings to determine their hashes.
 * It is run in conjunction with an equivalent M program that tests $ZHASH to ensure
 * equivalent output.
 */

int main()
{
	ydb_uint16		out;
	uint4			salt;
	int			len, status, randSalt;
	unsigned char		buffer[32];
	ydb_string_t		randStr, zHash;
	ci_name_descriptor	callin1, callin2, callin3, callin4;

	ydb_init();
	printf("Testing ydb_mmrhash_128 from C code\n");
	salt = 0;
	len = 4;
	ydb_mmrhash_128("test", len, salt, &out);
	ydb_mmrhash_128_hex(&out, buffer);
	printf("The hash of \"test\" with a salt of 0 is: ");
	for (int i = 0; i < 32; i++)
	{
		printf("%c", buffer[i]);
	}
	printf("\n");
	salt = 5;
	ydb_mmrhash_128("test", len, salt, &out);
	ydb_mmrhash_128_hex(&out, buffer);
	printf("The hash of \"test\" with a salt of 5 is: ");
	for (int i = 0; i < 32; i++)
	{
		printf("%c", buffer[i]);
	}
	printf("\n");
	salt = 0;
	ydb_mmrhash_128("test", len, salt, &out);
	ydb_mmrhash_128_hex(&out, buffer);
	printf("The hash of \"test\" with a salt of 0 is: ");
	for (int i = 0; i < 32; i++)
	{
		printf("%c", buffer[i]);
	}
	printf("\n");
	len = 7;
	ydb_mmrhash_128("YottaDB", len, salt, &out);
	ydb_mmrhash_128_hex(&out, buffer);
	printf("The hash of \"YottaDB\" with a salt of 0 is: ");
	for (int i = 0; i < 32; i++)
	{
		printf("%c", buffer[i]);
	}
	printf("\n");
	len = 44;
	salt = 63008;
	ydb_mmrhash_128("This test was added in YottaDB version R1.30", len, salt, &out);
	ydb_mmrhash_128_hex(&out, buffer);
	printf("The hash of \"This test was added in YottaDB version R1.30\" with a salt of 63008 is: ");
	for (int i = 0; i < 32; i++)
	{
		printf("%c", buffer[i]);
	}
	printf("\n");
	len = 158;
	salt = 6441898;
	ydb_mmrhash_128("YottaDB is a new kind of database company, delivering a proven database engine to your application, enhancing simplicity, security, stability and scalability.", len, salt, &out);
	printf("The hash of \"YottaDB is a new kind of database company, delivering a proven database engine to your application, enhancing simplicity, security, stability and scalability.\" with a salt of 6441898 is: ");
	for (int i = 0; i < 32; i++)
	{
		printf("%c", buffer[i]);
	}
	printf("\n");
	len = 137;
	salt = 1610;
	ydb_mmrhash_128("YottaDB compiles XECUTE <literal> at compile time when the literal is valid YottaDB code that has minimal impact on the M virtual machine", len, salt, &out);
	printf("The hash of \"YottaDB compiles XECUTE <literal> at compile time when the literal is valid YottaDB code that has minimal impact on the M virtual machine\" with a salt of 1610 is: ");
	for (int i = 0; i < 32; i++)
	{
		printf("%c", buffer[i]);
	}
	printf("\n");
	printf("Finished test of hardcoded calls to ydb_mmrhash_128 from C code\n");
	printf("Starting test of random calls to ydb_mmrhash_128 from C code\n");
	callin1.rtn_name.address = "str";
	callin1.rtn_name.length = 3;
	callin1.handle = NULL;
	callin2.rtn_name.address = "slt";
	callin2.rtn_name.length = 3;
	callin2.handle = NULL;
	callin3.rtn_name.address = "hash";
	callin3.rtn_name.length = 4;
	callin3.handle = NULL;
	randStr.address = (char *)(malloc(YDB_MAX_STR));
	zHash.address = (char *)(malloc(32));
	zHash.length = 32;
	for (int i = 0; i < 1000; i++)
	{
		randStr.length = YDB_MAX_STR;
		status = ydb_cip(&callin1, &randStr);
		if (YDB_OK != status)
		{
			printf("Call-in to get random string failed on iteration %d\n", i);
			printf("FAIL: ydb_cip() did not return the correct status. Got: %d; Expected: %d\n", status, YDB_OK);
			break;
		}

		status = ydb_cip(&callin2, &randSalt);
		if (YDB_OK != status)
		{
			printf("Call-in to get random salt failed on iteration %d\n", i);
			printf("FAIL: ydb_cip() did not return the correct status. Got: %d; Expected: %d\n", status, YDB_OK);
			break;
		}
		ydb_mmrhash_128(randStr.address, randStr.length, randSalt, &out);
		ydb_mmrhash_128_hex(&out, buffer);
		status = ydb_cip(&callin3, &zHash, &randStr, &randSalt);
		if (YDB_OK != status)
		{
			printf("Call-in to get zhash of random string and random salt failed on iteration %d\n", i);
			printf("FAIL: ydb_cip() did not return the correct status. Got: %d; Expected: %d\n", status, YDB_OK);
			break;
		}
		if (!strcmp(buffer, zHash.address))
		{
			printf("FAIL: ydb_mmrhash_128 and $ZHASH returned different hashes on the same input string and salt.\n");
			printf("The input string was \"");
			for (int i = 0; i < 32; i++)
			{
				printf("%c", randStr.address[i]);
			}
			printf("\".\n");
			printf("The hash produced by ydb_mmrhash_128 was: ");
			for (int i = 0; i < 32; i++)
			{
				printf("%c", buffer[i]);
			}
			printf("\nThe hash prodcuted by $ZHASH was: ");
			for (int i = 0; i < 32; i++)
			{
				printf("%c", zHash.address[i]);
			}
			printf("\n");
		}
	}
	free(randStr.address);
	free(zHash.address);
	printf("Finished test of random calls to ydb_mmrhash_128 from C code\n");
	printf("Will now test an invalid string length. This should return an error.\n");
	randStr.address = (char *)(malloc(YDB_MAX_STR + 1));
	callin4.rtn_name.address = "toolong";
	callin4.rtn_name.length = 7;
	callin4.handle = NULL;
	status = ydb_cip(&callin4, &randStr);
	if (abs(YDB_ERR_MAXSTRLEN) == abs(status))
		printf("ydb_cip() returned YDB_ERR_MAXSTRLEN with status code %d\n", abs(status));
	else
		printf("FAIL: ydb_cip() did not return the correct status. Got: %d; Expected: %d\n", abs(status), abs(YDB_ERR_MAXSTRLEN));
}
