#!/usr/local/bin/tcsh

#41) Test that non-supplementary failovers do not affect supplementary instance as long as rollback is not needed.
#	A,B are in one LMS group. P is in a different supplementary LMS group.
#	A->B and A->P replication is in effect.
#	A does 10 transactions all of which go to B. But only 8 reach P before A gets shut down.
#	So A,B have 10 updates while P has only 8 of those.
#	Now B comes up as primary. Now bring up A as secondary to B. One needs to do a fetchresync rollback on A.
#	It will produce an empty lost transaction file since A and B were in sync before they went down.
#	Now start source server on B to replicate to P.
#	The receiver server on P, which has been running all this while, should connect fine with B.
#	And replication should resume without any issues. This is because P is in sync with B.

source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2 2

$gtm_tst/com/dbcreate.csh mumps 1 125 1000 1024 4096 1024 4096

setenv needupdatersync 1
$MSR START INST1 INST2 RP
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync 

$gtm_tst/com/simplegblupd.csh -instance INST1 -count 8
$MSR SYNC INST1 INST3
$MSR STOPSRC INST1 INST3
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 2
$MSR SYNC INST1 INST2
$MSR STOP INST1 INST2
$MSR START INST2 INST1 RP
$MSR STARTSRC INST2 INST3
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 5

$MSR SYNC INST2 INST1
$MSR SYNC INST2 INST3
$MSR SYNC INST3 INST4
$MSR STOP INST2 INST1
$MSR STOPSRC INST2 INST3
$MSR STOPRCV INST1 INST3 # Need to use INST1 has it was with this value that the receiver was started.
$MSR STOP INST3 INST4

$gtm_tst/com/dbcheck.csh -extract
