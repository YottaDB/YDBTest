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
# This takes care of test cases 24, 25, and 27
# Test Case # 24:  (qualifier extract)
# Test Case # 25:  (show options ,also for C9C04-001979)
# C9C04-001979: mupip journal extract /show=header does not print time correctly

alias check_mjf 'unset echo; $tst_awk -f $gtm_tst/$tst/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" \!:*; set echo'

echo "Run with single region and multiple regions"
if ("" == $1) then
	set no_regions = 1
else
	set no_regions = $1
endif

$gtm_tst/com/dbcreate.csh . $no_regions
echo "Turn journaling on:"
$gtm_tst/com/jnl_on.csh
$grep "OPTIONS" jnl.log
echo "####################################################################"
echo "#STAGE A"
echo "# empty database with BIJ"
echo "####################################################################"
if ($?test_extract) then
	echo "######################################"
	echo "EXTRACT"
	echo ""
	set echo
	$MUPIP journal -extract -forward nonexist.mjl
	$MUPIP journal -extract=file-a.mjf -forward "*"
	check_mjf file-a.mjf
	$MUPIP journal -extract=/bad/path/file-a.mjf -forward "*" >& badpath_a.outx
	unset echo
	if (1 == $no_regions) then
		cat badpath_a.outx
	else
		# A multi-region extract could print more than one GTM-E-FILENOTCREATE message, one per region
		# depending on the parallelism chosen by test framework (env var "gtm_mupjnl_parallel"). Filter
		# them out as they cause varying # of lines in the test output that is not easily captured in a reference file.
		set filter1 = "%GTM-E-FILENOTCREATE, Journal extract file /bad/path/file-a.mjf_(AREG|BREG|CREG|DEFAULT) not created"
		set filter2 = "%SYSTEM-E-ENO2, No such file or directory"
		$grep -vE "$filter1|$filter2" badpath_a.outx
	endif
	set echo
	$MUPIP journal -extract -forward mumps.mjl
	check_mjf mumps.mjf
	if (1 != $no_regions) then
		$MUPIP journal -extract=c.mjf -forward c.mjl
		check_mjf c.mjf
		$MUPIP journal -extract=b.mjf -forward b.mjl,a.mjl
		check_mjf b.mjf
		$MUPIP journal -extract=a.mjf -forward a.mjl,b.mjl
		check_mjf a.mjf
		$MUPIP journal -extract=d.mjf -forward a.mjl,b.mjl
		check_mjf d.mjf
	endif
	unset echo
endif

if ($?test_show) then
	echo "######################################"
	echo "SHOW"
	echo ""
	set echo
	$MUPIP journal -show -forward mumps.mjl
	$MUPIP journal -show=header -noverify -forward mumps.mjl
	$MUPIP journal -show=processes -forward mumps.mjl
	$MUPIP journal -show=processes,active -forward mumps.mjl
	$MUPIP journal -show=ac -forward mumps.mjl
	$MUPIP journal -show=b -forward mumps.mjl
	$MUPIP journal -show=s -forward mumps.mjl
	$MUPIP journal -show -forward nonexist.mjl
	unset echo
endif

echo "####################################################################"
echo "#STAGE B"
echo "# database with BIJ with some updates"
echo "####################################################################"
echo "Do some  updates..."
$gtm_exe/mumps -run jnlrecm
sleep 1
$gtm_tst/com/abs_time.csh time6
setenv time1  `cat time1_abs`
setenv time2  `cat time2_abs`
setenv time3  `cat time3_abs`
setenv time4  `cat time4_abs`
setenv time5  `cat time5_abs`
setenv time6  `cat time6_abs`
echo "Updates done, test..."
$gtm_tst/com/backup_dbjnl.csh save_b "*.dat *.gld *.mjl* time*" "cp"
set echo
$MUPIP journal -extract -back mumps.mjl

if ($?test_extract) then
	echo "######################################"
	echo "EXTRACT"
	echo ""
	set echo
	$MUPIP journal -extract -back mumps.mjl
	check_mjf mumps.mjf
	$MUPIP journal -extract=fileb.mjf -forward "*"
	$MUPIP journal -extract=/bad/path/fileb.mjf -forward "*" >& badpath_b.outx
	unset echo
	if (1 == $no_regions) then
		cat badpath_b.outx
	else
		# A multi-region extract could print more than one GTM-E-FILENOTCREATE message, one per region
		# depending on the parallelism chosen by test framework (env var "gtm_mupjnl_parallel"). Filter
		# them out as they cause varying # of lines in the test output that is not easily captured in a reference file.
		set filter1 = "%GTM-E-FILENOTCREATE, Journal extract file /bad/path/fileb.mjf_(AREG|BREG|CREG|DEFAULT) not created"
		set filter2 = "%SYSTEM-E-ENO2, No such file or directory"
		$grep -vE "$filter1|$filter2" badpath_b.outx
	endif
	set echo
	$MUPIP journal -extract -forward mumps.mjl
	check_mjf mumps.mjf
	if (1 != $no_regions) then
		$MUPIP journal -extract -forward c.mjl
		check_mjf c.mjf
		$MUPIP journal -extract -forward c.mjl -fences=NONE
		check_mjf c.mjf
		$MUPIP journal -extract=ab1.mjf -broken=ab1.broken -lost=ab1.lost -forward b.mjl,a.mjl
		unset echo
		# Since multiple regions are involved with differing timestamps in PINI records across regions,
		# it is possible to get non-deterministic output order in the extract file. To avoid this
		# filter out just the logical records with deterministic fields.
		$grep '\^' ab1.mjf | $tst_awk -F\\ '{print $1,$3,$9,$11}'
		set echo
		$MUPIP journal -ex -losttrans=lost.list -broken=broken.list -for mumps.mjl
		unset echo
		wc -l lost.list broken.list >! wc.out
		$tst_awk '{print $1,$2}' wc.out
	endif
	unset echo
	if (1 == $no_regions) then
		echo "check that SHOW=STAT and EXTRACT counts match"
		$MUPIP jour -show=statistics -for mumps.mjl > & ! show_stats.out
		$MUPIP jour -extract=nodetail.mjf -for mumps.mjl
		$MUPIP jour -extract=detail.mjf -for -detail mumps.mjl
		# ZTSTART does not have a space after it:
		sed 's/ZTSTART/ZTSTART /g' detail.mjf | $grep -vE "EPOCH|PBLK" | $tst_awk -f $gtm_tst/$tst/inref/check_extract_jnlrec.awk -v detail=1 | sort > detail.out
		$tst_awk -f $gtm_tst/$tst/inref/check_extract_jnlrec.awk nodetail.mjf | sort > nodetail.out
		$tst_awk -f $gtm_tst/$tst/inref/check_show_jnlrec.awk show_stats.out | sort > stats.out
		echo "TOT_KILL, TOT_SET, and TOT_ZKILL should be the same in the three:"
		$grep TOT *detail.out stats.out
		diff -w stats.out detail.out | $grep -v TOTAL | $grep -E "^>|^<" | $grep -vE "ZTRI|ZTWO|LGTR|TSTA|NULL|BAD|AIMG|ALIGN|TRUNC|---"
		# Expected differences: no *BAD*, AIMG, ALIGN, ZTWOR, LGTRIG, NULL, TRUNC records in detail.out, no (Z)TS in stats.out
	endif
endif

if ($?test_show) then
	echo "######################################"
	echo "SHOW"
	echo ""
	set echo
	$MUPIP journal -show=all -forward mumps.mjl
	$MUPIP journal -show -backward mumps.mjl
	$MUPIP journal -show=header -noverify -forward mumps.mjl
	$MUPIP journal -show=header -noverify -forward "*"
	$MUPIP journal -show=processes -forward mumps.mjl
	$MUPIP journal -show=processes,active -forward mumps.mjl
	$MUPIP journal -show=ac -forward mumps.mjl
	$MUPIP journal -show=b -forward mumps.mjl
	$MUPIP journal -show=s -forward mumps.mjl
	if (1 != $no_regions) then
		$MUPIP journal -show=process -forward "*" >& show_process1.unsorted
		$tst_awk -f $gtm_tst/com/mupjnl_multireg_show_sort.awk show_process1.unsorted
		$MUPIP journal -show=s -forward "*" >& show_s1.unsorted
		$tst_awk -f $gtm_tst/com/mupjnl_multireg_show_sort.awk show_s1.unsorted
	endif
endif

if ((1 != $no_regions)&&($?test_extract || $?test_show)) then
	source $gtm_tst/$tst/u_inref/mu_jnl_extract_show_time.csh
endif

echo "####################################################################"
echo "#STAGE C"
echo "# database with BIJ with some active transactions (and an active process of another user)"
echo "####################################################################"

echo "Start second process (as same user)..."
$gtm_tst/$tst/u_inref/same_user.csh jnlrecm > same_user.log

##############################################################
echo "Wait for second user to finish its processing..."
$GTM << EOF
w "\$H = ",\$H,!
for i=1:1:240 quit:\$data(^sema1)  h 1
i i=240 w "TEST-E-TIMEOUT: USER2 DID NOT FINISH ITS PROCESSING"
w "second user should have finished",!
w "\$H = ",\$H,!
view "JNLFLUSH"
EOF
echo "Updates done, test..."
echo ""
##############################################################

# A couple of completed processes for -SHOW to show
$GTM << EOF
s (^a,^b,^c)=1
EOF
$GTM << EOF
s (^a,^b,^c)=2
EOF
$GTM << EOF
s (^a,^b,^c)=3
view "JNLFLUSH"
EOF

# One active process without any transactions:
($gtm_exe/mumps -r updatesyncndie &) >& updatesyncndie.out
$gtm_tst/com/wait_for_log.csh -log updatesyncndie_done.txt -duration 300
$gtm_tst/com/gtm_crash.csh
$MUPIP rundown -reg "*" -override >& rundown.out
$MUPIP rundown -relinkctl         >& rundown_rlnk.outx # Also rundown relinkctl files (if any) leftover from the crash
# Rundown the help database
$GTM << GTM_EOF >&! zhelp.out
zhelp

halt
GTM_EOF

$gtm_tst/com/backup_dbjnl.csh save_c "*.dat *.gld *.mjl* time*" "cp"
if ($?test_extract) then
	echo "######################################"
	echo "EXTRACT"
	echo ""
	set echo
	$MUPIP journal -extract=filec.mjf -broken=filec.broken -lost=filec.lost -forward "*"
	unset echo
	set sort_needed = 0
	if (1 != $no_regions) then
		set sort_needed = 1
		# In this case, dont use check_mjf but instead directly use sort and print only the columns
		# that will keep the output deterministic considering multiple processes ("gtm_mupjnl_parallel")
	endif
	if (! $sort_needed) then
		check_mjf filec.mjf
		unset echo
	else
		$grep '\^' filec.mjf | sort -k3,3n -k11,11 -t\\ | $tst_awk -F\\ '{print $1,$3,$9,$11}'
	endif
	set echo
	$MUPIP journal -extract -forward mumps.mjl
	check_mjf mumps.mjf
	if (1 != $no_regions) then
		$MUPIP journal -extract=cfor.mjf -forward c.mjl
		check_mjf cfor.mjf
		$MUPIP journal -extract=cfornofence.mjf -forward c.mjl -fences=NONE
		check_mjf cfornofence.mjf
		$MUPIP journal -extract=ab2.mjf -broken=ab2.broken -lost=ab2.lost -forward b.mjl,a.mjl
		unset echo
		# Since multiple regions are involved with differing timestamps in PINI records across regions,
		# it is possible to get non-deterministic output order in the extract file. To avoid this
		# filter out just the logical records with deterministic fields.
		$grep '\^' ab2.mjf | $tst_awk -F\\ '{print $1,$3,$9,$11}'
		set echo
	endif
	$MUPIP journal -extract -forward mumps.mjl -detail
endif

if (1 == $?test_show) then
	echo "######################################"
	echo "SHOW"
	echo ""
	$MUPIP journal -show=all -forward mumps.mjl
	$MUPIP journal -show -backward mumps.mjl -since=\"$time1\"
	$MUPIP journal -show=header -noverify -forward mumps.mjl
	$MUPIP journal -show=header -noverify -forward "*"
	$MUPIP journal -show=processes -forward mumps.mjl
	$MUPIP journal -show=processes,active -forward mumps.mjl
	$MUPIP journal -show=ac -forward mumps.mjl
	$MUPIP journal -show=b -forward mumps.mjl
	$MUPIP journal -show=s -forward mumps.mjl
	if (1 != $no_regions) then
		$MUPIP journal -show=process -forward "*" >& show_process2.unsorted
		$tst_awk -f $gtm_tst/com/mupjnl_multireg_show_sort.awk show_process2.unsorted
		$MUPIP journal -show=active -forward "*" >& show_active2.unsorted
		$tst_awk -f $gtm_tst/com/mupjnl_multireg_show_sort.awk show_active2.unsorted
		$MUPIP journal -show=s -forward "*" >& show_s2.unsorted
		$tst_awk -f $gtm_tst/com/mupjnl_multireg_show_sort.awk show_s2.unsorted
	endif
endif
unset echo

##############################################################
#echo "Stop second process..."
$gtm_tst/$tst/u_inref/second_process_end.csh
##############################################################
# Some broken transactions:
$GTM << EOF
ZTS
s ^a=1
s ^b=2
s ^c=4
h
EOF
set echo
$MUPIP journal -show=broken -forward "*" >& show_broken3.unsorted
$tst_awk -f $gtm_tst/com/mupjnl_multireg_show_sort.awk show_broken3.unsorted
unset echo

$gtm_tst/com/backup_dbjnl.csh save_c_end "*.dat *.gld *.mjl* time*" "cp"
$gtm_tst/com/dbcheck.csh
if (($?test_extract) && (1 == $no_regions)) then
	echo "####################################################################"
	echo "# DETAIL EXTRACT"
	$gtm_tst/$tst/u_inref/extract_detail.csh
	echo "####################################################################"
endif
