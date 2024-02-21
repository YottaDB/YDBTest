#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# ---------------------------------------------------------------------------------------------------------------'
echo '# Test that TSTART after set of $ZMAXTPTIME to random negative value does not assert fail (test of YDB@dcba3d9b).'
echo '# Also test that SET $ZMAXTPTIME to a random negative value sets it to a value of 0 (test of YDB@745fa769).'
echo '# ---------------------------------------------------------------------------------------------------------------'

# Set a random negative number
set randneg = `$gtm_exe/mumps -run %XCMD 'write -1-$random(2**20)'`

# Create database (needed for TSTART)
$gtm_tst/com/dbcreate.csh mumps
echo '# Expect to see $ZMAXTPTIME=0 (and not a negative value) below'
$gtm_exe/mumps -run %XCMD 'set $zmaxtptime='$randneg' tstart ():serial  tcommit  zwrite $zmaxtptime'

echo '# Also test that negative values of gtm_zmaxtptime/ydb_maxtptime env var is treated as 0 (test of pre-existing behavior)'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_maxtptime gtm_zmaxtptime $randneg
$gtm_exe/mumps -run %XCMD 'zwrite $zmaxtptime'

$gtm_tst/com/dbcheck.csh mumps

