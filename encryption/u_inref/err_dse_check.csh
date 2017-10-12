#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This subtest tests dse behavior with two database files, one of whose keys is missing.

setenv save_gtm_passwd $gtm_passwd
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps 2
echo "----------------------------------------------------------"
echo "dump file header without gtm_paswd and expect to work"
echo "----------------------------------------------------------"
unsetenv gtm_passwd
$DSE dump -file
setenv gtm_passwd $save_gtm_passwd
echo "----------------------------------------------------------"
echo "Rename a_dat_key as a_key"
echo "----------------------------------------------------------"
mv a_dat_key a_key
$DSE << EOF
dump -bl=0
dump -bl=1
find -reg=DEFAULT
dump -bl=0
dump -bl=1
exit
EOF
echo
mv a_key a_dat_key
$gtm_tst/com/dbcheck.csh
