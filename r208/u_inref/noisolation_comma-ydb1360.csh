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
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1360] VIEW "NOISOLATION" and $VIEW("NOISOLATION") with a global list that ends with a comma   #'
echo '# issue VIEWGVN for ""                                                                               #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage feeds the line shown to "mumps -direct" in a new process, checks that the output has no'
echo '# fatal error, and checks the output expected.'
echo

echo '# Command : $gtm_tst/com/dbcreate.csh mumps'
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
echo

# The input line of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'view "NOISOLATION":"^b,"' > stage1.inp
echo 'write $view("NOISOLATION","^b,"),!' > stage2.inp
echo 'view "NOISOLATION":"+^a,^b,"' > stage3.inp
echo 'view "NOISOLATION":"^a,,^b"' > stage4.inp
echo 'view "NOISOLATION":"^a,^b" write "$view(""NOISOLATION"",""^b"")=",$view("NOISOLATION","^b"),!' > stage5.inp
set viewgvn = '%YDB-E-VIEWGVN, Invalid global key name used with VIEW/$VIEW(): ""'

foreach stage (1 2 3 4 5)
	switch ($stage)
	case 1:
		echo '# Stage 1 : VIEW "NOISOLATION" with a global list that ends with a comma'
		set before = ('a Release build issued VIEWGVN with bytes read from past the end of the argument in' \
			'place of the name, or got a SIG-11, and a Debug build failed an assert in' \
			'view_arg_convert.c')
		set with = ('expect VIEWGVN for the empty name ("")')
		set expect = ("$viewgvn")
		breaksw
	case 2:
		echo '# Stage 2 : $VIEW("NOISOLATION") with a global list that ends with a comma'
		set before = ('a Release build issued VIEWGVN with bytes read from past the end of the argument in' \
			'place of the name, or got a SIG-11, and a Debug build failed an assert in' \
			'view_arg_convert.c')
		set with = ('expect VIEWGVN for the empty name ("")')
		set expect = ("$viewgvn")
		breaksw
	case 3:
		echo '# Stage 3 : VIEW "NOISOLATION" with a + and a list of two globals that ends with a comma'
		set before = ('a Release build issued VIEWGVN with bytes read from past the end of the argument in' \
			'place of the name, or got a SIG-11, and a Debug build failed an assert in' \
			'view_arg_convert.c')
		set with = ('expect VIEWGVN for the empty name ("")')
		set expect = ("$viewgvn")
		breaksw
	case 4:
		echo '# Stage 4 : VIEW "NOISOLATION" with an empty name between two commas'
		set before = ('VIEWGVN for the empty name ("") (this stage is a control)')
		set with = ('expect VIEWGVN for the empty name ("")')
		set expect = ("$viewgvn")
		breaksw
	case 5:
		echo '# Stage 5 : VIEW "NOISOLATION" with a list of two globals, then $VIEW("NOISOLATION") of the second'
		set before = ('$view("NOISOLATION","^b")=1 (this stage is a control)')
		set with = ('expect $view("NOISOLATION","^b")=1')
		set expect = ('$view("NOISOLATION","^b")=1')
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has this line"
	sed 's/^/#   /' stage$stage.inp
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : $with"
	$gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	foreach line ($expect:q)
		if (`$grep -cFx -- "$line" stage$stage.out`) then
			echo "PASS : stage$stage.out has the line $line"
		else
			echo "FAIL : stage$stage.out does not have the line $line"
		endif
	end
	if (5 != $stage) $gtm_tst/com/check_error_exist.csh stage$stage.out VIEWGVN
	echo
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
echo "# Done"
