#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
if ("ENCRYPT" == $test_encryption && "TRUE" == $gcrypt_fips && "FALSE" == "$gtm_test_tls") then
	# Since encryption is turned on, let's enable FIPS mode to test gcrypt FIPS mode of operation.
	# But, we can do that only if the gcrypt version of the encryption library is loaded.
	if (! $?encryption_lib) then
		echo "Environment variable encryption_lib is not defined. Cannot set FIPS mode."
		exit 1
	else if ("gcrypt" == $encryption_lib) then
		source $gtm_tst/com/set_env_random.csh "gtmcrypt_FIPS" "TRUE FALSE"
	endif
endif

$gtm_tst/$tst/u_inref/testver.csh
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps
$GTM << xyz
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
w "d ^zlfix",! d ^zlfix
w "d ^largeexp1",! d ^largeexp1
w "d ^largeexp2",! d ^largeexp2
w "d ^largeexp3",! d ^largeexp3
w "d ^order",! d ^order
h
xyz

source $gtm_tst/com/unset_ydb_env_var.csh ydb_zyerror gtm_zyerror
setenv gtm_ztrap_form  adaptive
echo "ZTRAP testing starts..."
$GTM << EOF
w "Testing valid ZTRAP cases...",!
w "do ^ztvref1",!  do ^ztvref1
w "do ^ztvref2",!  do ^ztvref2
w "do ^ztvref3",!  do ^ztvref3
w "do ^ztvcmd1",!  do ^ztvcmd1
w "do ^ztvcmd2",!  do ^ztvcmd2
w "do ^ztvcmd3",!  do ^ztvcmd3
EOF
echo "end of valid ZTRAP cases..."

echo "Testing invalid ZTRAP cases with gtm_ztrap_new set to TRUE..."
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_ztrap_new gtm_ztrap_new TRUE
$GTM << EOF
w "do ^ztidrv",!  do ^ztidrv
h
EOF

echo "Testing invalid ZTRAP cases with NO gtm_ztrap_new ..."
source $gtm_tst/com/unset_ydb_env_var.csh ydb_ztrap_new gtm_ztrap_new
$GTM << EOF
w "do ^ztidrv",!  do ^ztidrv
h
EOF

$GTM << EOF
w "do ^zticmd1",!  do ^zticmd1
w \$zs,!
h
EOF

$GTM << EOF
w "do ^zticmd2",!  do ^zticmd2
h
EOF

echo "end of invalid ZTRAP cases..."
echo "...end of ZTRAP testing"

echo "Testing of ZYERROR/ZERROR starts..."
$GTM << EOF
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
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zyerror gtm_zyerror "SUB2"
$GTM << EOF
w "do TST1^zevref4",!  do TST1^zevref4
h
EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zyerror gtm_zyerror "SUB3+0"
$GTM << EOF
w "do TST2^zevref4",!  do TST2^zevref4
h
EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zyerror gtm_zyerror "labelinanothermoduleforzyerror^zeleaf"
$GTM << EOF
w "do TST3^zevref4",!  do TST3^zevref4
h
EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_zyerror gtm_zyerror "labelinanothermoduleforzyerror+1^zeleaf"
$GTM << EOF
w "do TST4^zevref4",!  do TST4^zevref4
h
EOF

source $gtm_tst/com/unset_ydb_env_var.csh ydb_zyerror gtm_zyerror
$GTM << EOF
w "do TST1^zevref4",!  do TST1^zevref4
h
EOF
echo "...end of ZYERROR as environment variable"
echo "...end of ZYERROR testing"
echo "Testing ZTRAP for errors in ZBREAK, ZSTEP actions..."
$GTM << EOF
w "d ^zbrk",! d ^zbrk k x
w "d ^ztrp",! d ^ztrp k x
w "\$zstatus = ",\$zs,!
w "d ^zstep",! d ^zstep k x
w "d ^zstep1",! d ^zstep1 k x
EOF
echo "endof ZTRAP testing with ZBREAK and ZSTEP"
unsetenv gtm_ztrap_form
$gtm_tst/com/dbcheck.csh -extract

setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps 3
cp $gtm_tst/$tst/inref/basic.trg basic.trg
$gtm_tst/com/trigger_load.csh basic.trg "" -noprompt
$GTM << zyx
w "d ^kill1",!  d ^kill1
w "d ^set",!  d ^set
w "d ^globals",!  d ^globals
zyx

if ($test_collation_no != 0) echo "Running with alternative collation. ZPREVIOUS test will fail:"
# Randomly choose STDNULLCOLL or NOSTDNULLCOLL for local variable null collation. ^zprev knows to handle this
set stdnullcoll = `$ydb_dist/mumps -run rand 2`
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lct_stdnull gtm_lct_stdnull $stdnullcoll
$GTM << zyx
w "d ^zprev",!  d ^zprev
zyx
source $gtm_tst/com/unset_ydb_env_var.csh ydb_lct_stdnull gtm_lct_stdnull

$GTM << zyx
Do ^%GI
$gtm_tst/$tst/inref/asw.glo
yes
w "d ^per02397",!  d ^per02397
w "d ^miscdb",!  d ^miscdb
h
zyx
$gtm_tst/com/dbcheck.csh  -extract
setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh mumps
$GTM << yzx
w "d ^per02276",!  d ^per02276
w "d ^stpfail",!  d ^stpfail
h
yzx

$gtm_tst/com/dbcheck.csh -extract
setenv gtm_test_sprgde_id "ID4"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh . 1 . 1900 2048 . -res=128
cp $gtm_tst/$tst/inref/basic.trg basic.trg
$gtm_tst/com/trigger_load.csh basic.trg
$GTM << zxy
w "d ^putfail",!  d ^putfail
w "d ^fifo",!  d ^fifo
w "d ^stream",!  d ^stream
w "d ^iowrite",! d ^iowrite
h
zxy
# Wait for the do_dbx_c_stack_trace.csh processes started in "d ^fifo" to exit
$gtm_tst/com/wait_for_log.csh -log dbx_c_stack_trace_fifo.done -message "dbx tracing will exit now"
$gtm_tst/com/wait_for_log.csh -log dbx_c_stack_trace_fifo2.done -message "dbx tracing will exit now"
#
# iowrite program created a file TESTFILE.OUT. Examine
# this file for the $C(10) character.
$tst_od -c $tst_working_dir/TESTFILE.OUT | sed 's/^[^ ]*[ ]*//g'
#
#
#
if ($?test_replic != 1) then

	echo "More ZBreak and ZSTep tests ........"
	#
	$gtm_dist/mumps $gtm_tst/$tst/inref/decimal.m
	$gtm_dist/mumps $gtm_tst/$tst/inref/avg.m
	$gtm_dist/mumps $gtm_tst/$tst/inref/main.m
	$gtm_dist/mumps $gtm_tst/$tst/inref/squaroot.m
	$gtm_dist/mumps $gtm_tst/$tst/inref/factor.m
	$gtm_dist/mumps $gtm_tst/$tst/inref/newavg.m
	$gtm_dist/mumps $gtm_tst/$tst/inref/cube.m
	$gtm_dist/mumps $gtm_tst/$tst/inref/base.m
	$gtm_dist/mumps $gtm_tst/$tst/inref/square.m
	\cp $gtm_tst/$tst/inref/main.m .

	if ($HOSTOS == "OSF1") then
	    setenv gtmroutines "./shlib1.so ./shlib2 ./shlib3.so $gtmroutines"
	    $gt_cc_compiler ${gt_ld_shl_options} ${gt_ld_option_output} shlib1.so decimal.o avg.o
	    $gt_cc_compiler ${gt_ld_shl_options} ${gt_ld_option_output} shlib2 main.o square.o
	    $gt_cc_compiler ${gt_ld_shl_options} ${gt_ld_option_output} shlib3.so factor.o cube.o newavg.o
	    \rm decimal.o avg.o newavg.o main.o square.o factor.o cube.o
	endif
	#
	#
	$GTM<<EOF
	W "ZB fact^factor",! ZB fact^factor
	W "ZB ^main",! ZB ^main
	W "Do ^main",! do ^main
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	ZSH "B":local
	S x=\$o(local("B","")) f  s y(\$G(local("B",x)))="",x=\$o(local("B",x)) q:x=""
	S break=""
	W "ZSHOW B:",!
	F  S break=\$O(y(break)) Q:break=""  w !,break
	W "Do ^main",! do ^main
	W "ZSHOW B",! ZSH "B":local1
	S x=\$o(local1("B","")) f  s y(\$G(local1("B",x)))="",x=\$o(local1("B",x)) q:x=""
	S break=""
	F  S break=\$O(y(break)) Q:break=""  w !,break
	W "ZB -*",! ZB -*
	W "ZContinue",! ZC
	h
EOF
	#
	#
	$GTM<<EOF
	S strg1="Current value is : "
	S mainstr="breaks reached in main..."
	S avgstr2="breaks reached in average+3^avg..."
	W "ZB average+3^avg",! ZB average+3^avg:"W !,avgstr2"
	W "Do ^avg",! do ^avg
	W "ZB ^main",! ZB ^main:"W !,mainstr"
	W "ZB cubeit^cube",! ZB cubeit^cube:"I I=3 W !,strg1,I"
	W "Do ^main",! do ^main
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	ZSH "B":local
	S x=\$o(local("B","")) f  s y(\$G(local("B",x)))="",x=\$o(local("B",x)) q:x=""
	S break=""
	W "ZSHOW B:",!
	F  S break=\$O(y(break)) Q:break=""  w !,break
	h
EOF
	#
	#
	$GTM<<EOF
	S mainstr="breaks reached in main..."
	S avgstr1="breaks reached in average^avg..."
	W "ZB ^main",! ZB ^main:"W !,mainstr"
	W "ZB average^avg",! ZB average^avg:"W !,avgstr1"
	W "Do ^main",! do ^main
	W "ZContinue",! ZC
	W "Do ^avg",! do ^avg
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	ZSH "B":local
	S x=\$o(local("B","")) f  s y(\$G(local("B",x)))="",x=\$o(local("B",x)) q:x=""
	S break=""
	W "ZSHOW B:",!
	F  S break=\$O(y(break)) Q:break=""  w !,break
	W "ZB average^avg",! ZB average^avg:"ZB average^avg"
	ZSH "B":local
	S x=\$o(local("B","")) f  s y(\$G(local("B",x)))="",x=\$o(local("B",x)) q:x=""
	S break=""
	W "ZSHOW B:",!
	F  S break=\$O(y(break)) Q:break=""  w !,break
	W "ZL main",! ZL "main"
	W "ZSHOW B",! ZSH "B"
	W "ZB fact^factor",! ZB fact^factor
	W "Do ^main",! do ^main
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZB -average^avg",! ZB -average^avg
	ZSH "B":local3
	S x=\$o(local3("B","")) f  s y(\$G(local3("B",x)))="",x=\$o(local3("B",x)) q:x=""
	S break3=""
	W "ZSHOW B:",!
	F  S break=\$O(y(break3)) Q:break3=""  w !,break3
	W "ZB average+400^avg",! ZB average+400^avg
	W "ZB nolab^avg",! ZB nolab^avg
	W "ZB average+1^avg",! ZB average+1^avg
	W "ZB average+2^avg",! ZB average+2^avg
	ZSH "B":local
	S x=\$o(local("B","")) f  s y(\$G(local("B",x)))="",x=\$o(local("B",x)) q:x=""
	S break=""
	W "ZSHOW B:",!
	F  S break=\$O(y(break)) Q:break=""  w !,break
	W "ZB average+6^avg",! ZB average+6^avg
	ZSH "B":local
	S x=\$o(local("B","")) f  s y(\$G(local("B",x)))="",x=\$o(local("B",x)) q:x=""
	S break=""
	W "ZSHOW B:",!
	F  S break=\$O(y(break)) Q:break=""  w !,break
	W "ZB -*",! ZB -*
	W "ZSHOW B",! ZSH "B"
	h
EOF
	#
	#
	echo "Test breaks in eightlab^eightrtn...."
	$GTM<<EOF
	W "ZB squaroot^squaroot",! ZB squaroot^squaroot
	W "Do ^main",! Do ^main
	W "ZContinue",! ZC
	W "ZB -*",! ZB -*
	W "ZContinue",! ZC
	h
EOF
	#
	#
	############ZSTEP Tests#############
	$GTM<<EOF
	W "ZB ^main",! ZB ^main
	W "ZB ^base",! ZB ^base
	W "Do ^main",! Do ^main
	W "ZST into",! zst into:"w \$zpos,! zp @\$zpos b"
	W "ZST into",! zst into:"w \$zpos,! zp @\$zpos b"
	W "ZST into",! zst into:"w \$zpos,! zp @\$zpos b"
	W "ZST Outof",! zst outof:"w \$zpos,! zp @\$zpos b"
	W "ZST over",! zst over:"w \$zpos,! zp @\$zpos b"
	W "ZB cubeit^cube",! ZB cubeit^cube
	W "ZST Outof",! zst outof:"w \$zpos,! zp @\$zpos b"
	W "ZST Outof",! zst outof:"w \$zpos,! zp @\$zpos b"
	W "ZST over",! zst over:"w \$zpos,! zp @\$zpos b"
	W "ZST over",! zst over:"w \$zpos,! zp @\$zpos b"
	ZSH "B":local
	S x=\$o(local("B","")) f  s y(\$G(local("B",x)))="",x=\$o(local("B",x)) q:x=""
	S break=""
	W "ZSHOW B:",!
	F  S break=\$O(y(break)) Q:break=""  w !,break
	W "ZB -cubeit^cube",! ZB -cubeit^cube
	W "ZB -^main",! ZB -^main
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZContinue",! ZC
	W "ZST into",! zst into:"w \$zpos,! zp @\$zpos b"
	W "ZST into",! zst into:"w \$zpos,! zp @\$zpos b"
	W "ZST into",! zst into:"w \$zpos,! zp @\$zpos b"
	W "Converting ",n," from base ",y," to base ",z,!
	W "ZB -*",! ZB -*
	W "ZContinue",! ZC
	h
EOF
	#
endif
$gtm_tst/com/dbcheck.csh -extract

