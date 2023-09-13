#!/usr/local/bin/tcsh -f
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

# $1 - backlog limit
#
# Checks if the current backlog is <= to the input backlog limit
#
# Exits with normal status   (i.e. 0) if current backlog <= $1
# Exits with abnormal status (i.e. 1) if current backlog >  $1
#
# there is a possibility that this script is called when the test is operating on a dualsite version
# in those cases we need to nullify -instsecondary qualifier.Let's not put the onus on the test writer.
set vernow = "$gtm_exe:h:t"
if ((`expr $vernow \>= "V43001"`) && (`expr $vernow \< "V51000"`)) then
	setenv gtm_test_instsecondary
endif
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
set limit=$1
set logfile = "sb_$$_`date +%H%M%S`.log"
$MUPIP replic -source $gtm_test_instsecondary -showbacklog >& $logfile
set backlog = `$gtm_tst/com/compute_src_backlog_from_showbacklog_file.csh $logfile`
if ($backlog > $limit) then
  exit 1
else
  exit 0
endif
