#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2004, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# With spanning regions, an update to ^aslowfilling does not guarantee an update to AREG
# The "Journal State" checks that follow this wait_for_updtate.csh calls assume
# at least a single update goes to each of the regions in play
# So set ^a ^b etc (without subscripts) to guarantee that assumption
# waitupd^slowfill is not changed in order to have the $order(-1) usage with spanning regions,
# as it had helped uncover some code issues
$GTM << aaa	>>& wait_for_update.out
set i=1+\$get(^a)
set ^a=i,^b=i,^c=i,^d=i,^e=i
do waitupd^slowfill
halt
aaa
