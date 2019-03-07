#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# gtm_test_spanreg = Decimal 0 = Binary 00 => Do NOT use existing .sprgde files; Do NOT generate .sprgde files
# gtm_test_spanreg = Decimal 1 = Binary 01 => Do     use existing .sprgde files; Do NOT generate .sprgde files
# gtm_test_spanreg = Decimal 2 = Binary 10 => Do NOT use existing .sprgde files; Do     generate .sprgde files
# gtm_test_spanreg = Decimal 3 = Binary 11 => Do     use existing .sprgde files; Do     generate .sprgde files

# Attempt to generate .sprgde files.

if (! ((2 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) || ("GT.CM" == $test_gtm_gtcm)) then
	exit 0	# test did not want .sprgde files to be generated
endif
#
# In case of a secondary instance (in a MSR test or a non-MSR replic test) that is using the same gtm_test_sprgde_id
# as the primary instance, skip sprgde file generation on the secondary instances.
#
if ("$PWD" != "$tst_working_dir") then
	# we are not in the primary side
	set gensprgde = 0
	if ($?gtm_test_sec_sprgde_id_different) then
		if ($gtm_test_sec_sprgde_id_different) then
			set gensprgde = 1 # Generate sprgde file in case secondary has different sprgde_id
		endif
	endif
else
	# we are in primary side
	set gensprgde = 1
endif
if (! $gensprgde) then
	exit 0	# we are on secondary and secondary does not have different sprgde file (compared to primary)
		# since we will generate sprgde file during primary dbcheck_base invocation, skip this duplicate sprgde generation
endif

# Skip sprgde file generation/use for versions prior to V61000
if ( `expr "V61000" ">" $gtm_verno` ) then
	exit
endif

source $gtm_tst/com/findsprgdefilename.csh	# sets the var "sprgdeoutdir" and "sprgdefile" accordingly

if (! -e $sprgdeoutdir) then
	mkdir -p $sprgdeoutdir
	if ($status) then
		# Directory does not exist but we are not able to create it. Exit.
		exit 0
	endif
endif

# If there is no write permission in the target directory, exit
# (can happen with non-gtmtest user running T990 with gtm_test_spanreg=2/3)
if (! -w $sprgdeoutdir:h) then
	exit 0
endif

if (! -e $sprgdeoutdir) then
	mkdir -p $sprgdeoutdir
endif

unsetenv gtmdbglvl	# or else we will get Malloc dumps due to the "mumps -run" invocations
unsetenv gtm_local_collate	# to ensure "collkey" variable contents in gensprgde.m are not confused by this
$gtm_exe/mumps -run gensprgde >! tmp.sprgde
if ($status) then
	echo "TEST-E-GENSPRGDE : Error generating tmp.sprgde. See failed_${sprgdefile} for details"
	mv tmp.sprgde failed_$sprgdefile
	exit -1
endif
# temporarily set gtmgbldir to a dummy gbldir for the below GDE commands to execute without OBJDUP errors
setenv gtmgbldir tmp.sprgde.gld
unsetenv ydb_app_ensures_isolation	# or else we could get ZGBLDIRACC errors on non-existent gld file (tmp.sprgde.gld)
$tst_awk '/change -region .* -std/ {regs[$3]++} END {for (reg in regs) {if (reg != "DEFAULT") {print "add -region "reg" -dyn="reg}}}' tmp.sprgde >&! tmp.sprgde2
if (! -z tmp.sprgde2) then
	$GDE << GDE_EOF >&! tmp.sprgde.out
		@tmp.sprgde2
		@tmp.sprgde
		quit
GDE_EOF

	$grep -q "GDE-E-" tmp.sprgde.out
	if (0 == $status) then
		echo "TEST-E-USESPRGDE : Error using tmp.sprgde. See failed_$sprgdefile and below for errors"
		mv tmp.sprgde failed_$sprgdefile
		$grep "GDE-E-" tmp.sprgde.out
		exit -1
	endif
endif
rm -f gensprgde.o	# remove .o file in case this additional file causes test failures
if (! -z tmp.sprgde) then
	if (! -e $sprgdefile) then
		cp -f tmp.sprgde $sprgdefile
		cp -f tmp.sprgde $sprgdeoutdir/$sprgdefile
	else
		echo "TEST-E-SPRGDEEXISTS : Not overwriting $sprgdefile"
		exit -1
	endif
else
	if (-e $sprgdeoutdir/$sprgdefile) then
		rm -f $sprgdeoutdir/$sprgdefile
	endif
endif
exit 0
