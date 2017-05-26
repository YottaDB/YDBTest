#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$switch_chset UTF-8
setenv test_reorg "NON_REORG"
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps 4 255 1000
$gtm_exe/mumps -dir << aaa
d ^mbyexam
h
aaa
if ($?test_gtm_gtcm_one) then
        foreach x ($tst_gtcm_server_list)
        $rsh $x 'set chkhost=`uname -s`; if ("Linux" == $chkhost) netstat -pn ; echo "=======";echo netstat -an option; echo "======="; netstat -a' >& netstatinfo_$x
        end
endif

$gtm_tst/com/dbcheck.csh -extr
#
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps 4 255 1000
$GTM < $gtm_tst/$tst/u_inref/ugbl2gbl.input
$gtm_tst/com/dbcheck.csh -extr
