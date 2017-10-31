#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2010, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that GT.CM GNP Server does not error/SIG-V out if triggers are enabled on the server side and a matching global is updated.

# AREG is local, all others for remote GT.CM servers
source $gtm_tst/com/dbcreate.csh mumps 3

$gtm_exe/mumps -run gentrigfiles^gtcmtriggers

echo "# Expect GTM-E-UNIMPLOP error when triggers that go to remote (i.e gtcm client) regions is loaded"
$MUPIP trigger -trig=remote.trg
echo "# Loading triggers that go to the local region only should work fine"
$MUPIP trigger -trig=local.trg
echo '# Select/delete/load triggers using $ztrigger()'
$gtm_exe/mumps -run gtcmtriggers
# Copy and load the trigger file on to the remote GT.CM servers
set cnt = `setenv | $grep -c -E "tst_remote_dir_[12]"`
set cntx=1
set gtcm_server_list = `setenv | $grep -E "tst_remote_host_[0-9]" | cut -f 2 -d "="`
set gtcm_server_dir_list = `setenv | $grep -E "SEC_DIR_GTCM_[0-9]" | cut -f 2 -d "="`
echo ""
echo ""
$echoline
echo "Load triggers on remote nodes. See trigload*.out for the actual trigger command"
$echoline
while ($cntx <= $cnt)
	# Use short variable names for the long $rsh commands that will follow
	set serv = $gtcm_server_list[$cntx]
	set serv_dir = $gtcm_server_dir_list[$cntx]
	set trigload_log = "trigload_$serv.out"
	echo "Load triggers on "$serv":$serv_dir" >>&! $trigload_log
	$rcp ./remote.trg "$serv":$serv_dir
	if ($status) then
		echo "TEST-E-RCPFAILED: Failed to copy remote.trg to "$serv":$serv_dir"
	endif
	$rsh $serv  "source $gtm_tst/com/remote_getenv.csh $serv_dir ; cd $serv_dir ; $MUPIP trigger -triggerfile=remote.trg" >>&! $trigload_log
	@ cntx = $cntx + 1
end

# Do updates on local and remote nodes.
echo ""
echo ""
$echoline
echo "Do updates on Local and Remote nodes. The updates to remote nodes should not invoke triggers"
$echoline
$GTM << GTM_EOF
Set ^a(1)="Update to 'a' global"	; Will happen in the local node
Set ^b(1)="Remote update"		; Will happen in the remote node. Though triggers are defined on the remote side, none
					; should be executed
Set ^x(1)="Remote update 2"		; Will happen in the remote node. Though triggers are defined on the remote side, none
					; should be executed
GTM_EOF

echo ""
echo ""
$echoline
echo "Verify that no triggers were invoked on the remote sides"
$echoline
$GTM << GTM_EOF
zwrite ^a
zwrite ^b
zwrite ^x
GTM_EOF

$gtm_tst/com/dbcheck.csh
