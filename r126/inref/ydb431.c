/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include "libyottadb.h"

int main(){
	ydb_buffer_t localA, subs[5], retvalue, value;
	char errbuf[2048];
	int status, i;

	YDB_LITERAL_TO_BUFFER("a", &localA);
	for(i = 0; i < 4; i++){
		YDB_MALLOC_BUFFER(&subs[i], 8);
		subs[i].len_used = sprintf(subs[i].buf_addr, "sub%d", i);
		i++;
		YDB_MALLOC_BUFFER(&subs[i], 8);
		subs[i].len_used = sprintf(subs[i].buf_addr, "%d", i);
	}
	YDB_LITERAL_TO_BUFFER("This subscript is extra long so that we can go over the 512 byte size of the LVUNDEF buffer. Although as it turns out 512 characters, one byte being one ascii character, is really rather alot. The start of this string was at byte 25 of the line, and as of right now I am only at 230. I need to somehow reach at 537, and this is getting a little silly so here is the abc's: Aa Bb Cc Dd Ee Ff Gg Hh Ii Jj Kk Ll Mm Nn Oo Pp Qq Rr Ss Tt Uu Vv Ww Xx Yy Zz. Numbers: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25.", &subs[4]);
	YDB_LITERAL_TO_BUFFER("This is a value", &value);
	YDB_MALLOC_BUFFER(&retvalue, 1);

	printf("$get(a)\n");
	status = ydb_get_s(&localA, 0, NULL, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);


	printf("\n$get(a(\"sub0\")) $get(a(\"sub0\",1,\"sub2\",3))\n");
	status = ydb_get_s(&localA, 1, subs, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);

	status = ydb_get_s(&localA, 4, subs, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);


	printf("\nset a=\"This is a value\" kill a $get(a)\n");
	status = ydb_set_s(&localA, 0, NULL, &value);
	YDB_ASSERT(status == YDB_OK);
	status = ydb_delete_s(&localA, 0, NULL, YDB_DEL_TREE);
	YDB_ASSERT(status == YDB_OK);

	status = ydb_get_s(&localA, 0, NULL, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);


	printf("\nset a(\"sub0\")=\"This is a value\" kill a(\"sub0\") $get(a(\"sub0\")) $get(a(\"sub0\",1,\"sub2\",3))\n");
	status = ydb_set_s(&localA, 1, subs, &value);
	YDB_ASSERT(status == YDB_OK);
	status = ydb_delete_s(&localA, 1, subs, YDB_DEL_TREE);
	YDB_ASSERT(status == YDB_OK);

	status = ydb_get_s(&localA, 1, subs, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);

	status = ydb_get_s(&localA, 4, subs, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);


	printf("\nset a=\"This is a value\" kill (a) $get(a)\n");
	status = ydb_set_s(&localA, 0, NULL, &value);
	YDB_ASSERT(status == YDB_OK);

	status = ydb_delete_excl_s(0, NULL);
	YDB_ASSERT(status == YDB_OK);

	status = ydb_get_s(&localA, 0, NULL, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);


	printf("\nset a(\"sub0\")=\"This is a value\" kill (a(\"sub0\")) $get(a(\"sub0\")) $get(a(\"sub0\",1,\"sub2\",3))\n");
	status = ydb_set_s(&localA, 1, subs, &value);
	YDB_ASSERT(status == YDB_OK);

	status = ydb_delete_excl_s(0, NULL);
	YDB_ASSERT(status == YDB_OK);

	status = ydb_get_s(&localA, 1, subs, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);

	status = ydb_get_s(&localA, 4, subs, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);


	printf("\nset a(\"sub0\")=\"This is a value\" $get(a(\"sub0\",1))\n");
	status = ydb_set_s(&localA, 1, subs, &value);
	YDB_ASSERT(status == YDB_OK);

	status = ydb_get_s(&localA, 2, subs, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);


	printf("\nBuffer length test\n");
	printf("$get(a(\"sub0\",1,\"sub2\",3,\"This subscript is extra long so that we can go over the 512 byte size of the LVUNDEF buffer. Although as it turns out 512 characters, one byte being one ascii character, is really rather alot. The start of this string was at byte 25 of the line, and as of right now I am only at 230. I need to somehow reach at 537, and this is getting a little silly so here is the abc's: Aa Bb Cc Dd Ee Ff Gg Hh Ii Jj Kk Ll Mm Nn Oo Pp Qq Rr Ss Tt Uu Vv Ww Xx Yy Zz. Numbers: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25.\"))\n\n");
	status = ydb_get_s(&localA, 5, subs, &retvalue);
	YDB_ASSERT(status == YDB_ERR_LVUNDEF);
	ydb_zstatus(errbuf, sizeof(errbuf));
	printf("The $zstatus string is: %s\n", errbuf);

	return 0;
}
