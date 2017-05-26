#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
##############################################
### mu_rundown.csh test for mupip rundown  ###
##############################################
#
echo MUPIP RUNDOWN
# dbcreate.csh not used because of complicated GLD setup.
#
# Not applicable for replication/reorg
# so turn them off for dbcheck
unsetenv test_replic
setenv test_reorg NON_REORG
#
@ corecnt = 1
setenv gtmgbldir "./rundown.gld"
if (-f tempru.com) then
    \rm tempru.com
endif
echo "change -segment DEFAULT -file=rundown"  >!  tempru.com
echo "add -name b* -region=rega"              >>! tempru.com
echo "add -name c* -region=regb"              >>! tempru.com
echo "add -region rega -d=sega"               >>! tempru.com
echo "add -region regb -d=segb"               >>! tempru.com
echo "add -segment sega -file=rundowna"       >>! tempru.com
echo "add -segment segb -file=rundownb"       >>! tempru.com
echo "change -region DEFAULT -key_size=64"    >>! tempru.com
echo "change -region rega -key_size=64"       >>! tempru.com
echo "change -region regb -key_size=64"       >>! tempru.com
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	echo "change -segment DEFAULT -allocation=1300"	>>! tempru.com
	echo "change -segment sega -allocation=1300"	>>! tempru.com
	echo "change -segment segb -allocation=1300"	>>! tempru.com
endif
#
$convert_to_gtm_chset tempru.com
#
$GDE << EOF
@./tempru.com
exit
EOF
#
#

if("ENCRYPT" == $test_encryption) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif

$MUPIP create
if ($status > 0) then
    echo ERROR from mupip create.
    exit 1
endif
#
$GTM << EOF
do fill1^myfill("set")
set a="a123456789"
set a5=a_a_a_a_a
set ok=a5_"a12345678"
set off=a5_"a123456789"
set ^b(ok)="ok"
set ^b(off)="off"
write ^b(ok),!
write ^b(off),!
set ^c(ok)="ok"
set ^c(off)="off"
write ^c(ok),!
write ^c(off),!
set ^d(ok)="ok"
set ^d(off)="off"
write ^d(ok),!
write ^d(off),!
halt
EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "ru" "$corecnt"
#
$MUPIP rundown -file rundown.dat
if ( $status > 0 ) then
    echo ERROR from mupip rundown.
endif
source $gtm_tst/$tst/u_inref/check_core_file.csh "ru" "$corecnt"
echo "#"
echo "# Rundown with a bad region"
echo "#"
$MUPIP rundown -region FREELUNCH
source $gtm_tst/$tst/u_inref/check_core_file.csh "ru" "$corecnt"
#
# Rundown with region name list with mixed case
$MUPIP rundown -region Default |& sort -f
set mupip_stat = $status
source $gtm_tst/$tst/u_inref/check_core_file.csh "ru" "$corecnt"
if ( $mupip_stat > 0 ) then
    echo ERROR from mupip rundown.
endif
#
$MUPIP rundown -region "*" |& sort -f
set mupip_stat = $status
source $gtm_tst/$tst/u_inref/check_core_file.csh "ru" "$corecnt"
if ( $mupip_stat > 0 ) then
    echo ERROR from mupip rundown.
endif
#
#
$gtm_tst/com/dbcheck.csh
if ($LFE == "L") then
	exit
endif
#
\rm *.dat
$MUPIP create
$GTM << EOF
job rjob^rjob:(output="rjob.mjo")
halt
EOF

# wait at most 60 seconds or till the job finished the 'SET's
@ infi_cnt=1
@ time_cnt=1
while (($infi_cnt == 1) && ($time_cnt < 120))
        $grep "I am done" rjob.mjo
        if ($status == 0) then
                set infi_cnt=0
        endif
	@ time_cnt = $time_cnt + 1
	sleep 1
end

source $gtm_tst/$tst/u_inref/check_core_file.csh "ru" "$corecnt"
set pid = `$head -n 1 rjob.mjo`
$kill9 $pid	# kill the job while it's sleeping, so that shared memory is left over

# This test does kill -9 (above( of a GT.M process followed by a MUPIP RUNDOWN. A kill -9 could hit the running GT.M process while
# it is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared memory. So,
# set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

# Wait and retry in case of FTOK collisions. Note that collisions can happen after the loop as well.
set wait_time = 1
while ($wait_time)
	$MUPIP rundown -region "*" >&  tmp${wait_time}.rundown
	if (0 == $?) break
	@ wait_time = $wait_time + 1
	if ($wait_time == 10) break
	sleep 1
end

if ($wait_time == 10) then
	echo "Waited 10 seconds, not waiting any longer"
	echo "Check mu_rundown.debug"
	$ps | $grep `$head -n 1 rjob.mjo` >>&! mu_rundown.debug
	$gtm_tst/com/ipcs -a >>&! mu_rundown.debug
    foreach file (*.dat)
	set semkey=`$gtm_exe/ftok $file | $sed -n 's/.*\[ \(.*\) \].*/\1/p'`
	set semid=`$gtm_tst/com/ipcs -a | $grep $semkey | $tst_awk '{print $2}'`
	echo "semid: $semid; semkey: $semkey"
	echo $file
	echo -------------------------------
	$gtm_exe/semstat2 $semid
	echo -------------------------------
end
endif

cat rjob.mje
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx
$MUPIP rundown -region "*" |& sort -f
set mupip_stat = $status
source $gtm_tst/$tst/u_inref/check_core_file.csh "ru" "$corecnt"
if ( $mupip_stat > 0 ) then
    echo ERROR from mupip rundown.
endif
#
$GTM << EOF
for i=1:1:10000 if \$data(^a(i))'=1 write "ERROR : DATA LOST - ^a(",i,")",!
for i=1:1:10000 if \$data(^b(i))'=1 write "ERROR : DATA LOST - ^b(",i,")",!
for i=1:1:10000 if \$data(^c(i))'=1 write "ERROR : DATA LOST - ^c(",i,")",!
EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "ru" "$corecnt"
#
$gtm_tst/com/dbcheck.csh -nosprgde
#
