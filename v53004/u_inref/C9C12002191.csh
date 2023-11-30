#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test exercises the security changes which may modify group and mode for created journal files, backup temp files,
# shared memory, private semaphores - depending upon database settings and user membership in the database and/or the
# distribution group.  There are 5 major tests below (labeled test1 - test5) and the description of the state and
# expected results are provided as output to the test log in each case.
#
# In addition, the gtm_secshr socket's owner and mode are changed if the database distribution is restricted.  There are
# 2 tests for this change.  The first occurs during test1(non-restricted distribution) and the second occurs after
# test5(restricted distribution).  The actual output of commands such as ls and ipcs vary across platforms so have to be
# resolved in scripts such as, check_ipcsperm.csh.

# The lowercase version of the below groups/users should be kept in sync with the list in IGS.c
## Set the uid and gid environment variables
set tst_user = $USER
set tst_group = "gtc"
set tst_group1 = "gtcnot"
set tst_group3 = "gtmsec"

# on z/OS the user/group is upper case
if ( "os390" == $gtm_test_osname ) then
	set tst_group = "GTC"
	set tst_group1 = "GTCNOT"
	set tst_group3 = "GTMSEC"
endif
##

# Check for the assumptions about users and groups
# $tst_user SHOULD be part of $tst_group and $tst_group3

id >>&! check_groups.out
if ( "os390" != $gtm_test_osname ) then
	groups >>&! check_groups.out
else
	id -Gn >>&! check_groups.out
endif

$grep "$tst_group"  check_groups.out >&! /dev/null
if ($status) then
	echo "TEST-E-GROUPS. $tst_user is NOT part of $tst_group which is a requirement for this test"
	exit 1
endif
$grep "$tst_group3" check_groups.out >&! /dev/null
if ($status) then
	echo "TEST-E-GROUPS. $tst_user is NOT part of $tst_group3 which is a requirement for this test"
	exit 1
endif

# The max value of gtmsecshr_sock_name on various platforms
## 92 atlhxit1
## 92 atlhxit2
## 104 lespaul
## >= 108 <all others>

# Obtain MAX_SOCKFILE_NAME_LEN from gtmsecshr.h and subtract it from the above values
# gtmsecshr is coded not to start if the length of $gtm_tmp is greater than that
# Statement below is length of "gtm_secshr" - 2 (quotes) + 10 (max pid digits) + 1 (null terminator)
set sockfile_name_len = `$tst_awk '/#define *GTMSECSHR_SOCK_PREFIX/ {print length($NF) - 2 + 10 + 1}' $gtm_inc/gtmsecshr.h`
if ( "hp-ux"  == "$gtm_test_osname" ) then
	@ maxvalue = 92 - $sockfile_name_len
else if ("aix" == "$gtm_test_osname") then
	@ maxvalue = 104 - $sockfile_name_len
else
	@ maxvalue = 108 - $sockfile_name_len
endif

# try to use pwd/t as gtm_tmp dir. If it exceeds acceptable limit, use /tmp/${USER}_C9C12002191_${tst_image} instead
mkdir t ; cd t
set pwdlen = `pwd | wc -c`
if ($pwdlen > $maxvalue) then
	setenv gtm_tmp /tmp/${USER}_C9C12002191_${tst_image}
	# remove the directory if it exists first
	if ( -d $gtm_tmp ) then
		rm -rf $gtm_tmp
	endif
else
	setenv gtm_tmp `pwd`
endif
cd - ; rm -rf t
set tempdir = "$gtm_tmp"
mkdir $tempdir

# Make a temporary version first
set tempver = "${tst_ver}_C9C12002191_$$"


# modify cleanup.csh to remove temporary version if it still exists during analyst cleanup
echo "if (-d $gtm_root/$tempver) ssh -l $USER $HOST $cms_tools/rmver.csh $tempver" >> ../cleanup.csh
# create a directory with same name as $tempver so warn can determine if a test is still using the $tempver build
mkdir $tempver

$cms_tools/newincver.csh $tst_ver $tempver >&! newincver.out
set newincverstat = $status
if ($newincverstat) then
	echo "TEST-E-NEWINCVER failed. No point in proceeding further. Check newincver.out"
	exit 1
endif

# Since we switch to another version that supports encryption, the encryption key won't work.
# Hence turn off encryption here.
if ($?test_encryption) then
	set save_test_encryption = $test_encryption
	setenv test_encryption NON_ENCRYPT
endif
source $gtm_tst/com/switch_gtm_version.csh $tempver $tst_image

umask 000

set line = "######################################################################################"

if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv libext sl
else if ("HOST_OS390_S390" == "$gtm_test_os_machtype") then
	setenv libext dll
else
	setenv libext so
endif

$gtm_tst/com/dbcreate.csh mumps 1 255 1000 >&! dbcreate.out
cp mumps.gld bak_mumps.gld
cp mumps.dat bak_mumps.dat
echo "# create a small database"
$GTM << EOF
set val="abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz"
for i=1:1:1000 s ^a(i)=val s ^b(i)=val
EOF

cp mumps.dat large_mumps.dat

rm -f *.o >& /dev/null

echo

chmod 775 $gtm_dist/libyottadb.$libext
chgrp $tst_group $gtm_dist/libyottadb.$libext


#test 1
echo $line
set tstno = 1
echo "**** test1 ****"
echo "** database is world writeable"
echo '** process uid $tst_user is a member of database group $tst_group'
echo '** database group $tst_group is unchanged.  and 666 with default database permission of 666'
echo

$MUPIP set -journal=enable,on,nobefore -region "*" >>&! set_jnl_${tstno}.out
$gtm_dist/mumps -dir >& gtm_${tstno}.out <<here
set ^a=1
zsystem "$gtm_tst/com/ipcs -c > ipcs_full_${tstno}.out"
here

echo "# Check the permissions of ipcs. Expect the below"
echo '# 269287425  666        $tst_user   $tst_group        $tst_user   $tst_group       '
if ("$gtm_test_osname" == "linux") then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out "666:${tst_user}:${tst_group}:${tst_user}:${tst_group}"
else if (("$gtm_test_osname" == "hp-ux") || ("aix" == "$gtm_test_osname") || ("sunos" == "$gtm_test_osname") || \
		("osf1" == "$gtm_test_osname") || ("os390" == $gtm_test_osname)) then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out \
		"--ra-ra-ra-:${tst_user}:${tst_group}:${tst_user}:${tst_group}" \
		"--rw-rw-rw-:${tst_user}:${tst_group}:${tst_user}:${tst_group}"
else
endif
echo ""
echo "# Check permissions of libyottadb. Expect the below"
echo '# -rwxrwxr-x 1 $tst_user $tst_group 14740547 Jun 17 11:25 libyottadb.xx'
$gtm_tst/$tst/u_inref/check_fileperm.csh $gtm_dist/libyottadb.$libext "-rwxrwxr-x:${tst_user}:${tst_group}"
echo ""
echo "# Check the permissions of database file. Expect the below"
echo '# -rw-rw-rw- 1 $tst_user $tst_group 169472 Jun 18 05:29 mumps.dat'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.dat "-rw-rw-rw-:${tst_user}:${tst_group}"
echo ""
echo "# Check the permissions of journal file. Expect the below"
echo '# -rw-rw-rw- 1 $tst_user $tst_group .... ... .. ..... mumps.mjl'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.mjl "-rw-rw-rw-:${tst_user}:${tst_group}"
echo ""
echo "**** show gtmsecshr client socket for group unrestricted distribution, libyottadb.xx mode = 775 ****"
chmod 444 mumps.dat
$gtm_dist/mumps -dir >& gtm_gtmsecshr_${tstno}.outx <<here
set ^a=1
zsystem "ls -al ${tempdir}/gtm_s* "
here

echo "# Check the permissions of gtm_secshr* file. Expect the below"
set actual = `$tst_awk '{if (5<NF) {if ("'$tst_user'" == $3) print $1":"$3":"$4} }' gtm_gtmsecshr_${tstno}.outx`
if ("os390" == $gtm_test_osname) then
	echo '# crw-rw---- 1 $tst_user   $tst_group  0 Jun  5 13:54 /tmp/gtm_secshr0000669C'
	set expected = "crw-rw----:${tst_user}:${tst_group}"
else
	echo '# srwxrwxrwx 1 $tst_user   $tst_group  0 Jun  5 13:54 /tmp/gtm_secshr0000669C'
	set expected = "srwxrwxrwx:${tst_user}:${tst_group}"
endif
if ("$expected" == "$actual") then
	echo "TEST-I-PASS file permissions of gtm_secshr are as expected"
else
	echo "TEST-E-FAIL file permissions of gtm_secshr are not as expected"
	echo "The expected permissions are $expected, but the actual are $actual"
	echo "Check gtm_gtmsecshr_${tstno}.outx"
endif
echo ""

#do the backup
echo "# Perform mupip backup and check file permissions"
echo "# Expect same ownership and permissions as for the mumps.mjl above"

rm -f mumps.dat mumps.gld >& /dev/null
cp bak_mumps.gld mumps.gld
cp large_mumps.dat mumps.dat ; chmod 666 mumps.dat
mkdir bb_$tstno
$MUPIP backup "*" bb_$tstno/ >>& backup_${tstno}.out
echo ""
echo "# Check the permissions of the backed-up file"
$gtm_tst/$tst/u_inref/check_fileperm.csh bb_${tstno}/mumps.dat "-rw-rw-rw-:${tst_user}:${tst_group}"
echo ""
echo ""
#test 2
echo $line
@ tstno ++
echo "**** test2 ****"
echo '** database uid $tst_user is a member of database group $tst_group'
echo '** process uid $tst_user is a member of database group $tst_group'
echo '** set group to database group $tst_group, and 770 with database permission 644'
echo
rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld ; cp bak_mumps.dat mumps.dat ; chmod 666 mumps.dat
chmod 644 mumps.dat
$MUPIP set -journal=enable,on,nobefore -region "*" >& set_jnl_${tstno}.out
$gtm_dist/mumps -dir >& gtm_${tstno}.out <<here
set ^a=1
zsystem "$gtm_tst/com/ipcs -c > ipcs_full_${tstno}.out"
here

echo "# Check the permissions of ipcs. Expect the below"
echo '# 269615105  666        $tst_user   $tst_group        $tst_user   $tst_group       '
if ("$gtm_test_osname" == linux) then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out "666:${tst_user}:${tst_group}:${tst_user}:${tst_group}"
else if (("$gtm_test_osname" == "hp-ux") || ("aix" == "$gtm_test_osname") || ("sunos" == "$gtm_test_osname") || \
		("osf1" == "$gtm_test_osname") || ("os390" == $gtm_test_osname)) then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out \
		"--ra-ra-ra-:${tst_user}:${tst_group}:${tst_user}:${tst_group}" \
		"--rw-rw-rw-:${tst_user}:${tst_group}:${tst_user}:${tst_group}"
endif
echo ""
echo "# Check permissions of libyottadb. Expect the below"
echo '# -rwxrwxr-x 1 $tst_user $tst_group 14740547 Jun 17 11:25 libyottadb.xx'
$gtm_tst/$tst/u_inref/check_fileperm.csh $gtm_dist/libyottadb.$libext "-rwxrwxr-x:${tst_user}:${tst_group}"
echo ""
echo "# Check the permissions of database file. Expect the below"
echo '# -rw-r--r-- 1 $tst_user $tst_group 169472 Jun 18 05:29 mumps.dat'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.dat "-rw-r--r--:${tst_user}:${tst_group}"
echo
echo "# Check the permissions of journal file. Expect the below"
echo '# -rw-r--r-- 1 $tst_user $tst_group .... ... .. ..... mumps.mjl'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.mjl "-rw-r--r--:${tst_user}:${tst_group}"
echo ""

#do the backup
echo "# Perform mupip backup and check file permissions"
echo "# Expect same ownership and permissions as for the mumps.mjl above"

rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld ; cp bak_mumps.dat mumps.dat ; chmod 666 mumps.dat
cp large_mumps.dat mumps.dat
chmod 644 mumps.dat
mkdir bb_$tstno
$MUPIP backup "*" bb_$tstno/ >>& backup_${tstno}.out
echo ""
echo "# Check the permissions of the backed-up file"
$gtm_tst/$tst/u_inref/check_fileperm.csh bb_${tstno}/mumps.dat "-rw-r--r--:${tst_user}:${tst_group}"
echo ""
echo ""
#test 3
echo $line
@ tstno ++
echo "**** test3 ****"
echo "** database is not world writeable"
echo '** database uid $tst_user is not a member of database group $tst_group1'
echo '** database uid $tst_user is a member of distribution group $tst_group'
echo '** process uid $tst_user is a member of distribution group $tst_group'
echo '** set group to distribution group $tst_group, set database permission to 644'
echo
rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld ; cp bak_mumps.dat mumps.dat
$gtm_com/IGS mumps.dat CHOWN $tst_user $tst_group1
chmod 644 mumps.dat
$MUPIP set -journal=enable,on,nobefore -region "*" >& set_jnl_${tstno}.out
$gtm_dist/mumps -dir >& gtm_${tstno}.out <<here
set ^a=1
zsystem "$gtm_tst/com/ipcs -c > ipcs_full_${tstno}.out"
here

echo "# Check the permissions of ipcs. Expect the below"
echo '# 269713409  666        $tst_user   $tst_group        $tst_user   $tst_group       '
if ("$gtm_test_osname" == linux) then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out "666:${tst_user}:${tst_group}:${tst_user}:${tst_group}"
else if (("$gtm_test_osname" == "hp-ux") || ("aix" == "$gtm_test_osname") || ("sunos" == "$gtm_test_osname") || \
		("osf1" == "$gtm_test_osname") || ("os390" == $gtm_test_osname)) then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out \
		"--ra-ra-ra-:${tst_user}:${tst_group}:${tst_user}:${tst_group}" \
		"--rw-rw-rw-:${tst_user}:${tst_group}:${tst_user}:${tst_group}"
endif
echo ""
echo "# Check permissions of libyottadb. Expect the below"
echo '# -rwxrwxr-x 1 $tst_user $tst_group 14740547 Jun 17 11:25 libyottadb.xx'
$gtm_tst/$tst/u_inref/check_fileperm.csh $gtm_dist/libyottadb.$libext "-rwxrwxr-x:${tst_user}:${tst_group}"
echo ""
echo "# Check the permissions of database file. Expect the below"
echo '# -rw-r--r-- 1 $tst_user $tst_group1 169472 Jun 18 05:30 mumps.dat'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.dat "-rw-r--r--:${tst_user}:${tst_group1}"
echo
echo "# Check the permissions of journal file. Expect the below"
echo '# -rw-r--r-- 1 $tst_user $tst_group .... ... .. ..... mumps.mjl'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.mjl "-rw-r--r--:${tst_user}:${tst_group}"
echo ""

#do the backup
echo "# Perform mupip backup and check file permissions"
echo "# Expect same ownership and permissions as for the mumps.mjl above"

rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld
cp large_mumps.dat mumps.dat
$gtm_com/IGS mumps.dat CHOWN $tst_user $tst_group1
chmod 644 mumps.dat
mkdir bb_$tstno
$MUPIP backup "*" bb_$tstno/ >>& backup_${tstno}.out
echo ""
echo "# Check the permissions of the backed-up file"
$gtm_tst/$tst/u_inref/check_fileperm.csh bb_${tstno}/mumps.dat "-rw-r--r--:${tst_user}:${tst_group}"
echo ""
echo ""


#test 4
echo $line
@ tstno ++
echo "**** test4 ****"
echo "** database is not world writeable"
echo '** database uid $tst_user is a member of database group $tst_group3'
echo '** process uid $tst_user is a member of database group $tst_group3'
echo '** set group to database group $tst_group3, and 770 with database permission 664'
echo
rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld ; cp bak_mumps.dat mumps.dat
chown ${tst_user}:$tst_group3 mumps.dat
chmod 664 mumps.dat
$MUPIP set -journal=enable,on,nobefore -region "*" >& set_jnl_${tstno}.out
$gtm_dist/mumps -dir >& gtm_${tstno}.out <<here
set ^a=1
zsystem "$gtm_tst/com/ipcs -c > ipcs_full_${tstno}.out"
here

echo "# Check the permissions of ipcs. Expect the below"
echo '# 269811713  666        $tst_user   $tst_group        $tst_user   $tst_group3 '
if ("$gtm_test_osname" == linux) then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out "666:${tst_user}:${tst_group}:${tst_user}:${tst_group3}"
else if (("$gtm_test_osname" == "hp-ux") || ("aix" == "$gtm_test_osname") || ("sunos" == "$gtm_test_osname") || \
		("osf1" == "$gtm_test_osname") || ("os390" == $gtm_test_osname)) then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out \
		"--ra-ra-ra-:${tst_user}:${tst_group3}:${tst_user}:${tst_group}" \
		"--rw-rw-rw-:${tst_user}:${tst_group3}:${tst_user}:${tst_group}"
endif
echo ""
echo "# Check permissions of libyottadb. Expect the below"
echo '# -rwxrwxr-x 1 $tst_user $tst_group 14740547 Jun 17 11:25 libyottadb.xx'
$gtm_tst/$tst/u_inref/check_fileperm.csh $gtm_dist/libyottadb.$libext "-rwxrwxr-x:${tst_user}:${tst_group}"
echo ""
echo "# Check the permissions of database file. Expect the below"
echo '# -rw-rw-r-- 1 $tst_user $tst_group3 169472 Jun 18 05:30 mumps.dat'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.dat "-rw-rw-r--:${tst_user}:${tst_group3}"
echo
echo "# Check the permissions of journal file. Expect the below"
echo '# -rw-rw-r-- 1 $tst_user $tst_group3 .... ... .. ..... mumps.mjl'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.mjl "-rw-rw-r--:${tst_user}:${tst_group3}"
echo ""

#do the backup
echo "# Perform mupip backup and check file permissions"
echo "# Expect same ownership and permissions as for the mumps.mjl above"

rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld
cp large_mumps.dat mumps.dat
chown ${tst_user}:$tst_group3 mumps.dat
chmod 664 mumps.dat
mkdir bb_$tstno
$MUPIP backup "*" bb_$tstno/ >>& backup_${tstno}.out
echo ""
echo "# Check the permissions of the backed-up file"
$gtm_tst/$tst/u_inref/check_fileperm.csh bb_${tstno}/mumps.dat "-rw-rw-r--:${tst_user}:${tst_group3}"
echo ""
echo ""


#test 5
echo $line
@ tstno ++
echo "**** test5 ****"
echo "** database is not world writeable"
echo '** database uid $tst_user is not a member of database group $tst_group1'
echo '** database uid $tst_user is a member of distribution group $tst_group3'
echo '** process uid $tst_user is a member of distribution group $tst_group3'
echo '** set group to distribution group $tst_group3, set database permission to 664'
echo
rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld ; cp bak_mumps.dat mumps.dat
$gtm_com/IGS mumps.dat CHOWN $tst_user $tst_group1
chmod 664 mumps.dat
chown ${tst_user}:$tst_group3 $gtm_dist/libyottadb.$libext
$MUPIP set -journal=enable,on,nobefore -region "*" >& set_jnl_${tstno}.out
$gtm_dist/mumps -dir >& gtm_${tstno}.out <<here
set ^a=1
zsystem "$gtm_tst/com/ipcs -c > ipcs_full_${tstno}.out"
here

echo "# Check the permissions of ipcs. Expect the below"
echo '#269910017  666        $tst_user   $tst_group        $tst_user   $tst_group3 '
if ("$gtm_test_osname" == linux) then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out "666:${tst_user}:${tst_group}:${tst_user}:${tst_group}"
else if (("$gtm_test_osname" == "hp-ux") || ("aix" == "$gtm_test_osname") || ("sunos" == "$gtm_test_osname") || \
		("osf1" == "$gtm_test_osname") || ("os390" == $gtm_test_osname)) then
	$gtm_tst/$tst/u_inref/check_ipcsperm.csh ipcs_full_${tstno}.out \
		"--ra-ra-ra-:${tst_user}:${tst_group}:${tst_user}:${tst_group}" \
		"--rw-rw-rw-:${tst_user}:${tst_group}:${tst_user}:${tst_group}"
endif
echo ""
echo "# Check permissions of libyottadb. Expect the below"
echo '# -rwxrwxr-x 1 $tst_user $tst_group3 14740547 Jun 17 11:25 libyottadb.xx'
$gtm_tst/$tst/u_inref/check_fileperm.csh $gtm_dist/libyottadb.$libext "-rwxrwxr-x:${tst_user}:${tst_group3}"
echo ""
echo "# Check the permissions of database file. Expect the below"
echo '# -rw-rw-r-- 1 $tst_user $tst_group1 169472 Jun 18 05:30 mumps.dat'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.dat "-rw-rw-r--:${tst_user}:${tst_group1}"
echo
echo "# Check the permissions of journal file. Expect the below"
echo '# -rw-rw-rw- 1 $tst_user $tst_group .... ... .. ..... mumps.mjl'
$gtm_tst/$tst/u_inref/check_fileperm.csh mumps.mjl "-rw-rw-rw-:${tst_user}:${tst_group}"
echo ""

#do the backup
echo "# Perform mupip backup and check file permissions"
echo "# Expect same ownership and permissions as for the mumps.mjl above"

rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld ; cp bak_mumps.dat mumps.dat
cp large_mumps.dat mumps.dat
$gtm_com/IGS mumps.dat CHOWN $tst_user $tst_group1
chmod 664 mumps.dat
mkdir bb_$tstno
$MUPIP backup "*" bb_$tstno/ >>& backup_${tstno}.out
echo ""
echo "# Check the permissions of the backed-up file"
$gtm_tst/$tst/u_inref/check_fileperm.csh bb_${tstno}/mumps.dat "-rw-rw-rw-:${tst_user}:${tst_group}"
echo ""

chmod 770 $gtm_dist/libyottadb.$libext
$gtm_com/IGS $gtm_dist/libyottadb.$libext CHOWN $tst_user $tst_group3
rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld ; cp bak_mumps.dat mumps.dat ; chmod 444 mumps.dat


echo "**** show gtmsecshr client socket for group restricted distribution, libyottadb.xx mode = 770 ****"
chmod 444 mumps.dat
$gtm_dist/mumps -dir >& gtm_gtmsecshr_${tstno}.outx <<here
set ^a=1
zsystem "ls -al ${tempdir}/gtm_s* "
here

echo "# Check the permissions of gtm_secshr* file. Expect the below"
set actual = `$tst_awk '{if (5<NF) {if ("'$tst_user'" == $3) print $1":"$3":"$4} }' gtm_gtmsecshr_${tstno}.outx`
if ("os390" == $gtm_test_osname) then
	echo '# crw-rw---- 1 $tst_user   $tst_group3  0 Jun  5 13:54 /tmp/gtm_secshr0000669C'
	set expected = "crw-rw----:${tst_user}:${tst_group3}"
else
	echo '# srw-rw---- 1 $tst_user   $tst_group3  0 Jun  5 13:54 /tmp/gtm_secshr0000669C'
	set expected = "srw-rw----:${tst_user}:${tst_group3}"
endif
if ("$expected" == "$actual") then
	echo "TEST-I-PASS file permissions of gtm_secshr are as expected"
else
	echo "TEST-E-FAIL file permissions of gtm_secshr is not as expected"
	echo "The expected permissions are $expected, but the actual is $actual"
	echo "Check gtm_gtmsecshr_${tstno}.outx"
endif
echo ""


echo "# set the permissions of libyottadb right"
chown ${tst_user}:$tst_group $gtm_dist/libyottadb.$libext
chmod 775 $gtm_dist/libyottadb.$libext
echo ""
echo ""


#test 6
echo $line
@ tstno ++
echo "**** test6 ****"
echo "** This test verifies that the system does not crash if the setuid bit"
echo "** is missing on gtmsecshrdir and gtmsecshrdir/gtmsecshr itself."
echo '** The reason for including this test in the security-related test suite is'
echo '** that we already do a newincver, and there is no point in wasting extra space.'
echo

rm -f mumps.dat mumps.gld
cp bak_mumps.gld mumps.gld ; cp bak_mumps.dat mumps.dat

chmod 444 mumps.dat

$gtm_com/IGS $gtm_dist/gtmsecshrdir UNSETUID
$gtm_dist/mumps -dir >& gtm_${tstno}.outx <<here
set ^a=1
here

set curdir = `pwd`

echo "# Check the content of gtm_${tstno}.outx. Expect the below"
# notice no gtm error prefix below -- to avoid a false test failure
echo '# YDB> DBPRIVERR, No privilege for attempted update operation for file: ${curdir}/mumps.dat YDB>'

set actual = `cat gtm_${tstno}.outx`
set expected = "YDB> %YDB-E-DBPRIVERR, No privilege for attempted update operation for file: ${curdir}/mumps.dat YDB>"

if ("$expected" == "$actual") then
	echo "TEST-I-PASS the system gave us the correct warning message"
else
	echo "TEST-E-FAIL the warning message was not as expected"
	echo "The expected message is\n $expected,\nbut the actual is\n $actual"
	echo "Check gtm_${tstno}.outx"
endif
echo ""
echo ""


#test 7
echo $line
@ tstno ++
echo "**** test7 ****"
echo "** This test verifies that the system does not crash if the setuid bit"
echo "** is missing on gtmsecshr, gtmsecshrdir, and gtmsecshrdir/gtmsecshr itself."
echo '** The reason for including this test in the security-related test suite is'
echo '** that we already do a newincver, and there is no point in wasting extra space.'
echo

# rm -f mumps.dat mumps.gld
# cp bak_mumps.gld mumps.gld ; cp bak_mumps.dat mumps.dat

chmod 444 mumps.dat

$gtm_com/IGS $gtm_dist/gtmsecshr UNSETUID
$gtm_dist/mumps -dir >& gtm_${tstno}.outx <<here
set ^a=1
here

echo "# Check the content of gtm_${tstno}.outx. Expect the below"
# notice no gtm error prefix below -- to avoid a false test failure
echo '# YDB> GTMSECSHRPERM, The gtmsecshr module in $gtm_dist does not have the correct permission and uid YDB>'

set actual = `cat gtm_${tstno}.outx`
set expected = 'YDB> %YDB-E-GTMSECSHRPERM, The gtmsecshr module in $gtm_dist does not have the correct permission and uid YDB>'

if ("$expected" == "$actual") then
	echo "TEST-I-PASS the system gave us the correct warning message"
else
	echo "TEST-E-FAIL the warning message was not as expected"
	echo "The expected message is\n $expected,\nbut the actual is\n $actual"
	echo "Check gtm_${tstno}.outx"
endif
echo ""
echo ""

$gtm_com/IGS $gtm_dist/gtmsecshr CHOWN

chmod 644 mumps.dat
$gtm_tst/com/dbcheck.csh

#test 8 (GTM-7122)

###############################################################################################################
# This is a description of the rules we use for determining IPC and File permissions in GT.M.
#
# The columns defining each case have the following meanings:
#
#	DB Perm:	permissions on the database file, * for any
#	isowner:	user is the owner of the database file
#	oingroup:	file owner is a member of the database file group. a.k.a. owneringroup
#	ingroup:	user is a member of the database file group, either by OS config or setgid
#	restrict:	GT.M installation is group restricted by setting libyottadb o-x. a.k.a. gtmrestrict
#
# A dash (-) indicates "don't care", in which case the test verifies all options.
#
# The columns describing each case's results have the following meanings:
#
#	Result Group:	describes the source of the group identity used for the file or ipc
#	IPC Perm:	the permissions to use for generated shared memory and semaphores
#	File Perm:	the permissions to use for generated files, specifically journal files for this test
#
###############################################################################################################
# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm
#
# -r--r--rw-      N       Y       N       N       Current group of process           -rw-rw-rw-      -rw-rw-rw-
# -*--rw----      N       Y       Y       -       Group of database file             -rw-rw----      -rw-rw----
# -r*-r*-r*-      -       -       Y       -       Group of database file             -rw-rw-rw-      -r*-r*-r*-
# -rw-rw-r*-      -       -       N       -       Current group of process           -rw-rw-rw-      -rw-rw-rw-
# -r*-r--r--      -       -       N       -       Current group of process           -rw-rw-rw-      -r*-r--r--
# -r*-r*----      Y       Y       -       -       Group of database file             -rw-rw----      -r*-r*----
# -r*-r*----      Y       N       -       N       Current group of process           -rw-rw-rw-      -rw-rw-rw-
# -r*-r*----      Y       N       -       Y       Group to which GT.M is restricted  -rw-rw----      -rw-rw----
# -r*-r*----      N       Y       Y       -       Group of database file             -rw-rw----      -r*-r*----
# -r*-r*----      N       N       Y       N       Group of database file             -rw-rw-rw-      -rw-rw-rw-
# -r*-r*----      N       N       Y       Y       Group to which GT.M is restricted  -rw-rw----      -rw-rw----
# ----r*----      N       N       Y       -       Group of database file             -rw-rw----      -r*-r*----
# -r*-------      Y       -       -       -       Current group of process           -rw-------      -rw-------
###############################################################################################################
# Exception: isowner and owneringroup implies ingroup
# Exception: isowner and ingroup implies owneringroup
# Exception: isroot behaves as if isowner and ingroup, and sets IPC/File owner to match owner of DB
# Exception: restrict may remove "other" permissions.
###############################################################################################################

###############################################################################################################
# This test looks at shared memory permissions (shmperm) and semaphore permissions (semperm), which should
# match the Result Group and IPC Perm for each case.
# Similarly, this test looks at journal file permissions, which should match the Result Group and File Perm
# for each case.
# The test output is organized to correspond to these cases.
###############################################################################################################

echo $line
@ tstno ++
echo "**** test8 ****"
echo "** This test verifies the correct ipc and file permissions for all factors. (GTM-7122)"
echo

# Running setuid trashes LIBPATH on AIX, so no libicu. Unicode should not affect file permissions.
$switch_chset "M"

alias test_perms "$gtm_tst/$tst/u_inref/test_perms.csh \!* ; echo ====="

#(cd /gtc/staff/duzang/work/gtm-perm-test; ./makeIGS.csh) >& makeIGS.out	# for use before new IGS commands deployed

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r--r--rw-      N       Y       N       N       Current group of process           -rw-rw-rw-      -rw-rw-rw-"
echo "#"

foreach isroot (isroot "")
	test_perms perm=446 $isroot owneringroup
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -*--rw----      N       Y       Y       -       Group of database file             -rw-rw----      -rw-rw----"
echo "#"

foreach perm (060 460)
	foreach gtmrestrict (gtmrestrict "")
		foreach isroot (isroot "")
			foreach group (ingroup setgid)		# both cases in group
				test_perms perm=$perm $gtmrestrict $isroot owneringroup $group
			end
		end
	end
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r*-r*-r*-      -       -       Y       -       Group of database file             -rw-rw-rw-      -r*-r*-r*-"
echo "#"

foreach perm (666 664 644 444)
	foreach gtmrestrict (gtmrestrict "")
		foreach isroot (isroot "")
			foreach group (ingroup setgid)		# both cases in group
				foreach isowner (isowner "")
					foreach owneringroup (owneringroup "")
						test_perms perm=$perm $gtmrestrict $isroot $isowner $owneringroup $group
					end
				end
			end
		end
	end
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -rw-rw-r*-      -       -       N       -       Current group of process           -rw-rw-rw-      -rw-rw-rw-"
echo "#"

foreach perm (666 664)
	foreach gtmrestrict (gtmrestrict "")
		foreach isroot (isroot "")
			foreach isowner (isowner "")
				foreach owneringroup (owneringroup "")
					# eliminate cases that imply ingroup
					if ( ($isowner != "") && ($owneringroup != "") ) continue
					if ( ($isroot != "") && ($isowner == "") ) continue
					test_perms perm=$perm $gtmrestrict $isroot $isowner $owneringroup
				end
			end
		end
	end
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r*-r--r--      -       -       N       -       Current group of process           -rw-rw-rw-      -r*-r--r--"
echo "#"

foreach perm (644 444)
	foreach gtmrestrict (gtmrestrict "")
		foreach isroot (isroot "")
			foreach isowner (isowner "")
				foreach owneringroup (owneringroup "")
					# eliminate cases that imply ingroup
					if ( ($isowner != "") && ($owneringroup != "") ) continue
					if ( ($isroot != "") && ($isowner == "") ) continue
					test_perms perm=$perm $gtmrestrict $isroot $isowner $owneringroup
				end
			end
		end
	end
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r*-r*----      Y       Y       -       -       Group of database file             -rw-rw----      -r*-r*----"
echo "#"

foreach perm (660 640 440)
	foreach gtmrestrict (gtmrestrict "")
		foreach isroot (isroot "")
			foreach group (ingroup setgid "")
				test_perms perm=$perm $gtmrestrict $isroot isowner owneringroup $group
			end
		end
	end
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r*-r*----      Y       N       -       N       Current group of process           -rw-rw-rw-      -rw-rw-rw-"
echo "#"

foreach perm (660 640 440)
	foreach isroot (isroot "")
		test_perms perm=$perm $isroot isowner	# no group - would imply owneringroup
	end
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r*-r*----      Y       N       -       Y       Group to which GT.M is restricted  -rw-rw----      -rw-rw----"
echo "#"

if (gtmrestrict != "") then
	foreach perm (660 640 440)
		foreach isroot (isroot "")
			test_perms perm=$perm gtmrestrict $isroot isowner	# no group - would imply owneringroup
		end
	end
endif

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r*-r*----      N       Y       Y       -       Group of database file             -rw-rw----      -r*-r*----"
echo "#"

foreach perm (660 640 440)
	foreach gtmrestrict (gtmrestrict "")
		foreach isroot (isroot "")
			foreach group (ingroup setgid)		# both cases in group
				test_perms perm=$perm $gtmrestrict $isroot owneringroup ingroup $group
			end
		end
	end
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r*-r*----      N       N       Y       N       Group of database file             -rw-rw-rw-      -rw-rw-rw-"
echo "#"

foreach perm (660 640 440)
	foreach isroot (isroot "")
		foreach group (ingroup setgid)		# both cases in group
			test_perms perm=$perm $isroot $group
		end
	end
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r*-r*----      N       N       Y       Y       Group to which GT.M is restricted  -rw-rw----      -rw-rw----"
echo "#"

if (gtmrestrict != "") then
	foreach perm (660 640 440)
		foreach isroot (isroot "")
			foreach group (ingroup setgid)		# both cases in group
				test_perms perm=$perm gtmrestrict $isroot $group
			end
		end
	end
endif

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# ----r*----      N       N       Y       -       Group of database file             -rw-rw----      ----r*----"
echo "#"

foreach perm (060 040)
	foreach gtmrestrict (gtmrestrict "")
		foreach isroot (isroot "")
			foreach group (ingroup setgid)		# both cases in group
				test_perms perm=$perm $gtmrestrict $isroot $group
			end
		end
	end
end

echo "#"
echo "# DB Perm      isowner oingroup ingroup restrict  Result Group                        IPC Perm       File Perm"
echo "# -r*-------      Y       -       -       -       Current group of process           -rw-------      -rw-------"
echo "#"

foreach perm (600 400)
	foreach gtmrestrict (gtmrestrict "")
		foreach isroot (isroot "")
			foreach group (ingroup setgid "")
				foreach owneringroup (owneringroup "")
					test_perms perm=$perm $gtmrestrict $isroot isowner $owneringroup $group
				end
			end
		end
	end
end

echo $line

# Before starting %PEEKBYNAME test, check for any errors happened so far
$gtm_tst/com/errors.csh >&! allerrors_C9C12002191.log

# This mini-test is placed here because it triggers expected errors that errors.csh shouldn't catch
echo "# *** GTM-8296 %PEEKBYNAME test starts ***"
echo "# Take away gtmhelp.dat read permission to trigger an error"
chmod u-r $gtm_dist/gtmhelp.dat
cp {bak_,}mumps.gld
cp {bak_,}mumps.dat
$GTM<<EOF
write \$\$^%PEEKBYNAME("gd_region.jnl_state","DEFAULT"),!
write \$zgbldir
EOF
rm mumps.{dat,gld}
chmod u+r $gtm_dist/gtmhelp.dat
echo "# *** GTM-8296 %PEEKBYNAME test ends ***"
# Check for any errors before doing rmver
if (-z allerrors_C9C12002191.log) then
	$cms_tools/rmver.csh $tempver >&! rmver.out
	rm -rf $tempdir
endif

echo "# End of C9C12002191 testing"
