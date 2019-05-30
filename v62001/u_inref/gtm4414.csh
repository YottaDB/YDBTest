#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that specifying passcurlvn lets the parent process to pass its locals to the child
$gtm_tst/com/dbcreate.csh mumps > newdbcreate.out # Create just to allow TP
$gtm_exe/mumps -run gtm4414a

echo "# Comparing the locals of the parent and child"
# First eliminate the '; *' grabage that is left behind for new'ing the original local name
sed 's/inscopealias="foo" ;\*/inscopealias="foo"/' parentlocals.out > parentlocals.outtmp
mv parentlocals.out{tmp,}
sed 's/restartvar="after" ;\*/restartvar="after"/' localsintp.out > localsintp.outtmp
mv localsintp.out{tmp,}

diff childlocals.mjo parentlocals.out
diff tstartjob.mjo localsintp.out
diff passbyrefjobjob.mjo localsinpassbyref.out

# Set a regular pattern of locals and verify they are correctly passed
$gtm_exe/mumps -run gtm4414b
if ("" != `$grep TEST\-I\-PASS gtm4414b.mjo`) then
    echo "# Verified that the locals have passed in gtm4414b"
endif

echo "# Triggering the JOBLVN2LONG error"
$truss -o trace.outx -f $gtm_exe/mumps -run joblvn2longmsg >& joblvnerror.outx
cat joblvnerror.outx
echo "# No need to wait for grandchild to quit as it would not have been started due to the JOBLVN2LONG error in grandparent"
if ($?gtm_test_autorelink_support) then
	echo "Check that relinkctl ipcs are not left over in case of JOBLVN2LONG error (GTM-8224)."
	echo "Running mupip rctldump . and verifying # of routines is 0 and # of attached processes is 1"
	$gtm_exe/mupip rctldump . |& $grep -E "# of|joblvn2longmsg"
endif
$gtm_tst/com/dbcheck.csh	# even though db was not updated, dbcheck is necessary just to balance dbcreate
