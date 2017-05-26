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

# This is a helper script that randomly makes a test run in multihost(NON-MSR-framework) or multisite(MSR-framework)
# Do it by having a list of multi-host enabled tests and multi-site enabled tests (the framework treats them differently for now)

# If $gtm_test_nomultihost is set or if it is a non-replic test do not randomize multi-host
if ( ($?gtm_test_nomultihost) || (! $?test_replic) ) then
	setenv test_replic_mh_type 0
	exit
endif

if ("2WL" == "$gtm_server_location") then
	setenv gtmtest_noxendian 1
endif

set msr_tests          = " msreplic_A msreplic_B msreplic_C msreplic_D msreplic_E msreplic_F msreplic_G msreplic_H"
set msr_tests          = "$msr_tests suppl_inst_A suppl_inst_B suppl_inst_C suppl_inst_D dualfail_ms "

set mh_se_always_tests = " tcp_bkup "
set mh_oe_always_tests = " endiancvt "
set mh_always_tests    = ""
set mh_se_rand_tests   = ""
set mh_rand_tests      = " dual_fail filter "

if ($?test_replic_mh_type) then
	# If test_replic_mh_type is already set, just set the MULTISITE values if it is msr_test
	echo "# test_replic_mh_type was already set before coming into do_random_multihost.csh"	>>&! $settingsfile
	if ( ( "$msr_tests" =~ "* $tst *" ) && (0 != $test_replic_mh_type)) then
		setenv test_replic MULTISITE
		setenv test_repl   MULTISITE	# SUSPEND/ALLOW filter relies on test_repl variable - not test_replic
	endif
	exit
endif
set rand = `date | $tst_awk '{srand() ; print (int(rand() * 20))}'`
# If it is time to randomize, let the default be single-host replication
setenv test_replic_mh_type 0
if ( "$msr_tests" =~ "* $tst *" ) then
	# Do MultiSite with 10% probability and if so XENDIAN 50% of the times
	if (1 >= $rand) then
		setenv test_replic MULTISITE
		setenv test_repl   MULTISITE	# SUSPEND/ALLOW filter relies on test_repl variable - not test_replic
		setenv test_replic_mh_type 1
		if ( (0 >= $rand) && (! $?gtmtest_noxendian) ) then
			setenv test_replic_mh_type 2
		endif
	endif
else if ( "$mh_se_always_tests" =~ "* $tst *" ) then
	setenv test_replic_mh_type 1
else if ( "$mh_oe_always_tests" =~ "* $tst *" ) then
	setenv test_replic_mh_type 2
else if ( "$mh_always_tests" =~ "* $tst *" ) then
	# do multi-host always with 50/50 probability of same-endian and xendian
	setenv test_replic_mh_type 1
	if ( (10 > $rand) && (! $?gtmtest_noxendian) ) then
		setenv test_replic_mh_type 2
	endif
else if ( "$mh_se_rand_tests" =~ "* $tst *" ) then
	# Do a multi-host-same-endian with 10% probability
	if (1 >= $rand) then
		setenv test_replic_mh_type 1
	endif
else if ( "$mh_rand_tests" =~ "* $tst *" ) then
	# do a multi-host-same-endian with 5% probability and multi-host-xendian with 5% probability
	if (0 >= $rand) then
		setenv test_replic_mh_type 1
	else if (1 >= $rand) then
		if (! $?gtmtest_noxendian) setenv test_replic_mh_type 2
	endif
endif

unset rand
