#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script sets various random test options for each test.
set settingsfile = "$tst_general_dir/settings.csh"
set shorthost = $HOST:r:r:r

# $zroutines might not have been set properly at this point of execution. So let's not rely on rand.m
# If replay option is selected, source the file and exit
if ($?gtm_test_replay) then
	source $gtm_test_replay
	echo "# settings file $gtm_test_replay sourced"				>>&! $settingsfile
	cat $gtm_test_replay							>>&! $settingsfile
	exit
endif

echo "###################################################################"	>>&! $settingsfile
echo "########## Begin do_random_settings.csh random settings ###########"	>>&! $settingsfile

# Generate a sequence of n random numbers and use it in the rest of the script.
# If new randomness is needed, increase the count (first argument) and use $randnumbers[n]
# All random values needed in this routine are generated in one shot as generating them separately
# 	has been found to assign all of them the same value because the seed for srand() seems to be
# 	governed by the current time in second level granularity.
# If any new randomness is added, check if speed test also needs to be changed to take it into consideration
# arguments below are count-of-numbers-needed lower-bound upper-bound
set randnumbers = `$gtm_tst/com/genrandnumbers.csh 46 1 10`

# Caution : No. of random choices below and the no. of random numbers generated above might not necessarily be the same.
# 	    Increase the count by the number of new random numbers the newly introduced code needs.
#
setenv tst_random_all ""

###########################################################################
### Random option - 39 ### Randomly enable journaling for v[4-9]*, r[1-9]* and simpleapi tests (Can be expanded when required)
if !($?gtm_test_jnl) then
	if ( (( $tst == "simpleapi" ) || ( $tst =~ r[1-9]* ) || ( $tst =~ v[4-9]* )) && ( 5 >= $randnumbers[39] ) ) then
		setenv gtm_test_jnl SETJNL
	else
		setenv gtm_test_jnl NON_SETJNL
	endif
	echo "# gtm_test_jnl set by do_random_settings.csh"			>>&! $settingsfile
else
	echo "# gtm_test_jnl was set before coming into do_random_settings.csh"	>>&! $settingsfile
endif
echo "setenv gtm_test_jnl $gtm_test_jnl"					>>&! $settingsfile
setenv tst_random_all "$tst_random_all gtm_test_jnl"

###########################################################################
### Random option - 1 ### Journal string is set to either before or nobefore
# For now only "-jnl nobefore" or "-jnl before" is randomly specified
# This will cause the tests to randomly run with NOBEFORE_IMAGE or BEFORE_IMAGE journaling.
#
# Do this only if -jnl is not passed to gtmtest
if !($?tst_jnl_str) then
	if ( 5 >= $randnumbers[1]) then
		setenv tst_jnl_str "-journal=enable,on,nobefore"
		setenv gtm_test_jnl_nobefore 1
	else
		setenv tst_jnl_str "-journal=enable,on,before"
		setenv gtm_test_jnl_nobefore 0
	endif
	echo "# tst_jnl_str set by do_random_settings.csh"			>>&! $settingsfile
else
	echo "# tst_jnl_str was set before coming into do_random_settings.csh"	>>&! $settingsfile
endif
echo "setenv tst_jnl_str $tst_jnl_str"						>>&! $settingsfile
echo "setenv gtm_test_jnl_nobefore $gtm_test_jnl_nobefore"			>>&! $settingsfile
setenv tst_random_all "$tst_random_all gtm_test_jnl_nobefore"

###########################################################################
### Random option - 2 ### Append random align_size values to tst_jnl_str
# Random alignsize is skipped for 32-bit systems -- instead of a random value, use the default.  In general,
# there is no control over the number of journal buffers that may be allocated and so the total can exceed
# the 4 GB maximum for 32 bit systems.  Therefore, only have random alignsize for 64-bit systems.
#
# Do this random choice only if -align is not already passed to gtmtest.csh
if !($?test_align) then
	switch ($gtm_test_os_machtype)
		case "HOST_LINUX_X86_64":
			# Pick a power of 2 between (inclusive) 2^[12, 17] -- [4096, 131072]
			set align = `date | $tst_awk '{srand () ; print 2^(12 + int(rand() * 6))}'`
			breaksw
		case "HOST_LINUX_AARCH64":
		case "HOST_LINUX_ARMVXL":
		default:
			# 64-bit ARM and 32-bit ARM have limited memory capacities so limit alignsize on those platforms.
			# Or else tests which use many journal files (e.g. stress/concurr) could use gigabytes of memory
			# just for the source server and that can bring the ARM system down.
			set align = 4096
			breaksw
	endsw
	setenv test_align  "$align"
	echo "# test_align randomly set by do_random_settings.csh"		>>&! $settingsfile
else
	echo "# test_align was set before coming into do_random_settings.csh"	>>&! $settingsfile
endif
setenv tst_jnl_str "$tst_jnl_str,align=$test_align"
# Log the value in settings.csh
echo "setenv test_align $test_align"						>>&! $settingsfile
echo "setenv tst_jnl_str $tst_jnl_str"						>>&! $settingsfile
setenv tst_random_all "$tst_random_all test_align"

###########################################################################
### Random option - 3 ### Random collation
source $gtm_tst/com/do_random_collation.csh
echo "# collation settings by do_random_collation.csh"				>>&! $settingsfile
echo "setenv test_collation $test_collation"					>>&! $settingsfile
echo "setenv test_collation_value $test_collation_value"			>>&! $settingsfile
echo "setenv test_collation_no $test_collation_no"				>>&! $settingsfile

setenv tst_random_all "$tst_random_all test_collation"

###########################################################################
### Random option - 4 ### Set gtm_tp_allocation_clue to a random number
#
# Do this if gtm_tp_allocation_clue is not already passed to gtmtest.csh
if !($?gtm_tp_allocation_clue) then
	if (5 >= $randnumbers[2]) then
		# Set gtm_tp_allocation_clue to a random number
		set tpallocclue_range = `date | $tst_awk '{srand () ; print (1 + int (rand () * 4))}'`
		if (1 == $tpallocclue_range) then
			# Set the tp_alloc_clue to be a random number between 1 and 2^7
			set tpallocclue = `date | $tst_awk '{srand () ; print (1 + int (rand () * 2^7))}'`
		else if ( 2 ==  $tpallocclue_range) then
			# Set the tp_alloc_clue to be a random number between 2^7 and 2^14
			set tpallocclue = `date | $tst_awk '{srand () ; print (1 + 2^7 + int (rand () * (2^14 - 2^7) ) )}'`
		else if ( 3 ==  $tpallocclue_range) then
			# Set the tp_alloc_clue to be a random number between 2^14 and 2^21
			set tpallocclue = `date | $tst_awk '{srand () ; print (1 + 2^14 + int (rand () * (2^21 - 2^14) ) )}'`
		else if ( 4 ==  $tpallocclue_range) then
			# Set the tp_alloc_clue to be a random number between 2^21 and 2^28
			set tpallocclue = `date | $tst_awk '{srand () ; print (1 + 2^21 + int (rand () * (2^28 - 2^21) ) )}'`
		endif
		setenv gtm_tp_allocation_clue $tpallocclue
		# Log the value in settings.csh
		echo "# gtm_tp_allocation_clue set do_random_settings.csh"				>>&! $settingsfile
		echo "setenv gtm_tp_allocation_clue $gtm_tp_allocation_clue"				>>&! $settingsfile
	else
		echo "# gtm_tp_allocation_clue chosen to be UNDEFINED by do_random_settings.csh"	>>&! $settingsfile
		echo "unsetenv gtm_tp_allocation_clue"							>>&! $settingsfile
	endif
else
	echo "# gtm_tp_allocation_clue was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_tp_allocation_clue $gtm_tp_allocation_clue"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_tp_allocation_clue"

###########################################################################
### Random option - 5 ### Set gtm_zlib_cmp_level to a random number
#
# Do this if gtm_zlib_cmp_level is not already passed to gtmtest.csh
if !($?gtm_zlib_cmp_level) then
	if (5 >= $randnumbers[3]) then
		# Set gtm_zlib_cmp_level to a random number between 0 and 10 (10 should silently ignore and not fail)
		setenv gtm_zlib_cmp_level `date | $tst_awk '{srand () ; print (int (rand () * 11))}'`
		# Limit compression on slow boxes.
		# Each platform should have at least one box doing full compression testing.
		if ($shorthost =~ {atlst2000,pfloyd}) then
			if ($gtm_zlib_cmp_level > 1 && $gtm_zlib_cmp_level < 10) then
				setenv gtm_zlib_cmp_level 1
			endif
		endif
		if ($gtm_test_os_machtype =~ {HOST_HP-UX_IA64}) then
			if ($gtm_zlib_cmp_level > 6 && $gtm_zlib_cmp_level < 10) then
				setenv gtm_zlib_cmp_level 6
			endif
		endif
		# Log the value in settings.csh
		echo "# gtm_zlib_cmp_level set by do_random_settings.csh"			>>&! $settingsfile
	else
		echo "# gtm_zlib_cmp_level chosen to be UNDEFINED by do_random_settings.csh"	>>&! $settingsfile
	endif
else
	echo "# gtm_zlib_cmp_level was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	if ("-0" == "$gtm_zlib_cmp_level") then
		# If -0 is passed to an environment variable, it signals unsetenv the variable
		unsetenv gtm_zlib_cmp_level
	endif
endif
if ($?gtm_zlib_cmp_level) then
	echo "setenv gtm_zlib_cmp_level $gtm_zlib_cmp_level"					>>&! $settingsfile
else
	echo "unsetenv gtm_zlib_cmp_level"							>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_zlib_cmp_level"

###########################################################################
### Random option - 6 ### Randomly do multi-host testing
source $gtm_tst/com/do_random_multihost.csh
echo "# multi-host settings by do_random_multihost.csh"				>>&! $settingsfile
echo "setenv test_replic_mh_type $test_replic_mh_type"				>>&! $settingsfile
echo "setenv test_repl $test_repl"						>>&! $settingsfile
if ($?test_replic) then
	echo "setenv test_replic $test_replic"					>>&! $settingsfile
endif

setenv tst_random_all "$tst_random_all test_replic_mh_type"

###########################################################################
### Random option - 7 ### Decide if access method should be MM or BG#
#
# Randomly run with the MM (and therefore NOBEFORE) or BG access method.
#
# Do this only if -mm or -bg is not passed to gtmtest
 if !($?acc_meth) then
 	if (3 < $randnumbers[4]) then
 		setenv acc_meth "BG"
 	else
 		setenv acc_meth "MM"
 	endif
 	# Log the value in settings.csh
 	echo "# acc_meth set by do_random_settings.csh"						>>&! $settingsfile
 	echo "setenv acc_meth $acc_meth"							>>&! $settingsfile
 else
	echo "# acc_meth was already set before coming into do_random_settings.csh"		>>&! $settingsfile
 	echo "setenv acc_meth $acc_meth"							>>&! $settingsfile
 	if ("MM" == $acc_meth) then
 		# -MM or -env acc_meth="MM" was explicitly passed to gtmtest in which case we can safely turn off encryption.
 		setenv test_encryption "NON_ENCRYPT"
 		echo "# disabling encryption since -mm was explicitly specified to gtmtest.csh" >>&! $settingsfile
 		echo "setenv test_encryption $test_encryption" 					>>&! $settingsfile
 	endif
 endif
setenv tst_random_all "$tst_random_all acc_meth"

###########################################################################
### Random option - 8 ### Decide if encryption should be on/off ie; ENCRYPT or NON_ENCRYPT
# Also, if test_encryption is already set to "ENCRYPT" by arguments.csh (-encrypt/-env) then acc_meth should always be BG as
# MM mode doesn't support encryption
if ("MM" == "$acc_meth") then
	# disable encryption if MM is choosen randomly
	setenv test_encryption "NON_ENCRYPT"
	echo "# test_encryption is set to $test_encryption (since acc_meth is $acc_meth) by do_random_settings.csh"	>>&! $settingsfile
	echo "setenv test_encryption $test_encryption"									>>&! $settingsfile
else if !($?test_encryption) then
	if ((5 >= $randnumbers[5])) then
		setenv test_encryption "ENCRYPT"
	else
		setenv test_encryption "NON_ENCRYPT"
	endif
	echo "# test_encryption set by do_random_settings.csh"								>>&! $settingsfile
	echo "setenv test_encryption $test_encryption"									>>&! $settingsfile
else
	if ("ENCRYPT" == $test_encryption) then
		# Log the value in settings.csh
		setenv  acc_meth "BG"
		echo "# -encrypt was specified before coming into do_random_setttings.csh."				>>&! $settingsfile
		echo "# test_encryption was not randomly modified by do_random_settings.csh."				>>&! $settingsfile
		echo "# acc_meth was explicitly modified by do_random_settings.csh. to BG"				>>&! $settingsfile
		echo "setenv acc_meth $acc_meth"									>>&! $settingsfile
		echo "setenv test_encryption $test_encryption"								>>&! $settingsfile
	else
		echo "# -noencrypt was specified before coming into do_random_setttings.csh."				>>&! $settingsfile
		echo "# test_encryption was not randomly modified by do_random_settings.csh."				>>&! $settingsfile
		echo "setenv test_encryption $test_encryption"								>>&! $settingsfile
	endif

endif

setenv tst_random_all "$tst_random_all test_encryption"
# If encryption is turned on, randomize the encryption library and algorithm for this run.
source $gtm_tst/com/set_encryption_lib_and_algo.csh									>>&! $settingsfile

###########################################################################
### Random option - 43 ### Randomly enable parallel encryption on the fly
source $gtm_tst/com/do_random_eotf.csh
echo "# Encryption on the fly settings by do_random_eotf.csh"								>>&! $settingsfile
echo "setenv gtm_test_do_eotf $gtm_test_do_eotf"									>>&! $settingsfile
echo "setenv gtm_test_eotf_keys $gtm_test_eotf_keys"									>>&! $settingsfile
setenv tst_random_all "$tst_random_all gtm_test_do_eotf"


###########################################################################
### Random option - 9 ### Randomly set a value to gtmdbglvl
#
# Do this only 20% of the time. Note on versions V6.2-001 and prior, the $gtmdbglvl setting of 0x40000 and 0x1F0 could cause major
# performance issues with align sizes exceeding 16MB. Versions after that limit the amount of backfilling of allocated and/or freed
# memory setting and/or memory backfill verification checking to the first 16KB of a given memory area eliminating the worst of the
# performance issues. Nevertheless, single-CPU systems are better not additionally stressed with gtmdbglvl-related activity so
# keep gtmdbglvl unset on those systems.
if !($?gtmdbglvl) then
	if (8 < $randnumbers[6]) then
		@ numcpus = `grep -c ^processor /proc/cpuinfo`
		if ($numcpus == 1) then
			echo "# gtmdbglvl is chosen to be UNDEFINED by do_random_settings.csh due to 1 CDU"	>>&! $settingsfile
			echo "unsetenv gtmdbglvl"								>>&! $settingsfile
		else
			# if decided to set (20%), do this : 10% - 0x1F0 ; 60% - 0x40000 ; 30% - 0x30(48)
			if (6 >= $randnumbers[7]) then
				setenv gtmdbglvl "0x40000"	# 6/10 chance
			else if (9 >= $randnumbers[7]) then
				setenv gtmdbglvl "0x30"		# 3/10 chance
			else
				setenv gtmdbglvl "0x1F0"	# 1/10 chance
			endif
			echo "# gtmdbglvl set by do_random_settings.csh"				>>&! $settingsfile
			echo "setenv gtmdbglvl $gtmdbglvl"						>>&! $settingsfile
		endif
	else
		echo "# gtmdbglvl is chosen to be UNDEFINED by do_random_settings.csh"		>>&! $settingsfile
		echo "unsetenv gtmdbglvl"							>>&! $settingsfile
	endif
else
	echo "# gtmdbglvl was specified before coming to do_random_setttings.csh."		>>&! $settingsfile
	echo "setenv gtmdbglvl $gtmdbglvl"							>>&! $settingsfile
	echo "# gtmdbglvl was not randomly set by do_random_settings.csh."			>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtmdbglvl"

###########################################################################
### Random option - 10 ### Randomly set a value that will tell dbcheck_base* scripts to do INTEG with -ONLINE or -NOONLINE
### Note that, explicit MUPIP INTEGs done in a test will continue to use -online as default unless otherwise -noonline
### is specified explicitly
#
#
if !($?gtm_test_online_integ) then
	if (5 >= $randnumbers[8]) then
		# choose randomly between setting to "" or "-online"
		if (2 >= $randnumbers[8]) then	# 2/10th chance
			setenv gtm_test_online_integ ""
		else				# 3/10th chance
			setenv gtm_test_online_integ "-online"
		endif
	else					# 1/2 chance
		setenv gtm_test_online_integ "-noonline"
	endif
	echo "# gtm_test_online_integ set by do_random_settings.csh"				>>&! $settingsfile
	echo "setenv gtm_test_online_integ $gtm_test_online_integ"				>>&! $settingsfile
else
	echo "# gtm_test_online_integ was specified before coming to do_random_settings.csh."	>>&! $settingsfile
	echo "setenv gtm_test_online_integ $gtm_test_online_integ"				>>&! $settingsfile
	echo "# gtm_test_online_integ was not randomly set by do_random_settings.csh"		>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_online_integ"

###########################################################################
### Random option - 11 ### Set gtm_test_trigger to a random number
#
if !($?gtm_test_trigger) then
	if (5 >= $randnumbers[9]) then
		setenv gtm_test_trigger 1
	else
		setenv gtm_test_trigger 0
	endif
	echo "# gtm_test_trigger set by do_random_settings.csh"					>>&! $settingsfile
else
	echo "# gtm_test_trigger was already set before coming into do_random_settings.csh"	>>&! $settingsfile
endif
echo "setenv gtm_test_trigger $gtm_test_trigger"						>>&! $settingsfile
setenv tst_random_all "$tst_random_all gtm_test_trigger"

###########################################################################
### Random option - 12 ### pick unicode/nounicode randomly
#
# call the script that randomizes unicode choice. Enforced conditions like -unicode etc are taken care in the script
# The script is structured to echo the choice in settings.csh format, so redirect the output to settingsfile
source $gtm_tst/com/gtm_test_setunicode.csh							>>&! $settingsfile
setenv tst_random_all "$tst_random_all gtm_chset"

###########################################################################
### Random option - 13 ### Randomly enable full_boolean - setenv gtm_boolean 1
#
# Do this if gtm_boolean is not already passed to gtmtest.csh
if !($?gtm_boolean) then
	if (5 >= $randnumbers[10]) then
		setenv gtm_boolean 1
		# 50% chance of setting gtm_boolean 1
		echo "# gtm_boolean set by do_random_settings.csh"				>>&! $settingsfile
		echo "setenv gtm_boolean $gtm_boolean"						>>&! $settingsfile
	else if (2 >= $randnumbers[10]) then
		setenv gtm_boolean 0
		# 30% chance of setting gtm_boolean 0
		echo "# gtm_boolean set by do_random_settings.csh"				>>&! $settingsfile
		echo "setenv gtm_boolean $gtm_boolean"						>>&! $settingsfile
	else
		# 20% chance of setting leaving gtm_boolean un set
		echo "# gtm_boolean chosen to be UNDEFINED by do_random_settings.csh"		>>&! $settingsfile
		echo "unsetenv gtm_boolean"							>>&! $settingsfile
	endif
else
	echo "# gtm_boolean was already set before coming into do_random_settings.csh"		>>&! $settingsfile
	echo "setenv gtm_boolean $gtm_boolean"							>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_boolean"

###########################################################################
### Random option - 14 ### Randomly enable gtm_jnl_release_timeout
#
# Do this if gtm_source_idle_timeout is not already passed to gtmtest.csh
if !($?gtm_jnl_release_timeout) then
	if (5 >= $randnumbers[11]) then
		if (1 == $randnumbers[11]) then
			# Set gtm_jnl_release_timeout to a huge (but possible) value, between 361 and 2^32-1
			# Using toupper so 4.10182e+09 (seen on jackal) gets written 4.10182E+09
			setenv gtm_jnl_release_timeout `date | $tst_awk '{srand () ; print (toupper(361 + int (rand () * (2^32 - 362) )))}'`
		else
			# Set gtm_jnl_release_timeout to a reasonable random number between 0 and 360 sec.
			setenv gtm_jnl_release_timeout `date | $tst_awk '{srand () ; print (int (rand () * 361))}'`
		endif
		# Log the value in settings.csh
		echo "# gtm_jnl_release_timeout set by do_random_settings.csh"				>>&! $settingsfile
		echo "setenv gtm_jnl_release_timeout $gtm_jnl_release_timeout"				>>&! $settingsfile
	else
		echo "# gtm_jnl_release_timeout chosen to be UNDEFINED by do_random_settings.csh"	>>&! $settingsfile
		echo "unsetenv gtm_jnl_release_timeout"							>>&! $settingsfile
	endif
else
	echo "# gtm_jnl_release_timeout was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_jnl_release_timeout $gtm_jnl_release_timeout"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_jnl_release_timeout"

###########################################################################
### Random option - 15 ### Randomly enable mprof testing - setenv gtm_trace_gbl_name
#
# Do this if gtm_trace_gbl_name is not already passed to gtmtest.csh
# Disable it if $gtm_test_disable_trace_gbl is set in the environment
if !($?gtm_trace_gbl_name) then
	if ( (1 >= $randnumbers[12]) && (! $?gtm_test_disable_trace_gbl) ) then
		setenv gtm_trace_gbl_name ""
		# Log the value in settings.csh
		echo "# gtm_trace_gbl_name set in gtmtest.csh by do_random_settings.csh"	>>&! $settingsfile
		echo "setenv gtm_trace_gbl_name $gtm_trace_gbl_name"				>>&! $settingsfile
	else
		echo "# gtm_trace_gbl_name chosen to be UNDEFINED by do_random_settings.csh"	>>&! $settingsfile
		echo "unsetenv gtm_trace_gbl_name"						>>&! $settingsfile
		echo "setenv gtm_test_disable_trace_gbl"					>>&! $settingsfile
	endif
else
	echo "# gtm_trace_gbl_name was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_trace_gbl_name $gtm_trace_gbl_name"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_trace_gbl_name"

###########################################################################
### Random option - 16 ### Randomly decide to start a supplementary instance at the receiver side
#
# Do this if test_replic_suppl_type is not already passed to gtmtest.csh
if !($?test_replic_suppl_type) then
	# Assuming A,B to be non-supplementary and P,Q to be supplementary...
	if (4 >= $randnumbers[13]) then
		# 40% chance of setting A -> B type replication
		setenv test_replic_suppl_type 0
	else if (7 >= $randnumbers[13]) then
		# 30% chance of setting A -> P type replication
		setenv test_replic_suppl_type 1
	else
		# 30% chance of setting P -> Q type replication
		setenv test_replic_suppl_type 2
	endif
	# Log the value in settings.csh
	echo "# test_replic_suppl_type set by do_random_settings.csh"					>>&! $settingsfile
	echo "setenv test_replic_suppl_type $test_replic_suppl_type"					>>&! $settingsfile
else
	echo "# test_replic_suppl_type was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv test_replic_suppl_type $test_replic_suppl_type"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all test_replic_suppl_type"

###########################################################################
### Random option - 17 ### Randomly decide to enable TP
#
# Don't randomize if gtm_test_tp is forced by passing -tp or -notp to gtmtest.csh
if !($?gtm_test_tp) then
	# set to TP only if it is GT.M (and not GT.CM)
	if ( ("GT.M" == $test_gtm_gtcm) && ( 5 >= $randnumbers[14]) ) then
		setenv gtm_test_tp "TP"
	else
		setenv gtm_test_tp "NON_TP"
	endif
	echo "# gtm_test_tp set by do_random_settings.csh"						>>&! $settingsfile
	echo "setenv gtm_test_tp $gtm_test_tp"								>>&! $settingsfile
else
	# gtm_test_tp was forced to some value.
	echo "# gtm_test_tp was forced to $gtm_test_tp before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_tp $gtm_test_tp"								>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_tp"

###########################################################################
### Random option - 18 ### Randomly decide to enable spanning_nodes in tests
#
# Do this if gtm_test_spannode is not already passed to gtmtest.csh
if !($?gtm_test_spannode) then
	if (5 >= $randnumbers[15]) then
		setenv gtm_test_spannode 1
		echo "# gtm_test_spannode set by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_test_spannode $gtm_test_spannode"				>>&! $settingsfile
	else
		setenv gtm_test_spannode 0
		echo "# gtm_test_spannode disabled by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_test_spannode $gtm_test_spannode"				>>&! $settingsfile
	endif
else
	echo "# gtm_test_spannode was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_spannode $gtm_test_spannode"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_spannode"

###########################################################################
### Random option - 19 ### Randomly decide to do spanning regions
# Do this if gtm_test_spanreg is not already passed
#
# gtm_test_spanreg = Decimal 0 = Binary 00 => Do NOT use existing .sprgde files; Do NOT generate .sprgde files
# gtm_test_spanreg = Decimal 1 = Binary 01 => Do     use existing .sprgde files; Do NOT generate .sprgde files
# gtm_test_spanreg = Decimal 2 = Binary 10 => Do NOT use existing .sprgde files; Do     generate .sprgde files
# gtm_test_spanreg = Decimal 3 = Binary 11 => Do     use existing .sprgde files; Do     generate .sprgde files
# If randomly generating gtm_test_spanreg, only generate values 0 or 1 i.e. only randomly choose to use existing .sprgde files
# never cause .sprgde files to be generated on a random fashion. This will be done on a periodic basis separately.
if !($?gtm_test_spanreg) then
	if (6 >= $randnumbers[16]) then
		setenv gtm_test_spanreg 1
	else
		setenv gtm_test_spanreg 0
	endif
	echo "# gtm_test_spanreg set by do_random_settings.csh"					>>&! $settingsfile
	echo "setenv gtm_test_spanreg $gtm_test_spanreg"					>>&! $settingsfile
else
	echo "# gtm_test_spanreg was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_spanreg $gtm_test_spanreg"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_spanreg"

###########################################################################
### Random option - 20 ### Randomly decide to enable qdbrundown (mumps bypass) in tests
#
# Do this if gtm_test_qdbrundown is not already passed to gtmtest.csh
if !($?gtm_test_qdbrundown) then
	if (5 >= $randnumbers[17]) then
		setenv gtm_test_qdbrundown 1
		echo "# gtm_test_qdbrundown set by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_test_qdbrundown $gtm_test_qdbrundown"				>>&! $settingsfile
	else
		setenv gtm_test_qdbrundown 0
		echo "# gtm_test_qdbrundown disabled by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_test_qdbrundown $gtm_test_qdbrundown"				>>&! $settingsfile
	endif
else
	echo "# gtm_test_qdbrundown was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_qdbrundown $gtm_test_qdbrundown"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_qdbrundown"

###########################################################################
### Random option - 44 ### Randomly set gtm_db_counter_sem_incr
#
# Do this if gtm_db_counter_sem_incr is not already passed to gtmtest.csh
if !($?gtm_db_counter_sem_incr) then
	echo "# gtm_db_counter_sem_incr set by do_random_settings.csh"				>>&! $settingsfile
	if ( (9 < $randnumbers[43]) || (0 == $gtm_test_qdbrundown) ) then
		unsetenv gtm_db_counter_sem_incr	# 55% chance (due to 50% chance of $gtm_test_qdbrundown)
	else if (5 < $randnumbers[43]) then
		setenv gtm_db_counter_sem_incr 4096	# 20% chance
	else if (2 < $randnumbers[43]) then
		setenv gtm_db_counter_sem_incr 8192	# 15% chance
	else
		setenv gtm_db_counter_sem_incr 16384	# 10% chance
	endif
else
	echo "# gtm_db_counter_sem_incr was set before coming into do_random_settings.csh"	>>&! $settingsfile
	if ("-0" == "$gtm_db_counter_sem_incr") then
		# If -0 is passed to an environment variable, it signals unsetenv the variable
		unsetenv gtm_db_counter_sem_incr
	endif
endif
if ($?gtm_db_counter_sem_incr) then
	echo "setenv gtm_db_counter_sem_incr $gtm_db_counter_sem_incr"				>>&! $settingsfile
	# If gtm_db_counter_sem_incr is set, force gtm_test_qdbrundown=1
	setenv gtm_test_qdbrundown 1
	echo "# gtm_test_qdbrundown forced due to gtm_db_counter_sem_incr"			>>&! $settingsfile
	echo "setenv gtm_test_qdbrundown $gtm_test_qdbrundown"					>>&! $settingsfile
else
	echo "unsetenv gtm_db_counter_sem_incr"							>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_db_counter_sem_incr"

###########################################################################
### Random option - 21 ### Randomly decide to enable Anticipatory Freeze regression testing
#
# Do this if gtm_test_fake_enospc is not already passed to gtmtest.csh
if ! ($?gtm_test_fake_enospc) then
	if (5 >= $randnumbers[18]) then
		setenv gtm_test_fake_enospc 1
	else
		setenv gtm_test_fake_enospc 0
	endif
	echo "# gtm_test_fake_enospc set by do_random_settings.csh"				>>&! $settingsfile
	echo "setenv gtm_test_fake_enospc $gtm_test_fake_enospc"				>>&! $settingsfile
else
	echo "# gtm_test_fake_enospc was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_fake_enospc $gtm_test_fake_enospc"				>>&! $settingsfile
endif
# Automatically define custom errors and enable anticipatory freeze if fake ENOSPC is on
if ($?gtm_test_fake_enospc) then
	if (1 == $gtm_test_fake_enospc) then
	 	setenv gtm_test_freeze_on_error 1
		echo "# gtm_test_freeze_on_error set by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_test_freeze_on_error $gtm_test_freeze_on_error"		>>&! $settingsfile
		setenv gtm_custom_errors $gtm_tools/custom_errors_sample.txt
		echo "# gtm_custom_errors set by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_custom_errors $gtm_custom_errors"				>>&! $settingsfile
	endif
endif
setenv tst_random_all "$tst_random_all gtm_test_fake_enospc"

###########################################################################
### Random option - 22 ### Randomly decide to enable Instance freeze error file
#
# Do this if gtm_custom_errors is not already passed via -env gtm_custom_errors=<fully qualified path>
# or defined by option 21
if ! ($?gtm_custom_errors) then
	if (1 >= $randnumbers[19]) then
		setenv gtm_custom_errors $gtm_tools/custom_errors_sample.txt
		echo "# gtm_custom_errors set by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_custom_errors $gtm_custom_errors"				>>&! $settingsfile
	else if (8 > $randnumbers[19]) then
		echo "# gtm_custom_errors left undefined by do_random_settings.csh"		>>&! $settingsfile
		echo "unsetenv gtm_custom_errors"						>>&! $settingsfile
	else
		setenv gtm_custom_errors "/dev/null"
		echo "# gtm_custom_errors set by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_custom_errors $gtm_custom_errors"				>>&! $settingsfile
	endif
else
	echo "# gtm_custom_errors was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_custom_errors $gtm_custom_errors"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_custom_errors"

###########################################################################
### Random option - 23 ### Randomly decide to enable instance freeze on regions
#
# Do this if gtm_test_freeze_on_error is not already passed to gtmtest.csh
if ! ($?gtm_test_freeze_on_error) then
	if (5 >= $randnumbers[20]) then
		setenv gtm_test_freeze_on_error 1
	else
		setenv gtm_test_freeze_on_error 0
	endif
	echo "# gtm_test_freeze_on_error set by do_random_settings.csh"					>>&! $settingsfile
	echo "setenv gtm_test_freeze_on_error $gtm_test_freeze_on_error"				>>&! $settingsfile
else
	echo "# gtm_test_freeze_on_error was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_freeze_on_error $gtm_test_freeze_on_error"				>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_freeze_on_error"

###########################################################################
### Random option - 24 ### Randomly decide to enable standard side effects
#
# Do this if gtm_side_effects is not already passed to gtmtest.csh
if !($?gtm_side_effects) then
	if (5 >= $randnumbers[21]) then
		setenv gtm_side_effects 1
		echo "# gtm_side_effects set by do_random_settings.csh"					>>&! $settingsfile
		echo "setenv gtm_side_effects $gtm_side_effects"					>>&! $settingsfile
	else if (8 > $randnumbers[21]) then
		setenv gtm_side_effects 0
		echo "# gtm_side_effects disabled by do_random_settings.csh	"			>>&! $settingsfile
		echo "setenv gtm_side_effects $gtm_side_effects"					>>&! $settingsfile
	else
		echo "# gtm_side_effects undefined by do_random_settings.csh"				>>&! $settingsfile
		echo "unsetenv gtm_side_effects"							>>&! $settingsfile
	endif
else
	echo "# gtm_side_effects was already set before coming into do_random_settings.csh"		>>&! $settingsfile
	echo "setenv gtm_side_effects $gtm_side_effects"						>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_side_effects"

###########################################################################
### Random option - 25 ### Randomly decide to enable huge pages
#
# Do this randomness if gtm_test_hugepages is not already passed to gtmtest.csh
if !($?gtm_test_hugepages) then
	# Note - disable hugepage testing on Alpine until/unless we can set it up ##ALPINE_TODO##
	if (("alpine" != "$gtm_test_linux_distrib") && ( 5 >=  $randnumbers[22])) then
		setenv gtm_test_hugepages 1
	else
		setenv gtm_test_hugepages 0
	endif
	echo "# gtm_test_hugepages is set in do_random_settings.csh"					>>&! $settingsfile
else
	echo "# gtm_test_hugepages was already set before coming into do_random_settings.csh"		>>&! $settingsfile
endif

if ($gtm_test_hugepages) then
	setenv HUGETLB_SHM yes
	if ( $randnumbers[23] >= 9) then
		unsetenv HUGETLB_SHM
	endif
	# HUGETLB_MORECORE needs LD_PRELOAD, so set the latter if we are testing the former
	if ( $randnumbers[24] <= 5 || $?HUGETLB_MORECORE) then
		if (-e /usr/lib64/libhugetlbfs.so) then
			setenv LD_PRELOAD /usr/lib64/libhugetlbfs.so
		else if (-e /usr/lib/libhugetlbfs.so) then
			setenv LD_PRELOAD /usr/lib/libhugetlbfs.so
		endif
	endif
endif
# We dlopen() libhugetlbfs.so on supported systems regardless of test options, so keep it quiet.
setenv HUGETLB_VERBOSE 0
echo "setenv gtm_test_hugepages $gtm_test_hugepages"							>>&! $settingsfile
if ($?HUGETLB_MORECORE) then
	echo "setenv HUGETLB_MORECORE $HUGETLB_MORECORE"						>>&! $settingsfile
else
	echo "unsetenv HUGETLB_MORECORE"								>>&! $settingsfile
endif
if ($?HUGETLB_SHM) then
	echo "setenv HUGETLB_SHM $HUGETLB_SHM"								>>&! $settingsfile
else
	echo "unsetenv HUGETLB_SHM"									>>&! $settingsfile
endif
if ($?LD_PRELOAD) then
	echo "setenv LD_PRELOAD $LD_PRELOAD"								>>&! $settingsfile
else
	echo "unsetenv LD_PRELOAD"									>>&! $settingsfile
endif
echo "setenv HUGETLB_VERBOSE $HUGETLB_VERBOSE"								>>&! $settingsfile

setenv tst_random_all "$tst_random_all gtm_test_hugepages"

###########################################################################
### Random option - 26 ### Randomly decide to enable dynamic literals
#
# Do this if gtm_test_dynamic_literals is not already passed to gtmtest.csh
if !($?gtm_test_dynamic_literals) then
	if (5 >= $randnumbers[25]) then				# 5/10 chance (enabled)
		setenv gtm_test_dynamic_literals "DYNAMIC_LITERALS"
		echo "# gtm_test_dynamic_literals set by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_test_dynamic_literals $gtm_test_dynamic_literals"			>>&! $settingsfile
	else 							# 5/10 chance (disabled; default, pre-V60002 behavior)
		setenv gtm_test_dynamic_literals "NODYNAMIC_LITERALS"
		echo "# gtm_test_dynamic_literals disabled by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_test_dynamic_literals $gtm_test_dynamic_literals"			>>&! $settingsfile
	endif
else
	echo "# gtm_test_dynamic_literals was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_dynamic_literals $gtm_test_dynamic_literals"				>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_dynamic_literals"

###########################################################################
### Random option - 27 ### Randomly decide to disable IPv6
#
# Do this if gtm_ipv4_only is not already passed to gtmtest.csh
if !($?gtm_ipv4_only) then
	if (2 >= $randnumbers[26]) then				# 2/10 chance (enabled)
		source $gtm_tst/com/set_ydb_env_var_random.csh ydb_ipv4_only gtm_ipv4_only "1"
		if ($?ydb_ipv4_only) then
			echo "# ydb_ipv4_only set by do_random_settings.csh"				>>&! $settingsfile
			echo "setenv ydb_ipv4_only $ydb_ipv4_only"					>>&! $settingsfile
		else
			echo "# gtm_ipv4_only set by do_random_settings.csh"				>>&! $settingsfile
			echo "setenv gtm_ipv4_only $gtm_ipv4_only"					>>&! $settingsfile
		endif
	else 							# 8/10 chance (disabled; default, pre-V60002 behavior)
		source $gtm_tst/com/set_ydb_env_var_random.csh ydb_ipv4_only gtm_ipv4_only "0"
		if ($?ydb_ipv4_only) then
			echo "# ydb_ipv4_only disabled by do_random_settings.csh"			>>&! $settingsfile
			echo "setenv ydb_ipv4_only $ydb_ipv4_only"					>>&! $settingsfile
		else
			echo "# gtm_ipv4_only disabled by do_random_settings.csh"			>>&! $settingsfile
			echo "setenv gtm_ipv4_only $gtm_ipv4_only"					>>&! $settingsfile
		endif
	endif
else
	echo "# gtm_ipv4_only was already set before coming into do_random_settings.csh"		>>&! $settingsfile
	echo "setenv gtm_ipv4_only $gtm_ipv4_only"							>>&! $settingsfile
endif
if !($?host_suffix_if_ipv6) then
	setenv host_suffix_if_ipv6 `$gtm_dist/mumps -run chooseamong '' .v46 .v6`
else
	echo "# host_suffix_if_ipv6 was already set before coming into do_random_settings.csh"		>>&! $settingsfile
endif
echo "setenv host_suffix_if_ipv6 '$host_suffix_if_ipv6'"						>>&! $settingsfile

setenv tst_random_all "$tst_random_all ydb_ipv4_only"

###########################################################################
### Random option - 28 ### Randomly decide to enable SSL/TLS
if !($?gtm_test_tls) then
	if (5 >= $randnumbers[27]) then
		setenv gtm_test_tls "FALSE"
		echo "# SSL/TLS disabled by do_random_settings.csh"					>>&! $settingsfile
		echo "setenv gtm_test_tls FALSE"							>>&! $settingsfile
	else
		setenv gtm_test_tls "TRUE"
		echo "# SSL/TLS enabled by do_random_settings.csh"					>>&! $settingsfile
		echo "setenv gtm_test_tls TRUE"								>>&! $settingsfile
	endif
else
	echo "# gtm_test_tls was already set before coming into do_random_settings.csh"			>>&! $settingsfile
	echo "setenv gtm_test_tls $gtm_test_tls"							>>&! $settingsfile
endif

###########################################################################
### Random option - 29 ### Randomly decide to do SSL/TLS renegotation
if ($gtm_test_tls == "TRUE") then
	if !($?gtm_test_tls_renegotiate) then
		echo "# SSL/TLS renegotiate frequency set by do_random_settings.csh" 				>>&! $settingsfile
		if ($randnumbers[28] < 6) then
			setenv gtm_test_tls_renegotiate $randnumbers[28]
			echo "setenv gtm_test_tls_renegotiate $gtm_test_tls_renegotiate"			>>&! $settingsfile
		else
			unsetenv gtm_test_tls_renegotiate
			echo "unsetenv gtm_test_tls_renegotiate"						>>&! $settingsfile
		endif

	else
		echo "# gtm_test_tls_renegotiate was already set before coming into do_random_settings.csh"	>>&! $settingsfile
		echo "setenv gtm_test_tls_renegotiate $gtm_test_tls_renegotiate"				>>&! $settingsfile
	endif
endif
setenv tst_random_all "$tst_random_all gtm_test_tls"

###########################################################################
### Random option - 30 ### Randomly decide to enable -EMBED_SOURCE mumps qualifier
#
# Do this if gtm_test_gtm_test_embed_source is not already passed to gtmtest.csh
if !($?gtm_test_embed_source) then
	if (5 >= $randnumbers[29]) then				# 5/10 chance (enabled)
		setenv gtm_test_embed_source "TRUE"
		echo "# gtm_test_embed_source set by do_random_settings.csh"				>>&! $settingsfile
		echo "setenv gtm_test_embed_source $gtm_test_embed_source"				>>&! $settingsfile
	else 							# 5/10 chance (disabled; default, pre-V62000 behavior)
		setenv gtm_test_embed_source "FALSE"
		echo "# gtm_test_embed_source disabled by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_test_embed_source $gtm_test_embed_source"				>>&! $settingsfile
	endif
else
	echo "# gtm_test_embed_source was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_embed_source $gtm_test_embed_source"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_embed_source"


###########################################################################
### Random option - 31 ### Randomly decide to enable JNLFILEONLY on source servers
if !($?gtm_test_jnlfileonly) then
	if (5 >= $randnumbers[30]) then
		setenv gtm_test_jnlfileonly 0
		echo "# JNLFILEONLY disabled by do_random_settings.csh"					>>&! $settingsfile
		echo "setenv gtm_test_jnlfileonly $gtm_test_jnlfileonly"				>>&! $settingsfile
	else
		setenv gtm_test_jnlfileonly 1
		echo "# JNLFILEONLY enabled by do_random_settings.csh"					>>&! $settingsfile
		echo "setenv gtm_test_jnlfileonly $gtm_test_jnlfileonly"				>>&! $settingsfile
	endif
else
	echo "# gtm_test_jnlfileonly was already set before coming into do_random_settings.csh"		>>&! $settingsfile
	echo "setenv gtm_test_jnlfileonly $gtm_test_jnlfileonly"					>>&! $settingsfile
endif

setenv tst_random_all "$tst_random_all gtm_test_jnlfileonly"

###########################################################################
### Random option - 32 ### Randomly decide to enable autorelink on some directories in $gtmroutines
# NOTE: If more than three directories are put in $gtmroutines constructed by set_gtmroutines.csh, the below logic needs to be updated.
if !($?gtm_test_autorelink_dirs) then
	if (5 >= $randnumbers[31]) then
		setenv gtm_test_autorelink_dirs "1"
	else
		setenv gtm_test_autorelink_dirs "0"
	endif
	if (5 >= $randnumbers[32]) then
		setenv gtm_test_autorelink_dirs "${gtm_test_autorelink_dirs}1"
	else
		setenv gtm_test_autorelink_dirs "${gtm_test_autorelink_dirs}0"
	endif
	echo "# gtm_test_autorelink_dirs enabled thusly by do_random_settings.csh:"							>>&! $settingsfile
	echo "setenv gtm_test_autorelink_dirs $gtm_test_autorelink_dirs"								>>&! $settingsfile
else
	set gtm_test_autorelink_dirs_in = "$gtm_test_autorelink_dirs"
	if (0 == "$gtm_test_autorelink_dirs") then
		setenv gtm_test_autorelink_dirs "00"
	else if (1 == "$gtm_test_autorelink_dirs") then
		setenv gtm_test_autorelink_dirs "11"
	endif
	echo "# gtm_test_autorelink_dirs was already set ($gtm_test_autorelink_dirs_in) before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_autorelink_dirs $gtm_test_autorelink_dirs"								>>&! $settingsfile
endif
# Reset the gtmroutines value based on the gtm_chset value chosen.
if ($?gtm_chset) then
	if ("UTF-8" == $gtm_chset) then
		source $gtm_tst/com/set_gtmroutines.csh "UTF8"
	else
		source $gtm_tst/com/set_gtmroutines.csh "M"
	endif
else
	# If gtm_chset is not set, gtmroutines should point to the M objects/sources and not UTF-8.
	source $gtm_tst/com/set_gtmroutines.csh "M"
endif

setenv tst_random_all "$tst_random_all gtm_test_autorelink_dirs"

###########################################################################
### Random option - 33 ### Randomly enable autorelink retainment of rtnobj memory - setenv gtm_autorelink_keeprtn {0,1}
#
# Do this if gtm_autorelink_keeprtn is not already passed to gtmtest.csh
if !($?gtm_autorelink_keeprtn) then
	if (5 >= $randnumbers[34]) then
		setenv gtm_autorelink_keeprtn `$gtm_exe/mumps -run gen^randbool 1`
		# Log the value in settings.csh
		echo "# gtm_autorelink_keeprtn set by do_random_settings.csh"					>>&! $settingsfile
		echo "setenv gtm_autorelink_keeprtn $gtm_autorelink_keeprtn"					>>&! $settingsfile
	else
		if (3 >= $randnumbers[34]) then
			setenv gtm_autorelink_keeprtn `$gtm_exe/mumps -run gen^randbool 0`
			# Log the value in settings.csh
			echo "# gtm_autorelink_keeprtn set by do_random_settings.csh"				>>&! $settingsfile
			echo "setenv gtm_autorelink_keeprtn $gtm_autorelink_keeprtn"				>>&! $settingsfile
		else
			echo "# gtm_autorelink_keeprtn chosen to be UNDEFINED by do_random_settings.csh"	>>&! $settingsfile
			echo "unsetenv gtm_autorelink_keeprtn"							>>&! $settingsfile
		endif
	endif
else
	echo "# gtm_autorelink_keeprtn was already set before coming into do_random_settings.csh"		>>&! $settingsfile
	echo "setenv gtm_autorelink_keeprtn $gtm_autorelink_keeprtn"						>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_autorelink_keeprtn"

###########################################################################
### Random option - 34 ### Randomly enable poollimit - setenv gtm_poollimit <n>[%]
#
# Do this if gtm_poollimit is not already passed to gtmtest.csh
if !($?gtm_poollimit) then
	# Set it to be a percentage value (instead of number of buffers) half the time
	if ( $randnumbers[35] % 2 ) then
		set pct = "%"
		# maximum allowed value for poollimit is 50%, minimum - 4%
		set poollimit = `date | $tst_awk '{srand () ; print (4 + int (rand () * 47))}'`
	else
		set pct = ""
		# maximum allowed value for poollimit is 512, minimum - 32.
		set poollimit = `date | $tst_awk '{srand () ; print (32 + int (rand () * 481))}'`
	endif
	if (5 >= $randnumbers[35]) then
		# Log the value in settings.csh
		echo "# gtm_poollimit set by do_random_settings.csh"				>>&! $settingsfile
		echo "setenv gtm_poollimit ${poollimit}${pct}"					>>&! $settingsfile
		setenv gtm_poollimit ${poollimit}${pct}
	else
		echo "# gtm_poollimit chosen to be UNDEFINED by do_random_settings.csh"		>>&! $settingsfile
		echo "unsetenv gtm_poollimit"							>>&! $settingsfile
		unsetenv gtm_poollimit
	endif
else
	echo "# gtm_poollimit was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	if ("-0" == "$gtm_poollimit") then
		# If -0 is passed to an environment variable, it signals unsetenv the variable
		unsetenv gtm_poollimit
		echo "unsetenv gtm_poollimit"							>>&! $settingsfile
	else
		echo "setenv gtm_poollimit $gtm_poollimit"						>>&! $settingsfile
	endif
endif
setenv tst_random_all "$tst_random_all gtm_poollimit"

###########################################################################
### Random option - 36 ### Randomly enable gtm_test_passcurlvn
#
# Do this if gtm_test_passcurlvn is not already passed to gtmtest.csh
if !($?gtm_test_passcurlvn) then
	if (5 >= $randnumbers[36]) then
		setenv gtm_test_passcurlvn 0
	else
		setenv gtm_test_passcurlvn 1
	endif
	echo "# gtm_test_passcurlvn set by do_random_settings.csh"					>>&! $settingsfile
	echo "setenv gtm_test_passcurlvn $gtm_test_passcurlvn"						>>&! $settingsfile
else
	echo "# gtm_test_passcurlvn was already set before coming into do_random_settings.csh"		>>&! $settingsfile
	echo "setenv gtm_test_passcurlvn $gtm_test_passcurlvn"						>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_passcurlvn"

###########################################################################
### Random option - 37 ### Randomly enable gtm_test_defer_allocate
#
# Do this if gtm_test_defer_allocate is not already passed to gtmtest.csh
if !($?gtm_test_defer_allocate) then
	if (5 >= $randnumbers[37]) then
		setenv gtm_test_defer_allocate 0
	else
		setenv gtm_test_defer_allocate 1
	endif
	# Always defer allocation on jackal and tuatara due to GTM-8344
	if ($shorthost =~ {jackal,tuatara}) then
		setenv gtm_test_defer_allocate 1
	endif
	echo "# gtm_test_defer_allocate set by do_random_settings.csh"					>>&! $settingsfile
	echo "setenv gtm_test_defer_allocate $gtm_test_defer_allocate"					>>&! $settingsfile
else
	echo "# gtm_test_defer_allocate was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_defer_allocate $gtm_test_defer_allocate"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_defer_allocate"
###########################################################################

###########################################################################
### Random option - 38 ### Randomly enable gtm_test_epoch_taper
#
# Do this if gtm_test_epoch_taper is not already passed to gtmtest.csh
if !($?gtm_test_epoch_taper) then
	if (2 >= $randnumbers[38]) then
		setenv gtm_test_epoch_taper 0
	else
		setenv gtm_test_epoch_taper 1
	endif
	echo "# gtm_test_epoch_taper set by do_random_settings.csh"					>>&! $settingsfile
	echo "setenv gtm_test_epoch_taper $gtm_test_epoch_taper"					>>&! $settingsfile
else
	echo "# gtm_test_epoch_taper was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_epoch_taper $gtm_test_epoch_taper"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_epoch_taper"
###########################################################################

###########################################################################
### Random option - 40 ### Randomly enable update helpers
#
# Do this if gtm_test_updhelpers is not already passed to gtmtest.csh
if !($?gtm_test_updhelpers) then
	if (5 >= $randnumbers[40]) then
		setenv gtm_test_updhelpers 0
	else
		set helpers = `date | $tst_awk '{srand () ; print (int (rand () * maxhelpers) + 1)}' maxhelpers=8`
		set readers = `date | $tst_awk '{srand () ; print (int (rand () * helpers))}' helpers=${helpers}`
		setenv gtm_test_updhelpers "${helpers},${readers}"
		unset helpers readers
	endif
	echo "# gtm_test_updhelpers set by do_random_settings.csh"				>>&! $settingsfile
	echo "setenv gtm_test_updhelpers $gtm_test_updhelpers"					>>&! $settingsfile
else
	echo "# gtm_test_updhelpers was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_updhelpers $gtm_test_updhelpers"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_updhelpers"
###########################################################################

###########################################################################
### Random option - 41 ### Randomly enable forward rollback (whenever backward rollback is done)
#
# Do this if gtm_test_forward_rollback is not already passed to gtmtest.csh
if !($?gtm_test_forward_rollback) then
	if (5 >= $randnumbers[41]) then
		setenv gtm_test_forward_rollback 0
	else
		setenv gtm_test_forward_rollback 1
	endif
	echo "# gtm_test_forward_rollback set by do_random_settings.csh"			>>&! $settingsfile
	echo "setenv gtm_test_forward_rollback $gtm_test_forward_rollback"			>>&! $settingsfile
else
	echo "# gtm_test_forward_rollback was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_forward_rollback $gtm_test_forward_rollback"				>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_forward_rollback"
###########################################################################

###########################################################################
### Random option - 42 ### Randomly enable multiple threads/processes in mupip journal recover/rollback
# Uses randnumbers[42]
if !($?gtm_mupjnl_parallel) then
	set nthreads = $randnumbers[42]
	if (1 == $nthreads) then
		unsetenv gtm_mupjnl_parallel
		echo "# gtm_mupjnl_parallel chosen to be UNDEFINED by do_random_settings.csh"	>>&! $settingsfile
		echo "unsetenv gtm_mupjnl_parallel"						>>&! $settingsfile
	else
		set nthreads = `expr $nthreads - 2`
		setenv gtm_mupjnl_parallel ${nthreads}
		echo "# gtm_mupjnl_parallel set by do_random_settings.csh"			>>&! $settingsfile
		echo "setenv gtm_mupjnl_parallel $gtm_mupjnl_parallel"				>>&! $settingsfile
	endif
else
	echo "# gtm_mupjnl_parallel was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_mupjnl_parallel $gtm_mupjnl_parallel"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_mupjnl_parallel"
###########################################################################

###########################################################################
### Random option - 44 ### Randomly enable periodic forced journal overflow due to a simulated pool/record accounting sync problem
if !($?gtm_test_jnlpool_sync) then
	if ((1 != $gtm_test_jnlfileonly) && (2 >= $randnumbers[44])) then
		setenv gtm_test_jnlpool_sync `$tst_awk 'BEGIN {srand () ; print (5000 + int (rand () * 20000))}'`
	endif
	if ($?gtm_test_jnlpool_sync) then
		echo "# gtm_test_jnlpool_sync set by do_random_settings.csh"				>>&! $settingsfile
		echo "setenv gtm_test_jnlpool_sync $gtm_test_jnlpool_sync"				>>&! $settingsfile
	else
		echo "# gtm_test_jnlpool_sync chosen to be UNDEFINED by do_random_settings.csh"		>>&! $settingsfile
		echo "unsetenv gtm_test_jnlpool_sync"							>>&! $settingsfile
	endif
else
	echo "# gtm_test_jnlpool_sync was already set before coming into do_random_settings.csh"	>>&! $settingsfile
	echo "setenv gtm_test_jnlpool_sync $gtm_test_jnlpool_sync"					>>&! $settingsfile
endif
setenv tst_random_all "$tst_random_all gtm_test_jnlpool_sync"
###########################################################################

###########################################################################
### Random option - 45 ### Randomly enable lock hash collisions in dbg code
#
# Note: This option is currently not enabled in the test framework. Details below.
#
# 1) YDB#297 fixed various failures/hangs in the GT.M LOCK commands. As part of a test for that
#    commit 5859cdb0 exercised a dbg-only env var ydb_lockhash_n_bits which induced lock collisions
#    in the E_ALL. And verified all tests ran fine without issues even with randomly induced collisions.
# 2) But as part of YDB#673, we decided to revert YDB#297 as GT.M V6.3-009 was merged at that point in
#    time and it had come up with a different way to address lock collisions. The different way made it
#    almost impossible to encounter indefinite collision overflows in practice even though it left open
#    the theoretical possibility of that like prior GT.M versions.
# 3) This meant that YottaDB no longer addressed the theoretical possibility of lock collision overflows
#    like it did previously with the YDB#297 fixes.
# 4) Therefore, enabling ydb_lockhash_n_bits (induces collision overflows a lot more frequently) can cause
#    test failures/hangs. And hence we unfortunately need to disable this env var.
#
# Uses randnumbers[45]
set nbits = $randnumbers[45]
unsetenv ydb_lockhash_n_bits
echo "# ydb_lockhash_n_bits chosen to be UNDEFINED by do_random_settings.csh due to YDB#673's revert of YDB#297" >>&! $settingsfile
echo "unsetenv ydb_lockhash_n_bits"						>>&! $settingsfile
setenv tst_random_all "$tst_random_all ydb_lockhash_n_bits"
###########################################################################

###########################################################################
### Random option - 46 ### Randomly enable gtm_test_asyncio 30% of the time
#
# Do this if gtm_test_asyncio is not already passed to gtmtest.csh
if !($?gtm_test_asyncio) then
	if (6 >= $randnumbers[46]) then
		setenv gtm_test_asyncio 0
	else
		setenv gtm_test_asyncio 1
	endif
	echo "# gtm_test_asyncio set by do_random_settings.csh"					>>&! $settingsfile
else
	echo "# gtm_test_asyncio was already set before coming into do_random_settings.csh"	>>&! $settingsfile
endif
if ("MM" == "$acc_meth") then
	echo "# gtm_test_asyncio is forced to 0 since acc_meth is MM"	>>&! $settingsfile
	setenv gtm_test_asyncio 0
else if ($gtm_test_asyncio) then
	echo "# ASYNCIO and V4 format don't go together. So, disable creating V4 formats"	>>&! $settingsfile
	setenv gtm_test_mupip_set_version "disable"
	echo "setenv gtm_test_mupip_set_version $gtm_test_mupip_set_version"			>>&! $settingsfile
endif
echo "setenv gtm_test_asyncio $gtm_test_asyncio"						>>&! $settingsfile

setenv tst_random_all "$tst_random_all gtm_test_asyncio"
###########################################################################

# For any change to tst_random_all, a corresponding change is required in log_report.awk, to show in final report
echo "########### End do_random_settings.csh random settings ############"			>>&! $settingsfile
echo "setenv tst_random_all '$tst_random_all'"							>>&! $settingsfile
echo "###################################################################"			>>&! $settingsfile
