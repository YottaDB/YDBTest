#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

foreach effect ( 1 2 )
        source $gtm_tst/com/set_ydb_env_var_random.csh ydb_side_effects gtm_side_effects $effect
        echo " --> Test with ydb_side_effects env var set to $effect"
	$ydb_dist/yottadb -run gtm9123
end
