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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE340950 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE510902)

GT.M prevents compile-time errors in operations on literals within an XECUTE block from terminating the XECUTE without properly cleaning up the surrounding compilation environment. Previously, this could cause termination of compilation of the routine containing the XECUTE and failure to compile subsequent routines passed to the same GT.M process (GTM-DE510902)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"

echo "# Generate test routines for each of the following errors implicated by the changes in the release note:"
echo "# 1. DIVZERO"
echo "# 2. NEGFRACPWR"
echo "# 3. NUMOFLOW"
echo "# 4. PATNOTFOUND"
echo "# This list is derived from a review of the v71001 changes to sr_port/stx_error.c."
echo "# However, only the NEGFRACPWR and NUMOFLOW cases show behavioral differences in v71001,"
echo "# though all 4 of the above error codes are implicated in the changes to sr_port/stx_error.c."
echo "# See the following GitLab discussions for details:"
echo "# + https://gitlab.com/YottaDB/DB/YDBTest/-/issues/666#note_2379300790"
echo "# + https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2248#note_2401375342"
echo 'numoflow xecute "write +""1E60"",! quit"' >&! NUMOFLOW.m
echo 'divzero xecute "write 1/0,! quit"' >&! DIVZERO.m
echo 'negfracpwr xecute "write -1**-0.5,!"' >&! NEGFRACPWR.m
echo 'patnotfound xecute "write .0?1SS,!"' >&! PATNOTFOUND.m
echo 'noerror write 1,! quit' >&! noerror.m
echo

echo "# Run each test routine, followed by the 'noerror' routine."
echo "# In the case expect an error from the test routine, followed by '1' from the 'noerror' routine."
echo "# Prior to V71001, in the cases of NEGFRACPWR and NUMOFLOW, the 'noerror' routine would not compile"
echo "# after attempting to compile the matching test routine."
echo "# Instead, in the cases of NEGFRACPWR and NUMOFLOW:"
echo "# 1. pro builds would issue GTM-E-ZLINKFILE and GTM-E-ZLNOOBJECT errors"
echo "# 2. dbg builds would issue assert failures like the following:"
echo "#   %GTM-F-ASSERT, Assert failed in /Distrib/YottaDB/V71000/sr_port/mdb_condition_handler.c line 488 for expression (\!TREF(xecute_literal_parse))"
echo
setenv gtmroutines ". $gtmroutines"

foreach errname (DIVZERO NEGFRACPWR NUMOFLOW PATNOTFOUND)
	(expect -d $gtm_tst/$tst/u_inref/xecuteopfail_cleancompile-gtmde510902.exp $errname > expect-$errname.tmp) >& expect-$errname.dbg
	# Remove carriage returns inserted by [expect].
	cat expect-$errname.tmp | sed 's/\r//g' >& expect-$errname.outx
	perl $gtm_tst/com/expectsanitize.pl expect-$errname.outx >& expect-$errname-sanitized.out
end
cat expect*sanitized.out
