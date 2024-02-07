/****************************************************************
 *
 * Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
 * All rights reserved.
 *
 *	This source code contains the intellectual property
 *	of its copyright holder(s), and is made available
 *	under a license.  If you do not know the terms of
 *	the license, please stop and do not read further.
 *
 ****************************************************************/

#include <stdio.h>
#include <string.h>
#include "gtmxc_types.h"

/* callOut function
 * sets str->length to 5 when only 1 byte is allocated
 * this should cause an expected EXCEEDSPREALLOC error
 */
int callOutStr(int count, gtm_string_t *str){

	str->length = 5;

	return 0;
}

/* callOut function
 * writes to str->address until a EXTCALLBOUNDS error occurs
 */
int callOutStr2(int count, gtm_string_t *str){

    int prealloc = 1; // the prealloc set in the callout table which is in gtm7952b.csh
	for(int i = 0; i < prealloc+1; i++)
		str->address[i] = 'z';
	str->length = 1;

	return 0;
}

/* callOut function
 * write 8 characters to *str when only 1 character is allocated
 * This should cause an expected EXCEEDSPREALLOC error
 * This test used to generate EXCEEDSPREALLOC, but since YDB!1479 creates EXTCALLBOUNDS and is essentially  the same
 * as callOutChar2() since char** no longer allocates any space for a returned string (which should be a C literal).
 * Nevertheless, the test is retained, to guard against regression.
 */
int callOutChar(int count, gtm_char_t **str){

	strcpy(*str, "a1a2a3a4");

	return 0;
}

/* callOut function
 * writes to *str until a EXTCALLBOUNDS error occurs
 */
int callOutChar2(int count, gtm_char_t **str){

    int prealloc = 0; // prealloc in the callout table should be ignored (i.e. 0) because char ** supposed to return literal
	for(int i = 0; i < prealloc+1; i++)
		(*str)[i] = '\0'; // use NUL to ensure it is terminated as YDB does a strlen() on it.

	return 0;
}
