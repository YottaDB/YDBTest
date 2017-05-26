#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2007, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
unsetenv gtm_replic
unsetenv test_replic
echo MUPIP UNICODE EXTRACT LOAD
setenv gtmgbldir "load.gld"
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh "load" 1 250 700 1536 20000 256
else
	$gtm_tst/com/dbcreate.csh "load" 1 250 700 1536 100 256
endif
$GTM << GTM_EOF
w "do in0^udbfill(""set"")",!
d in0^udbfill("set")
for i=0:1:300 set ^%utf8char(\$C(i))=i
set ^%lsps(\$C(8232,8233))="To test if LS and PS "_\$C(8232,8233)_" works"
h
GTM_EOF
#
# DISABLED due to below mentioned reason
#
#echo $MUPIP extract -format=go -label=αβγδε -sel="bc*","^d*","%utf8char" αβγδε.go
#$MUPIP extract -format=go -label=αβγδε -sel="bc*","^d*","%utf8char" αβγδε.go
#if ( $status != 0 ) echo Fail from mupip extract
##
#
$GTM << bbbb
w "do in1^udbfill(""set"")",!
d in1^udbfill("set")
h
bbbb
echo $MUPIP extract -format=binary -log -label=YXdutf8 -sel="YX*","d*","%utf8char" ＸＹ.ＢＩＮ
$MUPIP extract -format=binary -log -label=YXdutf8 -sel="YX*","d*","%utf8char" ＸＹ.ＢＩＮ
if ( $status != 0 ) echo Fail from mupip extract
#
$GTM << bbbb
w "do in2^udbfill(""set"")",!
d in2^udbfill("set")
h
bbbb
echo $MUPIP extract -format=zwr -nolog -label=我能吞下玻璃而不伤身体 ＤＡＴＡ.ＺＷＲ
$MUPIP extract -format=zwr -nolog -label=我能吞下玻璃而不伤身体 ＤＡＴＡ.ＺＷＲ
if ( $status != 0 ) echo Fail from mupip extract
#
#
# DISABLED due to below mentioned reason
#
#\rm *.dat
#echo $MUPIP create
#$MUPIP create
#echo $MUPIP load -format=go αβγδε.go
#$MUPIP load -format=go αβγδε.go
#if ($status != 0) echo "Loading was unsuccessful"
#$gtm_tst/com/dbcheck.csh
#$GTM << dddd
#for i=0:1:300 do ^examine(\$get(^%utf8char(\$C(i))),i,"%utf8char("_i_")")
#w "h",!
#h
#dddd
#
\rm *.dat
echo $MUPIP create
$MUPIP create
echo $MUPIP load -format=binary ＸＹ.ＢＩＮ
$MUPIP load -format=binary ＸＹ.ＢＩＮ
if ($status != 0) echo "Loading was unsuccessful"
$gtm_tst/com/dbcheck.csh
# from here on no dbcreates are done so disable dbcheck from regenerating the .sprgde file using -nosprgde
$GTM << dddd
for i=0:1:300 do ^examine(\$get(^%utf8char(\$C(i))),i,"%utf8char("_i_")")
w "h",!
h
dddd
#
#
\rm *.dat
echo $MUPIP create
$MUPIP create
echo $MUPIP load -format=zwr ＤＡＴＡ.ＺＷＲ
$MUPIP load -format=zwr ＤＡＴＡ.ＺＷＲ
if ($status != 0) echo "Loading was unsuccessful"
$gtm_tst/com/dbcheck.csh -nosprgde
#
$GTM << dddd
w "do in0^udbfill(""ver"")",!
d in0^udbfill("ver")
w "do in1^udbfill(""ver"")",!
d in1^udbfill("ver")
w "do in2^udbfill(""ver"")",!
d in2^udbfill("ver")
for i=0:1:300 do ^examine(\$get(^%utf8char(\$C(i))),i,"%utf8char("_i_")")
w "h",!
h
dddd
#
#
#########################################3
#
echo Now load from different encoding
\rm *.o
# DISABLED due to below mentioned reason
#
#\rm *.dat
#setenv gtm_chset M
#$MUPIP create
#echo $MUPIP load -format=go αβγδε.go
#$MUPIP load -format=go αβγδε.go
#if ($status != 0) echo "Loading was unsuccessful as expected"
#$switch_chset UTF-8
#$gtm_tst/com/dbcheck.csh -nosprgde
#
\rm *.dat
setenv gtm_chset M
$MUPIP create
echo $MUPIP load -format=binary ＸＹ.ＢＩＮ
$MUPIP load -format=binary ＸＹ.ＢＩＮ
if ($status != 0) echo "Loading was unsuccessful as expected"
$switch_chset UTF-8
$gtm_tst/com/dbcheck.csh -nosprgde
#
#
\rm *.dat
setenv gtm_chset M
$MUPIP create
echo $MUPIP load -format=zwr ＤＡＴＡ.ＺＷＲ
$MUPIP load -format=zwr ＤＡＴＡ.ＺＷＲ
if ($status != 0) echo "Loading was unsuccessful as expected"
$switch_chset UTF-8
$gtm_tst/com/dbcheck.csh -nosprgde

exit
# Below cannot be done for some S/W issues.
# TODO Enable if S/W is fixed
#
#########################################3
#
echo Now load from same UTF-8 encoding but differnt format
#
\rm *.dat
$MUPIP create
echo $MUPIP load -format=ZWR αβγδε.go
$MUPIP load -format=ZWR αβγδε.go
if ($status != 0) echo "Loading was unsuccessful as expected"
#
\rm *.dat
$MUPIP create
echo $MUPIP load -format=BIN αβγδε.go
$MUPIP load -format=BIN αβγδε.go
if ($status != 0) echo "Loading was unsuccessful as expected"
#
\rm *.dat
$MUPIP create
echo $MUPIP load -format=go ＤＡＴＡ.ＺＷＲ
$MUPIP load -format=go ＤＡＴＡ.ＺＷＲ
if ($status != 0) echo "Loading was unsuccessful as expected"
#
\rm *.dat
$MUPIP create
echo $MUPIP load -format=binary ＤＡＴＡ.ＺＷＲ
$MUPIP load -format=binary ＤＡＴＡ.ＺＷＲ
if ($status != 0) echo "Loading was unsuccessful as expected"
#
\rm *.dat
$MUPIP create
echo $MUPIP load -format=GO ＸＹ.ＢＩＮ
$MUPIP load -format=GO ＸＹ.ＢＩＮ
if ($status != 0) echo "Loading was unsuccessful as expected"
#
\rm *.dat
$MUPIP create
echo $MUPIP load -format=ZWR ＸＹ.ＢＩＮ
$MUPIP load -format=ZWR ＸＹ.ＢＩＮ
if ($status != 0) echo "Loading was unsuccessful as expected"
#
