#!/usr/local/bin/tcsh -f

## ## multisite_replic/switch_over (or  multisite_switch_over test itself since it might be a long running test) ###2###Kishore
## This is the multi-site version of the switch_over test. We still need to keep the switch_over test so it can be used
## in the filter test.
## 

cat << EOF
## Let's say the layout of the
## servers is:
##            |--> INST2 (B)
## INST1 (A) -|
##            |--> INST3 (C)
## 
## A client might have this layout (say A, and B are on the main site, with C at a DR site). Say A needs to go under some
## maintenance, so they want to switch over to B. This subtest will test that.
##
EOF
## - Bring up replication as per the layout above.
##   setenv tst_buffsize 33000000
##   $MULTISITE_REPLIC_PREPARE 3
##   $gtm_tst/com/dbcreate.csh mumps 4 125 1000
##   START INST1 INST2 RP
##   START INST1 INST3 RP

setenv tst_buffsize 33000000
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh mumps 4 125 1000
$MSR START INST1 INST2 RP
$MSR START INST1 INST3 RP

## - Perform some updates on INST1. Pick these from the switch_over test.
##   $gtm_tst/com/fgdbfill.csh >>&! fgdbfill.out

echo "Database fill program starts"
$gtm_tst/com/fgdbfill.csh >>&! fgdbfill.out
echo "Database fill program ends"

## - Stop the receiver on INST3 (let's see if it can catch up from INST2 later).
##   STOPRCV INST1 INST3
## - Sync INST2 to INST1. INST3 may or may not be synced.
##   SYNC INST1 INST2

$MSR STOPRCV INST1 INST3
$MSR SYNC INST1 INST2

cat << EOF
## - Stop the receiver on INST2, and activate the source server on INST2.
EOF
##   RUN RCV=INST2 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0'
##   ACTIVATERP INST2 INST1
## - Start background updates on INST2. Pick from switch_over.
cat << EOF
## - Shutdown primary source server on INST1.
##   STOPSRC INST1 INST2
## 	--> Note the source server has been running on INST1 while there was a source server on INST2 as well. But no
## 	    receivers were running on either one, so this should be OK.
## - Stop INST1 --> INST3
##   STOPSRC INST1 INST3
## - Restart INST1 as Secondary.
##   STARTRCV INST2 INST1
## - Shutdown replication on INST3.
##   STOP INST3
## - Switch INST3 to replicate from INST2 as well.
##   START INST2 INST3
##   So the layout will look like:
##              |--> INST1 (A)
##   INST2 (B) -|
##              |--> INST3 (C)
EOF
## - stop background updates on INST2.
## - STOP ALL_LINKS
## - dbcheck -extract INST1 INST2 INST3

$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -receiv -shutdown -timeout=0 >& INST2_shut.tmp; cat INST2_shut.tmp'
$MSR REFRESHLINK INST1 INST2
$MSR ACTIVATE INST2 INST1 RP
echo "Background database fill program starts"
setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 1
$MSR RUN INST2 "$gtm_tst/com/imptp.csh >>&! imptp.out"
$MSR STOPSRC INST1 INST2 ON
$MSR STOPSRC INST1 INST3
$MSR STARTRCV INST2 INST1
$MSR START INST2 INST3
echo "Background database fill program ends"
$MSR RUN INST2 "$gtm_tst/com/endtp.csh >>&! endtp.out"
$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3
