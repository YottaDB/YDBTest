/****************************************************************
*
* Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
* All rights reserved.
*
* This source code contains the intellectual property
* of its copyright holder(s), and is made available
* under a license.  If you do not know the terms of
* the license, please stop and do not read further.
*
****************************************************************/
/* Test various return values from external call-outs
 * Note: basic.csh / make_fcn.csh already test the following retvals:
 *   void, gtm_long_t, gtm_ulong_t, gtm_status_t, gtm_int_t, gtm_uint_t
 */
#include <limits.h>
#include <inttypes.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"

#define STRING1 "Do not be so open-minded"
#define STRING2 "that your brains"
#define STRING3 "fall out."
#define STRING4 "- G. K. Chesterton"

#define PRINT(...) PRINTF(__VA_ARGS__); fflush(stdout);

// Test standard types

// Dummy function used merely for trying invalid types in the .xc file
void noop(int _nargs) { }

void set_return_numbers(int*ip, uint*uip, long*lp, ulong*ulp, int64_t*i64p, uint64_t*ui64p, float*fp, double*dp) {
	*ip = -2133333333;
	*uip = 4188888888;
	*lp = -2133333333;
	*ulp = 4188888888;
	*i64p = -9111111111111111111LL;
	*ui64p = 17777777777777777777ULL;
	*fp = 1222.33;
	*dp = 1.66666666666666E+46;
}

void inputs_tester(int _nargs,
	int i, int*ip, uint ui, uint*uip, long l, long*lp, ulong ul, ulong*ulp, int64_t*i64p, uint64_t*ui64p,
	float*fp, double*dp, char*cp, ydb_string_t*sp, ydb_buffer_t*bp, ydb_char_t**cpp) {

	// Written in separate lines so that the test output will show exactly which parameter is at fault if there is a segfault
	PRINT("    Got:  %i,", i);
	PRINT("%i,", *ip);
	PRINT("%u,%u,", ui, *uip);
	PRINT("%li,%li,", l, *lp);
	PRINT("%lu,%lu,", ul, *ulp);
	PRINT("%" PRIi64 ",%" PRIu64 ",", *i64p, *ui64p);
	PRINT("%.2f,%.14e,", *fp, *dp);
	PRINT("%s,", cp);
	PRINT("%.*s,", (int)sp->length, sp->address);
	PRINT("%.*s,", (int)bp->len_used, bp->buf_addr);
	PRINT("%s\n", *cpp);
}

void outputs_tester(int _nargs,
	int*ip, uint*uip, long*lp, ulong*ulp, int64_t*i64p, uint64_t*ui64p,
	float*fp, double*dp, char*cp, ydb_string_t*sp, ydb_buffer_t*bp, char**cpp) {

	// Written in separate lines so that the test output will show exactly which parameter is at fault if there is a segfault
	PRINT("    Got:  %i,", *ip);
	PRINT("%u,", *uip);
	PRINT("%li,", *lp);
	PRINT("%lu,", *ulp);
	PRINT("%" PRIi64 ",", *i64p);
	PRINT("%" PRIu64 ",", *ui64p);
	PRINT("%.2f,", *fp);
	PRINT("%.14e,", *dp);
	PRINT("%s,", cp);
	PRINT("%.*s,", (int)sp->length, sp->address);
	PRINT("%.*s,", (int)bp->len_used, bp->buf_addr);
	PRINT("%s\n", *cpp);

	set_return_numbers(ip, uip, lp, ulp, i64p, ui64p, fp, dp);
	strcpy(cp, STRING1);
	sp->length = strlen(STRING2); strncpy(sp->address,  STRING2, sp->length);
	bp->len_used = strlen(STRING3); strncpy(bp->buf_addr, STRING3, bp->len_used);
	strcpy(*cpp, STRING4);

	PRINT("  Return: %i,%u,%li,%lu,%" PRIi64 ",%" PRIu64 ",%.2f,%.14e,%s,%.*s,%.*s,%s\n",
		*ip, *uip, *lp, *ulp, *i64p, *ui64p, *fp, *dp, cp, (int)sp->length, sp->address, (int)bp->len_used, bp->buf_addr, *cpp);
}

void io_tester(int _nargs,
	int*ip, uint*uip, long*lp, ulong*ulp, int64_t*i64p, uint64_t*ui64p,
	float*fp, double*dp, char*cp, ydb_string_t*sp, ydb_buffer_t*bp, char**cpp) {

	// Written in separate lines so that the test output will show exactly which parameter is at fault if there is a segfault
	PRINT("    Got:  %i,", *ip);
	PRINT("%u,", *uip);
	PRINT("%li,", *lp);
	PRINT("%lu,", *ulp);
	PRINT("%" PRIi64 ",", *i64p);
	PRINT("%" PRIu64 ",", *ui64p);
	PRINT("%.2f,", *fp);
	PRINT("%.14e,", *dp);
	PRINT("%s,", cp);
	PRINT("%.*s,", (int)sp->length, sp->address);
	PRINT("%.*s,", (int)bp->len_used, bp->buf_addr);
	PRINT("%s\n", *cpp);

	set_return_numbers(ip, uip, lp, ulp, i64p, ui64p, fp, dp);
	// output strings -- but can only output up to the length of the input string as pre-allocation is not allowed with IO
	strncpy(cp, STRING1, strlen(cp));
	sp->length = stpncpy(sp->address,  STRING2, sp->length) - sp->address;
	bp->len_used = stpncpy(bp->buf_addr, STRING3, bp->len_used) - bp->buf_addr;
	*stpncpy(*cpp, STRING4, strlen(*cpp)) = '\0';

	PRINT("  Return: %i,%u,%li,%lu,%" PRIi64 ",%" PRIu64 ",%.2f,%.14e,%s,%.*s,%.*s,%s\n",
		*ip, *uip, *lp, *ulp, *i64p, *ui64p, *fp, *dp, cp, (int)sp->length, sp->address, (int)bp->len_used, bp->buf_addr, *cpp);
}

void inputs64_tester(int _nargs, int64_t i64, uint64_t ui64) {
	PRINT("    Got:  %" PRIi64 ",", i64);
	PRINT("%" PRIu64 "\n", ui64);
}
