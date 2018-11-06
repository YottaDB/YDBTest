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
$ydb_dist/dse change -fileheader -gvstatsreset >& dse_change.out
$ydb_dist/dse dump -fileheader -all | & grep DRD
$ydb_dist/dse < dse.inp > & dse.out
$ydb_dist/dse dump -fileheader -all | & grep DRD
