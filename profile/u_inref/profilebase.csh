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
#this needs to be removed when Profile is compatible with gtm_boolean=1
unsetenv gtm_boolean
#this needs to be removed when Profile is compatible with gtm_side_effects=1 and gtm_boolean=1
unsetenv gtm_side_effects

setenv HOSTNAME $HOST:r:r:r

if (! -d $gtm_test_log_dir) then
	mkdir -p $gtm_test_log_dir
	if ($status) echo "TEST-E-LOGDIR, cannot create log directory $gtm_test_log_dir for test $tst. Will not be able to save logs"
endif

setenv testbasedir $tst_working_dir

# construct the directory structure.
echo '*********** constructing test directories ************'
mkdir SCA
mkdir SCA/obj
mkdir v${profileversion}perf
mkdir v${profileversion}perf/gbls
mkdir v${profileversion}perf/spool
set scadir = "${testbasedir}/SCA"
set perfdir = "${testbasedir}/v${profileversion}perf"
set gblsdir = "${testbasedir}/v${profileversion}perf/gbls"

# restore from tar files
echo '********** restoring source and database from tar files **********'

set platform = $gtm_test_osname
if ("$gtm_test_osname" == "aix") then
	set osver=$gtm_test_osver
	# handle AIX 6
	if ($gtm_test_osver > 4) then
		set osver=5
	endif
	set platform = "$gtm_test_osname.$osver"
else if ("$gtm_test_osname" == "hp-ux") then
	if ($profileversion == "734") then # for now we are using the existing SCA
		set platform = "v70.$gtm_test_osname.$gtm_test_machtype"
	else
		set platform = "v$profileversion.$gtm_test_osname.$gtm_test_machtype"
	endif
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
#cat $gtm_test/big_files/profile/v${profileversion}profile.tar.gz| $tst_gzip -d - | tar x
cp $gtm_test/big_files/profile/v${profileversion}profile.tar.gz .
$tst_gzip -d v${profileversion}profile.tar.gz
tar xf v${profileversion}profile.tar

# hook up to the desired GT.M version
ln -s -f $gtm_exe $perfdir/gtm_dist
ln -s -f $gtm_exe $scadir/gtm_dist

# setup the environment variables and create dm and drv, modify the global directory.
cd $perfdir
cp $gtm_tst/com/findhost.m .
cp $gtm_tst/com/serverconf.m .
cp $gtm_tst/profile/inref/*.m .
cp $gtm_tst/profile/inref/*.gde .
cp $gtm_tst/profile/u_inref/* .		>>& $testbasedir/cp.outx
if ($profileversion == "734") then
	source $gtm_tst/profile/u_inref/gtmenv734
	setenv gtmroutines "$gtmroutines $perfdir"
else
	source $gtm_tst/profile/u_inref/gtmenv
endif
# Fix up the PATH on pre-11 Solaris so we get the proper "date" command
# This can be removed once all the pre-11 Solaris boxes are gone
if (("$gtm_test_osname" == "sunos") && ("5.10" == `uname -r`)) then
	setenv PATH "/usr/local/bin:$PATH"
endif
# keep the paths to gtm_tmp and gtm_log short, i.e., less than the system specific sun_path length
mkdir /tmp/gtm_profile_$$
setenv gtm_tmp /tmp/gtm_profile_$$
setenv gtm_log /tmp/gtm_profile_$$

setenv >profileenv.txt
#####
echo "! -qdbrundown if applicable"				> tmpprofile.gde
if ($?gtm_test_qdbrundown) then
	if ($gtm_test_qdbrundown) then
		echo "template -region -qdbrundown"		>> tmpprofile.gde
		echo "change -region DEFAULT -qdbrundown"	>> tmpprofile.gde
	endif
endif
cat profile.gde >> tmpprofile.gde
$GDE @tmpprofile.gde >&! gde.out
if ("ENCRYPT" == "$test_encryption" ) then
	cp $gtm_tst/com/CONVDBKEYS.m mrtns
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
	setenv gtmcrypt_config `pwd`/gtmcrypt.cfg
	setenv gtmcrypt_config_pri $gtmcrypt_config
	setenv gtmcrypt_config_sec `pwd`/gtmcrypt.cfg.sec
	sed 's|v734perf/gbls|v734perf/secondary/gbls|' ${gtmcrypt_config} >& ${gtmcrypt_config}.sec
endif
$MUPIP create
if ( ! -e $gtm_test/big_files/profile/v${profileversion}gbls.zwr.gz ) then
	echo "$gtm_test/big_files/profile/v${profileversion}gbls.zwr.gz does not exist"
	exit -1
endif

# if not told otherwise assume default number of accounts which is 100K
if (! $?profileaccounts) setenv profileaccounts ""

# instead of copying, gunziping and loading directly load from the gunzip
mkfifo tmpfifo
(cat $gtm_test/big_files/profile/v${profileversion}${profileaccounts}gbls.zwr.gz | $tst_gzip -d - > tmpfifo &)
$MUPIP load tmpfifo
rm tmpfifo

cd $gblsdir
chmod 775 *.*

if ($?test_replic) then
	# Create replicated secondary environment and start replication servers
	setenv PRI_SIDE $perfdir
	setenv SEC_SIDE $PRI_SIDE/secondary
	source $gtm_tst/com/portno_acquire.csh >>& $perfdir/portno.out

	mkdir $SEC_SIDE
	cd $SEC_SIDE
	if ("ENCRYPT" == "$test_encryption" ) then
		# use gtmcrypt_config for secondary database
		setenv gtmcrypt_config $gtmcrypt_config_sec
	endif
	mkdir gbls
	cp -p $PRI_SIDE/gbls/* gbls
	setenv gtmgbldir ${SEC_SIDE}/gbls/mumps.gld
	setenv mumps_tbls ${SEC_SIDE}/gbls/mumps.tbls
	setenv mumps_ttx ${SEC_SIDE}/gbls/mumps.ttx
	setenv mumps_ubg ${SEC_SIDE}/gbls/mumps.ubg
	mkdir replic
	cd replic
	setenv gtm_repl_instance ${SEC_SIDE}/mumps.repl
	$MUPIP replicate -instance -name=INSTB $gtm_test_qdbrundown_parms
	$MUPIP set -replication=on -reg "*" >& ${SEC_SIDE}/replon.log
	$MUPIP replic -source -start -passive -log=passive_source.log -buf=$tst_buffsize -instsecondary=INSTA
	$MUPIP replic -receiv -start -listen=$portno -log=receiver.log -buf=$tst_buffsize
	cd ..

	cd $PRI_SIDE
	if ("ENCRYPT" == "$test_encryption" ) then
		# switch back to use gtmcrypt_config for primary database
		setenv gtmcrypt_config $gtmcrypt_config_pri
	endif
	mkdir replic
	setenv gtmgbldir ${PRI_SIDE}/gbls/mumps.gld
	setenv mumps_tbls ${PRI_SIDE}/gbls/mumps.tbls
	setenv mumps_ttx ${PRI_SIDE}/gbls/mumps.ttx
	setenv mumps_ubg ${PRI_SIDE}/gbls/mumps.ubg
	cd replic
	setenv gtm_repl_instance ${PRI_SIDE}/mumps.repl
	$MUPIP replicate -instance -name=INSTA $gtm_test_qdbrundown_parms
	$MUPIP set -replication=on -reg "*" >& ${PRI_SIDE}/replon.log
	mupip replic -source -start -secondary=${HOST}:$portno -log=source.log -buf=$tst_buffsize -instsecondary=INSTB
else
	# Since test is not run with -replic, no point keeping gtm_custom_errors defined as that might cause FTOKERR/ENO2 errors
	# due to non-existent instance file.
	unsetenv gtm_custom_errors
endif

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

if ($profileaccounts == "") then # if default number of accounts then indicate 100K
	setenv numaccts 100K
else
	setenv numaccts $profileaccounts

endif

dsrtest $npeat

if ($?test_replic) then
	setenv gtm_repl_instance ${PRI_SIDE}/mumps.repl
	setenv gtm_test_instsecondary ""
	$gtm_tst/com/wait_until_src_backlog_below.csh 0
	$MUPIP replic -source -shutdown -time=0 >& ${PRI_SIDE}/srcshut.log
	if ($status != 0) then
		echo "PROFILEBASE-E-SRCSHUT : MUPIP REPLIC -SOURCE -SHUT -TIME=0 on Primary returned status $status."
	endif

	setenv gtm_repl_instance ${SEC_SIDE}/mumps.repl
	$gtm_tst/com/wait_until_rcvr_backlog_clear.csh
	$MUPIP replic -receiv -shutdown -time=0 >& ${SEC_SIDE}/rcvrshut.log
	if ($status != 0) then
		echo "PROFILEBASE-E-SRCSHUT : MUPIP REPLIC -receiv -SHUT -TIME=0 on Secondary returned status $status."
	endif
	$MUPIP replic -source -shutdown -time=0 >& ${SEC_SIDE}/srcshut.log
	if ($status != 0) then
		echo "PROFILEBASE-E-SRCSHUT : MUPIP REPLIC -SOURCE -SHUT -TIME=0 on Secondary returned status $status."
	endif

	# Do database extract and check if both primary and secondary have same data.
	# Cannot use dbcheck.csh because the remote side directory does not follow regular test system framework conventions.
	setenv gtmgbldir ${SEC_SIDE}/gbls/mumps.gld
	$gtm_tst/com/db_extract.csh sec.glo
	setenv gtmgbldir ${PRI_SIDE}/gbls/mumps.gld
	$gtm_tst/com/db_extract.csh pri.glo
	$tst_cmpsilent pri.glo sec.glo
	set diffstat = $status
	if ($diffstat != 0) then
		echo "TEST-E-FAILED: DATABASE EXTRACTs on PRIMARY and SECONDARY are DIFFERENT. diff in $PRI_SIDE/glo.glodiff"
		diff pri.glo sec.glo >& $PRI_SIDE/glo.glodiff
	else
		echo "DATABASE EXTRACT PASSED"
	endif
	# Remove port allocation file now that we are done using it.
	$gtm_tst/com/portno_release.csh
endif

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

egrep ".-E-|.-F-" spool/dsrtest.log

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
cp -p spool/passorfail.dat $save_dir/result_${timestamp}_v${profileversion}_${numaccts}_${gtm_verno}_${tst_image}.txt
rm -rf /tmp/gtm_profile_$$
# end
