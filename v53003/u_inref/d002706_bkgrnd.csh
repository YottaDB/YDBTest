#!/usr/local/bin/tcsh -f
#################################################################
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
# This module is derived from FIS GT.M.
#################################################################

# Helper script to start a reorg process in the background.
#
# $1 = Number used for the log file.

# Extension used is "logx" (instead of "log") since we dont want YDB-F-FORCEDHALT message to be caught by test framework.
$MUPIP reorg >& mupip_reorg_$1.logx &
