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
echo "# [YDB#1334] A FOR whose subscripted control variable is new and whose initial value is undefined   #"
echo "# leaves the local variable intact                                                                   #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# The FOR creates its control variable node, and any nodes above it that do not exist, before it'
echo '# evaluates the initial value. When that issues LVUNDEF, the error handling deletes those nodes again.'
echo '# Deleting the nodes above the control variable used a path through their trees left over from the'
echo '# lookup of the initial value, which damaged the tree of the local variable.'
echo '# Each stage runs its case in a new process. The case catches the LVUNDEF in $ETRAP, then prints PASS'
echo '# or WRONG for each check, and the local variable with ZWRITE if it has fewer than 5 nodes.'
echo

cp $gtm_tst/$tst/inref/ydb1334.m .

foreach label (minimal small deep sibling valued otherchild)
	switch ($label)
	case "minimal":
		echo '# Stage 1 : SET abc(2)=1, then FOR abc(1,1)=abc(3)'
		echo '#   expect LVUNDEF, abc(1) not to exist, and abc(2) to be intact'
		echo '#   previously an assert in lv_tree.c in a Debug build, and abc(1) left in place, then a SIG-11 in a'
		echo '#   Release build'
		breaksw
	case "small":
		echo '# Stage 2 : SET abc("",1)=1,abc("aaa",1)=1, then FOR abc(5,"ddx")=abc("aaa")'
		echo '#   expect LVUNDEF, abc(5) not to exist, and the 2 nodes to be intact'
		echo '#   previously the same failures as in stage 1'
		breaksw
	case "deep":
		echo '# Stage 3 : 100 nodes with numeric and string first subscripts, then 50 times'
		echo '#           FOR abc(25.5,"x","y")=abc(<a numeric first subscript that exists>,"none")'
		echo '#   expect LVUNDEF each time, abc(25.5) not to exist, and the 100 nodes to be intact'
		echo '#   previously an assert in lv_tree.c in a Debug build, and a SIG-11 in a Release build'
		breaksw
	case "sibling":
		echo '# Stage 4 : SET abc("",1)=1,abc("aaa",1)=1,abc(5,"q")=1, then FOR abc(5,"ddx")=abc("aaa")'
		echo '#   expect LVUNDEF, abc(5,"ddx") not to exist, and the 3 nodes to be intact'
		echo '#   previously the same result, since abc(5) has another child and is not deleted'
		breaksw
	case "valued":
		echo '# Stage 5 : SET abc(1)=1,abc(2)=2,abc(3)=3, then FOR abc(1,1)=abc(4), then SET abc(5)=5,abc(6)=6'
		echo '#   expect LVUNDEF, abc(1) to keep its value, and $QUERY to visit the 5 nodes'
		echo '#   previously the same result, since abc(1) has a value and is not deleted, so the error handling must'
		echo '#   leave the tree of the first level subscripts (and its lastLookup clue) as it was'
		breaksw
	case "otherchild":
		echo '# Stage 6 : SET abc(1,2)=1,abc(2)=2,abc(3)=3, then FOR abc(1,1)=abc(4), then SET abc(5)=5,abc(6)=6'
		echo '#   expect LVUNDEF, abc(1,2) to keep its value, and $QUERY to visit the 5 nodes'
		echo '#   previously the same result, since abc(1) has another child and is not deleted, so the error handling'
		echo '#   must leave the tree of the first level subscripts (and its lastLookup clue) as it was'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"$label"'^ydb1334'
	$gtm_dist/mumps -run $label^ydb1334
	echo
end
echo "# Done"
