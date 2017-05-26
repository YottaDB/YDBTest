#################################################################
#								#
# Copyright (c) 2007-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# core script for profile test
# add system specific speed values to com/serverconf.m

if ("$profileversion" == "64" && "$gtm_test_machtype" == "ia64") then
	echo "Profile Test V64 not supported on ia64"
	exit
endif

#this needs to be removed when UTF-8 is handled properly
unsetenv gtm_chset

setenv HOSTNAME $HOST:r:r:r

if (! -d $gtm_test_log_dir) then
	mkdir -p $gtm_test_log_dir
	if ($status) echo "TEST-E-LOGDIR, cannot create log directory $gtm_test_log_dir for test $tst. Will not be able to save logs"
endif

setenv testbasedir $tst_working_dir

# construct the directory structure.
echo '*********** constructing test directories ************'
mkdir SCA
mkdir v${profileversion}perf
mkdir v${profileversion}perf/gbls
set scadir = "${testbasedir}/SCA"
set perfdir = "${testbasedir}/v${profileversion}perf"
set gblsdir = "${testbasedir}/v${profileversion}perf/gbls"

ln -s -f $gtm_exe $perfdir/gtm_dist
ln -s -f $gtm_exe $scadir/gtm_dist

# restore from tar files
echo '********** restoring source and database from tar files **********'

setenv CALIPER "/opt/caliper/bin/caliper"
setenv CALIPER_REPORT scgprof

cd $scadir
set platform = $gtm_test_osname
if ("$gtm_test_osname" == "aix") then
	set osver=$gtm_test_osver
	# handle AIX 6
	if ($gtm_test_osver > 4) then
		set osver=5
	endif
	set platform = "$gtm_test_osname.$osver"
else if ("$gtm_test_osname" == "hp-ux") then
	set platform = "v$profileversion.$gtm_test_osname.$gtm_test_machtype"
else if ("$gtm_test_osname" == "linux") then
	set platform = "$gtm_test_osname"."$gtm_test_machtype"
endif

if ( ! -e $gtm_test/big_files/profile/$platform.SCA.tar.gz ) then
	echo "$gtm_test/big_files/profile/$platform.SCA.tar.gz does not exist"
	exit -1
endif
cd $scadir
cp $gtm_test/big_files/profile/$platform.SCA.tar.gz .
$tst_gzip -d $platform.SCA.tar.gz
tar xf $platform.SCA.tar

if ( ! -e $gtm_test/big_files/profile/v${profileversion}profile.tar.gz ) then
	echo "$gtm_test/big_files/profile/v${profileversion}profile.tar.gz does not exist"
	exit -1
endif
cd $perfdir
cp $gtm_test/big_files/profile/v${profileversion}profile.tar.gz .
$tst_gzip -d v${profileversion}profile.tar.gz
tar xf v${profileversion}profile.tar

# setup the environment variables and create dm and drv, modify the global directory.
cd $perfdir
cp $gtm_tst/com/findhost.m .
cp $gtm_tst/com/serverconf.m .
cp $gtm_tst/$tst/inref/*.m .
cp $gtm_tst/$tst/inref/*.gde .
cp $gtm_tst/$tst/u_inref/* .	>>& $testbasedir/cp.outx
source $gtm_tst/$tst/u_inref/gtmenv
#####
rm tmp.profile.gde
if ($?gtm_test_qdbrundown) then
	if ($gtm_test_qdbrundown) then
		echo "template -region -qdbrundown"		>> tmp.profile.gde
		echo "change -region DEFAULT -qdbrundown"	>> tmp.profile.gde
	endif
endif
cat profile.gde > tmp.profile.gde
$GDE @tmp.profile.gde
if ( "ENCRYPT" == $test_encryption) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create
cp $gtm_test/big_files/profile/v${profileversion}gbls.zwr.gz .
$tst_gzip -d v${profileversion}gbls.zwr.gz
$CALIPER $CALIPER_REPORT -o $tst_general_dir/mupip.txt $MUPIP load v${profileversion}gbls.zwr
cd $gblsdir
chmod 775 *.*
cd $perfdir

#this needs to be removed when UTF-8 is handled properly
unsetenv gtm_chset


####
echo '#\!/usr/local/bin/tcsh' >&! dm
echo "setenv testbasedir $tst_general_dir/profile_v${profileversion}" >> dm
echo "setenv profileversion ${profileversion}" >> dm
echo "source gtmenv" >> dm
echo "$gtm_exe/mumps -direct" >> dm
chmod 775 dm
echo '#\!/usr/local/bin/tcsh' >&! drv
echo "setenv testbasedir $tst_general_dir/profile_v${profileversion}" >> drv
echo "setenv profileversion ${profileversion}" >> drv
echo "source gtmenv" >> drv
echo "$gtm_exe/mumps -run SCADRV" >> drv
chmod 775 drv

# Now the profile environment is ready. Apply tests
if ($?test_npeat) then
	@ npeat = $test_npeat
else
	@ npeat = 1
endif

dsrtestcaliper $npeat

touch spool/passorfail.dat
$grep "FAIL" spool/passorfail.dat >& /dev/null
set stat_f=$status
$grep "PASS" spool/passorfail.dat >& /dev/null
set stat_p=$status
if ($stat_f&& $stat_p) then
	echo "FAIL: spool/passorfail.dat is empty."
else
	$grep "FAIL" spool/passorfail.dat
	$grep "PASS" spool/passorfail.dat
endif

$grep -E ".-E-|.-F-" spool/dsrtest.log

if ( -e PROFILE_ERROR.LOG) then
	echo "PROFILE_ERROR.LOG found. Dumping..."
	cat PROFILE_ERROR.LOG
endif

# save results
set timestamp = `date +%Y%m%d_%H%M%S`
set server = "$HOST:r:r"
set save_dir = $gtm_test_log_dir/$server
if (! -d $save_dir) then
   mkdir -p $save_dir
   if ($status) then
      echo "TEST-E-LOGDIR, Could not create log directory $save_dir"  >>! $tst_general_dir/outstream.log
   else
	  chmod 775 $save_dir
   endif
endif
if (! -w $save_dir) then
   echo "TEST-E-LOG, Do not have write permission to log directory $save_dir"
endif
cp -p spool/passorfail.dat $save_dir/result_${timestamp}_v${profileversion}_${gtm_verno}_${tst_image}.txt
# end
