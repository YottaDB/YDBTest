/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.*
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
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>

#define ERRBUF_SIZE	1024

#define NODE1		"1"
#define NODE2		"2"
#define NODE3		"3"
#define VALUE		"test"

int main(int argc, char** argv)
{
	int		i, status, sub, copy_done, node_check, seed;
	ydb_buffer_t	basevar, node1, node2[2], node3, value, badbasevar, ret_value1, ret_value2[2], ret_value3;
	char		errbuf[ERRBUF_SIZE], basevarbuff[64], retvaluebuff1[64], retvaluebuff2[2][64], retvaluebuff3[64];

	printf("### Test simple ydb_node_previous_st() of %s Variables ###\n", argv[1]); fflush(stdout);
	basevar.buf_addr = &basevarbuff[0];
	basevar.len_used = 0;
	basevar.len_alloc = 64;
	YDB_COPY_STRING_TO_BUFFER(argv[2], &basevar, copy_done);
	YDB_ASSERT(copy_done);
	basevar.buf_addr[basevar.len_used]='\0';
	YDB_LITERAL_TO_BUFFER(NODE1, &node1);
	YDB_LITERAL_TO_BUFFER(NODE1, &node2[0]);
	YDB_LITERAL_TO_BUFFER(NODE2, &node2[1]);
	YDB_LITERAL_TO_BUFFER(NODE3, &node3);
	YDB_LITERAL_TO_BUFFER(VALUE, &value);

	ret_value1.buf_addr = retvaluebuff1;
	ret_value1.len_alloc = sizeof(retvaluebuff1);
	ret_value1.len_used = 0;
	for ( i = 0; i < 2; i++ )
	{
		ret_value2[i].buf_addr = retvaluebuff2[i];
		ret_value2[i].len_alloc = sizeof(retvaluebuff2[i]);
		ret_value2[i].len_used = 0;
	}
	ret_value3.buf_addr = retvaluebuff3;
	ret_value3.len_alloc = sizeof(retvaluebuff3);
	ret_value3.len_used = 0;

	seed = (time(NULL) * getpid());
	srand48(seed);

	sub = node_check = (64 * drand48());

	printf("# Initialize call-in environment\n"); fflush(stdout);
	status = ydb_init();
	if (0 != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_init: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Set a %s variable with 0 subscripts\n", argv[1]); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP,NULL,&basevar,0,NULL,&value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Get the previous node of %s variable with 0 subscripts\n", argv[1]); fflush(stdout);
	printf("Starting at %s()\n", basevar.buf_addr); fflush(stdout);
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,0,NULL,&sub,&ret_value1);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != node_check)
	{
		printf("ydb_node_previous_st(): *ret_subs_used was altered: %d\n", sub);
		fflush(stdout);
	} else
	{
		printf("ydb_node_previous_st() returned NODE_ERR_NODEEND\n");
		fflush(stdout);
	}
	printf("# Set a %s variable with 1 subscript\n", argv[1]); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP,NULL,&basevar,1,&node1,&value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Get the previous node of %s variable with 1 subscript\n", argv[1]); fflush(stdout);
	printf("Starting at %s(%s)\n", basevar.buf_addr, node1.buf_addr); fflush(stdout);
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,1,&node1,&sub,&ret_value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != 0)
	{
		printf("ydb_node_previous_st(): returned the wrong amount of subscripts: %d\n", sub);
		fflush(stdout);
	} else
	{
		printf("Call 1: ydb_node_previous_st() returned %s()\n", basevar.buf_addr); fflush(stdout);
	}
	sub = node_check = (64 * drand48());
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,0,NULL,&sub,&ret_value1);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != node_check)
	{
		printf("ydb_node_previous_st(): *ret_subs_used was altered: %d\n", sub);
		fflush(stdout);
	} else
	{
		printf("ydb_node_previous_st() returned NODE_ERR_NODEEND\n");
		fflush(stdout);
	}
	sub = 1;
	printf("# Set a %s variable with a 2-depth index\n", argv[1]); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP,NULL,&basevar,2,node2,&value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Get the first node of %s variable using two calls to ydb_node_previous_st()\n", argv[1]); fflush(stdout);
	printf("Starting at %s(%s,%s)\n", basevar.buf_addr, node2[0].buf_addr, node2[1].buf_addr); fflush(stdout);
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,2,node2,&sub,ret_value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_next_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != 1)
	{
		printf("ydb_node_previous_st(): returned the wrong amount of subscripts: %d\n", sub);
		fflush(stdout);
	} else
	{
		ret_value2[0].buf_addr[ret_value2[0].len_used] = '\0';
		printf("Call 1: ydb_node_previous_st() returned %s(%s)\n", basevar.buf_addr, ret_value2[0].buf_addr); fflush(stdout);
	}
	sub = 1;
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,1,ret_value2,&sub,&ret_value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_next_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != 0)
	{
		printf("ydb_node_previous_st(): returned the wrong amount of subscripts: %d\n", sub);
		fflush(stdout);
	} else
	{
		printf("Call 2: ydb_node_next_st() returned %s()\n", basevar.buf_addr); fflush(stdout);
	}
	sub = node_check = (64 * drand48());
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,0,NULL,&sub,&ret_value2[0]);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != node_check)
	{
		printf("ydb_node_previous_st(): *ret_subs_used was altered: %d\n", sub);
		fflush(stdout);
	} else
	{
		printf("ydb_node_previous_st() returned NODE_ERR_NODEEND\n");
		fflush(stdout);
	}
	printf("# Set another %s variable with another 1-depth index\n", argv[1]); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP,NULL,&basevar,1,&node3,&value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	sub = 2;
	printf("# Get the first node of %s variable with 3 calls to ydb_node_previous_st()\n", argv[1]); fflush(stdout);
	printf("Starting at %s(%s)\n", basevar.buf_addr, node3.buf_addr); fflush(stdout);
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,1,&node3,&sub,ret_value2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != 2)
	{
		printf("ydb_node_previous_st(): returned the wrong amount of subscripts: %d\n", sub);
		fflush(stdout);
	} else
	{
		ret_value2[0].buf_addr[ret_value2[0].len_used] = '\0'; ret_value2[1].buf_addr[ret_value2[1].len_used] = '\0';
		printf("Call 1: ydb_node_previous_st() returned %s(%s, %s)\n", basevar.buf_addr, ret_value2[0].buf_addr, ret_value2[1].buf_addr);
		fflush(stdout);
	}
	sub = 1;
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,2,ret_value2,&sub,&ret_value1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != 1)
	{
		printf("ydb_node_previous_st(): returned the wrong amount of subscripts: %d\n", sub);
		fflush(stdout);
	} else
	{
		ret_value1.buf_addr[ret_value1.len_used] = '\0';
		printf("Call 2: ydb_node_previous_st() returned %s(%s)\n", basevar.buf_addr, ret_value1.buf_addr);
		fflush(stdout);
	}
	sub = 0;
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,1,&ret_value1,&sub,&ret_value3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != 0)
	{
		printf("ydb_node_previous_st(): returned the wrong amount of subscripts: %d\n", sub);
		fflush(stdout);
	} else
	{
		ret_value3.buf_addr[ret_value3.len_used] = '\0';
		printf("Call 3: ydb_node_previous_st() returned %s()\n", basevar.buf_addr);
		fflush(stdout);
	}
	sub = node_check = (64 * drand48());
	status = ydb_node_previous_st(YDB_NOTTP,NULL,&basevar,0,NULL,&sub,&ret_value2[0]);
	if (YDB_ERR_NODEEND != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_st(): %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	} else if (sub != node_check)
	{
		printf("ydb_node_previous_st(): *ret_subs_used was altered: %d\n", sub);
		fflush(stdout);
	} else
	{
		printf("ydb_node_previous_st() returned NODE_ERR_NODEEND\n");
		fflush(stdout);
	}
	return YDB_OK;
}
