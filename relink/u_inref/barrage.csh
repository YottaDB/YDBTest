#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

######################################################################################################################
# Test various autorelink-related functionality by invoking the barrage.m script first in the 'test' and then in the #
# 'analyze' mode. In case of a failure, barrage.m can be invoked in the 'replay' mode for further analysis. Below    #
# are the supported options:                                                                                         #
#                                                                                                                    #
#   (test mode)     mumps -run barrage                                                                               #
#   (replay mode)   mumps -run replay^barrage [analyze] [log to screen] [log to file] [break on errors]              #
#   (analysis mode) mumps -run analyze^barrage [log to screen] [log to file] [break on errors]                       #
#                                                                                                                    #
# All flags are optional and default to 0 (1 is the other legitimate value). Descriptions follow:                    #
#                                                                                                                    #
#   analyze         - enable / disable analysis (meaningful only during replay)                                      #
#   log to screen   - print (or not) short informative messages to the screen during analysis or replay              #
#   log to file     - print (or not) detailed M commands to reproduce the action performed by a particular process   #
#   break on errors - break (or not) on errors detected during the analysis                                          #
#                                                                                                                    #
# While it is safe to rerun the script in the 'replay' and 'analyze' modes, be advised that the 'test' mode wipes    #
# out all data recorded in a prior test.                                                                             #
######################################################################################################################

set debug_file = $PWD/debug.csh

# Create subdirectories for better file organization, in case a replay will be required.
mkdir db obj test

# Create a DB with good settings in the designated subdirectory.

cat >> testspecific.gde << CAT_EOF
change -segment DEFAULT -file=$PWD/db/mumps.dat
change -region DEFAULT -rec=10000 -key=512
CAT_EOF

setenv test_specific_gde $PWD/testspecific.gde
$gtm_tst/com/dbcreate.csh mumps	>&! dbcreate_db.out

# Move the gld to db and point gtmcrypt_config to absolute path
mv mumps.gld $PWD/db/
setenv gtmgbldir $PWD/db/mumps.gld
echo "setenv gtmgbldir $gtmgbldir"					>> $debug_file
if ("ENCRYPT" == "$test_encryption") then
	setenv gtmcrypt_config $PWD/gtmcrypt.cfg
endif

echo "setenv GTMXC_relink $GTMXC_relink"				>> $debug_file

# Update $gtmroutines, first saving the original value for dbcheck.csh's sake.
set save_gtmroutines = "$gtmroutines"
setenv gtmroutines 	"$PWD/obj(. $gtm_tst/$tst/inref) $gtm_dist"
setenv gtmcompile	"-embed_source"
echo 'setenv gtmroutines "'"$gtmroutines"'"'				>> $debug_file
echo 'setenv gtmcompile "'"$gtmcompile"'"'				>> $debug_file

# Define envvar for SIGUSR1 value on all platforms (for replay mode).
if (("OSF1" == $HOSTOS) || ("AIX" == $HOSTOS)) then
	setenv sigusrval 30
else if (("SunOS" == $HOSTOS) || ("HP-UX" == $HOSTOS) || ("OS/390" == $HOSTOS)) then
	setenv sigusrval 16
else if ("Linux" == $HOSTOS) then
	setenv sigusrval 10
endif
echo "setenv sigusrval $sigusrval"					>> $debug_file

set fail = 0
cd test

# Fire up the test in the designated subdirectory. Analyze the results. This is a light run because we do not want the replay
# to take too long; on the other hand, the replay verifies source and object file versions as well as the integrity of
# RCTLDUMPs, so we do not want to bypass it either.
setenv barrage_num_of_rtns	5
setenv barrage_num_of_src_dirs	3
setenv barrage_num_of_obj_dirs	3
setenv barrage_num_of_procs	2
setenv barrage_num_of_opers	1000
echo "# Light run:"							>> $debug_file
echo "setenv barrage_num_of_rtns $barrage_num_of_rtns"			>> $debug_file
echo "setenv barrage_num_of_src_dirs $barrage_num_of_src_dirs"		>> $debug_file
echo "setenv barrage_num_of_obj_dirs $barrage_num_of_obj_dirs"		>> $debug_file
echo "setenv barrage_num_of_procs $barrage_num_of_procs"		>> $debug_file
echo "setenv barrage_num_of_opers $barrage_num_of_opers"		>> $debug_file
$gtm_dist/mumps -run barrage > test.log
$gtm_dist/mumps -run analyze^barrage 0 1 1 > analysis.log
$grep -q "FAIL" {test,analysis}.log
if ($status) then
	$gtm_dist/mumps -run replay^barrage 1 0 1 1 > replay.log
	$grep -q "FAIL" replay.log
	if (! $status) then
		set fail = 1
	else
		ls -l core* >&! /dev/null
		if (! $status) then
			set fail = 1
		else
			echo "TEST-I-PASS, Test succeeded."
		endif
	endif
else
	set fail = 1
endif

if (! $fail) then
	# This time test more vigorously. Analyze the results. But do not replay.
	rm -rf *
	setenv barrage_num_of_rtns	20
	setenv barrage_num_of_src_dirs	5
	setenv barrage_num_of_obj_dirs	5
	setenv barrage_num_of_procs	5
	setenv barrage_num_of_opers	3500
	echo "# Heavy run:"						>> $debug_file
	echo "setenv barrage_num_of_rtns $barrage_num_of_rtns"		>> $debug_file
	echo "setenv barrage_num_of_src_dirs $barrage_num_of_src_dirs"	>> $debug_file
	echo "setenv barrage_num_of_obj_dirs $barrage_num_of_obj_dirs"	>> $debug_file
	echo "setenv barrage_num_of_procs $barrage_num_of_procs"	>> $debug_file
	echo "setenv barrage_num_of_opers $barrage_num_of_opers"	>> $debug_file
	$gtm_dist/mumps -run barrage > test.log
	$gtm_dist/mumps -run analyze^barrage 0 1 1 > analysis.log
	$grep -q "FAIL" {test,analysis}.log
	if (! $status) then
		set fail = 1
	else
		ls -l core* >&! /dev/null
		if (! $status) then
			set fail = 1
		else
			echo "TEST-I-PASS, Test succeeded."
		endif
	endif
endif
echo

# Wait for the children to notice that their parent is gone, and terminate.
if ($fail) then
	sleep 2
endif

# Return to the parent directory, restore $gtmroutines, and do a DB check (though dbcreate.csh was not used).
cd ..
setenv gtmroutines "$save_gtmroutines"
$gtm_tst/com/dbcheck.csh
