#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# do a mean thing to a database to see that DSE keeps reporting the appropriate key
setenv gtm_test_disable_randomdbtn 1
$gtm_tst/com/dbcreate.csh -block_size=1024 -key_size=64
$GTM << GTM_EOF
        set ^x=1,^y=1
GTM_EOF
$DSE << DSE_EOF >& dsedmp.out
        overwrite -block=5 -offset=12 -data=\ba
        overwrite -block=5 -offset=14 -data=\bb
        dump -bl=5
        dump -bl=3
        dump -bl=5
DSE_EOF
$tst_awk -f $gtm_tst/com/dse_filter_header.awk dsedmp.out
# no dbcheck.csh because we intentionally damaged the database
