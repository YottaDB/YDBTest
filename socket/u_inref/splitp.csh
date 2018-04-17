#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014, 2015 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test mumps JOBs with different sockets on stdin and stdout

source $gtm_tst/com/unset_ydb_env_var.csh ydb_ipv4_only	gtm_ipv4_only	# The test explicitly does IPv6, if the host supports it.

source $gtm_tst/com/portno_acquire.csh > portno1.out
@ portno1=$portno
source $gtm_tst/com/portno_acquire.csh > portno2.out
@ portno2=$portno
source $gtm_tst/com/portno_acquire.csh > portno3.out
@ portno3=$portno
source $gtm_tst/com/portno_acquire.csh > portno4.out
@ portno4=$portno

echo "Starting splitp"
$gtm_exe/mumps -run '%XCMD' "do ^splitp(${portno1},${portno2},${portno3},${portno4})"
echo "Done"

cp portno1.out portno.out
source $gtm_tst/com/portno_release.csh
cp portno2.out portno.out
source $gtm_tst/com/portno_release.csh
cp portno3.out portno.out
source $gtm_tst/com/portno_release.csh
cp portno4.out portno.out
source $gtm_tst/com/portno_release.csh
