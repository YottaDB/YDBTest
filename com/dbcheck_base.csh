#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
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
# dbcheck.csh : verifies data base integrity
#

#==============================
# Process arguments first
#==============================
if ($1 == "-nosprgde") then
	set okforsprgde = 0
	shift
else
	set okforsprgde = 1
endif
if ("$1" == "-wait_for_children_to_finish") then
	set wait_for_children_to_finish_specified = 1
	shift
else
	set wait_for_children_to_finish_specified = 0
endif
if ("$1" == "-noleftoveripccheck") then
	set noleftoveripccheck_specified = 1
	shift
else
	set noleftoveripccheck_specified = 0
endif

set arg1 = "$1"
if (-e "${arg1}.gld") then
	set dir = `dirname ${arg1}.gld`
	if ("$dir" != ".") then
		# A subdirectory has been specified. If so go into that subdirectory and do MUPIP INTEG -REG "*"
		cd $dir
		# Set gtmgbldir env var (not ydb_gbldir) in this test framework script
		# so we can run tests with older GT.M versions that don't understand ydb_gbldir.
		setenv gtmgbldir `basename ${arg1}.gld`
		shift
		set arg1 = "$1"
	endif
endif

if (!($?acc_meth)) setenv acc_meth "BG"
if (!($?GDE))  then
	if (!($?gtm_exe)) then
		if ($?gtm_dist) then
			setenv gtm_exe $gtm_dist
		else
			echo Please define \$gtm_exe (or \$gtm_dist)
			exit 1
		endif
	endif
	setenv GDE "$gtm_exe/mumps -run GDE"
endif
# $gtm_exe's existence is sure at this point
if (!($?MUPIP)) then
	setenv MUPIP "$gtm_exe/mupip"
endif

if (!($?gtmgbldir)) then
	setenv gtmgbldir "mumps.gld"
endif

if ($?tst_offline_reorg == 1) then
	$GTM << \emptytest >>&! emptyfiletest.log
	s a=$order(^%)
	i $l(a)=0  s f="rf_reorg.tmp"  o f  u f  w !,"EMPTY DATABASE(S)",!  c f
	h
\emptytest
	if (-f rf_reorg.tmp) then
        	\rm -f rf_reorg.tmp
	else
        	\rm -f rf_reorg.tmp
        	$MUPIP reorg >>&! offline_reorg.out
        	if ($status) then
                	echo "TEST FAILED in MUPIP REORG!"
        	endif
       	endif
endif

if ( $?HOSTOS == "0" )  setenv HOSTOS `uname -s`

# The below script sets online_noonline_specified and online_noonline to be used below
source $gtm_tst/com/set_online_for_dbcheck.csh $argv

echo $MUPIP

if (-e tmp.mupip) cp tmp.mupip tmp.mupip_`date +%y_%m_%d_%H_%M_%S`
if (("$arg1" != "") && ("FALSE" == "$online_noonline_specified")) then
	setenv dbname $arg1
	################
	if ($wait_for_children_to_finish_specified) then
		# do this only if there are multi-processes accessing the database, and
		# the parent is supposed to be the last process to finish
		set wait_time = 1
		while ($wait_time)
			$MUPIP integ $arg1.dat >&! tmp.mupip_wait
			$grep -q "\-E" tmp.mupip_wait
			if ($status) break
			@ wait_time = $wait_time + 1
			if ($wait_time == 10 ) break
			sleep 1
		end
		if ($wait_time == 10) then
			date
			echo "Waited 10 seconds for children, not waiting any longer"
			cat tmp.mupip_wait
		endif
	endif
	################
	if (! $noleftoveripccheck_specified) then
		source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 $arg1.dat # do rundown if needed before requiring standalone access
	endif
	echo "$MUPIP integ $arg1.dat"
	$MUPIP integ $arg1.dat >& tmp.mupip
else
	if (! $noleftoveripccheck_specified) then
		source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
	endif
	setenv dbname $arg1
	echo "$MUPIP integ -REG *"
	$MUPIP integ -REG $online_noonline "*" >& tmp.mupip
	# If gtm_test_trig_upgrade env var is defined, the parent test uses triggers and wants to additionally
	# test on-the-fly trigger upgrade (of ^#t global from #LABEL 2 to #LABEL 3).
	if ($?gtm_test_trig_upgrade) then
		# Do this only if journal files exist, since the LGTRIG records in them are needed to drive this test.
		set nonomatch = 1 ; set mjllist = *.mjl ; unset nonomatch
		if ("$mjllist" != '*.mjl') then
			@ num = 1
			while (-e $num)
				@ num = $num + 1
			end
			mkdir $num
			$GDE <<  GDE_EOF >&! $num/gde.out
				show -seg
				quit
GDE_EOF

			cp $gtmgbldir $num
			cp dbcreate.gde $num
			foreach file (`$tst_awk '/DYN/ { if ($2 !~ "\\.") printf "%s.dat\n", $2; else print $2;}' $num/gde.out`)
				cp ${file} $num
				set basefile = $file:r
				set nonomatch = 1 ; set mjllist = $basefile.mjl* ; unset nonomatch
				if ("$mjllist" != "$basefile.mjl*") cp $basefile.mjl* $num
			end
			# copy gtmcrypt.cfg & db_mapping_file for journal extract to work without CRYPTKEYFETCHFAILED error
			foreach value (gtmcrypt.cfg db_mapping_file)
				if (-e $value) then
					cp $value $num
				endif
			end
			cd $num
			$gtm_tst/com/trigupgrd_test.csh >& ../trig_upgrade.$num.log
			if (0 != $status) then
				echo "TEST-E-TRIGUPGRDTEST : Error in $num directory" >>& ../trig_upgrade.$num.log
			endif
			cd ..
		endif
	endif
endif

# the following while loop is to prevent file collision.  If a mupip.err_TIMESTAMP file already exist
# it will try the next file in the following sequence : XYZ_1, XYZ_1_2, XYZ_1_2_3, etc. until a non-
# existent file is found.
set mupip_err_file = "mupip.err_`date +%y_%m_%d_%H_%M_%S`"
set inc = 0
while (-e $mupip_err_file)
	@ inc++
	set mupip_err_file = "${mupip_err_file}_$inc"
end
cp tmp.mupip $mupip_err_file
$grep "Total error count from integ" tmp.mupip
if ($status == 0) then
	date
	\cat tmp.mupip
	set stat=1
else
	set error_free = `$tst_awk '/No errors detected by integ./ {count=count+1} END {print count}' tmp.mupip`
	set no_regions = `$gtm_tst/com/get_reg_list.csh count`
	if ("$arg1" != "") set no_regions=1
	if ("$error_free" == "$no_regions") then
		#if there are "No errors .." as many as the regions, it must be ok
		echo "No errors detected by integ."
		set stat=0
		$grep -q "YDB-E" tmp.mupip
		set estat = $status
		$grep -q "YDB-W" tmp.mupip
		set wstat = $status
		# mupip integ reports "No errors detected by integ." even though it sees the following errors. Lets report them
		$grep "Free blocks counter in file header:" tmp.mupip
		set ostat = $status
		if (! $ostat) then
			echo "Though mupip integ reported clean, one or more of the regions printed the above message(s)"
			echo "Check the file $mupip_err_file"
		endif
		if ((! $estat)||(! $wstat)) then
			echo "---------------------------------------------------------------"
			echo "TEST-E-DBCHECK error detected in dbcheck"
			cat tmp.mupip
			echo "---------------------------------------------------------------"
			set stat=1
		endif
	else
		echo "Number of regions does not match with number of *No errors* region count"
		echo '$error_free : '$error_free' ; $no_regions = '$no_regions''
		\cat tmp.mupip
		set stat=1
	endif
endif

# Generate .sprgde files if appropriate
if ($okforsprgde) then
	$gtm_tst/com/gensprgde.csh
	if ($status) then
		# An error occurred during .sprgde file generation. Exit dbcheck with error status.
		exit -1
	endif
endif

exit $stat
