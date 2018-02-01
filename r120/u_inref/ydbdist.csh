#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
set saveydbdist = $ydb_dist
unsetenv ydb_dist
unsetenv gtm_dist
set executables = "mumps mupip dbcertify dse ftok geteuid gtcm_gnp_server gtcm_pkdisp gtcm_play gtcm_server gtcm_shmclean gtmsecshr lke semstat2"

$echoline
echo "# Test of <ydb_dist/gtm_dist> env vars and how they affect how executables in $saveydbdist are invoked"
$echoline
#
echo ""
echo "# Test 1 : mumps/mupip/dse/lke etc. invoked through a soft link of a different name should work"
foreach exe ($executables)
	set newexe = "`pwd`/my$exe"
	echo "#  Invoking executable : $exe"
	ln -s $saveydbdist/$exe $newexe
	$newexe
	rm -f $newexe
end

echo ""
echo '# Test 2 : Copy of mumps/mupip/dse/lke etc. invoked from a directory that also contains a copy of libyottadb.so should work'
echo '#          Previously this would issue an IMAGENAME error for the "mumps" case. That is no longer the case'
cp $saveydbdist/libyottadb.so .	# needed by those executables that dlopen libyottadb.so (mumps, dse, mupip etc.)
foreach exe ($executables)
	set newexe = "`pwd`/my$exe"
	echo "#  Invoking executable : $exe"
	cp $saveydbdist/$exe $newexe
	$newexe
	rm -f $newexe
end
rm -f libyottadb.so

echo ""
echo '# Test 3 : Copy of mumps/mupip/dse/lke etc. invoked from a directory that does not also contain a copy of libyottadb.so should issue DLLNOOPEN error'
echo '#          Previously this would issue a GTMDISTUNVERIF error.'
foreach exe ($executables)
	set newexe = "`pwd`/my$exe"
	echo "#  Invoking executable : $exe"
	cp $saveydbdist/$exe $newexe
	$newexe
	rm -f $newexe
end

echo ""
echo '# Test 4 : mumps/mupip/dse/lke etc. invoked from a current directory where they do not exist, but are found in $PATH, should work'
set origpath = ($path)
set path = ($saveydbdist $origpath)
foreach exe ($executables)
	echo "#  Invoking executable : $exe"
	# Although we redirect the below to a file and immediately cat the file, not redirecting the output
	# results in some test output reordering issues. Not exactly sure what the cause is. But since redirection
	# addresses that issue, it is not further investigated. Use logx (not log) to avoid test error framework
	# from signaling errors in these files at the end of the test.
	$exe >& $exe.logx
	cat $exe.logx
end
set path = ($origpath)

echo ""
echo '# Test 5 : gtmsecshr issues a SECSHRNOYDBDIST error if ydb_dist env var is not set'
sleep 1	# sleep to ensure syslog_start is a different time than the time previous tests ran (as they also produce SECSHRNOYDBDIST message)
set syslog_start = `date +"%b %e %H:%M:%S"`
$saveydbdist/gtmsecshr
$gtm_tst/com/getoper.csh "$syslog_start" "" "syslog1.txt" "" "SECSHRNOYDBDIST"
$gtm_tst/com/check_error_exist.csh syslog1.txt SECSHRNOYDBDIST

