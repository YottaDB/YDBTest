#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.	#
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

if ($?HOSTOS == "0")  setenv HOSTOS `uname -s`

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
	$MUPIP integ $online_noonline -REG "*" >& tmp.mupip

	set master_map_size = `$gtm_dist/mumps -run %XCMD 'write $$^%PEEKBYNAME("sgmnt_data.master_map_len","DEFAULT")'`
	if ("$master_map_size" == 4186112) then		# i.e. 8176*512
		# This means the database file is already in V7 format. This is possible if the test did not use
		# dbcreate.csh (i.e. it used "mupip create" instead in which case gtm_test_use_V6_DBs env var will not
		# be honored and so the db would have been created in V7 format) OR if it used more than 1 dbcheck.csh
		# call for 1 dbcreate.csh call (in that case,the second dbcheck.csh call will find the .dat file already
		# in V7 format). In either case, skip the "mupip upgrade" check below.
		set dbcheck_base_skip_upgrade_check = 1
	endif
	# If $tst_ver is a pure GT.M build (e.g. V71002) or a YottaDB version before r1.32, skip the upgrade check
	# as that logic requires support for $$^%PEEKBYNAME("gd_segment.sname",...) which exists only from r1.32 onwards.
	# But the upgrade logic can only happen for V7 format YottaDB releases. And that starts from r2.00 so check for that.
	if ($tst_ver =~ "V*_R*") then
		# This is a YottaDB build (e.g. V70005_R202)
		# Check if the YottaDB release i.e. xxx in Rxxx is less than 124.
		# Note that some versions might have been named V63009_R131C etc. In that case, only take 131
		# and ignore the trailing C etc. Hence the "cut" command below.
		set ydbrel = `echo $tst_ver | sed 's/.*_R//g' | cut -b 1-3`
		if ($ydbrel < 200) then
			set dbcheck_base_skip_upgrade_check = 1
		endif
	else
		# This is a pure GT.M build (e.g. V71002)
		set dbcheck_base_skip_upgrade_check = 1
	endif
	if (! $?dbcheck_base_skip_upgrade_check && $gtm_test_use_V6_DBs) then
		# The caller subtest script created DBs in V6 format (as part of a prior dbcreate.csh call).
		# So the .dat file would be in V6 format. Test "mupip upgrade" of that V6 DB to V7 format.
		set bakdir = `mktemp -p . -d dbcheck_base_bakdir_XXXXXX`
		set logfile = $bakdir.out

		# Most tests would only define gtmgbldir env var but some tests might define ydb_gbldir env var
		# Therefore check for both. Note that ydb_gbldir prevails over gtmgbldir.
		if ($?ydb_gbldir) then
			set oldgbldir = $ydb_gbldir
		else
			set oldgbldir = $gtmgbldir
		endif
		if (! -e $oldgbldir) then
			set oldgbldir = "${oldgbldir}.gld"
			if (! -e $oldgbldir) then
				echo "TEST-E-DBCHECK_BASE : gtmgbldir is set to [$oldgbldir] but file does not exist"
			endif
		endif
		set newgbldir = $PWD/$bakdir/$oldgbldir:t
		cp $oldgbldir $newgbldir

		# First get a copy of the .dat files using "mupip backup". But disable journaling etc. as that
		# can cause problems with multiple .dat files pointing to the same journal file. We only care about
		# the "mupip upgrade" part and for that we only need the .dat files.
		$MUPIP backup -journal=disable -nonewjnlfiles "*" $bakdir >& $logfile

		# Before running "mupip upgrade" or "mupip reorg -upgrade", unsetenv any white-box variable set by the
		# test system caller script. Otherwise, they will fail asserts (e.g. secshr_db_clnup.c line 294 etc.)
		# No need to re-enable this for rest of script so no save/restore done (like "gtmgbldir", "gtm_repl_instance").
		unsetenv gtm_white_box_test_case_enable

		unsetenv ydb_gbldir		# unset ydb_gbldir env var as we are going to set gtmgbldir in the next line
		setenv gtmgbldir $newgbldir
		unsetenv ydb_routines
		set oldroutines = "$gtmroutines"
		setenv gtmroutines ". $gtm_dist"
		if ($?gtm_chset) then
			if ("$gtm_chset" == "UTF-8") then
				setenv gtmroutines ". $gtm_dist/utf8"
			endif
		endif

		set oldconfig = ""
		if ("ENCRYPT" == $test_encryption) then
			# It is possible the subtest did not use "dbcreate.csh" but uses "dbcheck.csh" (e.g. gtm7077.csh)
			# In that case, "$gtmcrypt_config" might not exist. In that case, skip the below part.
			if (-e $gtmcrypt_config) then
				# Update gtmcrypt_config to reflect the new $bakdir subdirectory path for the db files
				# (mumps.dat etc.) or else we would get CRYPTKEYFETCHFAILED error ("Expected hash" error detail).
				cp $gtmcrypt_config $bakdir
				set oldconfig = $gtmcrypt_config
				set newconfig = $PWD/$bakdir/$oldconfig:t
				setenv gtmcrypt_config $newconfig
				# While most ".dat" lines in gtmcrypt.cfg are of the form "dat: ", there are some of
				# the form "dat = " (those created by com/modconfig.csh) so handle both cases below.
				cat > configch.m << GDECH
				 set reg="" for  set reg=\$view("GVNEXT",reg)  quit:reg=""  do
				 . set filename=\$view("GVFILE",reg)
				 . set basename=\$piece(filename,"/",\$length(filename,"/"))
				 . write "s,dat: """_filename_""",dat: ""$PWD/$bakdir/"_basename_""",;",!
				 . write "s,dat = """_filename_""",dat = ""$PWD/$bakdir/"_basename_""",;",!
GDECH
				$gtm_dist/mumps -run configch > $bakdir/config.sed
				sed -i -f $bakdir/config.sed $newconfig
				mv configch.m $bakdir
			endif
		endif

		cd $bakdir

		# Fix absolute path names of segments in .gld to relative path names as we want the gld to point
		# to db files in the "bak" subdirectory when "mupip upgrade" is done (that is, we do not want to
		# touch the original .dat files in the parent directory).
		cat > gdech.m << GDECH
		 set reg="" for  set reg=\$view("GVNEXT",reg)  quit:reg=""  do
		 . set segname=\$\$^%PEEKBYNAME("gd_segment.sname",reg,"S")
		 . set filename=\$view("GVFILE",reg)
		 . set filename=\$piece(filename,"/",\$length(filename,"/"))
		 . write "change -seg "_segname_" -file="_filename,!
GDECH

		# First run GDE with V7 version to make sure .gld is upgraded (if needed)
		$gtm_dist/mumps -run gdech >& gdech.com
		$gtm_dist/mumps -run GDE @gdech.com >& gdech.out

		# Before running mupip upgrade, check for any regions that could still be in V7 format
		# due to the mupip create being done outside of dbcreate.csh. Known cases currently are
		# - Tests that use ydb_env_set would have created YDBOCTO and YDBAIM regions in V7 format.
		# - Tests that use "gtm_test_repl_norepl" would have recreated HREG in com/db_extract.csh.
		# In these cases, [mupip upgrade -reg "*"] would issue a MUNOFINISH error (with a message
		# "HREG: is ineligible for MUPIP UPGRADE to V6p... is currently V7"). To avoid that, recreate
		# those specific regions using the V6 version just like dbcreate_base.csh would have done.
		set reglist = "YDBOCTO YDBAIM"
		if ($gtm_test_repl_norepl) then
			# This is a case where HREG is non-replicated and all other regions are replicated.
			# In this case, various scripts like "com/db_extract.csh" could have recreated HREG
			# using $tst_ver (i.e. V7 version).
			set reglist = "$reglist HREG"
		endif
		foreach reg ($reglist)
			set master_map_size = `$gtm_dist/mumps -run %XCMD 'write $$^%PEEKBYNAME("sgmnt_data.master_map_len","'$reg'")'`
			if ("$master_map_size" == 4186112) then		# i.e. 8176*512
				set dbfilepath = `$gtm_dist/mumps -run %XCMD 'write $view("GVFILE","'$reg'")'`
				rm -f $dbfilepath:t
				# Since we want the .dat file to be in V6 format, switch to the V6 version.
				source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
				# Since the .gld format could be different between the V6 and V7 version, create a fresh V6
				# format .gld instead of using the V7 format $gtmgbldir (could result in a GDINVALID error).
				setenv gtmgbldir v6_${newgbldir:t}
				$gtm_dist/mumps -run GDE change -seg DEFAULT -file=$dbfilepath:t >& v6_gde_change_${reg}_$$.out
				$MUPIP create >& dbcheck_base_mupip_create_${reg}_$$.out
				source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
				# Restore gtmgbldir to V7 format
				setenv gtmgbldir $newgbldir
			endif
		end

		# Take backup of pre-upgrade .dat files in case needed for later analysis of failed tests
		mkdir bak
		cp * bak >& cp.outx

		set logfile = dbcheck_base_mupip_upgrade_$$.out
		yes | $MUPIP upgrade -reg "*" >& $logfile

		# Before running "mupip reorg -upgrade" and "mupip integ", unsetenv "gtm_repl_instance" in case it is set
		# as otherwise they would fail with a REPLINSTACC error (because we do not copy "mumps.repl" to "bak" subdir).
		if ($?gtm_repl_instance) then
			set replinst_save = $gtm_repl_instance
		else
			set replinst_save = ""
		endif
		unsetenv gtm_repl_instance

		set logfile = dbcheck_base_mupip_reorg_upgrade_$$.out
		yes | $MUPIP reorg -upgrade -reg "*" >& $logfile

		# ----------------------------------------------------------------------
		# The following code is commented out because it is possible that "mupip reorg" does not visit
		# each block and so it is possible for the below assertions to not be TRUE in some cases.
		# ----------------------------------------------------------------------
		## set logfile = dbcheck_base_mupip_reorg_$$.out
		## $MUPIP reorg -reg "*" >& $logfile
		## # In case database is empty, reorg would issue a "NOSELECT" warning. So filter that out
		## # else the test framework will treat that as a test failure.
		## $gtm_tst/com/check_error_exist.csh $logfile "W-NOSELECT" >& $logfile.outx
		##
		## set logfile = dbcheck_base_dse_all_dump_all_$$.out
		## $DSE all -dump -all >& $logfile
		## set var1 = `$grep "Database is Fully Upgraded" $logfile | $grep -v "Database is Fully Upgraded                :  TRUE"`
		## if ("" != "$var1") then
		## 	echo "TEST-E-FULLYUPGRADED : dbcheck_base.csh found Fully Upgraded not TRUE for at least one region in $logfile"
		## endif
		## set var2 = `$grep "Blocks to Upgrade" $logfile | $grep -v "Blocks to Upgrade       0x0000000000000000"`
		## if ("" != "$var2") then
		## 	echo "TEST-E-BLOCKS2UPGRADE : dbcheck_base.csh found Blocks to Upgrade not 0 for at least one region in $logfile"
		## endif
		# ----------------------------------------------------------------------

		set logfile = dbcheck_base_mupip_integ_$$.out
		$MUPIP integ $online_noonline -reg "*" >& $logfile
		if ($status) then
			# In some cases, the caller subtest expects "mupip integ" to issue an error.
			# For example, the v53004/updkillsuboflow subtest expects a DBGTDBMAX error in dbcheck.csh on
			# the secondary side. In that case, it would have set the "dbcheck_expect_error" env var to
			# contain the expected error name. So filter that error out from the integ output and assume
			# the integ is a success otherwise. If there are any other errors in the integ output, they
			# would be caught by the test framework since the integ output is in a *.out named file so it
			# is ok to skip issuing a TEST-E-MUPIPINTEG error in that case.
			if (! $?dbcheck_expect_error) then
				echo "TEST-E-MUPIPINTEG : dbcheck_base.csh found MUPIP INTEG failure. See $logfile."
			else
				$gtm_tst/com/check_error_exist.csh $logfile $dbcheck_expect_error >& $logfile.outx
			endif
		endif

		# Restore gtmgbldir. No need to restore ydb_gbldir as it will be done when this script returns back to caller.
		setenv gtmgbldir $oldgbldir
		setenv gtmroutines "$oldroutines"
		cd ..

		# Restore "gtm_repl_instance" in case it was unset above.
		if ("$replinst_save" != "") then
			setenv gtm_repl_instance $replinst_save
		endif

		if ("" != "$oldconfig") then
			setenv gtmcrypt_config $oldconfig
		endif
	endif

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
	# In Debian 10, we noticed that the "date" command prints output in a different format in M vs UTF8 mode
	# (LC_TIME or LC_ALL env var).
	#	LC_TIME=C          : Thu Apr 25 15:42:11 EDT 2019
	#	LC_TIME=en_US.utf8 : Thu 25 Apr 2019 03:43:14 PM EDT
	# This causes some test failures in tests which have the date output format embedded in them.
	# So keep the output format consistent by switching LC_ALL/LC_TIME to C before doing the "date".
	# We set LC_ALL (instead of LC_TIME) since that overrides LC_TIME anyways.
	(setenv LC_ALL C; date)
	\cat tmp.mupip
	set stat=1
else
	set error_free = `$tst_awk '/No errors detected by integ./ {count=count+1} END {print count}' tmp.mupip`
	set no_regions = `$gtm_tst/com/get_reg_list.csh count`
	if ("$arg1" != "") set no_regions=1
	if ("$error_free" < "$no_regions") then
		# The GLD says "$no_regions" regions exist. But MUPIP INTEG only found fewer regions ("$error_free" of them).
		# It is possible the remaining regions are AUTODB (e.g. YDBAIM created by ydb_env_set).
		# In that case, we do not want to fall through and issue a "regions does not match error in the "else" below.
		# Therefore, we check how many "*.dat" files actually exist in the current directory and set that to be
		# the total number of regions so that can then be compared against the MUPIP INTEG region count output.
		@ no_regions = `ls -1 *.dat | wc -l`
	endif
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
