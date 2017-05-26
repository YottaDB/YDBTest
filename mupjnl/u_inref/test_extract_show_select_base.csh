#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This takes care of test cases 23, and 26:
# Test Case # 23:  (extract with selection qualifiers with BIJ, also for D9C09-002218)
# Test Case # 26:  (show options with selection qualifiers with BIJ)
# D9C09-002218 MUPIP JOURNAL -EXTRACT -GLOBAL does not work right


unset backslash_quote
alias check_mjf 'echo \!:*; ($tst_awk -f $gtm_tst/$tst/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" \!:* | sed '"'"'s/\\/ %/g;s/.*:://g'"'"' | $tst_awk -F% -f $gtm_tst/$tst/inref/extract_summary.awk > \!:*_analysis); cat \!:*_analysis; $gtm_exe/mumps -run mjfhdate \!:* > \!:*_date'
##NOTE extract_summary.awk ignores EPOCH records

set test_extract = 1
set test_show = 1

$gtm_tst/com/dbcreate.csh . 1
setenv tst_jnl_str_save $tst_jnl_str
#setenv tst_jnl_str "-journal=enable,on,nobefore"
echo "Turn journaling on:"
$gtm_tst/com/jnl_on.csh
$grep "OPTIONS" jnl.log
echo "####################################################################"
echo "# database with some active transactions (and an active process of another user)"
echo "####################################################################"

$gtm_tst/com/abs_time.csh time1
setenv time1  `cat time1_abs`
$GTM << EOF
d p1^user1
EOF
##############################################################
echo "Start second process (as another user)..."
$gtm_tst/$tst/u_inref/other_user.csh user2 > other_user.log

echo "Wait for second user to finish its processing..."
$GTM << ENDWAIT
w "\$H = ",\$H,!
for i=1:1:240 quit:\$data(^sema1)  h 1
i i=240 w "TEST-E-TIMEOUT: USER2 DID NOT FINISH ITS PROCESSING"
w "second user should have finished",!
w "\$H = ",\$H,!
ENDWAIT
echo "Updates done, test..."
echo ""
##############################################################

$GTM << EOF
d p3^user1
view "JNLFLUSH"
EOF

## this step is necessary to ensure an extra EPOCH is written that updates the End Transaction number in the jnl file header
## if the extra EPOCH is not written, P2 (second process) which is running concurrently randomly writes an EPOCH
##	and this random EPOCH will update the End Transaction in the journal show header output done later below
## this causes unreliable output and in turn reference file issues. to avoid this, we write an extra EPOCH ourselves.
## the buff command needs to be done twice since the first one does not update the journal file header (see jnl_write_epoch_rec.c)
$DSE << EOF >&! dse_buff.log
	buff
	buff
EOF

set pid1 = `cat job1.pid`
set pid2 = `cat job2.pid`
set pid3 = `cat job3.pid`
set pid4 = 0
set pid5 = 1


if ($?test_extract) then
	echo "######################################"
	echo "EXTRACT"
	echo ""
	echo "First extract all"
	$GTM << EOF
	view "JNLFLUSH"
	h
EOF

	set verbose
	$MUPIP journal -extract=total.mjf -detail  -broken=total.broken -lost=total.lost -forward mumps.mjl
	check_mjf total.mjf
	check_mjf total.broken
	check_mjf total.lost
	$grep -v PINI total.mjf_analysis >  total.mjf_analysis_noPINI
	################################################################################
	$MUPIP journal -global="^A*,^C" -extract=globalac.mjf  -detail -forward mumps.mjl
	check_mjf globalac.mjf
	#Expected result: extracted globals ^A, ^AA, ^AAA, ^C to global.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -global="~(^*A*,^C,^*B*)" -extract=global_m_abc.mjf  -detail -forward mumps.mjl
	check_mjf global_m_abc.mjf
	#Expected result: extracted globals ^CC, ^CCC
	#Return status: success
	################################################################################
	$MUPIP journal -global="^*A" -extract=globalstara.mjf  -detail -forward mumps.mjl
	check_mjf globalstara.mjf
	#Expected result: extracted globals  ^A, ^XA, (but not ^AA, ^AAA, as they are subscripted)
	################################################################################
	$MUPIP journal -extract=globalasub1.mjf -forward -global=\"^A\(1\),^AA\" mumps.mjl
	check_mjf globalasub1.mjf
	#Expected result: extracted globals  ^A(1), ^A(1,"str") and ^AA
	################################################################################
	$MUPIP journal -extract=globalasub1a.mjf -forward -global=\"^A\(1\)\" -detail mumps.mjl
	check_mjf globalasub1a.mjf
	#Expected result: extracted globals  ^A(1), ^A(1,"str")
	################################################################################
	$MUPIP journal -extract=globalasub2.mjf -forward -global=\"^A\(1,\"\"str\"\"\),^AA\" -detail mumps.mjl
	check_mjf globalasub2.mjf
	#Expected result: extracted globals  ^A(1,"str"), ^AA
	################################################################################
	$MUPIP journal -extract=globalasub3.mjf -forward -global=\"^A\(1,\*\),^AA\" -detail mumps.mjl
	check_mjf globalasub3.mjf
	#Expected result: extracted globals  ^A(1,*), ^AA
	################################################################################
	$MUPIP journal -extract=globalasub4.mjf -forward -global=\"^A\(\*,\"\"str\"\"\),^AA\" -detail mumps.mjl
	check_mjf globalasub4.mjf
	#Expected result: extracted globals  ^A(*,"str"), ^AA
	################################################################################
	$MUPIP journal -global="^*A,~^AA" -extract=globalstara_maa.mjf  -detail -forward mumps.mjl
	check_mjf globalstara_maa.mjf
	#Expected result: extracted globals  ^A, ^XA, ^AAA
	################################################################################
	$MUPIP journal -global="^D" -extract=globald.mjf  -detail -forward mumps.mjl
	check_mjf globald.mjf
	#Expected result: no transaction is written to global.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -global="~^B" -extract=global_mb.mjf  -detail -broken=global_mb.broken -lost=global_mb.lost -forward mumps.mjl
	check_mjf global_mb.mjf
	check_mjf global_mb.broken
	check_mjf global_mb.lost
	#Expected result: extracted globals ^A, ^AA, ^AAA, ^BB, ^BBB, ^C, ^CC,^CCC to global2.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -global="~^D" -extract=global_md.mjf  -detail -broken=global_md.broken -lost=global_md.lost -forward mumps.mjl
	check_mjf global_md.mjf
	check_mjf global_md.broken
	check_mjf global_md.lost
	diff total.mjf_analysis global_md.mjf_analysis
	diff total.broken_analysis global_md.broken_analysis
	diff total.lost_analysis global_md.lost_analysis
	#Expected result: All the above transactions are written to global2.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -global="^A*,^C" -extract=bglobal_as_c.mjf  -detail -backward -since=\"$time1\" mumps.mjl
	check_mjf bglobal_as_c.mjf
	#Expected result: extracted globals ^A, ^AA, ^AAA, ^C to bglobal.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -global="^D" -extract=bglobal_d.mjf -since=\"$time1\"  -detail -backward mumps.mjl
	echo "check this one"
	check_mjf bglobal_d.mjf
	#Expected result: no transaction is written to bglobal.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -global="~^B" -extract=bglobal_mb.mjf  -detail -backward -since=\"$time1\" mumps.mjl -fences=none
	check_mjf bglobal_mb.mjf
	#Expected result: extracted globals ^A, ^AA, ^AAA, ^BB, ^BBB, ^C, ^CC,^CCC to bglobal2.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -global="~^D" -extract=bglobal_md.mjf  -detail -backward -since=\"$time1\" -broken=bglobal_md.broken -lost=bglobal_md.lost mumps.mjl
	check_mjf bglobal_md.mjf
	check_mjf bglobal_md.broken
	check_mjf bglobal_md.lost
	$grep -v PINI bglobal_md.mjf_analysis >  bglobal_md.mjf_analysis_noPINI
	diff total.mjf_analysis_noPINI bglobal_md.mjf_analysis_noPINI
	diff total.broken_analysis bglobal_md.broken_analysis
	diff total.lost_analysis bglobal_md.lost_analysis
	#Expected result: all the transactions are written to bglobal2.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -user="$USER" -extract=buser.mjf  -detail -backward -since=\"$time1\" mumps.mjl
	check_mjf buser.mjf
	$grep -v PINI buser.mjf_analysis >  buser.mjf_analysis_noPINI
	#Expected result: extracted following to buser.mjf:
	#p1^user1
	#p3^user1
	#Return status: success
	################################################################################
	$MUPIP journal -user="~$USER" -extract=buser2.mjf  -detail -backward -since=\"$time1\" mumps.mjl -fences=none
	check_mjf buser2.mjf
	#Expected result: extracted following to buser2.mjf:
	#^user2
	#Return status: success
	################################################################################
	$MUPIP journal -user="~${gtmtest1}" -extract=buser3.mjf  -detail -forward mumps.mjl
	check_mjf buser3.mjf
	$grep -v PINI buser3.mjf_analysis >  buser3.mjf_analysis_noPINI
	diff buser.mjf_analysis_noPINI buser3.mjf_analysis_noPINI
	#Expected result: extracted following to buser3.mjf:
	#p1^user1
	#p3^user1
	#Return status: success
	################################################################################
	$MUPIP journal -user="$USER,~${gtmtest1}" -extract=user4.mjf  -detail -forward mumps.mjl
	check_mjf user4.mjf
	$grep -v PINI user4.mjf_analysis >  user4.mjf_analysis_noPINI
	diff buser.mjf_analysis_noPINI user4.mjf_analysis_noPINI
	#Expected result: extracted following to buser4.mjf:
	#p1^user1
	#p3^user1
	#Return status: success
	################################################################################
	$MUPIP journal -user="~$USER,${gtmtest1}" -extract=user5.mjf  -detail -forward mumps.mjl -fences=none
	check_mjf user5.mjf
	#Expected result: extracted following to buser5.mjf:
	#^user2
	#Return status: success
	################################################################################
	$MUPIP journal -user="~$USER,~${gtmtest1}" -extract=user6.mjf  -detail -forward mumps.mjl
	if (-e user6.mjf) then
		echo "TEST-E-BADCREATE, user6.mjf should not have been created"
	endif
	#Expected result: no transaction is extracted to buser6.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -user="gtmtestx,~${gtmtest1}" -extract=user7.mjf  -detail -forward mumps.mjl
	if (-e user7.mjf) then
		echo "TEST-E""-NODATA, there should not be anything to extract into user7.mjf"
	endif
	#check_mjf user7.mjf
	#$grep -v PINI user7.mjf_analysis >  user7.mjf_analysis_noPINI
	#Expected result: no transaction is extracted
	#Return status: success
	################################################################################
	$MUPIP journal -user="$USER,~gtmtestx" -extract=user8.mjf  -detail -forward mumps.mjl
	check_mjf user8.mjf
	#Expected result: all transactions of $USER are extracted to buser8.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -extract=user_${gtmtest1}.mjf -user="${gtmtest1}" -detail -fences=none -for mumps.mjl # just to check against others
	(check_mjf user_${gtmtest1}.mjf) >& /dev/null
	unset verbose
	if ("OS/390" == ${HOSTOS}) then
		set gtmtstusr1 = "*TST1"
		set gtmtstusr2 = "GTMTST%"
		set gtmtstusr3 = "%TMTST%"
	else
		set gtmtstusr1 = "*test1"
		set gtmtstusr2 = "gtmtest%"
		set gtmtstusr3 = "%tmtest%"
	endif
	set verbose
	$MUPIP journal -extract=user_star.mjf -user="$gtmtstusr1" -detail -fences=none -for mumps.mjl
	check_mjf user_star.mjf
	diff user_${gtmtest1}.mjf_analysis user_star.mjf_analysis
	$MUPIP journal -extract=user_per.mjf -user="$gtmtstusr2" -detail -fences=none -for mumps.mjl
	check_mjf user_per.mjf
	check_mjf user_per.mjf
	diff user_${gtmtest1}.mjf_analysis user_per.mjf_analysis
	$MUPIP journal -extract=user_per2.mjf -user="$gtmtstusr3" -detail -fences=none -for mumps.mjl
	check_mjf user_per2.mjf
	diff user_per.mjf_analysis user_per2.mjf_analysis
	##TEST -PROCESS with * and % as well
	set verbose
	################################################################################
	$MUPIP journal -id="$pid1" -extract=bpid_1.mjf  -detail -backward -since=\"$time1\" mumps.mjl
	check_mjf bpid_1.mjf
	#Expected result: extracted following globals p1^user1
	#Return status: success
	################################################################################
	$MUPIP journal -id="~$pid1" -extract=bpid_1m.mjf -lost=bpid_1m.lost -broken=bpid_1m.broken -detail -backward -since=\"$time1\" mumps.mjl
	check_mjf bpid_1m.mjf
	check_mjf bpid_1m.broken
	check_mjf bpid_1m.lost
	$MUPIP journal -id="~$pid1" -extract=bpid2_nofence.mjf -backward -since=\"$time1\" -detail -fences=none mumps.mjl
	check_mjf bpid2_nofence.mjf
	#Expected result: extracted following: p3^user1, ^user2
	#Return status: success
	################################################################################
	$MUPIP journal -id="~$pid1,$pid2" -extract=pid_m1_2.mjf -forward -detail mumps.mjl -fences=none
	check_mjf pid_m1_2.mjf
	#Expected result: extracted following: ^user2
	#Return status: success
	################################################################################
	$MUPIP journal -id="$pid1,$pid2" -extract=bpid_1_2.mjf -backward -since=\"$time1\" -detail mumps.mjl -fences=none
	check_mjf bpid_1_2.mjf
	#Expected result: extracted following: p1^user1, p2^user1
	#Return status: success
	################################################################################
	$MUPIP journal -id="~($pid1,$pid2)" -extract=bpid_m12.mjf -backward -since=\"$time1\" -detail mumps.mjl
	check_mjf bpid_m12.mjf
	$MUPIP journal -id="~($pid1,$pid2)" -extract=pid_m12.mjf -forward -detail mumps.mjl
	check_mjf pid_m12.mjf
	# should extract p3^user1
	################################################################################
	$MUPIP journal -id="~$pid1,~$pid2" -extract=pid_m1_m2.mjf -forward -detail mumps.mjl
	check_mjf pid_m1_m2.mjf
	diff pid_m12.mjf_analysis pid_m1_m2.mjf_analysis
	#Expected result: extracted following: p3^user1
	#Return status: success
	################################################################################
	$MUPIP journal -id="~$pid1,~$pid2,$pid3" -extract=bpid_m1_m2_3.mjf -backward -since=\"$time1\" -detail mumps.mjl
	check_mjf bpid_m1_m2_3.mjf
	#Expected result: extracted following: p3^user1
	#Return status: success
	################################################################################
	$MUPIP journal -id="~$pid1,$pid4" -extract=bpid_m1_4.mjf -backward -since=\"$time1\" -detail mumps.mjl
	if (-e bpid_m1_4.mjf) then
		echo "TEST-E""-NODATA, there should not be anything to extract into bpid_m1_4.mjf"
	endif
	#check_mjf bpid_m1_4.mjf
	#Expected result: nothing will be extracted
	#Return status: success
	################################################################################
	$MUPIP journal -id="$pid4,$pid5" -extract=bpid_4_5.mjf -backward -since=\"$time1\" -detail mumps.mjl
	if (-e bpid_4_5.mjf) then
		echo "TEST-E""-NODATA, there should not be anything to extract into bpid_4_5.mjf"
	endif
	#check_mjf bpid_4_5.mjf
	#Expected result: no transaction is extracted
	#Return status: success
	################################################################################
	#u) For VMS only, repeat every test with /id with /process as well
	################################################################################
	$MUPIP journal -transaction="set" -extract=btypeset.mjf -for -detail mumps.mjl -fences=none
	check_mjf btypeset.mjf
	################################################################################
	$MUPIP journal -transaction=nokill -extract=btypenokill.mjf  -for -detail mumps.mjl -fences=none
	check_mjf btypenokill.mjf
	diff btypeset.mjf_analysis btypenokill.mjf_analysis
	#Expected result: extracted following to btype.mjf
	#Return status: success
	################################################################################
	$MUPIP journal -transaction="kill" -extract=btypekill.mjf -for -detail mumps.mjl -fences=none
	check_mjf btypekill.mjf
	################################################################################
	$MUPIP journal -transaction="noset" -extract=btypenoset.mjf -for -detail mumps.mjl -fences=none
	check_mjf btypenoset.mjf
	$grep -vE "EPOCH|PBLK" btypekill.mjf > btypekill1.mjf
	$grep -vE "EPOCH|PBLK" btypenoset.mjf > btypenoset1.mjf
	diff btypekill1.mjf btypenoset1.mjf
	################################################################################
	# Mix and match:
	################################################################################
	$MUPIP journal -transaction="set" -global="^A*" -user="${gtmtest1}" -extract=select1.mjf -for -detail mumps.mjl -fences=none
	check_mjf select1.mjf
	$MUPIP journal -transaction="kill" -global="^AA" -user="$USER" -extract=select2.mjf -for -detail mumps.mjl -fences=none
	check_mjf select2.mjf
	################################################################################
	unset verbose
endif

if (1 == $?test_show) then
	echo "######################################"
	echo "SHOW"
	echo ""
	set verbose
	#total:
	$MUPIP journal  -show=all -forward mumps.mjl
	################################################################################
	$MUPIP journal -global="^A*,^C" -show=stat -forward mumps.mjl
	#Expected result: display the information about globals ^A*, ^C in mumps.mjl.
	#Return status: success
	################################################################################
	$MUPIP journal -global="^A,^C" -show=s -forward mumps.mjl
	#Expected result: display the statistic information about globals  ^A, ^C in mumps.mjl.
	#Return status: success
	################################################################################
	$MUPIP journal -user="$USER" -show=s -forward mumps.mjl
	#Expected result: display the transaction information done by user $USER in mumps.mjl.
	#Return status: success
	################################################################################
	$MUPIP journal -user="${gtmtest1}" -show=s -forward mumps.mjl
	#Expected result: display the statistic transaction information done by user $USER.
	#Return status: success
	################################################################################
	$MUPIP journal -id="$pid1" -show=p -forward mumps.mjl
	#Expected result: display the transaction information done by process pid1.
	#Return status: success
	################################################################################
	$MUPIP journal -id="$pid1" -show=s -forward mumps.mjl
	#Expected result: display the transaction information done by process pid1.
	#Return status: success
	################################################################################
	$MUPIP journal -id="$pid2" -show=process -forward mumps.mjl
	#Expected result: display the information of process pid1.
	#Return status: success
	################################################################################
	$MUPIP journal -id="~$pid3" -show=process -forward mumps.mjl
	################################################################################
	$MUPIP journal -transaction="set" -show=s -forward mumps.mjl
	#Expected result: display the statistic set transaction information
	#Return status: success
	################################################################################
	$MUPIP journal -transaction="kill" -show=stat -forward mumps.mjl
	################################################################################

	unset verbose
endif
unset verbose

##############################################################
echo "Stop second process..."
$GTM << END
w "\$H = ",\$H,!
s ^done="done"
for i=1:1:240 quit:\$data(^sema2)  h 1
i i=240 w "TEST-E-TIMEOUT: USER2 DID NOT FINISH ITS PROCESSING"
w "End",!
w "\$H = ",\$H,!
h
END

$gtm_tst/$tst/u_inref/second_process_end.csh
##############################################################
#test some errors
set verbose
$MUPIP journal -extract=error.mjf -global=\"^A\(\" -for mumps.mjl
$MUPIP journal -extract=error.mjf -global=\"^A\(1,2,3\" -for mumps.mjl
$MUPIP journal -extract=error.mjf -global=\"^A\)\" -for mumps.mjl
$MUPIP journal -extract=error.mjf -global=\"^\(\" -for mumps.mjl
$MUPIP journal -extract=error.mjf -global=\"^\)\" -for mumps.mjl
$MUPIP journal -id="badpid" -extract=error.mjf  -detail -forward mumps.mjl
$MUPIP journal -id="98765432198" -extract=error.mjf  -detail -forward mumps.mjl

unset verbose
##############################################################

$gtm_tst/com/dbcheck.csh

echo "Test multiple regions..."
setenv gtmgbldir multireg.gld
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh multireg 4
$gtm_tst/com/jnl_on.csh

$GTM << EOF
s (^A,^B,^C,^D)=1
k ^A,^B,^C,^D
ZTS
s (^A,^B,^C,^D)=1
k ^A,^B,^C,^D
s (^A(1),^A(2),^A(11))=11
ZTC
h
EOF

set verbose
################################################################################
$MUPIP journal -show=stat -extract -global="~^B" -forward  b.mjl
check_mjf b.mjf
#Expected result: no transaction is extracted to b.mjf file
#Return status: success
################################################################################
$MUPIP journal -show=stat -extract=b1.mjf -global="^A,^B" -forward  b.mjl -lost=b1.lost -broken=b1.broken
check_mjf b1.mjf
check_mjf b1.lost
check_mjf b1.broken
#Expected result: ^B to b.mjf
#Return status: success
################################################################################
$MUPIP journal -extract=multi_mb.mjf -global="~^B" -forward  "*"
setenv extract_summary_sort 1	# signals extract_summary.awk to sort output as the latter is non-deterministic	 #BYPASSOK
				# due to parallelism in mupip journal (if "gtm_mupjnl_parallel" is 0 or > 1).
check_mjf multi_mb.mjf
unsetenv extract_summary_sort
#Expected result:^D is extracted to mumps.mjf
#                 ^A is extracted to A.mjf
#                 ^C is extracted to C.mjf
################################################################################
$MUPIP journal -show=stat -extract=no_a_mb.mjf -global="^A,~^B" -forward  b.mjl -fences=NONE
check_mjf no_a_mb.mjf
# Expected result: no transaction is extracted to no_a_mb.mjf file
$MUPIP journal -show=stat -extract=multi_a_ma1.mjf -global="^A,~^A(1)" -forward  "*" >& multi_a_ma1.unsorted
$tst_awk -f $gtm_tst/com/mupjnl_multireg_show_sort.awk multi_a_ma1.unsorted
check_mjf multi_a_ma1.mjf
$MUPIP journal -show=stat -extract=multi_a_ma1.mjf -global="^A,~^A(1)" -forward  a.mjl -fences=none
check_mjf multi_a_ma1.mjf
#Expected result:
#                 ^A is extracted to A.mjf except for ^A(1)
#Return status: success
################################################################################
unset verbose
$gtm_tst/com/dbcheck.csh
setenv tst_jnl_str $tst_jnl_str_save
