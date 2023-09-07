#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
echo ENTERING ONLINE4
#
#
setenv gtmgbldir online4.gld
setenv bkp_dir "`pwd`/online4"
mkdir $bkp_dir
chmod 777 $bkp_dir
if (-f $gtm_tst/$tst/inref/mrtst_$acc_meth.gde) then
	setenv test_specific_gde $gtm_tst/$tst/inref/mrtst_$acc_meth.gde
endif

setenv gtm_test_jnlfileonly 0	# The test checks at one step that the journal files are untouched when trying to update the
				# backed up database. If gtm_test_jnlfileonly is 1, the source server could open the journal
				# file any time in between as part of clearing the replication backlog and that could write
				# to the journal file header (opening the journal file in shared memory causes that even if
				# it is the source server which only reads from the journal file) which in turn can cause
				# that part of the test to fail. Therefore gtm_test_fileonly.

$gtm_tst/com/dbcreate.csh online4 4
if ("ENCRYPT" == $test_encryption) then
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed 's|dat: "'$cwd'/|dat: "|' ${gtmcrypt_config}.orig > $gtmcrypt_config
endif
if (! $?test_replic) $MUPIP set -reg "*" -journal=enable,on,nobefore |& sort -f
#
#
$GTM << EOF
do ^mrtstbld
job a^mrbackup(10,"$MUPIP backup -o -newjnlfiles ""*"" ./online4"):(out="online4b.out":err="online4b.log")
do ^mrtst(10,3000)
do ^waitback(300)
do ^mrverify
halt
EOF
cat *.mje*
$grep "%YDB-I-BACKUPSUCCESS" online4b.log
#
#

alias ls 'ls --full-time'	# Get micro/nano-second level granularity of time when comparing timestamps below (using "diff")

# do an update to the backed up database and expect an error
# make sure no new journal files were cut
$gtm_tst/com/backup_dbjnl.csh before_back_update "*.mjl*" cp
ls -al *.dat *.mjl* > before_back_update.log
\cp online4.gld ./online4
cd online4

# if encrypted then temporarily set gtmcrypt_config
if ($?gtmcrypt_config) setenv gtmcrypt_config "../gtmcrypt.cfg"

# We are currently in online4 sub-directory. If run as replic, gtm_repl_instance is defined to mumps.repl but doesn't exist in
# online4 sub-directory. Furthermore, if $gtm_custom_errors is set, the below update to the backup database will try to do
# jnlpool_init which issues FTOKERR/ENO2 erros since mumps.repl doesn't exist. So, unsetenv gtm_repl_instance. This is the
# right thing to do anyways since the backup database is NOT bound to any journal pool.
unsetenv gtm_repl_instance
$gtm_exe/mumps -run %XCMD 'set ^a=1' >&! back_update.logx
if ($?test_replic) setenv gtm_repl_instance mumps.repl
echo "Expect count of 2 for errors YDB-E-JNLOPNERR and YDB-E-FILEIDMATCH found in online4/back_update.logx:"
$grep -c -E 'YDB-E-JNLOPNERR|YDB-E-FILEIDMATCH' back_update.logx
cd ..
# if encrypted then reset gtmcrypt_config
if ($?gtmcrypt_config) setenv gtmcrypt_config "gtmcrypt.cfg"

# save the .dat and .mjl files for comparison to show no modification to db or jnl files by the attempt to modify
# the backed-up database

ls -al *.dat *.mjl* > after_back_update.log
$gtm_tst/com/backup_dbjnl.csh after_back_update "*.mjl*" cp
echo "Expect no difference between before_back_update.log and after_back_update.log"
diff before_back_update.log after_back_update.log
if (0 == $status) echo "No difference seen"

# do an update to the source database of ^a to a different value to make sure the modication of ^a in the backup
# database did not affect the source database nor cut new mjl files

$gtm_exe/mumps -run %XCMD 'if (""=$GET(^a)) set ^a=2'
ls -al *.mjl* > after_source_update.log
echo "Expect no journal switches between after_back_update.log and after_source_update.log"
if (`$grep -c mjl after_back_update.log` == `$grep -c mjl after_source_update.log`) echo "No journal switch - as expected"

$gtm_tst/com/dbcheck.csh

# save mjl listing for comparison later
ls -al *.mjl* > after_source_update_MJL.log
#
#
\rm -f *.dat
\cp ./online4/*.dat .
if ($status != 0) then
	echo 'ERROR: copy failed'
endif
#
$MUPIP journal -recover -forward acct.mjl,acnm.mjl,jnl.mjl,mumps.mjl >& jnl.log
echo "Verify that journaling is turned OFF at the end of forward recovery and that it finished successfully"
$grep -E "JNLSTATE|JNLSUCCESS" jnl.log | sort # Need to sort as output can be non-deterministic based on inode/ftok allocation for .dat files
$gtm_exe/mumps -run %XCMD 'do ^mrverify'
$gtm_exe/mumps -run %XCMD 'write "value of ^a in source database after recovery = ",$GET(^a),!'
#
#compare mjl files
ls -al *.mjl* > after_recovery_MJL.log
echo "Expect no journal switches between after_source_update_MJL.log and after_recovery_MJL.log"
if (`$grep -c mjl after_source_update_MJL.log` == `$grep -c mjl after_recovery_MJL.log`) echo "No journal switch - as expected"
echo LEAVING ONLINE4
