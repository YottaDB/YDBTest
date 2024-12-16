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
#
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE376239 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-DE376239)

GT.M reports a FALLINTOFLST error after an argumentless DO embedded subroutine followed by a label with a formallist when no QUIT terminates the code after the DO block, except when there are no lines between the end of the embedded subroutine and the label with the formallist, in which case GT.M infers a QUIT would be appropriate to separate them. When GT.M inserts an implicit QUIT, it issues a FALLINOFLST warning unless compilation has a -NOWARNING qualifier. Previously, since the FALLINTOFLST error was introduced in V6.0-002, GT.M inappropriately gave that error for cases of that combination under circumstances where the QUIT was on the same line as the argumentless DO rather than explicitly between the embedded subroutine and the label with the formallist. (GTM-DE376239)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"

echo "# See the below GitLab threads for more information on the cases tested below:"
echo "# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2197#note_2310986168"
echo "# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2197#note_2303484583"
foreach test ("a" "b" "c")
	foreach nowarning ("" " -NOWARNING")
			echo "# Testing compilation errors for: 'mumps$nowarning gtmde376239$test.m'"
			cp $gtm_tst/$tst/inref/gtmde376239$test.m .
			$gtm_dist/mumps$nowarning gtmde376239$test.m
			echo "# Testing runtime errors for: 'mumps -run embeddedrtn^gtmde376239$test'"
			$gtm_exe/mumps -run embeddedrtn^gtmde376239$test
			echo
	end
end

cat << CAT_EOF | sed 's/^/# /;'
YottaDB r2.04 will behave differently than r2.02 for the below test case.
r2.02 will provide a clear FALLINTOFLST error while r2.04 will issue
a confusing QUITARGREQD error (this happened because an implicit QUIT was
inserted by GT.M/YottaDB and not because of a QUIT coded by the user).
But we are going to keep the r2.04 behavior to be compatible with upstream
GT.M and other M implementations.
See note at https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2197#note_2303484583
for more details.
CAT_EOF
echo "# Testing compilation errors for: 'mumps gtmde376239d.m'"
cp $gtm_tst/$tst/inref/gtmde376239d.m .
$gtm_dist/mumps gtmde376239d.m
echo "# Testing runtime errors for: 'mumps -run embeddedrtn^gtmde376239d'"
$gtm_exe/mumps -run gtmde376239d
