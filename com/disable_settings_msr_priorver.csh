#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a helper script that disables certain randomness for tests that use MSR framework AND prior versions
# By default, ALL the settings that are not expected to work with MSR + priorver is disabled.
# Pass the keywords for the settings that should NOT be changed

# This tool can be enhanced to pass the prior version and let the tool decide which settings to disable based on the version passed

# disable encryption
# This test does not currently handle two important cases for encryption
# 1) need to use the framework switch_gtm_versions.csh, which properly
#    handles encryption, on the remote side
# 2) need to transfer the password to the remote side in an unobfuscated
#    manner because the obfuscated password uses ftok information.
if ( "$*" !~ "*encryption*" ) then
	setenv test_encryption "NON_ENCRYPT"
endif

# disable huge pages setup. switch_gtm_version.csh handles disabling and enabling when versions are switched. MSR framework doesn't source that script
# If 32-bit prior versions are used, LD_PRELOAD pointing to 64bit binaries will fail to load
if ( "$*" !~ "*hugepages*" ) then
	source $gtm_tst/com/disable_hugepages.csh
endif

# Disable gtmcompile, including the -dynamic_literals qualifer, since prior versions complain. See comment in switch_gtm_version.csh
if ( "$*" !~ "*gtmcompile*" ) then
	unsetenv gtmcompile
endif

# Since this test uses MSR framework (which means it will not use switch_gtm_version.csh), we cannot use qdbrundown.
# We can remove this diabling once MSR framework starts sourcing switch_gtm_versions.csh for older versions.
if ( "$*" !~ "*qdbrundown*" ) then
	setenv gtm_test_qdbrundown 0
	setenv gtm_test_qdbrundown_parms ""
	setenv gtm_db_counter_sem_incr 1
endif

# Disable unicode if ICU >= 4.4 is detected, since support for it started with V54002 and this test require an older version.
if ( "$*" !~ "*unicode*" ) then
	$gtm_tst/com/is_icu_new_naming_scheme.csh
	if (0 == $status) $switch_chset M >&! disable_utf8.txt
endif

# This subtest might use an older version, with no support for gtm_poollimit. Hence it should not be set.
if ( "$*" !~ "*gtm_poollimit*" ) then
	setenv gtm_poollimit 0
endif

# This subtest might use an older version, with no support for supplementary. Hence it should always be A->B type
if ( "$*" !~ "*supplinst*" ) then
	setenv test_replic_suppl_type 0
endif

# This subtest might use an older version, with no support for IPv6. Hence it should not use IPv6 addresses
if ( "$*" !~ "*ipv6*" ) then
	setenv test_no_ipv6_ver 1
endif

# The subtest might use versions prior to trigger support. Disable trigger extract comparison
if ( "$*" !~ "*triggers*" ) then
	setenv gtm_test_extr_no_trig 1
endif

# The secondary may not support SSL/TLS
if ( "$*" !~ "*tls*" ) then
	setenv gtm_test_tls FALSE
endif

# versions prior to V62001 does not support spanning regions
if ( "$*" !~ "*spanning_regions*" ) then
	setenv gtm_test_spanreg 0
endif
