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
#
# $GDE CHANGE -INSTANCE -FILE_NAME=\"\" will not work inside of an MSR RUN <inst name>
# command becuase of how special characters are handled.
#
# This script is desinged to be called inside of the MSR RUN command in order to
# work around this issue and effectively run a $GDE CHANGE -INSTANCE -FILE_NAME=""
# on the specified instance
#
# USAGE:
#	$MSR RUN <inst name> "$gtm_tst/com/rmv_map.csh"
# 	or
#	$gtm_tst/com/rmv_map.csh

# Current global directory is assumed to be `pwd`/mumps.gld
setenv gtmgbldir `pwd`/mumps.gld
setenv ydb_gbldir `pwd`/mumps.gld

$GDE CHANGE -INSTANCE -FILE_NAME=\"\"
