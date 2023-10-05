#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Create database file"
$gtm_tst/com/dbcreate.csh mumps

echo "# Turn on replication in the database file"
$MUPIP set -region "*" -replic=on -inst >&! mupipset.out

setenv gtm_repl_instance "mumps.repl"

echo "# Start passive source server"
# source this to get start_time variable
source $gtm_tst/com/passive_start_upd_enable.csh >&! passive_start_`date +%H_%M_%S`.out

echo "# Perform a few updates"
$gtm_exe/mumps -run %XCMD 'for i=1:1:100 set ^x(i)=i'

echo "# Run [mupip replic -source -showbacklog]. Expect to see no WARNING message"
$MUPIP replic -source -showbacklog

$MUPIP replicate -source -shutdown -timeout=0 >& source_shutdown.out

$gtm_tst/com/dbcheck.csh

