#!/usr/local/bin/tcsh -f
#
# GTM-7492. FOR control variable SIG-11 issues.
#
$GTM << EOF
	do ^gtm7492	; First 4 test cases. The other two require direct mode.
	set linestr="-------------------------------------------------------------------------"
	new (linestr)
	write !,linestr,!,"Test 5 ",!
	for @"i(1)"=1:1:3 write i(1),!
	new (linestr)
	write !,linestr,!,"Test 6 ",!
	set a="i",b="@a" for @b=1:1:3 write i,!
EOF
