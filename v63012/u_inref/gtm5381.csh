#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test does a "strace" and expects to see "pwrite64()" calls to the database blocks in the strace output.
# When ASYNCIO is ON, we will instead see "io_submit()" calls, not "pwrite64()" calls. ASYNCIO anyways needs the
# database block size to be a multiple of the underlying file system block size. So testing for FULLBLKWRT setting
# setting of 0 (full block writes disabled) does not make sense there anyways. Therefore, disabling ASYNCIO for this test.
setenv gtm_test_asyncio 0

echo '# Test to verify that the -FULLBLKWRT setting works correctly in all three modes {0,1,2} both with'
echo '# MUPIP and GDE.'
echo '#'
echo '# This test uses strace to capture the system calls done by a process doing a simple database'
echo '# update and verifies the correct functioning of each of the 3 modes:'
echo '#   0 - disabled'
echo '#   1 - enabled - writes occur on filesystem block boundaries'
echo '#   2 - enabled - Like (1) plus also writes full database blocks if it is the first time blk is written'
echo '# The straces are processed to find the largest database write done in the strace file and reports'
echo '# this value - which changes with each FULLBLKWRT setting.'
setenv acc_meth "BG"		# Override to BG as MM is not compatible with testing fullblkwrt
# See if this platform is RHEL 7 which reports a different open function name that we look for. RHEL 7 reports
# 'open()' calls to open a DB while all our other (more recent) platforms report 'openat()' to open a DB. If
# this is RHEL 7, set a flag so we know to convert open() to openat() so our processor can find the calls.
set distro_is_rhel7 = 0
if ("rhel" == $gtm_test_linux_distrib) then
	grep -q 'Red Hat Enterprise Linux 7' /etc/os-release
	if (! $status) then
		# This is a RHEL 7 system.
		set distro_is_rhel7 = 1
	endif
endif

echo
echo '# Create a DB with blksize 8192'
$gtm_tst/com/dbcreate.csh mumps 1 256 1024 8192
echo
echo '# Test that we can use GDE to initialize the DB to fullblkwrt=2 - other flavors will use MUPIP SET'
echo '# to effect the change in fullblkwrt settings. Also recreate mumps.dat with new gld file'
$GDE << EOF >& recreatedb.log
ch -seg DEFAULT -fullblkwrt=2
EOF
rm mumps.dat				# Remove current DB
$MUPIP create >>& recreatedb.log	# Recreate with fullblkwrt set
echo
echo '# Verify if GDE SHOW output contains the correct fullblockwrite indicator'
$GDE show >& gdeshow.txt
$ydb_dist/yottadb -run ^%XCMD 'do gdeFBWRValue^gtm5381("gdeshow.txt")'
echo
echo '# Make a copy of this database as we need to refresh out DB between each strace invocation.'
cp -p mumps.dat mumps.dat.orig
echo
echo '# For each of the valid FULLBLKWRT settings, run strace on a yottadb invocation that (1) sets a new node'
echo '# (^x in this case), (2) flushes the DB to see the writes done for that, then (3) increments the node it'
echo '# just set. In FULLBLKWRT=2, this will show that the first SET wrote 2 blocks with 8K writes (new ^x index'
echo '# block and the data block), then the next time that datablock gets updated, a 4K write is used. The other'
echo '# two modes do not show a difference.'
foreach i (2 1 0)
    switch($i)
    case 0:
	# FULLBLKWRT=0, writes for whatever part of the blocks are dirty - no minimum write size
	set announce = "### Starting test for -FULLBLKWRT=${i} [disabled] - Expect multiple write sizes < 200 bytes"
	breaksw
    case 1:
	# FULLBLKWRT=1, Everything is written on a filesystem block size boundary so all 4K writes
	set announce = "### Starting test for -FULLBLKWRT=${i} [enabled filblock] - Expect 5 4K writes"
	breaksw
    case 2:
	# FULLBLKWRT=2, First time blocks are written at 8K and the rest written at 4K. This test includes the initial
	#               writes of 2 blocks (newly created ^X) as 8K but when that node is rewritten after a DBFLUSH,
	#               it is written as 4K as nothing needed to change in the second filesystem block (2 per DB block).
	set announce = "### Starting test for -FULLBLKWRT=${i} [enabled dbblock] - Expect 3 4K writes and 2 8K writes"
	breaksw
    default:
	echo "Unknown value of i: $i"
	exit 1
    endsw
    echo
    echo "${announce}"
    # Restore our database and set FULLBLKWRT appropriately if not first time through the loop
    if (2 != $i) then
        cp -p mumps.dat.orig mumps.dat
       	# Reset the fullblkwrt option to our current setting using MUPIP this time
    	$MUPIP set -reg DEFAULT -fullblkwrt=$i
	set savestatus = $status
	if (0 != $savestatus) then
	    echo "TEST-E-FAIL Unable to reset fullblkwrt to $i - got error code $savestatus"
	    exit 1
	endif
    endif
    echo '# Verify if DSE D -F output contains the correct full block write mode'
    $DSE d -f >& dsedf${i}.txt
    $ydb_dist/yottadb -run ^%XCMD 'do dseFBWRValue^gtm5381("dsedf'${i}'.txt")'
    # Run a single set command, force DB buffers to flush, then run an increment of the same var we set to
    # verify the length of the second write. They are different lengths when FULLBLKWRT=2 as only the first
    # write of a block is the full block length (8192 in this case).
    strace -o strace0${i}.logx $ydb_dist/yottadb -run ^%XCMD 'set ^x=1 view "dbflush" if $incr(^x)'
    set savestatus = $status
    if (0 != $savestatus) then
	echo "TEST-E-FAIL strace for strace0${i}.logx failed rc: $savestatus"
	exit 1
    endif
    # If we are running on RHEL 7, convert the open(..) call to openat(..) calls to match newer systems
    # and make the parse code less complex.
    if ($distro_is_rhel7) then
	sed -i 's/^open(/openat(/g' strace0${i}.logx
    endif
    # Process the strace file just created
    $ydb_dist/yottadb -run ^%XCMD 'do findDBWriteSizes^gtm5381("'strace0${i}.logx'")'
    set savestatus = $status
    if (0 != $savestatus) then
	echo "TEST-E-FAIL yottadb invocation for $1 failed rc: $savestatus"
	exit 1
    endif
end
#
echo ""
echo "####################################################"
echo "# Verify DB still OK"
echo "#"
$gtm_tst/com/dbcheck.csh




