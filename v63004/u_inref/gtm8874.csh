#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Testing VIEW "[NO]STATSHARE"[:<region-list>]'

echo '#### testA ####'
echo '# enables or disables database statistics sharing for listed regions which permit such sharing. '
echo '#'
echo '# Without the region-list, the command acts on all regions enabled for sharing. '
echo '#'
echo '# When a targeted region has sharing disabled, STATSHARE has no immediate effect, '
echo '# but may cause the process to start sharing when MUPIP SET -STATS enables sharing for that region'
echo ''

echo "# Create a 3 region DB with gbl_dir mumps.gld and regions DEFAULT, AREG, and BREG"
$gtm_tst/com/dbcreate.csh mumps 3 >>& dbcreate_log_1.txt

echo ''
echo '# Disable sharing for BREG'
$MUPIP set -NOSTAT  -reg "BREG" #>>& dbcreate_log.txt

echo '# Run testA of gtm8874.m to test basic VIEW functionality and disabled regions'
$ydb_dist/mumps -run testA^gtm8874

echo '# Shut down the DB and backup necessary files to sub directory'
$gtm_tst/com/dbcheck.csh >>& dbcreate_log_1.txt
$gtm_tst/com/backup_dbjnl.csh dbbkup1 "*.gld *.mjl* *.mjf *.dat" cp nozip
echo ''

echo '#### testB ####'
echo '# When a targeted region has sharing disabled, STATSHARE has no immediate effect, '
echo '# but may cause the process to start sharing when MUPIP SET -STATS enables sharing for that region'
echo '#'
echo '# the $gtm_statshare environment variable applies to databases as the application first uses them'
echo ''

echo '# setenv gtm_statshare "TRUE"'
setenv gtm_statshare "TRUE"
echo '# Recreate the 3 region DB with gbl_dir mumps.gld'
$gtm_tst/com/dbcreate.csh mumps 3 >>& dbcreate_log_2.txt

echo ''
echo '# Disable sharing for BREG'
$MUPIP set -NOSTAT  -reg "BREG" #>>& dbcreate_log.txt

echo '# Run testB1 of gtm8874.m to V[IEW] "STATSHARE" and run $VIEW for each region with gtm_statshare="TRUE"'
$ydb_dist/mumps -run testB1^gtm8874

echo '# Enable sharing for BREG'
$MUPIP set -STAT  -reg "BREG" #>>& dbcreate_log.txt

echo '# Run testB2 of gtm8874.m to $VIEW regions'
$ydb_dist/mumps -run testB2^gtm8874

echo 'unsetenv gtm_statshare'
unsetenv gtm_statshare

echo '# Shut down the DB and backup necessary files to sub directory'
$gtm_tst/com/dbcheck.csh >>& dbcreate_log_2.txt
$gtm_tst/com/backup_dbjnl.csh dbbkup2 "*.gld *.mjl* *.mjf *.dat" cp nozip
echo ''

echo '#### testC ####'
echo '# VIEW "[NO]STATSHARE" with no region sub-argument opens any unopened mapped regions'
echo '# and any enabled associated statsDB regions'
echo '#'
echo '# When the last VIEW "[NO]STATSHARE" had no region sub-argument, regions implicitly share '
echo '# when the process first references them, but after a VIEW specifies selective sharing, '
echo '# regions don\'t implicitly share as they open'
echo ''

echo "# Create a 1 region DB with gbl_dir otherA.gld"
$gtm_tst/com/dbcreate.csh otherA >>& dbcreate_log_3.txt
echo "# Backup otherA.dat DB"
$gtm_tst/com/backup_dbjnl.csh dbbkup3 "*.gld *.mjl* *.mjf *.dat" cp nozip
echo "# Create a 1 region DB with gbl_dir otherB.gld"
$gtm_tst/com/dbcreate.csh otherB >>& dbcreate_log_3.txt
echo "# Move otherA.dat DB files back to current directory"

foreach x (`ls ./dbbkup3`)
     mv ./dbbkup3/$x ./$x
end

echo '# Run testC of gtm8874.m to test implicit sharing of VIEW "STATSHARE"'
$ydb_dist/mumps -run testC^gtm8874
