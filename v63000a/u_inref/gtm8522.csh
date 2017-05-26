#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2016 Fidelity National Information              #
# Services, Inc. and/or its subsidiaries. All rights reserved.  #
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
$gtm_dist/mumps -run gtm8522
