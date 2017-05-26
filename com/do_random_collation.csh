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

# This is a helper script that randomly enables collation for a few select tests

if ($?test_collation) then
	# Collation already set. Exit
	exit
endif

setenv test_collation "NON_COLLATION"	# The default
if (! $?test_collation_value) setenv test_collation_value "default"
if (! $?test_collation_no)    setenv test_collation_no 0
if ($test_collation_value != "default") setenv test_collation "COLLATION"

set collation_always = ""
set collation_random = " lost_trans crash_fail split_recov jnl tprollbk dse mupip online_bkup reorg resil "

# rand = 1 - 100
set rand = `date | $tst_awk '{srand() ; print (int(rand() * 100) + 1 )}'`

if ( "$collation_always" =~ "* $tst *" ) then
	setenv test_collation COLLATION
	if ("default" == "$test_collation_value") then
		setenv test_collation_no 1
	endif
else if ( "$collation_random" =~ "* $tst *" ) then
	if ( 50 < $rand ) then
		# set collation 50% of the times
		setenv test_collation COLLATION
		if ("default" == "$test_collation_value") then
			setenv test_collation_no 1
		endif
	endif
endif
