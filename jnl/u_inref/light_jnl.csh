#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# **** Light form of Journal test ***
#
\rm -f *.dat *.mjl >& /dev/null
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh light_jnl 9
setenv gtmgbldir "light_jnl.gld"
#
$MUPIP set -file -nojournal light_jnl.dat
$MUPIP set -region -journal=enable,on,before "*" > & $tst_working_dir/p2
sort -f $tst_working_dir/p2
#
$GTM << EOF
d ert^ldbfill
d ern^ldbfill
w "h",!  h
EOF
#
echo "Backward recovery ... ..."
$MUPIP journal -recover -backward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,h.mjl,light_jnl.mjl
echo "Forward recover ... ..."
echo "remove the database file and create a new one."
$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat" mv
$MUPIP create
#
$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,h.mjl,light_jnl.mjl >>& rec_for1.log
set stat1 = $status

$grep "Recover successful" rec_for1.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Light_jnl TEST FAILED"
	cat  rec_for1.log
	exit 1
endif
$gtm_tst/com/dbcheck.csh
# *** Journal Switch test TP.
$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.mjl *.gld" mv
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh light_jnl 3
setenv gtmgbldir "light_jnl.gld"
#
$MUPIP set -file -nojournal light_jnl.dat
$MUPIP set -region -journal=enable,on,nobefore "BREG"
#
$GTM << EOF
s ^in4=0
l ^test1
d ^ljtp
w "f k=1:1:3000  q:^in4=2  h 1",!                   f k=1:1:3000  q:^in4=2  h 1
w "if k=3000  w ""TIMEOUT 1"",!",!                  if k=3000  w "TIMEOUT 1",!
w "w ""starting to switch journal files."",!",!    w "starting to switch journal files.",!
w "h",!  h
l
EOF
#
$MUPIP set -region -journal=on,nobefore "BREG" > & $tst_working_dir/p3
$GTM << EOF
l ^test2
h 5
l
EOF
$GTM << EOF
f k=1:1:3000  q:^in4=4  h 1
i k=3000  w "Should we wait so long?",!
h
EOF
#
$gtm_tst/com/rundown.sh
echo "remove the database file and create a new one."
$gtm_tst/com/backup_dbjnl.csh bak3 "*.dat" mv
$MUPIP create
#
echo "First recover ... ..."
$MUPIP journal -recover -forward b.mjl_* >>& rec_for2.log
set stat1 = $status

$grep "Recover successful" rec_for2.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Light_jnl TEST FAILED"
	cat  rec_for2.log
	exit 1
endif
$GTM << EOF
d ^ltvr1
w "VERIFICATION PASSED",!
h
EOF
#
echo "Second recover ... ..."
$MUPIP journal -recover -forward b.mjl >>& rec_for3.log
set stat1 = $status

$grep "Recover successful" rec_for3.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Light_jnl TEST FAILED"
	cat  rec_for3.log
	exit 1
endif
$GTM << EOF
d ^ltvr2
w "VERIFICATION PASSED",!
h
EOF
$gtm_tst/com/dbcheck.csh
# *** Journal Switch test NON_TP.
$gtm_tst/com/backup_dbjnl.csh bak4 "*.dat *.mjl *.gld" mv
setenv gtm_test_sprgde_id "ID3"	# to differentiate multiple dbcreates done in the same subtest
source $gtm_tst/com/dbcreate.csh light_jnl 3
setenv gtmgbldir "light_jnl.gld"
#
$MUPIP set -file -nojournal light_jnl.dat
$MUPIP set -region -journal=enable,on,nobefore "AREG"
#
$GTM << EOF
s ^in4=0
l ^test1
d ^ljntp
w "f k=1:1:3000  q:^in4=2  h 1",!                   f k=1:1:3000  q:^in4=2  h 1
w "if k=3000  w ""TIMEOUT 1"",!",!                  if k=3000  w "TIMEOUT 1",!
w "w ""starting to switch journal files."",!",!    w "starting to switch journal files.",!
w "h",!  h
l
EOF
#
$MUPIP set -region -journal=on,nobefore "AREG" > & $tst_working_dir/p3
$GTM << EOF
l ^test2
h 5
l
EOF
#
$GTM << EOF
f k=1:1:3000  q:^in4=4  h 1
i k=3000  w "Should we wait so long?",!
h
EOF
#
$gtm_tst/com/rundown.sh
echo "remove the database file and create a new one."
$gtm_tst/com/backup_dbjnl.csh bak5 "*.dat" mv
$MUPIP create
#
echo "First recover ... ..."
$MUPIP journal -recover -forward a.mjl_* >>& rec_for4.log
set stat1 = $status

$grep "Recover successful" rec_for4.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Light_jnl TEST FAILED"
	cat  rec_for4.log
	exit 1
endif
$GTM << EOF
d ^lverify1
w "VERIFICATION PASSED",!
h
EOF
#
echo "Second recover ... ..."
$MUPIP journal -recover -forward a.mjl >>& rec_for5.log
set stat1 = $status

$grep "Recover successful" rec_for5.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Light_jnl TEST FAILED"
	cat  rec_for5.log
	exit 1
endif
$GTM << EOF
d ^lverify2
w "VERIFICATION PASSED",!
h
EOF
#
$gtm_tst/com/dbcheck.csh
