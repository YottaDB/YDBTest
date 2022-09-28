#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set allipc = ""
foreach file (*.dat)
set ipc = `$MUPIP ftok $file |& grep dat | $tst_awk '{printf("-s %s -m %s",$3,$6);}'`
set allipc = "$allipc $ipc"
end
echo $allipc
