#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#########################################
### mu_load.csh  test for mupip load  ###
#########################################
#
#
echo MUPIP LOAD
#
#
##############################
# STEP 1. basic extract/load #
##############################
#
# 1.1 go and binary format
##########################
#
# 'go' format is not supported in UTF-8 mode
# Since the intent of the subtest is explicitly check the go and binary format, it is forced to run in M mode
$switch_chset M >&! switch_chset.out
@ corecnt = 1
setenv gtmgbldir "load.gld"
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh "load" 1 125 700 1536 9900 256
else
	$gtm_tst/com/dbcreate.csh "load" 1 125 700 1536 100 256
endif
#
#
$GTM << GTM_EOF
view "gdscert":1
w "do in0^dbfill(""set"")",!
d in0^dbfill("set")
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$MUPIP extract -format=go -label=bc -sel="bc*","^d*" b-c.glo
if ( $status > 0 ) then
    echo ERROR from mupip extract 1.
    exit 1
endif
#
#
$GTM << GTM_EOF
view "gdscert":1
w "do in1^dbfill(""set"")",!
d in1^dbfill("set")
w "\$MUPIP extract -format=binary -label=YX -sel=""YX*"",""d*"" yx.bin",!
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$MUPIP extract -format=binary -label=YX -sel="YX*","d*" yx.bin
if ( $status > 0 ) then
    echo ERROR from mupip extract 2.
    exit 2
endif
#
#
$GTM << GTM_EOF
w "k ^bcde",!
k ^bcde
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
# A BUG.
# Upon success, MUPIP should return 0, instead of 1.
# Modify the following correspondingly after it is fixed.
$MUPIP load -format=go b-c.glo >&! bc.log
if ($status != 0) then
	echo "Loading b-c.glo was unsuccessful"
else
	echo "Loading b-c.glo was successful"
endif
#
#
$MUPIP load -format=binary yx.bin >&! yx.log
if ($status != 0) then
	echo "Loading yx.bin was unsuccessful"
else
	echo "Loading yx.bin was successful"
endif
#
#
$GTM << GTM_EOF
view "gdscert":1
w "do in0^dbfill(""ver"")",!
d in0^dbfill("ver")
w "do in1^dbfill(""ver"")",!
d in1^dbfill("ver")
w "h",!
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
# 1.2 SEQUENCIAL LOAD
#####################
#
#
$GTM << GTM_EOF
s ^aaaaaa="right"
s ^aaaaa="right"
s ^aaaa="right"
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$MUPIP extract -format=binary -label=li1 -sel=a:b aaa.bin
if ( $status > 0 ) then
    echo ERROR from binary extract
    exit 5
endif
#
#
$GTM << GTM_EOF
s ^aaaaaa="wrong"
s ^aaaaa="wrong"
s ^aaaa="wrong"
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$MUPIP load -format=binary aaa.bin
if ( $status != 0 ) then
    echo ERROR from binary load.
    exit 6
endif
#
#
$GTM << GTM_EOF
w ^aaaaaa," ",^aaaaa," ",^aaaa,!
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$MUPIP extract -label=li2 -sel="aaa*" -nolog -fo=go aaa.glo
if ( $status > 0 ) then
    echo ERROR from ascii extract
    exit 7
endif
#
#
$GTM << GTM_EOF
s ^aaaaaa="wrong"
s ^aaaaa="wrong"
s ^aaaa="wrong"
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$MUPIP load -format=go aaa.glo >&! bbb.log
if ( $status != 0 ) then
    echo ERROR from ascii load.
    exit 8
endif
#
#
$GTM << GTM_EOF
w ^aaaaaa," ",^aaaaa," ",^aaaa,!
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
#
# 1.3 CONCURRENT LOAD
#####################
#
#
$GTM << GTM_EOF
d fill5^myfill("right")
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$MUPIP extract -format=go -label=li3 -sel="aaa*" ccc.glo
if ($status > 0) then
    echo ERROR from concurrent load 1.
    exit 9
endif
$MUPIP extract -format=go -label=li4 -sel="bbb*" ddd.glo
if ($status > 0) then
    echo ERROR from concurrent load 2.
    exit 10
endif
#
#
$GTM << GTM_EOF
s ^flagflag=1
d fill5^myfill("wrong")
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
(($MUPIP load -format=go ccc.glo >&! ccc.log;  $gtm_exe/mumps -r setflag ) &) >&! /dev/null
$MUPIP load -format=go ddd.glo >&! ddd.log
if ($status != 0) then
    echo ERROR with concurrent load.
    exit 11
endif
#
#
$GTM <<GTM_EOF
for i=1:1:100 q:^flagflag=0  h 1
d fill5^myfill("ver")
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$gtm_tst/com/dbcheck.csh
#
#
#
##########################
# STEP 2.                #
#    1. multi-region     #
#    2. extract -freeze  #
#    3. load -fill       #
##########################
#
#
setenv gtmgbldir "load2.gld"
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
		set colno = $test_collation_no
	endif
	setenv test_specific_gde $gtm_tst/$tst/inref/mu_load_col${colno}.gde
endif
setenv gtm_test_spanreg 0	# We have already pointed a spanning gld to test_specific_gde
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh "load2" 3 125 700 1536 300 256
else
	$gtm_tst/com/dbcreate.csh "load2" 3 125 700 1536 100 256
endif
#
#
$GTM << GTM_EOF
d fill4^myfill("set")
zsy "$MUPIP extract -format=go -freeze big.glo"
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
# real stuff to be added later
echo PASS from mupip extract freeze.
#
#
$GTM << GTM_EOF
d fill4^myfill("kill")
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$MUPIP load -format=go -fill=5 big.glo >&! big.log
if ($status == 0) then
    echo loading big.glo successful.
else
    echo ERROR from loading big.glo.
endif
#
#
$GTM << GTM_EOF
d fill4^myfill("ver")
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "lo" "$corecnt" "FAIL"
#
#
$gtm_tst/com/dbcheck.csh
#
#
###########################
### END of mu_load.csh  ###
###########################
