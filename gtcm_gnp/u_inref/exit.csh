#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# dbcreate.csh called by locks_two_clients.csh
if ("b" == $1) then
	$rsh $tst_remote_host_2  "$sec_getenv_gtcm; cd $SEC_DIR_GTCM_2; "'$gtm_exe/mumps'" -run releb"
else if ("c" == $1) then
	$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; "'$gtm_exe/mumps'" -run relec"
endif
sleep 10
$gtm_tst/com/dbcheck.csh
