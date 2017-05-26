#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
############################################################################################################
# This test is just to check whether dbcertify operates well on a db that is greater than 4G mark in size
# We will not add this subtest as a part of 64bittn kit regular
# this will be a manually started test
############################################################################################################
# Since the test needs a V4 version, and the minimum prior version for MM access method is V53002, force BG for this subtest
source $gtm_tst/com/gtm_test_setbgaccess.csh
setenv v4ver `$gtm_tst/com/random_ver.csh -type V4`
if ("$v4ver" =~ "*-E-*") then
	echo "There are no V4 versions. Exiting"
	exit 1
endif
setenv sv4 "source $gtm_tst/com/switch_gtm_version.csh $v4ver $tst_image"
setenv sv5 "source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image"
#
setenv DBCERTIFY "$gtm_exe/dbcertify"
#
echo "chosen V4 VERSION FOR this dbcertify run is "$v4ver
# we don't require these features here and so turning it off
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
# This test uses V4 versions in a lot of subtests. MM access method works well only from versions V5.3-002.
source $gtm_tst/com/gtm_test_setbgaccess.csh
$sv4
$gtm_tst/com/dbcreate.csh mumps 2
#
$MUPIP exten DEFAULT -block=4300000
$MUPIP extend AREG -block=4400000
# This just makes the DB a little above the 4G mark
# Note we don't need to fill the DB as such with 4G data, this kind of extensions ensures we have local block bit maps
# all the way down to 4G level and if dbcertify can read and proceed that's good enough to go
$DSE << EOF
change -file -reserved_bytes=8
find -reg=DEFAULT
change -file -reserved_bytes=8
exit
EOF
#
# perform dbcertify
foreach reg ("AREG" "DEFAULT")
	$DBCERTIFY scan $reg -outfile=$reg.scan
	if ( $status ) then
		echo "TEST-E-ERROR dbcertify scan phase failed for 4GB database $reg"
		exit 1
	endif
	echo "yes"|$DBCERTIFY certify $reg.scan >>&! dbcertify_$reg.out
        $grep "DBCDBCERTIFIED" dbcertify_$reg.out
	if ($status) then
                echo "TEST-E-ERROR certification phase failed for 4GB database $reg"
        endif

end
$gtm_tst/com/dbcheck.csh
# go back to the version being tested
$sv5
# end of test
