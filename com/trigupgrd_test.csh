#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# trigupgrd_test.csh : verifies ^#t on-the-fly upgrade logic works correctly in various situations
#
gunzip *.gz >& /dev/null
unsetenv gtm_repl_instance	# do not worry about replication instance file here
setenv gtm_extract_nocol 1	# to do journal extract since db file stored in jnl file header would be missing

@ exit_status = 0
set curpwd = `pwd`
$gtm_tst/com/jnlextall.csh >& jnlextall.out
if ($status != 0) then
	echo "TRIGUPGRD_TEST-E-FAIL : Fail at jnlextall stage. See $curpwd/jnlextall.out"
	@ exit_status++
endif
unsetenv gtm_extract_nocol
$grep LGTRIG *.mjf* | sort -t\\ -k7,10 -n | $tst_awk -F\\ '{print $11}' | uniq > trig_input.trg
$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat *.gld" mv nozip
# Pick a version that would require a trigger upgrade by searching gv_trigger_common.h for the first version of HASHT_GBL_CURLABEL
$tst_awk '/#define[^A-Za-z0-9_]+HASHT_GBL_CURLABEL[^A-Za-z0-9_]/{gsub(/[\.-]/,"");if($5 ~ /^V[6-9][0-9][0-9]+[A-Z]?/)print $5;exit}' $gtm_inc/gv_trigger_common.h > less_than_ver
set less_than_ver = `cat less_than_ver`
if ("${less_than_ver}" == "") then
	# If the above fails, default to #LABEL 4 => V62002 and signal that the AWK command failed. The rest of the
	# upgrade test should succeed. If a code change breaks the AWK usage, this will help us trap such a condition.
	set less_than_ver = "V62002"
	echo "${less_than_ver}" >& less_than_ver
	echo "TRIGUPGRD_TEST-E-FAIL : Could not determine less than version"
	@ exit_status++
endif
if (($less_than_ver == "V62002") && ("dbg" == "$tst_image")) then
	# We are about to default the search for prior version in the interval [V60000,V62002).
	# No dbg builds for such versions exist in a non-gg setup. So skip this entire script in that case.
	exit 0
endif
$gtm_tst/com/random_ver.csh -gte V60000 -lt $less_than_ver > prior_ver.txt
$grep -q -- '-E-' prior_ver.txt
if ($status == 0) then
	echo "TRIGUPGRD_TEST-E-FAIL : Could not determine prior version"
	cat prior_ver.txt
	@ exit_status++
	exit $exit_status
endif
set priorver = `cat prior_ver.txt`
echo "Random version chosen is : $priorver"
if (`expr ${priorver} \< "V62001"`) then
	# Versions prior to V62001 do not support triggers AND spanning regions; disable it. GTM-7877 added support
	setenv gtm_test_spanreg 0
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $priorver
source $gtm_tst/com/switch_gtm_version.csh $priorver $tst_image
if ($status != 0) then
	echo "TRIGUPGRD_TEST-E-FAIL : Fail when SWITCHING to $priorver in $curpwd"
	@ exit_status = 1
endif
$gtm_tst/com/gde_filter_unsupported.csh dbcreate.gde $priorver
$GDE @dbcreate.gde >& gde.out
if ($status != 0) then
	echo "TRIGUPGRD_TEST-E-FAIL : Fail at GDE stage. See $curpwd/gde.out"
	@ exit_status++
endif
$MUPIP create >& mu_cre.out
if ($status != 0) then
	echo "TRIGUPGRD_TEST-E-FAIL : Fail at MUPIP CREATE stage. See $curpwd/mu_cre.out"
	@ exit_status++
endif
$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.gld" cp nozip
# below code was previously a while loop starting from 1 running through $maxlines.
# but that meant test runtimes were O(n^2) instead of O(n).
# therefore we later changed it to do just one iteration.
# we randomly choose a number between 1 and $maxlines and upgrade the database as if that many triggers were loaded.
@ maxlines = `$tst_awk 'END {print NR}' trig_input.trg`
@ curline = $maxlines
while ($curline <= $maxlines)
	$head -$curline trig_input.trg > $curline.tmp.trg
	source $gtm_tst/com/switch_gtm_version.csh $priorver $tst_image
	# Load triggers using older version. Deletion of non-existent triggers might error out in older versions.
	# So ignore only that error. Also load remaining triggers by loading one trigger line at a time.
	# Loading all triggers at the same time will cause one error to not load any good trigger either.
	cat << CAT_EOF > load$curline.m
		set file="$curline.tmp.trg"
		open file:(readonly)
		use file
		for  read line(\$incr(i))  quit:\$zeof
		close file
		kill line(i)  if \$incr(i,-1)
		use \$p
		set version=\$\$^verno()
		; randomly choose a number between 1 and i
		set i=\$random(i)+1
		for j=1:1:i do
		. if (version<62002)&'(j#100) view "STP_GCOL"	; Avoid GTM-8214 in prior versions
		. set @("trigstr="_line(j))	; need this to remove extraneous double-quotes & do \$c() evaluations
		. ; ---------------------------------------------
		. ; make an exception for "-abc*" which is used in validtriggers.trg to test GTM-7947.
		. ; this is used by parse_valid and dztriggerintp subtests and when run with pre-V62001 causes
		. ; assert failure in trigger_delete.c (GTM-7947)
		. if trigstr="-abc*" set trigstr=";"
		. ; ---------------------------------------------
		. ; if trigger is multiline then use \$ztrigger("FILE") as the older version might not support
		. ; multi-line trigger execution in \$ztrigger("ITEM").
		. if trigstr["-xecute=<<" do
		. . set outfile="$curline.file.trg"
		. . open outfile:(newversion)
		. . use outfile
		. . write trigstr,">>",!
		. . close outfile
		. . set x=\$ztrigger("file",outfile)
		. else  do
		. . set x=\$ztrigger("item",trigstr)
		. if (x'=1)&(\$zextract(trigstr,1)'="-") do
		. . write "TRIGUPGRD_TEST-E-FAIL : Fail at trigger load operation. See $curpwd/$curline.trig_load",! zhalt 1
CAT_EOF
	$gtm_exe/mumps -run ^load$curline >& $curline.trig_load
	if (($status != 0) || (-z $curline.trig_load)) then
		echo "TRIGUPGRD_TEST-E-FAIL : Fail at TRIGGER load stage. See $curpwd/$curline.trig_load"
		@ exit_status = 1
	endif

	echo "Backup"
	$gtm_tst/com/backup_dbjnl.csh $curline "*.dat" cp nozip
	$MUPIP trigger -select $curline.oldver.trig_select
	cp bak1/*.gld .

	echo "Upgrade and compare trigger select output to prior version select output"
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	$MUPIP TRIGGER -UPGRADE >& $curline.newver.trigupgrd.out
	$GTM << GTM_EOF >& $curline.newver.out
		write \$zver,!
		set \$etrap="write TRIGUPGRD_TEST-E-FAIL : Fail at trigger select stage. See $curpwd/$curline.newver.out,! zhalt 1"
		set file="$curline.newver.trig_select"
		open file:(newversion)
		use file
		set x=\$ztrigger("SELECT","*")
		close file
		if x'=1 write "TRIGUPGRD_TEST-E-FAIL : Fail at trigger select operation. See $curpwd/$curline.newver.out",! zhalt 1
GTM_EOF

	if ($status != 0) then
		@ exit_status++
	endif
	# Old trigger will have a trailing hash. Since the new version does not have it, remove it.
	# Also remove the region information, and bump up the cycle
	$tst_awk '{ if (/^;trigger name:/) {sub("# "," ") ; sub(/ \(region [A-Za-z0-9]*\)/,"") ; n=substr($0, match($0, /[0-9]+$/),RLENGTH)+1 ; sub(/[0-9]+$/,n)}; print }' $curline.oldver.trig_select >& $curline.filtered.oldver.trig_select
	# New TRIGGER SELECT output has below output
	#	;trigger name: a#1 (region xxx)  cycle: 5
	# where the region name xxx could be any valid region. So filter that out before doing the diff.
	sed 's/ (region [A-Za-z0-9]*)//g' $curline.newver.trig_select >& $curline.filtered.newver.trig_select
	diff $curline.filtered.oldver.trig_select $curline.filtered.newver.trig_select >& $curline.diff
	if ($status) then
		echo "TRIGUPGRD_TEST-E-FAIL : Fail at curline = $curline. See $curpwd/$curline.diff"
		@ exit_status++
	endif

	echo "Reload"
	$MUPIP trigger -select reload.trg
	$MUPIP trigger -trigger=reload.trg >&! reload.out
	if ("$test_subtest_name" =~ {compile}) then
		# The 'compile' subtest loads some triggers that don't compile
		mv reload.out reload.outx
		$grep -Ev 'INVCMD' reload.outx > reload.out
	endif

	# Prepare for next iteration of trigger load
	cp $curline/*.dat .
	cp bak2/*.gld .
	@ curline = $curline + 1
end
exit $exit_status
