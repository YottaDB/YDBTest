#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test of DB access with KILL

# This test cannot run in UTF8 mode as it plays with a lot of $CHARs
$switch_chset "M" >& switch_chset.log

setenv gtmgbldir "mumps.gld"

$gtm_tst/$tst/u_inref/gtcm_start.csh >& gtcm_start.log
if ($status) then
	echo "TEST-E-GTCM_START gtcm_start.csh failed. Please check gtcm_start.log."
	echo "Test cannot continue and will exit..."
	exit 1
endif
if ($?gtcm_server_host == 0) setenv gtcm_server_host 127.0.0.1
if ($?gtcm_server_gbldir == 0) setenv gtcm_server_gbldir "$tst_working_dir/mumps.gld"

$gtm_tst/com/dbcreate.csh mumps 1 1019 1500 2048

setenv gtmgbldir $tst_working_dir/mumps.gld
$GTM << GTM_EOF
	do ^drive
GTM_EOF

echo "drive complete"
$gtm_tst/com/rundown.sh
setenv gtmgbldir "mumps.gld"
$gtm_tst/$tst/u_inref/gtcm_stop.csh >& gtcm_stop.log
$gtm_tst/com/dbcheck.csh
$grep -l FAIL volkill.mjo*
cat volkill.mje*
