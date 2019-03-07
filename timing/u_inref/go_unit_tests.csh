#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
# In this subtest, we run the go/unit_tests subtests but with timing tests enabled.
# That is taken care of by the below script in the "go" test so we source it directly.
source $gtm_tst/go/u_inref/unit_tests.csh
