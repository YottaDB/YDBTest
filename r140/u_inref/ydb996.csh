#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

source $gtm_tst/com/portno_acquire.csh >>& portno.out	# portno env var will be set to the alloted portno
$ydb_dist/yottadb -run ydb996
$gtm_tst/com/portno_release.csh	# Release the portno allocated above by portno_acquire.csh

