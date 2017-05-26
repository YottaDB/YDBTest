#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# RF_EXTR.csh: Database extracts globals from source/receiver server, take the difference
#
#
#===================================================
# EXTRACTS and Compare Source  and receiver database
#===================================================
setenv rfextr_debuglog "RF_EXTR_debuglog.out"
if !($?test_replic) then
	exit
endif
if ( ($gtm_test_trigger) && (! $?gtm_test_extr_no_trig) ) then
	setenv gtm_test_trig_compare 1
endif
# Need to debug if extract takes too much time.
# The start time and end time (extr_end.txt) will always be in $tst_working_dir irrespective of what the current $pri_shell is
date >>& $rfextr_debuglog
if ($?gtm_test_replic_timestamp) then
	setenv extract_time $gtm_test_replic_timestamp
else
	setenv extract_time `date +%H_%M_%S`
endif
set gtm_ver_comparison = "postmultisite"
if ( -e "priorver.txt" ) then
	set premsver = `$tail -n +1 priorver.txt`
	set gtm_ver_comparison = `echo $premsver | $tst_awk '{v = "V52000"; if ($1 < v) print "premultisite"}'`
endif

if ( "MULTISITE" != $test_replic ) then
	if ($tst_org_host == $tst_remote_host) then
		set multi_hosts = 0
	else
		set multi_hosts = 1
	endif

	set priextr = "pri_${extract_time}.glo"
	set secextr = "sec_${extract_time}.glo"
	echo "# Comparing the extracts : $priextr and $secextr"		>>&! $rfextr_debuglog
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/db_extract.csh $priextr $?gtm_test_trig_compare"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/db_extract.csh $secextr $?gtm_test_trig_compare"
	set diffstat = 0
	set trigdiff = 0
	if ($multi_hosts) then
		# In case of multi-hosts use checksum instead of scp'ing the whole file
		$pri_shell "$pri_getenv; cd $PRI_SIDE; openssl dgst -sha512 $priextr" >&! ${priextr}.cksum
		$sec_shell "$sec_getenv; cd $SEC_SIDE; openssl dgst -sha512 $secextr" >&! ${secextr}.cksum
		set pri_cksum = `$tst_awk -F = '/'$priextr'/ {print $NF}' ${priextr}.cksum`
		set sec_cksum = `$tst_awk -F = '/'$secextr'/ {print $NF}' ${secextr}.cksum`
		if ("$pri_cksum" != "$sec_cksum") set diffstat = 1
		if ($?gtm_test_trig_compare) then
			if ($tst_now_secondary != $tst_org_host) then
				$rcp "$tst_remote_host":"$SEC_SIDE/${secextr:r}.trg" "${secextr:r}.trg"
			else
				$rcp "$tst_remote_host":"$PRI_SIDE/${priextr:r}.trg" "${priextr:r}.trg"
			endif
			$gtm_tst/com/sorted_compare.csh ${priextr:r}.trg ${secextr:r}.trg
			set trigdiff = $status
		endif
	else
		# In case of single host, use cmp as computing sha512 is very cpu intensive
		$tst_cmpsilent $PRI_SIDE/$priextr $SEC_SIDE/$secextr
		set diffstat = $status
		if ($?gtm_test_trig_compare) then
			$gtm_tst/com/sorted_compare.csh $PRI_SIDE/${priextr:r}.trg $SEC_SIDE/${secextr:r}.trg
			set trigdiff = $status
		endif
	endif
	if ($trigdiff) then
		echo "RFEXTR-E-FAIL: trigger extract is different on primary and secondary"
		echo "diff ${priextr:r}.trg $SEC_SIDE/${secextr:r}.trg follows"
		diff ${priextr:r}.trg $SEC_SIDE/${secextr:r}.trg
	endif

	cd $PRI_DIR
	if ($tst_org_host == $tst_remote_host) then
		set case="1"
	else
		# Take care of fail over scenario here
		if ($tst_now_secondary != $tst_org_host) then
			set case="2"
		else
			set case="3"
		endif
	endif
	echo "# The case number is :"$case >>& $rfextr_debuglog
	echo "# diffstat is: "$diffstat >>& $rfextr_debuglog
	if ($diffstat != 0) then
		switch ($case)
		case 1:
			if ( !(-e $PRI_DIR/$secextr) && (-e $SEC_SIDE/$secextr) ) cp $SEC_SIDE/$secextr $PRI_DIR/
			if ( !(-e $PRI_DIR/$priextr) && (-e $PRI_SIDE/$priextr) ) cp $PRI_SIDE/$priextr $PRI_DIR/
			if (-e $SEC_SIDE/helper.gde) then
				cp $SEC_SIDE/helper.gde "rcv_helper.gde"
				set passtmp = "rcv_helper.gde"
			endif
			if (-e $SEC_SIDE/tmp.com) then
				cp $SEC_SIDE/tmp.com "rcv_tmp.com"
				set passtmp = "rcv_tmp.com"
			endif
			set origfile=$priextr
			set cmpfile=$secextr
			breaksw
		case 2:
			$rcp "$tst_remote_host":"$SEC_SIDE/$secextr"  "$secextr"
			$rcp "$tst_remote_host":"$SEC_SIDE/tmp.com" "rcv_tmp.com"
			set origfile=$priextr
			set cmpfile=$secextr
			breaksw
		case 3:
			$rcp "$tst_remote_host":"$PRI_SIDE/$priextr"  "$priextr"
			$rcp "$tst_remote_host":"$PRI_SIDE/tmp.com" "rcv_tmp.com"
			set origfile=$secextr
			set cmpfile=$priextr
		endsw
		if !( -e $priextr && -e $secextr ) then
			echo "Either primary extract file or the secondary extract file does not exist"
			echo "TEST-E-FAILED : DATABASE EXTRACT FAILED"
			exit 1
		endif
		# The diff can be because of the representational differences of some chars
		# e.g double quote between the pre V52000 and post V52000 versions
		if ( "premultisite" == $gtm_ver_comparison ) then
			source $gtm_tst/com/RF_EXTR_premltisite.csh $origfile $cmpfile $passtmp
			if ($status) then
				echo "TEST-E-FAILED: DATABASE EXTRACTs on PRIMARY and SECONDARY are DIFFERENT"
				echo "Following is the number of lines in the extracts"
				wc -l $origfile $cmpfile
			else
				echo "DATABASE EXTRACT PASSED"
			endif
		else
			# The primary and secondary might have different spanning regions configuration
			# In that case use the below helper script to verify the extract files
			source $gtm_tst/com/RF_EXTR_spanreg.csh $priextr $secextr
			if ($status) then
				echo "TEST-E-FAILED: DATABASE EXTRACTs on PRIMARY and SECONDARY are DIFFERENT. Check $rfextr_debuglog for details"
			else
				echo "DATABASE EXTRACT PASSED"
			endif
		endif
	else
		echo "DATABASE EXTRACT PASSED"
	endif
	cd -
else
	if ( "" == $1 ) then
		echo "EXTRACT-E-MULTISITE.List of instances to extract is empty"
		exit 1
	endif
	# do db extracts on all instances
	# to make comparison quicker, group the instances by host and do a cmp among them
	# compare sha512 values among one instance per group (host)
	# Whenever comparison fails (within group or across group, copy over remote extract and call helper scripts
	set instlist = "$argv"
	set hostlist = ""
	foreach cur_inst ($instlist)
		$MSR RUN $cur_inst 'set msr_dont_trace;$gtm_tst/com/db_extract.csh '$cur_inst'_'${extract_time}'.glo '$?gtm_test_trig_compare''
		set count = ${cur_inst:s/INST//}
		set host = `eval 'echo $gtm_test_msr_HOSTNAME'${count}`
		# group instances by hosts
		echo $hostlist |& $grep -w $host >&! /dev/null
		if ($status) then
			# $host isn't in hostlist already
			set hostlist = ($hostlist $host)
			set insts_$host= ($cur_inst)
		else
			# $host is in hostlist
			set insts_$host = (`eval 'echo $insts_'${host}` $cur_inst)
		endif
	end
	set acrosshosts = ""
	set pairs = ""
	# pair up instances within each host. If there is only one instance in a host, the pair will be empty
	foreach host ($hostlist)
		set instances = (`eval 'echo $insts_'${host}`)
		echo "$host : $instances" >>&! $rfextr_debuglog
		set firstinst =  $instances[1]
		set acrosshosts = ($acrosshosts $firstinst)
		set instances = (`echo $instances[2-]`)
		foreach inst ($instances)
			set pairs = ($pairs ${firstinst}:${inst})
		end
	end
	# pair up instances across hosts
	foreach inst ($acrosshosts[2-])
		set pairs = ($pairs "$acrosshosts[1]":$inst)
	end

	foreach pair ($pairs)
		setenv extracts_processed
		set x = `echo $pair | cut -d : -f 1`
		set y = `echo $pair | cut -d : -f 2`
		set countx  = ${x:s/INST//}
		set dbpathx = `eval 'echo $gtm_test_msr_DBDIR'${countx}`
		set extrx   = ${x}_${extract_time}.glo
		set hostx   = `eval 'echo $gtm_test_msr_HOSTNAME'${countx}`
		set county  = ${y:s/INST//}
		set dbpathy = `eval 'echo $gtm_test_msr_DBDIR'${county}`
		set extry   = ${y}_${extract_time}.glo
		set hosty   = `eval 'echo $gtm_test_msr_HOSTNAME'${county}`
		echo ""									>>&! $rfextr_debuglog
		echo "# Comparing the extracts : $extrx @$hostx and $extry @$hosty"	>>&! $rfextr_debuglog
		set diffstat = 1
		set trigdiff = 0
		if ("$hostx" == "$hosty") then
			if ("$HOST:r:r:r:r" == "$hostx") then
				$tst_cmpsilent $dbpathx/$extrx $dbpathy/$extry
				set diffstat = $status
				if ($?gtm_test_trig_compare) then
					$gtm_tst/com/sorted_compare.csh $dbpathx/${extrx:r}.trg $dbpathy/${extry:r}.trg
					set trigdiff = $status
				endif
			else
				set tmpdiff = `$MSR RUN $x 'set msr_dont_trace ; set msr_dont_chk_stat ; cmp '$dbpathx/$extrx' '$dbpathy/$extry' '`
				if ("" != "$tmpdiff") set diffstat = 1
				if ($?gtm_test_trig_compare) then
					set tmpdiff = `$MSR RUN $x 'set msr_dont_trace ; set msr_dont_chk_stat ; $gtm_tst/com/sorted_compare.csh '$dbpathx/${extrx:r}.trg' '$dbpathy/${extry:r}.trg' '`
					if ("" != "$tmpdiff") set trigdiff = 1
				endif
			endif
		else
			$MSR RUN $x 'set msr_dont_trace;openssl dgst -sha512 '$extrx'' >&! ${extrx}.cksum
			$MSR RUN $y 'set msr_dont_trace;openssl dgst -sha512 '$extry'' >&! ${extry}.cksum
			set x_cksum = `$tst_awk -F = '/'$extrx'/ {print $NF}' ${extrx}.cksum`
			set y_cksum = `$tst_awk -F = '/'$extry'/ {print $NF}' ${extry}.cksum`
			if ("$x_cksum" == "$y_cksum") set diffstat = 0
			if ($?gtm_test_trig_compare) then
				if ("INST1" != "$x") then
					$MSR RUN SRC=INST1 RCV=$x 'set msr_dont_trace; $gtm_tst/com/cp_remote_file.csh  _REMOTEINFO___RCV_DIR__/'${extrx:r}.trg' __SRC_DIR__/'
				endif
				if ("INST1" != "$y") then
					$MSR RUN SRC=INST1 RCV=$y 'set msr_dont_trace; $gtm_tst/com/cp_remote_file.csh  _REMOTEINFO___RCV_DIR__/'${extry:r}.trg' __SRC_DIR__/'
				endif
				$gtm_tst/com/sorted_compare.csh ${extrx:r}.trg ${extry:r}.trg
				set trigdiff = $status
			endif
		endif
		if ($trigdiff) then
			if (! -e ${extrx:r}.trg) $MSR RUN SRC=INST1 RCV=$x 'set msr_dont_trace; $gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/'${extrx:r}.trg' __SRC_DIR__/'
			if (! -e ${extry:r}.trg) $MSR RUN SRC=INST1 RCV=$y 'set msr_dont_trace; $gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/'${extry:r}.trg' __SRC_DIR__/'
			$gtm_tst/com/RF_EXTR_supplinst.csh ${extrx:r}.trg ${extry:r}.trg
			if ($status) then
				echo "RFEXTR-E-FAIL: trigger extract is different on primary and secondary"
				echo "Check ${extrx:r}.trg and ${extry:r}.trg"
			endif
		endif
		if ($diffstat) then
			$MSR RUN SRC=INST1 RCV=$y 'set msr_dont_trace; $gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/'$extry' __SRC_DIR__/'
			if ( "premultisite" == $gtm_ver_comparison ) then
				$MSR RUN SRC=INST1 RCV=$y 'set msr_dont_trace; $gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/tmp.com __SRC_DIR__/compare_extract_at_source/'$rcv'_tmp.com'
				source $gtm_tst/com/RF_EXTR_premultisite.csh $extrx $extry ${rcv}_tmp.com
				if ($status) set diff_inst = ($extrx $extry)
			else
				$gtm_tst/com/RF_EXTR_supplinst.csh $extrx $extry
				if ($status) set diff_inst = ($extrx $extry)
			endif
			if ($?diff_inst) then
				# The primary and secondary might have different spanning regions configuration
				# In that case use the below helper script to verify the extract files
				source $gtm_tst/com/RF_EXTR_spanreg.csh $diff_inst[1] $diff_inst[2]
				if (0 != $status) then
					echo "DATABASE EXTRACTS $diff_inst[1] & $diff_inst[2] are different"
					setenv diff_flag
				endif
				unset diff_inst
			endif
		endif
	end
	if ( (!($?diff_flag)) && ($?extracts_processed) ) then
		echo "DATABASE EXTRACT PASSED"
		unsetenv extracts_processed
	else
		echo "TEST-E-FAILED: RF_EXTR failed. Check the above messages and $rfextr_debuglog for details"
		unsetenv diff_flag
	endif
	cd -
endif
date >>& $rfextr_debuglog
