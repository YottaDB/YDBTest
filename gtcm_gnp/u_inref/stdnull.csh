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

set stdnullcoll = $1

$DSE << DSE_EOF
	find -reg=DEFAULT
	change -file -null=TRUE
	change -file -stdnullcoll=$stdnullcoll
DSE_EOF

