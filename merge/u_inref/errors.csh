#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv test_reorg "NON_REORG"
setenv gtm_test_sprgde_exclude_reglist DEFAULT
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
echo "# section 1 : ^subslen"
source $gtm_tst/com/dbcreate.csh mumps 3 >&! dbcreate_case1.out
# Changing keysize on the remote host in case of GT.CM is not straight forward
# Also it would be good to see what error is issued if key size isn't reduced, which can be part of GT.CM runs
if ( "GT.CM" != "$test_gtm_gtcm") then
	$DSE << DSE_EOF >>& dse_keychange.out
	find -reg=DEFAULT
	change -file -key=40
DSE_EOF

endif

$GTM << xyz
d lcl^subslen
do gtm7867^subslen
halt
xyz
$gtm_tst/com/dbcheck.csh -extr
#
echo "# section 2 : ^errors"
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps 3 >&! dbcreate_case2.out
$gtm_exe/mumps -dir << xyz
d ^errors
halt
xyz

if ($?test_gtm_gtcm_one) then
	foreach x ($tst_gtcm_server_list)
	$rsh $x 'set chkhost=`uname -s`; if ("Linux" == $chkhost) netstat -pn ; echo "=======";echo netstat -an option; echo "======="; netstat -a' >& netstatinfo_$x
	end
endif
$gtm_tst/com/dbcheck.csh -extr
#
echo "# section 3 : ^activelv"
setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps 3 >&! dbcreate_case3.out
$gtm_exe/mumps -dir << xyz
d ^activelv
halt
xyz
$gtm_tst/com/dbcheck.csh -extr
