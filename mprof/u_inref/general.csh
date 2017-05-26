#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#first, get the error :
$GTM << FIN
	w "d ^nodb",! d ^nodb
FIN

echo ""

setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh .
$GTM << FIN
	view "TRACE":1
	h
FIN

$GTM << FIN
	view "TRACE":1:"LCL"
	h
FIN

$GTM << FIN
	w "d ^badprof",! d ^badprof
	h
FIN


$GTM << FIN
	w "d ^examin ^TRACE",! d ^examin("^TRACE")
	k ^TRACE
FIN

$gtm_exe/mumps -run badprof

$GTM << FIN
	w "d ^examin ^TRACE",! d ^examin("^TRACE")
	k ^TRACE
FIN

$GTM << FIN
	w "d ^out1",! d ^out1
		w "d ^examin ^TRACE",! d ^examin("^TRACE")
		k ^TRACE
	w "d ^out2",! d ^out2
		w "d ^examin ^TRACE",! d ^examin("^TRACE")
		k ^TRACE
	w "d ^smoke",! d ^smoke
		w "d ^examin ^TRACE",! d ^examin("^TRACE")
		k ^TRACE
FIN

# test for C9B08-001730
$gtm_tst/$tst/u_inref/levels_on_off.csh
$gtm_tst/com/dbcheck.csh

setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh . -key=200

$GTM << FIN
        w "d ^extin",! d ^extin
                w "d ^examin ^TRACE",! d ^examin("^TRACE")
                k ^TRACE
        w "d ^direct",! d ^direct
                w "d ^examin ^TRACE",! d ^examin("^TRACE")
                k ^TRACE
        w "d ^indirect",! d ^indirect
                w "d ^examin ^TRACE",! d ^examin("^TRACE")
                k ^TRACE
        w "d ^label",! d ^label
                w "d ^examin ^TRACE",! d ^examin("^TRACE")
                w "d ^examin ^TRACEN",! d ^examin("^TRACEN")
                k ^TRACE
        w "d ^multilvl",! d ^multilvl
                w "d ^examin ^TRACE",! d ^examin("^TRACE")
                k ^TRACE
        w "d ^comm",! d ^comm
                w "d ^examin ^TRACE",! d ^examin("^TRACE")
                k ^TRACE
FIN
$GTM << FIN
	w "d ^mnylvl",! d ^mnylvl
	w "d ^examin ^TRACE",! d ^examin("^TRACE")
	k ^TRACE
	h
FIN

if ($LFE != "L") then
	$GTM << FIN
		w "d ^fors",! d ^fors
                w "d ^examin ^TRACE",! d ^examin("^TRACE")
                k ^TRACE
        q
FIN
endif

# And to see that $j works:
$GTM << \FIN >&! job_out1.log
	VIEW "TRACE":1:"^LONGGLOBALNAMESCANBEUSEDTOSTORE(""TEST"",$j)"
	d ^lvls
	VIEW "TRACE":0:"^LONGGLOBALNAMESCANBEUSEDTOSTORE(""TEST"",$j)"
	zwr ^LONGGLOBALNAMESCANBEUSEDTOSTORE
	k ^LONGGLOBALNAMESCANBEUSEDTOSTORE
	q
\FIN
sort job_out1.log

if ($LFE != "L") then
	$GTM << \FIN >&! job_out2.log
	VIEW "TRACE":1:"^MYGBL(""TEST"",$j)"
	d ^lotsfor
	VIEW "TRACE":0:"^MYGBL(""TEST"",$j)"
	zwr ^MYGBL
	k ^MYGBL
	q
\FIN
sort job_out2.log

endif

$gtm_tst/com/dbcheck.csh

if ($LFE == "L")  exit
setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh .

$GTM << xyz
VIEW "TRACE":1:"^BASIC"
w "d ^fact(18)",!  d ^fact(18)
w "d ^arith(18)",!  d ^arith(18)
w "d ^ebmuldiv(0)",!  d ^ebmuldiv(0)
w "d ^barith",!  d ^barith
w "d ^bool",!      d ^bool
w "d ^relation",!  d ^relation
w "d ^pattst",!  d ^pattst
w "d ^sortsaft",!  d ^sortsaft
w "d ^text4",!  d ^text4
w "d ^per02457",!  d ^per02457
w "d ^ascii",!  d ^ascii
w "d ^char",!  d ^char
w "d ^fnextr",!  d ^fnextr
w "d ^length",!  d ^length
w "d ^piece",!  d ^piece
w "d ^setpiece",!  d ^setpiece
w "d ^query",!  d ^query
w "d ^extcall",!  d ^extcall
w "d ^locals",!  d ^locals
w "d ^cmptst",!  d ^cmptst
w "d ^expr2",!  d ^expr2
w "d ^for",!  d ^for
w "d ^forloop",!  d ^forloop
w "d ^log",!  d ^log
w "d ^new",!  d ^new
w "d ^select",!  d ^select
w "d ^xecute",!  d ^xecute
w "d ^larray",!  d ^larray
w "d ^view",!  d ^view
w "d ^view2(0)",!  d ^view2(0)
w "d ^zbits",!  d ^zbits
w "d ^per2586a(0)",! d ^per2586a(0)
w "d ^per2586b(0)",! d ^per2586b(0)
w "d ^per2586c(0)",! d ^per2586c(0)
w "d ^per2968",! d ^per2968
w "d ^tstp",!  d ^tstp
VIEW "TRACE":0
h
xyz

unsetenv gtm_zyerror
setenv gtm_ztrap_form  adaptive
echo "ZTRAP testing starts..."
$GTM << EOF
VIEW "TRACE":1:"^BASIC"
w "Testing valid ZTRAP cases...",!
w "do ^ztvref1",!  do ^ztvref1
w "do ^ztvref2",!  do ^ztvref2
w "do ^ztvref3",!  do ^ztvref3
w "do ^ztvcmd1",!  do ^ztvcmd1
w "do ^ztvcmd2",!  do ^ztvcmd2
w "do ^ztvcmd3",!  do ^ztvcmd3
EOF
echo "end of valid ZTRAP cases..."

echo "Testing invalid ZTRAP cases..."
$GTM << EOF
VIEW "TRACE":1:"^BASIC"
w "do NOLAB^ztiref",!  do NOLAB^ztiref
w "do OFF^ztiref",!  do OFF^ztiref
w "do MOD^ztiref",!  do MOD^ztiref
w "do SUB4^ztiref",!  do SUB4^ztiref
w "do IND^ztiref",!  do IND^ztiref
w "do TST1^zticmd3",!  do TST1^zticmd3
w "do TST2^zticmd3",!  do TST2^zticmd3
w "do TST3^zticmd3",!  do TST3^zticmd3
w "do TST4^zticmd3",!  do TST4^zticmd3
h
EOF

$GTM << EOF
VIEW "TRACE":1:"^BASIC"
w "do ^zticmd1",!  do ^zticmd1
h
EOF

$GTM << EOF >&! zticmd2.out1
VIEW "TRACE":1:"^BASIC"
w "do ^zticmd2",!  do ^zticmd2
h
EOF
$grep -v "MAXTRACELEVEL" zticmd2.out1


echo "end of invalid ZTRAP cases..."
echo "...end of ZTRAP testing"

echo "Testing of ZYERROR/ZERROR starts..."
$GTM << EOF
VIEW "TRACE":1:"^BASIC"
w "do ^zevref1",!  do ^zevref1
w "do ^zevref2",!  do ^zevref2
w "do ^zevref3",!  do ^zevref3

w "do NOLAB^zeiref1",!  do NOLAB^zeiref1
w "do OFF^zeiref1",!  do OFF^zeiref1
w "do MOD^zeiref1",!  do MOD^zeiref1
w "do IND^zeiref1",!  do IND^zeiref1
w "do ZTERR^zeiref1",!  do ZTERR^zeiref1
w "do TST1^zeiref2",!  do TST1^zeiref2
w "do TST2^zeiref2",!  do TST2^zeiref2
w "do TST3^zeiref2",!  do TST3^zeiref2
w "do TST4^zeiref2",!  do TST4^zeiref2
h
EOF

echo "Begin of ZYERROR environement test cases..."
setenv gtm_zyerror "SUB2"
$GTM << EOF
VIEW "TRACE":1:"^BASIC"
w "do TST1^zevref4",!  do TST1^zevref4
h
EOF

setenv gtm_zyerror "SUB3+0"
$GTM << EOF
VIEW "TRACE":1:"^BASIC"
w "do TST2^zevref4",!  do TST2^zevref4
h
EOF

setenv gtm_zyerror "lab^zeleaf"
$GTM << EOF
VIEW "TRACE":1:"^BASIC"
w "do TST3^zevref4",!  do TST3^zevref4
h
EOF

setenv gtm_zyerror "lab+1^zeleaf"
$GTM << EOF
VIEW "TRACE":1:"^BASIC"
w "do TST4^zevref4",!  do TST4^zevref4
h
EOF

unsetenv gtm_zyerror
$GTM << EOF
VIEW "TRACE":1:"^BASIC"
w "do TST1^zevref4",!  do TST1^zevref4
h
EOF
echo "...end of ZYERROR as environment variable"
echo "...end of ZYERROR testing"
unsetenv gtm_ztrap_form

setenv gtm_test_sprgde_id "ID4"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps 3
$GTM << zyx
VIEW "TRACE":1:"^BASIC"
w "d ^kill1",!  d ^kill1
w "d ^set",!  d ^set
w "d ^globals",!  d ^globals
zyx
if ($test_collation_no != 0) echo "Running with alternative collation. ZPREVIOUS test will fail:"
$GTM << zyx
VIEW "TRACE":1:"^BASIC"
w "d ^zprev",!  d ^zprev
zyx
$GTM << zyx
VIEW "TRACE":1:"^BASIC"
Do ^%GI
$gtm_tst/$tst/inref/asw.glo
yes
w "d ^per02397",!  d ^per02397
w "d ^miscdb",!  d ^miscdb
h
zyx
$gtm_tst/com/dbcheck.csh  -extract
setenv gtm_test_sprgde_id "ID5"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps
$GTM << yzx
VIEW "TRACE":1:"^BASIC"
w "d ^per02276",!  d ^per02276
w "d ^stpfail",!  d ^stpfail
h
yzx

sleep 10

$gtm_tst/com/dbcheck.csh -extract
setenv gtm_test_sprgde_id "ID6"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh . 1 . 1900 2048 . 128
$GTM << zxy
VIEW "TRACE":1:"^BASIC"
w "d ^putfail",!  d ^putfail
w "d ^fifo",!  d ^fifo
w "d ^stream",!  d ^stream
w "d ^iowrite",! d ^iowrite
h
zxy

# iowrite program created a file TESTFILE.OUT. Examine
# this file for the $C(10) character.
$tst_od -c TESTFILE.OUT | sed 's/^[^ ]*[ ]*//g'

$gtm_tst/com/dbcheck.csh -extract
