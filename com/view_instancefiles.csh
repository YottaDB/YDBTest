#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Note the 1-1 correspondence between opt_array and opt_name_array. Any additions/deletions  must be done in both arrays.
set opt_array      = ("\-print" "\-printhistory" "\-diff" "\-instance"   "\-detail" "\-ignore")
set opt_name_array = ("printit" "printhistory"   "diffit" "instancelist" "detailit" "ignoreit")
source $gtm_tst/com/getargs.csh $argv

# Note that the string passed to -ignore converts multiple spaces into single space and so string like the below will never match.
# HDR STRM  0: Journal Sequence Number
# Either pass a single space "HDR STRM 0:" or just pass string after the problematic space "0: Journal Sequence Number" in such cases.

set echoline = "echo =========================================================="
set detail = ""
if ($?detailit) set detail = "-detail"
if (! $?ignoreit) set ignoreit = ""

set instoutpat = "instancefile_*.out"
set nonomatch
set instoutfiles = $instoutpat
unset nonomatch
if ("$instoutfiles" == "$instoutpat") then
	set cntsnapshot = 1
	if ($?diffit) then
		echo "TEST-E-CANNOTDIFF view_instancefiles.csh does not have any previous output to diff against"
	endif
else
	set prev_cntsnapshot = `ls instancefile_*.out | sed 's/.*_//g;s/\.out//g' | sort -n | $tail -n 1`
	@ cntsnapshot = $prev_cntsnapshot + 1
endif

if (! $?instancelist) setenv instancelist "$gtm_test_msr_all_instances"

foreach instx ($instancelist)
	# If this is a multi-host test and "view_instancefiles_filter" env var is defined by the calling test,
	# then we need to ensure that env var is set even in the remote instances. This is done by updating
	# "env_supplementary.csh" on those instances to define this env var.
	if ($test_replic_mh_type && $?view_instancefiles_filter) then
		# Note that we want the double-quotes surrounding the value of $view_instancefiles_filter as it is a multi-word
		# string containing spaces (or else one would get a "setenv: Too many arguments" error). Hence the need for
		# the weird-looking \\" below.
		$MSR RUN $instx 'set msr_dont_trace ; echo setenv view_instancefiles_filter \\"'$view_instancefiles_filter'\\" >> env_supplementary.csh'
	endif
	$MSR RUN $instx 'set msr_dont_trace; $MUPIP replic -editinstance -show '$detail' $gtm_repl_instance >& '"instancefile_$cntsnapshot.outx"
	$MSR RUN $instx 'set msr_dont_trace; ($tst_awk -f $gtm_tst/com/view_instancefiles.awk -v funcx=filter -v ignore="'$ignoreit'" '"instancefile_$cntsnapshot.outx > instancefile_$cntsnapshot.out)"
	if ($?printit) then
		$echoline
		echo "The instance file contents on $instx (instancefile_$cntsnapshot.out):"
		$MSR RUN $instx "set msr_dont_trace; cat instancefile_$cntsnapshot.out"
		set printlastline
	endif
	if ($?printhistory) then
		$echoline
		echo "History records for $instx at instancefile_$cntsnapshot.out"
		$MSR RUN $instx 'set msr_dont_trace; $tst_awk -f $gtm_tst/com/view_instancefiles.awk -v funcx=history ' "instancefile_$cntsnapshot.out"
		set printlastline
	endif

	if ($?diffit) then
		set tmpfile = /tmp/view_instancefiles_$$.out
		$echoline
		$MSR RUN $instx "set msr_dont_trace; set msr_dont_chk_stat; diff instancefile_${prev_cntsnapshot}.out instancefile_$cntsnapshot.out" >&! $tmpfile
		if (! $status) then
			echo "No diff on $instx between instancefile_${prev_cntsnapshot}.out instancefile_$cntsnapshot.out"
		else
    			echo "Diffing instancefile_${prev_cntsnapshot}.out and instancefile_$cntsnapshot.out on $instx"
			cat $tmpfile
		endif
		set printlastline
		\rm -f $tmpfile >& /dev/null
	endif
	if ($?printlastline) then
		$echoline
	else
		# if nothing was printed, let's still note where we saved off instancefile_$cntsnapshot.out
		echo "Snapshot of instance file on $instx written into instancefile_$cntsnapshot.out"
	endif
end
