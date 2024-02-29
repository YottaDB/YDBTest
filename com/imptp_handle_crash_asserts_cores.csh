#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script is invoked by tests that run "imptp.csh" and crash the processes.
# Some of those tests see potential core files (due to assert failures, db integ errors etc.
# that happen due to a kill -9). The caller test handles the db integ errors by running a "mupip journal -recover"
# or "mupip journal -rollback". But the assert failures and core files cause a false test failure as they are seen
# by the test framework at the end of the test.

# Interestingly, these assert failures and/or core files have been seen only in tests that use NOBEFORE image journaling.
# Not sure why. So only a select few (2 to be precise) callers invoke this script currently.

# This script renames any core files away so the test framework does not see them.
# And it filters out any %YDB-F-ASSERT lines out of impjob_imptp*.mje*
# This script finds out the imptp jobid and uses this to do the renaming/filtering.

if ($?gtm_test_jobid) then
	set imptp_jobid = "$gtm_test_jobid"
else
	set imptp_jobid = "0"	# Default job id is 0
endif

# ###################################
# Rename cores away
# ###################################
set filepat="core*"
set nonomatch
set filereal=$filepat
unset nonomatch
if ("$filereal" != "$filepat") then
	# Files of the form "core*" exist. Move them away
	foreach file ($filereal)
		mv $file imptp_jobid_${imptp_jobid}_$file
	end
else
	# Files of the form "core*" do not exist. Nothing to do.
endif

# ###################################
# Filter %YDB-F-ASSERT lines away
# ###################################
# Can't use check_error_exist.csh since "%YDB-F-ASSERT" error will NOT always occur in all files
# And cannot rename "*.mje*" to "*.mje*x" as com/errors.csh will catch any "*.mje*" and "*.mje*x" will also match.
# Therefore we rename "*.mje*" to "*.xmje*"
foreach file (impjob_imptp${imptp_jobid}*.mje*)
	set newfile = $file:r.x${file:e}
	mv $file $newfile
	$grep -vE 'YDB-F-ASSERT' $newfile > $file
end

exit 0
