#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2004, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_exe/mumps $gtm_tst/$tst/inref/{zbbasic.m,zbbasicexec.m,errcont.m,lfill.m,zbdrive.m,zblab1.m,zblab2.m,zblab3.m,zblab4.m,zbmain.m}
$gtm_exe/mumps $gtm_tst/com/lotsvar.m
$gtm_exe/mumps $gtm_tst/com/examine.m
$gt_ld_m_shl_linker ${gt_ld_option_output} zbshlib$gt_ld_shl_suffix zbbasic.o zbbasicexec.o errcont.o lfill.o zbdrive.o zblab1.o zblab2.o zblab3.o zblab4.o zbmain.o lotsvar.o examine.o ${gt_ld_m_shl_options} >& shared_lib_zb.csh_ld.outx
#
#
$gtm_tst/com/dbcreate.csh mumps 1
\rm -f *.o				# Remove object files to make sure they do not get used or interfere
#
$GTM << aaa
S \$zro="./zbshlib$gt_ld_shl_suffix ."
d ^zbdrive
halt
aaa
\ls *.o >& /dev/null					# List any object files created
if ($status == 0) then
	\ls *.o
	echo "Object files created. TEST FAILED!"
endif
$gtm_tst/com/dbcheck.csh
