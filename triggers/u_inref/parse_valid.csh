#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192

# Testing the trigger command file parsing
# trigvn -command=cmd[,...] -xecute=strlit [-[z]delim="expr]" [-pieces=[lvn=]int1[:int2][;...]] [-options=[isolation][,consistencycheck]]
# trigvn	:
# 	Null Subscripts		^trigvn
#	Ranges			^trigvn(:) , ^trigvn(:2;5:) , ^trigvn(:"b";"m":"x")
#	Multiple Ranges		^trigvn(0,:,:) , ^trigvn(";":":";5:)
#				^trigvn(:,55;66;77:,:) , ^trigvn(2:,:"m";10;20;25;30;35;44;50,:)
#	Allow LVNs		^trigvn(tvar=:,tvar2="a":"z",tvar3=:10;20)
#
# -command=	S[ET],K[ILL],ZTK[ill],ZK[ill],ZW[ithdraw]
# 	Set only
# 	Kill only
# 	Set and Kill type
#
# -xecute=	"do ^twork"
# 		"do tsubrtn^twork"
# 		"do ^twork()"
# 		"do tsubrtn^twork()"
# 		"do ^twork(lvnname)"
# 		"do tsubrtn^twork(""5"",5)"
#
# -[z]delim=
# 	Single character	,
# 	Multiple characters	~"`
# 	With $[Z]Char		\$zchar(126)_\$char(96) aka ~`
# 	W/nonprinting $[z]char	\$zchar(9)_\$char(254)_""""
# 	Unicode character	\$char(8364)_\$char(36)_`
# 	\$zchar on Unicode chars	\$zchar(8364)_\$zchar(65284) 1st bytes of the euro and full dollar
#
# -piece=
# 	single piece	1
# 	multiple pieces	4;5;6  <--- doubles as collapsable
# 	range of piece	1:8
# 	discontiguous	1:3;7:8
# 	collapsable range
# 	with LVN	tlvn=1:3;5:6;7:8
#
# -options=
# 	isolation		i,isolation
# 	noisolation		noi,noisolation
# 	c[onsistencycheck]	c
# 	noc[onsistencycheck]	noc
#
# -name=
# 	allow use of all graphic characters 32-126
# 	allow names up to 28 characters
# 	disallow use of all non-graphic characters 1-31,127-155
#	disallow names over 28 characters

echo "Valid test cases"
set ntest="valid_M"
# test case includes lines with tabs and extra spaces and different globals
# that should get placed into various dat files
# 1. basic trigger requires only a GBL, command and an xectue string
# 2. global with ranges, three subscripts, multi-command, xectue string
#    and one option
# 3. single global subscript range, multi-command with mixed case, xecute
#    string
# 4. single global subscript alpha range with : and ;, single command,
#    delim with quotes using backtick as delimiter, pieces w/o quotes,
#    both options negated
# 5. single global subscript numeric range with :  and ;, single
#    command, delim with expression w/o quotes, single piece with lvn,
#    single option spelled out
# 5a. single global subscript alpha range with :  and ;, double
#     command, delim with expression w/quotes, two piece with lvn,
#     single negated option spelled out
# 6. three global subscripts alpha&numeric ranges with : and ;,
#    multiple mixed case commands. xecute string with ^, zdelim w/expr
#    w/o quotes, pieces in ranges
# 7. two global variable ranges with one using ";" and ";" as subscripts,
#    command with quotes, xecute string with M double quotes, -zdelim
#    w/expr w/unicode zchars, pieces w/lvn + range, option spelled out
# 8. three gbl subscripts w/lvn assignment pointing to alpha numeric
#    ranges with :, xecute string w/^, delim is ", piece consecutive,
#    options positive short forms
# 9. three gbl subscripts w/lvn assignment pointing to alpha numeric
#    ranges with : and ;, xecute string w/^, delim is ^, piece consecutive,
#    options positive short forms
# 10. remaining tests are parsing non-alphanumerics in the subscript line
cat $gtm_tst/$tst/inref/validtriggers.trg > triggers.trg
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		cat $gtm_tst/$tst/inref/validtriggersutf8.trg >> triggers.trg
	endif
endif
$MUPIP trigger -triggerfile=triggers.trg -noprompt >&! install1.trg
sed 's/, Line [0-9]*:/, Line X:/' install1.trg


$echoline
echo "Check the symmetry of the select output with what is installed"
$show loaded1.trg
$MUPIP trigger -triggerfile=loaded1.trg >&! install2.trg
sed 's/, Line [0-9]*:/, Line X:/' install2.trg

$echoline
echo "Use the select output to delete all triggers"
$show loaded2.trg
diff loaded1.trg loaded2.trg
sed 's/^+/-/' loaded1.trg > loaded3.trg
$MUPIP trigger -triggerfile=loaded3.trg >&! install3.trg
sed 's/, Line [0-9]*:/, Line X:/' install3.trg
echo "Should see no triggers installed"
$show

echo ""
$echoline
echo 'Retrying with ZTrigger'

$echoline
echo "triggers added"
$gtm_exe/mumps -run zload^parsevalid loaded1.trg >&! rerun1.trigout
$grep -c 'Added .* trigger' rerun1.trigout || $grep -v added rerun1.trigout
$grep FAILED rerun1.trigout

$echoline
echo "triggers deleted"
$gtm_exe/mumps -run zload^parsevalid loaded3.trg >&! rerun3.trigout
$grep -c 'Deleted .* trigger' rerun3.trigout || $grep -v deleted rerun3.trigout
$grep FAILED rerun3.trigout

# Did anything get left over?
$gtm_exe/mumps -run show^parsevalid
# load an empty trigger file
$gtm_exe/mumps -run MT^parsevalid
$load MT.trg PASS
echo ""

$echoline
echo "Do random load/unloads to tests for cores in trigger file parsing"
if !($?gtm_test_replay) then
	setenv gtm_valid_trigger_routine `$gtm_exe/mumps -run rand 2`
	echo "setenv gtm_valid_trigger_routine $gtm_valid_trigger_routine" >>& settings.csh
endif
if (1 == $gtm_valid_trigger_routine) then
	echo "Using $gtm_tst/$tst/inref/zsy_validtriggers.m"
	cp $gtm_tst/$tst/inref/zsy_validtriggers.m validtriggers.m
else
	echo "Using $gtm_tst/$tst/inref/do_validtriggers.m"
	cp $gtm_tst/$tst/inref/do_validtriggers.m validtriggers.m
endif
$gtm_exe/mumps -run validtriggers triggers.trg >& parsetest.outx
# Strip out load failures caused by changes in -options handling
$grep -v MUNOACTION parsetest.outx >&! parsetest.out
# delete all triggers
$gtm_exe/mumps -run deleteall^parsevalid

$gtm_tst/com/dbcheck.csh -extract
