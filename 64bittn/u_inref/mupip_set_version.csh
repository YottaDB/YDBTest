#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2005, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
 # switching to a random V4 version
$sv4
echo "GTM version is switched to $v4ver"
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -reser=8 -reg DEFAULT
$DBCERTIFY SCAN DEFAULT
echo "yes" | $DBCERTIFY CERTIFY mumps.dat.dbcertscan
echo "yes" | $MUPIPV5 upgrade mumps.dat

$sv5
echo "GTM version is switched to V6"
$GDE exit
$MUPIP set -version=V4 -region DEFAULT
$DSE dump -fileheader |&  $tst_awk '/Desired DB Format/ { print $5,$6,$7,$8}'	# should be V4
$MUPIP set -version=V6 -region DEFAULT
$DSE dump -fileheader |&  $tst_awk '/Desired DB Format/ { print $5,$6,$7,$8}'	# should be V6
$DSE change -fileheader -current_tn=F7FFFFFE #4G - 128M
$MUPIP set -version=V4 -region DEFAULT
$GTM << gtm_eof
set ^a="single update"
halt
gtm_eof
	# should issue TNTOOLARGE error

$MUPIP set -version=V6 -region DEFAULT
$GTM << gtm_eof
set ^b="Version is V6"
set ^c="Making Transactions to ensure curr_tn > 4G - 128M"
set ^d="Well, now switch to version V4"
halt
gtm_eof
$MUPIP set -version=V4 -region DEFAULT
#	--> it should issue MUDWNGRDTN error.
echo "MUPIP integ -tn_reset mumps.dat"
$MUPIP integ -tn_reset mumps.dat
echo "MUPIP set -version=V6"
$MUPIP set -version=V6 -region DEFAULT
echo "MUPIP reorg -downgrade"
$MUPIP reorg -downgrade -region DEFAULT
echo "yes" | $MUPIP downgrade mumps.dat
echo "MUPIP set -version=V4"
$MUPIP set -version=V4 -region DEFAULT
#	--> it should issue BADDBVER error.
echo "MUPIP set -version=V6"
$MUPIP set -version=V6 -region DEFAULT
#	--> it should issue BADDBVER error.
$gtm_tst/com/dbcheck.csh -noonline
$gtm_tst/com/backup_dbjnl.csh first_db

#3) Check that VERSION and EXTENSION_COUNT work together
echo ""
echo "Check that VERSION and EXTENSION_COUNT work together"
echo ""
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -version=V6 -extension_count=10 -region DEFAULT
$gtm_tst/com/dbcheck.csh -noonline
$gtm_tst/com/backup_dbjnl.csh step_3_db

#4) Test that CURR_TN <= WARN_MAX_TN <= MAX_TN inequality is maintained at all times by MUPIP SET when it plays with WARN_MAX_TN
echo ""
echo "Test that CURR_TN <= WARN_MAX_TN <= MAX_TN inequality is maintained"
echo ""
$gtm_tst/com/dbcreate.csh mumps 1
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"		# should be 0x0000000000000001(cur) 0xFFFFFFFFDFFFFFFF(max) 0xFFFFFFFF5FFFFFFF(warn)
$MUPIP set -version=V4 -reg "*"
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"		# should be 0x0000000000000002(cur) 0x00000000F7FFFFFF(max) 0x00000000D7FFFFFF(warn); Desired DB Format should be V4
$MUPIP set -version=V6 -reg "*"
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"		# should be 0x0000000000000003(cur) 0xFFFFFFFFDFFFFFFF(max) 0xFFFFFFFF5FFFFFFF(warn); Desired DB Format should be V6
$DSE change -fileheader -current_tn=EFFFFFFF
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"		# should be 0x00000000EFFFFFFF(cur) 0xFFFFFFFFDFFFFFFF(max) 0xFFFFFFFF5FFFFFFF(warn)
$MUPIP set -version=V4 -reg "*"
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"		# should be 0x00000000F0000000(cur) 0x00000000F7FFFFFF(max) 0x00000000F3FFFFFF(warn); Desired DB Format should be V4

$GTM << gtm_eof
set ^x=1
halt
gtm_eof

$DSE dump -fileheader |& $grep -E "Current|Maximum TN"		# should be 0x00000000F0000001(cur) 0x00000000F7FFFFFF(max) 0x00000000F3FFFFFF(warn); Desired DB Format should be V4
$MUPIP set -version=V6 -reg "*"
#
$DSE dump -fileheader |& $grep -E "Current|Maximum TN"		# should be 0x00000000F0000002(cur) 0xFFFFFFFFDFFFFFFF(max) 0xFFFFFFFF5FFFFFFF(warn); Desired DB Format should be V6
$gtm_tst/com/dbcheck.csh -noonline
