#!/usr/local/bin/tcsh -f
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

#
# This script is used by test/v62000/u_inref/gtm7926isgtmdist.csh to execute
# the HELP function of the target executable ($1) while using $3 as the value
# of $gtm_dist. Redirect the command's output to a file not checked for error
# messages. If an error is found, print "Failure".
#
# The Pass/Fail messages print the executable's path and $gtm_dist path.
#

# $1 absolute path to executable. Path format is assumed to be
# 	$gtm_root/$gtm_verno/$gtm_image/<exe name>
# $2 additional name for the output file. Used by the calling test to indicate
# 	which iteration the test is in.
# $3 The value for $gtm_dist

setenv gtm_dist $3
set logfile =  ${1:t}${1:h:t}.help.${2}.outx

printf "\n\n\n" | ${1} help >&! $logfile
$grep -q "%YDB-[FEW]" $logfile
if ( $status ) then
	echo "Pass for $1 gtm_dist=${gtm_dist}"
else
	echo "Failure for ${1} gtm_dist=${gtm_dist}"
endif

