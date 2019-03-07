#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test has BADCHAR writes as labels in routine which will trigger YDB-E-BADCHAR so avoid that
# our intention is to test only badlabels and not bad characters here. So switch to M mode.
$switch_chset "M" >&! switch_chset.log
$GTM << aaa
d ^mbadlabels
h
aaa
