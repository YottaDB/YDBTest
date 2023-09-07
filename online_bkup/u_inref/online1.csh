#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
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
#
#
echo ENTERING ONLINE1
#

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
setenv gtmgbldir online1.gld
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv bkp_dir "`pwd`/online1"
mkdir $bkp_dir
chmod 777 $bkp_dir
#
#
# ================================== Basic Backup ================================== #
#
#
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh online1 1 125 700 1536 700 256
else
	$gtm_tst/com/dbcreate.csh online1 1 125 700 1536 100 256
endif
#
# ------------- comprehensive record onine ----------------- #
#
$GTM << GTM_EOF
w "Do fill1^myfill(""set"")",!
d fill1^myfill("set")
h
GTM_EOF
$MUPIP backup -c -rec -o DEFAULT $bkp_dir
if ( $status != 0 ) then
    echo ERROR with comprehansive backup.
    exit 1
endif
#
# ----------------- incremental online ------------------------ #
#
$GTM << GTM_EOF
w "Do fill2^myfill(""set"")",!
d fill2^myfill("set")
h
GTM_EOF
$MUPIP backup -i -o DEFAULT $bkp_dir/backup.bak2
if ( $status != 0 ) then
    echo ERROR with incremental since comprehansive backup.
    exit 2
endif
#
# -------- incremental since incremental online --------------- #
#
$GTM << GTM_EOF
w "Do fill3^myfill(""set"")"
d fill3^myfill("set")
h
GTM_EOF
$MUPIP backup -i -since=i -o DEFAULT $bkp_dir/backup.bak3
if ( $status != 0 ) then
    echo ERROR with incremental since incremental backup.
    exit 3
endif
#
# -------- incremental since record online -------------------- #
#
$MUPIP backup -o -i -since=r DEFAULT $bkp_dir/backup.bak33
if ( $status != 0 ) then
    echo ERROR with incremental since record backup.
    exit 4
endif
#
# -------- incremental online transction ---------------------- #
#
$MUPIP backup -o -i -t=1 DEFAULT $bkp_dir/backup.bak333
if ( $status != 0 ) then
    echo ERROR with incremental from transaction backup.
    exit 5
endif
#
# ---------- check for integrity, shutdown replication/reorg -------------- #
#
$gtm_tst/com/dbcheck.csh
# from here on no dbcreates are done so disable dbcheck from regenerating the .sprgde file using -nosprgde
#
#
# =============================== Restore To Verify ================================ #
#
#
\rm -f *.dat
\cp $bkp_dir/online1.dat . 			# restore from the comprehansive backup.
$gtm_tst/com/dbcheck.csh -noshut -nosprgde	# integrity check
$GTM << GTM_EOF					# content check
w "Do fill1^myfill(""ver"")",!
d fill1^myfill("ver")
h
GTM_EOF
#
#
\rm -f *.dat
\cp $bkp_dir/online1.dat .
$MUPIP restore online1.dat $bkp_dir/backup.bak2
if ( $status != 0 ) then
    echo ERROR with incremental since comprehansive restore.
    exit 6
endif
$gtm_tst/com/dbcheck.csh -noshut -nosprgde
$GTM << GTM_EOF
w "Do fill2^myfill(""ver"")",!
d fill2^myfill("ver")
h
GTM_EOF
#
#
\rm -f *.dat
\cp $bkp_dir/online1.dat .
$MUPIP restore online1.dat $bkp_dir/backup.bak2
$MUPIP restore online1.dat $bkp_dir/backup.bak3
if ( $status != 0 ) then
    echo ERROR with incremental since incremental restore.
    exit 7
endif
$gtm_tst/com/dbcheck.csh -noshut -nosprgde
$GTM << GTM_EOF
w "Do fill3^myfill(""ver"")",!
d fill3^myfill("ver")
h
GTM_EOF
#
#
\rm -f *.dat
\cp $bkp_dir/online1.dat .
$MUPIP restore online1.dat $bkp_dir/backup.bak33
if ( $status != 0 ) then
    echo ERROR with incremental since record restore.
    exit 8
endif
$gtm_tst/com/dbcheck.csh -noshut -nosprgde
$GTM << GTM_EOF
w "Do fill3^myfill(""ver"")",!
d fill3^myfill("ver")
h
GTM_EOF
#
#
\rm -f *.dat
$MUPIP create
$MUPIP restore online1.dat $bkp_dir/backup.bak333
if ( $status != 0 ) then
    echo ERROR with incremental from transaction restore.
    exit 9
endif
$gtm_tst/com/dbcheck.csh -noshut -nosprgde
$GTM << GTM_EOF
w "Do fill3^myfill(""ver"")",!
d fill3^myfill("ver")
h
GTM_EOF
#
#
echo LEAVING ONLINE1
