#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# D9E12-002513 - test that ZHELP doesn't cause a GTMASSERT when M profiling is on
#
# disable implicit mprof testing to avoid interference with explicit mprof testing
unsetenv gtm_trace_gbl_name
echo Starting D9E12002513
$gtm_tst/com/dbcreate.csh mumps 1 255 16368 16384
echo ZHELP in the middle
$GTM > middle_zhelp.out <<EOF
view "trace":1:"^t"
write #,\$\$FUNC^%DH(123456789),#
zhelp "About_GTM"


write #,\$\$FUNC^%DH(123456789),#
EOF
echo ZHELP first
$GTM > first_zhelp.out <<EOF
view "trace":1:"^t"
zhelp "About_GTM"


write #,\$\$FUNC^%DH(123456789),#
EOF
$gtm_tst/com/dbcheck.csh -extract mumps
echo Ending D9E12002513
