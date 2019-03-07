/****************************************************************
 *								*
 * Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries. *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <libyottadb.h>
#include <gtmxc_types.h>

#define YDB_BUFFER_STR(s)  ((ydb_buffer_t[]){{ .buf_addr = s, .len_alloc = sizeof(s)-1, .len_used = sizeof(s)-1 }})

gtm_long_t func(int argc, gtm_string_t *t) {
  ydb_set_s(YDB_BUFFER_STR("result"), 0, NULL, YDB_BUFFER_STR("ok"));
  return 0;
}

