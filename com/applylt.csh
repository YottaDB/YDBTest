#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# applylt.csh <file_name> <1/0>
#
# Apply loss transaction
# -losttncomplete is run if the second argument is 1
if ($1 == "") then
	echo "No file name found for lost transactions!"
	exit 1
endif

$GTM << xyz
do ^umjrnl("$1")
h
xyz

if ("1" == "$2") then
	$MUPIP replic -source -losttncomplete
endif
