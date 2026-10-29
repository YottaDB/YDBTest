#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1328] ZGOTO 0 from direct mode to an entryref with no label and no routine name               #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Without a label or a routine name, ZGOTO uses the current routine, which in direct mode is the'
echo '# direct mode routine GTM$DMOD. For level 0, ZGOTO unwound every frame and then failed to relink'
echo '# GTM$DMOD.'
echo '#'
echo '# The stage runs the lines shown in direct mode in a new process, and checks the output for the lines'
echo '# named, and for no fatal error.'
echo

set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1328dm"

echo '# Stage 1 : ZGOTO $ZLEVEL-1 (that is, 0) to a label that starts with $CHAR(0), which is treated as'
echo '#           no label'
echo '# Before the fix : NOTMNAME and ZLNOOBJECT for GTM$DMOD, after which $ZLEVEL was 0, in a Release build'
echo '#                  (on x86_64, the process then got a SIG-11 when it exited), and an assert in'
echo '#                  mdb_condition_handler.c in a Debug build'
echo '# With the fix   : expect RTNNAME, and the next lines to run with $ZLEVEL 1'
$dm zgdmod RTNNAME
echo

echo "# Done"
