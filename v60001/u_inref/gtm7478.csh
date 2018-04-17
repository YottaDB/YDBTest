#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# 	This test fills the database with some globals. These globals can be categorized in two sets.
# First set includes the globals from ^A to ^Z. There are 300 nodes created with these globals.
# After these updates, INTEG report is run to determine the required database blocks, say 'rb'.
# And then database is recreated but this time global buffer is set to rb(=328) value.
# 	New GTM process makes same 300 updates in freshly created database plus it makes second set
# of 100 updates. This second set of 100 updates creates 100 new globals and creates new record for
# each global in the directory tree. This record for the global in directory tree contains the collation
# information.
# 	Another GTM process starts and fetches the first set of global nodes in the global buffer and
# makes them dirty by updating them. Now instance is frozen. After this point, MUPIP JOURNAL EXTRACT
# should not go to the database to fetch collation information. This is what is verified by this test.
# Along with it, it is also tested that if the database file is missing, MUPIP JOURNAL EXTRACT should not
# try to read the database file.

$gtm_tst/com/dbcreate.csh mumps 1 64 900 1024 100 328 200
setenv gtm_custom_errors $gtm_tools/custom_errors_sample.txt
$MUPIP set -region "*" -replic=on -inst >>&! journalcfg.out
setenv gtm_repl_instance "mumps.repl"
echo "# Starting paasive server"
# source this to get start_time variable
source $gtm_tst/com/passive_start_upd_enable.csh >&! passive_start_`date +%H_%M_%S`.out
$MUPIP set -flush_time=100000 -reg "*"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_extract_nocol gtm_extract_nocol 1
$gtm_exe/mumps -run dbfill^gtm7478
# bufferfill.m logs the output in freeze.out{1,2} and dbmissing.out{1,2} for JOURNAL extract done with
# ydb_extract_nocol/gtm_extract_nocol env variable defined and without its definition for instance freezing and DB missing case.
$gtm_exe/mumps -run bufferfill^gtm7478
$gtm_tst/com/grepfile.csh 'YDB-W-DBCOLLREQ' freeze.out1 1
$gtm_tst/com/grepfile.csh 'YDB-S-JNLSUCCESS' freeze.out1 1
$gtm_tst/com/grepfile.csh 'YDB-E-SETEXTRENV' freeze.out2 1
$gtm_tst/com/grepfile.csh 'YDB-E-MUNOACTION' freeze.out2 1
$gtm_tst/com/grepfile.csh 'YDB-W-DBCOLLREQ' dbmissing.out1 1
$gtm_tst/com/grepfile.csh 'YDB-S-JNLSUCCESS' dbmissing.out1 1
$gtm_tst/com/grepfile.csh 'YDB-E-SETEXTRENV' dbmissing.out2 1
$gtm_tst/com/grepfile.csh 'YDB-E-MUNOACTION' dbmissing.out2 1
$MUPIP replicate -source -shutdown -timeout=0
mv SRC_${start_time}.log  SRC_${start_time}.logx
$grep -v REPLINSTFROZEN SRC_${start_time}.logx  >&! SRC_${start_time}.log
mv mumps.bak mumps.dat
$gtm_tst/com/dbcheck.csh
