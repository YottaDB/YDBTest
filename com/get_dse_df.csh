#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set msg = "$1"
if ("$2" == "newlog") then
	echo "Current Time:`date +%H:%M:%S`"	>&!  dse_df.log
else
	echo "Current Time:`date +%H:%M:%S`"	>>&! dse_df.log
endif
echo $msg 					>>&  dse_df.log
$DSE all -dump -all				>>&! dse_df.log
