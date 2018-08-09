#!/usr/local/bin/tcsh -f
#################################################################
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
# Tests conversion utility routines can handle numbers with more than 18 digits
#

# Set to avoid wrapping at 68 columns or so which breaks long numbers into multiple lines otherwise
setenv BC_LINE_LENGTH 0
# The release note says that the conversion can handle numbers with digits up to the max string length, but chose to cap at 256 as the test would take too long otherwise
set rand=`$gtm_tst/com/genrandnumbers.csh 1 1 256`
foreach n (18 19 20 255 256 $rand -5 -10)
	if ($n>0) then
		echo "# Conversions using a random $n digit number"
	else
		set negn=`expr "0" - "$n"`
		echo "# Conversions using a random $negn digit negative number (Specified length is not long enough represent the fully converted number)"
	endif

	$ydb_dist/mumps -run gtm5574 $n
	echo "-------------------------------------------"
end
