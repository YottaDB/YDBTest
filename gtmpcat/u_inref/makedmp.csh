#!/usr/local/bin/tcsh -fx
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "Enter makedmp.csh"

alias dbglvlset "setenv gtmdbglvl 0x3"     # Turns on basic debug storage mgr plus gives a nice summary at end of what to expect in memory dump
alias dbglvlclr "unsetenv gtmdbglvl"
setenv gtm_trace_groups ALL
dbglvlclr

rm -f mumps.gld *.o core* GTM_FATAL_ERR* GTM_JOBEXAM.* makedmp.gld makedmp.instance.* >& /dev/null
rm -f mumps.dat acct*.dat acct*.mjl* acnm*.dat acnm*.mjl* jnl.dat jnl.mjl* mumps.mjl* unused.dat unused.mjl* makedmp_zwr.txt >& /dev/null
rm -fr repl2ndary >& /dev/null
rm -f repl.src.log >& /dev/null
rm -f mumps.coreid >& /dev/null
#
# Core file setup. For HPUX-IA64 and Solaris, execute appropriate coreadm commands so core files behave properly
#
if (("$HOSTOS" == "SunOS") || (("$HOSTOS" == "HP-UX") && ("$gtm_test_machtype" == "ia64"))) then
    coreadm -pcore.%p
endif
#
# Detect GT.M version we are running as
#
set gtmver = `$gtm_dist/mumps -run %XCMD 'Write $Piece($ZVersion," ",2),!'`
if ("$gtmver" == "") then
    echo "TEST-E-NOGTMVER Failure to detect GT.M version - exiting"
    exit 1
endif
set gtmversion=${gtmver:s/-//:s/.//}
if (1 == `expr "$gtmversion" '>=' "V61000"`) then
    set prev61000 = 0
else
    set prev61000 = 1
endif
#
# If this is V60001 or V60002, disable huge pages since these releases didn't force hugepage shared memory into corefiles which causes
# "issues" for gtmpcat. Makes the report sparse but also causes problems with the interactive cache command which is not as robust about
# probing to see if memory exists. This is more difficult to add since the gtmpcat cache command is table driven.
#
if (("V60001" == "$gtmversion") || ("V60002" == "$gtmversion")) then
    setenv gtm_test_hugepages 0
    unsetenv HUGETLB_SHM
    unsetenv HUGETLB_VERBOSE
    unsetenv HUGETLB_MORECORE
    unsetenv LD_PRELOAD
endif
#
# Make two gbldirs in primary directory.
#
setenv gtmgbldir "mumps.gld"
$gtm_dist/mumps -run ^GDE << EOF
exit
EOF
setenv gtmgbldir "makedmp.gld"
if ($prev61000) then
    $gtm_dist/mumps -run ^GDE << EOF
    @$gtm_tst/$tst/inref/makedmpPreV61000.gde
EOF
else
    $gtm_dist/mumps -run ^GDE << EOF
    @$gtm_tst/$tst/inref/makedmp.gde
EOF
endif
echo
echo "Creating primary databases"
$gtm_dist/mupip create
if (1 == `expr "$gtmversion" '>=' "V53002"`) then
    $gtm_dist/mupip set -access_method=mm -reg DEFAULT
else
    echo
    echo "Bypassing setting one (primary) region to MM due to version in use (pre-V53002)"
endif
echo
echo "Creating instance for primary"
setenv gtm_repl_instance "makedmp.instance.primrepl.inst"
$gtm_dist/mupip replicate -instance_create -name=PRIMINST $gtm_test_qdbrundown_parms
echo
echo "Enabling replication on the primary databases"
$gtm_dist/mupip set -journal=off,enable,nobefore -reg DEFAULT
if ($prev61000) then
    $gtm_dist/mupip set -region ACCT,ACNM,DEFAULT,JNL -replication=ON
    @ savestatus = $status
else
    $gtm_dist/mupip set -region ACCT1,ACCT2,ACCT3,ACNM1,ACNM2,DEFAULT,JNL -replication=ON
    @ savestatus = $status
endif
if (0 != $savestatus) then
    echo "Turning on replication failed - abort"
    exit 1
endif
echo
echo "Starting primary source server"
#
# port number setup in basic.csh
#
dbglvlset
$gtm_dist/mupip replicate -source -start -secondary=localhost:$replportno -log=repl.src.log -instsecondary=SECINST
dbglvlclr
#
# Move to secondary and set things up
#
echo
echo "Switching to secondary setup"
mkdir repl2ndary
pushd repl2ndary
if ($prev61000) then
    $gtm_dist/mumps -run ^GDE <<EOF
    @$gtm_tst/$tst/inref/makedmp2ndaryPreV61000.gde
EOF
else
    $gtm_dist/mumps -run ^GDE <<EOF
    @$gtm_tst/$tst/inref/makedmp2ndary.gde
EOF
endif
$gtm_dist/mupip create
if (1 == `expr "$gtmversion" '>=' "V53002"`) then
    $gtm_dist/mupip set -access_method=mm -reg DEFAULT
else
    echo
    echo "Bypassing setting one (secondary) region to MM due to version in use (pre-V53002)"
endif
echo
echo "Creating instance for secondary"
setenv gtm_repl_instance "makedmp.instance.secrepl.inst"
$gtm_dist/mupip replicate -instance_create -name=SECINST $gtm_test_qdbrundown_parms
echo
echo "Enabling replication on the secondary databaess"
$gtm_dist/mupip set -journal=off,enable,nobefore -reg DEFAULT
if ($prev61000) then
    $gtm_dist/mupip set -region ACCT,ACNM,DEFAULT,JNL -replication=ON
    @ savestatus = $status
else
    $gtm_dist/mupip set -region ACCT1,ACCT2,ACCT3,ACNM1,ACNM2,DEFAULT,JNL -replication=ON
    @ savestatus = $status
endif
if (0 != $savestatus) then
    echo "Turning on 2ndary replication failed - abort"
    exit 1
endif
echo
echo "Starting passive source server"
dbglvlset
$gtm_dist/mupip replicate -source -start -passive -log=repl.psvsrc.log -instsecondary=PRIMINST
echo
echo "Starting receiver server"
$gtm_dist/mupip replicate -receiver -start -listenport=$replportno -log=repl.rcv.log -helpers=4,2
dbglvlclr
popd
#
# Now back to the primary - waiting on replication servers to connect (Message in recv log: Received REPL_WILL_RESTART_WITH_INFO message)
#
echo "Waiting for replication connection"
$gtm_tst/com/wait_for_log.csh -log repl2ndary/repl.rcv.log -message "Received REPL_WILL_RESTART_WITH_INFO message" -duration 300
setenv gtm_repl_instance "makedmp.instance.primrepl.inst"
set triggerver = `expr "$gtmversion" '>=' "V54000"`
if (("pa_risc" != "$gtm_test_machtype") && (1 == $triggerver)) then
    echo
    echo "Adding triggers to database"
    $gtm_dist/mupip trigger -trig=$gtm_tst/$tst/inref/makedmp.trg
else
    echo
    echo "Not adding triggers due to GT.M version ($gtmver) not V5.4-000 or later or triggers unsupported (HPUX/HPPA)"
endif
#
# Record some output from various displays that can be checked against gtmpcat output (future enhancement)
#
$gtm_dist/mupip replicate -edit -show -detail makedmp.instance.primrepl.inst >& repl-primary-edit-show-${gtmversion}.txt
$gtm_dist/mupip replicate -source -jnlpool -detail -show >& repl-primary-src-show-${gtmversion}.txt
pushd repl2ndary
setenv gtm_repl_instance "makedmp.instance.secrepl.inst"
$gtm_dist/mupip replicate -edit -show -detail makedmp.instance.secrepl.inst >& ../repl-2ndary-edit-show-${gtmversion}.txt
$gtm_dist/mupip replicate -source -jnlpool -detail -show >& repl-2ndary-src-show-${gtmversion}.txt
setenv gtm_repl_instance "makedmp.instance.primrepl.inst"
popd
echo
dbglvlset
echo "Running makedmp program to generate core"
$gtm_dist/mumps -run makedmp
dbglvlclr
#
# Find/rename the jobexam file to use for later validation
#
set jefile = `ls -1 GTM_JOBEXAM.ZSHOW_DMP_*`
mv $jefile jobexam_output_${gtmversion}.txt
#
# Find core created by makedmp. If the name is "core", rename it so we have a predictable name
# since following cores would rename it for us not necessarily predictably.
#
set coreid = `ls -1 core*`
if ("$coreid" == "core") then
    mv core "mumpscore"
    set coreid = "mumpscore"
endif
#
# Write core fileid to file so basic.csh knows which one is the mumps core
#
echo $coreid > mumps.coreid
#
# Start killing the servers we started forcing them to core.
#
echo
echo "Killing primary source server to generate cores"
set psrcpid = `$tst_awk '/GTM Replication Source Server with Pid/ {print substr($14,2,length($14)-2)}' repl.src.log`
$kill -4 $psrcpid
#
set makedmpsclpid = `cat makedmp.job`
$kill -15 ${makedmpsclpid} >& /dev/null  # Kill the socket client process if it still exists
#
# Now work on the secondary servers - note order is important: helpers, updproc, receiver, source
#
pushd repl2ndary
setenv gtm_repl_instance "makedmp.instance.secrepl.inst"
#
set helperlist = `ls repl.rcv.log.uh* | $tst_awk '{list=list $2 " "} END {print list}' FS="_"`
if ("" == "$helperlist") then
    echo "******************"
    echo "TEST-E-NOHELPLST Helper list is null - not killing anything - may be processes and/or ipcs left over !!"
    echo "******************"
else
    foreach pid ($helperlist)
	$kill -4 $pid >& /dev/null
    end
endif
#
set supdpid = `$tst_awk '/Update Process started. PID/ {print $11}' repl.rcv.log`
$kill -4 $supdpid
#
set srcvpid = `$tst_awk '/GTM Replication Receiver Server with Pid/ {print substr($14,2,length($14)-2)}' repl.rcv.log`
$kill -4 $srcvpid
#
set ssrcpid = `$tst_awk '/GTM Replication Source Server with Pid/ {print substr($14,2,length($14)-2)}' repl.psvsrc.log`
$kill -4 $ssrcpid
#
# Wait for everything to finish dying so we can clean up
#
echo "All replication servers killed - waiting for them to disappear"
$kill -0 $psrcpid >& /dev/null
set stat = $status
while ($stat == 0)
    sleep 1
    $kill -0 $psrcpid >& /dev/null
    set stat=$status
end
$kill -0 $supdpid >& /dev/null
set stat = $status
while ($stat == 0)
    sleep 1
    $kill -0 $supdpid >& /dev/null
    set stat=$status
end
$kill -0 $srcvpid >& /dev/null
set stat=$status
while ($stat == 0)
    sleep 1
    $kill -0 $srcvpid >& /dev/null
    set stat=$status
end
$kill -0 $ssrcpid >& /dev/null
set stat=$status
while ($stat == 0)
    sleep 1
    $kill -0 $ssrcpid >& /dev/null
    set stat=$status
end
foreach pid ($helperlist)
    $kill -0 $pid >& /dev/null
    set stat = $status
    while ($stat == 0)
	sleep 1
	$kill -0 $pid >& /dev/null
	set stat = $status
    end
end
#
# Back to primary
#
popd
#
# Everything is (or should be) dead now -- cleanup the carnage (left-over IPCs) but log these messages in their
# own log since all sorts of irrelevant errors can pop up here (DBRDONLY, CRYPTINIT, etc).
#
$gtm_dist/mupip rundown >& mupip_rundown_log.txt
#
echo
echo "Disabling replication on primary side so mprof usage in basic.csh doesn't cause problems"
setenv gtm_repl_instance "makedmp.instance.primrepl.inst"
if ($prev61000) then
    $gtm_dist/mupip set -region ACCT,ACNM,DEFAULT,JNL -replication=OFF
else
    $gtm_dist/mupip set -region ACCT1,ACCT2,ACCT3,ACNM1,ACNM2,DEFAULT,JNL -replication=OFF
endif
echo
echo "Exit makedmp.csh"
#
# Until framework is fixed to make sure running in mode, just remove any %XCMD object file we may have
# created.
#
rm -f _XCMD.o
