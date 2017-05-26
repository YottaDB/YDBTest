#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
$echoline
cat << EOF
Test that activating one of two passive source servers and shutting down the other one works.
INST1 -|--(P)-> INST2
       |--(P)-> INST3

EOF

$echoline
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh .

$echoline
echo "# start replication on them once over to initialize all mumps.repl files, etc."
$MSR START INST1 INST2
$MSR START INST1 INST3
$MSR STOP INST1 INST2
$MSR STOP INST1 INST3

if ("TRUE" == $gtm_test_tls) then
	set INST2_tlsid_param = "-tlsid=INSTANCE2"
	set INST3_tlsid_param = "-tlsid=INSTANCE3"
else
	set INST2_tlsid_param = ""
	set INST3_tlsid_param = ""
endif
$echoline
$MSR RUN SRC=INST1 RCV=INST2 'set msr_dont_trace; $MUPIP replic -source -passive -start -instsecondary=__RCV_INSTNAME__ -rootprimary -buffsize=$tst_buffsize -log=passive12.log '$INST2_tlsid_param
$MSR RUN SRC=INST1 RCV=INST3 'set msr_dont_trace; $MUPIP replic -source -passive -start -instsecondary=__RCV_INSTNAME__ -rootprimary -buffsize=$tst_buffsize -log=passive13.log '$INST3_tlsid_param

$echoline
$MSR STARTRCV INST1 INST2
$MSR STARTRCV INST1 INST3

$echoline
echo "#- Some simple updates on INST1"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 77'

$echoline
echo "#- Activate the passive source server to INST3:"
$MSR ACTIVATE INST1 INST3 RP

$echoline
echo "#- Shutdown the passive source server to INST2:"
$MSR RUN SRC=INST1 RCV=INST2 '$MUPIP replic -source -shutdown -instsecondary=__RCV_INSTNAME__ -timeout=0'

$echoline
echo "#- Some simple updates on INST1"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 17'
$MSR REFRESHLINK INST1 INST3
$gtm_tst/com/dbcheck.csh -extract INST1 INST3
#=====================================================================
