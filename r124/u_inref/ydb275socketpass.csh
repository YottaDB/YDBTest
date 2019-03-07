#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test of #275 : LISTENING sockets can be passed through JOB or WRITE /PASS and WRITE /ACCEPT"

foreach label (socketJobPassListening socketLocalPassListening)
	echo ""
	echo "# --------------------------------------------------------------"
	echo "# Executing : mumps -run $label^ydb275socketpass"
	echo "# --------------------------------------------------------------"
	$ydb_dist/mumps -run $label^ydb275socketpass
end
