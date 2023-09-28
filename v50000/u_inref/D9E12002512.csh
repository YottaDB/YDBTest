#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9E12-002512 DSE ADD -STAR gets SIGADRALN error
#
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in MUPIP INTEG and DSE DUMP output
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps 1 -block=512 -rec=480
$GTM << EOF
	d ^d002512
EOF
cp mumps.dat mumpsbak.dat
$DSE << DSE_EOF >>&! dse_addstr.log
	dump -block=4
	remove -rec=7
	add -star -pointer=3
	dump -block=4
	remove -rec=7
	remove -rec=6
	add -star -pointer=A
	dump -block=4
	remove -rec=6
	remove -rec=5
	add -star -pointer=9
	dump -block=4
	remove -rec=5
	remove -rec=4
	add -star -pointer=8
	dump -block=4
	remove -rec=4
	remove -rec=3
	add -star -pointer=7
	dump -block=4
	remove -rec=3
	remove -rec=2
	add -star -pointer=6
	dump -block=4
	remove -rec=2
	remove -rec=1
	add -star -pointer=5
	dump -block=4
	exit
DSE_EOF
$grep -v '|' dse_addstr.log
if ($HOSTOS == "OSF1") then
	echo ""
endif
echo "End of test"
$gtm_tst/com/dbcheck.csh
