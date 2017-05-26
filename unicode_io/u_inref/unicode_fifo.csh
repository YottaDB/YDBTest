#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$switch_chset UTF-8
# If this subtest is modified then a corresponding change to zunicode_fifo.csh may be required
# increase gtm_non_blocked_write_retries so fifo test will still pass with non-blocking writes
setenv gtm_non_blocked_write_retries 1000

source $gtm_tst/com/dbcreate.csh mumps 1
# zlink io.m so the first iteration of the test(UTF-8) will have a more similar state to the later iterations
$GTM <<EOF
zlink "io.m"
EOF
$GTM << aaa
write "do ^unicodefifo(""UTF-8"")",!
do ^unicodefifo("UTF-8")
h
aaa
#
$GTM << aaa
write "do ^unicodefifo(""UTF-16"")",!
do ^unicodefifo("UTF-16")
aaa
#
$GTM << aaa
write "do ^unicodefifo(""UTF-16LE"")",!
do ^unicodefifo("UTF-16LE")
aaa
#
$GTM << aaa
write "do ^unicodefifo(""UTF-16BE"")",!
do ^unicodefifo("UTF-16BE")
aaa
#
$GTM << aaa
write "do ^unicodefifo(""M"")",!
do ^unicodefifo("M")
aaa
#
$gtm_tst/com/dbcheck.csh
