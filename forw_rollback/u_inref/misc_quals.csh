#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of various things for MUPIP JOURNAL -ROLLBACK -FORWARD
#

set rollback = "-rollback" # use this to avoid explicit "MUPIP journal -rollback" usage (work_check.csh alerts against that) # BYPASSOK("-rollback")

echo "Generate few updates in a replicated environment"
$gtm_tst/com/dbcreate.csh mumps
# Take backup of db for forward rollback
$MUPIP freeze -on '*' >& freeze_on.out
$gtm_tst/com/backup_dbjnl.csh bak_forw '*.dat' cp nozip
$MUPIP freeze -off '*' >& freeze_off.out
$GTM << GTM_EOF
	for i=1:1:3 set ^nontp(i)="NONTP"_i  hang 1
GTM_EOF
$gtm_tst/com/jnl_on.csh
$GTM << GTM_EOF
	hang 1
	for i=1:1:3 tstart ():serial set ^tp(i)="TP"_i tcommit  hang 1
GTM_EOF
# Take backup of db (for backward rollback) and mjl (for backward and forward rollback and recover)
$gtm_tst/com/backup_dbjnl.csh bak_back '*.gld *.dat *.mjl*' cp nozip
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/backup_dbjnl.csh bak_final '*.gld *.dat *.mjl*' cp nozip

set linestr = "----------------------------------------------------------"

echo "#############################################################################################################"
echo "# Test that MUPIP JOURNAL -ROLLBACK -FORWARD does not support the -NOCHECKTN qualifier"
echo "#	(even though MUPIP JOURNAL -RECOVER -FORWARD does) and that -CHECKTN is the default"
echo "# Test that MUPIP JOURNAL -ROLLBACK -FORWARD supports the -CHAIN qualifier just like MUPIP JOURNAL -RECOVER -FORWARD does"
echo "#	and that -CHAIN is the default"
echo "#############################################################################################################"
cp bak_back/*.mjl* .
cp bak_forw/*.dat .

echo ""
echo "Trying -NOCHECKTN. Expect a MUPCLIERR error"
echo $linestr
$MUPIP journal $rollback -forward -nochecktn "*"

echo ""
echo "Trying -CHECKTN with one missing .mjl file and prevlink. Expect JNLFILEOPNERR error"
echo $linestr
mkdir mjlbak
mv *.mjl_* mjlbak
echo "# With -CHAIN or no chain specification, we expect the same output. Test that by randomly adding one of the two."
if !($?gtm_test_replay) then
	set rand = `$gtm_exe/mumps -run rand 2`
	echo "# Randomly chosen CHAIN option : $rand"	>>&! settings.csh
	echo "setenv misc_quals_chain $rand"		>>&! settings.csh
else
	set rand = $misc_quals_chain
endif
if ($rand) then
	set chainstr = "-chain"
else
	set chainstr = ""
endif
echo $chainstr >& rand.chainstr
$MUPIP journal $rollback -forward -checktn $chainstr "*"

echo ""
echo "Trying -CHECKTN with one missing .mjl file and prevlink but with -NOCHAIN. Expect JNLDBTNNOMATCH but no NOPREVLINK error"
echo $linestr
$MUPIP journal $rollback -forward -checktn -nochain "*"

echo ""
echo "Trying -CHECKTN with one missing .mjl file and noprevlink and *. Expect JNLDBTNNOMATCH and NOPREVLINK error"
echo $linestr
$MUPIP set -jnlfile mumps.mjl -noprev -bypas	# use -bypas to avoid standalone access as that would give MUUSERLBK error
$MUPIP journal $rollback -forward -checktn "*"

echo ""
echo "Trying -CHECKTN with one missing .mjl file and noprevlink with explicit mjl file. Expect JNLDBTNNOMATCH and NOPREVLINK error"
echo $linestr
$MUPIP journal $rollback -forward -checktn mumps.mjl

echo ""
echo "Trying -CHECKTN with no missing .mjl file. Expect NO error"
echo $linestr
rm *.mjl*
cp bak_back/*.mjl* .
echo "# With CHECKTN or no checktn specification, we expect the same output. Test that by randomly adding one of the two."
if !($?gtm_test_replay) then
	set rand = `$gtm_exe/mumps -run rand 2`
	echo "# Randomly chosen CHECKTN option : $rand"	>>&! settings.csh
	echo "setenv misc_quals_checktn $rand"		>>&! settings.csh
else
	set rand = $misc_quals_checktn
endif
if ($rand) then
	set checktnstr = "-checktn"
else
	set checktnstr = ""
endif
echo $checktnstr >& rand.checktnstr
echo "# With * or explicit mjl filename specification, we expect the same output. Test that by randomly adding one of the two."
if !($?gtm_test_replay) then
	set rand = `$gtm_exe/mumps -run rand 2`
	echo "# Randomly chosen FILENAME option : $rand">>&! settings.csh
	echo "setenv misc_quals_filename $rand"		>>&! settings.csh
else
	set rand = $misc_quals_filename
endif
if ($rand) then
	set mjlstr = "*"
else
	set mjlstr = "mumps.mjl"
endif
echo $mjlstr >& rand.mjlstr
$MUPIP journal $rollback -forward $checktnstr "$mjlstr"

echo "#############################################################################################################"
echo "# Test that MUPIP JOURNAL -ROLLBACK (with -BACKWARD or -FORWARD) does not allow -FENCES=NONE or -FENCES=ALWAYS"
echo "# Test that MUPIP JOURNAL -ROLLBACK (with -BACKWARD or -FORWARD) allows -FENCES=PROCESS and is the default"
echo "#############################################################################################################"
foreach direction ("FORWARD" "BACKWARD")
	rm -f *.dat *.mjl*
	if ("$direction" == "BACKWARD") then
		cp bak_back/* .
	else
		cp bak_back/*.mjl* .
		cp bak_forw/*.dat .
	endif
	echo ""
	echo "Trying FENCES=NONE with $direction ROLLBACK. Expect MUPCLIERR error"
	echo $linestr

	$MUPIP journal $rollback -$direction -fences=none "*"

	echo ""
	echo "Trying FENCES=ALWAYS with $direction ROLLBACK. Expect MUPCLIERR error"
	echo $linestr
	$MUPIP journal $rollback -$direction -fences=always "*"

	echo ""
	if ($gtm_test_jnl_nobefore && ("BACKWARD" == $direction)) then
		set expect = "RLBKNOBIMG"
	else
		set expect = "NO"
	endif
	echo "Trying FENCES=PROCESS with $direction ROLLBACK. Expect $expect error"
	echo $linestr
	echo "# -FENCES=PROCESS or no -fences specification should produce the same output. Test that by randomly adding one of the two."
	if !($?gtm_test_replay) then
		set rand = `$gtm_exe/mumps -run rand 2`
		echo "# Randomly chosen $direction FENCES option : $rand"	>>&! settings.csh
		echo "setenv misc_quals_${direction}_fences $rand"		>>&! settings.csh
	else
		set rand = `eval echo '${'misc_quals_${direction}'_fences}'`
	endif
	if ($rand) then
		set fencestr = "-fences=process"
	else
		set fencestr = ""
	endif
	echo $fencestr >& rand.fencestr.$direction
	$MUPIP journal $rollback -$direction $fencestr "*"
end

echo "# Do some journal extracts and time calculations in preparation for the next few tests"
echo "# For purposes of the journal extract, move away the db to avoid REQRUNDOWN errors"
echo "# But this means possible DBCOLLREQ warnings from journal extract so redirect to .outx file to avoid those from showing up"
rm -f *.dat *.mjl*
cp bak_back/*.mjl* .
setenv gtm_extract_nocol 1	# to enable jext to work on journal files where db is absent (else SETEXTRENV error is issued)
$gtm_tst/com/jnlextall.csh mumps >& jnlextall.outx  # extract from mumps.mjl* files
unsetenv gtm_extract_nocol
echo "# Create setvar.csh that contains variables needed (and can be sourced) by test"
$grep -E "EPOCH|SET|PFIN" mumps.mjf{_*,} | sed 's/.*://g;s/ *//g' | $gtm_exe/mumps -run jnlextparse	# creates setvar.csh
mkdir orig_mjf
mv *.mjf* orig_mjf
# Variables set by setvar.csh are
#	$before1 : -BEFORE time in previous generation jnl file (mumps.mjl_*)
#	$before2 : -BEFORE time in current  generation jnl file (mumps.mjl)
#	$since1  : -SINCE  time in previous generation jnl file (mumps.mjl_*)
#	$since2  : -SINCE  time in current  generation jnl file (mumps.mjl)
#	$resync1 : -RESYNC seqno corresponding to a jnlrecord in previous generation jnl file (mumps.mjl_*)
#	$resync2 : -RESYNC seqno corresponding to a jnlrecord in current  generation jnl file (mumps.mjl)
#
# Previous generation mjl file
# ------------------------------
# EPOCH\63840,48616\65536\1315246500\17547\0\1\0\98\101\1		<-- since1
# SET\63840,48621\65536\1357066667\17670\0\1\0\0\0\0\^nontp(1)="1"	<-- before1
# SET\63840,48622\65537\1921142181\17670\0\2\0\0\0\0\^nontp(2)="2"
# SET\63840,48623\65538\1126562180\17670\0\3\0\0\0\0\^nontp(3)="3"	<-- resync1
# EPOCH\63840,48624\65539\3683185203\17670\0\4\0\96\101\1
# EPOCH\63840,48624\65539\3090979264\17696\0\4\0\96\101\1
#
# Current generation mjl file
# -----------------------------
# EPOCH\63840,48624\65539\2806990291\17696\0\4\0\96\101\1
# TSET\63840,48624\65539\3152882788\17697\0\4\0\0\1\0\^tp(1)="1"	<-- since2
# TSET\63840,48625\65540\1223565813\17697\0\5\0\0\1\0\^tp(2)="2"	<-- resync2
# TSET\63840,48626\65541\885625867\17697\0\6\0\0\1\0\^tp(3)="3"		<-- before2
# EPOCH\63840,48627\65542\2256871614\17697\0\7\0\94\101\1
#
source setvar.csh

# Do BACKWARD ROLLBACK tests only if BEFORE image journaling is turned on
if (! $gtm_test_jnl_nobefore) then
	echo "#############################################################################################################"
	echo "# Test that MUPIP JOURNAL -RECOVER -BACKWARD -BEFORE works even if -SINCE is not specified."
	echo "#	Previously it used to error out with a JNLTMQUAL1 error."
	echo "#"
	echo "# Specify -BEFORE time in the middle of previous generation mjl file (mumps.mjl_*)"
	echo "# Expect RLBKJNSEQ of 2"
	rm -f *.dat *.mjl*
	cp bak_back/* .
	$MUPIP journal $rollback -backward -before=\"$before1\" "*"

	echo "# Specify -BEFORE time in the middle of current  generation mjl file (mumps.mjl)"
	echo "# Expect RLBKJNSEQ of 7"
	rm -f *.dat *.mjl*
	cp bak_back/* .
	$MUPIP journal $rollback -backward -before=\"$before2\" "*"

	echo "#############################################################################################################"
	echo "# Test MUPIP JOURNAL -ROLLBACK -BACKWARD -SINCE"
	echo "#"
	echo "# Specify -SINCE time in the middle of previous generation mjl file (mumps.mjl_*)"
	echo "# Expect RLBKJNSEQ of 7"
	rm -f *.dat *.mjl*
	cp bak_back/* .
	$MUPIP journal $rollback -backward -since=\"$since1\" "*"

	echo "# Specify -SINCE time in the middle of current  generation mjl file (mumps.mjl)"
	echo "# Expect RLBKJNSEQ of 7"
	rm -f *.dat *.mjl*
	cp bak_back/* .
	$MUPIP journal $rollback -backward -since=\"$since2\" "*"

	echo "#############################################################################################################"
	echo "# Test that MUPIP JOURNAL -ROLLBACK -BACKWARD -BEFORE -SINCE works"
	echo "# Specify -SINCE and -BEFORE time in previous generation mjl file"
	echo "# Verify (by MUJNLPREVGEN message) that rollback did go to previous generation mjl file in its backward processing"
	echo "# Expect RLBKJNSEQ of 2"
	rm -f *.dat *.mjl*
	cp bak_back/* .
	$MUPIP journal $rollback -backward -since=\"$since1\" -before=\"$before1\" "*"
endif

if (! $gtm_test_jnl_nobefore) then
	set directionlist = "BACKWARD FORWARD"
else
	set directionlist = "FORWARD"
endif

foreach direction ($directionlist)
	echo "#############################################################################################################"
	echo "# Test MUPIP JOURNAL -ROLLBACK $direction -BEFORE -RESYNC"
	echo "#"
	echo "# -BEFORE time occurs before the RESYNC seqno specification. BEFORE should prevail."
	echo "# Expect RLBKJNSEQ of 2"
	rm -f *.dat *.mjl*
	if ("$direction" == "FORWARD") then
		cp bak_back/*.mjl* .
		cp bak_forw/*.dat .
	else
		cp bak_back/* .
	endif
	$MUPIP journal $rollback -$direction -resync=\"$resync1\" -before=\"$before1\" "*"
	echo "#"
	echo "# -BEFORE time occurs after the RESYNC seqno specification. RESYNC should prevail."
	echo "# Expect RLBKJNSEQ of 5"
	rm -f *.dat *.mjl*
	if ("$direction" == "FORWARD") then
		cp bak_back/*.mjl* .
		cp bak_forw/*.dat .
	else
		cp bak_back/* .
	endif
	$MUPIP journal $rollback -$direction -resync=\"$resync2\" -before=\"$before2\" "*"
end

echo "#############################################################################################################"
echo "# Test MUPIP JOURNAL -ROLLBACK -FORWARD -BEFORE"
echo "#"
echo "# Specify -BEFORE time in the middle of previous generation mjl file (mumps.mjl_*)"
echo "# Expect RLBKJNSEQ of 2"
rm -f *.dat *.mjl*
cp bak_back/*.mjl* .
cp bak_forw/*.dat .
$MUPIP journal $rollback -forward -before=\"$before1\" "*"

echo "# Specify -BEFORE time in the middle of current  generation mjl file (mumps.mjl)"
echo "# Expect RLBKJNSEQ of 7"
rm -f *.dat *.mjl*
cp bak_back/*.mjl* .
cp bak_forw/*.dat .
$MUPIP journal $rollback -forward -before=\"$before2\" "*"

