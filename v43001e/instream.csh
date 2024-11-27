#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# ------------------------------------------------------------------------------
# for stuff fixed in V43001E
# ------------------------------------------------------------------------------
# C9C12002186 [Narayanan] - Fixed-length patterns to zwrite and zsearch assert fail in do_pattern.c line 81
# C9D01002209 [Narayanan] - LOCK should accept extended reference syntax for nrefs in the form of locals
# D9B07001911 [Narayanan] - Database backed up by online backup should not have integrity errors
# C9C11002163 [Mohammad]  - Socket listener on port 0 does not set the actual port assigned to $key
# D9D01002285 [Narayanan] - ZSTEP OVER does transfer control to the correct M statement
# D9C03002051 [Mohammad]  - Mupip set -extension_count and standalone access
# D9D01002286 [Malli]     - File syntax error when $ZRO is changed within M program
# D9C04002091 [Nars]      - JOB environment leak
# C9C11002184 [Nergis]    - malloc core while changing local collation
# D9I06002687 [kishore]   - TCP Read uses lots of CPU (The actual test is within C9C11002163 test script)
#-----------------------------------------------------------------------------

echo "v43001e test starts..."
#

if ($?test_replic == 1) then
	# replic tests
	setenv subtest_list ""
else
	# non replic tests
	setenv subtest_list "C9C12002186 C9D01002209 D9B07001911 C9C11002163 D9D01002285 D9C03002051"
	setenv subtest_list "$subtest_list D9D01002286 D9C04002091 C9C11002184"
endif

setenv subtest_exclude_list ""

# filter out subtests that cannot pass with MM
# D9B07001911	Tests journal state changes from nobefore to before to off
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list D9B07001911"
endif

if ("ENCRYPT" == "$test_encryption" ) then
	# The below subtest spawns off a lot of processes (2500 of them) and those take a lot of time to finish due
	# to encryption initialization when opening each database region. Therefore disable this subtest if -encrypt.
	setenv subtest_exclude_list "$subtest_exclude_list D9C04002091"
endif

$gtm_tst/com/submit_subtest.csh
echo "v43001e test DONE."
