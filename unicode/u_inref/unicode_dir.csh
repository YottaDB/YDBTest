#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$switch_chset UTF-8
set save_gtmroutines="$gtmroutines"
setenv orig_dir `pwd`
setenv msrc_dir "αβγδε能吞"
\mkdir $msrc_dir
cd $msrc_dir
setenv msrc_dir `pwd`
\cp $gtm_tst/$tst/inref/unicodedir.m .
\cp $gtm_tst/com/udbfill.m .
\cp $gtm_tst/com/getunitemplate.m .
setenv uni_sub_dir "αβγＡＢＧ玻璃而傷"
\mkdir $uni_sub_dir
cd $uni_sub_dir
setenv uni_sub_dir `pwd`
#
setenv gtmgbldir "$uni_sub_dir/ＡＢＣＤ.ＥＦＧ"
$GDE << aaa
change -segment DEFAULT -file_name=$msrc_dir/ＡＢＣＤ.db
exit
aaa
if ("ENCRYPT" == "$test_encryption" ) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
	rm CONVDBKEYS.o
endif
$MUPIP create
#
#
setenv gtmroutines ".(. $gtm_exe $msrc_dir)"
ls -1 $msrc_dir/{*.o,*.m}
ls -lR $msrc_dir >lslR_1.txt
$GTM < $gtm_tst/$tst/u_inref/unicode_dir.input
ls -lR $msrc_dir >lslR_2.txt
#
#set echo
setenv gtmroutines "$uni_sub_dir"
echo "GTM_TEST_DEBUGINFOgtmroutines=$gtmroutines"
ls -1 {*.o,*.m} | $grep -v PINENTRY
$gtm_exe/mumps unicodedir.m
$gtm_exe/mumps -r unicodedir $msrc_dir
$gtm_exe/mumps -r unicodedir $uni_sub_dir
ls -lR $msrc_dir >lslR_3.txt
\rm *.o >>& rm_o.out
setenv gtmroutines "$msrc_dir"
echo "GTM_TEST_DEBUGINFOgtmroutines=$gtmroutines"
ls -1 $msrc_dir/{*.o,*.m}
$gtm_exe/mumps unicodedir.m
$gtm_exe/mumps -r unicodedir $msrc_dir
$gtm_exe/mumps -r unicodedir $uni_sub_dir
ls -lR $msrc_dir >lslR_4.txt
\rm *.o >>& rm_o.out
#
setenv gtmroutines "$orig_dir"
echo "GTM_TEST_DEBUGINFOgtmroutines=$gtmroutines"
ls -1 $orig_dir/{*.o,*.m}
$gtm_exe/mumps unicodedir.m
$gtm_exe/mumps -r unicodedir $msrc_dir
$gtm_exe/mumps -r unicodedir $uni_sub_dir
ls -lR $msrc_dir >lslR_5.txt
\rm *.o >>& rm_o.out
#
setenv gtmroutines "$save_gtmroutines"
echo "GTM_TEST_DEBUGINFOgtmroutines=$gtmroutines"
ls -1 $orig_dir/{*.o,*.m}
$gtm_exe/mumps $gtm_tst/$tst/inref/unicodedir.m
$gtm_exe/mumps -r unicodedir $msrc_dir
$gtm_exe/mumps -r unicodedir $uni_sub_dir
ls -lR $msrc_dir >lslR_6.txt
#unset echo
#
