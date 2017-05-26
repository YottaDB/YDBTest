#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test tries to do a database upgrade from V4 to V5. Since a V4 version will not be supporting encryption, unconditionally turn off
# encryption
setenv test_encryption NON_ENCRYPT

# Basic preparation for the test
source $gtm_tst/$tst/u_inref/endiancvt_prepare.csh

# If a V4 version is not available, disable the below section
if !($?gtm_platform_no_V4) then
	cat << EOF

## create a V4 database
## mupip endiancvt mumps.dat
##      --> Shoud issue "GTM-E-NOENDIANCVT Unable to convert the endian format of the file mumps.dat due to the database not in current version" error
## concurrently run a few updates
## mupip endiancvt mumps.dat
##      --> Shoud issue "GTM-E-NOENDIANCVT Unable to convert the endian format of the file mumps.dat due to the database not in current version" error

EOF
	# On HPPA, we cannot invoke switch_gtm_version unconditionally while V4 IMPTP is in progress as libreverse.sl
	# (if collation is enabled) cannot be removed and hence will cause false test failures. See <endiancvt_DLLNOOPEN>
	# for more information.
	set is_hppa = "FALSE"
	if (("HP-UX" == "$HOSTOS") && ("ia64" != "$MACHTYPE")) then
		set is_hppa = "TRUE"
	endif

	$sv4
	echo "GT.M switched to $v4ver version"
	# priorver.txt is to filter the old version names in the reference file
	echo $v4ver >& priorver.txt
	source $gtm_tst/com/bakrestore_test_replic.csh
	$gtm_tst/com/dbcreate.csh mumps 1 255 1000 $coll_arg
	source $gtm_tst/com/bakrestore_test_replic.csh
	# switch back to V5
	if ("FALSE" == "$is_hppa") $sv5
	$MUPIPV5 endiancvt mumps.dat < yes.txt >>&! endiancvt_try1.out
	$gtm_tst/com/check_error_exist.csh endiancvt_try1.out unrecognizable MUNOACTION
	if ("FALSE" == "$is_hppa") $sv4
	setenv gtm_test_dbfill "SLOWFILL"
	setenv gtm_test_jobcnt 1
	$gtm_tst/com/v4imptp.csh >>&! imptp.out
	if ("FALSE" == "$is_hppa") $sv5
	$MUPIPV5 endiancvt mumps.dat < yes.txt >>&! endiancvt_try2.out
	$gtm_tst/com/check_error_exist.csh endiancvt_try2.out unrecognizable MUNOACTION
	if ("FALSE" == "$is_hppa") $sv4
	$gtm_tst/com/v4endtp.csh >>&! imptp.out

	cat << EOF

# Upgrade the database to V5

EOF

	$sv5
	$gtm_tst/$tst/u_inref/dbcertify.csh
	echo ""
	echo "# mupip reorg upgrade..."
	$MUPIP reorg -upgrade -region DEFAULT >>&! reorg_upgrade.out
	$grep UPGRADE reorg_upgrade.out
	if ($gtm_test_qdbrundown) then
		$MUPIP set -region DEFAULT -qdbrundown >&! set_qdbrundown.out
	endif

	cat << EOF

## concurrently run a few updates
## mupip endiancvt mumps.dat
##      --> Shoud issue MUSTANDALONE error
## stop the updates
## mupip endiancvt mumps.dat
##      --> should be successfull

EOF

	$gtm_tst/com/imptp.csh >>&! imptp_2.out
	$MUPIP endiancvt mumps.dat < yes.txt >>&! endiancvt_try3.out
	$gtm_tst/com/check_error_exist.csh endiancvt_try3.out MUSTANDALONE MUNOACTION
	$gtm_tst/com/endtp.csh >>&! imptp_2.out
	source $gtm_tst/com/bakrestore_test_replic.csh
	$gtm_tst/com/dbcheck.csh
	source $gtm_tst/com/bakrestore_test_replic.csh
	cp mumps.dat mumps.dat_bak
	$MUPIP endiancvt mumps.dat < yes.txt
	echo "# Now copy the database to the remote machine and do an integ check"
	$rcp mumps.dat "$tst_remote_host":$SEC_SIDE/
	$sec_shell "$sec_getenv ; cd $SEC_SIDE ; source coll_env.csh 1 ;$gtm_tst/$tst/u_inref/integ_check.csh mumps.dat"
	$gtm_tst/com/backup_dbjnl.csh section_a '*.gld *.dat' mv
endif

cat << EOF

## b)
## Create a V5 database with GDS blocks bigger than a disk block (512)
##      /* The default blocksize is 1024. So a simple dbcreate would do */
## Set exactly one global
## Note down the size of the database (ls -l)
## \$MUPIP endiancvt mumps.dat -outdb=convert.dat
## check the size of the database (ls -l) of conver.dat matches mumps.dat
## In the other endian machine:
##    \$MUPIP integ convert.dat

EOF

source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcreate.csh mumps $coll_arg
source $gtm_tst/com/bakrestore_test_replic.csh
$GTM <<EOF
set ^oneglobal="check size"
halt
EOF

source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck.csh
source $gtm_tst/com/bakrestore_test_replic.csh
setenv size_before `ls -l mumps.dat | $tst_awk '{print $5}'`
$MUPIP endiancvt mumps.dat -outdb=convert.dat < yes.txt
setenv size_convert `ls -l convert.dat | $tst_awk '{print $5}'`
if ($size_before == $size_convert) then
	echo "TEST-I-SUCCESS the size of the database before and after endiancvt is the same"
else
	echo "TEST-E-SIZE of the database before and after endiancvt differs"
	echo "Actual size : $size_before - Converted size : $size_convert"
endif
echo "# Now copy the database to the remote machine and do an integ check"
$rcp convert.dat "$tst_remote_host":$SEC_SIDE/
$sec_shell "$sec_getenv ; cd $SEC_SIDE ;source coll_env.csh 1; $gtm_tst/$tst/u_inref/integ_check.csh convert.dat"
$gtm_tst/com/backup_dbjnl.csh section_b '*.gld *.dat' mv

cat << EOF

## c) /* Check with a data value that looks like a block pointer */
## Create a V5 database
## set a single global to a value that looks like a block pointer
##      - \$c(0,0,0,1) if machine_host is a big endian machine
##      - \$c(1,0,0,0) if machine_host is a little endian machine
## \$MUPIP endiancvt blkptrdat.dat
## copy blkptrdat.dat to the other endian machine
## In the remote machine:
##    \$MUPIP integ blkptrdat.dat

EOF

source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcreate.csh blkptrdat $coll_arg
setenv gtmgbldir blkptrdat.gld
source $gtm_tst/com/bakrestore_test_replic.csh
if ("BIG_ENDIAN" == "$gtm_endian") then
	# Big Endian
	$GTM << EOF
	set ^fakeptr=\$c(0,0,0,1)
	halt
EOF

else
	# Little Endian
	$GTM << EOF
	set ^fakeptr=\$c(1,0,0,0)
	halt
EOF

endif
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck.csh
source $gtm_tst/com/bakrestore_test_replic.csh
cp blkptrdat.dat blkptrdat.dat_bak
$MUPIP endiancvt blkptrdat.dat < yes.txt
echo "# Now copy the database to the remote machine and do an integ check"
$rcp blkptrdat.dat "$tst_remote_host":$SEC_SIDE/
$sec_shell "$sec_getenv ; cd $SEC_SIDE ;source coll_env.csh 1 ;$gtm_tst/$tst/u_inref/integ_check.csh blkptrdat.dat"
