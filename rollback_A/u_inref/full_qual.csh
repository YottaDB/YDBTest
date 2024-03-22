#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST CASE #65: test -FULL qualifier (03/24/2003)
#

# Turn off statshare related env var as it affects test flow (since the test does "cp" and "rm" assuming only base db exists
# whereas it needs to be modified to also handle statsdb related files and shm/sem which is not trivial) and is not considered
# worth the effort to support.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

# Use "-nostats" below to avoid statsdb from being opened by update process (default is "-stats"). Opening statsdb can
# cause problems since the test does "cp" and "rm". Same reason mentioned above where "ydb_statshare" env var is disabled).
$gtm_tst/com/dbcreate.csh mumps -nostats

setenv portno `$sec_shell "$sec_getenv; cat $SEC_SIDE/portno"`
setenv start_time `cat start_time`
echo "Start M process"
#
$gtm_exe/mumps -run %XCMD 'for i=0:1:2 set file="time"_i_".txt" open file use file write $zdate($horolog,"DD-MON-YEAR 24:60:SS") use $P hang:i 1 set ^x(i)=i if 2>i hang 1 zsystem "$DSE buffer_flush" hang 1'
#
#now stop the replication servers
echo "Receiver shut down ..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"
echo "Source shut down ..."
$gtm_tst/com/SRC_SHUT.csh "." >>& SHUT_${start_time}.out
#
cd $PRI_SIDE
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
mkdir ./save
cp mumps.* ./save
#rollback the database
echo "********************"
echo "Rolling back ... "
echo "********************"
#$gtm_tst/com/srcstat.csh "EXTRACT"
$gtm_tst/com/mupip_rollback.csh -resync=3 -lost=x.lost_2 "*" >>& rollback2.log
set stat1=$status
$grep "Rollback successful" rollback2.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Full qualifier test failed"
	cat rollback2.log
	exit 1
endif
#
echo "******************************"
echo "Verifying data ..."
echo "******************************"
$GTM << aaa
 zwr ^x
aaa
#
echo "*****************************"
echo "Extract ..."
echo "*****************************"
set jfile1=`ls -t mumps.mjl_*`
$MUPIP journal -extract=mumps_a.mjf -for mumps.mjl >>& ext_bak.log
set stat1=$status
if ($stat1 != 0 ) then
  echo "Full qualifier test failed "
  cat ext_bak.log
  exit 1
endif
#analyze the extract file
# should contain no data
echo "extract result of mumps.mjl"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_a.mjf
#
$MUPIP journal -extract=mumps_a_1.mjf -for $jfile1 >>& ext_bak.log
set stat1=$status
if ($stat1 != 0) then
  echo "Full qualifier test failed "
  cat ext_bak.log
  exit 1
endif
#analyze the extract file
# should contain ^x(0) and ^x(1)
echo "extract result of jfile1"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_a_1.mjf
#
$MUPIP journal -extract=mumps_a_2.mjf -for -full $jfile1 >>& ext_bak.log
set stat1=$status
if ($stat1 != 0 ) then
  echo "Full qualifier test failed "
  cat ext_bak.log
  exit 1
endif
#analyze the extract file
# should contain ^x(0), ^x(1), and ^x(2)
echo "full extract result of jfile1"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_a_2.mjf
#
#rollback the database
echo "Rolling back again... "
#$gtm_tst/com/srcstat.csh "EXTRACT"
$gtm_tst/com/mupip_rollback.csh -resync=2 -verbose -lost=x.lost_1 "*" >>& rollback1.log
set stat1=$status
$grep "Rollback successful" rollback1.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Full qualifier test failed"
	cat rollback1.log
	exit 1
endif
#
echo "******************************"
echo "Verifying data again ..."
echo "******************************"
$GTM << aaa
 zwr ^x
aaa
#
echo "*****************************"
echo "Extract ..."
echo "*****************************"
set jfile2=`ls -t rolled_bak_mumps.mjl_* | $tst_awk '{if (NR==1) print $0}'`
$MUPIP journal -extract=mumps_b.mjf -for mumps.mjl >>& ext_bak.log
set stat1=$status
if ($stat1 != 0 ) then
  echo "Full qualifier test failed "
  cat ext_bak.log
  exit 1
endif
#analyze the extract file
# should contain no data
echo "extract result of mumps.mjl"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_b.mjf
#
$MUPIP journal -extract=mumps_b_1.mjf -for $jfile2 >>& ext_bak.log
set stat1=$status
if ($stat1 != 0 ) then
  echo "Full qualifier test failed "
  cat ext_bak.log
  exit 1
endif
#analyze the extract file
# should contain no data
echo "extract result of jfile2"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_b_1.mjf
#
$MUPIP journal -extract=mumps_b_2.mjf -for -full $jfile2 >>& ext_bak.log
set stat1=$status

if ($stat1 != 0) then
  echo "Full qualifier test failed "
  cat ext_bak.log
  exit 1
endif
#analyze the extract file
# should contain ^x(0), ^x(1)
echo "full extract result of jfile2"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_b_2.mjf
#
$MUPIP journal -extract=mumps_b_3.mjf -for $jfile1 >>& ext_bak.log
set stat1=$status

if ($stat1 != 0) then
  echo "Full qualifier test failed "
  cat ext_bak.log
  exit 1
endif
#analyze the extract file
# should contain ^x(0)
echo "extract result of jfile1"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_b_3.mjf
#
$MUPIP journal -extract=mumps_b_4.mjf -for -full $jfile1 >>& ext_bak.log
set stat1=$status
if ($stat1 != 0) then
  echo "Full qualifier test failed "
  cat ext_bak.log
  exit 1
endif
#analyze the extract file
# should contain ^x(0), ^x(1) and ^x(2)
echo "full extract result of jfile1"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_b_4.mjf
#
echo "---------------------------------"
echo "*********************************"
echo "Backward recovery "
echo "*********************************"
rm *mumps.*
cp ./save/*.* .
set time1=`cat time1.txt`
set time2=`cat time2.txt`
$MUPIP journal -recov -back -since=\"$time2\" -before=\"$time2\" mumps.mjl >>& rec_back2.log
set stat3=$status
$grep "Recover successful" rec_back2.log
set stat4=$status
if ($stat3 != 0 || $stat4 != 0) then
	echo "Full qualifier test failed"
	cat rec_back2.log
	exit 1
endif
#
#
echo "******************************"
echo "Verifying data ..."
echo "******************************"
$GTM << aaa
 zwr ^x
aaa
#
echo "*****************************"
echo "Extract ..."
echo "*****************************"
set jfile1=`ls -t mumps.mjl_* | $tst_awk '{if (NR==1) print $0}'`
$MUPIP journal -extract=mumps_c.mjf -for mumps.mjl >>& ext_bak1.log
set stat1=$status
if ($stat1 != 0 ) then
  echo "Full qualifier test failed "
  cat ext_bak1.log
  exit 1
endif
#analyze the extract file
# should contain no data
echo "extract result of mumps.mjl"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_c.mjf
#
$MUPIP journal -extract=mumps_c_1.mjf -for $jfile1 >>& ext_bak1.log
set stat1=$status
if ($stat1 != 0) then
  echo "Full qualifier test failed "
  cat ext_bak1.log
  exit 1
endif
#analyze the extract file
# should contain ^x(0) and ^x(1)
echo "extract result of jfile1"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_c_1.mjf
#
$MUPIP journal -extract=mumps_c_2.mjf -for -full $jfile1 >>& ext_bak1.log
set stat1=$status
if ($stat1 != 0 ) then
  echo "Full qualifier test failed "
  cat ext_bak1.log
  exit 1
endif
#analyze the extract file
# should contain ^x(0), ^x(1), and ^x(2)
echo "full extract result of jfile1"
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' mumps_c_2.mjf
#
#back recover the database
echo "Backward recovery again... "
#$gtm_tst/com/srcstat.csh "EXTRACT"
$MUPIP journal -recov -back -since=\"$time1\" -before=\"$time1\" -verbose mumps.mjl >>& rec_bak1.log
set stat1=$status
$grep "Recover successful" rec_bak1.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Full qualifier test failed"
	cat rec_bak1.log
	exit 1
endif
#
echo "******************************"
echo "Verifying data again ..."
echo "******************************"
$GTM << aaa
 zwr ^x
aaa
#
echo "*****************************"
echo "Extract ..."
echo "*****************************"
set jfile2=`ls -t rolled_bak_mumps.mjl_* | $tst_awk '{if (NR==1) print $0}'`
$MUPIP journal -extract=mumps_d.mjf -for mumps.mjl >>& ext_bak1.log
set stat1=$status
if ($stat1 != 0 ) then
  echo "Full qualifier test failed "
  cat ext_bak1.log
  exit 1
endif
#analyze the extract file
# should contain no data
echo "extract result of mumps.mjl"
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' mumps_d.mjf
#
$MUPIP journal -extract=mumps_d_1.mjf -for $jfile2 >>& ext_bak1.log
set stat1=$status
if ($stat1 != 0 ) then
  echo "Full qualifier test failed "
  cat ext_bak1.log
  exit 1
endif
#analyze the extract file
# should contain no data
echo "extract result of jfile2"
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' mumps_d_1.mjf
#
$MUPIP journal -extract=mumps_d_2.mjf -for -full $jfile2 >>& ext_bak1.log
set stat1=$status

if ($stat1 != 0) then
  echo "Full qualifier test failed "
  cat ext_bak1.log
  exit 1
endif
#analyze the extract file
# should contain  ^x(1)
echo "full extract result of jfile2"
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' mumps_d_2.mjf
#
$MUPIP journal -extract=mumps_d_3.mjf -for $jfile1 >>& ext_bak1.log
set stat1=$status

if ($stat1 != 0) then
  echo "Full qualifier test failed "
  cat ext_bak1.log
  exit 1
endif
#analyze the extract file
# should contain ^x(0)
echo "extract result of jfile1"
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' mumps_d_3.mjf
#
$MUPIP journal -extract=mumps_d_4.mjf -for -full $jfile1 >>& ext_bak1.log
set stat1=$status
if ($stat1 != 0) then
  echo "Full qualifier test failed "
  cat ext_bak1.log
  exit 1
endif
#analyze the extract file
# should contain ^x(0), ^x(1) and ^x(2)
echo "full extract result of jfile1"
$tst_awk '{n=split($0,f,"\\");if(f[1]=="05") print f[n]}' mumps_d_4.mjf
#
$gtm_tst/com/dbcheck.csh -noshut
$gtm_tst/com/portno_release.csh
