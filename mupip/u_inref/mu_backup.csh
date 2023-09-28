#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in MUPIP BACKUP/RESTORE output and differences in minor DB version
#
##################################################
###  mu_backup.csh                             ###
###     Test scripts for the mupip backup ...  ###
###     Basic Functionalities                  ###
##################################################
#

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
echo MUPIP BACKUP
#
#
###################
# Initializations #
###################
#
# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
# This test needs the size of DB being created to always be fixed. Hence set gtm_test_defer_allocate.
setenv gtm_test_defer_allocate 0
#
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
#
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set filterit = '%YDB-I-BACKUPTN, Transactions from'
else
	set filterit = 'NOTHINGTOFILTEROUT'
endif
alias trcount '$tst_awk '"'"'/%YDB-I-BACKUPTN, Transactions from/ {tot=tot+strtonum($6)} END{ print "# Total number of transactions backed up: ",tot}'"'"' '
#

setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
setenv gtmgbldir mumps
set MAX_REC_SZ=1048576 # 1 MB
# we need to have only one DB, to ensure that the globals go into that DB and its size is deterministic.
# Creating a DB size of 125MB (BLOCK_SIZE=4096 * ALLOCATION=32000)
$gtm_tst/com/dbcreate.csh mumps 1 1019 $MAX_REC_SZ -block_size=4096 -allocation=32000
#Now fill in some data and check the size of backup.
# 70 * MAX_REC_SZ fills up ~70% of the DB size (125MB)
$GTM >&! gtm_setvars.out << EOF
set ^a="First var"
set ^b="second var"
for i=1:1:70 s ^a(i)=\$justify("",$MAX_REC_SZ)
EOF
set bkp_dir2=backup_checksize1
mkdir $bkp_dir2
$MUPIP backup "*" -noonline $bkp_dir2/ >& backup_set.out
if ($status > 0) then
    echo "BACKUP-E-FAILED : mupip backup multiple region"
    exit 102
endif
# compare the size of backup with the size of DB
$gtm_tst/$tst/u_inref/compare_backup_db_sz.csh "mumps.dat" "$bkp_dir2/mumps.dat"
#Do the integ check, stop the replication servers.
$gtm_tst/com/dbcheck.csh "mumps" >& mumps_dbcheck.out
#
# ---------------- Now proceed with original backup tests --------------- #
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
setenv gtmgbldir backup.gld
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh backup 1 125 700 1536 800 256
else
	$gtm_tst/com/dbcreate.csh backup 1 125 700 1536 100 256
endif
@ corecnt = 1
setenv gtmgbldir "./backup.gld"
setenv cur_dir $PWD
setenv bkp_dir "$cur_dir/backup-dir"
mkdir $bkp_dir
chmod 777 $bkp_dir
#
#
##########
# backup #
##########
#
#
$GTM << aaaa
w "Do fill1^myfill(""set"")",!
d fill1^myfill("set")
h
aaaa
source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
echo "#"
echo "# Backup with a bad region"
echo "#"
$MUPIP backup -c -rec FREELUNCH -noonline $bkp_dir
#
#Region Name in Mixed cases should be accepted
#
$MUPIP backup -c -rec Default -noonline $bkp_dir
if ( $status > 0 ) then
    echo "BACKUP-E-FAILED : comprehensive backup."
    exit 1
endif
#
#
$GTM << cccc
w "Do fill2^myfill(""set"")",!
d fill2^myfill("set")
h
cccc
source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
$MUPIP backup -i DEFAULT -noonline $bkp_dir/backup.bak2
if ( $status > 0 ) then
    echo "BACKUP-E-FAILED : incremental since comprehensive backup."
    exit 2
endif
#
#
$GTM << eeee
w "Do fill3^myfill(""set"")"
d fill3^myfill("set")
h
eeee

source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
$MUPIP backup -i -since=i DEFAULT -noonline $bkp_dir/backup.bak3
if ( $status > 0 ) then
    echo "BACKUP-E-FAILED : incremental since incremental backup."
    exit 3
endif
#
#
$MUPIP backup -i -since=r DEFAULT -noonline  $bkp_dir/backup.bak33
if ( $status > 0 ) then
    echo "BACKUP-E-FAILED : incremental since record backup."
    exit 4
endif
#
#
$MUPIP backup -i -t=1 DEFAULT -noonline  $bkp_dir/backup.bak333
if ( $status > 0 ) then
    echo "BACKUP-E-FAILED : incremental from transaction backup."
    exit 5
endif
#
#
$gtm_tst/com/dbcheck.csh "backup"
#
#
###########
# restore #
###########
#
# This part of the test uses dbcheck to check the integrity for the databases,
# But there is no replication/reorg involved, so save them and turn them off.
if ($?test_replic) then
	setenv test_replic_save_in_mu_backup Y
else
	setenv test_replic_save_in_mu_backup N
endif
unsetenv test_replic
setenv test_reorg_save_in_mu_backup NON_REORG
if ($?test_reorg) then
	setenv test_reorg_save_in_mu_backup $test_reorg
endif
setenv test_reorg NON_REORG
#
#
if (-f backup.dat) then
    \rm backup.dat
endif
cp $bkp_dir/backup.dat . # restore from the comprehensive backup.
#
#
$gtm_tst/com/dbcheck.csh "backup"
$GTM << bbbb
w "Do fill1^myfill(""ver"")",!
d fill1^myfill("ver")
h
bbbb
source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
\rm backup.dat
cp $bkp_dir/backup.dat .
$MUPIP restore backup.dat $bkp_dir/backup.bak2
if ( $status > 0 ) then
    echo "RESTORE-E-FAILED : incremental since comprehensive restore."
    exit 6
endif
$gtm_tst/com/dbcheck.csh "backup"
#
#
$GTM << dddd
w "Do fill2^myfill(""ver"")",!
d fill2^myfill("ver")
h
dddd
source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
\rm backup.dat
cp $bkp_dir/backup.dat .
$MUPIP restore backup.dat $bkp_dir/backup.bak2
$MUPIP restore backup.dat $bkp_dir/backup.bak3
if ( $status > 0 ) then
    echo "RESTORE-E-FAILED : incremental since incremental restore."
    exit 7
endif
$gtm_tst/com/dbcheck.csh "backup"
#
$GTM << ffff
w "Do fill3^myfill(""ver"")",!
d fill3^myfill("ver")
h
ffff
source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
\rm backup.dat
cp $bkp_dir/backup.dat .
$MUPIP restore backup.dat $bkp_dir/backup.bak33
if ( $status > 0 ) then
    echo "RESTORE-E-FAILED : incremental since record restore."
    exit 8
endif
$gtm_tst/com/dbcheck.csh "backup"
#
$GTM << gggg
w "Do fill3^myfill(""ver"")",!
d fill3^myfill("ver")
h
gggg
source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
\rm backup.dat
$MUPIP create
$MUPIP restore backup.dat $bkp_dir/backup.bak333
if ( $status > 0 ) then
    echo "RESTORE-E-FAILED : incremental from transaction restore."
    exit 9
endif
$gtm_tst/com/dbcheck.csh
#
#
$GTM << hhhh
w "Do fill3^myfill(""ver"")",!
d fill3^myfill("ver")
h
hhhh
source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
if ($test_replic_save_in_mu_backup == "Y") then
	setenv test_replic
endif
setenv test_reorg $test_reorg_save_in_mu_backup
#
###################
# New for phase 2 #
###################
#
#
# implicit freeze -- to be added for Extended Suite
##################
#
#
echo PASS from mupip backup implicit freeze.
#
# Multi-region and wildcard
###########################
#
#
\rm -rf *.dat >& /dev/null
\rm -rf *.gld >& /dev/null
\rm -rf $bkp_dir/*.dat >& /dev/null
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh backup 3 125 700 1536 700 256
else
	$gtm_tst/com/dbcreate.csh backup 3 125 700 1536 100 256
endif
#
#
$GTM << jjjj
d fill5^myfill("right")
h
jjjj
source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
$MUPIP backup "*" $bkp_dir -noonline >&! mupip_backup_fill5.out
if ($status > 0) then
    echo "BACKUP-E-FAILED : mupip backup multiple region"
    exit 11
endif
sort mupip_backup_fill5.out |& $grep -v "$filterit"
trcount mupip_backup_fill5.out
#
#
$gtm_tst/com/dbcheck.csh
#
#
\rm -rf *.dat >& /dev/null
\cp $bkp_dir/backup*.dat .
\cp $bkp_dir/a.dat .
\cp $bkp_dir/b.dat .
$GTM << kkkk
d fill5^myfill("ver")
h
kkkk
source $gtm_tst/$tst/u_inref/check_core_file.csh ba $corecnt
#
#
# backup to oneself
####################
#
#
$MUPIP backup -i -since=i DEFAULT -noonline ./backup.dat
if ($status == 0) then
    echo ERROR from backup to oneself.
    exit 13
endif
# Since replication servers are already shut down by the previous dbcheck call, use "-noshut" below.
# Since dbcheck is already done above, do not generate spanning regions config file in this dbcheck
$gtm_tst/com/dbcheck.csh -noshut -nosprgde
#
####################################
# END of this test                 #
####################################
