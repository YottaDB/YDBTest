#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
#
set repl_file = ""
if (-e mumps.repl) set repl_file = "mumps.repl"
$MUPIP ftok *.dat *.gld >& ftok.out
$MUPIP ftok -jnlpool $repl_file >>& ftok.out
$tst_awk '{ipcftokid = substr($10, 2, 10); if ("" != ipcftokid) print ipcftokid}' ftok.out > ftok.list
$gtm_tst/com/ipcs -a | grep $USER > ipcs.list
$grep -f ftok.list ipcs.list
exit (0 == $status)
