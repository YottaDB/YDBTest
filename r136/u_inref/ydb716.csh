#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Create 2-region gld DEFAULT and AREG where AREG is AUTODB region"
$GDE >& gde.out << GDE_EOF
change -segment DEFAULT -file=default.dat
add -name A -region=AREG
add -region AREG -dyn=ASEG -autodb
add -segment ASEG -file=a.dat
GDE_EOF

echo "# Test that [mupip create] (no -REGION=) creates database file only for DEFAULT region but not for AREG (AUTODB region)"
$MUPIP create

echo "# Run [ls -1 *.dat]. Verify that only default.dat exists. a.dat does not exist."
ls -1 *.dat

echo "# Test that [mupip create -region=AREG] creates database file even though AREG is AUTODB"
$MUPIP create -region=AREG

echo "# Run [ls -1 *.dat]. Verify that a.dat did get created"
ls -1 a.dat

echo "# Test that [mupip create -region=AREG] issues File-exists error if AREG (AUTODB region) file a.dat already exists"
$MUPIP create -region=AREG

echo "# Test that [mupip create] without [-region=] issues File-exists error only for DEFAULT but not for AREG (AUTODB region)"
$MUPIP create

