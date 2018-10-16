#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "-------------------------------------------------------------------------------------"
echo "# Test that invoking ydb_env_set does not reset gtm_prompt if ydb_prompt is undefined"
echo "-------------------------------------------------------------------------------------"
echo ""
echo "# Define gtm_prompt"
export gtm_prompt="test"
echo "gtm_prompt: $gtm_prompt"

echo ""
echo "# invoke ydb_env_set"
. $ydb_dist/ydb_env_set
echo '. $ydb_dist/ydb_env_set'

echo ""
echo "# test that gtm_prompt remains unchanged"
echo "gtm_prompt: $gtm_prompt"
