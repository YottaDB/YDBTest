#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This test does backward recovery (and before image journaling) which is not suppored by MM access method. Force BG access method
source $gtm_tst/com/gtm_test_setbgaccess.csh
setenv gtm_test_jnl NON_SETJNL
setenv gtm_test_mupip_set_version "V5"
$gtm_tst/com/dbcreate.csh mumps.dat
$MUPIP set -journal=on,enable,before -region "*"
# Without any database activity yet.  Expecting NOPREVLINK error but clean db after that.
$MUPIP journal -noverify -recover -backward -since=\"30-oct-1995 12:34:56\" '*'
$DSE quit
# Some database activity.  Expecting NOPREVLINK error and DBFLCORRP after that.
$GTM << EOF
set ^a=1
EOF
$MUPIP journal -noverify -recover -backward -since=\"30-oct-1995 12:34:56\" '*'
$DSE quit
# Without -noverify, recover shouldn't do any dabatase modification, so still expecting NOPREVLINK
# but a clean db after that.
$MUPIP journal -recover -backward -since=\"30-oct-1995 12:34:56\" '*'
$DSE quit
# Fix free blocks, which was changed by the previous failed '-noverify' recovery.
$DSE change -fileheader -blocks_free=62
$gtm_tst/com/dbcheck.csh
