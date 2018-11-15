#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2016 Fidelity National Information              #
# Services, Inc. and/or its subsidiaries. All rights reserved.  #
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
# GTM-8522 - GT.M needs to correctly handle some pattern specifications with alternations
#
# gtm8522 generates random patterns and we want to know the actual pattern in case of test failures/hangs
# so store them in an output file. But to keep reference file deterministic, grep out just the static components from it.
# Store in .outx (instead of .out) because it is possible randomly generated patterns have "-F-" or "-E-" etc. in them
# which we do not want the test framework from later catching.
$gtm_dist/mumps -run gtm8522 >& gtm8522.outx
$grep gtm8522 gtm8522.outx
