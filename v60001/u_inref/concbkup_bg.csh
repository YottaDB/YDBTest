#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

@ count = 1
mkdir backup_bg
@ max_conc_bkups = 1000
while ( $count <= $max_conc_bkups )
	rm backup_bg/* >&! delete_bg.log
	$MUPIP backup "*" backup_bg/ >&! backup_bg_$count.logx
	$grep "BKUPRUNNING" backup_bg_$count.logx
	if ( 0 == $status ) then
		touch STOP
		break
	else if (-e STOP) then
		break
	endif
	if ( 1000 == $count ) then
		break
	endif
	@ count = $count + 1
end
