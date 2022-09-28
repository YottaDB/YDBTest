#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
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

# The script checks for ipcs usages from *.dat and *.repl files. Ideal usage would be to check for the absence of any
set ipcdircheck = "$gtm_tst_out/$testname"
if ($?test_subtest_name) then
	set ipcdircheck = "$ipcdircheck/$test_subtest_name"
else
	set ipcdircheck = "$ipcdircheck/tmp"
endif
set dirs = ". "
if ("all" == "$1") then
	set instpat = 'instance[0-9]*'
	set nonomatch
	set instdirs = $instpat
	unset nonomatch
	if ("$instdirs" != "$instpat") then
		set dirs = "$dirs $instdirs"
	endif
endif

if ("" != "$2") then
	set preipcsfile = "$2"
else
	set preipcsfile = "ipcs.dummy"	# so that the rest of the script just works fine
endif

if (! -e $preipcsfile) then
	set preipcsnone = 1
	touch $preipcsfile
endif

if ($?gtm_test_ipcsalert) then
	if (0 != "$gtm_test_ipcsalert") then
		set do_ipcsalert = 1
	endif
endif

set all_sem = ""
set all_shm = ""
set debug_info = ""
foreach dir ($dirs)
	if !(-d $dir) continue
	cd $dir
	set dbpat = "*.dat"
	set nonomatch
	set dbfiles = $dbpat
	unset nonomatch
	if ("$dbfiles" != "$dbpat") then
		foreach dbfile ($dbfiles)
			# $3 - Semaphore array ; $6 - Shared memory
			set ipc = `$MUPIP ftok $dbfile |& $tst_awk '$1 == "'$dbfile'" {printf ("%s %s ",$3,$6)}'`
			set ftokipc = `$gtm_exe/ftok -id=43 $dbfile |& $tst_awk '$1 == "'$dbfile'" {printf "%s ",$5}'` # Semaphore array
			# There are multiple reasons why the above dbfile wouldn't return proper ipcs, like say they were not proper gtm db file etc.
			# In such cases, just mark ipcs as -1, to avoid subscript out of range errors below
			if ($#ipc != 2 ) then
				set ipc = ( -1 -1 )
			endif
			set all_sem = "$all_sem $ipc[1] $ftokipc"
			set all_shm = "$all_shm $ipc[2]"
			set debug_info = "$debug_info dbfile=$dbfile --> sem=$ipc[1],shm=$ipc[2],ftoksem=$ftokipc "
		end
	endif

	set replpat = "*.repl"
	set nonomatch
	set replfiles = $replpat
	unset nonomatch
	if ("$replfiles" != "$replpat") then
		foreach replfile ($replfiles)
			setenv gtm_repl_instance $replfile
			set jnlpoolipc = `$MUPIP ftok -jnlpool $gtm_repl_instance   |& $tst_awk '$1 == "jnlpool" {printf "%s %s ",$3,$6}'`
			set rcvpoolipc = `$MUPIP ftok -recvpool $gtm_repl_instance  |& $tst_awk '$1 == "recvpool" {printf "%s %s ",$3,$6}'`
			set repl_ftokipc = `$gtm_exe/ftok -id=44 $gtm_repl_instance |& $tst_awk '$1 == "'$gtm_repl_instance'" {printf "%s ",$5}'`
			if ($#rcvpoolipc != 2 ) then
				set rcvpoolipc = ( -1 -1 )
			endif
			if ($#jnlpoolipc != 2 ) then
				set jnlpoolipc = ( -1 -1 )
			endif
			set all_sem = "$all_sem $jnlpoolipc[1] $rcvpoolipc[1] $repl_ftokipc"
			set all_shm = "$all_shm $jnlpoolipc[2] $rcvpoolipc[2]"
			set debug_info = "$debug_info replfile=$replfile --> jnlpoolipcs=$jnlpoolipc ,rcvpoolipcs=$rcvpoolipc ,repl_ftokipc=$repl_ftokipc"
		end
	endif
	cd -
end
$gtm_tst/com/ipcs -s |& $grep -E "$USER|$gtmtest1" >&! ipcs_s_$$
$gtm_tst/com/ipcs -m |& $grep -E "$USER|$gtmtest1" >&! ipcs_m_$$
foreach ipc ($all_sem)
	if ("-1" != "$ipc") then
		$grep -qw $ipc ipcs_s_$$
		if !($status) then
			# If the $ipc is found in $preipcsfile file, do not throw error
			$grep -qw $ipc $preipcsfile
			if ($status) echo "CHECK-W-SEM : $ipc is not expected to be left around. (debug info : $debug_info)"
		endif
	endif
end

foreach ipc ($all_shm)
	if ("-1" != "$ipc") then
		$grep -qw $ipc ipcs_m_$$
		if !($status) then
			# If the $ipc is found in $preipcsfile file, do not throw error
			$grep -qw $ipc $preipcsfile
			if ($status) echo "CHECK-W-SHM : $ipc is not expected to be left around. (debug info : $debug_info)"
		endif
	endif
end

if ( ($?do_ipcsalert) && (! $?preipcsnone) ) then
	# Do this check only if gtm_test_ipcsalert is set and the preipcs file actually existed (won't exist in remote side of single-host replic test)
	set ipcsnow = "ipcs_a_$$"
	set preipcs = ${preipcsfile:t}_useronly_$$
	set suspected_ipcs = suspected_ipcs_$$
	$gtm_tst/com/ipcs -a |& $grep -E "$USER|$gtmtest1"  >&! $ipcsnow
	if (! -z $ipcsnow) then
		sort $ipcsnow>&! ${ipcsnow}_sort
		$grep -E "$USER|$gtmtest1" $preipcsfile | sort >&! $preipcs
		comm -13 $preipcs ${ipcsnow}_sort >&! $suspected_ipcs
		if (! -z $suspected_ipcs) then
			cp $preipcsfile .
			echo "CHECK-W-IPCS : ipcs suspected to be left behind. Check $preipcsfile:t, $ipcsnow, $suspected_ipcs @ $HOST:ar"
		endif
	endif
	set prerelinkctl = "${preipcsfile:h}/relinkctl.b4subtest"
	if (-e $prerelinkctl) then
		set relinkctlnow = "relinkctl_now_$$"
		set suspected_relinkctl = "suspected_relinkctl_$$"
		ls -1 /tmp/relinkdir/$USER |& sort >&! $relinkctlnow
		if (! -z $relinkctlnow) then
			comm -13 $prerelinkctl $relinkctlnow >&! $suspected_relinkctl
			if (! -z $suspected_relinkctl) then
				cp $prerelinkctl .
				echo "CHECK-W-RELINKCTL : relinkctl files suspected to be left behind. Check $prerelinkctl:t, $relinkctlnow, $suspected_relinkctl @ $HOST:ar"
			endif
		endif
	endif
endif
# if a dummy ipcs file is created, remove it
if ( ($?preipcsnone) || ("" == "$2") ) rm -f $preipcsfile
