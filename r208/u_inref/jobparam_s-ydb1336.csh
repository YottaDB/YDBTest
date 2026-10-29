#!/usr/local/bin/tcsh -f
#################################################################
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
echo "#-------------------------------------------------------------------------------------------------#"
echo "# [YDB#1336] A JOB command with an unknown job parameter name starting with S does not read past #"
echo "# the end of the JOB parameter name table                                                         #"
echo "#-------------------------------------------------------------------------------------------------#"
echo
echo '# The compiler looks up a job parameter name only among the names in the JOB parameter name table that'
echo '# start with the same letter. The index of where the names after S start was one too high, so for a'
echo '# name that starts with S but is not a valid name, the lookup compared one entry past the end of the'
echo '# table. Only an ASAN build showed that (a global-buffer-overflow in namelook()), as the extra entry'
echo '# did not match.'
echo '#'
echo '# Stage 1 compiles JOB commands with job parameter names that start with S, both names that are not'
echo '# valid and the valid ones (STARTUP, SCHEDULE, SWAPPING and their 3 letter abbreviations). It compiles'
echo '# each JOB command with XECUTE "if 0  job ^nosuchrtn:(<name>)", which compiles the JOB command without'
echo '# running the JOB command, and checks that a name that is not valid gets a JOBPARUNK error and that a'
echo '# valid name gets no error.'
echo

cp $gtm_tst/$tst/inref/ydb1336.m .

echo '# Stage 1 : compile JOB commands with job parameter names that start with S'
echo '# Before the fix : an ASAN build was terminated by a global-buffer-overflow in namelook() at'
echo '#                  the first name (S), so none of the lines below was printed. Other builds printed'
echo '#                  the lines below.'
echo '# With the fix   : expect JOBPARUNK for each name that is not valid, and no error for each valid name'
echo '# Command : $gtm_dist/mumps -run names^ydb1336'
$gtm_dist/mumps -run names^ydb1336
echo

echo "# Done"
