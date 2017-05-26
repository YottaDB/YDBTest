#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Verify that JOB process paratemeter -stdout and stderr - present in mumps text section are not modified by middle process created
# during JOB command execution.

echo "subtest gtm7905 starts."
cp $gtm_tst/$tst/inref/jobfail.m .
$gtm_exe/mumps jobfail.m
$gt_ld_m_shl_linker ${gt_ld_option_output} jobfail$gt_ld_shl_suffix jobfail.o ${gt_ld_m_shl_options} >& link_ld.outx
$gtm_exe/mumps -run %XCMD 'set $zroutines="jobfail.so" do ^jobfail'
echo "subtest gtm7905 ends."
