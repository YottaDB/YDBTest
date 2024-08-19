#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This verifies that gde will write to the appropriate .gld file"
echo "# Case 1: test when gtmgbldir is undefined:"
echo "#         GDE issues ZGBLDIRUNDEF error"
echo "#"
echo "# Case 2:test when gtmgbldir is defined and:"
echo "#     Case 2a) .gld does not exist then setgd=same, make change"
echo "#     Case 2b) .gld exists then setgd=same, make change"
echo "#     Case 2c)                  setgd=new, make change"
echo "#  All 3 subtests above should not produce any errors and should create the .gld file(s)"
echo "#"

echo "# ------------------------------------------------"
echo "# Case 1) : Begin write tests of gde..."
echo "# ------------------------------------------------"
unsetenv gtmgbldir
echo "# Undefined gtmgbldir env var. Expect GDE to issue ZGBLDIRUNDEF error"
ls *.gld
echo gtmgbldir is not defined: $?gtmgbldir
$gtm_exe/mumps -run GDE << _GDE_EOF
exit
_GDE_EOF

echo "# The *.gld's are: Expect no output below"
ls -1 | grep -w gld

echo "# Expect GDEDUMP.DMP to be created"
ls -1 GDEDUMP.DMP

echo "# Verify ZGBLDIRUNDEF error shows up in GDEDUMP.DMP"
mv GDEDUMP.DMP dump.outx
$grep ZGBLDIRUNDEF dump.outx
echo "# Create dump.out to be GDEDUMP.DMP minus the ZGBLDIRUNDEF error lines"
echo "# We expect no other errors in this file. If so, test framework will catch it at end."
echo "# Hence the .out extension for this file"
$grep -v ZGBLDIRUNDEF dump.outx > dump.out

echo "# ------------------------------------------------"
echo "# Case 2a) defined and doesn't exist - set to same..."
echo "# ------------------------------------------------"
setenv gtmgbldir "acct.gld"
echo "gtmgbldir is defined : $gtmgbldir ($?gtmgbldir)"
ls *.gld
$gtm_exe/mumps -run GDE << _GDE_EOF
setgd -f="acct.gld"
change -segment DEFAULT -file_name=acct.dat
change -region DEFAULT -key_size=100
_GDE_EOF

echo "# The *.gld's are: Expect 1 .gld file [acct.gld] in output below"
ls *.gld

echo "# ------------------------------------------------"
echo "# Case 2b) defined and exists set to same..."
echo "# ------------------------------------------------"
ls *.gld
$gtm_exe/mumps -run GDE << _GDE_EOF
setgd -f="acct.gld"
change -segment DEFAULT -file_name=acct.dat
change -region DEFAULT -key_size=100
_GDE_EOF

echo "# The *.gld's are: Expect 1 .gld file [acct.gld] in output below"
ls *.gld

echo "# ------------------------------------------------"
echo "# Case 2c) defined create new .gld set to same make change..."
echo "# ------------------------------------------------"
ls *.gld
$gtm_exe/mumps -run GDE << _GDE_EOF
setgd -f="mumps.gld"
setgd -f="acct.gld"
change -segment DEFAULT -file_name=acct.dat
change -region DEFAULT -key_size=100
_GDE_EOF

echo "# The *.gld's are: Expect 2 .gld file [acct.gld and mumps.gld] in output below"
ls *.gld

echo "End write tests of gde..."
