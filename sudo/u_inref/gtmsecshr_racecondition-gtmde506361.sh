#!/bin/bash
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Run gtmsecshr for 1 second, then terminate
while true;
do
	sleep 0.01
	if [ -e START ]; then
		break
	fi
done
$gtm_dist/gtmsecshr
sleep 1
pid=$(ps -ef | grep $gtm_dist/gtmsecshr | grep root | awk '$1 == "root" {print $2};')
kill $pid &> kill-gtmsecshr$1.pid
echo $pid &> gtmsecshr$1.pid
