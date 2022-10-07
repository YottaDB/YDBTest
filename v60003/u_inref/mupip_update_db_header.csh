#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#                                                               #
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#################################################################################
# This test verifies that journaling-related fields in the database file header #
# are not updated by MUPIP SET -JOURNAL if the commands does not succeed.       #
#################################################################################

# Because this test uses prior versions that may not handle large alignsize values, remove the alignsize part.
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`

# Disable unicode if ICU >= 4.4 is detected, since support for it started with V54002, and this test may choose an older version.
if (($?gtm_chset) && ($?gtm_icu_version)) then
	if (("UTF-8" == $gtm_chset) && (1 == `echo "if ($gtm_tst_icu_numeric_version >= 44) 1" | bc`)) then
		set save_chset = $gtm_chset
		$switch_chset "M" >&! switch_chset1.out
	endif
endif

# Also disable triggers to avoid complications with previous versions.
setenv gtm_test_trigger 0

if ($?gtm_test_replay) then
	set prior_ver = `echo $gtm_test_rand_prior_ver`
else
	# Pick a random version that is upgradable to the current one, but has lower journaling-related limits.
	$gtm_tst/com/random_ver.csh -gte V50000 -lt V55000 >&! prior_ver.txt
	if (0 != $status) then
		echo "TEST-E-FAIL, No prior versions available."
		exit
	else
		set prior_ver = `cat prior_ver.txt`
	endif
	echo "setenv gtm_test_rand_prior_ver $prior_ver" >> settings.csh
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
source $gtm_tst/com/ydb_temporary_disable.csh

# Switch to the chosen old version.
source $gtm_tst/com/switch_gtm_version.csh $prior_ver pro

# Create a database, enable journaling, and save the database header dump.
\rm -f *.o >& rm1.out	# remove .o files created by current version (in case the format is different)
$gtm_tst/com/dbcreate.csh mumps >&! db_create.out
$gtm_dist/mupip set $tst_jnl_str -reg DEFAULT >&! mupip_set_jnl1.out
$gtm_dist/dse dump -f >&! dse_dump1.txt

# Switch back to the current version.
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# If a prior version was initially selected, create_key_file.csh would have skipped this step.
if ("$test_encryption" == "ENCRYPT") then
	if (-f $gtm_dbkeys) then
		$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
	else
		unsetenv gtm_passwd
		unsetenv gtmcrypt_config
	endif
endif

# Update the database, attempt to enable journaling, and save the database header dump.
$gtm_dist/mumps -run GDE exit >&! gde_exit.out
$gtm_dist/mupip set $tst_jnl_str -reg DEFAULT >&! mupip_set_jnl2.out
$gtm_dist/dse dump -f >&! dse_dump2.txt

# Enabling journaling should have failed due to an existing journal file. Check that.
$gtm_tst/com/check_error_exist.csh mupip_set_jnl2.out FILEEXISTS JNLNOCREATE MUNOFINISH

# Define an alias for easier retrieval of various database header fields.
alias extract_field 'echo \!:1 | $tst_awk -F \!:2 '"'"'{print $2}'"'"' | $tst_awk '"'"'{print $1}'"'"

# Record the old version's journaling-related values.
set journal_lines = `$grep -E "Journal (Allocation|Extension|Alignsize|Buffer Size)" dse_dump1.txt`
set old_allocation = `extract_field $journal_lines "Journal Allocation"`
set old_extension = `extract_field $journal_lines "Journal Extension"`
set old_buffer_size = `extract_field $journal_lines "Journal Buffer Size"`
set old_alignsize = `extract_field $journal_lines "Journal Alignize"`

# Record the current version's journaling-related values.
set journal_lines = `$grep Journal dse_dump2.txt | $grep -E "Allocation|Extension|Alignsize|Buffer Size"`
set new_allocation = `extract_field $journal_lines "Journal Allocation"`
set new_extension = `extract_field $journal_lines "Journal Extension"`
set new_buffer_size = `extract_field $journal_lines "Journal Buffer Size"`
set new_alignsize = `extract_field $journal_lines "Journal Alignize"`

# Ensure that allocation, extension, and align size did not get updated while buffer size did.
if (($old_allocation != $new_allocation) 	\
	|| ($old_extension != $new_extension)	\
	|| ($old_alignsize != $new_alignsize)	\
	|| ($old_buffer_size == $new_buffer_size)) then
	echo "TEST-E-FAIL, Journaling-related fields updated incorrectly in the DB file header."
else
	echo "TEST-I-SUCCESS, Journaling-related fields updated correctly in the DB file header."
endif

# Verify that the database is OK.
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
