#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if (-X findmnt) then
	alias fslist findmnt	# Available (and more reliable) on newer Linux
else
	alias fslist mount
endif

set IGS=$gtm_com/IGS
if ($?gtm_test_useIGS) then
	# If we are working on a new IGS use that; otherwise use the existing one.
	set IGS = $gtm_test_useIGS
endif

set rwdir=${PWD}/rw_files
set rodir=${PWD}/ro_mount

mkdir -p $rwdir
mkdir -p $rodir

setenv gtm_test_silence_dbcreate 1
setenv gtm_test_mupip_set_version "disable"
setenv dbdir $rwdir
$gtm_tst/com/dbcreate.csh '$dbdir/mumps' 1 125-425 900-1050
mv $dbdir/mumps.gld* .
setenv gtmgbldir `pwd`/mumps.gld

echo
echo "Load data"
echo

setenv gtm_test_cur_pri_name $HOST
set updates=`$gtm_exe/mumps -r %XCMD 'write $random(1000)+500,\!'`
$gtm_tst/com/simpleinstanceupdate.csh $updates

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before doing mv/chmod etc. below

if ("ENCRYPT" == "$test_encryption") then
	sed 's/rw_files/ro_mount/' $gtm_dbkeys > ${gtm_dbkeys}.bak
	cat $gtm_dbkeys >> ${gtm_dbkeys}.bak
	$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.bak ${gtmcrypt_config}.ro.both
	sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! ${gtmcrypt_config}.ro
	cat ${gtmcrypt_config}.ro.both >>&! ${gtmcrypt_config}.ro
endif

# Rename initial rwdir to make sure we can't see it when running against rodir
alias switch_to_ro '@ rocnt++; mv ${rwdir} ${rwdir}x; $IGS "MOUNTDIRRO" ${rwdir}x $rodir ; setenv dbdir $rodir ; fslist >& fslist_ro_${rocnt}.out; setenv gtmcrypt_config gtmcrypt.cfg.ro'
alias switch_to_rw '@ rwcnt++; $IGS UMOUNT $rodir; mv ${rwdir}x ${rwdir}; setenv dbdir $rwdir; fslist >& fslist_rw_${rwcnt}.out; setenv gtmcrypt_config gtmcrypt.cfg'
alias pre_pass_ss '$gtm_tst/com/backup_dbjnl.csh "ss_pre_pass_$passno" $dbdir'

echo
echo "Switch to Read-Only"
echo

switch_to_ro
touch $dbdir/junkfile >& /dev/null && echo "TEST-E-rodirnotro, successfully wrote to read-only directory"

startpass:

@ passno++

ls -l $dbdir >& dbfiles_pass_${passno}.out

if ($passno == 2) then
	# Second verse, same as the first, but with journaling turned on
	echo
	echo "Enable Journaling"
	echo

	switch_to_rw
	pre_pass_ss
	$MUPIP set -file $dbdir/mumps.dat ${tst_jnl_str} >& journal_enable.out
	switch_to_ro
else if ($passno == 3) then
	echo
	echo "Enable Replication"
	echo

	switch_to_rw
	pre_pass_ss
	$MUPIP set -file $dbdir/mumps.dat -replication=on >& replic_enable_${passno}.out
	set instname=gtm7897
	setenv gtm_repl_instance ${instname}.inst
	$MUPIP replicate -instance_create -name=${instname} $gtm_test_qdbrundown_parms >>&! replic_enable_${passno}.out
	$MUPIP replicate -source -start -passive -log=SRC_${instname}_${passno}.logx -instsecondary=${instname}s -rootprimary >>&! replic_enable_${passno}.out
	$MUPIP replicate -source -shutdown -timeout=0 >&! replic_shutdown_${passno}.out
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed
	unsetenv gtm_repl_instance
	switch_to_ro
else if ($passno == 4) then
	echo
	echo "Freeze Region"
	echo

	switch_to_rw
	pre_pass_ss
	setenv gtm_repl_instance ${instname}.inst
	$MUPIP replicate -source -start -passive -log=SRC_${instname}_${passno}.logx -instsecondary=${instname}s -rootprimary >>&! replic_enable_${passno}.out
	$gtm_exe/mumps -run %XCMD 'set ^junk=123  zsystem "$MUPIP freeze -on DEFAULT"'
	$MUPIP replicate -source -shutdown -timeout=0 >&! replic_shutdown_${passno}.out
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed
	unsetenv gtm_repl_instance
	switch_to_ro
endif

echo
echo "Try integ fast"
echo

$MUPIP integ -fast -region "*" >& integ_fast_${passno}.out

echo
echo "Try integ noonline region"
echo

$MUPIP integ -region DEFAULT -noonline >& integ_noonline_region_${passno}.out

echo
echo "Try integ noonline file"
echo

$MUPIP integ -file $dbdir/mumps.dat -noonline >& integ_noonline_file_${passno}.out

echo
echo "Try integ online region"
echo

$MUPIP integ -region DEFAULT -online >& integ_online_region_${passno}.out

echo
echo "Try mumps read"
echo

set randupdate=`$gtm_exe/mumps -r %XCMD 'write $random('$updates')+1,\!'`
$gtm_exe/mumps -r %XCMD 'set upd=^GBL($ztrnlnm("gtm_test_cur_pri_name"),'"${randupdate}"')  if upd'"'=${randupdate}"'  write "TEST-E-nomatch, expected '"${randupdate}"', got  "_upd,\!'

echo
echo "Try mumps write"
echo

$gtm_exe/mumps -r %XCMD 'set ^XYZZY=1'

echo
echo "Try backup"
echo

$MUPIP backup -noonline DEFAULT back.dat

echo
echo "Try extract"
echo

$MUPIP extract -nolog extract.${passno} >& extract_${passno}.out

echo
echo "Try extract with freeze"
echo

$MUPIP extract -nolog -freeze extract_freeze.${passno}

echo
echo "Try freeze"
echo

$MUPIP freeze -on DEFAULT
$MUPIP freeze -off DEFAULT

echo
echo "Try extend"
echo

$MUPIP extend DEFAULT

echo
echo "Try integ tn_reset"
echo

$MUPIP integ -tn_reset -file $dbdir/mumps.dat >& integ_tn_reset_${passno}.out

check_error_exist.csh integ_tn_reset_${passno}.out "DBRDONLY|DBTNRESET"

echo
echo "Try reorg"
echo

$MUPIP reorg -select="^GBL"

echo
echo "Try rundown"
echo

$MUPIP rundown -region "*"

echo
echo "Try set file"
echo

$MUPIP set -file $dbdir/mumps.dat -journal=enable,on,before

echo
echo "Try set region"
echo

$MUPIP set -region "*" -journal=enable,on,before

if ($passno > 1) then
	echo
	echo "Try journal extract"
	echo

	setenv gtm_extract_nocol 1
	$MUPIP journal -extract=mumps.${passno} -forward $dbdir/mumps.mjl

	echo
	echo "Try journal recover"
	echo

	$MUPIP journal -recover -forward $dbdir/mumps.mjl

	echo
	echo "Try journal verify"
	echo

	$MUPIP journal -verify -forward $dbdir/mumps.mjl

	echo
	echo "Try journal show"
	echo

	$MUPIP journal -show=all -forward $dbdir/mumps.mjl >& journal_show_${passno}.out
endif

echo
echo "Pass #$passno Complete"
echo

if ($passno < 4) goto startpass

# Cleanup

switch_to_rw

$grep -v "UMOUNT" ../cleanup.csh >&! ../cleanup.csh.bak
mv ../cleanup.csh.bak ../cleanup.csh

if ( "$IGS" != "$gtm_com/IGS") rm -f $IGS

$MUPIP freeze -off DEFAULT
$gtm_tst/com/dbcheck.csh

echo
echo "Done."
