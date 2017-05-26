#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that inability to write to stdout and stderr (induced in this case with a broken pipe), either during
# process start-up or runtime, does not cause nested errors while printing the error.

( echo 1; $gtm_dist/mumps -run %XCMD 'sleep 0.2 write 1/0' ) |& $head -1 > head.out

( echo 1; $gtm_dist/mumps -run %XCMD 'sleep 0.2 write "hey"' ) |& $head -1 >> head.out

setenv gtm_local_collate 1
setenv gtm_collate_1 `pwd`/idonotexist.so
touch a
( echo 1; $gtm_dist/mumps -run a ) |& $head -1 >> head.out

( ls -l core* > list_of_cores.out ) >&! /dev/null

if (-z list_of_cores.out) then
	echo "TEST-I-PASS, Test succeeded."
else
	echo "TEST-E-FAIL, Test failed with the following cores:"
	cat list_of_cores.out
endif
