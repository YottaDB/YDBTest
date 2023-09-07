#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo MUPIP BACKUP
setenv gtmgbldir "ＡＢＣＤ.gld"
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate_base.csh ＡＢＣＤ 1 255 1000 . 25000
else
	$gtm_tst/com/dbcreate_base.csh ＡＢＣＤ 1 255 1000
endif
$MUPIP set $tst_jnl_str -reg "*"
set cur_dir=`pwd`
set bkup_dir1="$cur_dir/ＡＤＩＲ"
set bkup_dir2="$cur_dir/αβγδε"
set bkup_dir3="$cur_dir/我能吞下玻璃而不伤身体"
mkdir $bkup_dir1
mkdir $bkup_dir2
mkdir $bkup_dir3
$GTM << aaaa
w "Do in0^udbfill(""set"")",!
d in0^udbfill("set")
h
aaaa
$MUPIP backup "*" $bkup_dir1
if ( $status > 0 ) then
    echo ERROR with comprehansive backup.
    exit 1
endif
#
$GTM << cccc
w "Do in0^udbfill(""kill"")",!
d in0^udbfill("kill")
w "Do in1^udbfill(""set"")",!
d in1^udbfill("set")
h
cccc
#
$MUPIP backup -incremental DEFAULT $bkup_dir2/backup.bak2
if ( $status > 0 ) then
    echo ERROR with incremental since comprehensive backup.
    exit 2
endif
#
$GTM << eeee
w "Do in1^udbfill(""kill"")",!
d in1^udbfill("kill")
w "Do in2^udbfill(""set"")",!
d in2^udbfill("set")
h
eeee
$MUPIP backup -incremental -i -since=i "*" $bkup_dir3/backup.bak3
if ( $status > 0 ) then
    echo ERROR with incremental since incremental backup.
    exit 3
endif
#
$MUPIP backup -i -since=r DEFAULT -noonline  $bkup_dir3/backup.bak33
if ( $status > 0 ) then
    echo ERROR with incremental since record backup.
    exit 4
endif
#
$MUPIP backup -i -t=1 DEFAULT -noonline  $bkup_dir3/backup.bak333
if ( $status > 0 ) then
    echo ERROR with incremental from transaction backup.
    exit 5
endif
$gtm_tst/com/dbcheck.csh
#
#
###########
# restore #
###########
\cp -f $bkup_dir1/* .  # Restore from comprehensive bakup
$GTM << eeee
w "Do in0^udbfill(""ver"")",!
d in0^udbfill("ver")
h
eeee
#
\cp -f $bkup_dir1/* .  # Restore from comprehensive bakup
$MUPIP restore ＡＢＣＤ.dat $bkup_dir2/backup.bak2
if ( $status > 0 ) then
    echo $MUPIP restore ＡＢＣＤ.dat $bkup_dir2/backup.bak2 failed
    exit 8
endif
$GTM << eeee
w "Do in1^udbfill(""ver"")",!
d in1^udbfill("ver")
h
eeee
#
$MUPIP restore ＡＢＣＤ.dat $bkup_dir3/backup.bak3
if ( $status > 0 ) then
    echo $MUPIP restore ＡＢＣＤ.dat $bkup_dir3/backup.bak3 failed
    exit 8
endif
$GTM << eeee
w "Do in2^udbfill(""ver"")",!
d in2^udbfill("ver")
h
eeee
$gtm_tst/com/dbcheck.csh
#
\rm *.dat
$MUPIP create
$MUPIP restore ＡＢＣＤ.dat $bkup_dir3/backup.bak33
if ( $status > 0 ) then
    echo $MUPIP restore ＡＢＣＤ.dat $bkup_dir3/backup.bak33
    exit 8
endif
$GTM << eeee
w "Do in2^udbfill(""ver"")",!
d in2^udbfill("ver")
h
eeee
$gtm_tst/com/dbcheck.csh
#
\rm *.dat
$MUPIP create
$MUPIP restore ＡＢＣＤ.dat $bkup_dir3/backup.bak333
if ( $status > 0 ) then
    echo $MUPIP restore ＡＢＣＤ.dat $bkup_dir3/backup.bak333 failed
    exit 8
endif
$GTM << eeee
w "Do in2^udbfill(""ver"")",!
d in2^udbfill("ver")
h
eeee
$gtm_tst/com/dbcheck.csh
#
####################################
# END of this test                 #
####################################
