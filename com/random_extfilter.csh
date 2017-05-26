#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# Randomly choose between a simple echo-back filter on both source and receiver sides
# OR one where the source inflates the data and the receiver deflates the data back to its original value.
# The latter choice tests the buffer expansion algorithms of internal and external filter buffers in the
# source and receiver server code.

if ($?gtm_test_replay) then
	# If -replay is done, the below settings would have been sourced already
	exit
endif

if ($1 == "") then
	set randno = `$gtm_exe/mumps -run rand 2`
else
	set randno = $1
endif

if ($randno == 0) then
	setenv gtm_tst_ext_filter_src "$gtm_exe/mumps -run ^extfilter"
	setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^extfilter"
else
	setenv gtm_tst_ext_filter_spaces `$gtm_exe/mumps -run rand 1000 1 500`	# generate random number : 500 <= randno < 1500
	setenv gtm_tst_ext_filter_src "$gtm_exe/mumps -run ^extfilterinflate"
	setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^extfilterdeflate"
endif

echo "# random_extfilter.csh settings"						>>&! settings.csh
echo 'setenv gtm_tst_ext_filter_src "'$gtm_tst_ext_filter_src'"'		>>&! settings.csh
echo 'setenv gtm_tst_ext_filter_rcvr "'$gtm_tst_ext_filter_rcvr'"'		>>&! settings.csh
if ($?gtm_tst_ext_filter_spaces) then
	echo 'setenv gtm_tst_ext_filter_spaces "'$gtm_tst_ext_filter_spaces'"'	>>&! settings.csh
endif
