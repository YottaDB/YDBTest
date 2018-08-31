#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# test to make sure GT.M can build shared libraries >4GB

unsetenv gtmdbglvl	# turn off gtmdbglvl checking for this particular subtest due to run time constraints

# There is a memory bloating on Solaris with dbg image. Until it is resolved, test must be run as pro image.
if (( "sunos" == "$gtm_test_osname" ) && ( "dbg" == "$tst_image" )) then
	echo "Until Solaris memory bloating issue (C9I12-003068) is resolved, test must be run with pro image"
	echo "# End of largelibtest"
	exit
endif

# The current zwr file that is loaded from big_files is in M mode
# If that gets replaced with a new extract that is in UTF-8 mode, change the below line accordingly
$switch_chset M >&! /dev/null


echo "# Parameters"

setenv debug "0"	# debug level - comment out or set to zero for non-debug
setenv dup "13"		# number of dups of routines needed to get >4GB
setenv gtmgbldir "$PWD/g/mumps.gld"
setenv gtmroutines "$PWD/o($PWD/r) $gtmroutines"
setenv MUMPS "$gtm_exe/mumps"
# If chset is UTF-8, set the correct gtmroutines and mumps path
if ($?gtm_chset) then
	if ($gtm_chset == "UTF-8") then
		setenv MUMPS "$gtm_exe/utf8/mumps"
	endif
endif
setenv libsize "5000"	# new shared library every so many source files
setenv loadfrom "0"	# make it 0 to load from shared libraries
setenv sourcedir "$PWD/src"

echo "# Setup directories"

mkdir -p g o 	# directories for globals, object (for routines, "r" directory is already there in the .tar.gz file)

echo "# Unpack routines"
$tst_gunzip -d < $gtm_test/big_files/largelibtest/WorldVistAEHRv10FT01_routines.tar.gz |tar -xf -

# The directories are created with proper permissions. The untar of WorldVista... causes the directory
# permission to go read-only so it needs to be set writeable. Note: the change of permission by the
# untar does not occur on all platforms.
chmod ug+w r # ensure directory r is writable so that we can delete it when test is done

echo "# Make copies of the files"
cp $gtm_tst/$tst/inref/makecopies.m .
cp $gtm_tst/$tst/inref/loadcode.m .
$MUMPS -run makecopies $dup $libsize $debug >&! makecopies.out

echo "# Set up the database"
$GDE <<EOF
ch -s DEFAULT -bl=4096 -al=50000 -ex=10000 -fi=$PWD/g/mumps.dat
ch -r DEFAULT -re=4080 -ke=255 -stdnull
exit
EOF

if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create

$tst_gunzip -d < $gtm_test/big_files/largelibtest/WorldVistAEHRv10FT01.zwr.gz > WorldVistAEHRv10FT01.zwr
$gtm_exe/mupip load WorldVistAEHRv10FT01.zwr -onerror=stop
\rm WorldVistAEHRv10FT01.zwr

echo "# Run the test"
$gtm_exe/mumps -dir $loadfrom $debug << EOF
D ^loadcode
S DUZ=1 D P^DI
?
^
D ^ZTMGRSET
N
H
EOF

echo "# End of largelibtest"
