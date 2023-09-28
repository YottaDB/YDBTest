#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# damage a block by restoring a bit map over it, then ensure that find -exhaustive can locate it
# in the given case, find without -exhaustive works as well

setenv gtm_test_mupip_set_version "disable"	# Prevent random usage of V4 database as that causes issues with using MM
setenv gtm_test_use_V6_DBs 0	  		# Disable V6 DB mode due to differences in DSE FIND output
$gtm_tst/com/dbcreate.csh mumps -block_size=1024
$gtm_dist/mumps -run \%XCMD "for i=1:1:100000 set ^x(i)=i"	# generate some full blocks
$DSE << DSE_EOF
save -block=1b9
save -block=0
restore -block=1b9 -from=0
find -block=1b9 -exhaustive
find -block=1b9
restore -block=1b9
DSE_EOF
$gtm_tst/com/dbcheck.csh

