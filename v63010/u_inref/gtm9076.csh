#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This test checks that FILEPATHTOOLONG error messages show up as expected when creating a global directory or a journal file where"
echo "# the full file path exceeds 255 characters. It also checks that the FNTRANSERROR message shows up as expected when creating a"
echo "# database file with MUPIP CREATE where the path for the database exceeds 255 characters."

set path_length = `expr length $PWD`

set path255_length = 0
set filenamelength = 11 # includes 2 "/"s (before and after the large number of "a"s)
set path255 = ""
set testpath = $PWD

while (255 >= `expr $path_length + $path255_length + $filenamelength`)
	set path255 = "${path255}a"
	set path255_length = `expr $path255_length + 1`
end

$echoline
echo "# Create a mumps.gld file in the test root directory. We will need this later for a MUPIP CREATE."

$GDE exit

$echoline
echo "# Switch to the subdirectory where the full path of mumps.gld/mumps.dat will be 256 characters"

mkdir $path255
cd $path255

$echoline
echo "# Run GDE here to create a mumps.gld, expecting a FILEPARSE error (FILEPATHTOOLONG error detail will be in GDEDUMP.DMP)"

$GDE exit

$echoline
echo "# Set ydb_gbldir to the test root's mumps.gld file."
setenv ydb_gbldir "$testpath/mumps.gld"

$echoline
echo "# Run MUPIP CREATE to create a mumps.dat, expecting a FNTRANSERROR error."
$MUPIP CREATE

$echoline
echo "# Returning to the test root directory and creating a database."
cd ..
$gtm_tst/com/dbcreate.csh mumps


$echoline
echo "# Creating a journal file with a full path of 256 characters"
$MUPIP set -journal="enable,file=${path255}/mumps.mjl" -file mumps.dat

$echoline
$gtm_tst/com/dbcheck.csh
