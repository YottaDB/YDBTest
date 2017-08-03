#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "########################################################################"
echo "Time = `date`"
# Include -l option to have the "Process State" information. But not including it in the default $ps as it has some column issues
set ps = "${ps:s/ps /ps -l /}"	#BYPASSOK ps
echo "$ps"
echo "########################################################################"
$ps
echo ""

echo "########################################################################"
echo "Time = `date`"
echo "$gtm_tst/com/ipcs -a"
echo "########################################################################"
$gtm_tst/com/ipcs -a
echo ""

echo "########################################################################"
echo "Time = `date`"
echo "$netstat"
echo "########################################################################"
$netstat
echo ""

echo "########################################################################"
echo "Time = `date`"
echo "$lsof -i"
echo "########################################################################"
$lsof -i
echo ""

