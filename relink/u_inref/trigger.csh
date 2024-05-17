#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that autorelink happens when an update on a replicated trigger occurs.

# We do not want autorelink-enabled directories that have been randomly assigned by the test system because we are explicitly
# testing the autorelink functionality, as opposed to the rest of the test system which may be testing it implicitly.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

# Make sure only the current directory is autorelink-enabled, on both sides.
set gtmroutines_noautorelink = "$gtmroutines"
setenv gtmroutines ".* $gtmroutines"
setenv test_gtmroutines_preset "$gtmroutines"	# set this env var to indicate to test framework that "gtmroutines"
						# is a special value that needs to be restored as part of version switching.

setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode in dbcreate.csh as this test sets "test_gtmroutines_preset" and that
				# causes trouble with version switching that happens in V6 DB mode (inside dbcreate.csh).
source $gtm_tst/com/gtm_test_trigupdate_disabled.csh	# this test relies on M trigger code on secondary side to be executed
							# so disable "-trigupdate".

# Set things up.
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps
echo

# Start the servers.
$MSR START INST1 INST2 RP
echo

# Cache the name of the secondary's update process log.
get_msrtime
set updproclog = RCVR_${time_msr}.log.updproc

#############################################################################
# Case 1. An update propagated to the secondary triggers an invocation of a #
#         routine whose object has been ZRUPDATEd.                          #
#############################################################################

echo "Case 1"
echo

# Install a trigger.
$gtm_dist/mumps -run %XCMD 'set x=$ZTRIGGER("ITEM","+^x -commands=S -xecute=""DO ^TRIG""")'
echo

# Create a routine that the trigger invokes.
cat > TRIG.m << eof
 write "version 1",!
eof

# Copy the routine to the secondary.
cp TRIG.m $SEC_SIDE

# Start a process to set ^x=1 and wait in the background for a signal, upon
# which do set ^x=2 and terminate.
($gtm_dist/mumps -run sets^trigger >&! mumps1.out &) >& /dev/null

# Obtain the process's pid.
$gtm_tst/com/wait_for_log.csh -log pid1.out -message "DONE" -duration 120 -waitcreation
@ pid = `$head -1 pid1.out`

# Make sure that the first update has been synchronized.
$MSR SYNC ALL_LINKS
echo

# Create a second version of the trigger-invoked routine.
cat > TRIG.m << eof
 write "version 2",!
eof

# Compile it on the primary.
$gtm_dist/mumps TRIG.m

# Copy the routine to the secondary.
cp TRIG.m $SEC_SIDE

# Prepare a simple M script to compile and zrupdate the new version of the routine.
cat > update.m <<eof
 zcompile "TRIG.m"
 zrupdate "TRIG.o"
 zshow "A"
eof

# Move the script to the secondary.
mv update.m $SEC_SIDE

# Compile and zrupdate the new version of the routine on the secondary.
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_dist/mumps -run update"
echo

# Signal the backgrounded process to do the second set.
$kill -USR1 $pid

# Wait for the set to take effect.
$gtm_tst/com/wait_for_log.csh -log pid1.out -message "DONE2" -duration 120

# Syncrhonize the second update.
$MSR SYNC ALL_LINKS
echo

# The backgrounded process should now terminate.
$gtm_tst/com/wait_for_proc_to_die.csh $pid 120

# Verify which versions of TRIG.m got invoked on the primary and secondary. Only
# on the secondary should version 2 be invoked after the second update.
echo "On the primary:"
cat mumps1.out
echo
echo "On the secondary:"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $grep version $updproclog"
echo

#############################################################################
# Case 2. An update propagated to the secondary triggers a modification of  #
#         a routine source, followed by its compilation, ZRUPDATE, and re-  #
#         invocation.                                                       #
#############################################################################

echo "Case 2"
echo

cat > wrtrtn.trg <<eof
+^wrtrtn -commands=ZTRIGGER -xecute=<<
  set src="TRIG.m",obj="TRIG.o"
  open src:newversion
  use src
  write " write ""version 3"""
  close src
  zcompile src
  zrupdate obj
  zshow "A"
  do ^TRIG
>>
eof

# Install a trigger.
$gtm_dist/mumps -run %XCMD 'set y=$ZTRIGGER("FILE","wrtrtn.trg")'
echo

# Start a process to set ^x=3 and wait in the background for a signal, upon
# which to invoke the wrtrtn trigger and terminate.
($gtm_dist/mumps -run setandcall^trigger >&! mumps2.out &) >& /dev/null

# Because we have a backgrounded process on the primary that we will be doing a zshow "A" on,
# make sure that no other routines will be pulled into the report.
setenv gtmroutines "$gtmroutines_noautorelink"

# Obtain the process's pid.
$gtm_tst/com/wait_for_log.csh -log pid2.out -message "DONE" -duration 120 -waitcreation
@ pid = `$head -1 pid2.out`

# Make sure that the first update has been synchronized.
$MSR SYNC ALL_LINKS
echo

# Signal the backgrounded process to do the second set.
$kill -USR1 $pid

# Wait for the set to take effect.
$gtm_tst/com/wait_for_log.csh -log pid2.out -message "DONE2" -duration 120

# Syncrhonize the second update.
$MSR SYNC ALL_LINKS
echo

# The backgrounded process should now terminate.
$gtm_tst/com/wait_for_proc_to_die.csh $pid 120

# Verify which versions of TRIG.m got invoked on the primary and secondary. Only
# on the secondary should version 2 be invoked after the second update.
echo "On the primary:"
cat mumps2.out
echo
echo "On the secondary:"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $grep version $updproclog"
echo

# Wrap things up.
$gtm_tst/com/dbcheck.csh
