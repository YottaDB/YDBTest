#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# create multiple database "database, areg, breg, creg ..."
# if called with single region, creates a single region database
#
# if acc_meth has a value of "MM" then the database is given an access_method of mm
#
#####
#
# We are potentially (if doing V6 databases) about to reset the version we use to create the
# databases (reverting to our test version at the end). The issue is that when the DBs are created
# with various versions, this presents problems with the reference file and masking those random versions
# so we are going to save the values of what would be $GDE and $MUPIP here - before the version is changed
# and then use these versions as objects of the 'Using: ' lines echoed to the output. This makes the version
# predictable (but wrong). But if we do change the version, the version we're using will be recorded in
# the v6debug file if it becomes needful to know.
#
set CURR_GDE = "$gtm_dist/mumps -run GDE"
set CURR_MUPIP = "$gtm_dist/mupip"
#
# See if we've requested a V6 format database.
#
set v6switch_done = 0
echo >> v6debug.txt # Spacing between potentially multiple calls to dbcreate.csh.
echo "gtm_dist: $gtm_dist" >> v6debug.txt
echo "tst_ver:  $tst_ver" >> v6debug.txt
if ($?gtm_test_use_V6_DBs) then
	echo "gtm_test_use_V6_DBs: $gtm_test_use_V6_DBs" >> v6debug.txt
	if (1 == $gtm_test_use_V6_DBs) then
		# We are requesting a V6 format database - must switch to a previously determined (in do_random_settings.csh)
		# V6 version.
		if ($?gtm_chset) then
			echo "gtm_chset (before): $gtm_chset" >> v6debug.txt
		else
			echo "gtm_chset (before): <undefined>" >> v6debug.txt
		endif
		source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image >> v6debug.txt
		if ("V63003A_R120" == "$gtm_test_v6_dbcreate_rand_ver") then
			# This version requires a msgprefix of GTM for GDE to work at all
			echo "dbcreate_base (top): gtm_test_v6_dbcreate_rand_ver: $gtm_test_v6_dbcreate_rand_ver" >> v6debug.txt
			setenv ydb_msgprefix "GTM"
		endif
		if ($?gtm_chset) then
			echo "gtm_chset (after): $gtm_chset" >> v6debug.txt
		else
			echo "gtm_chset (after): <undefined>" >> v6debug.txt
		endif
		echo `$gtm_dist/mumps -run ^%XCMD 'zwrite $zchset'` >>& v6debug.txt
		set v6switch_done = 1
	endif
endif
echo "gtm_dist: $gtm_dist" >> v6debug.txt

#check the existence of the necessary environment variables and initialize them to a standard value if they do not exist
#first determine where the source is (instead of using gtm_tst
#if gtm_tst is defined, i.e. inside test_suite, use gtm_tst
if ($?gtm_tst) then
	setenv source_dir $gtm_tst/com
else
	setenv source_dir $gtm_test/T990/com
	setenv gtm_tst $gtm_test/T990
endif


if (!($?gtm_exe) && !($?gtm_dist)) then
	echo 'Please define $gtm_exe (or $gtm_dist)'
	if ($v6switch_done) source $gtm_tst/com/dbcreate_reset_version.csh # Restore original version, reset ydb_msgprefix
	exit 1
endif

if (!($?gtm_exe)) setenv gtm_exe $gtm_dist
# $gtm_exe's existence is sure at this point
if (!($?GDE)) setenv GDE "$gtm_exe/mumps -run GDE"
if (!($?MUPIP)) setenv MUPIP "$gtm_exe/mupip"
if (!($?GDE_SAFE)) setenv GDE_SAFE "$gtm_tst/com/pre_V54002_safe_gde.csh"

if ( $#argv == 0 ) then
	echo ""
	echo "USAGE of <dbcreate.csh/dbcreate_base.csh>:"
	echo "dbcreate.csh/dbcreate_base.csh <database> <n-regions> <key-size> <rec size> <blk size> <alloc>"
	echo "<global buffers> <extension> <reservedbytes> <collation> <null_subscripts> <acc_meth> <stdnull> <-t=template_file>"
	echo "<qdbrundown> <freeze>"
	echo ""
	echo "<-option=value> can be anywhere in the arguments, others still taken by position"
	echo If running outside the test suite, \$gtm_exe has to be defined,
	echo acc_meth is by default BG
	echo -n
	echo "null_subscripts argument needs to have a value, so:"
	echo "dbcreate.csh . . . . . . . . . . EXISTING"
	echo "dbcreate.csh . -n=ALWAYS"
	echo "are two different ways to specify null subscripts"
	echo -n
	echo Please do not use acc_meth option when using from inside testsuite,
	echo it is defined properly for each test run.
	echo ""
	echo "Use dbcreate_base.csh only if you want to do something other than defaults for"
	echo "the options, like creating a non-replicated database although the "
	echo "option is REPLIC."
	echo "Otherwise use dbcreate.csh to create databases, BG/MM, arbitrary number of regions, "
	echo "online reorg'ed/not reoorg'ed, or replicated/non-replicated databases"
	echo "You can use -key=... -rec=... arguments (other arguments still taken as postional"
	echo "If you want a database with different settings for different regions, you can create a gde command list file and point it to test_specific_gde"
	echo "There is also the -t=filename option to specify settings for all regions (as template commands). This script"
	echo "will then use these commands (template commands) for all regions, and explicitly run them for the DEFAULT region."
	echo "This is useful for:"
	echo " 1. working around the limitation of dbcreate wrt the ordering of changing block_size/record_size/key_size (in case one does not fit in the next item,"
	echo " in increasing or decreasing order (in which case the ordering might need to be changed from what dbcreate uses))"
	echo " 2. having to use user-specified gde commands with GT.CM tests for some reason (such as the above)"
	echo "Don't forget to also call dbcheck.csh/dbcheck_filter.csh at the end of the test."
	if ($v6switch_done) source source $gtm_tst/com/dbcreate_reset_version.csh # Restore original version, reset ydb_msgprefix
	exit 1
endif

set timenow = `date +%H_%M_%S`
set renamecount = 0
set rename = "$timenow"
while ( (-e tmp.com_$rename) || (-e dbcreate.out_$rename) || (-e dbcreate.gde_$rename) )
	@ renamecount++
	set rename = "${timenow}_$renamecount"
end
if (-e tmp.com) mv tmp.com tmp.com_$rename
if (-e tmp_gdeshowcmd.com) mv tmp_gdeshowcmd.com tmp_gdeshowcmd.com_$rename
if (-e dbcreate.out) \mv dbcreate.out dbcreate.out_$rename
if (-e dbcreate_gdeshowcmd.out) \mv dbcreate_gdeshowcmd.out dbcreate_gdeshowcmd.out_$rename
if (-e dbcreate.gde) \mv dbcreate.gde dbcreate.gde_$rename
# -GTCM_LOCAL/-GTCM_REMOTE can only be the first argument
switch ($1)
	case "-GTCM_LOCAL":
		set argumentstring = `echo $argv | $tst_awk '{for(i=3;i<=NF;i++) printf $i " "}'`
		set argumentstring = "$argumentstring -test_gtcm=$2"
		breaksw
	case "-GTCM_REMOTE":
		# This method will not work with aliases or single server (both GT.CM servers on the same host)
		# if it is necessary to fix it: change the GTCM_REMOTE's qualifier to send in only the
		# necessary bit for this host, and change dbcreate_multi.awk to use that directly #BYPASSOK
		# in that case, he has to be given the total number of GT.CM servers as well.
		set argumentstring = `echo $argv | $tst_awk '{for(i=3;i<=NF;i++) printf $i " "}'`
		set argumentstring = "$argumentstring -test_gtcm=${HOST:r:r:r};$2"
		breaksw
	default:
		set argumentstring = "$argv"
endsw
if ($?acc_meth) then
	set argumentstring = "$argumentstring -acc_meth_env=$acc_meth"
	if ("MM" == $acc_meth) then
		set argumentstring = "$argumentstring -journal=nobefore_image"
	endif
endif
if ($?test_collation_no) then
	if ($test_collation_no > 0) then
		set argumentstring = "$argumentstring -test_collation=$test_collation_no"
	endif
endif
set argn=""
if ($?gtmgbldir) then
	set argn = "-name_override="$gtmgbldir
endif
echo $argumentstring $argn |$tst_awk  -f $source_dir/dbcreate_multi.awk > tmp.com
$grep "! different_gld-specified-in-input" tmp.com >& /dev/null
@ grepstatus = $status
# if the grep returns 0, it means -different_gld was specified and this is a secondary instance.
# Append instname to gtm_test_sprgde_id in that case.
if (0 == $grepstatus) then
	if (! $?gtm_test_sprgde_id) then
		set sprgdeid = ""
	else
		set sprgdeid = "${gtm_test_sprgde_id}_"
	endif
	if (! $?gtm_test_cur_sec_name) then
		# this is a secondary in a non-MSR test. Use sec_name
		setenv gtm_test_sprgde_id "${sprgdeid}${gtm_test_cur_sec_name}"
	else
		# this is a secondary in an MSR test. Use pri_name
		setenv gtm_test_sprgde_id "${sprgdeid}${gtm_test_cur_pri_name}"
	endif
	# Record this modified sprgde_id in env_supplementary.csh for future.
	echo "setenv gtm_test_sec_sprgde_id_different 1" >>! env_supplementary.csh
	echo "setenv gtm_test_sprgde_id ${gtm_test_sprgde_id}" >> env_supplementary.csh
	# TODO: Make this scheme work for non-MSR tests since they dont source env_supplementary.csh on secondary side
endif
# if specific gde file is specified, use it
if ($?test_specific_gde) then
	if ("GT.CM" == $test_gtm_gtcm) then
		echo "TEST-E-GTCMvsGDE \$test_specific_gde option is not supported for GT.CM testing"
		if ($v6switch_done) source source $gtm_tst/com/dbcreate_reset_version.csh # Restore original version, reset ydb_msgprefix
		exit 1
	endif
	# none of the test using $test_specific_gde use a random version
	# xtg -l test_specific_gde | grep -v 'test.com' | xargs grep random_ver
	if (-f $test_specific_gde) then
		@ headnum = `$tst_awk '/GDE_EOF/{print NR;exit}' tmp.com`  #' for VIM syntax highlighting
		$head -n $headnum tmp.com				>&! tmp.tmp.tmp
		if ($gtm_test_qdbrundown) then
			echo "template -region -qdbrundown"		>> tmp.tmp.tmp
			echo "change -region DEFAULT -qdbrundown"	>> tmp.tmp.tmp
		endif
		cat $test_specific_gde					>> tmp.tmp.tmp
		echo "\_GDE_EOF"					>> tmp.tmp.tmp
		echo '$gtm_tst/com/usesprgde.csh >> dbcreate.gde'	>> tmp.tmp.tmp
		echo '$convert_to_gtm_chset dbcreate.gde'		>> tmp.tmp.tmp
		echo '$GDE @dbcreate.gde >>&! dbcreate.out'		>> tmp.tmp.tmp
		\mv -f tmp.tmp.tmp tmp.com
	else
		echo "TEST-E-TEST_SPECIFIC_GDE File $test_specific_gde not found"
		if ($v6switch_done) source $gtm_tst/com/dbcreate_reset_version.csh # Restore original version, reset ydb_msgprefix
		exit 1
	endif
endif

#source the output of AWK
unsetenv ydb_app_ensures_isolation # in case it is set on test replay (else ZGBLDIRACC errors on non-existent gld file are possible)
source tmp.com >>&! dbcreate.out
if ($status) echo "TEST-E-DBCREATE ERROR from tmp.com Check dbcreate.out for details"

# various issues with gde -show -commands were sorted out in V6.1-000. Test only for versions starting V61000
if ( `expr "V61000" "<=" $gtm_verno` ) then
	# Testing for the gde command qualifier: starts
	cat << CAT_EOF >>! tmp_gdeshowcmd.com

	# The below tests if using output of gde -show -command creates an identical gde file
	\$GDE <<_GDEEOF_
	show -command -file="gde.new.cmd"
	quit
_GDEEOF_

	\$GDE <<_GDEEOF_
	log -on="oldgde.log"
	show -all
	log -off
	quit
_GDEEOF_

	mv \$gtmgbldir \$gtmgbldir.old
	\$GDE @gde.new.cmd

	\$GDE <<_GDEEOF_
	log -on="newgde.log"
	show -all
	log -off
	quit
_GDEEOF_

	\$gtm_tst/com/gdeshowdiff.csh oldgde.log newgde.log
	if ( \$status ) then
	    echo "show -command failed to create identical global directory. Exiting ..."
	    if ($v6switch_done) source $gtm_tst/com/dbcreate_reset_version.csh # Restore original version, reset ydb_msgprefix
	    exit 1
	else
	    echo "show -command successful"
	endif

CAT_EOF
	# Testing for the gde command qualifier: ends
	#source the output of AWK
	source tmp_gdeshowcmd.com >>&! dbcreate_gdeshowcmd.out
	if ($status) then
		echo "TEST-E-DBCREATE. using output of gde show -commands failed to produce identical gld. Check dbcreate_gdeshowcmd.out for details"
		if ($v6switch_done) source $gtm_tst/com/dbcreate_reset_version.csh # Restore original version, reset ydb_msgprefix
		exit 1
	endif
endif

if ($gtm_test_tls == "TRUE") then
	cp $gtm_tst/com/tls/gtmtls.cfg .
	sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! gtmcrypt.cfg
endif

# -GTCM can only be the first argument, since it is not to be used by the user, this constraint is still ok (i.e. for the user, the argument ordering is still free)
if (-e create_key_file.out) \mv create_key_file.out create_key_file.out_$rename
if ("-GTCM_LOCAL" == "$1") then
	# only AREG is local in GT.CM testing
	$grep "areg" tmp.com >&! /dev/null 	#check if there is a region AREG
	if ($status) then
		echo "Files Created in `pwd`:"
		echo "Using: $CURR_GDE"
		\ls $dbname.gld
		exit
	endif
	if ("ENCRYPT" == "$test_encryption" ) then
		$gtm_tst/com/create_key_file.csh >& create_key_file.out
	endif
	$MUPIP create  -region=AREG >>&! dbcreate.out
	set stat = $status
else
	if ("ENCRYPT" == "$test_encryption" ) then
		$gtm_tst/com/create_key_file.csh >& create_key_file.out
	endif
	$MUPIP create  >>&! dbcreate.out
	set stat = $status
endif
if ($stat) then
	echo "TEST-E-DBCREATE_MUPIP ERROR from $MUPIP create"
	cat dbcreate.out
	if ($v6switch_done) source $gtm_tst/com/dbcreate_reset_version.csh # Restore original version, reset ydb_msgprefix
	exit 1
endif

# If we switched to V6 to create the DBs, we need to revert back to whatever version we are running
# with. In addition, in order to be able to use the V6 gld files, we need to open them with V7 GDE
# and exit to cause the gld to be rewritten in V7's upgraded format.
#
if ($v6switch_done) then
	echo "Switch version back" >> v6debug.txt
	source $gtm_tst/com/dbcreate_reset_version.csh # Restore original version, reset ydb_msgprefix
	#
	# Open the global dir we created and close it to upgrade it to V7 format
	#
	echo "gtm_dist:  $gtm_dist" >> v6debug.txt
	if ($?gtm_chset) then
		echo "gtm_chset: $gtm_chset" >> v6debug.txt
	else
		echo "gtm_chset: <undefined>" >> v6debug.txt
	endif
	echo `$gtm_dist/mumps -run ^%XCMD 'zwrite $zchset'` >>& v6debug.txt
	$gtm_dist/mumps -run GDE EXIT >>& upgrade_v6_gld_to_v7.log
endif

# If $?gtm_custom_errors is defined at this point, then MUPIP SET -VERSION done below will try to open $gtm_repl_instance (as part
# of jnlpool_init) to setup the journal pool. But, the file pointed to by $gtm_repl_instance doesn't exist at this point because
# MUPIP REPLIC -INSTANCE_CREATE is not yet done. So, temporarily undefine $gtm_custom_errors to avoid FTOKERR/ENO2 errors.
if ($?gtm_custom_errors) then
	setenv restore_gtm_custom_errors $gtm_custom_errors
	unsetenv gtm_custom_errors
endif
source $gtm_tst/com/mupip_set_version.csh	# randomly decide on V4 or V5 database format
source $gtm_tst/com/mupip_set_encryptable.csh	# randomly do mupip set -encryptable
source $gtm_tst/com/change_current_tn.csh	# randomly decide on transaction number to start off with
if ( (! $?test_replic) && ("GT.M" == "$test_gtm_gtcm") ) then
	if ("SETJNL" == "$gtm_test_jnl") $gtm_tst/com/jnl_on.csh
endif
if ($?restore_gtm_custom_errors) then
	setenv gtm_custom_errors $restore_gtm_custom_errors
	unsetenv restore_gtm_custom_errors
endif

if (($gtm_test_trigger) && ($?test_specific_trig_file)) then
	if ("GT.CM" == $test_gtm_gtcm) then
		echo "TEST-E-GTCMvsTRIGGERS Triggers and hence \$test_specific_trig_file are not supported for GT.CM testing"
		exit 1
	endif
	$MUPIP trigger -triggerfile=$test_specific_trig_file -noprompt >>&! dbcreate.out
	@ stat = $stat + $status
endif
if ($stat) then
	echo "TEST-E-DBCREATE_MUPIP ERROR from $MUPIP create"
	cat dbcreate.out
	exit 1
endif
$grep -f $gtm_tst/com/errors_catch.txt dbcreate.out >& /dev/null
if (! $status) then
	echo "---------------------------------------------------------------"
	echo "TEST-E-DBCREATE, errors seen in the log file dbcreate.out:"
	$grep -f $gtm_tst/com/errors_catch.txt dbcreate.out
	echo "---------------------------------------------------------------"
endif

#chmod  +w $dbname.* >& /dev/null
foreach value (a b c d e f g h i)
	if (-f {$value}.dat) then
		if ($mmglobalbuffs != 0) then
			$MUPIP set -file {$value}.dat -global_buffers=$mmglobalbuffs >& /dev/null
		endif
		\chmod 666 {$value}.dat >& /dev/null
	endif
end

echo "Files Created in `pwd`:"
echo "Using: $CURR_GDE"
\ls $dbname.gld
echo "Using: $CURR_MUPIP"
if (("GT.CM" != $test_gtm_gtcm) && !($?gtm_test_silence_dbcreate)) then
	\ls -1 *.dat
else if (("GT.CM" != $test_gtm_gtcm) && ($?gtm_test_silence_dbcreate)) then
	printf "GTM_TEST_DEBUGINFO: "
	\ls *.dat
endif
#

#############################################################################
# collation testing:
# once the software is fixed (journalling and collation),
# use enable_nct.csh to enable numeric collation (when testing WITH collation)
