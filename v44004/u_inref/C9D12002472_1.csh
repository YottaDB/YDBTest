#################################################################
#								#
#	Copyright 2004, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv gtm_test_spanreg 0	# The test prints # of Sets, Block TN numbers etc with and without GVDUPSETNOOP
				# Since the transaction number etc are counted, spanning a global should be avoided
#
if (! $?test_replic) then
	# NON_REPLIC tests:
	$gtm_tst/$tst/u_inref/setnoop_enable_disable.csh
else
	# REPLICATED tests:
	$gtm_tst/$tst/u_inref/setnoop_updproc.csh

endif
