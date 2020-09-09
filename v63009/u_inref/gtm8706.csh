#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

source $gtm_tst/com/portno_acquire.csh >>& portno.out
setenv gtm_tst_ext_filter_src \""$gtm_exe/mumps -run ^extfilter"\"
setenv filter_arg "-filter=$gtm_tst_ext_filter_src"

echo "# V6.3-009 now supports the -STOPRECEIVERFILTER qualifer for MUPIP REPLICATE and is not compatible with"
echo "# any other -RECEIVER qualifer. Using the -STOPRECEIVERFILTER qualifer will turn off any active filter in"
echo "# the receiver server without turning off the receiver server, if there is no active filter a non-success"
echo "# code is returned."

$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set -journal="on,enable,nobefore" -replic=on -reg "*" >&! replication.log
setenv gtm_repl_instance mumps.repl
$MUPIP replicate -instance_create -name=mumps.repl $gtm_test_qdbrundown_parms

echo "# Starting source server and receiver server"
$ydb_dist/mupip replicate -source -start -passive -instsecondary=INSTANCE1 -buffsize=1048576 -log=source.log >>& server.log
$ydb_dist/mupip replicate -receiver -start -listen=$portno -log=receive.log $filter_arg

echo "# Using -STOPRECEIVERFILTER with an active filters"
$MUPIP REPLICATE -RECEIVER -STOPRECEIVERFILTER
$MUPIP replic -receiver -shutdown -timeout=0 >>& server.log

echo "# Using -STOPRECEIVERFILTER with no active filters"
$MUPIP replicate -receiver -start -listen=$portno -log=receive.log
$MUPIP REPLICATE -RECEIVER -STOPRECEIVERFILTER


$MUPIP replic -receiver -shutdown -timeout=0 >>& shutdown.log
$MUPIP replic -source -shutdown -timeout=0 >> shutdown.log

$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh
