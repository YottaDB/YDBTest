#################################################################
#								#
#	Copyright 2006, 2014 Fidelity Information Services, Inc	#
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
Test that a passive source server to a tertiary can be restarted (after a crash) as an active propagateprimary
INST1 --> INST2 --> INST3

EOF

$echoline
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh .
$MSR START INST1 INST2 #will start passive source server from INST2 to INST1
$MSR STARTRCV INST2 INST3
if ("TRUE" == $gtm_test_tls) then
	set INST2_tlsid_param = "-tlsid=INSTANCE2"
	set INST3_tlsid_param = "-tlsid=INSTANCE3"
else
	set INST2_tlsid_param = ""
	set INST3_tlsid_param = ""
endif
$echoline
echo "#- Start a passive propagating source server from INST2 to INST3:"
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_trace; $ps >& ps_before_pstart23.outx; source $gtm_tst/com/set_tls_env.csh; $MUPIP replic -source -passive -start -instsecondary=__RCV_INSTNAME__ -propagateprimary -log=passive23.log '$INST2_tlsid_param' < /dev/null ; $ps >& ps_after_pstart23.outx'
echo "#    	--> We expect passive source server to be running on INST2 to INST3, note down its pid (pidpass23)."
$MSR RUN SRC=INST2 RCV=INST3 '$MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__ >& checkhealth.tmp ; cat checkhealth.tmp' >& checkhealth.out
set pidpass23 = `$tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }' checkhealth.out`
echo "#- Some updates on INST1."
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 88'

$echoline
echo "#- Crash the INST2 -> INST3 passive source server:"
$MSR RUN INST2 "set msr_dont_trace ; $kill9 $pidpass23"

$echoline
echo "#- Start an active propagating source server from INST2 to INST3:"
$MSR RUN SRC=INST2 RCV=INST3 'set msr_dont_trace; $ps >& ps_before_astart23.outx; source $gtm_tst/com/set_tls_env.csh; $MUPIP replic -source -start -secondary=__RCV_HOST__:__RCV_PORTNO__ -instsecondary=__RCV_INSTNAME__ -propagateprimary -log=active23.log '$INST3_tlsid_param ' < /dev/null ; $ps >& ps_after_astart23.outx'

echo "#- Some updates on INST1"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 18'
$MSR SYNC INST1 INST2
$MSR SYNC INST2 INST3
$MSR STOPRCV INST1 INST2
$MSR RUN RCV=INST2 SRC=INST3 '$MUPIP replic -source -shutdown -instsecondary=__SRC_INSTNAME__' >& shutdown2src.log
$MSR REFRESHLINK INST1 INST2

#echoline
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3
#=====================================================================
