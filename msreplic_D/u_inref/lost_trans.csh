#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
alias shrink   "sed 's/ABCDEFGHIJKLMNOPQRSTUVWXYZ.*abcdefghijklmnopqrstuvwxyz/A...z/g'"
setenv ZQGBLMOD '$ZQGBLMOD' # to make echo commands in this script easier
$echoline
cat << EOF

  This subtest will test $ZQGBLMOD and -needrestart and -losttncomplete, and applying lost transactions.
       The overall scheme is:
       -----------------------------------------------------------------------------------------------
              INST1/A  (  *)      INST2/B  (  *)       INST3/C  (  *)        INST4/D
       -----------------------------------------------------------------------------------------------
Step  1:    (P)  1-100 (  0)sw  (S)  1- 70 (  0)sw   (S)  1- 50 (  0)sw    (T)  1-.. 	$ZQGBLMOD(^GBLA(1...35))=1
Step  2:    (r)    L1  ( 71)    (P)        ( 71)           -                     -
Step  3:    (S)                 (P)        ( 71)     (r)        (  0)            -  	$ZQGBLMOD(^GBLA(1...30))=0
Step  4:    (S) 71-130 ( 71)sw  (P) 71-140 ( 71)sw   (S) 51-100 (  0)sw          -  	$ZQGBLMOD(^GBLA(1...30))=1
Step  5:          -                   -              (P)101-    (  0)sw          -  	$ZQGBLMOD(^GBLA(1...35))=1
Step  6:          -             (r)    L2  ( 71)     (P)        (101)            -  	$ZQGBLMOD(^GBLA(1...30))=0 (false negative)
Step  7:    (r)   X1   ( 71)    (S)        ( 71)     (P)        (101)      (T)      	$ZQGBLMOD(^GBLA(1...30))=1,$ZQGBLMOD(^GBLA(30...35))=0
Step  8:               ( 71)    (S)        (  0)     (P) apply L1, L2      (T)
Step  9:                        (S)        (  0)     (P) -losttn  (0)      (T)
Step 10:    (S)        (  0)    (S)                  (P)                   (T)

(P): Primary
(S): Secondary (receiver alive)
(T): Tertiary (This is only for D: D will be connected to B when B is secondary)
(r): rollback
-  : shutdown
sw : journal switch when seqno 71 or 101 would be written to the journal file. See below for details (and reasoning)
(*): the value of the zqgblmod field out of dse dump -fileheader output.
$ZQGBLMOD(^GBLA(a...b))=val ==> The value of $ZQGBLMOD for the subscripted globals ^GBLA(a) to ^GBLA(b) is expected to
be val if applied on the instance that is the primary at this step. Also the $ZQGBLMOD should be done AFTER the
updates indicated in the primary instance for this step are done.
EOF

$echoline
$MULTISITE_REPLIC_PREPARE 4
$gtm_tst/com/dbcreate.csh . -rec=1000 -block_size=1024

$echoline
echo "#- Step 1:"
$MSR START INST1 INST2
$MSR START INST1 INST3
$MSR START INST2 INST4 PP
echo "# seqnos: 1-50:"
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 50 	# seqnos: (1-50)
$MSR SYNC INST1 INST3
$MSR STOPRCV INST1 INST3

if ($gtm_test_jnl_nobefore) then
	# We are running with NOBEFORE_IMAGE journaling. The fetchresync rollback on INST1 (done later) will NOT roll back
	# the database so we need to restore the database from a backup that is taken here.
	echo "#-- Take backup on INST1 at seqno 51."
	$MSR RUN INST1 "mkdir bak1; $MUPIP backup -replinstance=bak1 "'"*" bak1'
endif

echo "# seqnos: 51-70:"
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 20 	# seqnos: (51-70)
$MSR SYNC INST1 INST2
cat << EOF
    switch journals on INST1. -- Due to $ZQGBLMOD's pessimistic answers, let's
    switch journals here to see the most-accurate answers from $ZQGBLMOD.
    There will be other places below (whenever seqno 71 will be written to the
    journal file) for the same reason.
    Also switch journals soon after to see that $ZQGBLMOD does follow back
    to the previous journal file as necessary.
EOF
echo "#-- Switch journals on INST1."
$MSR RUN INST1 '$gtm_tst/com/jnl_on.csh $test_jnldir'
echo "#-- Switch journals on INST2."
$MSR RUN INST2 '$gtm_tst/com/jnl_on.csh $test_jnldir'
echo "#-- Switch journals on INST3."
$MSR RUN INST3 '$gtm_tst/com/jnl_on.csh $test_jnldir'

$echoline
$MSR STOPRCV INST1 INST2
echo "# seqnos: 71- 75:"
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 5 	# seqnos: (71- 75)
echo "#-- Switch journals on INST1."
$MSR RUN INST1 '$gtm_tst/com/jnl_on.csh'
echo "# seqnos: 76-100:"
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 25 	# seqnos: (76-100)
$MSR STOP INST1
$MSR STOP INST2 INST4	# note we are not SYNC'ing here

$echoline
echo "#- Step 2:"
$MSR STARTSRC INST2 INST1
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 0'
echo "#  	--> We expect 0."
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 0'
echo "#  	--> We expect 0."

$gtm_tst/com/view_instancefiles.csh
$MSR RUN RCV=INST1 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost1_INST1.glo "*"' >& rollback1_INST1.log
$grep "Executing" rollback1_INST1.log
$grep JNLSUCCESS rollback1_INST1.log
cat << EOF
  	--> We expect transactions with seqnos 71-100 to be in lost1_INST1.glo (L1). Also check the first line of the
	    lost transaction file, the third field should show PRIMARY (newly introduced field that shows
	    (previous)PRIMARY or (previous)SECONDARY).
EOF
set firstline = `$head -n 1 lost1_INST1.glo`
if ($?gtm_chset) then
	# for UTF-8 mode we will have the first field in the header to be UTF-8. This will be filtered to go with the test flow below.
	if ("UTF-8" == $gtm_chset) set firstline = `$head -n 1 lost1_INST1.glo|sed 's/[ ]*UTF-8$//g'`
endif
echo $firstline
echo $firstline | $tst_awk '{if ("PRIMARY" != $3) exit 1; if (4 != NF) exit 1; if ("INSTANCE1" != $NF) exit 1}'
if ($status) then
	echo "TEST-E-LOSTTRANSFILE header is not as expected!"
endif
$MSR RUN INST1 '$gtm_tst/com/analyze_jnl_extract.csh lost1_INST1.glo 71 100'  | shrink
if ($gtm_test_jnl_nobefore) then
	# If NOBEFORE_IMAGE journaling, we want to test that rollback -fetchresync (which will basically be a LOSTTNONLY rollback)
	# can be done any # of times and will yield the same lost transaction file.
	echo "Testing repeated rollbacks (with NOBEFORE_IMAGE journaling) yield the same lost transaction file"
	$MSR RUN RCV=INST1 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost1_INST1_1.glo "*"' >& rollback1_INST1_1.log
	$MSR RUN INST1 'diff lost1_INST1_1.glo lost1_INST1_1.glo'
endif
echo "#  Transfer lost1_INST1.glo to INST3"
$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/lost1_INST1.glo _REMOTEINFO___RCV_DIR__/'
#tmp tmp remove $MSR RUN SRC=INST1 RCV=INST3 'cp __SRC_DIR__/lost1_INST1.glo __RCV_DIR__/'

$MSR RUN INST2 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 71'
echo "#  	--> We expect 71."

if ($gtm_test_jnl_nobefore) then
	set expect = 0
else
	set expect = 71
endif
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/dse_dump_info.csh '$expect
echo "#  	--> We expect $expect."
$gtm_tst/com/view_instancefiles.csh -diff
cat << EOF
	--> We do not expect a diff at this point (from the last time view_instancefiles.csh was done) since the slot
	    for INST1 would not be updated by the rollback.
EOF

if ($gtm_test_jnl_nobefore) then
	# We are running with NOBEFORE_IMAGE journaling. Fetchresync rollback was done on INST1 and now we want to bring up
	# INST1 as if the databases were rolled back. Restore from backup.
	$MSR RUN INST1 '$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.mjl* *.repl" mv'
	$MSR RUN INST1 'cp bak1/* .; '$MUPIP' set -replication=on '$tst_jnl_str' -reg "*"'
endif

$MSR STARTRCV INST2 INST1 waitforconnect
$gtm_tst/com/view_instancefiles.csh -diff -instance INST1
echo "#  	--> We expect the resync_seqno for the INST1 slot to be updated."

$echoline
echo "#- Step 3:"
$MSR STARTSRC INST2 INST3
$gtm_tst/com/view_instancefiles.csh
$MSR RUN RCV=INST3 SRC=INST2 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost1_INST3.glo "*"' >& rollback1_INST3.log
$grep "Executing" rollback1_INST3.log
$grep JNLSUCCESS rollback1_INST3.log
echo "#  	--> Since there are no lost transactions, we do not expect lost1_INST3.glo to have any transactions."
$MSR RUN INST3 '$gtm_tst/com/analyze_jnl_extract.csh lost1_INST3.glo 0 0'
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 71'
echo "#  	--> We expect 71."
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 0'
echo "#  	--> We expect 0."
$gtm_tst/com/view_instancefiles.csh
cat << EOF
	--> We do not expect a diff at this point (from the last time view_instancefiles.csh was done) since the slot
	for INST3 would not be updated by the rollback.
EOF
$MSR STARTRCV INST2 INST3 waitforconnect
$gtm_tst/com/view_instancefiles.csh -diff
echo "# 	--> We expect the resync_seqno for the INST3 slot to be updated."
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/check_zqgblmod.csh 0:1-30 >& zqgblmod.tmp; cat zqgblmod.tmp'
echo '#  	--> Expected values are: $ZQGBLMOD(^GBLA(1...30)=0'

$echoline
echo "#- Step 4:"
echo "#-- Switch journals on INST2."
$MSR RUN INST2 '$gtm_tst/com/jnl_on.csh $test_jnldir'
$MSR SYNC INST2 INST3

if ($gtm_test_jnl_nobefore) then
	# We are running with NOBEFORE_IMAGE journaling. The fetchresync rollback on INST2 (done later) will NOT roll back
	# the database so we need to restore the database from a backup that is taken here.
	echo "#-- Take backup on INST2 at seqno 71."
	$MSR RUN INST2 "mkdir bak1; $MUPIP backup -replinstance=bak1 "'"*" bak1 >& bak1mkdir.tmp; cat bak1mkdir.tmp'
endif

echo "#-- Switch journals on INST1."
$MSR RUN INST1 '$gtm_tst/com/jnl_on.csh $test_jnldir'
$MSR SYNC INST2 INST3 sync_to_disk	# we need C to catch up so that we can switch journal files
echo "#-- Switch journals on INST3."
$MSR RUN INST3 '$gtm_tst/com/jnl_on.csh $test_jnldir'
echo ""
echo "# seqnos: ( 71-100):"
echo "# Let INSTB start seq 70 from ^GBLA(1) again..."
mv update_stat.txt update_stat1.txt
echo "35,3" >! update_stat.txt	# i.e start from ^GBLA(1)=4 (next value in the update order)
echo "# seqnos: 71-75:"
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 5 	# seqnos: (71- 75)
echo "#-- Switch journals on INST2."	# to see that $ZQGBLMOD values will indeed move to the previous jnl file
$MSR RUN INST2 '$gtm_tst/com/jnl_on.csh $test_jnldir'
echo "# seqnos: 76-100:"
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 25 	# seqnos: (76-100)
$MSR SYNC INST2 INST3
$MSR STOPRCV INST2 INST3
echo "# seqnos: 101-130:"
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 30 	# seqnos: (101-130)
$MSR SYNC INST2 INST1
$MSR STOPRCV INST2 INST1
echo "# seqnos: 131-140:"
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 10 	# seqnos: (131-140)
$MSR STOP INST2
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/check_zqgblmod.csh 1:1-30'
echo '#  	--> Expected values are: $ZQGBLMOD(^GBLA(1...30)=1'

$echoline
echo "#- Step 5:"
$MSR STARTSRC INST3 INST2
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/check_zqgblmod.csh 1:1-35'
echo '#  	--> Expected values are: $ZQGBLMOD(^GBLA(1...35))=1 since zqgblmod field in dse dump -file output still shows 0.'

$echoline
echo "#- Step 6:"
$gtm_tst/com/view_instancefiles.csh
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 0'
echo "#  	--> We expect 0."
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 71'
echo "#  	--> We expect 71."
$MSR RUN SRC=INST3 RCV=INST2 '$MUPIP replic -source -needrestart -instsecondary=__RCV_INSTNAME__' >& needrestart1.out
$grep "Executing" needrestart1.out
echo "#	--> We expect a 'NEEDS to be restarted first' message since the receiver did not connect yet."
$grep "NEEDS to be restarted first" needrestart1.out >& /dev/null
if ($status) then
	echo "TEST-E-NEEDRESTART incorrect at needrestart1.out"
endif
echo "#-- Switch journals on INST3."
$MSR RUN INST3 '$gtm_tst/com/jnl_on.csh $test_jnldir'
$MSR RUN RCV=INST2 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost2_INST2.glo "*" >& rollback2_INST2.tmp; cat rollback2_INST2.tmp' >& rollback2_INST2.log
$grep "Executing" rollback2_INST2.log
$grep JNLSUCCESS rollback2_INST2.log
cat << EOF
  	--> We expect transactions with seqnos 101-140 in lost2_INST2.glo (L2). Also check the third field of the"
	    first line shows PRIMARY type of lost transaction file (as in (previous)PRIMARY).
EOF
$MSR RUN INST2 '$gtm_tst/com/analyze_jnl_extract.csh lost2_INST2.glo 101 140'  | shrink
echo "#  Transfer lost2_INST2.glo to INST1 (for analysis of the first line)"
$MSR RUN SRC=INST2 RCV=INST1 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/lost2_INST2.glo _REMOTEINFO___RCV_DIR__/'
echo "#  Transfer lost2_INST2.glo to INST3"
$MSR RUN SRC=INST2 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/lost2_INST2.glo _REMOTEINFO___RCV_DIR__/'
$convert_to_gtm_chset lost2_INST2.glo
set firstline = `$head -n 1 lost2_INST2.glo`
if ($?gtm_chset) then
	# for UTF-8 mode we will have the first field in the header to be UTF-8. This will be filtered to go woth the test flow below.
	if ("UTF-8" == $gtm_chset) set firstline = `$head -n 1 lost2_INST2.glo|sed 's/[ ]*UTF-8$//g'`
endif
echo $firstline
echo $firstline | $tst_awk '{if ("PRIMARY" != $3) exit 1; if (4 != NF) exit 1; if ("INSTANCE2" != $NF) exit 1}'
if ($status) then
	echo "TEST-E-LOSTTRANSFILE header is not as expected!"
endif
$MSR RUN SRC=INST3 RCV=INST2 'setenv gtm_repl_instsecondary __RCV_INSTNAME__; $MUPIP replic -source -needrestart' >& needrestart2.out
$grep "Executing" needrestart2.out
cat << EOF
	--> We expect a "DOES NOT NEED to be restarted" message since a rollback command was run. (Note we are
	    testing the usage of gtm_repl_instsecondary as well).
EOF
$grep "DOES NOT NEED to be restarted" needrestart2.out >& /dev/null
if ($status) then
	echo "TEST-E-NEEDRESTART incorrect at needrestart2.out"
endif
$gtm_tst/com/view_instancefiles.csh
echo "#  	--> We do not expect a diff at this point."
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 101'
echo "#  	--> We expect 101."
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 71'
echo "#  	--> We expect 71."

if ($gtm_test_jnl_nobefore) then
	# We are running with NOBEFORE_IMAGE journaling. Fetchresync rollback was done on INST2 and now we want to bring up
	# INST2 as if the databases were rolled back. Restore from backup.
	$MSR RUN INST2 '$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.mjl* *.repl" mv'
	$MSR RUN INST2 'cp bak1/* .; '$MUPIP' set -replication=on '$tst_jnl_str' -reg "*" >& bak1cp.tmp; cat bak1cp.tmp'
endif

$MSR STARTRCV INST3 INST2
$MSR RUN SRC=INST3 RCV=INST2 '$MUPIP replic -source -needrestart -instsecondary=__RCV_INSTNAME__' >& needrestart3.out
$grep "Executing" needrestart3.out
echo "#	--> We expect a "DOES NOT NEED to be restarted" message since the receiver is up."
$grep "DOES NOT NEED to be restarted" needrestart3.out >& /dev/null
if ($status) then
	echo "TEST-E-NEEDRESTART incorrect at needrestart3.out"
endif
$gtm_tst/com/view_instancefiles.csh
echo "#  	--> We expect the resync_seqno for the INST2 slot to be updated."
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/check_zqgblmod.csh 0:1-30'
cat << EOF
  	--> Expected values are: $ZQGBLMOD(^GBLA(1...30))=0
	    Note that this is a false negative, since actually the globals have been modified. If we were looking
	    at $ZQGBLMOD to apply the lost transactions in L1 (lost1_INST1.glo), this would have been the wrong
	    answer, since those lost transactions were generated for a different primary.
EOF

$echoline
echo "#- Step 7:"
$MSR STARTSRC INST3 INST1
$MSR START INST2 INST4 PP
$gtm_tst/com/view_instancefiles.csh
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 101'
echo "#  	--> We expect 101."

if ($gtm_test_jnl_nobefore) then
	set expect = 0
else
	set expect = 71
endif
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/dse_dump_info.csh '$expect
echo "#  	--> We expect $expect."

$MSR RUN SRC=INST3 RCV=INST1 '$MUPIP replic -source -needrestart -instsecondary=__RCV_INSTNAME__' >& needrestart4.out
$grep "Executing" needrestart4.out
echo "#	--> We expect a "NEEDS to be restarted first" message since the receiver did not connect yet."
$grep "NEEDS to be restarted first" needrestart4.out >& /dev/null
if ($status) then
	echo "TEST-E-NEEDRESTART incorrect at needrestart4.out"
endif
$MSR RUN RCV=INST1 SRC=INST3 '$gtm_tst/com/mupip_rollback.csh -verbose -fetchresync=__RCV_PORTNO__ -losttrans=lost2_INST1.glo "*"' >& rollback2_INST1.log
$grep "Executing" rollback2_INST1.log
$grep JNLSUCCESS rollback2_INST1.log
cat << EOF
  	--> We expect transactions with seqnos 101-130 in lost2_INST1.glo (X1). Note we will not need to apply this
	    since the same lost transactions (and more) are already in L2. Also check that the first line indicates
	    SECONDARY type of lost transaction file.
EOF
set firstline = `$head -n 1 lost2_INST1.glo`
if ($?gtm_chset) then
	# for UTF-8 mode we will have the first field in the header to be UTF-8. This will be filtered to go woth the test flow below.
	if ("UTF-8" == $gtm_chset) set firstline = `$head -n 1 lost2_INST1.glo|sed 's/[ ]*UTF-8$//g'`
endif
echo $firstline
echo $firstline | $tst_awk '{if ("SECONDARY" != $3) exit 1; if (4 != NF) exit 1; if ("INSTANCE1" != $NF) exit 1}'
if ($status) then
	echo "TEST-E-LOSTTRANSFILE header is not as expected in lost2_INST1!"
endif
$MSR RUN INST1 '$gtm_tst/com/analyze_jnl_extract.csh lost2_INST1.glo 101 130'  | shrink
$MSR RUN SRC=INST3 RCV=INST1 '$MUPIP replic -source -needrestart -instsecondary=__RCV_INSTNAME__' >& needrestart5.out
$grep "Executing" needrestart5.out
echo "#	--> We expect a "DOES NOT NEED to be restarted" message since a rollback was performed."
$grep "DOES NOT NEED to be restarted" needrestart5.out >& /dev/null
if ($status) then
	echo "TEST-E-NEEDRESTART incorrect at needrestart5.out"
endif
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 101'
echo "#  	--> We expect 101."

if ($gtm_test_jnl_nobefore) then
	set expect = 0
else
	set expect = 71
endif
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/dse_dump_info.csh '$expect
echo "#  	--> We expect $expect."

if ($gtm_test_jnl_nobefore) then
	# We are running with NOBEFORE_IMAGE journaling. Fetchresync rollback was done on INST2 and now we want to bring up
	# INST2 as if the databases were rolled back. Restore from backup.
	$MSR RUN INST1 '$gtm_tst/com/backup_dbjnl.csh bak3 "*.dat *.mjl* *.repl" mv'
	$MSR RUN INST1 'cp bak1/* .; '$MUPIP' set -replication=on '$tst_jnl_str' -reg "*"'
endif

$MSR STARTRCV INST3 INST1
$MSR RUN SRC=INST3 RCV=INST1 '$MUPIP replic -source -needrestart -instsecondary=__RCV_INSTNAME__' >& needrestart6.out
$grep "Executing" needrestart6.out
echo "#	--> We expect a "DOES NOT NEED to be restarted" message since the receiver is up."
$grep "DOES NOT NEED to be restarted" needrestart6.out >& /dev/null
if ($status) then
	echo "TEST-E-NEEDRESTART incorrect at needrestart6.out"
endif
$MSR SYNC INST3 INST1
$MSR STOPRCV INST3 INST1
$MSR RUN SRC=INST3 RCV=INST1 '$MUPIP replic -source -needrestart -instsecondary=__RCV_INSTNAME__' >& needrestart7.out
$grep "Executing" needrestart7.out
echo "#  --> We still expect a "DOES NOT NEED to be restarted" message since the receiver did communicate with INST1."
$grep "DOES NOT NEED to be restarted" needrestart7.out >& /dev/null
if ($status) then
	echo "TEST-E-NEEDRESTART incorrect at needrestart7.out"
endif
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 101'
echo "#  	--> We expect 101."
cat << EOF
In order to test $ZQGBLMOD returns correct values (0 AND 1), let's explicitly change the Zqgblmod Seqno and
Zqgblmod Trans fields in the fileheader to 71 (0x47). (Zqgblmod Trans might be different, since the test uses
random transaction numbers). To be safe, we'll pick up the values from the journal fileheader.
EOF
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/change_zqgblmod_seqno_tn.csh 71'
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 71'
echo "#  	--> We expect 71."
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/check_zqgblmod.csh 1:1-30 0:31-35'
cat << EOF
  	--> Expected values are: $ZQGBLMOD(^GBLA(1...30))=1,$ZQGBLMOD(^GBLA(31...35))=0
	    Note that these are the correct/safe values, i.e. if we wanted to apply L1(gbls: ^GBLA(1...30)),
	    $ZQGBLMOD says they have been modified, which is correct.
	    As for L2 (seqno 101:^GBLA(31) ... 106:^GBLA(1) ... 140:^GBLA(35)), the $ZQGBLMOD values are either
	    correct (for ^GBLA(30...35)), or simply safe (^GBLA(1...30)), i.e. the application needs to verify
	    if these globals need to be applied.
EOF

$echoline
echo "#- Step 8: Apply lost transactions (L1: lost1_INST1.glo and L2: lost2_INST2.glo)"
$MSR RUN INST3 '$gtm_tst/com/applylt_check_zqgblmod.csh lost1_INST1.glo ' >& applylt1_INST1.logx
# we should shrink msr_execute_xx.out since it has very long lines that might cause
# trouble in errors.csh (due to grep limitations on some platforms). There are other
# such shrink/moves in other files below.
mv $msr_execute_last_out ${msr_execute_last_out}x
shrink ${msr_execute_last_out}x >! $msr_execute_last_out
$grep "Executing" applylt1_INST1.logx
shrink applylt1_INST1.logx
echo '#  	--> This should succeed, but print out all updates rather than make the updates in the database (due to $ZQGBLMOD values).'
$MSR RUN INST3 '$gtm_tst/com/applylt_check_zqgblmod.csh lost2_INST2.glo ' >& applylt2_INST2.logx
mv $msr_execute_last_out ${msr_execute_last_out}x
shrink ${msr_execute_last_out}x >! $msr_execute_last_out
$grep "Executing" applylt2_INST2.logx
shrink applylt2_INST2.logx
cat << EOF
	--> This should succeed, but it will not apply all the transactions. It will apply the first 5 (seqnos
	    101-105: ^GBLA(31-35), the rest (seqnos:105-140: ^GBLA(1-35)) are expected to report $ZQGBLMOD=1.
EOF

$echoline
echo "#- Step 9:"
echo "#  On INST1, INST2, and INST3, run $gtm_tst/$tst/u_inref/dse_dump_info.csh"
if ($gtm_test_jnl_nobefore) then
	set expect = 0
else
	set expect = 71
endif
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/dse_dump_info.csh '$expect
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 71'
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 71'
echo "#  	--> We expect $expect, 71, 71 from INST1, INST2, and INST3, respectively."

$echoline
$MSR RUN INST3 '$MUPIP replic -source -losttncomplete'
echo "#  On INST1, INST2, INST3 and INST4, run $gtm_tst/$tst/u_inref/dse_dump_info.csh:"
if ($gtm_test_jnl_nobefore) then
	set expect = 0
else
	set expect = 71
endif
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/dse_dump_info.csh '$expect
echo "#  	--> We expect $expect."
$MSR RUN INST3 '$gtm_tst/$tst/u_inref/dse_dump_info.csh 0'
echo "#  	--> We expect 0."
cat << EOF
  	--> We expect 0 from INST2 and INST4. However, due to connection delays, the information might take a while to
	    make it to INST2 (and INST4). So make this step a loop, checking the value on INST2 (and INST4) and if it
	    is not 0 yet, waiting more 5 seconds, upto a minute. If it is not 0 at the end of the minute, report
	    error.

EOF
set wait = 60
set sleepinc = 5
while ($wait)
	$MSR RUN INST2 'set msr_dont_chk_stat; $gtm_tst/$tst/u_inref/dse_dump_info.csh 0' >>&! dse_dump_info2.out
	$tail -n 1 dse_dump_info2.out | $grep "The Zqgblmod seqno value is as expected" >& /dev/null
	set dse_dump_info_stat = $status
	if (! $dse_dump_info_stat) break
	$gtm_tst/com/check_error_exist.csh $msr_execute_last_out UNEXPECTEDVAL >>& notinterested.outx
	sleep $sleepinc
	@ wait = $wait - $sleepinc
end
if ($dse_dump_info_stat) then
	echo "TEST-E-COMINST2 INST2 did not get the updated value"
else
	mv dse_dump_info2.out dse_dump_info2.outx
	$grep -vE "UNEXPECTEDVAL" dse_dump_info2.outx > dse_dump_info2.out
endif

set wait = 60
while ($wait)
	$MSR RUN INST4 'set msr_dont_chk_stat; $gtm_tst/$tst/u_inref/dse_dump_info.csh 0' >>&! dse_dump_info4.out
	$tail -n 1 dse_dump_info4.out | $grep "he Zqgblmod seqno value is as expected" >& /dev/null
	set dse_dump_info_stat = $status
	if (! $dse_dump_info_stat) break
	$gtm_tst/com/check_error_exist.csh $msr_execute_last_out UNEXPECTEDVAL >>& notinterested.outx
	sleep $sleepinc
	@ wait = $wait - $sleepinc
end
if ($dse_dump_info_stat) then
	echo "TEST-E-COMINST4 INST4 did not get the updated value"
else
	mv dse_dump_info4.out dse_dump_info4.outx
	$grep -vE "UNEXPECTEDVAL" dse_dump_info4.outx > dse_dump_info4.out
endif

$echoline
echo "#- Step 10:"
$MSR STARTRCV INST3 INST1
echo "#  	--> We expect 0 from INST1 finally. However, due to possible connection delays, make this a waiting loop like the above step."
set wait = 60
while ($wait)
	$MSR RUN INST1 'set msr_dont_chk_stat; $gtm_tst/$tst/u_inref/dse_dump_info.csh 0' >>&! dse_dump_info1.out
	$tail -n 1 dse_dump_info1.out | $grep "he Zqgblmod seqno value is as expected" >& /dev/null
	set dse_dump_info_stat = $status
	if (! $dse_dump_info_stat) break
	$gtm_tst/com/check_error_exist.csh $msr_execute_last_out UNEXPECTEDVAL >>& notinterested.outx
	sleep $sleepinc
	@ wait = $wait - $sleepinc
end
if ($dse_dump_info_stat) then
	echo "TEST-E-COMINST1 INST1 did not get the updated value"
else
	mv dse_dump_info1.out dse_dump_info1.outx
	$grep -vE "UNEXPECTEDVAL" dse_dump_info1.outx > dse_dump_info1.out
endif
endif

$echoline
echo "#- Wrap up:"
$MSR SYNC ALL_LINKS
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3

cat << EOF
Also check that all of the data is indeed as expected. Let's use an extract scheme to verify this data: Take an extract
for the expected data and store it in the test system, and in the test, diff the actual extract against it.
EOF

ls INST1*.glo >& /dev/null
if ($status) then
	echo "TEST-E-EXTRACTERROR"
	exit
endif
set extfile = `ls INST1_*.glo`
shrink ${extfile} > ${extfile}.tmp
\diff $gtm_tst/$tst/outref/lost_trans_extract.glo ${extfile}.tmp
if ($status) then
	echo "TEST-E-EXTRACTINCORRECT, the data is not as expected check the above diff of:"
	echo "diff $gtm_tst/$tst/outref/lost_trans_extract.glo ${extfile}.tmp"
else
	echo "PASS"
endif
#=====================================================================
