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

$GDE @$gtm_tst/$tst/inref/noisolation.gde >&! gdeout.out
$MUPIP create >&! mupipcreate.out

echo "# Randomly change the max keysize of a few databases - to keep it out of sync with .gld values"

if (! $?gtm_test_replay) then
	$gtm_tst/com/create_reg_list.csh
	set region_list = `cat reg_list.txt`
	set noisolation_reglist  = `$gtm_exe/mumps -run all^chooseamong $region_list`
	setenv noisolation_reflist `$gtm_exe/mumps -run rand 2 10`
	echo 'setenv noisolation_reglist "'$noisolation_reglist'"'	>>&! settings.csh
	echo 'setenv noisolation_reflist "'$noisolation_reflist'"'	>>&! settings.csh
endif

if ("" != "$noisolation_reglist") then
	$gtm_tst/com/dse_command.csh -region "$noisolation_reglist" -do 'change -fileheader -key=256'
endif

$gtm_exe/mumps -run noisolation
