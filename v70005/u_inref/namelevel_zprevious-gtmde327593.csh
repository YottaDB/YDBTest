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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-DE327593)

GT.M handles name-level \$ORDER(gvn,-1)/\$ZPREVIOUS(gvn) correctly when searching across subscript-level
mappings in the global directory. In V7.0-004, \$ORDER(gvn,-1), where gvn is an unsubscripted global,
could return the same gvn instead of a previous global name or the null string. The workaround was
to add global data to otherwise empty global maps between the specified gvn and its previous gvn, and
optionally KILLing it afterwards, which leaves around sufficient residual information in the database
to avoid the issue. (GTM-DE327593)

CAT_EOF

echo '# Create 2-region database (AREG and DEFAULT) with STDNULLCOLL (needed for globals spanning multiple regions)'
$gtm_tst/com/dbcreate.csh mumps 2 -stdnull

echo '# Add custom GDE mappings that exercise the GTM-DE327593 bug'
$GDE << GDE_EOF
add -name a* -region=AREG
add -name a(1) -region=DEFAULT
add -name aa* -region=DEFAULT
exit
GDE_EOF

echo '# Set ^aa=1 and then execute [write $ZPREVIOUS(^aa)]'
echo '# This used to incorrectly return ^aa in V7.0-004 but correctly returns the empty string in V7.0-005'
echo '# Expect to see an empty line below'
$gtm_dist/mumps -run %XCMD 'set ^aa=1  write $zprevious(^aa),!'

echo '# Validate DB'
$gtm_tst/com/dbcheck.csh

