#################################################################
#                                                               #
# Copyright (c) 2018, 2019 YottaDB LLC and/or its subsidiaries. #
# All rights reserved.                                          #
#                                                               #
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#

setenv gtm_test_asyncio 0	# Disable asyncio temporarily. Remove this line once YDB#945 is fixed.

# we need to create a database so that there is a valid .gld file (needed by ydb_env_set)
$gtm_tst/com/dbcreate.csh mumps
# ydb_env_set only works in sh, which is why this csh redirects to ydb197.sh.
sh $gtm_tst/$tst/u_inref/ydb197.sh

$gtm_tst/com/dbcheck.csh
