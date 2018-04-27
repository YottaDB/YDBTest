#!/usr/local/bin/tcsh -f
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################

# Before sourcing the script file generated from multisite_replic.awk let's do mandatory checks here!!
# Let's have 3 different sections each trying to catch different scenarios and report.
#
if ( 0 == $#argv ) then
	echo "TEST-E-chk_msr_error"
	echo "Pls. specify the current multisite action as argument while calling the script"
	echo "Usage:"
	echo "\$gtm_tst/\$tst/u_inref/chk_msr_errors.csh RUN"
	exit 1
endif
####################### section reporting error in multisite action inside the awk program #####################
if ( -e msr_error.log) then
	echo "TEST-E-ERROR in multisite action as "
	cat msr_error.log
	mv msr_error.log msr_error_$action_file.log
	exit 1
endif
#
####################### section reporting error in script generation by the awk program #####################
if !( `grep -v "tcsh" $action_file".csh"|wc -l` ) then
	echo "TEST-E-NOSCRIPT awk porgram didn't generate a script for the multisite action $argv"
	echo "Pls. check the trace and logs for a possible fallout"
	exit 1
endif
#
####################### section reporting error in active links information for a given  msr layout #####################
# we don't expect link file updation for the below set of MSR actions
setenv msr_error_chk `echo $1 | $grep -E "START|STOP|CRASH|REFRESH|ACTIVATE" | grep -v "YDB-" | wc -l`
if ( (!( -e msr_links_temp.txt)) && ( 0 != $msr_error_chk ) ) then # because we don't expect links updation in RUN command of msr
	echo "TEST-E-ACTIVE_LINKS, active links file not updated.Error in multisite_action.Check multisite logs"
	exit 1
endif
