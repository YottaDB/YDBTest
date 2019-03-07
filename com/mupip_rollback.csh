#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This central script is invoked by the test system whenever it needs to do a mupip journal rollback.
# This script checks the parameters $1, $2, etc. for the following
# If -backward is only requested, then the script does a -backward rollback only.
# If -forward is only requested, then the script does a -forward rollback only.
# If both -backward and -forward are specified, then the script does both rollbacks one after the other.
# If neither -backward nor -forward is requested, then the script does a -backward rollback (which is what the caller wants)
#	followed by a hidden -forward rollback after which it verifies that the file header has exactly the same state
#	as the -backward rollback (in terms of sequence numbers etc.).

# $1 == "noresync" is a special parameter to indicate the caller used "-noresync".
# In this case, forward and backward rollback could end up with different Stream Reg Seqno fields.
# So take that into account when checking for diffs.
if ("$1" == "noresync") then
	set caller_used_noresync = 1
	shift
else
	set caller_used_noresync = 0
endif

# $1 == "forward_only" is a special parameter to indicate the caller test wants to only run
# forward rollback in case nobefore-image journaling is turned on.
if ("$1" == "forward_only") then
	set forward_only_specified = 1
	shift
else
	set forward_only_specified = 0
endif

set do_backward = 0
set do_forward = 0

set rollbackparms = "-backward"
set rollforwparms = "-forward"
set noglob	# make sure no filename expansions take place in case "*" is a parameter (likely for rollback)
set do_resync = 0
set do_rsync_strm = 0
set do_fetchresync = 0
set losttransfile = ""
set brokenfile = ""
set starseen = 0
while ($#argv)
	set var = "$1"
	set var2 = $var:al	# lower-case-converted variable name
	if (("$var2" == "-back") || ("-backward" == "$var2")) then
		# "-backward" specified. Note it down
		set do_backward = 1
	else if (("$var2" == "-for") || ("-forward" == "$var2")) then
		# "-forward" specified. Note it down
		set do_forward = 1
	else if ("$var" =~ "-fetchresync*") then
		# "-fetchresync" specified. Note it down
		set do_fetchresync = 1
		set fetchresyncparms = "$var"
		set rollbackparms = "$rollbackparms $var"
	else if ("$var2" =~ "-online") then
		# "-online" specified. Cannot do forward rollback (hidden or otherwise).
		set do_backward = 1
		set rollbackparms = "$rollbackparms $var"
	else if ("$var2" =~ "-rsync_strm*") then
		# "-online" specified. Cannot do forward rollback using specified -resync seqno
		# but have to do it based on the seqno that backward rollback takes the db back to.
		set do_rsync_strm = 1
		set rollbackparms = "$rollbackparms $var"
	else if ("$var2" =~ "-resync*") then
		# "-resync" specified
		set do_resync = 1
		set resyncparms = "$var"
		set rollbackparms = "$rollbackparms $var"
	else if ("$var2" =~ "-lost*=*") then
		# "-losttrans" specified. Use different file for backward vs forward rollback
		set losttransfile = `echo "$var" | sed 's/.*=//g'`
		set rollbackparms = "$rollbackparms $var"
	else if ("$var2" =~ "-broken*=*") then
		# "-broken" specified. Use different file for backward vs forward rollback
		set brokenfile = `echo "$var" | sed 's/.*=//g'`
		set rollbackparms = "$rollbackparms $var"
	else if ("$var2" =~ "-since*=*") then
		# "-since" specified. Use it only for backward rollback. Skip it for forward rollback (-since unsupported)
		# Note that -since is specified as -since=\"03-Nov-2015 08:39:42\" which counts as TWO parameters
		# (as the double-quote is escaped) so shift the second parameter also as part of parsing the -since specification
		shift
		set rollbackparms = "$rollbackparms $var $1"
	else if ("$var" == "*") then
		set rollbackparms = "$rollbackparms $var"
		set starseen = 1
		set starparm = "$var"
		# for forward rollback, the list of journal files could be "*" OR an actual list based on
		# whether "gtm_test_switches_jnl_files" is 1 or not. So defer this for later.
	else
		# other options like "-verbose" or "-noerror" etc. specified. Use for both backward anf forward rollback.
		set rollbackparms = "$rollbackparms $var"
		set rollforwparms = "$rollforwparms $var"
	endif
	shift
end

if ($gtm_test_jnl_nobefore && ! $do_backward && ! $do_forward && ! $forward_only_specified) then
	# Test runs with NOBEFORE image journaling and "-backward" or "-forward" was not explicitly specified to mupip_rollback.csh.
	# In this case a backward rollback will be a LOSTTNONLY rollback and will not roll the database back so
	# a forward rollback is not possible in this case. Disallow it by treating the input as if a "-backward"
	# was specified to "mupip_rollback.csh" (which would only run backward rollback and skip forward rollback).
	# The only exception is if "forward_only" was specified in which case we will fall through and run just
	# forward rollback (i.e. skip the backward rollback).
	set do_backward = 1
endif

# If current version is <= V62002A, then forward rollback is not a supported feature so dont try it.
if (`expr "V62002A" \>= "$gtm_verno"`) then
	set do_backward = 1
endif

set rollbackcmd = "$MUPIP journal -rollback"		#BYPASSOK("-rollback")
@ forw_rollback_needed = 1
@ exit_status = 0
if ($do_backward) then
	$rollbackcmd $rollbackparms
	@ status1 = $status
	@ exit_status = $status1
	@ forw_rollback_needed = 0;
endif

if ($do_forward) then
	if ("" != "$losttransfile") then
		set rollforwparms = "$rollforwparms -losttrans=$losttransfile"
	endif
	if ($starseen) then
		$rollbackcmd $rollforwparms $starparm
	else
		$rollbackcmd $rollforwparms
	endif
	@ status1 = $status
	if (! $exit_status) then
		@ exit_status = $status1
	endif
	@ forw_rollback_needed = 0;
endif

if (0 == $forw_rollback_needed) then
	if ($?mupjnl_check_leftover_files) then
		$gtm_tst/com/mupjnl_check_leftover_files.csh
		@ status1 = $status
		if ($status1) then
			echo "TEST-E-ERROR: Backward rollback had leftover files"
			@ exit_status = $status1
		endif
	endif
	exit $exit_status
endif

set bakdir = `$gtm_tst/com/get_repl_inst_name.csh`
if ("" == "$bakdir") then
	echo "TEST-E-ERROR: get_repl_inst_name.csh returned empty string. Ensure $gtm_repl_instance points to an existing file"
	exit 1
endif

set orig_bakdir = dir_$bakdir	# this is the directory where backup_for_mupip_rollback.csh would have stored the backups

# Check if "${bakdir}_n_misc.log" already exists for n=0,1,2,... If so increment "n" until otherwise.
# Once "n" is determined, we can create "dir_${bakdir}_n_mupip_rollback_*" directories as needed (guaranteed to be non-existing).
@ n = 0
while (1)
	if (! -e ${bakdir}_${n}_misc.log) then
		break
	endif
	@ n = $n + 1
end
set bakdir = "${bakdir}_${n}"

set backwardlog = "${bakdir}_mupip_rollback_backward.out"
set forwardlog = "${bakdir}_mupip_rollback_forward.out"
set misclog = "${bakdir}_misc.log"

echo "#################################################################" >>& $misclog
echo "# Do backward rollback first." >>& $misclog
# But before that save off the .mjl files for the later forward rollback
# since they would be modified by the backward rollback. We want to do the forward rollback with the same
# .mjl files that backward rollback worked on and verify the database state is identical.
# In addition, to ensure both backward and forward rollback are presented with the same database files,
# do mupip rundown (use "-override" to avoid REQROLLBACK errors) in case shared memory is still left over.
echo "#################################################################" >>& $misclog
echo "$MUPIP rundown -override -reg * >>& $misclog" >>& $misclog
$MUPIP rundown -override -reg *	>>& $misclog
set bakdir1 = dir_${bakdir}_mupip_rollback_1
unset noglob
$gtm_tst/com/backup_dbjnl.csh $bakdir1 "*.gld *.dat *.mjl* *.repl" cp nozip
set noglob
# If "forward_only" was specified, skip the backward rollback step.
if (! $forward_only_specified) then
	echo "$rollbackcmd $rollbackparms >& $backwardlog" >>& $misclog
	$rollbackcmd $rollbackparms >& $backwardlog
	@ status1 = $status
	@ exit_status = $status1
	cat $backwardlog

	if ($exit_status) then
		# if backward rollback errored out, no point attempting forward rollback
		echo "TEST-E-ERROR: Backward rollback exited with non-zero status. See $backwardlog for more details" >>& $misclog
		exit $exit_status
	endif

	if ($?mupjnl_check_leftover_files) then
		$gtm_tst/com/mupjnl_check_leftover_files.csh
		@ status1 = $status
		if ($status1) then
			@ exit_status = $status1
			echo "TEST-E-ERROR: Backward rollback had leftover files. See $backwardlog for more details" >>& $misclog
			exit $exit_status
		endif
	endif

	# If forward rollback was not randomly chosen by the test framework, then skip it.
	if (0 == $gtm_test_forward_rollback) then
		# Since exit_status is 0, cleanup backup directories to avoid space issues, particularly in tests that
		# do multiple mupip_rollback.csh invocations (e.g. repeat_rollback_after_crash.csh), before exiting.
		echo "rm -rf $bakdir1" >>& $misclog
		rm -rf $bakdir1
		exit $exit_status
	endif

	echo "# Note down dse dump, mupip extract, broken & lost transaction info for .dat file from BACKWARD ROLLBACK" >>& $misclog
	echo "$DSE all -dump -all >& ${bakdir}_backward_dse_dump.log" >>& $misclog
	$DSE all -dump -all >& ${bakdir}_backward_dse_dump.log
	echo "$MUPIP extract ${bakdir}_backward_extract.out" >>& $misclog
	$MUPIP extract ${bakdir}_backward_extract.out >>& ${bakdir}_backward_extract.outx # .outx needed in case we see YDB-W-NOSELECT here
											  # with .out test framework will signal test failure
	@ status1 = $status
	if (0 != $status1) then
		if (224 == $status1) then
			$grep -q "NOSELECT" ${bakdir}_backward_extract.outx
			@ status1 = $status
			if (0 == $status1) then
				# NOSELECT situation. Possible if there is no extractable data at the seqno rollback point.
				touch ${bakdir}_backward_extract.out	# create file
			endif
		else
			@ status1 = 1
		endif
		if (0 != $status1) then
			# this is not a NOSELECT situation. flag it as a real error.
			set dispstr = "MUPIP EXTRACT errored out. See ${bakdir}_backward_extract.outx for details"
			echo "TEST-E-ERROR : $dispstr" >>& $misclog
		endif
	endif
	set back_losttn_file = `sed -n 's;.*Lost transactions extract file \([^ ]*\) created$;\1;p' $backwardlog`
	if (("" != "$losttransfile") && ("" != "$back_losttn_file")) then
		set losttransfile_fullpath = `$gtm_tst/com/realpath.csh $losttransfile`
		set back_losttn_file_fullpath = `$gtm_tst/com/realpath.csh $back_losttn_file`
		if ("$losttransfile_fullpath" != "$back_losttn_file_fullpath") then
			set dispstr = "-losttrans=$losttransfile was specified but losttn file $back_losttn_file was created instead"
			echo "TEST-E-ERROR : $dispstr" >>& $misclog
			exit 1
		endif
	endif
	set back_broken_file = `sed -n 's;.*Broken transactions extract file \([^ ]*\) created$;\1;p' $backwardlog`
	if (("" != "$brokenfile") && ("" != "$back_broken_file")) then
		set brokenfile_fullpath = $gtm_tst/com/realpath.csh $brokenfile
		set back_broken_file_fullpath = `$gtm_tst/com/realpath.csh $back_broken_file`
		if ("$brokenfile_fullpath" != "$back_broken_file_fullpath") then
			set dispstr = "-broken=$brokenfile was specified but brokentn file $back_broken_file was created instead"
			echo "TEST-E-ERROR : $dispstr" >>& $misclog
			exit 1
		endif
	endif
else
	echo '# Skipping backward rollback because "forward_only" was specified' >>& $misclog
endif

echo "#################################################################" >>& $misclog
echo "# Do forward rollback next" >>& $misclog
echo "#################################################################" >>& $misclog
set bakdir2 = dir_${bakdir}_mupip_rollback_2
unset noglob
$gtm_tst/com/backup_dbjnl.csh $bakdir2 "*.dat *.mjl*" mv nozip
set noglob
set use_back_seqno = 0
if ($do_resync) then
	if (! $do_rsync_strm) then
		# "-resync" specified but "-rsync_strm" not specified. Can safely use this for forward rollback too
		set rollforwparms = "$rollforwparms $resyncparms"
	else
		# "-resync" and "-rsync_strm" specified. It has no equivalent in forward rollback. So determine the seqno that
		# backward rollback took the db to and use that with -resync= in the hidden forward rollback.
		set use_back_seqno = 1
	endif
else if ($do_fetchresync) then
	# "-fetchresync" specified which has no equivalent in forward rollback. So determine the seqno that
	# backward rollback took the db to and use that with -resync= in the hidden forward rollback.
	set use_back_seqno = 1
endif
if (! $forward_only_specified) then
	# It is possible the rollback is done with a version >= r120 in which case the message is going to be YDB-I-RLBKJNSEQ
	# or a version < r120 in which case the message will be GTM-I-RLBKJNSEQ so search for both possibilities below.
	set forw_resync_seqno = `$tst_awk '/-I-RLBKJNSEQ,/ {print $10}' $backwardlog`
	if ($use_back_seqno) then
		set rollforwparms = "$rollforwparms -resync=$forw_resync_seqno"
	endif
	# If broken trans file was created in backward rollback, set -broken= a different file name for forward rollback
	if ("" != "$back_broken_file") then
		set forw_broken_file_expect = "${back_broken_file}_forw"
		set rollforwparms = "$rollforwparms -broken=${forw_broken_file_expect}"
	else
		set forw_broken_file_expect = ""
	endif
	# If losttrans file was created in backward rollback, set -losttrans= a different file name for forward rollback
	if ("" != "$back_losttn_file") then
		set forw_losttn_file_expect = "${back_losttn_file}_forw"
		set rollforwparms = "$rollforwparms -losttrans=${forw_losttn_file_expect}"
	else
		set forw_losttn_file_expect = ""
	endif
else if ("" != "$losttransfile") then
	set rollforwparms = "$rollforwparms -losttrans=$losttransfile"
endif
# Determine list of journal file names to pass to forward rollback. Could be "*" or actual file list
# depending on whether "gtm_test_switches_jnl_files" is unset or set to 1.
if (! $?gtm_test_switches_jnl_files) then
	set usestar = 1
else
	if (! $gtm_test_switches_jnl_files) then
		set usestar = 1
	else
		set usestar = 0
	endif
endif
if ($usestar) then
	set rollforwparms = "$rollforwparms $starparm"
else
	# The journal file names used at the time of backup_for_mupip_rollback.csh invocation might not be
	# the current journal file names anymore (e.g. c.mjl then vs c_curr.mjl now). For forward rollback
	# using "*" would try to rollback using c.mjl whereas it should use c_curr.mjl as that is the more
	# current journal file. In this case, do not use "*" but instead use a list of current jnl file names.
	# Determine list of journal file names from the dse all -dump output.
	unset noglob
	cp $bakdir1/*.dat .	# Restore db that backward rollback used to get list of current jnl file names
	set noglob
	set jnlfilelist = `$DSE all -dump |& $tst_awk -F/ '/Journal File:/ {print $NF;}'`
	set jnlfilelist = "$jnlfilelist"
	set commajnllist = ${jnlfilelist:as/ /,/}
	set rollforwparms = "$rollforwparms $commajnllist"
endif

unset noglob
cp $bakdir1/*.mjl* .
cp ${orig_bakdir}/*.dat .
set noglob

echo "$rollbackcmd $rollforwparms >>& $forwardlog" >>& $misclog
$rollbackcmd $rollforwparms >>& $forwardlog
@ status1 = $status
@ exit_status = $status1

if ($exit_status) then
	echo "TEST-E-ERROR: Forward rollback exited with non-zero status. See $forwardlog for more details" >>& $misclog
	exit $exit_status
endif

if ($?mupjnl_check_leftover_files) then
	$gtm_tst/com/mupjnl_check_leftover_files.csh
	@ status1 = $status
	if ($status1) then
		@ exit_status = $status1
		echo "TEST-E-ERROR: Forward rollback had leftover files. See $forwardlog for more details" >>& $misclog
		exit $exit_status
	endif
endif

if (! $forward_only_specified) then
	echo "# Note down dse dump, mupip extract, broken & lost transaction info for .dat file from FORWARD ROLLBACK" >>& $misclog
	echo "$DSE all -dump -all >& ${bakdir}_forward_dse_dump.log" >>& $misclog
	$DSE all -dump -all >& ${bakdir}_forward_dse_dump.log
	echo "$MUPIP extract ${bakdir}_forward_extract.out" >>& $misclog
	$MUPIP extract ${bakdir}_forward_extract.out >>& ${bakdir}_forward_extract.outx	# .outx needed in case we see YDB-W-NOSELECT here
											# with .out test framework will signal test failure
	@ status1 = $status
	if (0 != $status1) then
		if (224 == $status1) then
			$grep -q "NOSELECT" ${bakdir}_forward_extract.outx
			@ status1 = $status
			if (0 == $status1) then
				# NOSELECT situation. Possible if there is no extractable data at the seqno rollback point.
				touch ${bakdir}_forward_extract.out	# create file
			endif
		else
			@ status1 = 1
		endif
		if (0 != $status1) then
			# this is not a NOSELECT situation. flag it as a real error.
			set dispstr = "MUPIP EXTRACT errored out. See ${bakdir}_forward_extract.outx for details"
			echo "TEST-E-ERROR : $dispstr" >>& $misclog
			set exit_status = 1
		endif
	endif
	set forw_losttn_file = `sed -n 's;.*Lost transactions extract file \([^ ]*\) created$;\1;p' $forwardlog`
	set forw_losttn_file_fullpath = `$gtm_tst/com/realpath.csh $forw_losttn_file`
	set forw_losttn_file_expect_fullpath = `$gtm_tst/com/realpath.csh $forw_losttn_file_expect`
	if ("$forw_losttn_file_fullpath" != "$forw_losttn_file_expect_fullpath") then
		set dispstr = "-losttrans=$forw_losttn_file_expect was specified but losttn file $forw_losttn_file was created instead"
		echo "TEST-E-ERROR : $dispstr" >>& $misclog
		set exit_status = 1
	endif
	set forw_broken_file = `sed -n 's;.*Broken transactions extract file \([^ ]*\) created$;\1;p' $forwardlog`
	set forw_broken_file_fullpath = `$gtm_tst/com/realpath.csh $forw_broken_file`
	set forw_broken_file_expect_fullpath = `$gtm_tst/com/realpath.csh $forw_broken_file_expect`
	if ("$forw_broken_file_fullpath" != "$forw_broken_file_expect_fullpath") then
		set dispstr = "-broken=$forw_broken_file_expect was specified but broken file $forw_broken_file was created instead"
		echo "TEST-E-ERROR : $dispstr" >>& $misclog
		set exit_status = 1
	endif
endif

set bakdir3 = dir_${bakdir}_mupip_rollback_3
unset noglob
$gtm_tst/com/backup_dbjnl.csh $bakdir3 "*.dat *.mjl*" mv	# move over files for debugging test failures if any

set sort = "sort -T ."	# Use sort -T . to ensure temporary files get created in current directory instead of /tmp where we might not have enough space

if (! $forward_only_specified) then
	echo "#################################################################" >>& $misclog
	echo "# Check BACKWARD and FORWARD rollback produced the same database state" >>& $misclog
	echo "#################################################################" >>& $misclog

	echo "# Check rollback output. Filter out those fields that could be different (timestamps, certain messages etc.)" >>& $misclog
	foreach file ($backwardlog $forwardlog)
		# Below is reasoning for why each message is filtered out.
		# FILECREATE message show up for broken and losttn files both of which have different names in the forward rollback.
		# MUJNLSTAT messages have timestamp in them.
		# FILERENAME messages happen in backward rollback (which runs with journaling enabled) but not in forward rollback.
		# JNLSTAT messages show up in forward rollback (to say journaling has been turned off) but dont in backward rollback.
		# "SHOW output" includes the mjl file name which could be the renamed file name in case of backward rollback
		#	whereas forward rollback does no rename of jnl file names.
		# MUJNLPREVGEN is possible in forward rollback because we include all journal files needed since the last backup
		#	whereas with backward rollback we include only as many journal files as needed from the current end of the db.
		# MUINFO* messages (MUINFOSTR, MUINFOUINT4, MUINFOUINT6, MUINFOUINT8) show up with -verbose. These describe journal
		#	file-names and journal file offsets which can differ between forward and backward rollback.
		# CHNGTPRSLVTM is possible with backward rollback but never with forward rollback.
		set pattern = "FILECREATE|MUJNLSTAT|FILERENAME|JNLSTATE|^SHOW output|MUJNLPREVGEN|MUINFO|CHNGTPRSLVTM"
		# By default backward rollback runs with -verify, but forward rollback runs with -noverify.
		# Therefore filter out "Verify successful" message from both logs. Since pre r1.20 versions would have a
		# GTM-S-JNLSUCCESS message and r1.20 (and above) would have YDB-S-JNLSUCCESS messages (and both types of
		# versions can call the mupip_rollback.csh script), allow for both patterns.
		set pattern = "$pattern|-S-JNLSUCCESS, Verify successful"
		if ($do_fetchresync) then
			# If -fetchresync is used in backward rollback, then we need to filter associated logs with establishing the
			#	connection on a remote host:port since forward rollback does not support it. The set of lines
			#	corresponding to that have been determined as satisfying one of the below patterns.
			set pattern = "$pattern|Connecting|Connection|History|Received|Sending|Remote|Waiting|endianness|Determined"
		endif
		if ($use_back_seqno) then
			# If -fetchresync or -resync/-rsync_strm were used, filter out RESOLVESEQNO message since it could start out
			# with a higher seqno in backward rollback relative to the final seqno of the instance after the rollback, but
			# that means forward rollback will be provided the final seqno as the -resync= parameter which means it would
			# start out with this in the RESOLVESEQNO message.
			# Similar to RESOLVESEQNO, filter out RESOLVESEQSTRM as well (which is for non-supplementary stream #).
			set pattern = "$pattern|RESOLVESEQNO|RESOLVESEQSTRM"
		endif
		if ("$file" == "$backwardlog") then
			# FILENOTCREATE is possible if -losttrans or -broken was specified in backward rollback command but no such file
			#	got created. In the forward rollback command, we would not specify these qualifiers in that case so no
			#	such FILENOTCREATE message will show up.
			set pattern = "$pattern|FILENOTCREATE"
		endif
		# If -resync=1 is specified in forward rollback, it is possible that a RLBKSTRMSEQ message is printed for backward
		# rollback but not for forward rollback because the latter did not process any journal record with a non-zero
		# strm_seqno whereas backward rollback did see the instance file header as supplementary and so would still print
		# a seqno of 1. So filter out the RLBKSTRMSEQ message for Stream  0 with Seqno 1 in that case.
		if (1 == $forw_resync_seqno) then
			set pattern = "$pattern|RLBKSTRMSEQ.*Stream  0 : Seqno 1 "
		endif
		# In case caller_used_noresync is 1, forward and backward rollback could end up with different Stream Reg Seqno fields.
		# This is because forward rollback plays from one direction and stops at the desired stream seqno whereas backward
		# rollback plays from the reverse direction AND -noresync resets the Stream Reg Seqno somewhere in between.
		# So ignore any RLBKSTRMSEQ messages in this case. Note that the database extract etc. should be identical even in this case.
		if ($caller_used_noresync) then
			set pattern = "$pattern|RLBKSTRMSEQ.*Stream  [1-9]"
		else
			# RLBKSTRMSEQ message with Seqno 1 can additionally show up for non-zero stream #s in case of backward rollback
			#	since it dumps them based on the seqno stored in the instance file which is updated on receipt of a history
			#	record from the source side without touching the database strm_reg_seqno fields (which is what forward
			#	rollback bases its RLBKSTRMSEQ message on). So filter those out since they can be different.
			#	Note that the below wont work correctly in case the stream # is 10 thru 15 but we dont exercise that
			#	codepath in the test system so it is okay for now.
			set pattern = "$pattern|RLBKSTRMSEQ.*Stream  [1-9] : Seqno 1 "
		endif
		$grep -vE "$pattern" $file >& $file.filtered
		# It is possible that backward and forward rollback displays the SHOW output of various journal files (across multiple
		# regions in different order). So need to sort the output before doing the diff.
		$sort $file.filtered >& $file.filtered.sort
	end
	echo "diff {$backwardlog,$forwardlog}.filtered.sort" >>& $misclog
	diff {$backwardlog,$forwardlog}.filtered.sort >>& $misclog
	if ($status) then
		echo "TEST-E-ERROR : ROLLBACK LOG diff of backward and forward rollback failed. See above for details" >>& $misclog
		set exit_status = 1
	endif

	echo "# Check dse dump for seqno match" >>& $misclog
	foreach direction (backward forward)
		# Backward rollback displays "Replication ON" whereas forward rollback will display "Replication OFF" in the same
		# line where "Region Seqno" is displayed so change ON to OFF as part of the filtering to help with the later diff.
		# Also "Zqgblmod Seqno" and "Zqgblmod Trans" would be non-zero in case of a backward rollback that uses -fetchresync
		# whereas a forward rollback does not support -fetchresync so these fields would remain unchanged. So filter them out.
		# Note that even though -fetchresync is not used in this particular invocation of mupip_rollback.csh, it could have
		# been used on a prior invocation of mupip_rollback.csh on this instance so we should filter out "Zqgblmod" whether
		# or not -fetchresync is used in this invocation.
		set excludepattern = "Zqgblmod Seqno"

		# In case of a supplementary instance P, the database file header gets a Stream Reg Seqno value of 1 the moment a
		# A->P type connection happens. But the backup on P (taken by backup_for_mupip_rollback.csh) would have happened
		# at P startup which would be before the A->P connection event. So it is possible the forward rollback dse output
		# has a Stream Reg Seqno value of 0 while the backward rollback output has a value of 1. Filter out this discrepancy.
		# Note that if the backward rollback output has a Stream Reg Seqno value any more than 1, then we do expect the forward
		# rollback output to also have the same value. It is only 1 which is the special value.
		#	 Stream  1: Reg Seqno   0x0000000000000001
		set excludepattern = "$excludepattern|Stream[ ]*[1-9]*: Reg Seqno[ ]*0x0000000000000001"

		# In case caller_used_noresync is 1, forward and backward rollback could end up with different Stream Reg Seqno fields.
		# This is because forward rollback plays from one direction and stops at the desired stream seqno whereas backward
		# rollback plays from the reverse direction AND -noresync resets the Stream Reg Seqno somewhere in between.
		# So ignore just this. Note that the database extract etc. should all be identical even in this case.
		if ($caller_used_noresync) then
			set excludepattern = "$excludepattern|Stream[ ]*[1-9]*: Reg Seqno[ ]*0x.*"
		endif
		$tst_awk '$0 ~ /Seqno/ && $0 !~ /'"$excludepattern"'/ { gsub(/ ON/,"OFF"); print }' ${bakdir}_${direction}_dse_dump.log >& ${bakdir}_${direction}_dse_dump.log.filtered
	end
	echo "diff ${bakdir}_{backward,forward}_dse_dump.log.filtered" >>& $misclog
	diff ${bakdir}_{backward,forward}_dse_dump.log.filtered >>& $misclog
	if ($status) then
		echo "TEST-E-ERROR : DSE DUMP diff of backward and forward rollback failed. See above for details" >>& $misclog
		set exit_status = 1
	endif

	echo "# Check mupip extract" >>& $misclog
	# The second line of the extract file contains a timestamp so need to remove that before the diff.
	foreach direction (backward forward)
		$tail -n +3 ${bakdir}_${direction}_extract.out >& ${bakdir}_${direction}_extract.out.filtered
	end
	# Since extract files could be huge, use "cmp" instead of "diff" (faster).
	echo "cmp ${bakdir}_{backward,forward}_extract.out.filtered" >>& $misclog
	cmp ${bakdir}_{backward,forward}_extract.out.filtered >>& $misclog
	if ($status) then
		echo "TEST-E-ERROR : MUPIP EXTRACT diff of backward and forward rollback failed. See above for details" >>& $misclog
		set exit_status = 1
	endif

	echo "# Check appropriate lost transaction files got created" >>& $misclog
	if ("" != "$back_losttn_file") then
		# A losttn transaction file was created in backward and forward rollback. Check diff.
		# A backward rollback lost transaction file contains the replication instance name as the 4th column in the first line
		# whereas a forward rollback does not. So filter that out.
		# Also, a forward rollback lost transaction file always contains SECONDARY as the 3rd column in the first line
		# whereas a backward rollback could contain either PRIMARY or SECONDARY. So filter that out.
		# Since rollback could process the individual regions in an arbitrary order, it is possible the lost transaction
		# file contains records in a different order in the backward vs forward case. So sort it.
		# The 5th column could optionally contain UTF-8 so include that in the output.
		set dispstr=""
		if ($?gtm_chset) then
			if ("UTF-8" == "$gtm_chset") then
				set dispstr = ',$5'
			endif
		endif
		if ($do_fetchresync) then
			$tst_awk '{if (NR == 1) print $1,$2,"SECONDARY"'$dispstr'; else print; }' $back_losttn_file	\
									| $sort >& $back_losttn_file.sort
		else
			$tst_awk '{if (NR == 1) print $1,$2,$3'$dispstr'; else print; }' $back_losttn_file | $sort >& $back_losttn_file.sort
		endif
		$sort $forw_losttn_file >& $forw_losttn_file.sort
		echo "cmp $back_losttn_file.sort $forw_losttn_file.sort" >>& $misclog
		cmp $back_losttn_file.sort $forw_losttn_file.sort >>& $misclog
		if ($status) then
			echo "TEST-E-ERROR : LOST TRANS diff of backward and forward rollback failed. See above for details" >>& $misclog
			set exit_status = 1
		endif
	endif

	echo "# Check appropriate broken transaction files got created" >>& $misclog
	if ("" != "$back_broken_file") then
		# A broken transaction file was created in backward and forward rollback. Check diff.
		# Since rollback could process the individual regions in an arbitrary order, it is possible the broken transaction
		# file contains records in a different order in the backward vs forward case. So sort it.
		$sort $back_broken_file > $back_broken_file.sort
		$sort $forw_broken_file > $forw_broken_file.sort
		echo "cmp $back_broken_file.sort $forw_broken_file.sort" >>& $misclog
		cmp $back_broken_file.sort $forw_broken_file.sort >>& $misclog
		if ($status) then
			echo "TEST-E-ERROR : BROKEN TRANS diff of backward and forward rollback failed. See above for details" \
				>>& $misclog
			set exit_status = 1
		endif
	endif

	cp $bakdir2/*.mjl* .	# restore mjl to reflect backward rollback
	cp $bakdir2/*.dat .	# restore dat to reflect backward rollback
else
	# Forward rollback done. Databases are in good shape.
	cp $bakdir3/*.dat.gz .	# restore dat to reflect forward rollback
	gunzip *.dat.gz
	# Move away replication instance file
	if (-e $gtm_repl_instance) then
		mv $gtm_repl_instance $gtm_repl_instance.orig_${n}
	endif
	# Create new replication instance file (below logic is copied from RCVR.csh)
	if ((1 == $test_replic_suppl_type) || (2 == $test_replic_suppl_type)) then
		set supplarg = "-supplementary"
	else
		set supplarg = ""
	endif
	echo "$MUPIP replic -instance_create -name=$gtm_test_cur_sec_name $supplarg $gtm_test_qdbrundown_parms" >>& $misclog
	$MUPIP replic -instance_create -name=$gtm_test_cur_sec_name $supplarg $gtm_test_qdbrundown_parms
	@ status1 = $status
	if ($status1) then
		echo "TEST-E-ERROR : MUPIP replic -instance_create failed. See $misclog for details" >>& $misclog
		set exit_status = 1
	endif
endif

echo "Exit status == $exit_status" >>& $misclog

if (0 == $exit_status) then
	# Create files/directories that will take up a lot of space as this causes accumulation of disk space
	# (and in turn disk-full scenarios) by the calling test if it invokes mupip_rollback.csh more than once.
	# Biggies are *.dat files (under bakdir* directories) and extract files
	# Cleaning them up is okay since this invocation of mupip_rollback.csh succeeded.
	echo "rm -rf $bakdir1 $bakdir2 $bakdir3" >>& $misclog
	rm -rf $bakdir1 $bakdir2 $bakdir3
	echo "rm -f ${bakdir}_*_extract.out{,.filtered}" >>& $misclog
	rm -f ${bakdir}_*_extract.out{,.filtered}	# * to account for "backward" and "forward"
endif

exit $exit_status
