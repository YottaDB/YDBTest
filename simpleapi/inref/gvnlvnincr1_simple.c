/****************************************************************
 *								*
 * Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "libyottadb.h"

#include <stdio.h>
#include <string.h>
#include <stdio.h>

#define ERRBUF_SIZE 	1024

#define SUBSCR		"1"

#define INCR3		"3"
#define INCRM1		"-1"
#define INCRM4		"-4"
#define INCR2ABC	"2ABC"
#define INCRM2ABC	"-2ABC"
#define INCRPURE	"ABCD"
#define VALUE6ABC	"6ABC"
#define VALUEM6ABC	"-6ABC"
#define VALUEPURE	"EFGH"

int main(int argc, char** argv)
{
	int		status, copy_done;
	ydb_buffer_t 	ret_value, subscr, basevar, incr3, incrm1, incrm4, incr2abc, incrm2abc, incrpure;
	ydb_buffer_t 	value6abc, valuem6abc, valuepure;
	char		retvaluebuff[64], basevarbuff[64], errbuf[ERRBUF_SIZE];

	printf("### Test data return in ydb_incr_s() of %s Variables ###\n", argv[1]); fflush(stdout);

	YDB_LITERAL_TO_BUFFER(SUBSCR, &subscr);
	YDB_LITERAL_TO_BUFFER(INCR3, &incr3);
	YDB_LITERAL_TO_BUFFER(INCRM1, &incrm1);
	YDB_LITERAL_TO_BUFFER(INCRM4, &incrm4);
	YDB_LITERAL_TO_BUFFER(INCR2ABC, &incr2abc);
	YDB_LITERAL_TO_BUFFER(INCRM2ABC, &incrm2abc);
	YDB_LITERAL_TO_BUFFER(INCRPURE, &incrpure);
	YDB_LITERAL_TO_BUFFER(VALUE6ABC, &value6abc);
	YDB_LITERAL_TO_BUFFER(VALUEM6ABC, &valuem6abc);
	YDB_LITERAL_TO_BUFFER(VALUEPURE, &valuepure);


	basevar.buf_addr = &basevarbuff[0];
	basevar.len_used = 0;
	basevar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &basevar, copy_done);
	YDB_ASSERT(copy_done);
	basevar.buf_addr[basevar.len_used] = '\0';


	ret_value.buf_addr = &retvaluebuff[0];
	ret_value.len_used = 0;
	ret_value.len_alloc = 64;


	printf("\n# Test ydb_incr_s() on %s, which is not initially set.\n", basevar.buf_addr);
	printf("# Check to make sure %s is not set\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# ydb_incr_s() will set the value of %s to 0, and then perform the increment.\n", basevar.buf_addr); fflush(stdout);
	printf("# *increment is set to NULL, which defaults to 1\n"); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Get %s to confirm the value has incremented.\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 1)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "1", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}

	printf("\n# Test ydb_incr_s() with *increment set to %s\n", incr3.buf_addr); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, &incr3, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Get %s to confirm the value has incremented.\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 1)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "4", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}

	printf("\n# Test ydb_incr_s() with *increment set to %s\n", incrm1.buf_addr); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, &incrm1, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Get %s to confirm the value has decremented.\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 1)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "3", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}

	printf("\n# Test ydb_incr_s() with *increment set to %s in order to decrement to a negative value\n", incrm4.buf_addr); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, &incrm4, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Get %s to confirm the value has decremented.\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 2)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "-1", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}
	printf("\n# Set the value of %s to %s\n", basevar.buf_addr, valuepure.buf_addr);
	status = ydb_set_s(&basevar, 0, NULL, &valuepure);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Test ydb_incr_s() when the value of %s is %s, which should be treated as 0, incrementing by 1\n", basevar.buf_addr, valuepure.buf_addr); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Get %s to confirm the value has incremented\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 1)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "1", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}
	printf("\n# Test ydb_incr_s() with *increment set to %s, which should be treated as 0\n", incrpure.buf_addr); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, &incrpure, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Get %s to confirm the value has not incremented.\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 1)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "1", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}
	printf("\n# Set the value of %s to %s\n", basevar.buf_addr, value6abc.buf_addr);
	status = ydb_set_s(&basevar, 0, NULL, &value6abc);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Test ydb_incr_s() when the value of %s is %s, and *increment is set to %s\n", basevar.buf_addr, value6abc.buf_addr, incr2abc.buf_addr); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, &incr2abc, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	printf("# Get %s to confirm the value has incremented.\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 1)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "8", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}
	printf("\n# Set the value of %s to %s\n", basevar.buf_addr, value6abc.buf_addr);
	status = ydb_set_s(&basevar, 0, NULL, &value6abc);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Test ydb_incr_s() when the value of %s is %s, and *increment set to %s\n", basevar.buf_addr, value6abc.buf_addr, incrm2abc.buf_addr); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, &incrm2abc, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Get %s to confirm the value has decremented.\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 1)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "4", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}

	printf("\n# Set the value of %s to %s\n", basevar.buf_addr, valuem6abc.buf_addr);
	status = ydb_set_s(&basevar, 0, NULL, &valuem6abc);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Test ydb_incr_s() when the value of %s is %s, and *increment set to %s\n", basevar.buf_addr, valuem6abc.buf_addr, incr2abc.buf_addr); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, &incr2abc, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Get %s to confirm the value has incremented.\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 2)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "-4", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}

	printf("\n# Set the value of %s to %s\n", basevar.buf_addr, valuem6abc.buf_addr);
	status = ydb_set_s(&basevar, 0, NULL, &valuem6abc);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Test ydb_incr_s() when the value of %s is %s, and *increment set to %s\n", basevar.buf_addr, valuem6abc.buf_addr, incrm2abc.buf_addr); fflush(stdout);
	status = ydb_incr_s(&basevar, 0, NULL, &incrm2abc, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_incr_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Get %s to confirm the value has decremented.\n", basevar.buf_addr); fflush(stdout);
	status = ydb_get_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_get_s[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	if (ret_value.len_used != 2)
	{
		printf("ydb_incr_s() resulted in an incorrect response\n");
		fflush(stdout);
	} else
	{
		ret_value.buf_addr[ret_value.len_used] = '\0';
		if (memcmp(ret_value.buf_addr, "-8", ret_value.len_used) == 0)
		{
			printf("ydb_get_s() returns %s\n", ret_value.buf_addr);
			fflush(stdout);
		}
	}
	return YDB_OK;
}
