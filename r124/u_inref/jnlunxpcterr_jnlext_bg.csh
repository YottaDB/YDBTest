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

set echo
set verbose

while (1)
	if (-e jnlext.STOP) then
		# jnlunxpcterr.csh is asking us to stop. Exit now that we are at a logical point.
		break
	endif
	$MUPIP journal -extract -forward mumps.mjl
	if ($status) then
		echo "TEST-E-ERROR in MUPIP JOURNAL -EXTRACT -FORWARD"
		break
	endif
	if (! $gtm_test_jnl_nobefore) then
		$MUPIP journal -extract -backward mumps.mjl
		if ($status) then
			echo "TEST-E-ERROR in MUPIP JOURNAL -EXTRACT -FORWARD"
			break
		endif
	endif
end

touch jnlext.ERROR
