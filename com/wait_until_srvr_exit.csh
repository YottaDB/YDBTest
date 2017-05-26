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

# A tool to wait until the passed server type exits (exits immediately if the server doesn't exist - no error thrown)
# usage :
# $gtm_tst/com/wait_until_srvr_exit.csh <src|rcvr|updproc|passive> [secondary_instance_name]

set srvrtype = $1
set instsecondary = "$2"

set srvrpids = `$gtm_tst/com/get_pid.csh $srvrtype $instsecondary`

foreach pid ($srvrpids)
	$gtm_tst/com/wait_for_proc_to_die.csh $pid
end
