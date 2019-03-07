#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
cat > gtm8943.tab <<EOF
gtm8943: void ^gtm8943()
EOF

setenv GTMCI gtm8943.tab

cat > gtm8943ci.c << EOF
#include <string.h>
#include <limits.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"
int main()
{
	int status = gtm_ci("gtm8943");
	printf("ZGOTO 0 Returned to C Program\n");
	return 0;
	}
EOF
# Compiling c program, creating executable
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_tst/$tst/inref -I$ydb_dist gtm8943ci.c
if ($status) then
	echo "# Compile failed"
endif
# -lgtmshr used instead of $tst_ld_yottadb to show that this test produces a sig11 in the previous version
$gt_ld_linker $gt_ld_option_output gtm8943ci $gt_ld_options_common gtm8943ci.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist -lgtmshr $gt_ld_syslibs >&! link2.map
if ($status) then
	echo "# Creation of Executable failed"
endif
echo "# Running a c program that will execute a call in (without calling gtm_init()) with a ZGOTO 0, this would previously produce a SIG-11 error"
./gtm8943ci
if ($status) then
	echo "# Error encountered while running program"
else
	echo "No Sig-11 error"
endif

echo "# Running same M program directly from shell script, ZGOTO 0 should terminate the process"
$ydb_dist/mumps -run gtm8943
