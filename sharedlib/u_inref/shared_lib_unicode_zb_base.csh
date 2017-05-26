#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2007, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_disable_randomdbtn 1
setenv gtm_test_mupip_set_version "disable"
set dir1 = "multi_ｂｙｔｅ_後漢書_byte"
mkdir $dir1
cd $dir1

$gtm_exe/mumps $gtm_tst/$tst/inref/{zbbasicexec.m,unizbdrive.m,unizbbasic.m}
$gtm_exe/mumps $gtm_tst/com/examine.m
$gt_ld_m_shl_linker ${gt_ld_option_output} zbshlib$gt_ld_shl_suffix unizbbasic.o zbbasicexec.o  unizbdrive.o  examine.o  ${gt_ld_m_shl_options} >& shared_lib_unicode_zb_base_ld.outx
#
#
$gtm_tst/com/dbcreate.csh mumps 1
\rm -f *.o                              # Remove object files to make sure they do not get used or interfere
#
$GTM << aaa
S \$zro="./zbshlib$gt_ld_shl_suffix ."
d ^unizbdrive
halt
aaa
\ls *.o >& /dev/null                                    # List any object files created
if ($status == 0) then
        \ls *.o
        echo "Object files created. TEST FAILED!"
endif

$gtm_tst/com/dbcheck.csh
cd ..

