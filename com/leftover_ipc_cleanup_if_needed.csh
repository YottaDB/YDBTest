#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#
# $1 - name of caller script. printed in log file for debugging purposes
# $2 - "" if rundown -reg "*" needs to be done.
#      if not "", a rundown -file $2 is done.
#
source $gtm_tst/com/can_ipcs_be_leftover.csh
if (! $status) then
	exit
endif

set opts = "-override -cleanjnl"
set outfile = "leftover_ipc_cleanup_if_needed.out"
echo "# `date` : caller : $1"						>>! $outfile
if ($2 == "") then
	if ($?gtm_repl_instance) then
		# Check if replication instance file exists.
		# If it does not, unsetenv gtm_repl_instance to avoid FTOKERR from below
		if (! -e $gtm_repl_instance) then
			set save_gtm_repl_instance = $gtm_repl_instance
			unsetenv gtm_repl_instance
		endif
	endif
	echo "# doing explicit rundown : rundown -reg '*' $opts"	>>! $outfile
	source $gtm_tst/com/mupip_rundown_handle_ftok_collision.csh -reg "*" $opts >>& $outfile
	if ($?save_gtm_repl_instance) then
		setenv gtm_repl_instance $save_gtm_repl_instance
	endif
else
	echo "# doing explicit rundown : rundown -file $2 $opts"	>>! $outfile
	source $gtm_tst/com/mupip_rundown_handle_ftok_collision.csh -file $2 $opts >>& $outfile
endif
