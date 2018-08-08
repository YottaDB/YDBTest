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
echo "# Enabling auto relink"
source $gtm_tst/relink/u_inref/enable_autorelink_dirs.csh
cat > temp.m << EOF
oldtemp
	write "Old Program",!
	quit
EOF
cp temp.m oldtemp.m
cat > newtemp.m <<EOF
newtemp
	write "New Program",!
	quit
EOF

$ydb_dist/mumps -run gtm8951
echo ""
echo ""


echo "# Disabling auto relink"
source $gtm_tst/com/gtm_test_disable_autorelink.csh
cp oldtemp.m temp.m
$ydb_dist/mumps -run gtm8951
