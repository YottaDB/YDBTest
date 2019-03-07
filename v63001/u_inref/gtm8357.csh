#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "-------------------------------------------------------------------------------------------------------------------------"
echo "Release Note being tested:"
echo "-------------------------------------------------------------------------------------------------------------------------"
echo '(GTM-8357) : GT.M takes the initial value of $ZSTEP from the environment variable $gtm_zstep, with a default value of "B"'
echo '(a BREAK command) if $gtm_zstep is not defined; previously, changing the default value required a SET command.'
echo "-------------------------------------------------------------------------------------------------------------------------"
echo ""
echo '# Tests that setting the value of $ydb_zstep or $gtm_zstep will change the value of $ZSTEP instead of defaulting to "B"'
echo '# Set the value of $ydb_zstep or $gtm_zstep to "; comment"'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zstep gtm_zstep "; comment"

echo '# Enter mumps and write the value of $ZSTEP'

$ydb_dist/mumps -run gtm8357

echo '# Set the value of $ydb_zstep or $gtm_zstep to "G", which is invalid M code and should get YDB-E-SPOREOL and YDB-I-TEXT errors.'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zstep gtm_zstep "G"

echo '# Enter mumps and write the value of $ZSTEP'

$ydb_dist/mumps -run gtm8357
