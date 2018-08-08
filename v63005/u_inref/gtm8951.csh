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
#
#
source $gtm_tst/relink/u_inref/enable_autorelink_dirs.csh

cat > temp.m << EOF
oldtemp
	write "Old Program",!
	quit
EOF

cat > newtemp.m <<EOF
newtemp
	write "New Program",!
	quit
EOF

$ydb_dist/mumps -run gtm8951
