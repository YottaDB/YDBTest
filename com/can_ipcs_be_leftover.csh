#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Only DBG images honor gtm_db_counter_sem_incr. With PRO, leftover ipcs are not therefore possible.
if ("pro" == "$gtm_exe:t") then
	exit 0
endif
if (! $?gtm_db_counter_sem_incr) then
	exit 0
endif
if (1 == $gtm_db_counter_sem_incr) then
	exit 0
endif
# If current version is < V63000, then leftover ipcs are not possible (since gtm_db_counter_sem_incr is not honored there).
if (`expr "V63000" \> "$gtm_verno"`) then
	exit 0
endif

exit 1
