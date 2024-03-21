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
#
cat << 'CAT_EOF' | sed 's/^/# /;'
********************************************************************************************
GTM-F135292 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637151)

$ZJOBEXAM() recognizes an optional second argument of an expr that evaluates to a string as described for the argument of ZSHOW
specifying one or more codes determining the nature of the information produced by the function. If the argument is missing
or empty, GT.M operates as if it was a "*" and produces the associated context. This provides a way to suppress content
that might contain PNI. Previously, $ZJOBEXAM() always produced a full context. (GTM-F135292)

'CAT_EOF'

setenv ydb_prompt "GTM>"
setenv ydb_msgprefix "GTM"

echo ''
echo '# Create database file'
$gtm_tst/com/dbcreate.csh mumps
echo ''

echo ''
echo '# Prepare routines for using "zshow "a"'
set save_gtmroutines = "$gtmroutines"
setenv gtmroutines ".*(. $gtm_tst/$tst/inref)"
echo ''
echo '# This routine will generate random combination & length for 2nd argument in $ZJOBEXAM.'
echo '# And check if generated combination & length produced correct output and correct order.'
echo '# This will run 5 times in total.'
echo ''
echo '# Run the program'
$gtm_exe/mumps -run generatezje^gtmf135292
echo ''

# Restore after test
setenv gtmroutines "$save_gtmroutines"
