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

$switch_chset UTF-8
# If this subtest is modified then a corresponding change to unicode_fifo.csh may be required
# increase gtm_non_blocked_write_retries so fifo test will still pass with non-blocking writes
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_non_blocked_write_retries gtm_non_blocked_write_retries 1000

source $gtm_tst/com/dbcreate.csh mumps 1
$GTM << aaa
write "do ^zunicodefifo(""UTF-8"")",!
do ^zunicodefifo("UTF-8")
h
aaa
#
$GTM << aaa
write "do ^zunicodefifo(""UTF-16"")",!
do ^zunicodefifo("UTF-16")
aaa
#
$GTM << aaa
write "do ^zunicodefifo(""UTF-16LE"")",!
do ^zunicodefifo("UTF-16LE")
aaa
#
$GTM << aaa
write "do ^zunicodefifo(""UTF-16BE"")",!
do ^zunicodefifo("UTF-16BE")
aaa
#
$GTM << aaa
write "do ^zunicodefifo(""M"")",!
do ^zunicodefifo("M")
aaa
#
$gtm_tst/com/dbcheck.csh
