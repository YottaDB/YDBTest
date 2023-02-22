#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/local/bin/tcsh -f

# "mupip set -encryptable" will not work - if encryption environment is not set, in case of GT.CM since remote databases can't be accessed and versions prior to V63000
if ( ("NON_ENCRYPT" == "$test_encryption") || ("GT.CM" == $test_gtm_gtcm) || ( `expr "V63000" ">" $gtm_verno` ) ) then
	exit 0
endif

if ($?gtm_test_db_format) then
	set dbformat = $gtm_test_db_format
else
	set dbformat = `$DSE dump all -f |& $tst_awk '/Desired DB Format/ {if ($NF == "V4") dbformat="V4"} END {print dbformat}'`
endif

if ("V4" == "$dbformat") then
	exit 0
endif

if (-e settings.csh) then
	# Get only the value of gtm_test_set_encryptable from settings.csh. If present tmp.csh will have the setenv command else the file will be empty
	$grep -E "gtm_test_set_encryptable" settings.csh >&! tmp.csh
	source tmp.csh
	\rm tmp.csh
endif

# Randomly set gtm_test_set_encryptable if not already set and if gtm_test_db_format is not V4
if (! $?gtm_test_set_encryptable) then
	set rand = `$gtm_exe/mumps -run rand 2`
	if ($rand) then
		set gtm_test_set_encryptable = 1
		echo "setenv gtm_test_set_encryptable $gtm_test_set_encryptable"	>> settings.csh
	endif
endif

# Do mupip set -encryptable if gtm_test_set_encryptable is 1
if ($?gtm_test_set_encryptable) then
	if ($gtm_test_set_encryptable) then
		set outfile = mse_`date +%y%m%d_%H%M%S`_$$.out
		alias command '$MUPIP set -encryptable -region "*"'
		alias command			>>&! $outfile
		command				>>&! $outfile
		set mupip_status = $status
		if ($mupip_status) then
			echo "MUPIP_SET_ENCRYPTABLE-E-ERROR, `alias command` returned status $mupip_status, please check $outfile"
		endif
	endif
endif
