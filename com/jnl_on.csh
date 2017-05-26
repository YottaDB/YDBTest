#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#################################################
#Send the directory for the journal files as $1
#So that this script can be used for both primary and secondary
#$1 is  the directory name for the journal files
# if $2 is -replic=on , it will turn replication on, too so that the journal files will not be switched when replication is turned on.

set exitstat = 0

$gtm_tst/com/is_v4gde_format.csh
if ($status == 1) then
	# it is pre-V5 gde format. use the corresponding script that understand this old gde format.
	$gtm_tst/com/v4gde_jnl_on.csh "$1" "$2"
	exit
endif

# Support for replication to run with NOBEFORE_IMAGE started only at V52001. Therefore if the test is run for an
# older version, set BEFORE_IMAGE unconditionally (even if test was started with -jnl nobefore). It is ok to overwrite
# the environment variable "tst_jnl_str" unconditionally to correspond to BEFORE-IMAGE as we expect the caller to
# NOT do a source of this script (thereby ensuring this script does not pollute the environment variable space of caller).
set gtmverno = $gtm_exe:h:t
set majorver = `echo $gtmverno | cut -c2-3`
set minorver = `echo $gtmverno | cut -c4-7`
if ((52 > $majorver) || (52 == $majorver) && ($minorver =~ 000*)) then
	echo "Version is older than V52001. Setting environment variable tst_jnl_str unconditionally to BEFORE-IMAGE" >>&! jnl.log
	source $gtm_tst/com/gtm_test_setbeforeimage.csh
endif

# do not create journal files at /*.mjl if $1 is null, use . then
set jnldir = "$1"
if ("$jnldir" == "") set jnldir = "."

if (("$2" != "-replic=on")&&("$2" != "")) then
 echo "Arguments not understood $2"
 exit
endif

# If the current version is less than V55000, use $gtm_tst/com/pre_V54002_safe_gde.csh
if (`expr $gtm_verno "<" "V54002"`) then
	setenv GDE_SAFE "$gtm_tst/com/pre_V54002_safe_gde.csh"
else
	setenv GDE_SAFE "$GDE"
endif
echo GDE is $GDE_SAFE >>&! jnl.log

if (-e jnl_on_specific_dblist.txt) then
	# jnl_on_specific_dblist.txt file should just have the list of database files that should have replication enabled.
	# to see the format of the file, check $gtm_tst/v53002/inref/jnl_on_specific_dblist.txt
	# Future enhancement - Also, allow jnl_on_specific.csh that will have list of mupip commands. Source that file and exit this script
	set db_list = `cat jnl_on_specific_dblist.txt`
	set jnl_on_file = 1
else
	$GDE_SAFE show -map >&! gde.out
	set db_list = `$tst_awk '/FILE/ {print $NF}' gde.out | $grep -v ":" | $tst_awk -F. '{print $1}' | $tst_awk -F/ '{print $NF}' | sort -u`
endif
echo "####################################################################" >>&! jnl.log
date >>&! jnl.log
echo "--------------------" >>&! jnl.log
echo "JOURNAL OPTIONS: $tst_jnl_str" >>&! jnl.log
# ':' is a sign of GT.CM region (oscar:/testarea4/...)
# If the db directory and jnldir is different -reg "*" won't work
if !(("." == "$jnldir") || ("$PWD" == "$jnldir")) then
	set jnl_on_file = 1
endif
# If jnl_on_file is explicitly set or if the test is GT.CM, turn on journaling using file= instead of -reg "*"
if ( ($?test_jnl_on_file) || ("GT.CM" == "$test_gtm_gtcm") ) then
	set jnl_on_file = 1
endif

if ($?jnl_on_file) then
	foreach x ($db_list)
		echo File $x.dat "---> "journal file $jnldir/${x}.mjl >>&! jnl.log
		echo $MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}.mjl $2 >>&! jnl.log
		$MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}.mjl $2 >>&! jnl.log
		set jnlstat = $status
		if ($jnlstat) then
			echo "JNL_ON-E-MUPIP, mupip set -file returned status $jnlstat, please check jnl.log"
			echo "JNL_ON-E-MUPIP, The previous mupip set -file returned status $jnlstat" >> jnl.log
			set exitstat = 1
		endif
	end
else
	echo "$MUPIP set ${tst_jnl_str} $2 -reg '*'"	>>&! jnl.log
	$MUPIP set ${tst_jnl_str} $2 -reg "*" 		>>&! jnl.log
	set jnlstat = $status
	if ($jnlstat) then
		echo "JNL_ON-E-MUPIP, mupip set ${tst_jnl_str} $2 -reg * returned status $jnlstat. Please check jnl.log"
		echo "JNL_ON-E-MUPIP, the previous mupip set command returned status $jnlstat" >> jnl.log
		set exitstat = 1
	endif
endif
exit $exitstat
