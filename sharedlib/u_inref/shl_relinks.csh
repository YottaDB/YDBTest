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
setenv save_gtmroutines "$gtmroutines"
$gtm_exe/mumps $gtm_tst/$tst/inref/{errcont.m,lnkrtn.m,lnkrtn0.m,lnkrtn1.m,lnkrtn2.m,relinks.m}
$gt_ld_m_shl_linker ${gt_ld_option_output} shl_relinks$gt_ld_shl_suffix errcont.o lnkrtn.o  lnkrtn0.o  lnkrtn1.o  lnkrtn2.o  relinks.o ${gt_ld_m_shl_options} >& shl_relinks_ld.outx
#
\cp $gtm_tst/$tst/inref/{lnkrtn1.m,lnkrtn2.m} .	# Needed for zlink
#
$gtm_tst/com/dbcreate.csh mumps 1
\rm -f *.o					# Remove object files to make sure they do not get used or interfere
#
setenv gtmroutines ". ./shl_relinks$gt_ld_shl_suffix"
$gtm_exe/mumps -run relinks
\ls *.o					# List any object files created

setenv gtmroutines "$save_gtmroutines"
$gtm_tst/com/dbcheck.csh
