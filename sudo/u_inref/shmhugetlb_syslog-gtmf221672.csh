#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F221672 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-F221672)

The SHMHUGETLB syslog warning message provides information about the operation of the calling process.
Previously, SHMHUGETLB failure messages did not include operational information necessary to understand the reasons for such failures. (GTM-F221672)
CAT_EOF
echo ''
source $gtm_tst/$tst/u_inref/setinstalloptions.csh
# The Buffered Global (BG) database access method is required in this case because
# the SHMHUGETLB error under test is only issued when shared memory is used. Shared
# memory is used in BG, but not in Memory Mapped (MM) mode. So, set the access method
# to BG in case MM was chosen in do_random_settings.csh.
echo '# Set the database access method to BG mode to ensure shared memory is used'
setenv acc_meth "BG"
set sudostr = "$sudostr --preserve-env gtmgbldir"
# Enable memory lock capability for DSE when in the pipeline,
# to prevent `%SYSTEM-E-ENO1, Operation not permitted` errors,
# which occur due to capabilities being dropped when switching
# from the root user id to the gtmtest user id via `su -l gtmtest`
# in `pipeline-test-ydbtest.csh`. For more information see the discussion at:
# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2196#note_2373397992
if ($?ydb_test_inside_docker) then
	sudo setcap 'cap_ipc_lock+ep' $gtm_dist/dse
endif
# Set start time for getoper.csh
set syslog_start = `date +"%b %e %H:%M:%S"`
setenv ydb_msgprefix "GTM"
echo '# Set gtm_hugetlb_shm to enable hugetlb pages'
setenv gtm_hugetlb_shm 1
echo '# Create database file'
$gtm_tst/com/dbcreate.csh mumps
echo '# Set the number of global buffers to the maximum to create conditions for SHMHUGETLB error'
$gtm_dist/mupip set -glo=2097151 -reg "*" >&! mupip.out
echo '# Run DSE to produce SHMHUGETLB error'
(echo "exit" | $gtm_dist/dse & ; echo $! >&! dse.pid) >&! dse.out
set dsePID = `cat dse.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $dsePID
echo ''
echo '# Check syslog for SHMHUGETLB errors'
$gtm_tst/com/getoper.csh "$syslog_start" "" test_syslog.txt
grep SHMHUGETLB test_syslog.txt | grep -E "(GTM|YDB|MUMPS)-DSE\[$dsePID\]" | sed "s@.* \(GTM\|YDB\|MUMPS\)-DSE\[[0-9]*\]: \(%GTM-W-SHMHUGETLB, Could not back shared memory with huge pages, using base pages instead for database file \)$PWD/mumps.dat\(, %SYSTEM-E-ENO12, Cannot allocate memory -- generated from \).*\.@##TIMESTAMP GTM-DSE\[##PID\]: \2##PATH\3##MEMADDR.@g"
$gtm_tst/com/dbcheck.csh
# Reset capabilities on the DSE, undoing `cap_ipc_lock+ep` above
if ($?ydb_test_inside_docker) then
	sudo setcap '-r' $gtm_dist/dse
endif
