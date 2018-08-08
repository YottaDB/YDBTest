#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
cat > gtm8959.tab <<EOF
gtm8959: void ^gtm8959()
EOF

setenv GTMCI gtm8959.tab

cat > gtm8959ci.c << EOF
#include <string.h>
#include <limits.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"
int main()
{
	int status = gtm_ci("gtm8959");
	printf("# ZGOTO 0 returned to C program\n");
	return 0;
	}
EOF
# Compiling c program, creating executable
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_tst/$tst/inref -I$ydb_dist gtm8959ci.c
if ($status) then
	echo "# Compile failed"
endif
# -lgtmshr used instead of $tst_ld_yottadb to show that this test produces a sig11 in the previous version
$gt_ld_linker $gt_ld_option_output gtm8959ci $gt_ld_options_common gtm8959ci.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist -lgtmshr $gt_ld_syslibs >&! link2.map
if ($status) then
	echo "# Creation of Executable failed"
endif
echo "# Running a c program that will execute a call in with a ZGOTO 0, this would previously produce a SIG-11 error"
./gtm8959ci
if ($status) then
	echo "# Error encountered while running program"
else
	echo "# Status 0 returned from gtm8959ci"
endif
