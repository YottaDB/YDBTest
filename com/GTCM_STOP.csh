#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# STOP the GT.CM SERVERS

set time_stamp = `date +%H_%M_%S`

$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM; $gtm_tst/com/GTCM_SERVER_STOP.csh $time_stamp >&! gtcm_stop_`date +%H_%M_%S`.log ; source $gtm_tst/com/portno_release.csh PORTNO_DEFINED_GTCM"
