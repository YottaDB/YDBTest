#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
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
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 4
setenv gtm_white_box_test_case_count 1
setenv acc_meth "BG"   # wcs_recover does not run with BG
$gtm_tst/com/dbcreate.csh mumps
set syslog_time1 = `date +"%b %e %H:%M:%S"`
echo "# In DSE touch the database, spawn a GT.M process that creates a bunch of globals, using a bunch of blocks"
echo "# save, then damage a block, which should cause DBDANGER, then restore the correct block contents"
$DSE << DSE_EOF
map -free -block=10
spawn "$gtm_exe/mumps -run \%XCMD 'for i=65:1:90,97:1:122 set @\$char(94,i)=1'"
save -block=3
change -bsiz=100
restore
DSE_EOF
sleep 1           # Some separation so last msg out gets included
set syslog_time2 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" gtm6348.txt "" "YDB-W-DBDANGER"
$grep -c "YDB-W-DBDANGER" gtm6348.txt
$gtm_tst/com/dbcheck.csh
