#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if !($?gtm_test_replay) then
	set namespaces = `$gtm_exe/mumps -run rand 2`
	echo "setenv namespaces $namespaces"	>>&! settings.csh
endif
@ case = 1
$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/name.cmd'")'

echo "$GDE << gde_eof"	>>&! name_script.csh
cat gdename.cmd		>>&! name_script.csh
echo "gde_eof"		>>&! name_script.csh

chmod +x name_script.csh

./name_script.csh

$GDE show -map >&! map_case_${case}.out
$grep "REG =" map_case_${case}.out

mv mumps.gld mumps.gld_$case

#        ----------------------------------------------
#        X               X               X0              <-- this is the above test case
#        X(1)            X(1)            X(1)++
#        X("abc")        X("abc")        X("abc")++
#        X(1:"abc")      X(1)            X("abc")
#        X(:"a")         X("")           X("a")
#        X(:)            X("")           X0
#        X(2,:)          X(2,"")         X(2)++
#        X("abcd","z":)  X("abcd","z")   X("abcd")++
#
foreach name ('X' 'X(1)' 'X("abc")' 'X(1:"abc")' 'X(:"a")' 'X(:)' 'X(2,:)' 'X("abcd","z":)' 'X($char(22))' 'X($ZCHAR(29))' )
	@ case++
	echo "# name map case : $case - Checking name : $name"
	$GDE >&! map_case_${case}.out << EOF
	template -reg -stdnull
	change -reg DEFAULT -stdnull
	add -reg AREG -d=ASEG
	add -seg ASEG -f=a.dat
	add -name $name -reg=AREG
	show -commands
	show -map
EOF

	$grep -E "ADD -NAME|REG =" map_case_${case}.out
	mv mumps.gld mumps.gld_$case
end

$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/namemap1.cmd'")'

echo "# Checking a complex name mapping scenario - case : $case"
# GTM-5572 : gde parsing does not handle spaces correctly - Check if @file.com<space> works properly
echo "show -name"	>&! dummy.cmd
cp dummy.cmd gdenamemap1.cmddummy.cmd
echo "$GDE << gde_eof"					>> name_map1_script.csh
if ($namespaces) then
	echo "@gdenamemap1.cmd  dummy.cmd	"	>> name_map1_script.csh
	echo "@gdenamemap1.cmd  @dummy.cmd  "		>> name_map1_script.csh
	echo "@gdenamemap1.cmd  dummy.cmd y.c   "	>> name_map1_script.csh
	echo "@gdenamemap1.cmd  "			>> name_map1_script.csh
else
	echo "@gdenamemap1.cmd  dummy.cmd"		>> name_map1_script.csh
	echo "@gdenamemap1.cmd  @dummy.cmd"		>> name_map1_script.csh
	echo "@gdenamemap1.cmd  dummy.cmd y.c"		>> name_map1_script.csh
	echo "@gdenamemap1.cmd"				>> name_map1_script.csh
endif
echo "gde_eof"						>> name_map1_script.csh
chmod +x name_map1_script.csh
./name_map1_script.csh

$GDE show -map >&! map_case_${case}.out
$grep "REG =" map_case_${case}.out
mv mumps.gld mumps.gld_$case
