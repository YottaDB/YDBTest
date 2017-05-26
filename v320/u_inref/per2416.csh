#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtmgbldir per2416.gld
$gtm_tst/com/dbcreate.csh per2416 .
$GTM <<abc
w "do ^per2416",! do ^per2416
h
abc
$gtm_tst/com/dbcheck.csh
