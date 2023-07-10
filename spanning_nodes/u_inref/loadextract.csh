#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Can we extract an example database, and reload using different formats (zwr,go,bin)?
# 'go' format is not supported in UTF-8 mode
# Since the intent of the subtest is to explicitly check extract in zwr, go, and binary format, it is forced to run in M mode

# Since the reference file for this test has "SUSPEND_OUTPUT 4G_ABOVE_DB_BLKS" usage, it needs to fixate
# the value of the "ydb_test_4g_db_blks" env var in case it is randomly set by the test framework to a non-zero value.
if (0 != $ydb_test_4g_db_blks) then
	echo "# Setting ydb_test_4g_db_blks env var to a fixed value as reference file has 4G_ABOVE_DB_BLKS usages" >> settings.csh
	setenv ydb_test_4g_db_blks 8388608
endif

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

source $gtm_tst/com/set_limits.csh
$switch_chset M >&! switch_chset.out
$gtm_tst/com/dbcreate.csh "mumps" 1 125 10000
$GTM << xyz
set spnblk=\$j("end",9000)
for i=1:5:2000  s ^var("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i)=i_spnblk
for i=851:5:926  K ^var("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i)
h
xyz
$gtm_exe/mumps -run %XCMD 'zwrite ^var' > compare.txt
$gtm_tst/com/dbcheck.csh -extr
$MUPIP integ -r "*"
echo "### -format=zwr ###"
$MUPIP extract -override extr3.zwr
$gtm_exe/mumps -run %XCMD 'kill ^var'
$MUPIP load extr3.zwr
$gtm_exe/mumps -run %XCMD 'zwrite ^var' > zwrcmp.txt
diff compare.txt zwrcmp.txt
echo "### -format=go ###"
$MUPIP extract -override -format=go extr3.go
$gtm_exe/mumps -run %XCMD 'kill ^var'
$MUPIP load -format=go extr3.go
$gtm_exe/mumps -run %XCMD 'zwrite ^var' > gocmp.txt
diff compare.txt gocmp.txt
echo "### -format=bin ###"
$MUPIP extract -override extr3.bin -format=bin
$gtm_exe/mumps -run %XCMD 'kill ^var'
$MUPIP load -format=bin extr3.bin
$gtm_exe/mumps -run %XCMD 'zwrite ^var' > bincmp.txt
diff compare.txt bincmp.txt

mkdir set1
mv mumps.* set1/
mv extr* set1/
mv compare.txt set1/
mv zwrcmp.txt set1/
mv gocmp.txt set1/
mv bincmp.txt set1/

# 1048576 is the maximum record size we can specify
$GDE <<EOF
change -segment DEFAULT -block_size=512 -global_buffer_count=9000 -file=mumps.dat
change -region DEFAULT -null_subscripts=always -stdnull -rec=$MAX_RECORD_SIZE
EOF
$MUPIP create
$gtm_exe/mumps -run %XCMD "do ^load($MAX_RECORD_SIZE)"
$gtm_exe/mumps -run %XCMD 'zwrite ^a' > compare.txt
$MUPIP extract -override extr.zwr
$gtm_exe/mumps -run %XCMD 'kill ^a'
$MUPIP load extr.zwr
$gtm_exe/mumps -run %XCMD 'zwrite ^a' > zwrcmp.txt
diff compare.txt zwrcmp.txt
$MUPIP extract -override -format=go extr.go
$gtm_exe/mumps -run %XCMD 'kill ^a'
$MUPIP load -format=go extr.go
$gtm_exe/mumps -run %XCMD 'zwrite ^a' > gocmp.txt
diff compare.txt gocmp.txt
$MUPIP extract -override extr.bin -format=bin
$gtm_exe/mumps -run %XCMD 'zwrite ^a' > bincmp.txt
diff compare.txt bincmp.txt
