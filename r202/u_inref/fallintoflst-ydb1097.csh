#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "##############################################################################################################"
echo '# Test FALLINTOFLST compile time warning (but NO runtime error) is issued when falling through dotted DO lines'
echo "##############################################################################################################"

foreach file (ydb1097a ydb1097b ydb1097c ydb1097d ydb1097e ydb1097f ydb1097g)
	if ("ydb1097d" != "$file") then
		echo "# Running [mumps -run $file]. Expecting a FALLINTOFLST warning at compile time (but no runtime error)."
	else
		echo "# Running [mumps -run $file]. Expecting a FALLINTOFLST error."
	endif
	$gtm_dist/mumps -run $file
end

