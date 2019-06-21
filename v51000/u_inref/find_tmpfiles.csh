#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################
set echo
set verbose
cd baktmp
alias ltf 'ls -lart --full-time'
set found_nonzero_tmpfile = 0
while !( -e endloop.txt)
	echo "checking temp files"
	set filepat="*"
	set nonomatch
	set filereal=$filepat
	unset nonomatch
	date
	if ("$filereal" != "$filepat") then
		echo $filereal
		# Files of the form "*" in "baktmp/" directory (i.e. backup temporary files) exist
		foreach file ($filereal)
			if (! -z $file) then
				set found_nonzero_tmpfile = 1
				break
			endif
		end
	else
		# Files of the form "*" do not exist
		echo "TEST-I-TEMPFILES, not exist at this point"
		continue
	endif
	if ($found_nonzero_tmpfile) then
		# There would be 4 temporary files, one per region.
		# Previously we used to chmod just one file (that of BREG). But we have had one rare failure
		# where BREG temporary file at that time was 0-byte whereas DEFAULT region temporary file
		# had non-zero size. Removing permissions on DEFAULT region temporary file in that case would
		# have avoided the test failure. Hence the decision to remove permissions on ALL regions temporary files
		# even if we found only a subset of the regions having a non-zero temporary file in the foreach loop above.
		chmod a-w *
		ltf *
		date
		cd -
		$ydb_dist/mumps -run %XCMD 'set ^permissionchanged=1'
		cd baktmp
		ltf *
		date
		# Record what mumps and mupip processes are running at this time
		$psuser | $grep -E "mupip|mumps"
		ltf *
		date
		#To debug can sleep 30 and then ls to ensure that we can see the size increasing
		# for at least the temp files corresponding to region AREG
		cd -
		unset echo
		unset verbose
		exit
	else
		echo "TEST-I-TEMPFILES, exist at this point but all empty files (size is 0 bytes)"
	endif
end
echo "TEST-E-TEMPFILES not found. Was not able to change permissions as desired"
cd -
unset echo
unset verbose
