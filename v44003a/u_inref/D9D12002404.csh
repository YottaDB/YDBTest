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
# This module is derived from FIS GT.M.
#################################################################
#
# D9D12-002404 [Malli] %YDB-F-GTMCHECK, Internal GT.M error
#
$GTM<<EOF
w "Testing D9D12-002404...",!
d ^gtmchk
h
EOF
