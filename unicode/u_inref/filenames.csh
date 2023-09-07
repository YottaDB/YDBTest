#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Since the reference file for this test has "SUSPEND_OUTPUT 4G_ABOVE_DB_BLKS" usage, it needs to fixate
# the value of the "ydb_test_4g_db_blks" env var in case it is randomly set by the test framework to a non-zero value.
if (0 != $ydb_test_4g_db_blks) then
	echo "# Setting ydb_test_4g_db_blks env var to a fixed value as reference file has 4G_ABOVE_DB_BLKS usages" >> settings.csh
	setenv ydb_test_4g_db_blks 8388608
endif

## verify the output for each step ???
#=====================================================================
# Using dbcreate.csh isn't straight forward for the below setup
# Also, the below are tests for gde to handle unicode characters and hence is better to have them here
$echoline
cat << EOF >>! ｇｄｅ.gdecmd
change -segment DEFAULT -file_name=ＲＥＧＤＥＦＡＵＬＴ.dat
add -name a* -region=areg
add -name A* -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=安办在.好
add -name b* -region=breg
add -name B* -region=breg
add -region breg -dyn=bseg
add -segment bseg -file=我能吞下玻璃而不伤身体.dat
EOF
$convert_to_gtm_chset ｇｄｅ.gdecmd

# depending on the list of locales configured, locale -a might be considered a binary output. (on scylla currently)
# grep needs -a option to process the output as text to get the actual value instead of "Binary file (standard input) matches"
# but -a is not supported on the non-linux servers we have.
if ("Linux" == "$HOSTOS") then
	set binaryopt = "-a"
else
	set binaryopt = ""
endif
set utflocale = `locale -a | $grep $binaryopt -iE 'en_us\.utf.?8$' | $head -n 1`
setenv LC_COLLATE "$utflocale" # because with LC_COLLATE C the below command fails in AIX
setenv gtmgbldir ｍｕｍｐｓ.ｇｌｄ
$GDE << EOF
@ｇｄｅ.gdecmd
exit
EOF

$echoline
$GDE << EOF
add -name c* -region=creg
add -name C* -region=creg
add -region creg -dyn=cseg
add -segment cseg -file=ＲＥＧＣ.dat
add -name d* -region=dreg
add -name D* -region=dreg
add -region dreg -dyn=dseg
add -segment dseg -file=D我能吞下玻璃而不伤身体.dat
exit
EOF

if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$echoline
$GDE << EOF
show -all
show -map
show -reg
show -region areg
show -template
exit
EOF
# ??? verify the above output in the reference file

$echoline
$MUPIP create
foreach filei (ＲＥＧＤＥＦＡＵＬＴ.dat 安办在.好 我能吞下玻璃而不伤身体.dat ＲＥＧＣ.dat D我能吞下玻璃而不伤身体.dat)
	if (! -f $filei) echo "TEST-E-NOFILE, $filei was not created!"
endif
if ($gtm_test_qdbrundown) then
	$MUPIP set -region "*" -qdbrundown >&! set_qdbrundown.out
endif

$GTM << EOF
for ii=1:1:10 set varii=ii_" ＡａＡ"_ii,^xyz(ii)=varii,^a(ii)=varii,^binregb(ii)=varii,^cats(ii)=varii,^dogs(ii)=varii
halt
EOF

$echoline
set echo; setenv gtm_chset M; unset echo
# Verify they were set correctly:
$GTM << EOF
for ii=1:1:10 do multiequal^examine(^xyz(ii),^binregb(ii),^cats(ii),^dogs(ii),ii_" ＡａＡ"_ii)
halt
EOF

$echoline
set echo; setenv gtm_chset UTF-8; unset echo

# For UTF-8, they should still be as expected:
rm examine.o
$GTM << EOF
for ii=1:1:10 do multiequal^examine(^xyz(ii),^binregb(ii),^cats(ii),^dogs(ii),ii_" ＡａＡ"_ii)
halt
EOF

##TODO## The below from the test plan is not done
#    140   Test what happens when the global diretory file is loaded in when $gtm_chset is M
#    141   mumps -direct
#    142         --> it should succeed, set some globals, verify they are fine.
#
$echoline
#- GDE -- Test that LOG filenames can be UNICODE, and that the output is encoded in utf-8. test different commands,
#  such as SHOW -ALL, and verify the output.
$GDE << EOF
LOG -ON="ｇｄｅｌｏｇ.log"
SHOW -ALL
EOF

if (! -f ｇｄｅｌｏｇ.log) then
	echo "TEST-E-GDELOGFILE, GDE log file ｇｄｅｌｏｇ.log was not created!"
endif

cat ｇｄｅｌｏｇ.log

$echoline
#- Turn journaling on. The journal filenames should include the multi-byte characters.
$MUPIP set -journal="enable,on,before,filename=mｇmｄｅｆ.mjl" -reg "DEFAULT"
$MUPIP set -journal="enable,on,before,filename=安办在.mjl" -reg "AREG"
$MUPIP set -journal="enable,on,before,filename=我能吞下玻璃而不伤身体.mjl" -reg "BREG"
$MUPIP set -journal="enable,on,before,filename=ＲＥＧＣ．ｍｊｌ" -reg "CREG" # note that the dot is the wide-dot
$MUPIP set -journal="enable,on,before,filename=D我能吞下玻璃而不伤身体.mjl" -reg "DREG"
#to ensure the timestamp skips a second or two
echo "GTM_TEST_DEBUGINFO "`date`; set echo; sleep 2; unset echo; echo "GTM_TEST_DEBUGINFO "`date`

$echoline
echo "#- Set some globals."
$GTM << EOF
for ii=1:1:5 set ^zvar(ii,"我能吞下玻璃而不伤身体",ii)="ｓｏｍｅ ｄａｔａ"
halt
EOF


$echoline
echo "#- cut a new generation jnl file for one region (DEFAULT)"
$MUPIP set -journal="enable,on,before,filename=mｇmｄｅｆ１.mjl" -reg "DEFAULT"
#to ensure the timestamp skips a second or two
echo "GTM_TEST_DEBUGINFO "`date`; set echo; sleep 2; unset echo; echo "GTM_TEST_DEBUGINFO "`date`
echo "#- ls -lt mｇmｄｅｆ*.mjl*"
ls -lt mｇmｄｅｆ*.mjl* | sed 's/^/GTM_TEST_DEBUGINFO /g' #for debugging

$echoline
$MUPIP set -journal="enable,on,before" -reg "安办在" >& mjon.log
$gtm_tst/com/check_error_exist.csh mjon.log "MUNOACTION"

echo "#- Set some globals."
$GTM << EOF
for ii=1:1:11 set ^avar(ii,"我能吞下玻璃而不伤身体",ii)="ｓｏｍｅ ｄａｔａ"
for ii=1:1:22 set ^bvar(ii,"我能吞下玻璃而不伤身体",ii)="ｓｏｍｅ ｄａｔａ"
for ii=1:1:33 set ^cvar(ii,"我能吞下玻璃而不伤身体",ii)="ｓｏｍｅ ｄａｔａ"
for ii=1:1:44 set ^dvar(ii,"我能吞下玻璃而不伤身体",ii)="ｓｏｍｅ ｄａｔａ"
for ii=1:1:88 set ^zvar(ii,"我能吞下玻璃而不伤身体",ii)="ｓｏｍｅ ｄａｔａ"
halt
EOF

$echoline
echo "#- cut a new generation jnl file for one region (DEFAULT) again"
$MUPIP set -journal="enable,on,before,filename=mｇmｄｅｆ１.mjl" -reg "DEFAULT"
echo "#- ls -lt mｇmｄｅｆ*.mjl*"
ls -lt mｇmｄｅｆ*.mjl* | sed 's/^/GTM_TEST_DEBUGINFO /g' #for debugging

echo ""
#to ensure the timestamp skips a second or two
echo "GTM_TEST_DEBUGINFO "`date`; set echo; sleep 2; unset echo; echo "GTM_TEST_DEBUGINFO "`date`

echo ""
echo "#- cut a new generation jnl file for CREG, would be named ＲＥＧＣ．ｍｊｌ.mjl"
$MUPIP set -journal="enable,on,before" -reg "CREG"

$GTM << EOF
for ii=1:1:7 set ^avar(ii,"ｓｏｍｅ",ii)="some data"
for ii=1:1:7 set ^cvar(ii,"ｓｏｍｅ",ii)="some data"
halt
EOF

#to ensure the timestamp skips a second or two
echo "GTM_TEST_DEBUGINFO "`date`; set echo; sleep 2; unset echo; echo "GTM_TEST_DEBUGINFO "`date`
echo "#- cut a new generation jnl file for DEFAULT without jnl filename"
ls -lt mｇmｄｅｆ*.mjl* | sed 's/^/GTM_TEST_DEBUGINFO /g' #for debugging
$GTM <<EOF
s ^zvar("another")="for jnl timestamp" ;To ensure the jnl file has a different timestamp"
EOF
$MUPIP set -journal="enable,on,before" -reg "DEFAULT"
ls -lt mｇmｄｅｆ*.mjl* | sed 's/^/GTM_TEST_DEBUGINFO /g' #for debugging

$echoline
echo "# - mupip journal -extract to extract from the journal files"

echo "# DEFAULT region"
# DEFAULT region's data layout should be:
# mｇmｄｅｆ.mjl -- 11-15
# mｇmｄｅｆ１.mjl_<date1> --  16-103 (defmjlprev1)
# mｇmｄｅｆ１.mjl_<date2> -- 103-103 (defmjlprev2)
# the following section tests this layout

echo "# mｇmｄｅｆ.mjl"
$MUPIP journal -extract -forward mｇmｄｅｆ.mjl
# tn starts from 11 since there were 10 updates before
$gtm_tst/com/analyze_jnl_extract.csh mｇmｄｅｆ.mjf 11 15 tn

$echoline

set cnt = `ls -l mｇmｄｅｆ１.mjl_* | wc -l`
if (2 != $cnt) then
	echo "TEST-E-PREVMJL, count of mjl files not as expected: $cnt"
	ls -l mｇmｄｅｆ１.mjl*
endif

echo "# defmjlprev1"
set defmjlprev1 = `ls -rt mｇmｄｅｆ１.mjl_*| $head -n 1`
echo "GTM_TEST_DEBUGINFO $defmjlprev1"
if (! -e $defmjlprev1) then
	echo "TEST-E-PREVJNL, previous jnl filename not as expected: $defmjlprev1"
endif

$MUPIP journal -extract -forward $defmjlprev1
$gtm_tst/com/analyze_jnl_extract.csh mｇmｄｅｆ１.mjf 16 103 tn
echo "GTM_TEST_DEBUGINFO "`date`; set echo; sleep 2; unset echo; echo "GTM_TEST_DEBUGINFO "`date`

echo "# defmjlprev2"
set defmjlprev2 = `ls -rt mｇmｄｅｆ１.mjl_*| $tail -n 1`
echo "GTM_TEST_DEBUGINFO $defmjlprev2"
if (! -e $defmjlprev2) then
	echo "TEST-E-PREVJNL, previous jnl filename not as expected: $defmjlprev2"
endif

$MUPIP journal -extract -forward $defmjlprev2
$gtm_tst/com/analyze_jnl_extract.csh mｇmｄｅｆ１.mjf 104 104 tn

set cnt = `ls -l mｇmｄｅｆ１.mjf* | wc -l`
if (2 != $cnt) then
	echo "TEST-E-PREVMJF, mjf files not as expected: $cnt"
	ls -l mｇmｄｅｆ１.mjf*
endif

echo "# mｇmｄｅｆ１.mjl"
$MUPIP journal -extract -forward mｇmｄｅｆ１.mjl
$gtm_tst/com/analyze_jnl_extract.csh mｇmｄｅｆ１.mjf 0 0 tn # empty jnl file
unset echo

$echoline
echo "#AREG"
$MUPIP journal -extract -forward 安办在.mjl
$gtm_tst/com/analyze_jnl_extract.csh 安办在.mjf 11 28 tn

echo "#BREG"
$MUPIP journal -extract -forward 我能吞下玻璃而不伤身体.mjl
$gtm_tst/com/analyze_jnl_extract.csh 我能吞下玻璃而不伤身体.mjf 11 32 tn

echo "#CREG"
set cmjlprev = `ls ＲＥＧＣ．ｍｊｌ.mjl_*`
echo "GTM_TEST_DEBUGINFO $cmjlprev"
if (! -e $cmjlprev) then
	echo "TEST-E-PREVJNL, previous jnl filename cmjlprev not as expected: $cmjlprev"
endif
$MUPIP journal -extract -forward $cmjlprev
$gtm_tst/com/analyze_jnl_extract.csh ＲＥＧＣ．ｍｊｌ.mjf 11 43 tn

$MUPIP journal -extract -forward ＲＥＧＣ．ｍｊｌ.mjl
$gtm_tst/com/analyze_jnl_extract.csh ＲＥＧＣ．ｍｊｌ.mjf 44 50 tn

echo "#DREG"
$MUPIP journal -extract -forward D我能吞下玻璃而不伤身体.mjl
$gtm_tst/com/analyze_jnl_extract.csh D我能吞下玻璃而不伤身体.mjf 11 54 tn

$echoline
echo "# - mupip journal -show "
echo "#AREG"
$MUPIP journal -show=header -forward 安办在.mjl
# now that we have one full output, let us just focus on the fields that will have the multibyte characters
echo "#BREG"
$MUPIP journal -show=header -forward 我能吞下玻璃而不伤身体.mjl |& tee breg_mjl_show.out |& $head -n 14
echo "#CREG"
$MUPIP journal -show=header -forward  $cmjlprev |& tee creg_mjl_show_header.out |& $head -n 14
$MUPIP journal -show=all -forward  ＲＥＧＣ．ｍｊｌ.mjl |& tee creg_mjl_show_all.out |& $head -n 14
echo "#DREG"
$MUPIP journal -show=header -forward D我能吞下玻璃而不伤身体.mjl |& tee dreg_mjl_show.out |& $head -n 14
echo "#DEFAULT"
$MUPIP journal -show=header -forward mｇmｄｅｆ.mjl |& tee defreg_mjl1_show.out |& $head -n 14
$MUPIP journal -show=header -forward $defmjlprev1 |& tee defreg_mjl2_show.out |& $head -n 14
$MUPIP journal -show=header -forward $defmjlprev2 |& tee defreg_mjl3_show.out |& $head -n 14
$MUPIP journal -show=header -forward mｇmｄｅｆ１.mjl |& tee defreg_mjl4_show.out |& $head -n 14


$echoline
echo "#- mupip backup to a directory with a name with unicode characters"
mkdir backupｂａｃｋｕｐ我

$MUPIP backup "*" backupｂａｃｋｕｐ我 >&! mupip_backup.out
$grep "%YDB-I-BACKUPTN, Transactions from" mupip_backup.out | sort
echo ""
$grep "BACKUP COMPLETED" mupip_backup.out

echo "#Contents of the backup directory:"
# this ugly coding is because the ordering of ls with unicode is not consistant across machines and across different runs in a same machine
cd backupｂａｃｋｕｐ我/ ;ls ＲＥＧＤＥＦＡＵＬＴ.dat ;ls 安办在.好 ;ls 我能吞下玻璃而不伤身体.dat ;ls ＲＥＧＣ.dat ;ls D我能吞下玻璃而不伤身体.dat ;cd -

# just to check, move back DEFAULT region's database:
cp -p backupｂａｃｋｕｐ我/ＲＥＧＤＥＦＡＵＬＴ.dat .
$GTM << EOF
do ^examine(\$DATA(^zvar),10,"^zvar should have descendants")
set ^zvar="hello"
write ^zvar,!
halt
EOF

$echoline
$DSE << EOF >&! dse_dump_file1.out
find -reg=AREG
dump -file
find -reg=BREG
dump -file
find -reg=CREG
dump -file
find -reg=DREG
dump -file
find -reg=DEFAULT
dump -file
EOF


echo "#- mupip set -file ... -glo="
echo "#	--> Change the global buffers, and verify that it worked."
echo "#AREG"
$MUPIP set -file 安办在.好 -glo=2048
echo "#BREG"
$MUPIP set -file 我能吞下玻璃而不伤身体.dat -glo=4096
echo "#CREG"
$MUPIP set -file ＲＥＧＣ.dat -glo=2048
echo "#DREG"
$MUPIP set -region DREG -glo=2048
echo "#DEFAULT"
$MUPIP set -file ＲＥＧＤＥＦＡＵＬＴ.dat -glo=4096

echo "#- mupip extend the databases"
echo "#	--> This should succeed, verify the new block count."
echo "#AREG"
$MUPIP extend -blocks=100 AREG
echo "#BREG"
$MUPIP extend -blocks=200 BREG
echo "#CREG"
$MUPIP extend -blocks=300 CREG
echo "#DREG"
$MUPIP extend -blocks=400 DREG
echo "#DEFAULT"
$MUPIP extend -blocks=500 DEFAULT

$DSE << EOF >&! dse_dump_file2.out
find -reg=AREG
dump -file
find -reg=BREG
dump -file
find -reg=CREG
dump -file
find -reg=DREG
dump -file
find -reg=DEFAULT
dump -file
EOF

echo "# verify the new Global Buffers and Total blocks"
echo "# Compare global buffers before and after the mupip set done above"
$grep "Global Buffers" dse_dump_file1.out > glo1.out
$grep "Global Buffers" dse_dump_file2.out > glo2.out
diff glo1.out glo2.out

echo "# Compare total blocks count before and after the mupip extend done above"
$grep "Total blocks" dse_dump_file1.out > blk1.out
$grep "Total blocks" dse_dump_file2.out > blk2.out
diff blk1.out blk2.out

$echoline

echo "#- Test that DSE DUMP -fileheader and DSE DUMP -fileheader -all shows the filenames correctly (database and journal)."
$grep "File" dse_dump_file2.out

$DSE dump -file -all >& dse_dump_file_all.out
$grep -E "^File |Journal File: " dse_dump_file_all.out

$echoline
echo "#- mupip extract the data"
$MUPIP extract ｍｕｐｉｐｅｘｔ1.ext
$MUPIP extract << EOF
ｍｕｐｉｐｅｘｔ2.ext
EOF

if (! -e ｍｕｐｉｐｅｘｔ1.ext) then
	echo "TEST-E-EXTRFILE ｍｕｐｉｐｅｘｔ1.ext not found"
endif
if (! -e ｍｕｐｉｐｅｘｔ2.ext) then
	echo "TEST-E-EXTRFILE ｍｕｐｉｐｅｘｔ2.ext not found"
endif
$head -n 2 ｍｕｐｉｐｅｘｔ1.ext
$head -n 2 ｍｕｐｉｐｅｘｔ2.ext

$echoline
echo "#- mupip load using a filename with multi-byte characters."
echo "#	--> This should succeed."
\rm -f ＲＥＧＣ.dat ＲＥＧＤＥＦＡＵＬＴ.dat
echo "# mupip create - will give 'File exists' error for the existing database files... please ignore"
$MUPIP create
if ($gtm_test_qdbrundown) then
	$MUPIP set -region "*" -qdbrundown >>&! set_qdbrundown.out
endif
echo "# mupip load ｍｕｐｉｐｅｘｔ1.ext"
$MUPIP load  ｍｕｐｉｐｅｘｔ1.ext
echo "# now do mupip extract into ｍｕｐｉｐｅｘｔ3.ext"
$MUPIP extract ｍｕｐｉｐｅｘｔ3.ext
echo "# check if the two extracts ｍｕｐｉｐｅｘｔ1.ext and ｍｕｐｉｐｅｘｔ3.ext differ"
set lines=`wc -l ｍｕｐｉｐｅｘｔ1.ext | $tst_awk '{print $1}'`
@ lines = $lines - 2
$tail -n $lines ｍｕｐｉｐｅｘｔ1.ext >&! mupipext1.tail
set lines=`wc -l ｍｕｐｉｐｅｘｔ3.ext | $tst_awk '{print $1}'`
@ lines = $lines - 2
$tail -n $lines ｍｕｐｉｐｅｘｔ3.ext >&! mupipext3.tail

\diff mupipext1.tail mupipext3.tail >& /dev/null ##BYPASSOK tail
if ($status) then
	echo "TEST-E-LOAD mupip load test failed. Check the extract files for the diff"
	echo "ｍｕｐｉｐｅｘｔ1.ext ｍｕｐｉｐｅｘｔ3.ext"
else
	echo "TEST-I-PASS mupip load test passed."
endif

$echoline
echo "#- mupip freeze one of the databases."
echo "#	--> This should succeed, verify the freeze is effective by attempting to change a global in a frozen region."
cat << \EOF >& frozen.m
 write "PID: ",$JOB,!
 set h1=$H
 write "GTM_TEST_DEBUGINFO h1:",h1,!
 set ^xxx="is it frozen?"
 set h2=$H
 set diff=$$^difftime(h2,h1)
 if (diff<9) write "TEST-E-FROZEN",!
 else  write "PASS",!
 write "GTM_TEST_DEBUGINFO h2:",h2,!
\EOF

$MUPIP freeze -on DEFAULT >& freeze_on_DEFAULT.out
$gtm_exe/mumps -run frozen >& frozen.log &
echo "GTM_TEST_DEBUGINFO "`date`; set echo; sleep 12; unset echo; echo "GTM_TEST_DEBUGINFO "`date`
$MUPIP freeze -off DEFAULT >& freeze_off_DEFAULT.out
$gtm_tst/com/wait_for_log.csh -log frozen.log -message "PID" -waitcreation
set pid = `$grep PID frozen.log | sed 's/.* //g'`
$gtm_tst/com/wait_for_proc_to_die.csh $pid
$grep -v PID frozen.log

$echoline
echo "#- error from MUPIP freeze: nonexisting region"
mv ＲＥＧＤＥＦＡＵＬＴ.dat ＲＥＧＤＥＦＡＵＬＴ.datt
$MUPIP freeze -on DEFAULT >& freeze_err.log
set errENO = "ENO2"
$gtm_tst/com/check_error_exist.csh freeze_err.log $errENO MUNOACTION
echo "# cat freeze_err.log"
cat freeze_err.log

mv ＲＥＧＤＥＦＡＵＬＴ.datt ＲＥＧＤＥＦＡＵＬＴ.dat

$echoline
echo "#- Lock some globals, and test that the -OUTPUT qualifier of LKE SHOW and CLEAR can write into files with names"
echo "#  with multi-byte characters."
echo "#  Note that this is NOT the test for multi-byte characters in the locked variables, that test is in the locks test."
cat << \EOF > locks.m
startjob ;
	set jmaxwait=0
	do ^job("child^locks",1,"""""")
	quit
child	;
	write "Here in child, will lock some variables",!
	lock ^a("ａｂｃ")
	lock +z("我能吞下玻璃而不伤身体")
	lock +^b(1,"ａｂｃ")
	lock +^b("我能吞下玻璃而不伤身体")
	set ^childlocks=1
	write $HOROLOG
	for i=1:1  quit:1=$DATA(^stop)  hang 1
	write "All done!",!
	quit
waitjob ;
	set ^stop=1
	do wait^job
	quit
\EOF

echo "#lock some globals"
$GTM << EOF
do startjob^locks
for i=1:1:120 quit:1=\$DATA(^childlocks)  h 1
if (120=i) write "Wait timed out",! zshow "*"
halt
EOF

$LKE show -all
echo "#lke and output files"
$LKE << EOF
show -all -output=lke_show_ｏｕｔｐｕｔ1.out
clear -region=BREG -output=lke_clear_ｏｕｔｐｕｔ1.out -nointeractive
exit
EOF

$LKE show -all -output=lke_show_ｏｕｔｐｕｔ2.out

$LKE clear -all -nointeractive -output=lke_clear_ｏｕｔｐｕｔ2.out
echo "# all locks should be gone now"
$LKE show -all

more lke_*.out >& filenames_lke.log
$gtm_tst/com/check_reference_file.csh $gtm_tst/$tst/outref/filenames_lke.txt filenames_lke.log
set stat = $status
if ($stat) then
    echo "-------------------------------------------------------------"
    echo "TEST-E-FILENAMES FAIL - See diff in filenames_lke.diff"
    echo "-------------------------------------------------------------"
endif

echo "#release the job"
$GTM << EOF
do waitjob^locks
halt
EOF

$echoline
echo "#- job off a process with the log and error going to filenames with multi-byte characters."
cat << \EOF >& joboff.m
joboff	;
	write "PID: ",$JOB,!
	write "Here in the jobbed off process",!
	w 1/0	;!intentional error!
	halt
\EOF

$GTM << EOF
job ^joboff:(output="ｊｏｂｏｆｆ.ｍｊｏ":error="ｊｏｂｏｆｆ.ｍｊｅ")
h 5
halt
EOF

if (! -e ｊｏｂｏｆｆ.ｍｊｏ) then
	echo "TEST-E-JOB output file not found"
endif
if (! -e ｊｏｂｏｆｆ.ｍｊｅ) then
	echo "TEST-E-JOB error file not found"
endif
echo "grep -v PID ｊｏｂｏｆｆ.ｍｊｏ"	# BYPASSOK grep
$grep -v PID ｊｏｂｏｆｆ.ｍｊｏ
$gtm_tst/com/check_error_exist.csh ｊｏｂｏｆｆ.ｍｊｅ DIVZERO

$echoline
echo "#- Create a replication instance file 我能吞下玻璃而不伤身体.repl, with -name=我能吞"
setenv gtm_repl_instance 我能吞下玻璃而不伤身体.repl
$MUPIP replic -instance_create $gtm_test_qdbrundown_parms -name=我能吞

echo "#- Attempt a mupip replic command with an instance name that has multi-byte characters"
echo "(such as mupip replic -source -start -instsecondary=我能吞我能)"
$MUPIP set -replication=on -reg "*" >&! replic_on.out
$MUPIP replic -source -start -passive -instsecondary=我能吞我能 -log=passive.log -buff=1
echo "#- editinstance -show"
$MUPIP replic -editinstance -show 我能吞下玻璃而不伤身体.repl>&! replinst_show.out
set jnlseqno = 0
source $gtm_tst/com/can_ipcs_be_leftover.csh
if ($status) then
	# This means $gtm_db_counter_sem_incr is set and is non-zero
	# Depending upon the value of $gtm_db_counter_sem_incr and the system limit, buffer overflow might have occurred due to
	# both the startup command and the actual passiver source server bumping up ipcs. And since the overflow occurs, we flush the instance file header from shared memory to disk.
	# thereby flushing the jnl_seqno value stored in shm which is 1 (initialized at passive source server startup). Whereas without any overflow the instance file is untouched
	set jnlseqno = '01'
endif
sed 's/HDR Journal Sequence Number                              ['$jnlseqno'].* .0x000000000000000../HDR Journal Sequence Number                   ##FILTERED##/' replinst_show.out
echo "#- shutdown the instance"
$MUPIP replic -source -shut -instsecondary=我能吞我能 -time=0

$echoline
echo "#- set an environment variable envvar_ｅｎｖ to some value, and attempt to read the value from GTM."
echo "#	--> It should succeed."
setenv envvar_ｅｎｖ "some value, ｌｏｏｋ"
$GTM << EOF
set var=\$ZTRNLNM("envvar_ｅｎｖ")
write "The value read from the environment variable is:",var,!
halt
EOF

$echoline
echo "#- try some command that does not accept multi-byte characters, and see the error makes sense."
$GTM << EOF >>& gtm_errors.log
ｗｒｉｔｅ "abc",!
write ａｂｃ,!
set x=3+ａ
write "But there is an error ｏｎ ｔｈｉｓ ｌｉｎｅ!",!,,
EOF

# Let's not use check_error_exist here so that we can get the output altogether
mv gtm_errors.log gtm_errors.logx
sed 's/-E-/_E_/g' gtm_errors.logx > gtm_errors.log
cat gtm_errors.log


$echoline
echo "#- mupip integ"
$MUPIP integ -region "*" >& integ_star.out
echo "#AREG"
$MUPIP integ -file 安办在.好 >& integ_areg.out
echo "#BREG"
$MUPIP integ -file 我能吞下玻璃而不伤身体.dat>& integ_breg.out
echo "#CREG"
$MUPIP integ -file ＲＥＧＣ.dat>& integ_creg.out
echo "#DREG"
$MUPIP integ -file D我能吞下玻璃而不伤身体.dat>& integ_dreg.out
echo "#DEFAULT"
$MUPIP integ -file ＲＥＧＤＥＦＡＵＬＴ.dat >& integ_defreg1.out
$MUPIP integ -region DEFAULT >& integ_defreg2.out

$grep "No errors" integ*.out


$echoline
$gtm_tst/com/dbcheck.csh
#################################################################################################################
#-------------------
# cheat-sheet for region names, database filenames, and (final state of) journal filenames used in this test
#-------------------
#AREG
#db: 安办在.好
#jnl: 安办在.mjl
#-------------------
#BREG
#db: 我能吞下玻璃而不伤身体.dat
#jnl: 我能吞下玻璃而不伤身体.mjl
#-------------------
#CREG
#db: ＲＥＧＣ.dat
#jnl: ＲＥＧＣ．ｍｊｌ -- cmjlprev
#ＲＥＧＣ．ｍｊｌ.mjl
#-------------------
#DREG
#db: D我能吞下玻璃而不伤身体.dat
#jnl: D我能吞下玻璃而不伤身体.mjl
#-------------------
#DEFAULT
#db: ＲＥＧＤＥＦＡＵＬＴ.dat
#jnl:
#mｇmｄｅｆ.mjl
#mｇmｄｅｆ１.mjl_date1 -- defmjlprev1
#mｇmｄｅｆ１.mjl_date1 -- defmjlprev2
#mｇmｄｅｆ１.mjl
#-------------------
