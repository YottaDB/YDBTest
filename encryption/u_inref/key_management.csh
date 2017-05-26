#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#################################################################
# Validate the correct processing of non-trivial conditions
# having to do with GT.M's symmetric key retrieval, storage, and
# management based on the internal knowledge of the code.
#################################################################

$gtm_tst/com/dbcreate.csh mumps 2
mv gtmcrypt.cfg gtmcrypt.cfg.orig

cat > db-a.cfg << EOF
database : {
	keys : ( {
		dat: "$PWD/a.dat";
		key: "$PWD/a_dat_key";
	} );
};
EOF

cat > db-mumps-a.cfg << EOF
database : {
	keys : ( {
		dat: "$PWD/mumps.dat";
		key: "$PWD/mumps_dat_key";
	}, {
		dat: "$PWD/a.dat";
		key: "$PWD/a_dat_key";
	} );
};
EOF

cat > device-a.cfg << EOF
files : {
        a: "a_dat_key";
};
EOF

cat > device-mumps-a.cfg << EOF
files : {
        mumps:	"mumps_dat_key";
        a:	"a_dat_key";
};
EOF

cat > db-mumps-device-a.cfg << EOF
database : {
	keys : ( {
		dat: "$PWD/mumps.dat";
		key: "$PWD/mumps_dat_key";
	} );
};
files : {
        a:	"a_dat_key";
};
EOF

cat > device-mumps-db-a.cfg << EOF
database : {
	keys : ( {
		dat: "$PWD/a.dat";
		key: "$PWD/a_dat_key";
	} );
};
files : {
        mumps:	"mumps_dat_key";
};
EOF

cat > db-a-device-a.cfg << EOF
database : {
	keys : ( {
		dat: "$PWD/a.dat";
		key: "$PWD/a_dat_key";
	} );
};
files : {
        a: "a_dat_key";
};
EOF

cat > db-mumps-duplicate.cfg << EOF
database : {
	keys : ( {
		dat: "$PWD/mumps.dat";
		key: "$PWD/mumps_dat_key";
	}, {
		dat: "$PWD/mumps.dat";
		key: "$PWD/a_dat_key";
	} );
};
EOF

cat > db-mumps.cfg << EOF
database : {
	keys : ( {
		dat: "$PWD/mumps.dat";
		key: "$PWD/mumps_dat_key";
	} );
};
EOF

###################################################################################################################################
# Test case 1.	We skip one of the keys in the configuration file and force the process to read it by doing an update on the region
#		or IO on the device whose key is specified. We then add the missing key to the matching section (database or files)
#		and perform an operation with the newly added key for that section. Since the configuration file has a newer
#		modified date, it should be re-read, and no errors should be given.
###################################################################################################################################

set database = `$gtm_dist/mumps -run rand 2 1 0`
set iv = `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv1.txt

if ($database == 1) then
	set operation = db
else
	set operation = device
endif

cp ${operation}-a.cfg gtmcrypt.cfg
touch gtmcrypt.cfg
($gtm_exe/mumps -run keymanagement 1 $operation a mumps $iv >&! mumps1.out & ; echo $! >! pid1.txt) >&! /dev/null
set pid = `cat pid1.txt`
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps1.out -duration 30 -message "done"
mv gtmcrypt.cfg gtmcrypt.cfg.1.1
cp ${operation}-mumps-a.cfg gtmcrypt.cfg
sleep 1
touch gtmcrypt.cfg
# Trigger $zinterrupt processing in the MUMPS process.
$kill -USR1 $pid
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps1.out -duration 30 -message "done2"
mv gtmcrypt.cfg gtmcrypt.cfg.1.2
$gtm_tst/com/wait_for_proc_to_die.csh $pid 30

###################################################################################################################################
# Test case 2.	We skip one of the keys in the configuration file and force the process to read it by doing an update on the region
#		or IO on the device whose key is specified. We then add the missing key to the other section (database or files)
#		and perform an operation with the newly added key for that section. Since the configuration file has a newer
#		modified date, it should be re-read, and no errors should be given.
###################################################################################################################################

set database = `$gtm_dist/mumps -run rand 2 1 0`
set iv = `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv2.txt

if ($database == 1) then
	set operation = db
	set other = device
else
	set operation = device
	set other = db
endif

cp ${operation}-a.cfg gtmcrypt.cfg
touch gtmcrypt.cfg
($gtm_exe/mumps -run keymanagement 2 $operation a mumps $iv >&! mumps2.out & ; echo $! >! pid2.txt) >&! /dev/null
set pid = `cat pid2.txt`
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps2.out -duration 30 -message "done"
mv gtmcrypt.cfg gtmcrypt.cfg.2.1
cp ${other}-mumps-${operation}-a.cfg gtmcrypt.cfg
sleep 1
touch gtmcrypt.cfg
# Trigger $zinterrupt processing in the MUMPS process.
$kill -USR1 $pid
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps2.out -duration 30 -message "done2"
mv gtmcrypt.cfg gtmcrypt.cfg.2.2
$gtm_tst/com/wait_for_proc_to_die.csh $pid 30

###################################################################################################################################
# Test case 3.	Force the process to read the configuration file and perform an operation involving a particular key. Then remove
# 		that key from the configuration file and retry the operation for the removed key. Since it has been stored in
# 		memory, no errors should occur.
###################################################################################################################################

set database = `$gtm_dist/mumps -run rand 2 1 0`
set iv = `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv3.txt

if ($database == 1) then
	set operation = db
else
	set operation = device
endif

cp ${operation}-mumps-a.cfg gtmcrypt.cfg
touch gtmcrypt.cfg
($gtm_exe/mumps -run keymanagement 3 $operation mumps a $iv >&! mumps3.out & ; echo $! >! pid3.txt) >&! /dev/null
set pid = `cat pid3.txt`
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps3.out -duration 30 -message "done"
mv gtmcrypt.cfg gtmcrypt.cfg.3.1
cp ${operation}-a.cfg gtmcrypt.cfg
sleep 1
touch gtmcrypt.cfg
# Trigger $zinterrupt processing in the MUMPS process.
$kill -USR1 $pid
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps3.out -duration 30 -message "done2"
mv gtmcrypt.cfg gtmcrypt.cfg.3.2
$gtm_tst/com/wait_for_proc_to_die.csh $pid 30

###################################################################################################################################
# Test case 4.	Force the process to read the configuration file and perform an operation involving a particular key. Then remove
# 		a different key (from the same section) from the configuration file and try an operation for the removed key. Since
# 		it has not been stored in memory, we should get an error.
###################################################################################################################################

set database = `$gtm_dist/mumps -run rand 2 1 0`
set iv = `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv4.txt

if ($database == 1) then
	set operation = db
else
	set operation = device
endif

cp ${operation}-mumps-a.cfg gtmcrypt.cfg
touch gtmcrypt.cfg
($gtm_exe/mumps -run keymanagement 4 $operation a mumps $iv >&! mumps4.out & ; echo $! >! pid4.txt) >&! /dev/null
set pid = `cat pid4.txt`
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps4.out -duration 30 -message "done"
mv gtmcrypt.cfg gtmcrypt.cfg.4.1
cp ${operation}-a.cfg gtmcrypt.cfg
sleep 1
touch gtmcrypt.cfg
# Trigger $zinterrupt processing in the MUMPS process.
$kill -USR1 $pid
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps4.out -duration 30 -message "CRYPTKEYFETCHFAILED"
mv gtmcrypt.cfg gtmcrypt.cfg.4.2
$gtm_tst/com/check_error_exist.csh mumps4.out CRYPTKEYFETCHFAILED
$gtm_tst/com/wait_for_proc_to_die.csh $pid 30

###################################################################################################################################
# Test case 5.	Force the process to read the configuration file and perform an operation involving a particular key. Then remove
# 		a different key (from the other section) from the configuration file and try an operation for the removed key.
# 		Since it has not been stored in memory, we should get an error.
###################################################################################################################################

set database = `$gtm_dist/mumps -run rand 2 1 0`
set iv = `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv5.txt

if ($database == 1) then
	set operation = db
	set other = device
else
	set operation = device
	set other = db
endif

cp ${operation}-mumps-${other}-a.cfg gtmcrypt.cfg
touch gtmcrypt.cfg
($gtm_exe/mumps -run keymanagement 5 $operation mumps a $iv >&! mumps5.out & ; echo $! >! pid5.txt) >&! /dev/null
set pid = `cat pid5.txt`
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps5.out -duration 30 -message "done"
mv gtmcrypt.cfg gtmcrypt.cfg.5.1
cp ${operation}-a.cfg gtmcrypt.cfg
sleep 1
touch gtmcrypt.cfg
# Trigger $zinterrupt processing in the MUMPS process.
$kill -USR1 $pid
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps5.out -duration 30 -message "CRYPTKEYFETCHFAILED"
mv gtmcrypt.cfg gtmcrypt.cfg.5.2
$gtm_tst/com/check_error_exist.csh mumps5.out CRYPTKEYFETCHFAILED
$gtm_tst/com/wait_for_proc_to_die.csh $pid 30

###################################################################################################################################
# Test case 6.	Specify the same key for database and device encryption and see if it works.
###################################################################################################################################

set database = `$gtm_dist/mumps -run rand 2 1 0`
set iv = `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv6.txt

if ($database == 1) then
	set operation = db
else
	set operation = device
endif

cp db-a-device-a.cfg gtmcrypt.cfg
touch gtmcrypt.cfg
($gtm_exe/mumps -run keymanagement 6 $operation a a $iv >&! mumps6.out & ; echo $! >! pid6.txt) >&! /dev/null
set pid = `cat pid6.txt`
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps6.out -duration 30 -message "done"
mv gtmcrypt.cfg gtmcrypt.cfg.6.1
$gtm_tst/com/wait_for_proc_to_die.csh $pid 30

###################################################################################################################################
# Test case 7.	Write an encrypted update, then remove the respective database's key from the configuration and specify a different
# 		key file with identical key data for a different database. Try decrypting the update; although a key with the
# 		requisite hash is loaded, it no longer corresponds to the right database, so the operation should fail.
###################################################################################################################################

set iv = `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv7.txt

cp db-mumps-a.cfg gtmcrypt.cfg
touch gtmcrypt.cfg
$gtm_dist/mumps -run %XCMD 'set ^mumps(7)=$horolog'
mv a_dat_key a_dat_key_bak
cp mumps_dat_key a_dat_key
mv gtmcrypt.cfg gtmcrypt.cfg.7.1
cp db-a.cfg gtmcrypt.cfg
sleep 1
touch gtmcrypt.cfg
($gtm_exe/mumps -run keymanagement 7 db mumps a $iv >&! mumps7.out & ; echo $! >! pid7.txt) >&! /dev/null
set pid = `cat pid7.txt`

$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps7.out -duration 30 -message "CRYPTKEYFETCHFAILED"
mv gtmcrypt.cfg gtmcrypt.cfg.7.2
mv a_dat_key_bak a_dat_key
$gtm_tst/com/check_error_exist.csh mumps7.out CRYPTKEYFETCHFAILED
$gtm_tst/com/wait_for_proc_to_die.csh $pid 30

###################################################################################################################################
# Test case 8.	Write an encrypted update, then remove the respective database's key from the configuration and specify a different
# 		key file with identical key data for a device. Try decrypting the update; although a key with the requisite hash is
# 		loaded, it no longer corresponds to the right database, so the operation should fail.
###################################################################################################################################

set iv = `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv8.txt

cp db-mumps-a.cfg gtmcrypt.cfg
touch gtmcrypt.cfg
$gtm_dist/mumps -run %XCMD 'set ^mumps(8)=$horolog'
mv a_dat_key a_dat_key_bak
cp mumps_dat_key a_dat_key
mv gtmcrypt.cfg gtmcrypt.cfg.8.1
cp device-a.cfg gtmcrypt.cfg
sleep 1
touch gtmcrypt.cfg
($gtm_exe/mumps -run keymanagement 8 db mumps a $iv >&! mumps8.out & ; echo $! >! pid8.txt) >&! /dev/null
set pid = `cat pid8.txt`
$gtm_tst/com/wait_for_log.csh -waitcreation -log mumps8.out -duration 30 -message "CRYPTKEYFETCHFAILED"
mv gtmcrypt.cfg gtmcrypt.cfg.8.2
$gtm_tst/com/check_error_exist.csh mumps8.out CRYPTKEYFETCHFAILED
$gtm_tst/com/wait_for_proc_to_die.csh $pid 30

# Not doing a dbcheck.csh since the required key would be missing at this point.
# But do a rundown to clean up the ftok semaphore that would be leftover from the prior CRYPTKEYFETCHFAILED errors
# Even the rundown will get the same error so filter those out.
$MUPIP rundown -reg "*" >& rundown.out
$gtm_tst/com/check_error_exist.csh rundown.out CRYPTKEYFETCHFAILED MUNOTALLSEC >& check_error_rundown.outx
